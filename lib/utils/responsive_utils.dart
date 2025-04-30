import 'package:flutter/material.dart';

/// Utility class for responsive sizing
class ResponsiveSizing {
  /// Helper method to determine screen size category
  static ScreenSize getScreenSize(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 396) {
      return ScreenSize.small;
    } else if (width < 1200) {
      return ScreenSize.medium;
    } else {
      return ScreenSize.large;
    }
  }

  /// Get appropriate padding based on screen size
  static EdgeInsets getPadding(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.small:
        return const EdgeInsets.all(8.0);
      case ScreenSize.medium:
        return const EdgeInsets.all(16.0);
      case ScreenSize.large:
        return const EdgeInsets.all(24.0);
    }
  }

  /// Get appropriate card height based on screen size
  static double getCardHeight(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.small:
        return 160.0;
      case ScreenSize.medium:
        return 180.0;
      case ScreenSize.large:
        return 200.0;
    }
  }

  /// Get appropriate list item height based on screen size
  static double getListItemHeight(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.small:
        return 70.0;
      case ScreenSize.medium:
        return 80.0;
      case ScreenSize.large:
        return 90.0;
    }
  }

  /// Get appropriate font size for headings based on screen size
  static double getHeadingFontSize(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.small:
        return 20.0;
      case ScreenSize.medium:
        return 24.0;
      case ScreenSize.large:
        return 28.0;
    }
  }

  /// Get responsive grid column count
  static int getGridColumnCount(BuildContext context) {
    final screenSize = getScreenSize(context);

    switch (screenSize) {
      case ScreenSize.small:
        return 1;
      case ScreenSize.medium:
        return 3;
      case ScreenSize.large:
        return 3;
    }
  }
}

/// Screen size categories
enum ScreenSize {
  small,
  medium,
  large,
}
