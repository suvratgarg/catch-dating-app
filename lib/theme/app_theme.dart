import 'package:flutter/material.dart';

abstract final class AppTheme {
  // Change this to update the brand colour across the whole app.
  static const _seedColor = Color(0xFFE8445A);

  static final light = _build(
    ColorScheme.fromSeed(seedColor: _seedColor),
  );

  static final dark = _build(
    ColorScheme.fromSeed(seedColor: _seedColor, brightness: Brightness.dark),
  );

  static ThemeData _build(ColorScheme colorScheme) => ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 52),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      scrolledUnderElevation: 0,
    ),
  );
}
