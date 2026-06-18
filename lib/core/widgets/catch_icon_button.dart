import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchIconButtonVariant { bordered, float, plain }

/// Handoff `IconButton`: a Phosphor glyph in a circular target.
///
/// Defaults to the 44px bordered inline control. Top bars use [navSize] for the
/// handoff's 40px back/action rule, and photo/map overlays use
/// [CatchIconButtonVariant.float].
///
/// Usage:
/// ```dart
/// CatchIconButton(onTap: () {}, child: Icon(CatchIcons.notificationsOutlined))
///
/// // Floating photo/map chrome.
/// CatchIconButton(variant: CatchIconButtonVariant.float, child: Icon(CatchIcons.close))
///
/// // Solid custom variant.
/// CatchIconButton(background: t.ink, child: Icon(CatchIcons.tune, color: t.surface))
/// ```
class CatchIconButton extends StatelessWidget {
  const CatchIconButton({
    super.key,
    required this.child,
    this.onTap,
    this.variant = CatchIconButtonVariant.bordered,
    this.active = false,
    this.fill,
    this.accent,
    this.disabled = false,
    this.background,
    this.size = defaultSize,
    this.borderRadius,
  });

  factory CatchIconButton.icon({
    Key? key,
    required IconData icon,
    VoidCallback? onTap,
    CatchIconButtonVariant variant = CatchIconButtonVariant.bordered,
    bool active = false,
    bool? fill,
    Color? accent,
    bool disabled = false,
    Color? background,
    double size = defaultSize,
    double? borderRadius,
  }) {
    return CatchIconButton(
      key: key,
      onTap: onTap,
      variant: variant,
      active: active,
      fill: fill,
      accent: accent,
      disabled: disabled,
      background: background,
      size: size,
      borderRadius: borderRadius,
      child: Icon(icon),
    );
  }

  static const double defaultSize = CatchLayout.iconButtonSize;
  static const double navSize = CatchLayout.iconButtonNavSize;

  final Widget child;
  final VoidCallback? onTap;
  final CatchIconButtonVariant variant;
  final bool active;
  final bool? fill;
  final Color? accent;
  final bool disabled;

  /// Override fill color. Defaults to the variant's handoff surface.
  final Color? background;

  /// Diameter of the button circle. Defaults to [defaultSize].
  final double size;

  /// Override shape radius. Defaults to [CatchRadius.pill] (full circle).
  final double? borderRadius;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final radius = borderRadius ?? CatchRadius.pill;
    final palette = _IconBtnPalette.from(
      tokens: t,
      variant: variant,
      active: active,
      accent: accent,
      background: background,
    );
    final enabled = onTap != null && !disabled;
    final filled = fill ?? active;
    final iconTheme = IconThemeData(
      color: palette.foreground,
      size: (size * CatchLayout.iconButtonGlyphScale).roundToDouble(),
      fill: filled ? 1.0 : null,
    );

    return Opacity(
      opacity: disabled ? CatchOpacity.disabledControl : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(radius),
          border: palette.borderColor == null
              ? null
              : Border.all(color: palette.borderColor!),
          boxShadow: palette.shadow,
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(radius),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: enabled ? onTap : null,
            child: SizedBox.square(
              dimension: size,
              child: Center(
                child: IconTheme.merge(data: iconTheme, child: child),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _IconBtnPalette {
  const _IconBtnPalette({
    required this.background,
    required this.foreground,
    required this.borderColor,
    required this.shadow,
  });

  final Color background;
  final Color foreground;
  final Color? borderColor;
  final List<BoxShadow> shadow;

  static _IconBtnPalette from({
    required CatchTokens tokens,
    required CatchIconButtonVariant variant,
    required bool active,
    required Color? accent,
    required Color? background,
  }) {
    final activeColor = accent ?? tokens.ink;

    switch (variant) {
      case CatchIconButtonVariant.bordered:
        return _IconBtnPalette(
          background: background ?? tokens.surface,
          foreground: active ? activeColor : tokens.ink,
          borderColor: tokens.line2,
          shadow: CatchElevation.none,
        );
      case CatchIconButtonVariant.float:
        return _IconBtnPalette(
          background:
              background ??
              tokens.surface.withValues(
                alpha: CatchOpacity.iconButtonFloatFill,
              ),
          foreground: active
              ? activeColor
              : CatchIconButtonColors.floatingForeground,
          borderColor: null,
          shadow: CatchElevation.iconButtonFloat,
        );
      case CatchIconButtonVariant.plain:
        return _IconBtnPalette(
          background: background ?? Colors.transparent,
          foreground: active ? activeColor : tokens.ink,
          borderColor: null,
          shadow: CatchElevation.none,
        );
    }
  }
}
