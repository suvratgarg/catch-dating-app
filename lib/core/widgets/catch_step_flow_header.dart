import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_step_progress.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:flutter/material.dart';

class CatchStepFlowHeader extends StatelessWidget {
  const CatchStepFlowHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
  });

  final String title;
  final String? subtitle;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final clampedStep = currentStep.clamp(0, totalSteps - 1);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        12,
        CatchSpacing.s5,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: onBack == null
                    ? const SizedBox.shrink()
                    : IconBtn(
                        onTap: onBack,
                        child: Tooltip(
                          message: 'Back',
                          child: Icon(
                            CatchIcons.arrowBackIosNewRounded,
                            size: 18,
                            color: t.ink,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.sectionTitle(
                        context,
                        color: t.ink,
                      ),
                    ),
                    if (subtitle != null && subtitle!.isNotEmpty)
                      Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink2,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: CatchSpacing.s3),
              Text(
                '${clampedStep + 1}/$totalSteps',
                style: CatchTextStyles.labelL(context, color: t.ink2),
              ),
            ],
          ),
          const SizedBox(height: CatchSpacing.s3),
          CatchStepProgress(
            currentStep: currentStep,
            totalSteps: totalSteps,
            showCounter: false,
          ),
        ],
      ),
    );
  }
}
