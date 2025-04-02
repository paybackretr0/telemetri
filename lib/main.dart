import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:telemetri/ui/screens/auth/login_provider.dart';
import 'package:telemetri/ui/screens/profile/profile_provider.dart';
import 'package:telemetri/ui/navigations/app_routes.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:telemetri/ui/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],

      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Neo Telemetri App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            initialRoute: RouteNames.splash,
            onGenerateRoute: AppRoutes.generateRoute,
          );
        },
      ),
    );
  }
}
