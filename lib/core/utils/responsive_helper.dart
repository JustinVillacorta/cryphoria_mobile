import 'package:flutter/material.dart';

class ResponsiveHelper {
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;

  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < mobileBreakpoint;
  }

  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= mobileBreakpoint && width < tabletBreakpoint;
  }

  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }

  static EdgeInsets safePadding(BuildContext context, {
    double? horizontal,
    double? vertical,
    double? all,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double basePadding = all ?? 16.0;
    double horizontalPadding = horizontal ?? basePadding;
    double verticalPadding = vertical ?? basePadding;

    if (screenWidth < 360) {
      horizontalPadding = horizontalPadding * 0.75;
      verticalPadding = verticalPadding * 0.75;
    }

    if (screenHeight < 640) {
      verticalPadding = verticalPadding * 0.5;
    }

    return EdgeInsets.symmetric(
      horizontal: horizontalPadding,
      vertical: verticalPadding,
    );
  }

  static double fontSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return baseSize * 0.9;
    } else if (screenWidth > 600) {
      return baseSize * 1.1;
    }
    return baseSize;
  }

  static double spacing(BuildContext context, double baseSpacing) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    if (screenWidth < 360 || screenHeight < 640) {
      return baseSpacing * 0.7;
    }

    return baseSpacing;
  }

  static double safeContainerHeight(BuildContext context, double baseHeight) {
    final screenHeight = MediaQuery.of(context).size.height;
    final maxHeight = screenHeight * 0.8;

    return baseHeight > maxHeight ? maxHeight : baseHeight;
  }

  static EdgeInsets buttonPadding(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    }

    return const EdgeInsets.symmetric(horizontal: 16, vertical: 16);
  }

  static double iconSize(BuildContext context, double baseSize) {
    final screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 360) {
      return baseSize * 0.85;
    }

    return baseSize;
  }

  static T responsiveValue<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop(context) && desktop != null) {
      return desktop;
    } else if (isTablet(context) && tablet != null) {
      return tablet;
    }
    return mobile;
  }
}

extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveHelper.isMobile(this);
  bool get isTablet => ResponsiveHelper.isTablet(this);
  bool get isDesktop => ResponsiveHelper.isDesktop(this);

  EdgeInsets safePadding({double? horizontal, double? vertical, double? all}) =>
      ResponsiveHelper.safePadding(this, horizontal: horizontal, vertical: vertical, all: all);

  double fontSize(double baseSize) => ResponsiveHelper.fontSize(this, baseSize);
  double spacing(double baseSpacing) => ResponsiveHelper.spacing(this, baseSpacing);
  double iconSize(double baseSize) => ResponsiveHelper.iconSize(this, baseSize);

  T responsiveValue<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) => ResponsiveHelper.responsiveValue(this, mobile: mobile, tablet: tablet, desktop: desktop);
}