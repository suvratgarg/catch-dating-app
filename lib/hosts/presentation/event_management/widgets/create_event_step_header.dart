import 'package:catch_dating_app/core/widgets/catch_step_flow_header.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class CreateEventStepHeader extends StatelessWidget {
  const CreateEventStepHeader({
    super.key,
    required this.title,
    required this.clubName,
    required this.currentStep,
    required this.totalSteps,
    required this.onClose,
    this.onStepOverview,
    this.isReviewing = false,
  });

  final String title;
  final String clubName;
  final int currentStep;
  final int totalSteps;
  final VoidCallback? onClose;
  final VoidCallback? onStepOverview;
  final bool isReviewing;

  @override
  Widget build(BuildContext context) {
    return CatchStepHeader(
      title: title,
      subtitle: clubName,
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
