import 'package:catch_dating_app/core/schema_contracts/catch_contract_field_policy.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart'
    show CatchContractConstraints, CatchContractFieldConstraints;

enum CatchOptionGroupVariant { label, mono }

class CatchOption<T> {
  const CatchOption({required this.value, required this.label});

  final T value;
  final String label;
}

/// Design-system OptionGroup: an underline selection row for tabs, lenses, and
/// inline scope controls.
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
  final T selected;
  final CatchContractFieldConstraints? contract;
  final String Function(T value)? contractValue;
  final String? contractExemption;
  final ValueChanged<T>? onChanged;
  final CatchOptionGroupVariant variant;
  final Color? accent;
  final Widget? trailing;
  final EdgeInsetsGeometry contentPadding;
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
        oldWidget.options != widget.options ||
        oldWidget.contract != widget.contract ||
        oldWidget.contractValue != widget.contractValue) {
      _syncLabelKeys();
    }
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
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final options = _options;
    assert(
      options.any((option) => option.value == widget.selected),
      'CatchOptionGroup selected value must be allowed by its contract.',
    );
    final selectedRule = widget.accent ?? t.ink;
    final gap = widget.variant == CatchOptionGroupVariant.mono
        ? CatchSpacing.s4
        : CatchSpacing.micro18;
    final selectedIndex = options.indexWhere(
      (option) => option.value == widget.selected,
    );
    final indicatorRect = _indicatorRect(selectedIndex);
    final indicatorDuration = widget.selectionPosition == null
        ? CatchMotion.fast
        : Duration.zero;

    final optionsRow = Row(
      mainAxisSize: widget.scrollable ? MainAxisSize.min : MainAxisSize.max,
      children: [
        for (var index = 0; index < options.length; index += 1) ...[
          if (index != 0) SizedBox(width: gap),
          if (widget.scrollable)
            CatchOptionGroupItem<T>(
              option: options[index],
              selected: index == selectedIndex,
              selectedRule: selectedRule,
              variant: widget.variant,
              showIndicator: false,
              labelKey: _labelKeys[index],
              onTap: widget.onChanged == null
                  ? null
                  : () => widget.onChanged!(options[index].value),
            )
          else
            Flexible(
              flex: options[index].label.length,
              child: CatchOptionGroupItem<T>(
                option: options[index],
                selected: index == selectedIndex,
                selectedRule: selectedRule,
                variant: widget.variant,
                showIndicator: false,
                labelKey: _labelKeys[index],
                onTap: widget.onChanged == null
                    ? null
                    : () => widget.onChanged!(options[index].value),
              ),
            ),
        ],
      ],
    );

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
                child: widget.scrollable
                    ? SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: optionsRow,
                      )
                    : optionsRow,
              ),
              if (widget.trailing != null) ...[
                const SizedBox(width: CatchSpacing.s3),
                widget.trailing!,
              ],
            ],
          ),
        ),
        if (indicatorRect != null)
          AnimatedPositioned(
            duration: indicatorDuration,
            curve: CatchMotion.standardCurve,
            left: indicatorRect.left,
            bottom: 0,
            width: indicatorRect.width,
            child: DecoratedBox(
              decoration: BoxDecoration(color: selectedRule),
              child: const SizedBox(height: CatchSpacing.micro3),
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

class CatchOptionGroupItem<T> extends StatelessWidget {
  const CatchOptionGroupItem({
    super.key,
    required this.option,
    required this.selected,
    this.selectedRule,
    this.variant = CatchOptionGroupVariant.label,
    this.onTap,
    this.showIndicator = true,
    this.labelKey,
  });

  final CatchOption<T> option;
  final bool selected;
  final Color? selectedRule;
  final CatchOptionGroupVariant variant;
  final VoidCallback? onTap;
  final bool showIndicator;
  final Key? labelKey;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final foreground = selected ? t.ink : t.ink3;
    final selectedRuleColor = selectedRule ?? t.ink;
    final style = switch (variant) {
      CatchOptionGroupVariant.label => CatchTextStyles.labelL(
        context,
        color: foreground,
      ),
      CatchOptionGroupVariant.mono => CatchTextStyles.monoLabel(
        context,
        color: foreground,
      ),
    };
    final label = variant == CatchOptionGroupVariant.mono
        ? option.label.toUpperCase()
        : option.label;

    return Semantics(
      button: onTap != null,
      selected: selected,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CatchRadius.sm),
          child: AnimatedContainer(
            duration: CatchMotion.fast,
            curve: CatchMotion.standardCurve,
            padding: const EdgeInsets.symmetric(
              horizontal: CatchSpacing.s1,
              vertical: CatchSpacing.s2,
            ),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: showIndicator && selected
                      ? selectedRuleColor
                      : Colors.transparent,
                  width: CatchSpacing.micro3,
                ),
              ),
            ),
            child: Text(
              label,
              key: labelKey,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: style,
            ),
          ),
        ),
      ),
    );
  }
}
