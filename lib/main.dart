import 'package:firebase_core/firebase_core.dart' as firebaseCore;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/ui/screens/auth/login_provider.dart';
import 'package:telemetri/ui/screens/profile/profile_provider.dart';
import 'package:telemetri/ui/screens/permission/permission_provider.dart';
import 'package:telemetri/ui/screens/delegation/delegation_provider.dart';
import 'package:telemetri/ui/screens/notification/notification_provider.dart';
import 'package:telemetri/ui/screens/calendar/calendar_provider.dart';
import 'package:telemetri/ui/screens/home/home_provider.dart';
import 'package:telemetri/ui/screens/history/history_provider.dart';
import 'package:telemetri/ui/screens/attendance/scan_qr_provider.dart';
import 'package:telemetri/ui/navigations/app_routes.dart';
import 'package:telemetri/ui/theme/app_theme.dart';
import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

// Conditional imports
import 'package:telemetri/utils/push_notification_service.dart'
    if (dart.library.io) 'package:telemetri/utils/push_notification_service.dart'
    if (dart.library.js) 'package:telemetri/utils/push_notification_service_stub.dart';

dynamic pushNotificationService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    // Initialize Firebase dan push notifications hanya untuk Android
    if (Platform.isAndroid) {
      try {
        await firebaseCore.Firebase.initializeApp();
        print('Firebase initialized successfully for Android');

        pushNotificationService = PushNotificationService();
        await pushNotificationService!.init();
        print('Push notification service initialized for Android');
      } catch (e) {
        print('Error initializing Firebase for Android: $e');
      }
    } else {
      print('Firebase and push notifications skipped for iOS');
    }

    HttpOverrides.global = MyHttpOverrides();

    runApp(MyApp(pushNotificationService: pushNotificationService));
  } catch (e) {
    print('Error during initialization: $e');
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red),
              SizedBox(height: 16),
              Text('Initialization Error'),
              SizedBox(height: 8),
              Text(error, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

class MyApp extends StatelessWidget {
  final dynamic pushNotificationService;

  const MyApp({super.key, this.pushNotificationService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
        ChangeNotifierProvider(create: (_) => PermissionProvider()),
        ChangeNotifierProvider(create: (_) => DelegationProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => CalendarProvider()),
        ChangeNotifierProvider(create: (_) => HistoryProvider()),
        ChangeNotifierProvider(create: (_) => ScanQrProvider()),
      ],
      child: Consumer<LoginProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            navigatorKey: pushNotificationService?.navigatorKey,
            title: 'Neo Telemetri App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRoutes.generateRoute,
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
