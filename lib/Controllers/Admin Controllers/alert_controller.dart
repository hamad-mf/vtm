import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' show asin, cos, pi, sin, sqrt;

class AlertController with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  bool isLoading = false;
  String? error;

  // Alert settings
  int alertDistance = 500; // Default 500 meters
  bool isEnabled = false;

  // Alert state
  bool _hasAlertTriggered = false;
  DateTime? _lastAlertTime;
  static const ALERT_COOLDOWN = Duration(minutes: 5);

  AlertController() {
    _initializeNotifications();
    loadAlertSettings();
  }

  Future<void> _initializeNotifications() async {
    const androidInitialize = AndroidInitializationSettings('app_icon');
    const iOSInitialize = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        // Handle notification tap
      },
    );
  }

  // Calculate distance using Haversine formula
  double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371000; // Earth's radius in meters

    double lat1 = point1.latitude * (pi / 180);
    double lon1 = point1.longitude * (pi / 180);
    double lat2 = point2.latitude * (pi / 180);
    double lon2 = point2.longitude * (pi / 180);

    double dLat = lat2 - lat1;
    double dLon = lon2 - lon1;

    double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * asin(sqrt(a));
    return earthRadius * c; // Returns distance in meters
  }

  Future<void> loadAlertSettings() async {
    isLoading = true;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      final doc =
          await _firestore
              .collection('students')
              .doc(userId)
              .collection('settings')
              .doc('alerts')
              .get();

      if (doc.exists) {
        final data = doc.data()!;
        alertDistance = data['alertDistance'] ?? 500;
        isEnabled = data['isEnabled'] ?? false;
      }
    } catch (e) {
      error = 'Failed to load alert settings: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveAlertSettings({
    required int distance,
    required bool enabled,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not logged in');

      await _firestore
          .collection('students')
          .doc(userId)
          .collection('settings')
          .doc('alerts')
          .set({
            'alertDistance': distance,
            'isEnabled': enabled,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      alertDistance = distance;
      isEnabled = enabled;
      _hasAlertTriggered = false;
      _lastAlertTime = null;
    } catch (e) {
      error = 'Failed to save alert settings: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkAndTriggerAlert(LatLng busLocation) async {
    if (!isEnabled || _hasAlertTriggered) return;

    if (_lastAlertTime != null &&
        DateTime.now().difference(_lastAlertTime!) < ALERT_COOLDOWN) {
      return;
    }

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      // Get student's destination
      final studentDoc =
          await _firestore.collection('students').doc(userId).get();

      if (!studentDoc.exists) return;

      final data = studentDoc.data()!;
      final destLat = data['destinationLatitude']?.toDouble();
      final destLng = data['destinationLongitude']?.toDouble();

      if (destLat == null || destLng == null) return;

      final destination = LatLng(destLat, destLng);
      final distance = calculateDistance(busLocation, destination);

      // Check if bus is within alert distance
      if (distance <= alertDistance) {
        await _showAlert(
          'Get Ready!',
          'Bus is approximately ${distance.round()} meters from your destination',
        );
        _hasAlertTriggered = true;
        _lastAlertTime = DateTime.now();
      }
    } catch (e) {
      print('Error checking alerts: $e');
    }
  }

  Future<void> _showAlert(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'bus_alerts',
      'Bus Alerts',
      channelDescription: 'Alerts for bus arrival',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const iOSDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iOSDetails,
    );

    await _notifications.show(0, title, body, details);
  }

  void resetAlertState() {
    _hasAlertTriggered = false;
    _lastAlertTime = null;
  }
}
