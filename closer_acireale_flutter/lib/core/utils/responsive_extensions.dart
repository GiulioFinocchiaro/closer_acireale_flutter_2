import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../constants/app_constants.dart';
import 'responsive_utils.dart';

// Estensioni per BuildContext per semplificare l'uso delle funzioni responsive
extension ResponsiveContext on BuildContext {
  // Device type checks
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  
  // Screen dimensions
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  
  // Responsive font sizes
  double responsiveFontSize({
    required double mobile,
    double? tablet,
    double? desktop,
  }) => ResponsiveUtils.getResponsiveFontSize(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  ).sp;
  
  // Responsive padding
  EdgeInsets responsivePadding({
    double? mobile,
    double? tablet,
    double? desktop,
  }) => ResponsiveUtils.getResponsivePadding(
    this,
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );
  
  // Responsive spacing
  double responsiveSpacing({
    double mobile = 8.0,
    double tablet = 12.0,
    double desktop = 16.0,
  }) => ResponsiveUtils.getSpacing(
    this,
    mobileSpacing: mobile,
    tabletSpacing: tablet,
    desktopSpacing: desktop,
  );
  
  // Grid column count
  int gridColumns({
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) => ResponsiveUtils.getGridCrossAxisCount(
    this,
    mobileColumns: mobile,
    tabletColumns: tablet,
    desktopColumns: desktop,
  );
  
  // Max container width
  double get maxContainerWidth => ResponsiveUtils.getMaxContainerWidth(this);
  
  // Card size
  Size get cardSize => ResponsiveUtils.getCardSize(this);
  
  // Responsive value selector
  T responsive<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop && desktop != null) return desktop;
    if (isTablet && tablet != null) return tablet;
    return mobile;
  }
}

// Classe per gestire layout responsivi più avanzati
class ResponsiveLayout {
  static Widget adaptive({
    required BuildContext context,
    required Widget mobile,
    Widget? tablet,
    Widget? desktop,
  }) {
    return ResponsiveUtils.buildResponsiveLayout(
      context,
      mobile: mobile,
      tablet: tablet,
      desktop: desktop,
    );
  }
  
  // Layout a colonne responsive
  static Widget columns({
    required BuildContext context,
    required List<Widget> children,
    double spacing = 16.0,
    CrossAxisAlignment crossAxisAlignment = CrossAxisAlignment.start,
    MainAxisAlignment mainAxisAlignment = MainAxisAlignment.start,
  }) {
    if (context.isMobile) {
      return Column(
        crossAxisAlignment: crossAxisAlignment,
        mainAxisAlignment: mainAxisAlignment,
        children: children.map((child) => Padding(
          padding: EdgeInsets.only(bottom: spacing.h),
          child: child,
        )).toList(),
      );
    }
    
    return Row(
      crossAxisAlignment: crossAxisAlignment,
      mainAxisAlignment: mainAxisAlignment,
      children: children.map((child) => Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: spacing.w),
          child: child,
        ),
      )).toList(),
    );
  }
  
  // Wrap responsive
  static Widget wrap({
    required BuildContext context,
    required List<Widget> children,
    double spacing = 16.0,
    double runSpacing = 16.0,
    WrapAlignment alignment = WrapAlignment.start,
    WrapCrossAlignment crossAxisAlignment = WrapCrossAlignment.start,
  }) {
    return Wrap(
      spacing: spacing.w,
      runSpacing: runSpacing.h,
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      children: children,
    );
  }
  
  // Container con larghezza massima responsiva
  static Widget constrainedContainer({
    required BuildContext context,
    required Widget child,
    EdgeInsets? padding,
    EdgeInsets? margin,
    Alignment alignment = Alignment.center,
  }) {
    return Container(
      width: double.infinity,
      alignment: alignment,
      padding: padding,
      margin: margin,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.maxContainerWidth,
        ),
        child: child,
      ),
    );
  }
  
  // Sidebar layout per desktop/tablet
  static Widget sidebarLayout({
    required BuildContext context,
    required Widget sidebar,
    required Widget content,
    double sidebarWidth = 280,
    bool forceStack = false,
  }) {
    if (context.isMobile || forceStack) {
      return content; // Su mobile non mostriamo la sidebar
    }
    
    return Row(
      children: [
        SizedBox(
          width: sidebarWidth.w,
          child: sidebar,
        ),
        Expanded(child: content),
      ],
    );
  }
}

// Classe per gestire breakpoints personalizzati
class BreakpointManager {
  static const double extraSmall = 480;
  static const double small = 768;
  static const double medium = 1024;
  static const double large = 1200;
  static const double extraLarge = 1440;
  
  static bool isExtraSmall(BuildContext context) =>
      MediaQuery.of(context).size.width < extraSmall;
  
  static bool isSmall(BuildContext context) =>
      MediaQuery.of(context).size.width >= extraSmall &&
      MediaQuery.of(context).size.width < small;
      
  static bool isMedium(BuildContext context) =>
      MediaQuery.of(context).size.width >= small &&
      MediaQuery.of(context).size.width < medium;
      
  static bool isLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= medium &&
      MediaQuery.of(context).size.width < large;
      
  static bool isExtraLarge(BuildContext context) =>
      MediaQuery.of(context).size.width >= large;
}

// Mixin per componenti responsivi
mixin ResponsiveMixin {
  double getResponsiveFontSize(BuildContext context, {
    double xs = 12,
    double sm = 14,
    double md = 16,
    double lg = 18,
    double xl = 20,
  }) {
    if (BreakpointManager.isExtraSmall(context)) return xs.sp;
    if (BreakpointManager.isSmall(context)) return sm.sp;
    if (BreakpointManager.isMedium(context)) return md.sp;
    if (BreakpointManager.isLarge(context)) return lg.sp;
    return xl.sp;
  }
  
  EdgeInsets getResponsivePadding(BuildContext context, {
    double xs = 8,
    double sm = 12,
    double md = 16,
    double lg = 20,
    double xl = 24,
  }) {
    double padding;
    if (BreakpointManager.isExtraSmall(context)) {
      padding = xs;
    } else if (BreakpointManager.isSmall(context)) {
      padding = sm;
    } else if (BreakpointManager.isMedium(context)) {
      padding = md;
    } else if (BreakpointManager.isLarge(context)) {
      padding = lg;
    } else {
      padding = xl;
    }
    return EdgeInsets.all(padding.w);
  }
}