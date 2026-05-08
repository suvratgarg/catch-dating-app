import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
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
    return CatchStepFlowHeader(
      title: title,
      subtitle: runClubName,
      currentStep: currentStep,
      totalSteps: totalSteps,
      onBack: onBack,
    );
  }
}
