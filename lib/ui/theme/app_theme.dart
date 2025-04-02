import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color(0xFF2147C7),
      scaffoldBackgroundColor: Colors.white,
      fontFamily: 'Raleway',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Raleway'),
        displayMedium: TextStyle(fontFamily: 'Raleway'),
        displaySmall: TextStyle(fontFamily: 'Raleway'),
        headlineLarge: TextStyle(fontFamily: 'Raleway'),
        headlineMedium: TextStyle(fontFamily: 'Raleway'),
        headlineSmall: TextStyle(fontFamily: 'Raleway'),
        titleLarge: TextStyle(fontFamily: 'Raleway'),
        titleMedium: TextStyle(fontFamily: 'Raleway'),
        titleSmall: TextStyle(fontFamily: 'Raleway'),
        bodyLarge: TextStyle(fontFamily: 'Raleway'),
        bodyMedium: TextStyle(fontFamily: 'Raleway'),
        bodySmall: TextStyle(fontFamily: 'Raleway'),
        labelLarge: TextStyle(fontFamily: 'Raleway'),
        labelMedium: TextStyle(fontFamily: 'Raleway'),
        labelSmall: TextStyle(fontFamily: 'Raleway'),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      primaryColor: const Color(0xFF2147C7),
      scaffoldBackgroundColor: Colors.black,
      fontFamily: 'Raleway',
      brightness: Brightness.dark,
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontFamily: 'Raleway'),
        displayMedium: TextStyle(fontFamily: 'Raleway'),
      ),
    );
  }
}
