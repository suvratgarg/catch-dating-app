import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_step_progress.dart';
import 'package:catch_dating_app/core/widgets/icon_btn.dart';
import 'package:flutter/material.dart';

class CreateRunStepHeader extends StatelessWidget {
  const CreateRunStepHeader({
    super.key,
    required this.title,
    required this.runClubName,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  final String title;
  final String runClubName;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        12,
        CatchSpacing.s5,
        0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconBtn(
                onTap: onBack,
                child: Tooltip(
                  message: 'Back',
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: t.ink,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: CatchTextStyles.titleL(context)),
                    Text(
                      runClubName,
                      style: CatchTextStyles.bodyS(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          CatchStepProgress(currentStep: currentStep, totalSteps: totalSteps),
        ],
      ),
    );
  }
}
