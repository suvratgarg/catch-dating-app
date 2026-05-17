import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:flutter/material.dart';

class EventJoinedCelebrationScreen extends StatelessWidget {
  const EventJoinedCelebrationScreen({
    super.key,
    required this.event,
    required this.onViewEvent,
    required this.onBackHome,
    this.clubName,
    this.paymentData,
    this.supplementalChildren = const [],
    this.viewEventKey,
    this.backHomeKey,
  });

  final Event event;
  final String? clubName;
  final PaymentConfirmationData? paymentData;
  final VoidCallback onViewEvent;
  final VoidCallback onBackHome;
  final List<Widget> supplementalChildren;
  final Key? viewEventKey;
  final Key? backHomeKey;

  @override
  Widget build(BuildContext context) {
    final paymentData = this.paymentData;

    return CatchCelebrationScreen(
      kind: CelebrationMomentKind.eventJoined,
      eyebrow: 'Booking confirmed',
      title: "You're in.",
      message:
          'Your spot is confirmed for ${event.title}${clubName == null ? '' : ' with $clubName'}.',
      details: [
        CelebrationDetail(
          icon: Icons.calendar_month_outlined,
          label: 'When',
          value: '${event.longDateLabel} · ${event.timeRangeLabel}',
        ),
        CelebrationDetail(
          icon: Icons.location_on_outlined,
          label: 'Where',
          value: event.meetingPoint,
        ),
        CelebrationDetail(
          icon: Icons.directions_run_rounded,
          label: 'Event',
          value:
              '${EventFormatters.distanceKm(event.distanceKm)} · ${event.pace.label}',
        ),
        if (paymentData != null) ...[
          CelebrationDetail(
            icon: Icons.payments_outlined,
            label: 'Paid',
            value: EventFormatters.priceInPaise(paymentData.amountInPaise),
          ),
          CelebrationDetail(
            icon: Icons.receipt_long_outlined,
            label: 'Payment ID',
            value: paymentData.paymentId,
          ),
        ],
      ],
      note:
          'Arrive by the meeting time. Catches unlock automatically when the event finishes.',
      supplementalChildren: supplementalChildren,
      primaryAction: CelebrationAction(
        key: viewEventKey,
        label: 'View event',
        onPressed: onViewEvent,
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
