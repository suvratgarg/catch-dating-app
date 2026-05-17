import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:flutter/material.dart';

class EventCheckInCelebrationScreen extends StatelessWidget {
  const EventCheckInCelebrationScreen({
    super.key,
    required this.event,
    required this.onViewEvent,
    required this.onBackHome,
  });

  final Event event;
  final VoidCallback onViewEvent;
  final VoidCallback onBackHome;

  @override
  Widget build(BuildContext context) {
    return CatchCelebrationScreen(
      kind: CelebrationMomentKind.eventCheckedIn,
      eyebrow: 'Checked in',
      title: 'Checked in.',
      message: "You're on the roster. Have a great event.",
      icon: Icons.location_on_rounded,
      details: [
        CelebrationDetail(
          icon: Icons.directions_run_rounded,
          label: 'Event',
          value: event.title,
        ),
        CelebrationDetail(
          icon: Icons.schedule_rounded,
          label: 'Starts',
          value: event.timeRangeLabel,
        ),
        CelebrationDetail(
          icon: Icons.location_on_outlined,
          label: 'Meet point',
          value: event.meetingPoint,
        ),
      ],
      primaryAction: CelebrationAction(
        label: 'View event',
        onPressed: onViewEvent,
        icon: const Icon(Icons.directions_run_rounded),
      ),
      secondaryAction: CelebrationAction(
        label: 'Back to home',
        onPressed: onBackHome,
      ),
      onClose: onBackHome,
    );
  }
}
