import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
  FlutterLocalNotificationsPlugin();

  /// Initialize local notifications and create channels
  Future<void> initialize() async {
    log("🔧 Initializing NotificationService...");

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(initSettings,
        onDidReceiveNotificationResponse: (response) {
      log("🔔 Notification tapped: ${response.payload}");
    });

    await _createDefaultChannel();
    log("✅ NotificationService initialized");
  }

  /// Create default channel with high importance for heads-up
  Future<void> _createDefaultChannel() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        'default_channel',
        'Default Notifications',
        description: 'Default notifications for app',
        importance: Importance.high,
        playSound: true,
      ),
    );
  }

  /// Show notification (used for foreground)
  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'default_channel',
      'Default Notifications',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      details,
    );
  }

  /// Register FCM listeners
  void registerHandlers() {
    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      final title = message.notification?.title ?? '';
      final body = message.notification?.body ?? '';
      showNotification(title, body);
    });

    // App opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log("📲 Opened from background: ${message.data}");
    });

    // App opened from terminated
    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message != null) {
        log("📲 Opened from terminated: ${message.data}");
      }
    });
  }
}
