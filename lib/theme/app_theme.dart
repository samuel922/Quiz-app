import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData build() {
    final base = ThemeData.dark(useMaterial3: true);

    const primaryColor = Color(0xFF8A7DFF);
    const secondaryColor = Color(0xFF2A1B4F);
    const accentColor = Color(0xFFFF8BA7);

    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primaryColor,
        secondary: accentColor,
        surface: const Color(0xFF120826),
      ),
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: base.textTheme.apply(
        fontFamily: 'Lato',
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(color: Colors.white.withValues(alpha: 0.4)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      sliderTheme: base.sliderTheme.copyWith(
        activeTrackColor: primaryColor,
        inactiveTrackColor: Colors.white24,
        thumbColor: accentColor,
        overlayColor: accentColor.withValues(alpha: 0.2),
      ),
      switchTheme: base.switchTheme.copyWith(
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryColor.withValues(alpha: 0.65);
          }
          return Colors.white24;
        }),
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return Colors.white;
          }
          return Colors.white70;
        }),
      ),
      dropdownMenuTheme: base.dropdownMenuTheme.copyWith(
        inputDecorationTheme: const InputDecorationTheme(
          border: InputBorder.none,
        ),
      ),
      cardColor: secondaryColor,
    );
  }
}
