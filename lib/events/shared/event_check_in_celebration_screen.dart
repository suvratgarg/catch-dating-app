import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
      eyebrow: context.l10n.eventsEventCheckInCelebrationScreenEyebrowCheckedIn,
      title: context.l10n.eventsEventCheckInCelebrationScreenTitleCheckedIn,
      message:
          context.l10n.eventsEventCheckInCelebrationScreenMessageYouReOnThe,
      icon: CatchIcons.locationOnRounded,
      details: [
        CelebrationDetail(
          icon: CatchIcons.directionsRunRounded,
          label: context.l10n.eventsEventCheckInCelebrationScreenLabelEvent,
          value: event.title,
        ),
        CelebrationDetail(
          icon: CatchIcons.scheduleRounded,
          label: context.l10n.eventsEventCheckInCelebrationScreenLabelStarts,
          value: event.timeRangeLabel,
        ),
        CelebrationDetail(
          icon: CatchIcons.locationOnOutlined,
          label: context.l10n.eventsEventCheckInCelebrationScreenLabelMeetPoint,
          value: event.locationName,
        ),
      ],
      primaryAction: CelebrationAction(
        label: context.l10n.eventsEventCheckInCelebrationScreenLabelViewEvent,
        onPressed: onViewEvent,
        icon: Icon(CatchIcons.directionsRunRounded),
      ),
      secondaryAction: CelebrationAction(
        label: context.l10n.eventsEventCheckInCelebrationScreenLabelBackToHome,
        onPressed: onBackHome,
      ),
      onClose: onBackHome,
    );
  }
}
