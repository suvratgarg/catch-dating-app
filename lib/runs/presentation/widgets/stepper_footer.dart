import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:flutter/material.dart';

class StepperFooter extends StatelessWidget {
  const StepperFooter({
    super.key,
    required this.isLastStep,
    required this.isLoading,
    required this.onNext,
    this.onSaveDraft,
    this.nextLabel = 'Next',
    this.lastStepLabel = 'Schedule run',
  });

  final bool isLastStep;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback? onSaveDraft;
  final String nextLabel;
  final String lastStepLabel;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return ColoredBox(
      color: t.bg,
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          CatchSpacing.s4,
          CatchSpacing.s3,
          CatchSpacing.s4,
          CatchSpacing.s3 + bottomPadding,
        ),
        child: Row(
          children: [
            if (onSaveDraft != null) ...[
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CatchButton(
                    label: 'Save Draft',
                    onPressed: isLoading ? null : onSaveDraft,
                    variant: CatchButtonVariant.ghost,
                    size: CatchButtonSize.lg,
                    icon: const Icon(Icons.save_outlined),
                    foregroundColor: t.primary,
                  ),
                ),
              ),
              const SizedBox(width: CatchSpacing.s3),
            ],
            Expanded(
              child: Align(
                alignment: Alignment.centerRight,
                child: CatchButton(
                  label: isLastStep ? lastStepLabel : nextLabel,
                  onPressed: onNext,
                  isLoading: isLoading,
                  fullWidth: true,
                  icon: isLastStep
                      ? null
                      : const Icon(Icons.arrow_forward_rounded),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
