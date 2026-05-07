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
    this.labels,
    this.semanticFormatterCallback,
  });

  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final RangeLabels? labels;
  final SemanticFormatterCallback? semanticFormatterCallback;

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
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
        labels: labels,
        semanticFormatterCallback: semanticFormatterCallback,
        onChanged: onChanged,
      ),
    );
  }
}
