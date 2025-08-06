import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class DriverScreen extends StatefulWidget {
  const DriverScreen({super.key});

  @override
  State<DriverScreen> createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  late Timer locationTimer;
  int currentIndex = 0;

  // Predefined fake route (LatLngs) for simulation
  List<LatLng> routePoints = [
    LatLng(17.391, 78.478),    // Start point (matches ParentScreen)
    LatLng(17.395, 78.475),    // Moving towards first stop
    LatLng(17.40, 78.47),      // First stop (matches ParentScreen)
    LatLng(17.405, 78.465),    // Between stops
    LatLng(17.41, 78.46),      // Moving towards second stop
    LatLng(17.42, 78.45),      // Second stop (matches ParentScreen)
    LatLng(17.435, 78.440),    // Moving towards end
    LatLng(17.445, 78.432),    // Almost at end
    LatLng(17.455, 78.425),    // End point (matches ParentScreen)
  ];

  @override
  void initState() {
    super.initState();
    startSimulatedMovement();
  }

  void startSimulatedMovement() {
    locationTimer = Timer.periodic(Duration(seconds: 3), (_) async {
      if (currentIndex >= routePoints.length) currentIndex = 0;

      final fakePosition = routePoints[currentIndex];
      currentIndex++;

      await FirebaseDatabase.instance.ref('bus_locations/bus_1').set({
        'lat': fakePosition.latitude,
        'lng': fakePosition.longitude,
      });

      log('Updated location: ${fakePosition.latitude}, ${fakePosition.longitude}');
    });
  }

  @override
  void dispose() {
    locationTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simulated Driver Movement')),
      body: Center(
        child: Text(
          'Simulating driver movement...\nWatch it on the parent screen!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
