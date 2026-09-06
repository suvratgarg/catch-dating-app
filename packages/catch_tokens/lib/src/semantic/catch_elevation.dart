import 'package:catch_tokens/src/primitives/catch_spacing.dart';
import 'package:catch_tokens/src/semantic/catch_opacity.dart';
import 'package:catch_tokens/src/semantic/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Minimal elevation tokens. Most Catch surfaces should use a hairline border;
/// use shadows only when UI actually floats above content.
abstract final class CatchElevation {
  static const List<BoxShadow> none = <BoxShadow>[];

  /// Shared physical-shadow color for Material/PhysicalShape surfaces.
  static const Color physicalShadow = Color.fromRGBO(26, 20, 16, 0.18);

  /// Flutter physical elevation for clipped ticket shapes that cannot use
  /// regular [BoxShadow] lists.
  static const double physicalTicket = 4.0;

  /// Physical lift for circular floating controls over media.
  static const double physicalControl = 3.0;

  /// Handoff floating icon-button shadow for controls over photos and maps.
  static const List<BoxShadow> iconButtonFloat = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.18),
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  /// Toggle knob shadow from the handoff control primitive.
  static const List<BoxShadow> toggleKnob = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.25),
      blurRadius: 3,
      offset: Offset(0, 1),
    ),
  ];

  /// Physical lift for the primary pass control over media.
  static const double physicalPassControl = 5.0;

  /// Material menu elevation.
  static const double menu = 8.0;

  /// Subtle lift for content cards that should read as "above the page" while
  /// keeping the hairline border style. Use for hero event cards, editorial
  /// picks, and selected map peek tiles.
  static const List<BoxShadow> card = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.06),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.04),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Bottom sheets, floating action buttons, popovers.
  static const List<BoxShadow> raised = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.10),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.06),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
  ];

  /// Toasts, snackbars, dropdown overlays.
  static const List<BoxShadow> overlay = <BoxShadow>[
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.18),
      blurRadius: 40,
      offset: Offset(0, 16),
    ),
    BoxShadow(
      color: Color.fromRGBO(26, 20, 16, 0.08),
      blurRadius: 8,
      offset: Offset(0, 4),
    ),
  ];

  static List<BoxShadow> focusRing(CatchTokens t) => <BoxShadow>[
    BoxShadow(color: t.primarySoft, spreadRadius: CatchSpacing.micro3),
  ];

  /// Exact active-field lift from the Field handoff. Field rows deliberately
  /// use one shadow layer so the pressed-to-focused handoff reads as one tile
  /// instead of two competing elevations.
  static List<BoxShadow> fieldActive(Brightness brightness) => <BoxShadow>[
    BoxShadow(
      color: brightness == Brightness.dark
          ? const Color.fromRGBO(0, 0, 0, 0.55)
          : const Color.fromRGBO(22, 20, 15, 0.08),
      blurRadius: brightness == Brightness.dark ? 22 : 18,
      offset: Offset(0, brightness == Brightness.dark ? 8 : 6),
    ),
  ];

  static List<BoxShadow> segmentedSelected(CatchTokens t) => <BoxShadow>[
    BoxShadow(
      color: t.ink.withValues(alpha: CatchOpacity.controlOverlayPressed),
      blurRadius: CatchSpacing.micro14,
      offset: const Offset(CatchSpacing.s0, CatchSpacing.micro3),
    ),
  ];

  static List<BoxShadow> glow(
    Color color, {
    required double blurRadius,
    double spreadRadius = CatchSpacing.micro2,
  }) => <BoxShadow>[
    BoxShadow(color: color, blurRadius: blurRadius, spreadRadius: spreadRadius),
  ];
}
