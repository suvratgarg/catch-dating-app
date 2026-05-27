import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
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
      icon: CatchIcons.locationOnRounded,
      details: [
        CelebrationDetail(
          icon: CatchIcons.directionsRunRounded,
          label: 'Event',
          value: event.title,
        ),
        CelebrationDetail(
          icon: CatchIcons.scheduleRounded,
          label: 'Starts',
          value: event.timeRangeLabel,
        ),
        CelebrationDetail(
          icon: CatchIcons.locationOnOutlined,
          label: 'Meet point',
          value: event.locationName,
        ),
      ],
      primaryAction: CelebrationAction(
        label: 'View event',
        onPressed: onViewEvent,
        icon: Icon(CatchIcons.directionsRunRounded),
      ),
      secondaryAction: CelebrationAction(
        label: 'Back to home',
        onPressed: onBackHome,
      ),
      onClose: onBackHome,
    );
  }
}
