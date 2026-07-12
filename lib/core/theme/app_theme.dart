import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_fonts.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

abstract final class AppTheme {
  // Neutral seed — most UI reads CatchTokens directly; the M3 scheme is secondary.
  static const _seedColor = Color(0xFF16140F);

  static final light = _build(
    colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
    tokens: CatchTokens.light,
  );

  static final dark = _build(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    tokens: CatchTokens.dark,
  );

  static ThemeData _build({
    required ColorScheme colorScheme,
    required CatchTokens tokens,
  }) {
    final base = ThemeData(useMaterial3: true, colorScheme: colorScheme);
    final textTheme = CatchTextStyles.materialTextTheme(base.textTheme, tokens);

    return base.copyWith(
      // Platform system font as the app-wide function/body baseline, tuned to
      // Catch's semantic scale so Material fallbacks do not flatten hierarchy.
      textTheme: textTheme,

      scaffoldBackgroundColor: tokens.bg,

      // Register the active Catch design tokens as a ThemeExtension so any
      // widget can call CatchTokens.of(context) to read exact design values.
      extensions: <ThemeExtension<dynamic>>[
        tokens,
        colorScheme.brightness == Brightness.dark
            ? ActivityPalette.dark
            : ActivityPalette.light,
      ],

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
          // No color — the button's state-aware foregroundColor wins.
          textStyle: CatchFonts.sans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1,
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
          textStyle: CatchFonts.sans(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            height: 1,
          ),
        ),
      ),

      appBarTheme: AppBarTheme(
        centerTitle: true,
        scrolledUnderElevation: 0,
        backgroundColor: tokens.bg,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: CatchFonts.sans(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.18,
          color: tokens.ink,
        ),
        iconTheme: IconThemeData(color: tokens.ink),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: tokens.ink,
        contentTextStyle: CatchFonts.sans(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.35,
          color: tokens.bg,
        ),
        actionTextColor: tokens.primarySoft,
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: tokens.primary,
          textStyle: CatchFonts.sans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            height: 1.2,
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
            CatchFonts.sans(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 1.3,
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
          return CatchFonts.sans(
            fontSize: 11,
            height: 1.2,
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
        labelStyle: CatchFonts.sans(
          fontSize: 13,
          height: 1.2,
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
}
