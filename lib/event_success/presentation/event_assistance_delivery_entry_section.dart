import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class EventAssistanceDeliveryEntrySection extends StatelessWidget {
  const EventAssistanceDeliveryEntrySection({
    super.key,
    required this.onReview,
    this.confirmationNeeded = false,
  });
  final VoidCallback onReview;
  final bool confirmationNeeded;
  @override
  Widget build(BuildContext context) => CatchSection.divided(
    title: context.l10n.eventAssistanceDeliveryTitle,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          confirmationNeeded
              ? context.l10n.eventAssistanceDeliveryPendingBody
              : context.l10n.eventAssistanceDeliveryBody,
          style: CatchTextStyles.supporting(context),
        ),
        gapH12,
        CatchButton(
          label: confirmationNeeded
              ? context.l10n.eventAssistanceDeliveryPending
              : context.l10n.eventAssistanceDeliveryReview,
          variant: CatchButtonVariant.secondary,
          onPressed: onReview,
        ),
      ],
    ),
  );
}
