import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';

class RunJoinedCelebrationScreen extends StatelessWidget {
  const RunJoinedCelebrationScreen({
    super.key,
    required this.run,
    required this.onViewRun,
    required this.onBackHome,
    this.clubName,
    this.paymentData,
    this.supplementalChildren = const [],
    this.viewRunKey,
    this.backHomeKey,
  });

  final Run run;
  final String? clubName;
  final PaymentConfirmationData? paymentData;
  final VoidCallback onViewRun;
  final VoidCallback onBackHome;
  final List<Widget> supplementalChildren;
  final Key? viewRunKey;
  final Key? backHomeKey;

  @override
  Widget build(BuildContext context) {
    final paymentData = this.paymentData;

    return CatchCelebrationScreen(
      kind: CelebrationMomentKind.runJoined,
      eyebrow: 'Booking confirmed',
      title: "You're in.",
      message:
          'Your spot is confirmed for ${run.title}${clubName == null ? '' : ' with $clubName'}.',
      details: [
        CelebrationDetail(
          icon: Icons.calendar_month_outlined,
          label: 'When',
          value: '${run.longDateLabel} · ${run.timeRangeLabel}',
        ),
        CelebrationDetail(
          icon: Icons.location_on_outlined,
          label: 'Where',
          value: run.meetingPoint,
        ),
        CelebrationDetail(
          icon: Icons.directions_run_rounded,
          label: 'Run',
          value:
              '${RunFormatters.distanceKm(run.distanceKm)} · ${run.pace.label}',
        ),
        if (paymentData != null) ...[
          CelebrationDetail(
            icon: Icons.payments_outlined,
            label: 'Paid',
            value: RunFormatters.priceInPaise(paymentData.amountInPaise),
          ),
          CelebrationDetail(
            icon: Icons.receipt_long_outlined,
            label: 'Payment ID',
            value: paymentData.paymentId,
          ),
        ],
      ],
      note:
          'Arrive by the meeting time. Catches unlock automatically when the run finishes.',
      supplementalChildren: supplementalChildren,
      primaryAction: CelebrationAction(
        key: viewRunKey,
        label: 'View run',
        onPressed: onViewRun,
        icon: const Icon(Icons.directions_run_rounded),
      ),
      secondaryAction: CelebrationAction(
        key: backHomeKey,
        label: 'Back to home',
        onPressed: onBackHome,
      ),
      onClose: onBackHome,
    );
  }
}
