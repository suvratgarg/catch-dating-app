import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:flutter/material.dart';

class StepProgressBar extends StatelessWidget {
  const StepProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: List.generate(
        totalSteps,
        (i) => Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 280),
            margin: EdgeInsets.only(right: i < totalSteps - 1 ? 4 : 0),
            height: 4,
            decoration: BoxDecoration(
              color: i <= currentStep ? t.primary : t.line,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }
}
