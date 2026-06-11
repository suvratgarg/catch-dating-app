import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:flutter/material.dart';

class CreateEventStepHeader extends StatelessWidget {
  const CreateEventStepHeader({
    super.key,
    required this.title,
    required this.clubName,
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  final String title;
  final String clubName;
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return CatchStepFlowHeader(
      title: title,
      subtitle: clubName,
      currentStep: currentStep,
      totalSteps: totalSteps,
      onBack: onBack,
    );
  }
}
