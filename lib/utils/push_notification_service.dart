import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:telemetri/ui/screens/delegation/delegation_screen.dart';
import 'package:telemetri/data/environment/env_config.dart';
import 'package:telemetri/utils/platform_helper.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

class PushNotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<void> init() async {
    if (!PlatformHelper.isAndroid) {
      return;
    }

    try {
      await _fcm.requestPermission();

      String? token = await _fcm.getToken();
      if (token != null) {
        await _sendTokenToBackend(token);
      }

      _fcm.onTokenRefresh.listen((newToken) async {
        await _sendTokenToBackend(newToken);
      });

      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
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

      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      RemoteMessage? initialMessage = await _fcm.getInitialMessage();
      if (initialMessage != null) {
        _handleMessage(initialMessage);
      }

      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessage);
    } catch (e) {
      return;
    }
  }

  Future<void> _sendTokenToBackend(String token) async {
    try {
      final response = await http.post(
        Uri.parse('${EnvConfig.apiBaseUrl}update-device-token'),
        headers: {
          'Authorization': 'Bearer <your-auth-token>',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'device_token': token}),
      );
      if (response.statusCode == 200) {
      } else {}
    } catch (e) {
      return;
    }
  }

  void _handleMessage(RemoteMessage message) {
    String? delegationId = message.data['delegation_id'];
    if (delegationId != null) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => DelegationScreen()),
      );
    }
  }
}
