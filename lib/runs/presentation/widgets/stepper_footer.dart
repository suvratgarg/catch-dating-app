import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:flutter/material.dart';

class StepperFooter extends StatelessWidget {
  const StepperFooter({
    super.key,
    required this.isLastStep,
    required this.isLoading,
    required this.onNext,
  });

  final bool isLastStep;
  final bool isLoading;
  final VoidCallback onNext;

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
            child: CatchButton(
              label: isLastStep ? 'Schedule run' : 'Next',
              onPressed: onNext,
              isLoading: isLoading,
              fullWidth: true,
              icon: isLastStep ? null : const Icon(Icons.arrow_forward_rounded),
            ),
          ),
        ],
      ),
    );
  }
}
