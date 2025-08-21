// import 'dart:developer';
// import 'dart:typed_data';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// class NotificationService {
//   static final FlutterLocalNotificationsPlugin
//       _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

//   /// Initialize local notification plugin and create channels
//   Future<void> initialize() async {
//     log("🔧 Initializing NotificationService...");

//     // Android initialization settings
//     const AndroidInitializationSettings androidInitializationSettings =
//         AndroidInitializationSettings('@mipmap/ic_launcher');

//     final InitializationSettings initializationSettings =
//         InitializationSettings(
//       android: androidInitializationSettings,
//     );

//     await _flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         log("🔔 Notification tapped with payload: ${response.payload}");
//       },
//     );

//     // Create notification channels with custom sounds
//     await _createNotificationChannels();
//     log("✅ NotificationService initialized successfully");
//   }

//   /// Create notification channels for bus alerts
//   Future<void> _createNotificationChannels() async {
//     log("📡 Creating notification channels...");

//     final androidImplementation =
//         _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
//             AndroidFlutterLocalNotificationsPlugin>();

//     // Bus alert channel with custom sound
//     await androidImplementation?.createNotificationChannel(
//       const AndroidNotificationChannel(
//         'bus_alerts_v2',
//         'bus_alerts_v2',
//         description: 'Critical alerts for bus arrival at your destination',
//         importance: Importance.max,
//         sound: RawResourceAndroidNotificationSound('bus_alert_sound'),
//         playSound: true,
//         enableVibration: true,
//       ),
//     );

//     // Default channel
//     await androidImplementation?.createNotificationChannel(
//       const AndroidNotificationChannel(
//         'default_channel',
//         'Default Notifications',
//         description: 'Default notification sound',
//         importance: Importance.high,
//         playSound: true,
//       ),
//     );

//     log("✅ All channels created successfully");
//   }

//   /// Register push notification handlers
//   void registerHandlers() {
//     log("🔧 Registering push notification handlers...");

//     // Foreground message handler
//     FirebaseMessaging.onMessage.listen((RemoteMessage message) {
//       log("📱 Received foreground message: ${message.notification?.title}");
      
//       String title = message.notification?.title ?? 'New Notification';
//       String body = message.notification?.body ?? '';
//       String type = message.data['type'] ?? 'default';

//       _showCustomNotification(title: title, body: body, type: type);
//     });

//     // Background tap handler
//     FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
//       _handleNotificationTap(message);
//     });

//     // Terminated state handler
//     FirebaseMessaging.instance
//         .getInitialMessage()
//         .then((RemoteMessage? message) {
//       if (message != null) _handleNotificationTap(message);
//     });

//     log("✅ Push notification handlers registered");
//   }

//   /// Show custom notification with correct channel
//   Future<void> _showCustomNotification({
//     required String title,
//     required String body,
//     required String type,
//   }) async {
//     log("📱 Showing notification: $title, $body, $type");

//     // Use bus_alerts channel for bus-related notifications
//     String channelId = type.contains('bus') || type.contains('alert') 
//         ? 'bus_alerts_v2' 
//         : 'default_channel';
    
//     String channelName = channelId == 'bus_alerts_v2' 
//         ? 'bus_alerts_v2' 
//         : 'Default Notifications';

//     final androidDetails = AndroidNotificationDetails(
//       channelId,
//       channelName,
//       importance: Importance.max,
//       priority: Priority.high,
//       icon: '@mipmap/ic_launcher',
//       color: Colors.blue,
//       playSound: true,
//       enableVibration: true,
//       styleInformation: BigTextStyleInformation(body),
//       // Add vibration pattern for bus alerts
//       vibrationPattern: channelId == 'bus_alerts_v2' 
//           ? Int64List.fromList([0, 250, 250, 250])
//           : null,
//     );

//     final NotificationDetails platformChannelSpecifics =
//         NotificationDetails(android: androidDetails);

//     final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
//     try {
//       await _flutterLocalNotificationsPlugin.show(
//         id,
//         title,
//         body,
//         platformChannelSpecifics,
//         payload: 'custom_notification_payload',
//       );
//       log("✅ Notification shown successfully on $channelId");
//     } catch (e) {
//       log("❌ Error showing notification: $e");
//     }
//   }

//   /// Handle notification tap
//   void _handleNotificationTap(RemoteMessage message) {
//     log("🔔 Handling notification tap: ${message.data}");
//     // Add your navigation logic here
//   }

//   /// Test notification for debugging
//   Future<void> showTestNotification() async {
//     await _showCustomNotification(
//       type: 'bus_alerts_v2',
//       title: 'Test Bus Alert',
//       body: 'Testing bus alert notification with custom sound',
//     );
//   }
// }