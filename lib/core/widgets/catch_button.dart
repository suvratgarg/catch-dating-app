import 'package:catch_dating_app/core/theme/catch_platform_tokens.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:flutter/material.dart';

enum CatchButtonVariant { primary, secondary, ghost, danger, light }

enum CatchButtonSize { sm, md, lg }

/// Named button geometry. Pill remains the product default; rounded is for
/// editorial/full-width actions whose container should read as a bar.
enum CatchButtonShape { pill, rounded }

/// Canonical Catch button primitive.
///
/// Use [variant] for visual hierarchy and [size] for density. Screens should
/// configure this widget rather than creating bespoke Material button styles.
/// Interactive targets retain the platform minimum around compact visuals;
/// labels reflow naturally in both width modes without shrinking their text.
class CatchButton extends StatefulWidget {
  const CatchButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = CatchButtonVariant.primary,
    this.size = CatchButtonSize.md,
    this.shape = CatchButtonShape.pill,
    this.icon,
    this.isLoading = false,
    this.fullWidth = false,
    this.isInteractive = true,
    this.semanticsLabel,
    this.accentColor,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  }) : _command = false,
       iconAtEnd = false;

  /// Unboxed toolbar command with natural-height text and a platform-sized
  /// hit area. Useful for paired sort/filter commands and inline record actions.
  const CatchButton.command({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.iconAtEnd = false,
    this.semanticsLabel,
  }) : _command = true,
       variant = CatchButtonVariant.ghost,
       size = CatchButtonSize.md,
       shape = CatchButtonShape.rounded,
       isLoading = false,
       fullWidth = false,
       isInteractive = true,
       accentColor = null,
       backgroundColor = null,
       foregroundColor = null,
       borderColor = null;

  final bool _command;
  final bool iconAtEnd;

  final String label;
  final VoidCallback? onPressed;
  final CatchButtonVariant variant;
  final CatchButtonSize size;
  final CatchButtonShape shape;
  final Widget? icon;
  final bool isLoading;
  final bool fullWidth;
  final bool isInteractive;
  final String? semanticsLabel;

  /// Activity pigment for a primary button. The foreground is paired to white
  /// unless [foregroundColor] is supplied explicitly.
  final Color? accentColor;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  @override
  State<CatchButton> createState() => _CatchButtonState();
}

class _CatchButtonState extends State<CatchButton> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  bool get _enabled =>
      widget.isInteractive && widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    if (widget._command) {
      return Semantics(
        button: true,
        enabled: _enabled,
        label: widget.semanticsLabel,
        child: CatchRowPressSurface(
          onTap: _enabled ? widget.onPressed : null,
          expandToMaxWidth: false,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: CatchPlatformTokens.minimumInteractiveExtent,
              minWidth: CatchPlatformTokens.minimumInteractiveExtent,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s2),
              child: IconTheme(
                data: IconThemeData(
                  size: CatchIcon.sm,
                  color: _enabled ? t.ink : t.ink3,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.icon != null && !widget.iconAtEnd) ...[
                      widget.icon!,
                      const SizedBox(width: CatchSpacing.s2),
                    ],
                    Flexible(
                      child: Text(
                        widget.label,
                        style: CatchTextStyles.control(
                          context,
                          color: _enabled ? t.ink : t.ink3,
                        ),
                      ),
                    ),
                    if (widget.icon != null && widget.iconAtEnd) ...[
                      const SizedBox(width: CatchSpacing.s2),
                      widget.icon!,
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }
    final spec = _ButtonSizeSpec.from(widget.size);
    final mediaQuery = MediaQuery.maybeOf(context);
    final reduceMotion = mediaQuery?.disableAnimations ?? false;
    final transitionDuration = reduceMotion
        ? CatchMotion.none
        : CatchMotion.fast;
    final radius = widget.shape == CatchButtonShape.pill
        ? CatchRadius.pill
        : CatchRadius.md;
    var palette = _ButtonPalette.from(widget.variant, t);
    final accent = widget.accentColor;
    if (accent != null && widget.variant == CatchButtonVariant.primary) {
      palette = palette.copyWith(
        background: accent,
        foreground: CatchTokens.editorialWhite,
        border: Colors.transparent,
      );
    }
    palette = palette.copyWith(
      background: widget.backgroundColor,
      foreground: widget.foregroundColor,
      border: widget.borderColor,
    );
    final border = _focused
        ? CatchBorder.resolve(t, CatchBorderRole.focus)
        : widget.variant == CatchButtonVariant.secondary
        ? CatchBorder.interactive(
            t,
            _pressed
                ? CatchInteractiveBorderState.pressed
                : _hovered
                ? CatchInteractiveBorderState.hovered
                : CatchInteractiveBorderState.resting,
          ).copyWith(color: widget.borderColor)
        : CatchBorder.resolve(
            t,
            CatchBorderRole.boundary,
            color: palette.border,
          );

    final buttonContent = Stack(
      alignment: Alignment.center,
      children: [
        if (_enabled && (_hovered || _pressed))
          Positioned.fill(
            child: ColoredBox(
              color: CatchTokens.editorialBlack.withValues(
                alpha: _pressed
                    ? CatchOpacity.controlOverlayPressed
                    : CatchOpacity.controlOverlayHover,
              ),
            ),
          ),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: spec.padding,
            vertical: CatchSpacing.s2,
          ),
          child: AnimatedSwitcher(
            duration: transitionDuration,
            switchInCurve: CatchMotion.standardCurve,
            switchOutCurve: CatchMotion.standardCurve,
            child: widget.isLoading
                ? CatchButtonLoadingDots(color: palette.foreground)
                : CatchButtonLabel(
                    label: widget.label,
                    color: palette.foreground,
                    icon: widget.icon,
                    gap: spec.gap,
                    fullWidth: widget.fullWidth,
                    allowMultiline: true,
                    textStyle: spec.textStyle(context),
                  ),
          ),
        ),
      ],
    );

    final decoratedButton = ConstrainedBox(
      constraints: BoxConstraints(minHeight: spec.height),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(radius),
          border: border.all,
          boxShadow: _focused ? CatchElevation.focusRing(t) : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: buttonContent,
        ),
      ),
    );

    final child = AnimatedScale(
      scale: _enabled && _pressed ? 0.97 : 1,
      duration: transitionDuration,
      curve: CatchMotion.standardCurve,
      child: AnimatedOpacity(
        opacity: widget.isInteractive && !_enabled ? 0.4 : 1,
        duration: transitionDuration,
        curve: CatchMotion.standardCurve,
        child: decoratedButton,
      ),
    );

    return Semantics(
      button: widget.isInteractive,
      enabled: widget.isInteractive ? _enabled : null,
      label: widget.semanticsLabel ?? widget.label,
      child: widget.isInteractive
          ? Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _enabled ? widget.onPressed : null,
                onHover: (hovered) => setState(() => _hovered = hovered),
                onFocusChange: (focused) => setState(() => _focused = focused),
                onHighlightChanged: (pressed) =>
                    setState(() => _pressed = pressed),
                // Feedback is painted on the visual button, not its invisible
                // target padding. There is only one gesture/focus owner.
                splashFactory: NoSplash.splashFactory,
                highlightColor: Colors.transparent,
                hoverColor: Colors.transparent,
                focusColor: Colors.transparent,
                borderRadius: BorderRadius.circular(radius),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: CatchPlatformTokens.minimumInteractiveExtent,
                    minWidth: CatchPlatformTokens.minimumInteractiveExtent,
                  ),
                  child: Align(
                    widthFactor: widget.fullWidth ? null : 1,
                    heightFactor: 1,
                    child: widget.fullWidth
                        ? SizedBox(width: double.infinity, child: child)
                        : child,
                  ),
                ),
              ),
            )
          : widget.fullWidth
          ? SizedBox(width: double.infinity, child: child)
          : child,
    );
  }
}

class CatchButtonLabel extends StatelessWidget {
  const CatchButtonLabel({
    super.key,
    required this.label,
    required this.color,
    required this.textStyle,
    this.icon,
    this.gap = CatchSpacing.micro6,
    this.fullWidth = false,
    this.allowMultiline = false,
  });

  final String label;
  final Color color;
  final Widget? icon;
  final double gap;
  final bool fullWidth;
  final bool allowMultiline;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final iconWidget = icon;
    final labelWidget = Text(
      label,
      maxLines: allowMultiline ? null : 1,
      overflow: allowMultiline ? TextOverflow.visible : TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: textStyle.copyWith(color: color),
    );
    final content = Row(
      mainAxisSize: allowMultiline && fullWidth
          ? MainAxisSize.max
          : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (iconWidget != null) ...[
          IconTheme(
            data: IconThemeData(color: color, size: CatchIcon.md),
            child: iconWidget,
          ),
          SizedBox(width: gap),
        ],
        if (allowMultiline) Flexible(child: labelWidget) else labelWidget,
      ],
    );

    if (allowMultiline) return content;
    if (fullWidth) {
      return Center(
        child: FittedBox(fit: BoxFit.scaleDown, child: content),
      );
    }

    return FittedBox(fit: BoxFit.scaleDown, child: content);
  }
}

class CatchButtonLoadingDots extends StatelessWidget {
  const CatchButtonLoadingDots({super.key, required this.color});

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
              color: color.withValues(
                alpha: CatchOpacity.loadingDotAlphas[index],
              ),
              borderRadius: BorderRadius.circular(CatchRadius.pill),
            ),
            child: const SizedBox.square(dimension: CatchSpacing.micro6),
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
    required this.gap,
    required this.textStyle,
  });

  final double height;
  final double padding;
  final double gap;
  final TextStyle Function(BuildContext context) textStyle;

  static _ButtonSizeSpec from(CatchButtonSize size) {
    return switch (size) {
      CatchButtonSize.sm => const _ButtonSizeSpec(
        height: CatchSpacing.s9,
        padding: CatchSpacing.micro14,
        gap: CatchSpacing.micro6,
        textStyle: CatchTextStyles.buttonSm,
      ),
      CatchButtonSize.md => const _ButtonSizeSpec(
        height: CatchSpacing.s12,
        padding: CatchSpacing.s5,
        gap: CatchSpacing.micro6,
        textStyle: CatchTextStyles.buttonMd,
      ),
      CatchButtonSize.lg => const _ButtonSizeSpec(
        height: CatchLayout.buttonLgHeight,
        padding: CatchSpacing.s6,
        gap: CatchSpacing.micro6,
        textStyle: CatchTextStyles.buttonLg,
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
        foreground: CatchTokens.editorialWhite,
        border: Colors.transparent,
      ),
      CatchButtonVariant.light => _ButtonPalette(
        background: CatchTokens.editorialWhite,
        foreground: CatchTokens.editorialLight.ink,
        border: Colors.transparent,
      ),
    };
  }
}
