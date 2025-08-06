// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

// class ParentScreen extends StatefulWidget {
//   @override
//   _ParentScreenState createState() => _ParentScreenState();
// }

// class _ParentScreenState extends State<ParentScreen> {
//   LatLng? driverPosition;
//   late GoogleMapController mapController;
//   Set<Marker> markers = {};
//   Set<Polyline> polylines = {};

//   final String apiKey = 'AIzaSyD4H13KH_xF8I2f7RXK2WjXCYrQSROqZek';

//   final LatLng startPoint = LatLng(17.391, 78.478);
//   final LatLng endPoint = LatLng(17.455, 78.425);
//   final List<LatLng> stops = [
//     LatLng(17.40, 78.47),
//     LatLng(17.42, 78.45),
//   ];

//   // OPTIMIZATION: Cache the polyline points to avoid re-fetching
//   List<LatLng>? cachedPolylinePoints;
//   bool isPolylineLoaded = false;

//   @override
//   void initState() {
//     super.initState();
//     drawRoutePolyline();
//     fetchDriverLocation();
//   }

//   void fetchDriverLocation() {
//     FirebaseDatabase.instance.ref('bus_locations/bus_1').onValue.listen((event) {
//       final data = Map<String, dynamic>.from(event.snapshot.value as Map);

//       LatLng newDriverPosition = LatLng(data['lat'], data['lng']);

//       setState(() {
//         driverPosition = newDriverPosition;
//         markers.removeWhere((m) => m.markerId.value == 'driver');
//         markers.add(Marker(
//           markerId: MarkerId('driver'),
//           position: newDriverPosition,
//           infoWindow: InfoWindow(title: 'Bus Location'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         ));
//       });

//       // OPTIMIZATION: Reduce camera animations to save API calls
//       // Only animate if driver moved significantly (>100 meters)
//       if (driverPosition != null) {
//         double distance = _calculateDistance(driverPosition!, newDriverPosition);
//         if (distance > 0.001) { // Roughly 100 meters
//           mapController.animateCamera(
//             CameraUpdate.newLatLng(newDriverPosition),
//           );
//         }
//       }
//     });
//   }

//   // OPTIMIZATION: Calculate distance to reduce unnecessary camera moves
//   double _calculateDistance(LatLng pos1, LatLng pos2) {
//     double deltaLat = (pos1.latitude - pos2.latitude).abs();
//     double deltaLng = (pos1.longitude - pos2.longitude).abs();
//     return deltaLat + deltaLng; // Simple distance approximation
//   }

//   Future<void> drawRoutePolyline() async {
//     // OPTIMIZATION: Check if we already have cached polyline
//     if (isPolylineLoaded && cachedPolylinePoints != null) {
//       _buildPolylineFromCachedPoints();
//       return;
//     }

//     String waypoints = stops
//         .map((stop) => '${stop.latitude},${stop.longitude}')
//         .join('|');

//     final url =
//         'https://maps.googleapis.com/maps/api/directions/json?origin=${startPoint.latitude},${startPoint.longitude}&destination=${endPoint.latitude},${endPoint.longitude}&waypoints=$waypoints&key=$apiKey';

//     try {
//       final response = await http.get(Uri.parse(url));
//       final data = json.decode(response.body);

//       if (data['status'] == 'OK') {
//         final points = data['routes'][0]['overview_polyline']['points'];
//         final List<LatLng> polylinePoints = decodePolyline(points);
        
//         // OPTIMIZATION: Cache the polyline points
//         cachedPolylinePoints = polylinePoints;
//         isPolylineLoaded = true;
        
//         _buildPolylineFromPoints(polylinePoints);
//       } else {
//         log('Error fetching route: ${data['status']}');
//         // OPTIMIZATION: Fallback to simple straight line if API fails
//         _createFallbackRoute();
//       }
//     } catch (e) {
//       log('Network error: $e');
//       _createFallbackRoute();
//     }
//   }

//   // OPTIMIZATION: Build polyline from cached points
//   void _buildPolylineFromCachedPoints() {
//     if (cachedPolylinePoints != null) {
//       _buildPolylineFromPoints(cachedPolylinePoints!);
//     }
//   }

//   // OPTIMIZATION: Extract common polyline building logic
//   void _buildPolylineFromPoints(List<LatLng> polylinePoints) {
//     setState(() {
//       polylines.clear();
//       polylines.add(Polyline(
//         polylineId: PolylineId('route'),
//         points: polylinePoints,
//         color: Colors.deepPurple,
//         width: 5,
//       ));

//       // Add static markers only once
//       if (markers.where((m) => m.markerId.value == 'start').isEmpty) {
//         markers.add(Marker(
//           markerId: MarkerId('start'), 
//           position: startPoint, 
//           infoWindow: InfoWindow(title: 'Start'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ));
//       }
      
//       if (markers.where((m) => m.markerId.value == 'end').isEmpty) {
//         markers.add(Marker(
//           markerId: MarkerId('end'), 
//           position: endPoint, 
//           infoWindow: InfoWindow(title: 'End'),
//           icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         ));
//       }

//       for (int i = 0; i < stops.length; i++) {
//         if (markers.where((m) => m.markerId.value == 'stop$i').isEmpty) {
//           markers.add(Marker(
//             markerId: MarkerId('stop$i'),
//             position: stops[i],
//             infoWindow: InfoWindow(title: 'Stop ${i + 1}'),
//             icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//           ));
//         }
//       }
//     });
//   }

//   // OPTIMIZATION: Fallback route without API
//   void _createFallbackRoute() {
//     List<LatLng> simpleRoute = [
//       startPoint,
//       ...stops,
//       endPoint,
//     ];
    
//     cachedPolylinePoints = simpleRoute;
//     isPolylineLoaded = true;
//     _buildPolylineFromPoints(simpleRoute);
//   }

//   List<LatLng> decodePolyline(String encoded) {
//     List<LatLng> points = [];
//     int index = 0, len = encoded.length;
//     int lat = 0, lng = 0;

//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1F) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
//       lat += dlat;

//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1F) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
//       lng += dlng;

//       points.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//     return points;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Parent Page'),
//         backgroundColor: Colors.deepPurple,
//         foregroundColor: Colors.white,
//       ),
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(target: startPoint, zoom: 13),
//             onMapCreated: (controller) => mapController = controller,
//             markers: markers,
//             polylines: polylines,
//             myLocationEnabled: false, // OPTIMIZATION: Disable to save API calls
//             myLocationButtonEnabled: false,
//             // OPTIMIZATION: Reduce map interactions that trigger API calls
//             rotateGesturesEnabled: true,
//             scrollGesturesEnabled: true,
//             tiltGesturesEnabled: false, // Disable tilt to reduce rendering load
//             zoomControlsEnabled: true,
//             zoomGesturesEnabled: true,
//           ),
//           // OPTIMIZATION: Add loading indicator
//           if (!isPolylineLoaded)
//             Container(
//               color: Colors.black26,
//               child: Center(
//                 child: CircularProgressIndicator(
//                   valueColor: AlwaysStoppedAnimation<Color>(Colors.deepPurple),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }