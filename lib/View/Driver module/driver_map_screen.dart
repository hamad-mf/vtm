import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:visibility_detector/visibility_detector.dart';

class DriverMapScreen extends StatefulWidget {
  const DriverMapScreen({super.key});

  @override
  State<DriverMapScreen> createState() => _DriverMapScreenState();
}

class _DriverMapScreenState extends State<DriverMapScreen> {
  bool showCustomDriverMarker = false;

  void toggleDriverMarker() {
    setState(() {
      showCustomDriverMarker = !showCustomDriverMarker;
    });
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

  double totalDistanceMeters = 0;
  int totalDurationSeconds = 0;
   GoogleMapController? mapController;
  late Timer locationUpdateTimer;

  // Map display
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  LatLng? currentDriverPosition;

  // Route data
  List<LatLng> routePoints = [];
  List<LatLng> studentDestinations = [];
  bool isRouteLoaded = false;
  bool isLocationServiceEnabled = false;

  // ⬇️ Add this new variable to track permission status
  bool hasLocationPermission = false;

  // Firebase
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Driver data
  String? driverId;
  String? assignedRouteId;
  String? assignedBusId;
  Map<String, dynamic>? routeData;

  // Google Maps API
  final String apiKey =
      'AIzaSyD4H13KH_xF8I2f7RXK2WjXCYrQSROqZek'; // Replace with your actual API key

  @override
  void initState() {
    super.initState();
    log('DriverMapScreen: initState called');
    initializeDriver();
  }

  Future<void> initializeDriver() async {
    driverId = _auth.currentUser?.uid;
    if (driverId == null) {
      _showError('Please log in as a driver');
      return;
    }

    await _requestLocationPermissions();

    // ⬇️ Only proceed if we have location permission
    if (hasLocationPermission) {
      await _fetchDriverData();
      if (assignedRouteId != null) {
        await _fetchRouteData();
        await _fetchStudentDestinations();
        await _buildRouteWithDestinations();
        _startLocationTracking();
      } else {
        _showError('No route assigned to this driver');
      }
    }
  }

  // ⬇️ Modified to update permission status and show dialog if needed
  Future<void> _requestLocationPermissions() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever ||
        permission == LocationPermission.denied) {
      setState(() {
        hasLocationPermission = false;
      });
      _showLocationPermissionDialog();
      return;
    }

    isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      setState(() {
        hasLocationPermission = false;
      });
      _showLocationPermissionDialog();
      return;
    }

    setState(() {
      hasLocationPermission = true;
    });
  }

  // ⬇️ Add this new method to show the permission dialog
  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must click retry button
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.red),
              SizedBox(width: 8),
              Text(
                'Location Permission Required',
                style: TextStyle(fontSize: 15.sp),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This app needs location permission to track your bus and show your route.',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 12),
              Text(
                'Please allow location permission to continue.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await _requestLocationPermissions(); // Try again
                if (!isLocationServiceEnabled) {
                  // Location services are still off. Prompt user to open settings.
                  await Geolocator.openLocationSettings();
                }
                // If permission granted, continue initialization
                if (hasLocationPermission) {
                  await _fetchDriverData();
                  if (assignedRouteId != null) {
                    await _fetchRouteData();
                    await _fetchStudentDestinations();
                    await _buildRouteWithDestinations();
                    _startLocationTracking();
                  } else {
                    _showError('No route assigned to this driver');
                  }
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchDriverData() async {
    try {
      DocumentSnapshot driverDoc =
          await _firestore.collection('drivers').doc(driverId).get();

      if (driverDoc.exists) {
        final data = driverDoc.data() as Map<String, dynamic>;
        assignedRouteId = data['assignedRoute'];
        assignedBusId = data['assignedBusId'];

        log('Driver data: RouteID=$assignedRouteId, BusID=$assignedBusId');
      }
    } catch (e) {
      log('Error fetching driver data: $e');
      _showError('Failed to load driver information');
    }
  }

  Future<void> _fetchRouteData() async {
    if (assignedRouteId == null) return;

    try {
      DocumentSnapshot routeDoc =
          await _firestore.collection('routes').doc(assignedRouteId).get();

      if (routeDoc.exists) {
        routeData = routeDoc.data() as Map<String, dynamic>;
        log('Route data loaded: ${routeData!['routeName']}');
      }
    } catch (e) {
      log('Error fetching route data: $e');
      _showError('Failed to load route information');
    }
  }

  Future<void> _fetchStudentDestinations() async {
    if (driverId == null) return;

    try {
      QuerySnapshot studentsSnapshot =
          await _firestore
              .collection('students')
              .where('assignedDriverId', isEqualTo: driverId)
              .get();

      studentDestinations.clear();

      for (var doc in studentsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double? lat = data['destinationLatitude']?.toDouble();
        double? lng = data['destinationLongitude']?.toDouble();

        if (lat != null && lng != null && lat != 0.0 && lng != 0.0) {
          studentDestinations.add(LatLng(lat, lng));
          log('Added student destination: $lat, $lng');
        }
      }

      log('Loaded ${studentDestinations.length} student destinations');
    } catch (e) {
      log('Error fetching student destinations: $e');
    }
  }

  Future<void> _buildRouteWithDestinations() async {
    if (routeData == null) return;

    setState(() {
      isRouteLoaded = false;
    });

    try {
      // Extract route points
      final startPoint = routeData!['startPoint'];
      final endPoint = routeData!['endPoint'];
      final stops = List<Map<String, dynamic>>.from(routeData!['stops'] ?? []);

      LatLng startLatLng = LatLng(
        startPoint['latitude'].toDouble(),
        startPoint['longitude'].toDouble(),
      );

      LatLng endLatLng = LatLng(
        endPoint['latitude'].toDouble(),
        endPoint['longitude'].toDouble(),
      );

      // Build waypoints including stops and student destinations
      List<LatLng> allWaypoints = [];

      // Add route stops
      for (var stop in stops) {
        allWaypoints.add(
          LatLng(stop['latitude'].toDouble(), stop['longitude'].toDouble()),
        );
      }

      // Add student destinations
      allWaypoints.addAll(studentDestinations);

      await _fetchGoogleDirectionsRoute(startLatLng, endLatLng, allWaypoints);
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
    // Log the route data we're trying to use
    log('=== ROUTE DEBUG INFO ===');
    log('Start Point: ${start.latitude}, ${start.longitude}');
    log('End Point: ${end.latitude}, ${end.longitude}');
    log('Waypoints: ${waypoints.length}');
    for (int i = 0; i < waypoints.length; i++) {
      log('  Waypoint $i: ${waypoints[i].latitude}, ${waypoints[i].longitude}');
    }
    log('=====================');

    if (waypoints.isEmpty) {
      // Simple route without waypoints
      final url =
          'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${start.latitude},${start.longitude}'
          '&destination=${end.latitude},${end.longitude}'
          '&mode=driving' // Specify driving mode
          '&avoid=tolls' // Optional: avoid tolls
          '&units=metric' // Use metric units
          '&key=$apiKey';

      log('API URL (no waypoints): $url');
      await _processDirectionsResponse(url, start, end, waypoints);
    } else {
      // Route with waypoints - try different approaches

      // First, try with fewer waypoints if we have too many
      List<LatLng> limitedWaypoints =
          waypoints.length > 8
              ? waypoints
                  .take(8)
                  .toList() // Reduced from 23 to 8
              : waypoints;

      // Try without optimization first
      String waypointString = limitedWaypoints
          .map((point) => '${point.latitude},${point.longitude}')
          .join('|');

      final url =
          'https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${start.latitude},${start.longitude}'
          '&destination=${end.latitude},${end.longitude}'
          '&waypoints=$waypointString' // Removed optimize:true temporarily
          '&mode=driving'
          '&units=metric'
          '&alternatives=false'
          '&key=$apiKey';

      log('API URL (with waypoints): $url');

      // If this fails, try without waypoints as fallback
      try {
        await _processDirectionsResponse(url, start, end, limitedWaypoints);
      } catch (e) {
        log('Route with waypoints failed, trying simple route: $e');

        // Fallback: try simple route without waypoints
        final simpleUrl =
            'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=${start.latitude},${start.longitude}'
            '&destination=${end.latitude},${end.longitude}'
            '&mode=driving'
            '&units=metric'
            '&key=$apiKey';

        log('Fallback API URL: $simpleUrl');
        await _processDirectionsResponse(simpleUrl, start, end, []);
      }
    }
  }

  Future<void> _processDirectionsResponse(
    String url,
    LatLng start,
    LatLng end,
    List<LatLng> waypoints,
  ) async {
    try {
      log('Fetching directions from Google API...');
      final response = await http.get(Uri.parse(url));
      final data = json.decode(response.body);

      log('API Response Status: ${data['status']}');

      if (data['status'] == 'OK') {
        final routes = data['routes'] as List;

        if (routes.isNotEmpty) {
          final route = routes[0];

          // Get the overview polyline for the entire route
          final overviewPolyline = route['overview_polyline']['points'];
          final List<LatLng> overviewPoints = _decodePolyline(overviewPolyline);

          // Also get detailed step-by-step polylines for maximum accuracy
          final legs = route['legs'] as List;
          List<LatLng> detailedPoints = [];
          double distanceMeters = 0;
          int durationSeconds = 0;
          for (var leg in legs) {
            distanceMeters += (leg['distance']['value'] as num).toDouble();
            durationSeconds += (leg['duration']['value'] as num).toInt();
          }

          setState(() {
            totalDistanceMeters = distanceMeters;
            totalDurationSeconds = durationSeconds;
          });

          for (var leg in legs) {
            final steps = leg['steps'] as List;
            for (var step in steps) {
              final stepPolyline = step['polyline']['points'];
              final stepPoints = _decodePolyline(stepPolyline);
              detailedPoints.addAll(stepPoints);
            }
          }

          // Use detailed points if available, otherwise use overview
          List<LatLng> finalPolylinePoints =
              detailedPoints.isNotEmpty ? detailedPoints : overviewPoints;

          // Don't sample too aggressively - keep more points for road accuracy
          routePoints =
              finalPolylinePoints.length > 200
                  ? _samplePolylinePoints(finalPolylinePoints, 200)
                  : finalPolylinePoints;

          log('✅ Route loaded successfully!');
          log('   - Overview points: ${overviewPoints.length}');
          log('   - Detailed points: ${detailedPoints.length}');
          log('   - Final points: ${finalPolylinePoints.length}');
          log('   - Sampled points: ${routePoints.length}');

          _buildMapMarkers(start, end, waypoints);
          _drawPolyline(finalPolylinePoints); // Draw the full detailed polyline

          setState(() {
            isRouteLoaded = true;
          });

          // Hide any previous error messages
          ScaffoldMessenger.of(context).clearSnackBars();
        } else {
          log('❌ No routes found in API response');
          _showError('No routes available in response');
          _createFallbackRoute();
        }
      } else {
        // Handle different API error statuses
        String errorMessage = 'Route planning failed';

        switch (data['status']) {
          case 'ZERO_RESULTS':
            errorMessage = 'No route found between locations';
            log(
              '❌ ZERO_RESULTS: No route found between the specified locations',
            );
            break;
          case 'OVER_QUERY_LIMIT':
            errorMessage = 'API quota exceeded';
            log('❌ OVER_QUERY_LIMIT: Google Maps API quota exceeded');
            break;
          case 'REQUEST_DENIED':
            errorMessage = 'API key invalid or restricted';
            log('❌ REQUEST_DENIED: API request denied - check API key');
            log('   Error details: ${data['error_message'] ?? 'No details'}');
            break;
          case 'INVALID_REQUEST':
            errorMessage = 'Invalid route parameters';
            log('❌ INVALID_REQUEST: Invalid route parameters');
            log('   Error details: ${data['error_message'] ?? 'No details'}');
            break;
          case 'UNKNOWN_ERROR':
            errorMessage = 'Server error occurred';
            log('❌ UNKNOWN_ERROR: Server error occurred');
            break;
          default:
            errorMessage = 'API Error: ${data['status']}';
            log('❌ Unexpected API status: ${data['status']}');
            log(
              '   Error message: ${data['error_message'] ?? 'None provided'}',
            );
        }

        _showError(errorMessage);
        _createFallbackRoute();
      }
    } catch (e) {
      log('❌ Network/Parse error: $e');
      _showError('Network error: Unable to fetch route');
      _createFallbackRoute();
    }
  }

  void _createFallbackRoute() {
    if (routeData == null) return;

    final startPoint = routeData!['startPoint'];
    final endPoint = routeData!['endPoint'];
    final stops = List<Map<String, dynamic>>.from(routeData!['stops'] ?? []);

    List<LatLng> fallbackPoints = [];

    fallbackPoints.add(
      LatLng(
        startPoint['latitude'].toDouble(),
        startPoint['longitude'].toDouble(),
      ),
    );

    for (var stop in stops) {
      fallbackPoints.add(
        LatLng(stop['latitude'].toDouble(), stop['longitude'].toDouble()),
      );
    }

    fallbackPoints.addAll(studentDestinations);

    fallbackPoints.add(
      LatLng(endPoint['latitude'].toDouble(), endPoint['longitude'].toDouble()),
    );

    routePoints = fallbackPoints;
    _buildMapMarkers(
      fallbackPoints.first,
      fallbackPoints.last,
      fallbackPoints.sublist(1, fallbackPoints.length - 1),
    );
    _drawPolyline(fallbackPoints);

    setState(() {
      isRouteLoaded = true;
    });
  }

  void _buildMapMarkers(LatLng start, LatLng end, List<LatLng> waypoints) {
    setState(() {
      markers.clear();

      // Start marker
      markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: start,
          infoWindow: const InfoWindow(title: 'Start Point'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );

      // End marker
      markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: end,
          infoWindow: const InfoWindow(title: 'End Point'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Waypoint markers
      for (int i = 0; i < waypoints.length; i++) {
        markers.add(
          Marker(
            markerId: MarkerId('waypoint_$i'),
            position: waypoints[i],
            infoWindow: InfoWindow(title: 'Stop ${i + 1}'),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueBlue,
            ),
          ),
        );
      }
    });
  }

  void _drawPolyline(List<LatLng> points) {
    setState(() {
      polylines.clear();
      polylines.add(
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          color: Colors.red,
          width: 6, // Increased width for better visibility
          patterns: [], // Solid line (no dashes)
          jointType: JointType.round, // Smooth joints
          endCap: Cap.roundCap, // Rounded end caps
          startCap: Cap.roundCap, // Rounded start caps
          geodesic: false, // Don't use geodesic lines (follow roads better)
        ),
      );
    });
  }

  int countdown = 20;
  Timer? countdownTimer;

  // Add at the top of _DriverMapScreenState class
  bool isTestingMode = false; // 🧪 SET TO FALSE FOR PRODUCTION!
  bool showDriverMarker = false;

  // Test coordinates - update these and hot reload
  LatLng testLocation = LatLng(10.192474, 76.173253);

  void _startLocationTracking() {
    if (!isLocationServiceEnabled && !isTestingMode) return;

    log('Starting location tracking...');

    if (isTestingMode) {
      log('🧪 TESTING MODE ACTIVE');
      _updateTestLocation(); // Initial marker update right away

      // Continuous simulated movement every 5 seconds
      locationUpdateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        _updateTestLocation(); // This will now cause immediate UI updates
        setState(() {
          countdown = 5;
        });
      });

      // Countdown for display
      countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (countdown > 0) {
          setState(() {
            countdown--;
          });
        }
      });
      return;
    }

    // 🚀 Production code — unchanged
    log('🚀 PRODUCTION MODE ACTIVE');
    _getCurrentLocationAndUpdate();
    locationUpdateTimer = Timer.periodic(const Duration(seconds: 20), (
      timer,
    ) async {
      await _getCurrentLocationAndUpdate();
      setState(() {
        countdown = 20;
      });
    });
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() {
          countdown--;
        });
      }
    });
  }

  void _updateTestLocation() {
    log(
      '🧪 Using test location: ${testLocation.latitude}, ${testLocation.longitude}',
    );

    // Update Firebase with simulated position
    _updateLocationInFirebase(testLocation);

    // Update map marker and force rebuild immediately
    setState(() {
      currentDriverPosition = testLocation;
      markers.removeWhere((m) => m.markerId.value == 'current_driver');
      markers.add(
        Marker(
          markerId: const MarkerId('current_driver'),
          position: testLocation,
          infoWindow: InfoWindow(
            title: 'Simulated Location',
            snippet:
                'Lat: ${testLocation.latitude}, Lng: ${testLocation.longitude}',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
        ),
      );
    });
  }

  Future<void> _getCurrentLocationAndUpdate() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15), // Add timeout
      );

      LatLng currentLocation = LatLng(position.latitude, position.longitude);

      // Log all location details
      log('=== CURRENT LOCATION UPDATE ===');
      log('Latitude: ${position.latitude}');
      log('Longitude: ${position.longitude}');
      log('Accuracy: ${position.accuracy} meters');
      log('Altitude: ${position.altitude} meters');
      log('Speed: ${position.speed} m/s');
      log('Heading: ${position.heading}°');
      log(
        'Timestamp: ${DateTime.fromMillisecondsSinceEpoch(position.timestamp.millisecondsSinceEpoch ?? 0)}',
      );
      log('=============================');

      await _updateLocationInFirebase(currentLocation);
      _updateDriverMarkerOnMap(currentLocation);
    } catch (e) {
      log('Error getting current location: $e');
      _showError('Failed to get current location: $e');
    }
  }

  Future<void> _updateLocationInFirebase(LatLng location) async {
    if (assignedBusId == null) return;

    try {
      await FirebaseDatabase.instance.ref('bus_locations/$assignedBusId').set({
        'lat': location.latitude,
        'lng': location.longitude,
        'timestamp': ServerValue.timestamp,
        'driverId': driverId,
      });

      log('Location updated: ${location.latitude}, ${location.longitude}');
    } catch (e) {
      log('Error updating location in Firebase: $e');
    }
  }

  void _updateDriverMarkerOnMap(LatLng location) {
    log(
      'Updating driver marker on map: ${location.latitude}, ${location.longitude}',
    );

    setState(() {
      currentDriverPosition = location;

      // Remove existing driver marker
      markers.removeWhere((m) => m.markerId.value == 'current_driver');

      // Only add marker if showCustomDriverMarker is true
      if (showCustomDriverMarker) {
        markers.add(
          Marker(
            markerId: const MarkerId('current_driver'),
            position: location,
            infoWindow: InfoWindow(
              title: 'Your Current Location',
              snippet:
                  'Lat: ${location.latitude.toStringAsFixed(6)}\nLng: ${location.longitude.toStringAsFixed(6)}',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueOrange,
            ),
          ),
        );
      }
    });

    try {
  if (mapController != null) {
    mapController!.animateCamera(CameraUpdate.newLatLngZoom(location, 18))
        .then((_) {
          log('✅ Camera moved successfully to current location');
        })
        .catchError((error) {
          log('❌ Error moving camera: $error');
        });
  }
} catch (e) {
  log('❌ Camera animation failed: $e');
}
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
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5), // Show longer for debugging
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );

    // Also log the error
    log('🚨 Error shown to user: $message');
  }

  @override
  void dispose() {
    locationUpdateTimer.cancel();
    countdownTimer?.cancel(); // ⬇️ Add null check for countdown timer
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final baseColor = const Color(0xFF7B60A0);
    return VisibilityDetector(
      key: Key('driver-map-visibility'),
      onVisibilityChanged: (info) {
        if (info.visibleFraction == 0) {
          // Not visible!
          locationUpdateTimer.cancel();
          countdownTimer?.cancel();
        } else {
          // Visible again, restart timers if needed
          if (locationUpdateTimer.isActive == false) {
            _startLocationTracking();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Driver Navigation'),
          backgroundColor: baseColor,
          foregroundColor: Colors.white,
          actions: [
            if (isTestingMode) // Only show in testing mode
              IconButton(
                icon: const Icon(Icons.location_on),
                onPressed: () => _updateTestLocation(), // 🔥 Manual trigger
              ),
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => initializeDriver(),
            ),
          ],
        ),
        body: Stack(
          children: [
            // ⬇️ Only show map if we have permission and route is loaded
            if (hasLocationPermission && isRouteLoaded)
              GoogleMap(
                initialCameraPosition:
                    routePoints.isNotEmpty
                        ? CameraPosition(target: routePoints.first, zoom: 18)
                        : const CameraPosition(target: LatLng(0, 0), zoom: 18),
                onMapCreated: (controller) {
                  mapController = controller;
                  log('Google Map created successfully');
                },
                onCameraMove: (CameraPosition position) {
                  // Log camera movements (optional - can be verbose)
                  // log('Camera moved to: ${position.target.latitude}, ${position.target.longitude}, zoom: ${position.zoom}');
                },
               onCameraIdle: () {
  if (mapController != null) {
    mapController!.getVisibleRegion().then((bounds) {
      log('Camera idle. Visible region: ${bounds.southwest} to ${bounds.northeast}');
    });
  }
},
                onTap: (LatLng tappedLocation) {
                  // Log tapped locations on map
                  log(
                    'Map tapped at: ${tappedLocation.latitude}, ${tappedLocation.longitude}',
                  );
                },
                markers: markers,
                polylines: polylines,
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: true,
                mapType: MapType.normal,
              )
            // ⬇️ Show loading screen if permission granted but route not loaded
            else if (hasLocationPermission && !isRouteLoaded)
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      'Loading route data...',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              )
            // ⬇️ Show permission message if no permission
            else
              const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.location_off, size: 64, color: Colors.red),
                    SizedBox(height: 16),
                    Text(
                      'Location Permission Required',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Please allow location access to use the navigation',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

            // Status panel - only show if permission granted and route loaded
            if (hasLocationPermission && isRouteLoaded)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Distance: ${formatDistance(totalDistanceMeters)}'),
                      Text('ETA: ${formatDuration(totalDurationSeconds)}'),
                      Text(
                        'Route: ${routeData?['routeName'] ?? 'Unknown'}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Students: ${studentDestinations.length}'),

                      // Text('Route Points: ${routePoints.length}'),

                      // ⬇️ Add countdown text here
                      if (showCustomDriverMarker)
                        Text(
                          'Next update in: ${countdown}s',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                          ),
                        ),
                      if (currentDriverPosition != null) ...[
                        // Text(
                        //   'Current Location:',
                        //   style: const TextStyle(fontWeight: FontWeight.w500),
                        // ),
                        // Text(
                        //   'Lat: ${currentDriverPosition!.latitude.toStringAsFixed(6)}',
                        //   style: const TextStyle(
                        //     fontSize: 12,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                        // Text(
                        //   'Lng: ${currentDriverPosition!.longitude.toStringAsFixed(6)}',
                        //   style: const TextStyle(
                        //     fontSize: 12,
                        //     color: Colors.grey,
                        //   ),
                        // ),
                        const SizedBox(height: 4),
                        if (isTestingMode)
                          ElevatedButton.icon(
                            onPressed: () {
                              if (currentDriverPosition != null) {
                                // Log current location to console
                                log('=== MANUAL LOCATION LOG ===');
                                log('Current Screen Location:');
                                log(
                                  'Latitude: ${currentDriverPosition!.latitude}',
                                );
                                log(
                                  'Longitude: ${currentDriverPosition!.longitude}',
                                );
                                log(
                                  'Formatted: ${currentDriverPosition!.latitude.toStringAsFixed(6)}, ${currentDriverPosition!.longitude.toStringAsFixed(6)}',
                                );
                                log(
                                  'Google Maps Link: https://maps.google.com/?q=${currentDriverPosition!.latitude},${currentDriverPosition!.longitude}',
                                );
                                log('========================');

                                // Also show in UI
                                _showError('Location logged to console');
                              }
                            },
                            icon: const Icon(Icons.location_on, size: 16),
                            label: const Text('Log Location'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                            ),
                          ),
                      ] else
                        const Text(
                          'Getting current location...',
                          style: TextStyle(fontSize: 12, color: Colors.orange),
                        ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
