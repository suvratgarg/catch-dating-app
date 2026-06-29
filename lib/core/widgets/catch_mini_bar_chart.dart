import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';

class CatchMiniBarChart extends StatelessWidget {
  const CatchMiniBarChart({
    super.key,
    required this.values,
    this.maxValue,
    this.height = CatchSpacing.s16,
    this.spacing = CatchSpacing.micro6,
    this.minFilledHeightFactor = 0.06,
    this.emptyHeightFactor = 0.02,
    this.filledColor,
    this.emptyColor,
    this.backgroundColor,
    this.borderColor,
    this.semanticLabel,
  }) : assert(height > 0),
       assert(spacing >= 0),
       assert(minFilledHeightFactor >= 0 && minFilledHeightFactor <= 1),
       assert(emptyHeightFactor >= 0 && emptyHeightFactor <= 1);

  final List<num> values;
  final num? maxValue;
  final double height;
  final double spacing;
  final double minFilledHeightFactor;
  final double emptyHeightFactor;
  final Color? filledColor;
  final Color? emptyColor;
  final Color? backgroundColor;
  final Color? borderColor;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final effectiveMax = maxValue ?? values.fold<num>(0, _maxNum);

    final chart = CatchSurface(
      padding: CatchInsets.contentDense,
      borderColor: borderColor ?? t.line,
      backgroundColor: backgroundColor ?? t.surface,
      child: SizedBox(
        height: height,
        child: values.isEmpty
            ? const SizedBox.expand()
            : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final (index, value) in values.indexed) ...[
                    if (index > 0) SizedBox(width: spacing),
                    Expanded(
                      child: _CatchMiniBar(
                        value: value,
                        maxValue: effectiveMax,
                        minFilledHeightFactor: minFilledHeightFactor,
                        emptyHeightFactor: emptyHeightFactor,
                        filledColor: filledColor ?? t.ink,
                        emptyColor: emptyColor ?? t.line2,
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );

    final label = semanticLabel?.trim();
    if (label == null || label.isEmpty) return chart;
    return Semantics(label: label, child: chart);
  }
}

class _CatchMiniBar extends StatelessWidget {
  const _CatchMiniBar({
    required this.value,
    required this.maxValue,
    required this.minFilledHeightFactor,
    required this.emptyHeightFactor,
    required this.filledColor,
    required this.emptyColor,
  });

  final num value;
  final num maxValue;
  final double minFilledHeightFactor;
  final double emptyHeightFactor;
  final Color filledColor;
  final Color emptyColor;

  @override
  Widget build(BuildContext context) {
    final ratio = maxValue <= 0
        ? emptyHeightFactor
        : (value / maxValue).clamp(minFilledHeightFactor, 1).toDouble();

    return Align(
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: ratio,
        child: CatchSurface(
          radius: CatchRadius.xs,
          borderWidth: 0,
          backgroundColor: value <= 0 ? emptyColor : filledColor,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

num _maxNum(num max, num value) => value > max ? value : max;
