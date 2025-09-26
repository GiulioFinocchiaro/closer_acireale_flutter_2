import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

class ResponsiveUtils {
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < AppConstants.mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= AppConstants.mobileBreakpoint && 
           width < AppConstants.desktopBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= AppConstants.desktopBreakpoint;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  // Restituisce il numero di colonne per la griglia basato sulla larghezza schermo
  static int getGridCrossAxisCount(BuildContext context, {
    int mobileColumns = 1,
    int tabletColumns = 2,
    int desktopColumns = 3,
  }) {
    if (isMobile(context)) return mobileColumns;
    if (isTablet(context)) return tabletColumns;
    return desktopColumns;
  }

  // Restituisce padding responsivo
  static EdgeInsets getResponsivePadding(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    double padding;
    
    if (isMobile(context)) {
      padding = mobile ?? AppConstants.defaultPadding;
    } else if (isTablet(context)) {
      padding = tablet ?? AppConstants.cardPadding;
    } else {
      padding = desktop ?? AppConstants.cardPadding * 1.5;
    }
    
    return EdgeInsets.all(padding);
  }

  // Restituisce font size responsivo
  static double getResponsiveFontSize(BuildContext context, {
    double? mobile,
    double? tablet,
    double? desktop,
  }) {
    if (isMobile(context)) {
      return mobile ?? 14;
    } else if (isTablet(context)) {
      return tablet ?? 16;
    } else {
      return desktop ?? 18;
    }
  }

  // Restituisce la larghezza massima per i container
  static double getMaxContainerWidth(BuildContext context) {
    if (isMobile(context)) {
      return getScreenWidth(context);
    } else if (isTablet(context)) {
      return getScreenWidth(context) * 0.9;
    } else {
      return 1200; // Max width per desktop
    }
  }

  // Restituisce il tipo di layout appropriato
  static Widget buildResponsiveLayout(
    BuildContext context, {
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    if (isMobile(context)) return mobile;
    if (isTablet(context)) return tablet ?? mobile;
    return desktop ?? tablet ?? mobile;
  }

  // Calcola lo spazio tra gli elementi basato sullo schermo
  static double getSpacing(BuildContext context, {
    double mobileSpacing = 8.0,
    double tabletSpacing = 12.0,
    double desktopSpacing = 16.0,
  }) {
    if (isMobile(context)) return mobileSpacing;
    if (isTablet(context)) return tabletSpacing;
    return desktopSpacing;
  }

  // Restituisce le dimensioni della card basate sullo schermo
  static Size getCardSize(BuildContext context) {
    if (isMobile(context)) {
      return Size(getScreenWidth(context) - 32, 120);
    } else if (isTablet(context)) {
      return Size((getScreenWidth(context) - 48) / 2, 140);
    } else {
      return Size((getScreenWidth(context) - 64) / 3, 160);
    }
  }
}