import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

/// Canonical Catch range slider.
///
/// Keep range slider styling here so feature screens do not need to remember
/// theme patches like hiding tick marks.
class CatchRangeSlider extends StatelessWidget {
  const CatchRangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.divisions,
    this.minLabel,
    this.maxLabel,
    this.semanticFormatterCallback,
  });

  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? minLabel;
  final String? maxLabel;
  final SemanticFormatterCallback? semanticFormatterCallback;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
        disabledActiveTickMarkColor: Colors.transparent,
        disabledInactiveTickMarkColor: Colors.transparent,
      ),
      child: RangeSlider(
        min: min,
        max: max,
        divisions: divisions,
        values: values,
        semanticFormatterCallback: semanticFormatterCallback,
        onChanged: onChanged,
      ),
    );

    if (minLabel == null && maxLabel == null) return slider;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        slider,
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s2),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                minLabel ?? '',
                style: CatchTextStyles.supporting(context, color: t.ink3),
              ),
              Text(
                maxLabel ?? '',
                style: CatchTextStyles.supporting(context, color: t.ink3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
