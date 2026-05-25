import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppTheme {
  // Catch orange - matches CatchTokens.sunsetLight.primary.
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
    final textTheme = _textTheme(base.textTheme, tokens);

    return base.copyWith(
      // Inter as the app-wide text theme baseline, tuned to Catch's semantic
      // scale so Material fallbacks do not flatten the app's text hierarchy.
      textTheme: textTheme,

      scaffoldBackgroundColor: tokens.bg,

      // Register the active Catch design tokens as a ThemeExtension so any
      // widget can call CatchTokens.of(context) to read exact design values.
      extensions: <ThemeExtension<dynamic>>[tokens],

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: tokens.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CatchRadius.sm),
          borderSide: BorderSide(color: tokens.line2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CatchRadius.sm),
          borderSide: BorderSide(color: tokens.line2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(CatchRadius.sm),
          borderSide: BorderSide(color: tokens.primary, width: 1.5),
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: tokens.ink3),
        labelStyle: textTheme.labelLarge?.copyWith(color: tokens.ink2),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: tokens.primary,
          foregroundColor: tokens.primaryInk,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CatchRadius.pill),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: tokens.primary,
          side: BorderSide(color: tokens.primary),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(CatchRadius.pill),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0,
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: tokens.bg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.18,
          letterSpacing: 0,
          color: tokens.ink,
        ),
        iconTheme: IconThemeData(color: tokens.ink),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.ink,
        contentTextStyle: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.35,
          letterSpacing: 0,
          color: tokens.bg,
        ),
        actionTextColor: tokens.primarySoft,
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.primary,
          textStyle: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.2,
            letterSpacing: 0,
          ),
        ),
      ),

      menuTheme: MenuThemeData(
        style: MenuStyle(
          backgroundColor: WidgetStatePropertyAll(tokens.surface),
          surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ),

      menuButtonTheme: MenuButtonThemeData(
        style: ButtonStyle(
          textStyle: WidgetStatePropertyAll(
            GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
              letterSpacing: 0,
              color: tokens.ink,
            ),
          ),
        ),
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
          borderRadius: BorderRadius.circular(CatchRadius.md),
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
          borderRadius: BorderRadius.circular(CatchRadius.pill),
        ),
      ),
    );
  }

  static TextTheme _textTheme(TextTheme base, CatchTokens tokens) {
    final inter = GoogleFonts.interTextTheme(base);
    TextStyle style(
      double size,
      FontWeight weight,
      double height,
      Color color,
    ) => GoogleFonts.inter(
      fontSize: size,
      fontWeight: weight,
      height: height,
      letterSpacing: 0,
      decoration: TextDecoration.none,
      color: color,
    );

    return inter.copyWith(
      displayLarge: style(40, FontWeight.w800, 1.02, tokens.ink),
      displayMedium: style(32, FontWeight.w800, 1.04, tokens.ink),
      displaySmall: style(26, FontWeight.w800, 1.08, tokens.ink),
      headlineLarge: style(32, FontWeight.w800, 1.05, tokens.ink),
      headlineMedium: style(28, FontWeight.w800, 1.10, tokens.ink),
      headlineSmall: style(20, FontWeight.w800, 1.14, tokens.ink),
      titleLarge: style(19, FontWeight.w700, 1.20, tokens.ink),
      titleMedium: style(16, FontWeight.w700, 1.24, tokens.ink),
      titleSmall: style(14, FontWeight.w700, 1.26, tokens.ink),
      bodyLarge: style(16, FontWeight.w400, 1.50, tokens.ink),
      bodyMedium: style(14, FontWeight.w400, 1.50, tokens.ink),
      bodySmall: style(13, FontWeight.w400, 1.45, tokens.ink2),
      labelLarge: style(13, FontWeight.w700, 1.24, tokens.ink),
      labelMedium: style(11, FontWeight.w700, 1.24, tokens.ink2),
      labelSmall: style(10, FontWeight.w800, 1.15, tokens.ink2),
    );
  }
}
