import 'package:flutter/material.dart';
import 'platform_helper.dart';

class ResponsiveHelper {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 768;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 768 &&
      MediaQuery.of(context).size.width < 1024;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  static bool isLargeScreen(BuildContext context) =>
      MediaQuery.of(context).size.width > 1200;

  static double getScreenWidth(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static int getCrossAxisCount(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }

  static EdgeInsets getContentPadding(BuildContext context) {
    if (PlatformHelper.isWeb) {
      if (isDesktop(context)) {
        return const EdgeInsets.symmetric(horizontal: 64, vertical: 24);
      } else if (isTablet(context)) {
        return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
      }
      return const EdgeInsets.all(24);
    }
    return const EdgeInsets.all(16);
  }

  static double getMaxContentWidth(BuildContext context) {
    if (PlatformHelper.isWeb && isDesktop(context)) {
      return 1200;
    }
    return double.infinity;
  }
}
