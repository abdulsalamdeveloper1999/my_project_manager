import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

// Theme mode state notifier
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  // Load the saved theme from Hive
  Future<void> _loadSavedTheme() async {
    try {
      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox('settings');
      }

      final box = Hive.box('settings');
      final isDarkMode = box.get('isDarkMode', defaultValue: false) as bool;

      state = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      debugPrint('❌ Error loading theme: $e');
    }
  }

  // Toggle between light and dark theme
  Future<void> toggleTheme() async {
    try {
      final newTheme =
          state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
      state = newTheme;

      if (!Hive.isBoxOpen('settings')) {
        await Hive.openBox('settings');
      }

      final box = Hive.box('settings');
      await box.put('isDarkMode', state == ThemeMode.dark);
    } catch (e) {
      debugPrint('❌ Error saving theme: $e');
    }
  }
}

// Provider for theme mode
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});

// Light theme
ThemeData getLightTheme() {
  // Modern, softer color palette
  const primaryColor = Color(0xFF5B86E5); // Modern blue
  const secondaryColor = Color(0xFF36D1DC); // Teal accent
  const backgroundColor = Color(0xFFF8F9FA); // Light gray background
  const textColor = Color(0xFF2D3748); // Dark text that's easier on the eyes
  const cardColor = Colors.white;

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: const Color(0xFFFF9671), // Soft coral for accents
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      surface: cardColor,
      onSurface: textColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: cardColor,
      foregroundColor: primaryColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: primaryColor),
      titleTextStyle: const TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      shadowColor: Colors.black.withOpacity(0.05),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(0),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFFEEEEEE),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textColor,
        fontSize: 14,
      ),
    ),
    extensions: [
      CustomThemeExtension(
        cardShadow: BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 5),
        ),
      ),
    ],
  );
}

// Dark theme
ThemeData getDarkTheme() {
  const primaryColor = Color(
      0xFF5B86E5); // Keep the same blue but it will appear different on dark
  const secondaryColor = Color(0xFF36D1DC); // Teal accent
  const backgroundColor = Color(0xFF1A1A2E); // Dark background
  const surfaceColor = Color(0xFF252A37); // Slightly lighter surface
  const textColor = Color(0xFFE1E2E6); // Light text for dark mode

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      tertiary: const Color(0xFFFF9671), // Keep the same coral accent
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      surface: surfaceColor,
      onSurface: textColor,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      shadowColor: Colors.black.withOpacity(0.15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    cardTheme: CardTheme(
      elevation: 0,
      color: surfaceColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.all(0),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    dividerTheme: const DividerThemeData(
      color: Color(0xFF353645),
      thickness: 1,
    ),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
      titleMedium: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(
        color: textColor,
        fontSize: 16,
      ),
      bodyMedium: TextStyle(
        color: textColor,
        fontSize: 14,
      ),
    ),
    extensions: [
      CustomThemeExtension(
        cardShadow: BoxShadow(
          color: Colors.black.withOpacity(0.25),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 5),
        ),
      ),
    ],
  );
}

// Custom theme extension
class CustomThemeExtension extends ThemeExtension<CustomThemeExtension> {
  final BoxShadow cardShadow;

  CustomThemeExtension({
    required this.cardShadow,
  });

  @override
  ThemeExtension<CustomThemeExtension> copyWith({BoxShadow? cardShadow}) {
    return CustomThemeExtension(
      cardShadow: cardShadow ?? this.cardShadow,
    );
  }

  @override
  ThemeExtension<CustomThemeExtension> lerp(
      ThemeExtension<CustomThemeExtension>? other, double t) {
    if (other is! CustomThemeExtension) {
      return this;
    }

    return CustomThemeExtension(
      cardShadow: BoxShadow.lerp(cardShadow, other.cardShadow, t)!,
    );
  }

  // Helper to get the theme extension from context
  static CustomThemeExtension of(BuildContext context) {
    final extension = Theme.of(context).extension<CustomThemeExtension>();
    if (extension == null) {
      // Return a default extension if not found
      return CustomThemeExtension(
        cardShadow: BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 20,
          spreadRadius: 0,
          offset: const Offset(0, 5),
        ),
      );
    }
    return extension;
  }
}
