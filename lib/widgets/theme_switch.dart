import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_provider.dart';

class ThemeSwitch extends ConsumerWidget {
  const ThemeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final isDarkMode = themeMode == ThemeMode.dark;

    return GestureDetector(
      onTap: () {
        ref.read(themeModeProvider.notifier).toggleTheme();
      },
      child: Container(
        width: 80,
        height: 40,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: isDarkMode ? const Color(0xFF3A3A5A) : const Color(0xFFE0E6FF),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: 0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Track
            AnimatedAlign(
              alignment:
                  isDarkMode ? Alignment.centerRight : Alignment.centerLeft,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDarkMode ? const Color(0xFF5B86E5) : Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    isDarkMode ? Icons.dark_mode : Icons.light_mode,
                    size: 16,
                    color: isDarkMode ? Colors.white : const Color(0xFF5B86E5),
                  ),
                ),
              ),
            ),
            // Sun icon (left)
            Positioned(
              left: 12,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: isDarkMode ? 0.5 : 0.0,
                child: const Icon(
                  Icons.light_mode,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
            // Moon icon (right)
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Opacity(
                opacity: isDarkMode ? 0.0 : 0.5,
                child: const Icon(
                  Icons.dark_mode,
                  size: 14,
                  color: Color(0xFF5B86E5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
