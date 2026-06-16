import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:flutter/material.dart';

class CatchNumberStepper extends StatelessWidget {
  const CatchNumberStepper({
    super.key,
    required this.value,
    required this.formatValue,
    this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.onDecrease,
    this.onIncrease,
    this.decreaseTooltip = 'Decrease',
    this.increaseTooltip = 'Increase',
    this.enabled = true,
  });

  final num value;
  final String Function(num value) formatValue;
  final ValueChanged<num>? onChanged;
  final num? min;
  final num? max;
  final num step;
  final VoidCallback? onDecrease;
  final VoidCallback? onIncrease;
  final String decreaseTooltip;
  final String increaseTooltip;
  final bool enabled;

  VoidCallback? get _decrease {
    if (!enabled) return null;
    if (onDecrease != null) return onDecrease;
    final next = value - step;
    if (onChanged == null || (min != null && next < min!)) return null;
    return () => onChanged!(next);
  }

  VoidCallback? get _increase {
    if (!enabled) return null;
    if (onIncrease != null) return onIncrease;
    final next = value + step;
    if (onChanged == null || (max != null && next > max!)) return null;
    return () => onChanged!(next);
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchControlShell(
      tone: CatchControlTone.raised,
      enabled: enabled,
      padding: CatchControlMetrics.contentPadding(CatchControlSize.md),
      child: Row(
        children: [
          IconButton(
            tooltip: decreaseTooltip,
            icon: Icon(CatchIcons.removeRounded, color: t.ink),
            onPressed: _decrease,
            constraints: CatchControlMetrics.squareConstraints(
              CatchControlMetrics.stepperIconExtent,
            ),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Center(
              child: Text(
                formatValue(value),
                // Stepper value is the focal datum — `.t-numeric-l` (16/w700).
                style: CatchTextStyles.numericLarge(context),
              ),
            ),
          ),
          IconButton(
            tooltip: increaseTooltip,
            icon: Icon(CatchIcons.addRounded, color: t.ink),
            onPressed: _increase,
            constraints: CatchControlMetrics.squareConstraints(
              CatchControlMetrics.stepperIconExtent,
            ),
            padding: EdgeInsets.zero,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
