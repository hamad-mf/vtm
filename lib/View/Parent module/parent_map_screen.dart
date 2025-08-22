import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class ParentMapScreen extends StatefulWidget {
  const ParentMapScreen({Key? key}) : super(key: key);

  @override
  State<ParentMapScreen> createState() => _ParentMapScreenState();
}

class _ParentMapScreenState extends State<ParentMapScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? mapController;

  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> routePoints = [];

  String apiKey = 'AIzaSyD4H13KH_xF8I2f7RXK2WjXCYrQSROqZek';

  // From parent -> student -> driver
  String? studentRegNo;
  String? assignedDriverId;
  String? assignedBusId;
  String? assignedRouteId;

  LatLng? routeStart;
  LatLng? routeEnd;
  List<LatLng> stops = [];
  List<LatLng> studentDestinations = [];
  LatLng? myDestination;
  LatLng? driverLocation;

  StreamSubscription<DatabaseEvent>? driverLocationStream;
  Timer? statusUpdateTimer;

  bool isLoading = true;
  String loadingMessage = "Loading route...";

  Map<String, dynamic>? routeData;
  double totalDistanceMeters = 0;
  int totalDurationSeconds = 0;
  DateTime? lastDriverUpdate;

  @override
  void initState() {
    super.initState();
    _initializeParentRoute();
  }

  Future<void> _initializeParentRoute() async {
    try {
      setState(() {
        isLoading = true;
        loadingMessage = "Finding your linked student...";
      });

      final parentUid = FirebaseAuth.instance.currentUser?.uid;
      log("parent uid :  ${parentUid}");
      if (parentUid == null) {
        setState(() {
          loadingMessage = "Not logged in";
          isLoading = false;
        });
        return;
      }

      // Fetch parent doc and get StudentRegNo
      final parentDoc =
          await _firestore.collection('parents').doc(parentUid).get();
      if (!parentDoc.exists) {
        setState(() {
          loadingMessage = "Parent profile not found";
          isLoading = false;
        });
        return;
      }
      final parentData = parentDoc.data()!;
      studentRegNo = parentData['StudentRegNo'];
      if (studentRegNo == null || studentRegNo!.isEmpty) {
        setState(() {
          loadingMessage = "No registration number in parent profile";
          isLoading = false;
        });
        return;
      }

      // Fetch linked student using regno
      final studentQuery =
          await _firestore
              .collection('students')
              .where('registrationNumber', isEqualTo: studentRegNo)
              .limit(1)
              .get();
      if (studentQuery.docs.isEmpty) {
        setState(() {
          loadingMessage = "Student not found";
          isLoading = false;
        });
        return;
      }
      final studentData = studentQuery.docs.first.data();
      assignedDriverId = studentData['assignedDriverId'];
      assignedRouteId = studentData['assignedRouteId'];
      myDestination = LatLng(
        studentData['destinationLatitude']?.toDouble() ?? 0.0,
        studentData['destinationLongitude']?.toDouble() ?? 0.0,
      );

      // Defensive: Avoid 0.0 coordinate errors
      if (myDestination!.latitude == 0.0 && myDestination!.longitude == 0.0) {
        myDestination = null;
      }

      // Fetch driver doc to get assignedBusId
      if (assignedDriverId == null || assignedDriverId!.isEmpty) {
        setState(() {
          loadingMessage = "No driver assigned";
          isLoading = false;
        });
        return;
      }
      final driverDoc =
          await _firestore.collection('drivers').doc(assignedDriverId).get();
      if (!driverDoc.exists) {
        setState(() {
          loadingMessage = "Driver profile not found";
          isLoading = false;
        });
        return;
      }
      final driverData = driverDoc.data() as Map<String, dynamic>;
      assignedBusId = driverData['assignedBusId'];

      // Fetch route data
      if (assignedRouteId == null || assignedRouteId!.isEmpty) {
        setState(() {
          loadingMessage = "No route assigned for student";
          isLoading = false;
        });
        return;
      }
      final routeDoc =
          await _firestore.collection('routes').doc(assignedRouteId).get();
      if (!routeDoc.exists) {
        setState(() {
          loadingMessage = "Route details not found";
          isLoading = false;
        });
        return;
      }
      routeData = routeDoc.data() as Map<String, dynamic>;

      await _buildRouteFromData();
      await _fetchAllStudentDestinations(assignedDriverId!);
      await _buildRouteWithDestinations();
      _listenToDriverLocation();
      _startStatusUpdateTimer();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        loadingMessage = "Error: $e";
        isLoading = false;
      });
      log('ParentMapScreen error: $e');
    }
  }

  Future<void> _buildRouteFromData() async {
    if (routeData == null) return;
    final startPoint = routeData!['startPoint'];
    final endPoint = routeData!['endPoint'];
    final stopsRaw = routeData!['stops'] as List<dynamic>? ?? [];
    routeStart = LatLng(
      (startPoint['latitude'] as num).toDouble(),
      (startPoint['longitude'] as num).toDouble(),
    );
    routeEnd = LatLng(
      (endPoint['latitude'] as num).toDouble(),
      (endPoint['longitude'] as num).toDouble(),
    );
    stops =
        stopsRaw.map((stop) {
          return LatLng(
            (stop['latitude'] as num).toDouble(),
            (stop['longitude'] as num).toDouble(),
          );
        }).toList();
  }

  Future<void> _fetchAllStudentDestinations(String assignedDriverId) async {
    try {
      final studentsSnapshot =
          await _firestore
              .collection('students')
              .where('assignedDriverId', isEqualTo: assignedDriverId)
              .get();
      studentDestinations.clear();
      for (var doc in studentsSnapshot.docs) {
        final data = doc.data();
        double? lat = data['destinationLatitude']?.toDouble();
        double? lng = data['destinationLongitude']?.toDouble();
        if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
          studentDestinations.add(LatLng(lat, lng));
        }
      }
    } catch (e) {
      log('Error fetching student destinations: $e');
    }
  }

  Future<void> _buildRouteWithDestinations() async {
    if (routeData == null || routeStart == null || routeEnd == null) return;
    try {
      List<LatLng> allWaypoints = [];
      allWaypoints.addAll(stops);
      allWaypoints.addAll(studentDestinations);
      await _fetchGoogleDirectionsRoute(routeStart!, routeEnd!, allWaypoints);
    } catch (e) {
      log('Error building route: $e');
      _createFallbackRoute();
    }
  }

  Future<void> _fetchGoogleDirectionsRoute(
    LatLng start,
    LatLng end,
    List<LatLng> waypoints,
  ) async {
    try {
      String url;
      if (waypoints.isEmpty) {
        url =
            'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=${start.latitude},${start.longitude}'
            '&destination=${end.latitude},${end.longitude}'
            '&mode=driving'
            '&units=metric'
            '&key=$apiKey';
      } else {
        List<LatLng> limitedWaypoints =
            waypoints.length > 8 ? waypoints.take(8).toList() : waypoints;
        String waypointString = limitedWaypoints
            .map((point) => '${point.latitude},${point.longitude}')
            .join('|');
        url =
            'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=${start.latitude},${start.longitude}'
            '&destination=${end.latitude},${end.longitude}'
            '&waypoints=$waypointString'
            '&mode=driving'
            '&units=metric'
            '&alternatives=false'
            '&key=$apiKey';
      }

      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final routes = data['routes'] as List;
        if (routes.isNotEmpty) {
          final route = routes[0];
          final legs = route['legs'] as List;
          List<LatLng> detailedPoints = [];
          double distanceMeters = 0;
          int durationSeconds = 0;
          for (var leg in legs) {
            distanceMeters += (leg['distance']['value'] as num).toDouble();
            durationSeconds += (leg['duration']['value'] as num).toInt();
            final steps = leg['steps'] as List;
            for (var step in steps) {
              final stepPolyline = step['polyline']['points'];
              final stepPoints = _decodePolyline(stepPolyline);
              detailedPoints.addAll(stepPoints);
            }
          }
          setState(() {
            totalDistanceMeters = distanceMeters;
            totalDurationSeconds = durationSeconds;
            routePoints =
                detailedPoints.length > 200
                    ? _samplePolylinePoints(detailedPoints, 200)
                    : detailedPoints;
          });
          _buildRoutePolyline();
          _buildRouteMarkers();
          if (mapController != null) {
            _fitCameraToRoute();
          }
        }
      } else {
        throw Exception('Directions API error: ${data['status']}');
      }
    } catch (e) {
      log('❌ Parent route fetch error: $e');
      _createFallbackRoute();
    }
  }

  void _createFallbackRoute() {
    if (routeStart == null || routeEnd == null) return;
    List<LatLng> fallbackPoints = [routeStart!];
    fallbackPoints.addAll(stops);
    fallbackPoints.addAll(studentDestinations);
    fallbackPoints.add(routeEnd!);
    setState(() {
      routePoints = fallbackPoints;
    });
    _buildRoutePolyline();
    _buildRouteMarkers();
  }

  void _buildRoutePolyline() {
    setState(() {
      polylines.clear();
      if (routePoints.isNotEmpty) {
        polylines.add(
          Polyline(
            polylineId: const PolylineId("route_polyline"),
            points: routePoints,
            color: Colors.red,
            width: 6,
            jointType: JointType.round,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
            geodesic: false,
          ),
        );
      }
    });
  }

  void _buildRouteMarkers() {
    markers.clear();

    // Start marker
    if (routeStart != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('start_point'),
          position: routeStart!,
          infoWindow: const InfoWindow(title: "Start"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
    }

    // Route stops markers
    for (int i = 0; i < stops.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('stop_$i'),
          position: stops[i],
          infoWindow: InfoWindow(title: "Stop ${i + 1}"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // My destination (highlighted)
    if (myDestination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('my_destination'),
          position: myDestination!,
          infoWindow: const InfoWindow(title: "My Child"),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueMagenta,
          ),
        ),
      );
    }

    // Other student destinations
    for (int i = 0; i < studentDestinations.length; i++) {
      if (myDestination == null || studentDestinations[i] != myDestination) {
        markers.add(
          Marker(
            markerId: MarkerId('student_dest_$i'),
            position: studentDestinations[i],
            infoWindow: const InfoWindow(title: "Student Pickup"),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow,
            ),
          ),
        );
      }
    }

    // End marker
    if (routeEnd != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('end_point'),
          position: routeEnd!,
          infoWindow: const InfoWindow(title: "End"),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    _updateDriverMarker();
    setState(() {});
  }

  void _updateDriverMarker() {
    if (driverLocation != null) {
      markers.removeWhere((m) => m.markerId.value == 'driver_marker');
      markers.add(
        Marker(
          markerId: const MarkerId('driver_marker'),
          position: driverLocation!,
          infoWindow: InfoWindow(
            title: "Bus Location",
            snippet: _getDriverStatusText(),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    }
  }

  String _getDriverStatusText() {
    if (lastDriverUpdate == null) return "Location updating...";
    final now = DateTime.now();
    final diff = now.difference(lastDriverUpdate!).inSeconds;
    if (diff < 30) {
      return "Live (${diff}s ago)";
    } else if (diff < 300) {
      return "Recent (${(diff / 60).floor()}m ago)";
    } else {
      return "Last seen ${(diff / 60).floor()}m ago";
    }
  }

  void _listenToDriverLocation() {
    if (assignedBusId == null) {
      log('❌ Cannot listen to driver location: assignedBusId is null');
      return;
    }
    driverLocationStream = FirebaseDatabase.instance
        .ref('bus_locations/$assignedBusId')
        .onValue
        .listen(
          (event) {
            final data = event.snapshot.value as Map<dynamic, dynamic>?;
            if (data == null) return;
            final lat = double.tryParse(data['lat'].toString());
            final lng = double.tryParse(data['lng'].toString());
            if (lat != null && lng != null && mounted) {
              setState(() {
                driverLocation = LatLng(lat, lng);
                lastDriverUpdate = DateTime.now();
              });
              _updateDriverMarker();
            }
          },
          onError: (error) {
            log('❌ Firebase listener error: $error');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error listening to bus location: $error'),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
  }

  void _startStatusUpdateTimer() {
    statusUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && driverLocation != null) {
        setState(() {
          _updateDriverMarker();
        });
      }
    });
  }

  void _fitCameraToRoute() {
    if (routePoints.isEmpty) return;
    double minLat = routePoints.first.latitude;
    double maxLat = routePoints.first.latitude;
    double minLng = routePoints.first.longitude;
    double maxLng = routePoints.first.longitude;
    for (LatLng point in routePoints) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }
    mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        100.0, // padding
      ),
    );
  }

  List<LatLng> _samplePolylinePoints(List<LatLng> allPoints, int targetCount) {
    if (allPoints.length <= targetCount) return allPoints;
    List<LatLng> sampledPoints = [];
    double step = (allPoints.length - 1) / (targetCount - 1);
    for (int i = 0; i < targetCount; i++) {
      int index = (i * step).round();
      if (index < allPoints.length) {
        sampledPoints.add(allPoints[index]);
      }
    }
    return sampledPoints;
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polylineCoordinates = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;
    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;
      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;
      polylineCoordinates.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return polylineCoordinates;
  }

  String formatDistance(double meters) {
    if (meters >= 1000) {
      return "${(meters / 1000).toStringAsFixed(2)} km";
    } else {
      return "${meters.toStringAsFixed(0)} m";
    }
  }

  String formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    if (d.inHours > 0) {
      return "${d.inHours}h ${d.inMinutes % 60}m";
    } else {
      return "${d.inMinutes} min";
    }
  }

  @override
  void dispose() {
    driverLocationStream?.cancel();
    statusUpdateTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live School Bus Map"),
        backgroundColor: const Color(0xFF7B60A0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _initializeParentRoute(),
          ),
          if (driverLocation != null)
            IconButton(
              icon: const Icon(Icons.my_location),
              onPressed: () {
                if (mapController != null && driverLocation != null) {
                  mapController!.animateCamera(
                    CameraUpdate.newLatLngZoom(driverLocation!, 18),
                  );
                }
              },
            ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 12),
                    Text(loadingMessage),
                  ],
                ),
              )
              : Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: routeStart ?? const LatLng(0, 0),
                      zoom: 15,
                    ),
                    markers: markers,
                    polylines: polylines,
                    onMapCreated: (controller) {
                      mapController = controller;
                      if (routePoints.isNotEmpty) {
                        _fitCameraToRoute();
                      }
                    },
                    myLocationEnabled: false,
                    myLocationButtonEnabled: false,
                    zoomControlsEnabled: true,
                    mapType: MapType.normal,
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Route: ${routeData?['routeName'] ?? 'Unknown'}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (totalDistanceMeters > 0) ...[
                            Text(
                              'Total Distance: ${formatDistance(totalDistanceMeters)}',
                            ),
                            Text(
                              'Estimated Time: ${formatDuration(totalDurationSeconds)}',
                            ),
                            const SizedBox(height: 4),
                          ],
                          // Text(
                          //   'Student Pickups: ${studentDestinations.length}',
                          // ),
                          // const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                driverLocation != null
                                    ? Icons.directions_bus
                                    : Icons.bus_alert,
                                color:
                                    driverLocation != null
                                        ? Colors.green
                                        : Colors.orange,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  driverLocation != null
                                      ? 'Bus: ${_getDriverStatusText()}'
                                      : 'Bus: Searching for location...',
                                  style: TextStyle(
                                    color:
                                        driverLocation != null
                                            ? Colors.green
                                            : Colors.orange,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              log('Manual refresh triggered');
                              _listenToDriverLocation();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Refreshing bus location...'),
                                ),
                              );
                            },
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Bus Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
    );
  }
}
