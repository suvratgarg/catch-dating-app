import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // Catch orange — matches CatchTokens.sunsetLight.primary
  static const _seedColor = Color(0xFFFF4E1F);

  static final light = _build(
    colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
    tokens: CatchTokens.sunsetLight,
  );

  static final dark = _build(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    tokens: CatchTokens.sunsetDark,
  );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required CatchTokens tokens,
  }) {
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);

    return base.copyWith(
      // Inter as the app-wide text theme baseline.
      textTheme: GoogleFonts.interTextTheme(base.textTheme),

      scaffoldBackgroundColor: tokens.bg,

      // Register the active Catch design tokens as a ThemeExtension so any
      // widget can call CatchTokens.of(context) to read exact design values.
      extensions: <ThemeExtension<dynamic>>[tokens],

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.raised,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CatchRadius.card),
          borderSide: BorderSide(color: tokens.line2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CatchRadius.card),
          borderSide: BorderSide(color: tokens.line2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CatchRadius.card),
          borderSide: BorderSide(color: tokens.primary, width: 1.5),
        ),
        hintStyle: TextStyle(color: tokens.ink3),
        labelStyle: TextStyle(color: tokens.ink2),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.primaryInk,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CatchRadius.button),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.primary,
          side: BorderSide(color: tokens.primary),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CatchRadius.button),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: tokens.bg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.spaceGrotesk(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          letterSpacing: 17 * -0.02,
          color: tokens.ink,
        ),
        iconTheme: IconThemeData(color: tokens.ink),
      ),

      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: tokens.surface,
        indicatorColor: tokens.primarySoft,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return IconThemeData(color: tokens.primary);
          }
          return IconThemeData(color: tokens.ink3);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return GoogleFonts.inter(
            fontSize: 11,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
            color: selected ? tokens.primary : tokens.ink3,
          );
        }),
      ),

      dividerTheme: DividerThemeData(color: tokens.line, thickness: 1),

      cardTheme: CardThemeData(
        color: tokens.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CatchRadius.card),
        ),
        elevation: 0,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: tokens.raised,
        selectedColor: tokens.primarySoft,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: tokens.ink,
        ),
        side: BorderSide(color: tokens.line2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CatchRadius.button),
        ),
      ),
    );
  }
}
