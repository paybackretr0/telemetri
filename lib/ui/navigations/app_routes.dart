import 'package:flutter/material.dart';
import 'package:telemetri/ui/screens/faq/faq_screen.dart';
import 'package:telemetri/ui/screens/splash/splash_screen.dart';
import 'package:telemetri/ui/screens/home/home_screen.dart';
import 'package:telemetri/ui/screens/auth/login_screen.dart';
import 'package:telemetri/ui/screens/calendar/calendar_screen.dart';
import 'package:telemetri/ui/navigations/main_container.dart';
import 'package:telemetri/ui/screens/attendance/scan_qr_screen.dart';
import 'package:telemetri/ui/screens/history/history_screen.dart';
import 'package:telemetri/ui/screens/profile/profile_screen.dart';
import 'package:telemetri/ui/screens/notification/notification_screen.dart';
import 'package:telemetri/ui/screens/about/about_screen.dart';

class RouteNames {
  static const main = '/main';
  static const splash = '/';
  static const home = '/home';
  static const login = '/login';
  static const calendar = '/calendar';
  static const scanQR = '/scan-qr';
  static const history = '/history';
  static const profile = '/profile';
  static const notification = '/notification';
  static const faq = '/faq';
  static const about = '/about';
}

class AppRoutes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RouteNames.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case RouteNames.main:
        final args = settings.arguments as Map<String, dynamic>?;
        final initialIndex =
            args != null ? args['initialIndex'] as int? ?? 0 : 0;
        return MaterialPageRoute(
          builder: (_) => MainContainer(initialIndex: initialIndex),
        );
      case RouteNames.home:
        return MaterialPageRoute(builder: (_) => const HomeScreen(key: null));
      case RouteNames.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case RouteNames.calendar:
        return MaterialPageRoute(builder: (_) => const CalendarScreen());
      case RouteNames.scanQR:
        return MaterialPageRoute(builder: (_) => const ScanQRScreen());
      case RouteNames.history:
        return MaterialPageRoute(builder: (_) => const HistoryScreen());
      case RouteNames.profile:
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      case RouteNames.notification:
        return MaterialPageRoute(builder: (_) => const NotificationScreen());
      case RouteNames.faq:
        return MaterialPageRoute(builder: (_) => const FaqScreen());
      case RouteNames.about:
        return MaterialPageRoute(builder: (_) => const AboutScreen());
      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
        );
    }
  }
}
