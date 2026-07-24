import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:flutter/material.dart';

class CreateClubStepHeader extends StatelessWidget {
  const CreateClubStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currentStep,
    required this.totalSteps,
    this.onBack,
    this.showBack = true,
  });

  final String title;
  final String? subtitle;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onBack;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return CatchStepHeader(
      title: title,
      subtitle: subtitle,
      step: currentStep + 1,
      total: totalSteps,
      onBack: onBack,
      showBack: showBack,
    );
  }
}
