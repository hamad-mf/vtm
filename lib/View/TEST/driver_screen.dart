// import 'dart:async';
// import 'dart:convert';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;

// class DriverScreen extends StatefulWidget {
//   const DriverScreen({super.key});

//   @override
//   State<DriverScreen> createState() => _DriverScreenState();
// }

// class _DriverScreenState extends State<DriverScreen> {
//   late Timer locationTimer;
//   int currentIndex = 0;
//   List<LatLng> routePoints = [];
//   bool isRouteLoaded = false;

//   final String apiKey = 'AIzaSyD4H13KH_xF8I2f7RXK2WjXCYrQSROqZek';
  
//   // Same route as ParentScreen
//   final LatLng startPoint = LatLng(17.391, 78.478);
//   final LatLng endPoint = LatLng(17.455, 78.425);
//   final List<LatLng> stops = [
//     LatLng(17.40, 78.47),
//     LatLng(17.42, 78.45),
//   ];

//   @override
//   void initState() {
//     super.initState();
//     fetchActualRoute();
//   }

//   // SOLUTION: Fetch the actual Google Directions route
//   Future<void> fetchActualRoute() async {
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
        
//         setState(() {
//           // SOLUTION: Use actual polyline points, but sample them for smoother movement
//           routePoints = samplePolylinePoints(polylinePoints, 20); // Get ~20 points
//           isRouteLoaded = true;
//         });
        
//         log('Route loaded with ${routePoints.length} points');
//         startSimulatedMovement();
//       } else {
//         log('Error fetching route: ${data['status']}');
//         // Fallback to simple route
//         createFallbackRoute();
//       }
//     } catch (e) {
//       log('Network error: $e');
//       createFallbackRoute();
//     }
//   }

//   // SOLUTION: Sample points from polyline for smooth movement
//   List<LatLng> samplePolylinePoints(List<LatLng> allPoints, int targetCount) {
//     if (allPoints.length <= targetCount) return allPoints;
    
//     List<LatLng> sampledPoints = [];
//     double step = (allPoints.length - 1) / (targetCount - 1);
    
//     for (int i = 0; i < targetCount; i++) {
//       int index = (i * step).round();
//       if (index < allPoints.length) {
//         sampledPoints.add(allPoints[index]);
//       }
//     }
    
//     return sampledPoints;
//   }

//   // Fallback if API fails
//   void createFallbackRoute() {
//     setState(() {
//       routePoints = [
//         startPoint,
//         ...stops,
//         endPoint,
//       ];
//       isRouteLoaded = true;
//     });
//     startSimulatedMovement();
//   }

//   void startSimulatedMovement() {
//     if (!isRouteLoaded || routePoints.isEmpty) return;
    
//     locationTimer = Timer.periodic(Duration(seconds: 3), (_) async {
//       if (currentIndex >= routePoints.length) {
//         currentIndex = 0; // Loop back to start
//       }

//       final fakePosition = routePoints[currentIndex];
//       currentIndex++;

//       await FirebaseDatabase.instance.ref('bus_locations/bus_1').set({
//         'lat': fakePosition.latitude,
//         'lng': fakePosition.longitude,
//       });

//       log('Updated location: ${fakePosition.latitude}, ${fakePosition.longitude} (Point ${currentIndex}/${routePoints.length})');
//     });
//   }

//   // Google Polyline decoder
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
//   void dispose() {
//     if (locationTimer != null) locationTimer.cancel();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Simulated Driver Movement'),
//         backgroundColor: Colors.green,
//         foregroundColor: Colors.white,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             if (!isRouteLoaded)
//               Column(
//                 children: [
//                   CircularProgressIndicator(),
//                   SizedBox(height: 16),
//                   Text('Loading route...'),
//                 ],
//               )
//             else
//               Column(
//                 children: [
//                   Icon(Icons.directions_bus, size: 60, color: Colors.green),
//                   SizedBox(height: 16),
//                   Text(
//                     'Simulating driver movement...\nFollowing actual road route!',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 18),
//                   ),
//                   SizedBox(height: 16),
//                   Text(
//                     'Route Points: ${routePoints.length}\nCurrent: ${currentIndex}/${routePoints.length}',
//                     textAlign: TextAlign.center,
//                     style: TextStyle(fontSize: 14, color: Colors.grey[600]),
//                   ),
//                 ],
//               ),
//           ],
//         ),
//       ),
//     );
//   }
// }