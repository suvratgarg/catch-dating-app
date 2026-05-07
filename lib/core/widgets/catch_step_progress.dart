import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class CatchStepProgress extends StatelessWidget {
  const CatchStepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.label,
  }) : assert(totalSteps > 0),
       assert(currentStep >= 0);

  final int currentStep;
  final int totalSteps;
  final String? label;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final clampedStep = currentStep.clamp(0, totalSteps - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (label != null)
              Expanded(
                child: Text(
                  label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.labelL(context, color: t.ink2),
                ),
              )
            else
              const Spacer(),
            Text(
              '${clampedStep + 1}/$totalSteps',
              style: CatchTextStyles.labelL(context, color: t.ink2),
            ),
          ],
        ),
        const SizedBox(height: CatchSpacing.s2),
        Row(
          children: List.generate(
            totalSteps,
            (index) => Expanded(
              child: AnimatedContainer(
                duration: CatchMotion.fast,
                curve: CatchMotion.standardCurve,
                margin: EdgeInsets.only(
                  right: index < totalSteps - 1 ? CatchSpacing.s1 : 0,
                ),
                height: 4,
                decoration: BoxDecoration(
                  color: index <= clampedStep ? t.primary : t.line,
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
