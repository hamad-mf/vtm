import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

import 'package:flutter/services.dart' show rootBundle;

class FCMService {
  /// Get OAuth2 Access Token from the service account JSON
  static Future<String> _getAccessToken() async {
    final serviceAccount = json.decode(
      await rootBundle.loadString('assets/vtm_service.json'),
    );

    final accountCredentials = ServiceAccountCredentials.fromJson(serviceAccount);
    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(accountCredentials, scopes);

    final accessToken = client.credentials.accessToken.data;
    client.close();

    return accessToken;
  }

  /// Send a notification to a specific device token
  static Future<void> sendNotificationToToken({
    required String token,
    required String title,
    required String body,
    required String projectId,
  }) async {
    final accessToken = await _getAccessToken();

    final url = Uri.parse(
      'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
    );

    final message = {
      "message": {
        "token": token,
        "notification": {
          "title": title,
          "body": body,
        },
        "android": {
          "notification": {
            "channel_id": "default_channel"
          }
        },
        "data": {
          "click_action": "FLUTTER_NOTIFICATION_CLICK"
        }
      }
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
      body: jsonEncode(message),
    );

    log("📨 FCM Response: ${response.statusCode} - ${response.body}");
  }
}
