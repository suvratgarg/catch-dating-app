import 'package:catch_dating_app/core/schema_contracts/catch_contract_field_policy.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

export 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart'
    show CatchContractConstraints, CatchContractFieldConstraints;

/// Canonical Catch range slider.
///
/// Keep range slider styling here so feature screens do not need to remember
/// theme patches like hiding tick marks.
class CatchRangeSlider extends StatelessWidget {
  const CatchRangeSlider({
    super.key,
    required this.values,
    required this.onChanged,
    this.minimumContract,
    this.maximumContract,
    this.contractExemption,
    this.onChangeEnd,
    this.min,
    this.max,
    this.divisions,
    this.minLabel,
    this.maxLabel,
    this.semanticFormatterCallback,
  });

  final RangeValues values;
  final ValueChanged<RangeValues>? onChanged;
  final ValueChanged<RangeValues>? onChangeEnd;
  final CatchContractFieldConstraints? minimumContract;
  final CatchContractFieldConstraints? maximumContract;
  final String? contractExemption;
  final double? min;
  final double? max;
  final int? divisions;
  final String? minLabel;
  final String? maxLabel;
  final SemanticFormatterCallback? semanticFormatterCallback;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final effectiveMin =
        CatchContractFieldPolicy.effectiveMinimum(
          minimumContract,
          min,
        )?.toDouble() ??
        0;
    final effectiveMax =
        CatchContractFieldPolicy.effectiveMaximum(
          maximumContract,
          max,
        )?.toDouble() ??
        100;
    final contractStep =
        minimumContract?.multipleOf ?? maximumContract?.multipleOf;
    final effectiveDivisions =
        divisions ??
        (contractStep == null
            ? null
            : ((effectiveMax - effectiveMin) / contractStep).round());
    assert(
      values.start >= effectiveMin && values.end <= effectiveMax,
      'CatchRangeSlider values must stay inside contract-derived bounds.',
    );
    final slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        // Design-system RangeSlider: 4px line2 track, ink active fill, a 24px
        // surface knob lifted off the track (no M3 seed tones).
        trackHeight: CatchSpacing.s1,
        activeTrackColor: t.primary,
        inactiveTrackColor: t.line2,
        thumbColor: t.surface,
        rangeThumbShape: const RoundRangeSliderThumbShape(
          enabledThumbRadius: CatchSpacing.s3,
          elevation: CatchElevation.physicalControl,
        ),
        overlayColor: t.primary.withValues(
          alpha: CatchOpacity.controlOverlayPressed,
        ),
        activeTickMarkColor: Colors.transparent,
        inactiveTickMarkColor: Colors.transparent,
        disabledActiveTickMarkColor: Colors.transparent,
        disabledInactiveTickMarkColor: Colors.transparent,
      ),
      child: RangeSlider(
        min: effectiveMin,
        max: effectiveMax,
        divisions: effectiveDivisions,
        values: values,
        semanticFormatterCallback: semanticFormatterCallback,
        onChanged: onChanged,
        onChangeEnd: onChangeEnd,
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
