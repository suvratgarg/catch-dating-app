import 'package:catch_tokens/src/primitives/catch_stroke.dart';
import 'package:catch_tokens/src/semantic/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Semantic reasons a line exists. A role resolves both its theme-aware color
/// and its stroke width so callers cannot independently drift either value.
enum CatchBorderRole {
  separator,
  boundary,
  control,
  selected,
  focus,
  danger,
  warning,
}

/// Complete visual states for interactive boundaries.
///
/// Hover and press deliberately retain the resting border; their feedback is
/// fill-only, which prevents a pointer interaction from shifting geometry.
enum CatchInteractiveBorderState {
  resting,
  hovered,
  pressed,
  selected,
  focused,
  disabled,
  error,
}

@immutable
class CatchBorderSpec {
  const CatchBorderSpec({
    required this.role,
    required this.color,
    required this.width,
  });

  final CatchBorderRole role;
  final Color color;
  final double width;

  BorderSide get side => BorderSide(color: color, width: width);
  Border get all => Border.fromBorderSide(side);

  CatchBorderSpec copyWith({Color? color}) =>
      CatchBorderSpec(role: role, color: color ?? this.color, width: width);
}

/// Theme-aware border resolver for separators, surfaces, and interactions.
abstract final class CatchBorder {
  static CatchBorderSpec resolve(
    CatchTokens tokens,
    CatchBorderRole role, {
    Color? color,
  }) {
    final resolved = switch (role) {
      CatchBorderRole.separator => CatchBorderSpec(
        role: role,
        color: tokens.line,
        width: CatchStroke.hairline,
      ),
      CatchBorderRole.boundary => CatchBorderSpec(
        role: role,
        color: tokens.line2,
        width: CatchStroke.hairline,
      ),
      CatchBorderRole.control => CatchBorderSpec(
        role: role,
        color: _controlColor(tokens),
        width: CatchStroke.hairline,
      ),
      CatchBorderRole.selected => CatchBorderSpec(
        role: role,
        color: tokens.primary,
        width: CatchStroke.emphasis,
      ),
      CatchBorderRole.focus => CatchBorderSpec(
        role: role,
        color: tokens.primary,
        width: CatchStroke.focusRing,
      ),
      CatchBorderRole.danger => CatchBorderSpec(
        role: role,
        color: tokens.danger,
        width: CatchStroke.emphasis,
      ),
      CatchBorderRole.warning => CatchBorderSpec(
        role: role,
        color: tokens.warning,
        width: CatchStroke.emphasis,
      ),
    };
    return color == null ? resolved : resolved.copyWith(color: color);
  }

  static CatchBorderSpec interactive(
    CatchTokens tokens,
    CatchInteractiveBorderState state, {
    Color? selectedColor,
  }) {
    return switch (state) {
      CatchInteractiveBorderState.error => resolve(
        tokens,
        CatchBorderRole.danger,
      ),
      CatchInteractiveBorderState.focused => resolve(
        tokens,
        CatchBorderRole.focus,
      ),
      CatchInteractiveBorderState.selected => resolve(
        tokens,
        CatchBorderRole.selected,
        color: selectedColor,
      ),
      CatchInteractiveBorderState.disabled => resolve(
        tokens,
        CatchBorderRole.boundary,
      ),
      CatchInteractiveBorderState.resting ||
      CatchInteractiveBorderState.hovered ||
      CatchInteractiveBorderState.pressed => resolve(
        tokens,
        CatchBorderRole.control,
      ),
    };
  }

  static Color _controlColor(CatchTokens tokens) {
    final isDark =
        ThemeData.estimateBrightnessForColor(tokens.bg) == Brightness.dark;
    if (isDark) return tokens.ink3;
    // Light ink3 is just below the 3:1 non-text contrast floor on the app
    // background. Pull it ten percent toward ink so resting interactive
    // boundaries clear that floor on both bg and surface.
    return Color.lerp(tokens.ink3, tokens.ink, 0.10)!;
  }
}
