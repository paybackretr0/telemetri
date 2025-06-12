import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:telemetri/ui/screens/delegation/delegation_screen.dart';

// Background message handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Background message: ${message.notification?.title}');
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  Future<void> init() async {
    await _fcm.requestPermission();
    // Get initial token
    String? token = await _fcm.getToken();
    print('FCM Token: $token');
    if (token != null) {
      await _sendTokenToBackend(token);
    }
    // Handle token refresh
    _fcm.onTokenRefresh.listen((newToken) async {
      print('New FCM Token: $newToken');
      await _sendTokenToBackend(newToken);
    });
    // Foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      if (message.notification != null) {
        final context = navigatorKey.currentState?.context;
        if (context != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${message.notification?.title}: ${message.notification?.body}',
              ),
              action: SnackBarAction(
                label: 'View',
                onPressed: () => _handleMessage(message),
              ),
            ),
          );
        }
      }
    });
    // Background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    // Handle notification opened from terminated state
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleMessage(initialMessage);
    }
    // Handle notification opened from background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse('http://192.168.1.5:8000/api/update-device-token'),
        headers: {
          'Authorization': 'Bearer <your-auth-token>',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'device_token': token}),
      );
      if (response.statusCode == 200) {
        print('Token sent to backend successfully');
      } else {
        print('Failed to send token: ${response.body}');
      }
    } catch (e) {
      print('Error sending token: $e');
    }
  }

  void _handleMessage(RemoteMessage message) {
    String? delegationId = message.data['delegation_id'];
    if (delegationId != null) {
      print('Navigate to delegation: $delegationId');
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => DelegationScreen()),
      );
    }
  }
}
