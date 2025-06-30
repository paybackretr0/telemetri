import 'package:firebase_core/firebase_core.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/ui/screens/auth/login_provider.dart';
import 'package:telemetri/ui/screens/profile/profile_provider.dart';
import 'package:telemetri/ui/screens/permission/permission_provider.dart';
import 'package:telemetri/ui/screens/delegation/delegation_provider.dart';
import 'package:telemetri/ui/screens/notification/notification_provider.dart';
import 'package:telemetri/ui/screens/event/activity_provider.dart';
import 'package:telemetri/ui/screens/calendar/calendar_provider.dart';
import 'package:telemetri/ui/screens/home/home_provider.dart';
import 'package:telemetri/ui/screens/history/history_provider.dart';
import 'package:telemetri/ui/screens/attendance/scan_qr_provider.dart';
import 'package:telemetri/ui/navigations/app_routes.dart';
import 'package:telemetri/ui/theme/app_theme.dart';
import 'dart:io';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:telemetri/utils/push_notification_service.dart';
import 'package:telemetri/utils/platform_helper.dart';

dynamic pushNotificationService;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    if (PlatformHelper.isAndroid) {
      try {
        await firebase.Firebase.initializeApp();
        debugPrint('Firebase initialized successfully for Android');

        pushNotificationService = PushNotificationService();
        await pushNotificationService!.init();
      } catch (e) {
        debugPrint('Error initializing Firebase for Android: $e');
      }
    } else if (PlatformHelper.isWeb) {
      if (kDebugMode) {
        debugPrint('Running on web - Firebase and push notifications skipped');
      }
    } else {
      debugPrint('Firebase and push notifications skipped for iOS');
    }

    if (PlatformHelper.isMobile) {
      HttpOverrides.global = MyHttpOverrides();
    }

    runApp(MyApp(pushNotificationService: pushNotificationService));
  } catch (e) {
    if (kDebugMode) {
      debugPrint('Error during initialization: $e');
    }
    runApp(ErrorApp(error: e.toString()));
  }
}

class ErrorApp extends StatelessWidget {
  final String error;

  const ErrorApp({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Initialization Error'),
              const SizedBox(height: 8),
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

        // UAS
        ChangeNotifierProvider(create: (_) => ActivityProvider()),
      ],
      child: MaterialApp(
        navigatorKey: pushNotificationService?.navigatorKey,
        title: 'Neo Telemetri App',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        initialRoute: RouteNames.initialRoute,
        onGenerateRoute: AppRoutes.generateRoute,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          if (kIsWeb) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child!,
            );
          }
          return child!;
        },
      ),
    );
  }
}
