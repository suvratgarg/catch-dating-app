import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
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
    return CatchSurface(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      tone: CatchSurfaceTone.raised,
      radius: CatchRadius.md,
      borderColor: t.line,
      child: Row(
        children: [
          IconButton(
            tooltip: decreaseTooltip,
            icon: Icon(Icons.remove_rounded, color: t.ink),
            onPressed: _decrease,
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: Center(
              child: Text(
                formatValue(value),
                style: CatchTextStyles.mono(context),
              ),
            ),
          ),
          IconButton(
            tooltip: increaseTooltip,
            icon: Icon(Icons.add_rounded, color: t.ink),
            onPressed: _increase,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}
