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
  });

  final bool isLastStep;
  final bool isLoading;
  final VoidCallback onNext;
  final VoidCallback? onSaveDraft;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final bottomPadding = MediaQuery.paddingOf(context).bottom;

    return Container(
      color: t.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Divider(color: t.line, height: 1, thickness: 1),
          Padding(
            padding: EdgeInsets.fromLTRB(
              CatchSpacing.s4,
              12,
              CatchSpacing.s4,
              12 + bottomPadding,
            ),
            child: Row(
              children: [
                if (onSaveDraft != null)
                  TextButton.icon(
                    onPressed: isLoading ? null : onSaveDraft,
                    icon: const Icon(Icons.save_outlined, size: 18),
                    label: const Text('Save Draft'),
                  ),
                const Spacer(),
                Expanded(
                  child: CatchButton(
                    label: isLastStep ? 'Schedule run' : 'Next',
                    onPressed: onNext,
                    isLoading: isLoading,
                    icon: isLastStep
                        ? null
                        : const Icon(Icons.arrow_forward_rounded),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
