import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:catch_dating_app/l10n/l10n.dart';

class CatchStepProgress extends StatelessWidget {
  const CatchStepProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.label,
    this.showCounter = true,
  }) : assert(totalSteps > 0),
       assert(currentStep >= 0);

  final int currentStep;
  final int totalSteps;
  final String? label;
  final bool showCounter;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final clampedStep = currentStep.clamp(0, totalSteps - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (label != null || showCounter) ...[
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
              if (showCounter)
                Text(
                  context.l10n.coreCatchStepProgressTextValue1Totalsteps(
                    value1: clampedStep + 1,
                    totalSteps: totalSteps,
                  ),
                  style: CatchTextStyles.labelL(context, color: t.ink2),
                ),
            ],
          ),
          const SizedBox(height: CatchSpacing.s2),
        ],
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
                height: CatchSpacing.s1,
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
