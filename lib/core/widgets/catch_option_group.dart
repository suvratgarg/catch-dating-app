import 'dart:async';

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart'
    show CatchContractConstraints;

/// Design-system OptionGroup: an underline selection row for tabs, lenses, and
/// inline scalar scope controls whose fixed, terse options fit the viewport.
/// Non-summary variants scroll automatically when full scaled labels no longer
/// fit. [scrollable] forces that mode; it never permits undersized targets.
/// Use `CatchAdaptiveSelectionControl` when the choices are numerous, long, or
/// dynamic enough that the inline row would hide their meaning.
class CatchOptionGroup<T> extends StatefulWidget {
  const CatchOptionGroup({
    super.key,
    required this.options,
    required this.selected,
    this.contract,
    this.contractValue,
    this.contractExemption,
    this.onChanged,
    this.variant = CatchOptionGroupVariant.label,
    this.accent,
    this.trailing,
    this.contentPadding = EdgeInsets.zero,
    this.scrollable = false,
    this.showDivider = true,
    this.selectionPosition,
  });

  final List<CatchOption<T>> options;

  /// Null leaves every option unselected unless null is an explicit option.
  final T? selected;
  final CatchContractFieldConstraints? contract;
  final String Function(T value)? contractValue;
  final String? contractExemption;
  final ValueChanged<T>? onChanged;
  final CatchOptionGroupVariant variant;
  final Color? accent;
  final Widget? trailing;
  final EdgeInsetsGeometry contentPadding;

  /// Force horizontal scrolling; overflow also enables it when false.
  final bool scrollable;
  final bool showDivider;

  /// Fractional selected option index, usually from [TabController.animation].
  ///
  /// When provided, the underline tracks drag progress exactly. When omitted,
  /// the underline animates between discrete selected values.
  final double? selectionPosition;

  @override
  State<CatchOptionGroup<T>> createState() => _CatchOptionGroupState<T>();
}

class _CatchOptionGroupState<T> extends State<CatchOptionGroup<T>> {
  final GlobalKey _groupKey = GlobalKey();
  var _labelKeys = <GlobalKey>[];
  var _labelRects = <Rect?>[];
  bool _revealSelected = true;

  List<CatchOption<T>> get _options {
    final values = CatchContractFieldPolicy.supportedChoiceValues(
      widget.contract,
      widget.options.map((option) => option.value).toList(growable: false),
      widget.contractValue,
      multi: false,
    ).toSet();
    return widget.options
        .where((option) => values.contains(option.value))
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _syncLabelKeys();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLabelRects());
  }

  @override
  void didUpdateWidget(covariant CatchOptionGroup<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.options.length != widget.options.length ||
        oldWidget.contract != widget.contract ||
        oldWidget.contractValue != widget.contractValue) {
      _syncLabelKeys();
    }
    if (oldWidget.selected != widget.selected) _revealSelected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLabelRects());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Text scaling and viewport changes can hide a previously visible tab.
    _revealSelected = true;
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateLabelRects());
  }

  void _syncLabelKeys() {
    _labelKeys = [
      for (var index = 0; index < _options.length; index += 1) GlobalKey(),
    ];
    _labelRects = List<Rect?>.filled(_options.length, null);
  }

  void _updateLabelRects() {
    if (!mounted) return;
    final groupContext = _groupKey.currentContext;
    if (groupContext == null) return;
    final groupBox = groupContext.findRenderObject() as RenderBox?;
    if (groupBox == null || !groupBox.hasSize) return;

    final nextRects = <Rect?>[];
    for (final key in _labelKeys) {
      final labelContext = key.currentContext;
      final labelBox = labelContext?.findRenderObject() as RenderBox?;
      if (labelBox == null || !labelBox.hasSize) {
        nextRects.add(null);
        continue;
      }
      final offset = labelBox.localToGlobal(Offset.zero, ancestor: groupBox);
      nextRects.add(offset & labelBox.size);
    }

    var changed = nextRects.length != _labelRects.length;
    if (!changed) {
      for (var index = 0; index < nextRects.length; index += 1) {
        if (nextRects[index] != _labelRects[index]) {
          changed = true;
          break;
        }
      }
    }
    if (changed) setState(() => _labelRects = nextRects);
    if (_revealSelected) {
      _revealSelected = false;
      final index = _options.indexWhere(
        (option) => option.value == widget.selected,
      );
      if (index < 0 || index >= _labelKeys.length) return;
      final labelContext = _labelKeys[index].currentContext;
      if (labelContext == null) return;
      final scrollable = Scrollable.maybeOf(
        labelContext,
        axis: Axis.horizontal,
      );
      final labelBox = labelContext.findRenderObject();
      if (scrollable != null && labelBox != null) {
        // Reveal only this rail. Scrolling an ancestor page would move content
        // unexpectedly when a user switches tabs or restores a deep link.
        unawaited(scrollable.position.ensureVisible(labelBox, alignment: 0.5));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final options = _options;
    assert(
      widget.selected == null ||
          options.any((option) => option.value == widget.selected),
      'CatchOptionGroup selected value must be allowed by its contract.',
    );
    if (widget.variant == CatchOptionGroupVariant.summary) {
      return Padding(
        padding: widget.contentPadding,
        child: Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final option in options)
              CatchOptionGroupItem<T>(
                option: option,
                selected: option.value == widget.selected,
                variant: widget.variant,
                onTap: widget.onChanged == null || !option.enabled
                    ? null
                    : () => widget.onChanged!(option.value),
              ),
            ?widget.trailing,
          ],
        ),
      );
    }
    final selectedRule = widget.accent ?? t.ink;
    final gap = switch (widget.variant) {
      CatchOptionGroupVariant.summary => CatchSpacing.s2,
      CatchOptionGroupVariant.mono => CatchSpacing.s4,
      CatchOptionGroupVariant.operational => CatchSpacing.s1,
      CatchOptionGroupVariant.label => CatchSpacing.micro18,
    };
    final selectedIndex = options.indexWhere(
      (option) => option.value == widget.selected,
    );
    final indicatorRect = _indicatorRect(selectedIndex);
    final indicatorDuration =
        !MediaQuery.disableAnimationsOf(context) &&
            widget.selectionPosition == null
        ? CatchMotion.fast
        : Duration.zero;

    // Select scrolling from content, not a caller's guess. Compressing a row
    // of choices must never shrink its hitboxes or ellipsize the only labels.
    final optionWidths = <double>[];
    final neededWidth =
        options.fold<double>(0, (width, option) {
          final style = switch (widget.variant) {
            CatchOptionGroupVariant.mono => CatchTextStyles.monoLabel(context),
            CatchOptionGroupVariant.operational => CatchTextStyles.labelL(
              context,
            ),
            _ => CatchTextStyles.tabLabel(context, selected: true),
          };
          final painter = TextPainter(
            text: TextSpan(
              text: widget.variant == CatchOptionGroupVariant.mono
                  ? option.label.toUpperCase()
                  : option.label,
              style: style,
            ),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final horizontalPadding =
              widget.variant == CatchOptionGroupVariant.operational &&
                  MediaQuery.textScalerOf(context).scale(1) < 1.4
              ? CatchSpacing.s4
              : CatchSpacing.s2;
          final iconWidth =
              option.icon != null &&
                  MediaQuery.textScalerOf(context).scale(1) < 1.4
              ? CatchLayout.optionGroupIconSlotExtent
              : 0;
          final contentWidth = painter.width + horizontalPadding + iconWidth;
          painter.dispose();
          final targetWidth =
              contentWidth < CatchPlatformTokens.minimumInteractiveExtent
              ? CatchPlatformTokens.minimumInteractiveExtent
              : contentWidth.ceilToDouble();
          optionWidths.add(targetWidth);
          return width + targetWidth;
        }) +
        gap * (options.length - 1).clamp(0, options.length);

    return Stack(
      key: _groupKey,
      clipBehavior: Clip.none,
      children: [
        if (widget.showDivider)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(color: t.line),
              child: const SizedBox(height: CatchStroke.hairline),
            ),
          ),
        Padding(
          padding: widget.contentPadding,
          child: Row(
            children: [
              Expanded(
                child: LayoutBuilder(
                  builder: (context, available) {
                    final operationalWidth = optionWidths.isEmpty
                        ? 0.0
                        : optionWidths.reduce((a, b) => a > b ? a : b) *
                                  options.length +
                              gap * (options.length - 1);
                    final requiredWidth =
                        widget.variant == CatchOptionGroupVariant.operational
                        ? operationalWidth
                        : neededWidth;
                    final scrollable =
                        widget.scrollable || requiredWidth > available.maxWidth;
                    final optionsRow = Row(
                      mainAxisSize: scrollable
                          ? MainAxisSize.min
                          : MainAxisSize.max,
                      children: [
                        for (
                          var index = 0;
                          index < options.length;
                          index += 1
                        ) ...[
                          if (index != 0) SizedBox(width: gap),
                          if (scrollable)
                            CatchOptionGroupItem<T>(
                              option: options[index],
                              selected: index == selectedIndex,
                              selectedRule: selectedRule,
                              variant: widget.variant,
                              showIndicator: false,
                              labelKey: _labelKeys[index],
                              onTap:
                                  widget.onChanged == null ||
                                      !options[index].enabled
                                  ? null
                                  : () =>
                                        widget.onChanged!(options[index].value),
                            )
                          else
                            Flexible(
                              flex:
                                  widget.variant ==
                                      CatchOptionGroupVariant.operational
                                  ? 1
                                  : optionWidths[index].ceil(),
                              child: CatchOptionGroupItem<T>(
                                option: options[index],
                                selected: index == selectedIndex,
                                selectedRule: selectedRule,
                                variant: widget.variant,
                                showIndicator: false,
                                labelKey: _labelKeys[index],
                                onTap:
                                    widget.onChanged == null ||
                                        !options[index].enabled
                                    ? null
                                    : () => widget.onChanged!(
                                        options[index].value,
                                      ),
                              ),
                            ),
                        ],
                      ],
                    );

                    return scrollable
                        ? NotificationListener<ScrollNotification>(
                            onNotification: (_) {
                              WidgetsBinding.instance.addPostFrameCallback(
                                (_) => _updateLabelRects(),
                              );
                              return false;
                            },
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: optionsRow,
                            ),
                          )
                        : optionsRow;
                  },
                ),
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: CatchSpacing.s3),
                widget.trailing!,
              ],
            ],
          ),
        ),
        if (indicatorRect != null &&
            widget.variant != CatchOptionGroupVariant.operational)
          AnimatedPositioned(
            duration: indicatorDuration,
            curve: CatchMotion.standardCurve,
            left: indicatorRect.left,
            bottom: 0,
            width: indicatorRect.width,
            child: DecoratedBox(
              decoration: BoxDecoration(color: selectedRule),
              child: const SizedBox(height: CatchSpacing.micro2),
            ),
          ),
      ],
    );
  }

  Rect? _indicatorRect(int selectedIndex) {
    if (selectedIndex < 0 || _labelRects.isEmpty || _options.isEmpty) {
      return null;
    }
    final position = (widget.selectionPosition ?? selectedIndex.toDouble())
        .clamp(0, _options.length - 1)
        .toDouble();
    final lowerIndex = position.floor();
    final upperIndex = position.ceil();
    if (lowerIndex < 0 ||
        lowerIndex >= _labelRects.length ||
        upperIndex < 0 ||
        upperIndex >= _labelRects.length) {
      return null;
    }
    final lowerRect = _labelRects[lowerIndex];
    final upperRect = _labelRects[upperIndex];
    if (lowerRect == null || upperRect == null) return null;
    return Rect.lerp(lowerRect, upperRect, position - lowerIndex);
  }
}
