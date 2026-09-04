import 'dart:math' as math;

import 'package:catch_dating_app/core/theme/catch_platform_tokens.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_count_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

enum CatchIconButtonVariant { bordered, float, plain }

/// Handoff `IconButton`: a Phosphor glyph in a circular target.
///
/// Defaults to the 44-point bordered visual. Top bars use [navSize], while
/// [targetExtentFor] separately owns the platform-sized hit/focus allocation.
/// Photo/map overlays use [CatchIconButtonVariant.float]. Counted actions use
/// [counted] so callers provide a typed count instead of composing a string
/// badge around the button.
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
class CatchIconButton extends StatefulWidget {
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
    this.borderColor,
    this.size = defaultSize,
    this.borderRadius,
    this.tooltip,
    this.liveRegion = false,
  }) : _count = null;

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
    Color? borderColor,
    double size = defaultSize,
    double? borderRadius,
    String? tooltip,
    bool liveRegion = false,
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
      borderColor: borderColor,
      size: size,
      borderRadius: borderRadius,
      tooltip: tooltip,
      liveRegion: liveRegion,
      child: Icon(icon),
    );
  }

  /// Icon-only action with the canonical count badge overlaid on the target.
  ///
  /// The count stays typed through the API. Zero hides the badge, and the
  /// shared [CatchCountBadge] owns count formatting and overflow behavior.
  factory CatchIconButton.counted({
    Key? key,
    required IconData icon,
    required int count,
    VoidCallback? onTap,
    CatchIconButtonVariant variant = CatchIconButtonVariant.bordered,
    bool active = false,
    bool? fill,
    Color? accent,
    bool disabled = false,
    Color? background,
    Color? borderColor,
    double size = defaultSize,
    double? borderRadius,
    String? tooltip,
    bool liveRegion = false,
  }) {
    assert(count >= 0, 'count must not be negative');
    return CatchIconButton._counted(
      key: key,
      count: count,
      onTap: onTap,
      variant: variant,
      active: active,
      fill: fill,
      accent: accent,
      disabled: disabled,
      background: background,
      borderColor: borderColor,
      size: size,
      borderRadius: borderRadius,
      tooltip: tooltip,
      liveRegion: liveRegion,
      child: Icon(icon),
    );
  }

  const CatchIconButton._counted({
    super.key,
    required int this._count,
    required this.child,
    this.onTap,
    this.variant = CatchIconButtonVariant.bordered,
    this.active = false,
    this.fill,
    this.accent,
    this.disabled = false,
    this.background,
    this.borderColor,
    this.size = defaultSize,
    this.borderRadius,
    this.tooltip,
    this.liveRegion = false,
  });

  static const double defaultSize = CatchLayout.iconButtonSize;
  static const double navSize = CatchLayout.iconButtonNavSize;

  /// Layout and hit extent, distinct from the visible circle's diameter.
  /// Ancestor chrome must reserve this extent rather than [navSize].
  static double targetExtentFor(double visualExtent) =>
      math.max(visualExtent, CatchPlatformTokens.minimumInteractiveExtent);

  final Widget child;
  final VoidCallback? onTap;
  final CatchIconButtonVariant variant;
  final bool active;
  final bool? fill;
  final Color? accent;
  final bool disabled;

  /// Override fill color. Defaults to the variant's handoff surface.
  final Color? background;

  /// Override border color. Defaults to the variant's handoff border.
  final Color? borderColor;

  /// Visible circle diameter. Cannot reduce the platform minimum hit area.
  final double size;

  /// Override shape radius. Defaults to [CatchRadius.pill] (full circle).
  final double? borderRadius;

  /// Accessible label and hover affordance for icon-only actions.
  final String? tooltip;

  /// Announces a changed semantic label for in-place busy states.
  final bool liveRegion;

  final int? _count;

  @override
  State<CatchIconButton> createState() => _CatchIconButtonState();
}

class _CatchIconButtonState extends State<CatchIconButton> {
  bool _focused = false;
  bool _hovered = false;
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final onTap = widget.onTap;
    final variant = widget.variant;
    final active = widget.active;
    final accent = widget.accent;
    final background = widget.background;
    final borderColor = widget.borderColor;
    final disabled = widget.disabled;
    final size = widget.size;
    final targetExtent = CatchIconButton.targetExtentFor(size);
    final radius = widget.borderRadius ?? CatchRadius.pill;
    final palette = _IconBtnPalette.from(
      tokens: t,
      variant: variant,
      active: active,
      accent: accent,
      background: background,
      borderColor: borderColor,
    );
    final enabled = onTap != null && !disabled;
    final filled = widget.fill ?? active;
    final border = _focused
        ? CatchBorder.resolve(t, CatchBorderRole.focus)
        : active
        ? CatchBorder.resolve(
            t,
            CatchBorderRole.selected,
            color: borderColor ?? accent,
          )
        : variant == CatchIconButtonVariant.bordered
        ? CatchBorder.interactive(
            t,
            disabled
                ? CatchInteractiveBorderState.disabled
                : CatchInteractiveBorderState.resting,
          ).copyWith(color: borderColor)
        : palette.borderColor == null
        ? null
        : CatchBorder.resolve(
            t,
            CatchBorderRole.boundary,
            color: palette.borderColor,
          );
    final iconTheme = IconThemeData(
      color: palette.foreground,
      size: (size * CatchLayout.iconButtonGlyphScale).roundToDouble(),
      fill: filled ? 1.0 : null,
    );

    final button = Opacity(
      opacity: disabled ? CatchOpacity.disabledControl : 1,
      child: CatchSurface(
        width: size,
        height: size,
        backgroundColor: enabled && (_hovered || _pressed)
            ? Color.alphaBlend(
                palette.foreground.withValues(
                  alpha: _pressed
                      ? CatchOpacity.controlOverlayPressed
                      : CatchOpacity.controlOverlayHover,
                ),
                palette.background,
              )
            : palette.background,
        radius: radius,
        borderSpec: border,
        boxShadow: _focused ? CatchElevation.focusRing(t) : palette.shadow,
        padding: EdgeInsets.zero,
        child: Center(
          child: IconTheme.merge(data: iconTheme, child: widget.child),
        ),
      ),
    );
    final count = widget._count;
    final countedButton = count == null
        ? button
        : SizedBox.square(
            dimension: size,
            child: CatchCountBadge(count: count, child: button),
          );
    final message = widget.tooltip;
    final target = Semantics(
      button: true,
      enabled: enabled,
      label: message,
      liveRegion: widget.liveRegion,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          onHover: (hovered) => setState(() => _hovered = hovered),
          onHighlightChanged: (pressed) => setState(() => _pressed = pressed),
          // The visible surface is opaque. Paint feedback there rather than
          // letting ink disappear behind it or fill only the target padding.
          splashFactory: NoSplash.splashFactory,
          hoverColor: Colors.transparent,
          focusColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onFocusChange: (focused) {
            if (_focused != focused) setState(() => _focused = focused);
          },
          borderRadius: BorderRadius.circular(radius),
          child: SizedBox.square(
            dimension: targetExtent,
            child: Center(child: countedButton),
          ),
        ),
      ),
    );
    if (message == null || message.isEmpty) return target;
    return Tooltip(message: message, excludeFromSemantics: true, child: target);
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
    required Color? borderColor,
  }) {
    final activeColor = accent ?? tokens.ink;

    switch (variant) {
      case CatchIconButtonVariant.bordered:
        return _IconBtnPalette(
          background: background ?? tokens.surface,
          foreground: active ? activeColor : tokens.ink,
          borderColor: borderColor ?? tokens.line2,
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
          borderColor: borderColor,
          shadow: CatchElevation.iconButtonFloat,
        );
      case CatchIconButtonVariant.plain:
        return _IconBtnPalette(
          background: background ?? Colors.transparent,
          foreground: active ? activeColor : tokens.ink,
          borderColor: borderColor,
          shadow: CatchElevation.none,
        );
    }
  }
}
