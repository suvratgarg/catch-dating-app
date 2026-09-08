import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/src/components/catch_field_repeat_button.dart';
import 'package:catch_ui/src/foundations/catch_icons.dart';
import 'package:catch_ui/src/foundations/catch_text_styles.dart';
import 'package:flutter/material.dart';

/// Exact numeric control used by `CatchField.stepper`.
class CatchFieldStepper extends StatelessWidget {
  const CatchFieldStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.decreaseSemanticLabel,
    required this.increaseSemanticLabel,
    this.min,
    this.max,
    this.step = 1,
    this.unit,
    this.formatter,
    this.enabled = true,
  });

  final num value;
  final ValueChanged<num>? onChanged;
  final num? min;
  final num? max;
  final num step;
  final String? unit;
  final String Function(num value)? formatter;
  final String decreaseSemanticLabel;
  final String increaseSemanticLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final number = formatter?.call(value) ?? _formatNumber(value);
    final formatted = unit == null ? number : '$number $unit';
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        key: const ValueKey('catch-field-stepper'),
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchFieldRepeatButton(
            icon: CatchIcons.removeRounded,
            semanticLabel: decreaseSemanticLabel,
            enabled:
                enabled && onChanged != null && (min == null || value > min!),
            onStep: () => onChanged?.call(_nextValue(-step)),
          ),
          SizedBox(width: CatchFieldRepeatButton.layoutGap),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: CatchFieldTokens.stepperValueMinWidth,
            ),
            child: Text(
              formatted,
              key: const ValueKey('catch-field-stepper-value'),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: CatchTextStyles.fieldRowTitle(context, color: t.ink),
            ),
          ),
          SizedBox(width: CatchFieldRepeatButton.layoutGap),
          CatchFieldRepeatButton(
            icon: CatchIcons.addRounded,
            semanticLabel: increaseSemanticLabel,
            enabled:
                enabled && onChanged != null && (max == null || value < max!),
            onStep: () => onChanged?.call(_nextValue(step)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(num number) => number == number.roundToDouble()
      ? number.toInt().toString()
      : number.toString();

  num _nextValue(num delta) {
    num next = ((value + delta) * 100).round() / 100;
    if (min != null && next < min!) next = min!;
    if (max != null && next > max!) next = max!;
    return next;
  }
}
