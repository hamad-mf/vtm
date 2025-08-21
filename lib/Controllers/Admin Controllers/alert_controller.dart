import 'dart:developer';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int alertDistance = 20; // Default 500 meters
  bool isEnabled = false;

  // Alert state
  bool _hasAlertTriggered = false;
  DateTime? _lastAlertTime;
  static const ALERT_COOLDOWN = Duration(minutes: 5);

  AlertController() {
    _initializeNotifications().then((_) {
      forceRecreateChannel(); // Always recreate after init
    });
    loadAlertSettings();
  }

  Future<void> _initializeNotifications() async {
    const androidInitialize = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOSInitialize = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initializationSettings = InitializationSettings(
      android: androidInitialize,
      iOS: iOSInitialize,
    );

    await _notifications.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse details) async {
        log('Notification tapped: ${details.payload}');
      },
    );

    // Create custom notification channel with custom sound
    await _createNotificationChannel();
    // Request notification permissions
    await _requestNotificationPermissions();
  }

  // Create custom notification channel with proper custom sound
  Future<void> _createNotificationChannel() async {
    log('Creating bus_alerts_v3 notification channel...');

    const androidChannel = AndroidNotificationChannel(
      'bus_alerts_v3', // NEW Channel ID
      'Bus Alerts V3', // NEW Channel name
      description: 'Critical alerts for bus arrival at your destination',
      importance: Importance.max,
      enableVibration: true,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('bus_alert_sound'), // Custom sound file
    );

    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(androidChannel);
      log('✅ bus_alerts_v3 channel created successfully');
    } else {
      log('❌ Failed to get Android plugin');
    }
  }

  Future<void> _requestNotificationPermissions() async {
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      log('Notification permission granted: $granted');
    }
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
      log('Error checking alerts: $e');
    }
  }

  // High-frequency vibration using Flutter's built-in haptic feedback
  Future<void> _triggerHighFrequencyBuzz() async {
    try {
      log('Triggering high-frequency vibration buzz...');
      for (int i = 0; i < 30; i++) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 25));
      }
      await Future.delayed(const Duration(milliseconds: 50));
      for (int i = 0; i < 20; i++) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 40));
      }
      await Future.delayed(const Duration(milliseconds: 50));
      for (int i = 0; i < 25; i++) {
        await HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 20));
      }
      log('Extended high-frequency vibration completed (4+ seconds)');
    } catch (e) {
      log('Error triggering vibration: $e');
    }
  }

  // Show alert with new channel (bus_alerts_v3)
 Future<void> _showAlert(String title, String body) async {
  log('=== ALERT DEBUG INFO ===');
  log('Title: $title');
  log('Body: $body');
  log('Channel ID: bus_alerts_v3');
  log('Sound file: bus_alert_sound');
  log('========================');

  await _triggerHighFrequencyBuzz();

  // Android notification details
  final androidDetails = AndroidNotificationDetails(
    'bus_alerts_v3',
    'Bus Alerts V3',
    channelDescription: 'Critical alerts for bus arrival at your destination',
    importance: Importance.max,
    priority: Priority.high,
    enableVibration: true,
    playSound: true,
    vibrationPattern: Int64List.fromList([
      0, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 500,
    ]),
    // REMOVE or FIX the LED settings:
    // Option 1: Remove LED settings completely
    // enableLights: true,
    // ledColor: Color(0xFF00FF00),
    
    // Option 2: Add the required timing parameters
    enableLights: true,
    ledColor: const Color(0xFF00FF00),
    ledOnMs: 1000,  // LED on for 1 second
    ledOffMs: 500,  // LED off for 0.5 seconds
    
    ticker: 'Bus Alert - Get Ready!',
    autoCancel: false,
    fullScreenIntent: true,
    category: AndroidNotificationCategory.alarm,
    sound: const RawResourceAndroidNotificationSound('bus_alert_sound'),
  );

  // iOS notification details
  final iOSDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
    sound: 'bus_alert_sound.aiff', // Make sure this file exists in your iOS project
  );

  final details = NotificationDetails(
    android: androidDetails,
    iOS: iOSDetails,
  );

  try {
    await _notifications.show(0, title, body, details, payload: 'bus_arrival_alert');
    log('Alert notification shown with bus_alerts_v3 channel');
  } catch (e) {
    log('Error showing alert notification: $e');
    // Fallback: Try without LED settings
    await _showAlertFallback(title, body);
  }
}

// Fallback method without LED settings
Future<void> _showAlertFallback(String title, String body) async {
  final androidDetails = AndroidNotificationDetails(
    'bus_alerts_v3',
    'Bus Alerts V3',
    channelDescription: 'Critical alerts for bus arrival at your destination',
    importance: Importance.max,
    priority: Priority.high,
    enableVibration: true,
    playSound: true,
    vibrationPattern: Int64List.fromList([
      0, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 80, 30, 500,
    ]),
    ticker: 'Bus Alert - Get Ready!',
    autoCancel: false,
    fullScreenIntent: true,
    category: AndroidNotificationCategory.alarm,
    sound: const RawResourceAndroidNotificationSound('bus_alert_sound'),
  );

  final iOSDetails = DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  final details = NotificationDetails(
    android: androidDetails,
    iOS: iOSDetails,
  );

  await _notifications.show(0, title, body, details, payload: 'bus_arrival_alert');
}
  // Force-recreate channel for new ID
  Future<void> forceRecreateChannel() async {
    log('Force recreating notification channel...');

    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      // Delete previous v3 channel just in case, then create new
      await androidPlugin.deleteNotificationChannel('bus_alerts_v3');
      log('Deleted existing bus_alerts_v3 channel');
      await Future.delayed(Duration(milliseconds: 500));
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          'bus_alerts_v3', // NEW CHANNEL ID
          'Bus Alerts V3',
          description: 'Critical alerts for bus arrival at your destination',
          importance: Importance.max,
          enableVibration: true,
          playSound: true,
          sound: null,
        ),
      );
      log('Created new bus_alerts_v3 channel with custom sound');
    }
  }

  // Rest is unchanged (other vibration/test/utility methods) ...

  // Light buzz for testing
  Future<void> _triggerLightBuzz() async {
    try {
      for (int i = 0; i < 6; i++) {
        await HapticFeedback.lightImpact();
        await Future.delayed(const Duration(milliseconds: 80));
      }
    } catch (e) {
      log('Error triggering light buzz: $e');
    }
  }

  Future<void> _triggerMediumBuzz() async {
    try {
      for (int i = 0; i < 8; i++) {
        await HapticFeedback.mediumImpact();
        await Future.delayed(const Duration(milliseconds: 70));
      }
    } catch (e) {
      log('Error triggering medium buzz: $e');
    }
  }

  Future<void> testVibration([int level = 3]) async {
    switch (level) {
      case 1:
        await _triggerLightBuzz();
        break;
      case 2:
        await _triggerMediumBuzz();
        break;
      case 3:
        await _triggerHighFrequencyBuzz();
        break;
      default:
        await _triggerHighFrequencyBuzz();
    }
  }

  Future<void> triggerVibrationLevel(int level) async {
    await testVibration(level);
  }

  void resetAlertState() {
    _hasAlertTriggered = false;
    _lastAlertTime = null;
    notifyListeners();
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  Future<bool> checkNotificationPermissions() async {
    final android = _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    if (android != null) {
      final granted = await android.areNotificationsEnabled();
      return granted ?? false;
    }
    return true; // Assume granted for iOS
  }

  // Test method to manually trigger alert
  Future<void> testBusAlert() async {
    log('🧪 Testing bus alert with custom sound...');
    await _showAlert(
      'Test Bus Alert!',
      'This is a test alert to check custom sound functionality',
    );
  }
}
