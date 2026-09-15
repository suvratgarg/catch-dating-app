import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class EventAssistanceHelpEntry extends StatelessWidget {
  const EventAssistanceHelpEntry({
    super.key,
    required this.onReview,
    this.confirmationNeeded = false,
  });
  final VoidCallback onReview;
  final bool confirmationNeeded;
  @override
  Widget build(BuildContext context) => CatchSection.divided(
    title: context.l10n.eventAssistanceHelpTitle,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          confirmationNeeded
              ? context.l10n.eventAssistanceHelpPendingBody
              : context.l10n.eventAssistanceHelpBody,
          style: CatchTextStyles.supporting(context),
        ),
        gapH12,
        CatchButton(
          label: confirmationNeeded
              ? context.l10n.eventAssistanceHelpPending
              : context.l10n.eventAssistanceHelpReview,
          variant: CatchButtonVariant.secondary,
          onPressed: onReview,
        ),
      ],
    ),
  );
}
