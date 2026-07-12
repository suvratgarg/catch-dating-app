import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:flutter/material.dart';
import 'package:catch_dating_app/l10n/l10n.dart';

enum CatchSearchFieldMode { field, expanding, expanded }

/// Handoff `SearchField`: raised pill input with search glyph and quiet clear
/// target.
class CatchSearchField extends StatefulWidget {
  const CatchSearchField({
    super.key,
    this.value = '',
    this.placeholder = 'Search',
    this.onChanged,
    this.autofocus = false,
    this.enabled = true,
    this.textInputAction = TextInputAction.done,
    this.onSubmitted,
    this.onFocusChanged,
    this.semanticLabel,
    this.emptyTrailingIcon,
    this.emptyTrailingTooltip,
    this.onEmptyTrailingPressed,
    this.mode = CatchSearchFieldMode.field,
    this.expanded = true,
    this.progress,
    this.maxWidth,
    this.onOpenSearch,
    this.onCloseSearch,
    this.tooltip = 'Search',
    this.collapsedExtent = CatchIconButton.navSize,
    this.backgroundColor,
    this.borderColor,
    this.foregroundColor,
    this.mutedForegroundColor,
  });

  final String value;
  final String placeholder;
  final ValueChanged<String>? onChanged;
  final bool autofocus;
  final bool enabled;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onFocusChanged;
  final String? semanticLabel;
  final IconData? emptyTrailingIcon;
  final String? emptyTrailingTooltip;
  final VoidCallback? onEmptyTrailingPressed;
  final CatchSearchFieldMode mode;
  final bool expanded;
  final double? progress;
  final double? maxWidth;
  final VoidCallback? onOpenSearch;
  final VoidCallback? onCloseSearch;
  final String tooltip;
  final double collapsedExtent;
  final Color? backgroundColor;
  final Color? borderColor;
  final Color? foregroundColor;
  final Color? mutedForegroundColor;

  @override
  State<CatchSearchField> createState() => _CatchSearchFieldState();
}

class _CatchSearchFieldState extends State<CatchSearchField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
  }

  @override
  void didUpdateWidget(covariant CatchSearchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
    }
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChanged() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
    setState(() {});
  }

  void _handleSubmitted(String value) {
    widget.onSubmitted?.call(value);
    _focusNode.unfocus();
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
    _focusNode.requestFocus();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (widget.mode != CatchSearchFieldMode.field) {
      return _buildExpandingSearch(context);
    }

    final t = CatchTokens.of(context);
    final foreground = widget.foregroundColor ?? t.ink;
    final mutedForeground = widget.mutedForegroundColor ?? t.ink3;

    return Semantics(
      label: widget.semanticLabel ?? widget.placeholder,
      textField: true,
      child: CatchControlShell(
        size: CatchControlSize.compact,
        shape: CatchControlShape.pill,
        tone: CatchControlTone.raised,
        enabled: widget.enabled,
        focused: _focusNode.hasFocus,
        padding: const EdgeInsets.only(
          left: CatchSpacing.s4,
          right: CatchSpacing.s2,
        ),
        child: Row(
          children: [
            Icon(
              CatchIcons.search,
              size: CatchLayout.searchFieldIconSize,
              color: mutedForeground,
            ),
            const SizedBox(width: CatchLayout.searchFieldIconGap),
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                autofocus: widget.autofocus,
                enabled: widget.enabled,
                textInputAction: widget.textInputAction,
                onChanged: widget.onChanged,
                onSubmitted: _handleSubmitted,
                onTapOutside: (_) => _focusNode.unfocus(),
                style: CatchTextStyles.bodyM(
                  context,
                  color: widget.enabled ? foreground : mutedForeground,
                ),
                cursorColor: t.primary,
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  fillColor: Colors.transparent,
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  hintText: widget.placeholder,
                  hintStyle: CatchTextStyles.bodyM(
                    context,
                    color: mutedForeground,
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, _) {
                if (value.text.isEmpty) {
                  if (widget.emptyTrailingIcon != null &&
                      widget.onEmptyTrailingPressed != null) {
                    return SizedBox.square(
                      dimension: CatchLayout.searchFieldClearSize,
                      child: IconButton(
                        tooltip:
                            widget.emptyTrailingTooltip ?? widget.placeholder,
                        padding: EdgeInsets.zero,
                        style: IconButton.styleFrom(
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(
                          widget.emptyTrailingIcon,
                          size: CatchLayout.searchFieldClearIconSize,
                          color: mutedForeground,
                        ),
                        onPressed: widget.enabled
                            ? widget.onEmptyTrailingPressed
                            : null,
                      ),
                    );
                  }

                  return const SizedBox(
                    width: CatchLayout.searchFieldClearSize,
                  );
                }

                return SizedBox.square(
                  dimension: CatchLayout.searchFieldClearSize,
                  child: IconButton(
                    tooltip: context.l10n
                        .coreCatchSearchFieldTooltipClearPlaceholder(
                          placeholder: widget.placeholder,
                        ),
                    padding: EdgeInsets.zero,
                    style: IconButton.styleFrom(
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    icon: Icon(
                      CatchIcons.clearCircle,
                      size: CatchLayout.searchFieldClearIconSize,
                      color: mutedForeground,
                    ),
                    onPressed: widget.enabled ? _clear : null,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandingSearch(BuildContext context) {
    final targetProgress = widget.mode == CatchSearchFieldMode.expanded
        ? 1.0
        : (widget.progress ?? (widget.expanded ? 1.0 : 0.0));

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(end: targetProgress),
      duration: CatchMotion.base,
      curve: CatchMotion.standardCurve,
      builder: (context, progress, _) =>
          _buildExpandingSearchAt(context, progress),
    );
  }

  Widget _buildExpandingSearchAt(BuildContext context, double progress) {
    final t = CatchTokens.of(context);
    final foreground = widget.foregroundColor ?? t.ink;
    final mutedForeground = widget.mutedForegroundColor ?? t.ink3;
    final maxWidth = widget.maxWidth ?? widget.collapsedExtent;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final width =
        widget.collapsedExtent +
        ((maxWidth - widget.collapsedExtent) * clampedProgress);
    final fieldOpacity = ((clampedProgress - 0.12) / 0.88).clamp(0.0, 1.0);
    final iconOpacity = (1 - (clampedProgress / 0.42)).clamp(0.0, 1.0);
    final fieldInteractive = clampedProgress > 0.72;
    final collapsedInteractive = clampedProgress < 0.08;
    final radius = BorderRadius.circular(CatchRadius.pill);
    if (fieldInteractive &&
        widget.autofocus &&
        widget.enabled &&
        !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !widget.enabled || _focusNode.hasFocus) return;
        _focusNode.requestFocus();
      });
    }

    return Align(
      alignment: Alignment.centerRight,
      widthFactor: 1,
      heightFactor: 1,
      child: SizedBox(
        width: width,
        height: widget.collapsedExtent,
        child: Material(
          color: Colors.transparent,
          borderRadius: radius,
          clipBehavior: Clip.antiAlias,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? t.surface,
              borderRadius: radius,
              border: Border.all(color: widget.borderColor ?? t.line2),
            ),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (clampedProgress > 0)
                  IgnorePointer(
                    ignoring: !fieldInteractive,
                    child: ExcludeSemantics(
                      excluding: !fieldInteractive,
                      child: Opacity(
                        opacity: fieldOpacity,
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: CatchSpacing.s3,
                            right: CatchSpacing.s1,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                CatchIcons.search,
                                size: CatchLayout.searchFieldIconSize,
                                color: mutedForeground,
                              ),
                              const SizedBox(
                                width: CatchLayout.searchFieldIconGap,
                              ),
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  autofocus: widget.autofocus,
                                  enabled: widget.enabled,
                                  textInputAction: widget.textInputAction,
                                  onChanged: widget.onChanged,
                                  onSubmitted: _handleSubmitted,
                                  onTapOutside: (_) => _focusNode.unfocus(),
                                  style: CatchTextStyles.bodyM(
                                    context,
                                    color: widget.enabled
                                        ? foreground
                                        : mutedForeground,
                                  ),
                                  cursorColor: t.primary,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: false,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    disabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    hintText: widget.placeholder,
                                    hintStyle: CatchTextStyles.bodyM(
                                      context,
                                      color: mutedForeground,
                                    ),
                                  ),
                                ),
                              ),
                              _ExpandingSearchTrailing(
                                controller: _controller,
                                enabled: widget.enabled,
                                placeholder: widget.placeholder,
                                emptyTrailingTooltip: context
                                    .l10n
                                    .coreCatchSearchFieldVisiblecopyCloseSearch,
                                foregroundColor: mutedForeground,
                                onClear: _clear,
                                onEmptyPressed:
                                    widget.onCloseSearch ??
                                    widget.onEmptyTrailingPressed,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                IgnorePointer(
                  ignoring: !collapsedInteractive,
                  child: ExcludeSemantics(
                    excluding: !collapsedInteractive,
                    child: Opacity(
                      opacity: iconOpacity,
                      child: InkWell(
                        onTap: widget.enabled ? widget.onOpenSearch : null,
                        child: Tooltip(
                          message: widget.tooltip,
                          excludeFromSemantics: true,
                          child: Semantics(
                            button: true,
                            enabled: widget.enabled,
                            label: widget.semanticLabel ?? widget.tooltip,
                            child: Center(
                              child: Icon(
                                CatchIcons.search,
                                size: CatchIcon.md,
                                color: foreground,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ExpandingSearchTrailing extends StatelessWidget {
  const _ExpandingSearchTrailing({
    required this.controller,
    required this.enabled,
    required this.placeholder,
    required this.emptyTrailingTooltip,
    required this.foregroundColor,
    required this.onClear,
    required this.onEmptyPressed,
  });

  final TextEditingController controller;
  final bool enabled;
  final String placeholder;
  final String emptyTrailingTooltip;
  final Color foregroundColor;
  final VoidCallback onClear;
  final VoidCallback? onEmptyPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        final isEmpty = value.text.isEmpty;
        final icon = isEmpty ? CatchIcons.close : CatchIcons.clearCircle;
        final tooltip = isEmpty
            ? emptyTrailingTooltip
            : context.l10n.coreCatchSearchFieldTooltipClearPlaceholder(
                placeholder: placeholder,
              );
        final onPressed = isEmpty ? onEmptyPressed : onClear;
        if (isEmpty && onPressed == null) {
          return const SizedBox(width: CatchLayout.searchFieldClearSize);
        }

        return SizedBox.square(
          dimension: CatchLayout.searchFieldClearSize,
          child: IconButton(
            tooltip: tooltip,
            padding: EdgeInsets.zero,
            style: IconButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: Icon(
              icon,
              size: CatchLayout.searchFieldClearIconSize,
              color: foregroundColor,
            ),
            onPressed: enabled ? onPressed : null,
          ),
        );
      },
    );
  }
}
