import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class CreateClubStepHeader extends StatelessWidget {
  const CreateClubStepHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.currentStep,
    required this.totalSteps,
    this.onClose,
    this.onStepOverview,
    this.isReviewing = false,
  });

  final String title;
  final String? subtitle;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onClose;
  final VoidCallback? onStepOverview;
  final bool isReviewing;

  @override
  Widget build(BuildContext context) {
    return CatchStepHeader(
      title: title,
      subtitle: subtitle,
      step: isReviewing ? null : currentStep + 1,
      total: isReviewing ? null : totalSteps,
      onBack: onClose,
      leadingType: CatchTopBarLeading.close,
      onStepOverview: isReviewing ? null : onStepOverview,
      stepOverviewSemanticsLabel: isReviewing
          ? null
          : context.l10n.hostsWizardStepOverviewSemantics(
              step: currentStep + 1,
              total: totalSteps,
            ),
    );
  }
}
