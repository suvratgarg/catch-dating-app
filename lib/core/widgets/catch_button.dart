import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

enum CatchButtonVariant { primary, secondary, ghost, danger }

enum CatchButtonSize { sm, md, lg }

/// Canonical Catch button primitive.
///
/// Use [variant] for visual hierarchy and [size] for density. Screens should
/// configure this widget rather than creating bespoke Material button styles.
class CatchButton extends StatefulWidget {
  const CatchButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CatchButtonVariant.primary,
    this.size = CatchButtonSize.md,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.semanticsLabel,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });

  final String label;
  final VoidCallback? onPressed;
  final CatchButtonVariant variant;
  final CatchButtonSize size;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;
  final String? semanticsLabel;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  State<CatchButton> createState() => _CatchButtonState();
}

class _CatchButtonState extends State<CatchButton> {
  bool _hovered = false;
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final spec = _ButtonSizeSpec.from(widget.size);
    final palette = _ButtonPalette.from(widget.variant, t).copyWith(
      background: widget.backgroundColor,
      foreground: widget.foregroundColor,
      border: widget.borderColor,
    );

    final child = AnimatedScale(
      scale: _enabled && _pressed ? 0.97 : 1,
      duration: CatchMotion.fast,
      curve: CatchMotion.standardCurve,
      child: AnimatedOpacity(
        opacity: _enabled ? 1 : 0.4,
        duration: CatchMotion.fast,
        curve: CatchMotion.standardCurve,
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: spec.height),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: palette.background,
              borderRadius: BorderRadius.circular(CatchRadius.pill),
              border: Border.all(
                color: palette.border,
                width: widget.variant == CatchButtonVariant.secondary ? 1.5 : 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(CatchRadius.pill),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _enabled ? widget.onPressed : null,
                  onHover: (hovered) => setState(() => _hovered = hovered),
                  onHighlightChanged: (pressed) =>
                      setState(() => _pressed = pressed),
                  splashColor: palette.foreground.withValues(alpha: 0.08),
                  highlightColor: Colors.transparent,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      if (_hovered || _pressed)
                        Positioned.fill(
                          child: ColoredBox(
                            color: Colors.black.withValues(
                              alpha: _pressed ? 0.08 : 0.04,
                            ),
                          ),
                        ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: spec.padding),
                        child: AnimatedSwitcher(
                          duration: CatchMotion.fast,
                          switchInCurve: CatchMotion.standardCurve,
                          switchOutCurve: CatchMotion.standardCurve,
                          child: widget.isLoading
                              ? _LoadingDots(color: palette.foreground)
                              : _ButtonLabel(
                                  label: widget.label,
                                  color: palette.foreground,
                                  icon: widget.icon,
                                  gap: spec.gap,
                                  fullWidth: widget.fullWidth,
                                  textStyle: spec.textStyle(context),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.semanticsLabel ?? widget.label,
      child: widget.fullWidth
          ? SizedBox(width: double.infinity, child: child)
          : child,
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.label,
    required this.color,
    required this.icon,
    required this.gap,
    required this.fullWidth,
    required this.textStyle,
  });

  final String label;
  final Color color;
  final Widget? icon;
  final double gap;
  final bool fullWidth;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          IconTheme(
            data: IconThemeData(color: color, size: CatchIcon.md),
            child: icon!,
          ),
          SizedBox(width: gap),
        ],
        if (fullWidth)
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: textStyle.copyWith(color: color),
            ),
          )
        else
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textStyle.copyWith(color: color),
          ),
      ],
    );
  }
}

class _LoadingDots extends StatelessWidget {
  const _LoadingDots({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey('catch-button-loading'),
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(left: index == 0 ? 0 : CatchSpacing.s1),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.4 + index * 0.2),
              borderRadius: BorderRadius.circular(CatchRadius.pill),
            ),
            child: const SizedBox.square(dimension: 6),
          ),
        );
      }),
    );
  }
}

class _ButtonSizeSpec {
  const _ButtonSizeSpec({
    required this.height,
    required this.padding,
    required this.fontSize,
    required this.gap,
  });

  final double height;
  final double padding;
  final double fontSize;
  final double gap;

  TextStyle textStyle(BuildContext context) {
    return CatchTextStyles.labelL(context).copyWith(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      height: 1,
      letterSpacing: 0,
    );
  }

  static _ButtonSizeSpec from(CatchButtonSize size) {
    return switch (size) {
      CatchButtonSize.sm => const _ButtonSizeSpec(
        height: 36,
        padding: 14,
        fontSize: 13,
        gap: 6,
      ),
      CatchButtonSize.md => const _ButtonSizeSpec(
        height: 48,
        padding: 20,
        fontSize: 15,
        gap: 6,
      ),
      CatchButtonSize.lg => const _ButtonSizeSpec(
        height: 56,
        padding: 24,
        fontSize: 16,
        gap: 6,
      ),
    };
  }
}

class _ButtonPalette {
  const _ButtonPalette({
    required this.background,
    required this.foreground,
    required this.border,
  });

  final Color background;
  final Color foreground;
  final Color border;

  _ButtonPalette copyWith({
    Color? background,
    Color? foreground,
    Color? border,
  }) {
    return _ButtonPalette(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      border: border ?? this.border,
    );
  }

  static _ButtonPalette from(CatchButtonVariant variant, CatchTokens t) {
    return switch (variant) {
      CatchButtonVariant.primary => _ButtonPalette(
        background: t.primary,
        foreground: t.primaryInk,
        border: Colors.transparent,
      ),
      CatchButtonVariant.secondary => _ButtonPalette(
        background: t.surface,
        foreground: t.ink,
        border: t.line2,
      ),
      CatchButtonVariant.ghost => _ButtonPalette(
        background: Colors.transparent,
        foreground: t.ink,
        border: Colors.transparent,
      ),
      CatchButtonVariant.danger => _ButtonPalette(
        background: t.danger,
        foreground: Colors.white,
        border: Colors.transparent,
      ),
    };
  }
}
