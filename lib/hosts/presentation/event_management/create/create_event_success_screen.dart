import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:flutter/material.dart';

class CreateEventSuccessScreen extends StatelessWidget {
  const CreateEventSuccessScreen({
    super.key,
    required this.club,
    required this.event,
    this.inviteCode,
    this.eventDisplayName,
    required this.onManageEvent,
    required this.onDone,
  });

  final Club club;
  final Event event;
  final String? inviteCode;
  final String? eventDisplayName;
  final VoidCallback onManageEvent;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final normalizedInviteCode = inviteCode?.trim();
    final inviteLink =
        normalizedInviteCode == null || normalizedInviteCode.isEmpty
        ? null
        : AppDeepLinks.event(
            clubId: club.id,
            eventId: event.id,
            inviteCode: normalizedInviteCode,
          ).toString();
    final displayName = _eventCreatedDisplayName(event, eventDisplayName);
    final message = inviteLink == null
        ? '$displayName is now listed on ${club.name}. People can discover it from their home feed.'
        : '$displayName is now listed on ${club.name}. People can discover it, but only attendees with the invite code or private link can book.';

    return CatchCelebrationScreen(
      kind: CelebrationMomentKind.eventCreated,
      icon: CatchIcons.celebration,
      eyebrow: 'Event created',
      title: 'Your event is live.',
      message: message,
      details: [
        CelebrationDetail(
          icon: CatchIcons.calendarMonthOutlined,
          label: 'When',
          value: _eventCreatedWhenLabel(event),
        ),
        CelebrationDetail(
          icon: CatchIcons.locationOnOutlined,
          label: 'Where',
          value: event.locationName,
        ),
        CelebrationDetail(
          icon: CatchIcons.directionsRunRounded,
          label: 'Event',
          value: _eventCreatedActivityLabel(event),
        ),
        CelebrationDetail(
          icon: CatchIcons.groupOutlined,
          label: 'Capacity',
          value: '${event.capacityLimit} attendees',
        ),
        if (normalizedInviteCode != null && normalizedInviteCode.isNotEmpty)
          CelebrationDetail(
            icon: CatchIcons.keyOutlined,
            label: 'Invite code',
            value: normalizedInviteCode,
          ),
        if (inviteLink != null)
          CelebrationDetail(
            icon: CatchIcons.linkOutlined,
            label: 'Private link',
            value: inviteLink,
          ),
      ],
      note: 'Bookings, waitlist, and attendance are tracked from Manage event.',
      primaryAction: CelebrationAction(
        label: 'Manage event',
        onPressed: onManageEvent,
      ),
      secondaryAction: CelebrationAction(
        label: 'Back to club',
        onPressed: onDone,
      ),
      onClose: onDone,
      showCloseButton: false,
      appearance: CatchCelebrationAppearance.paper,
    );
  }
}

String _eventCreatedDisplayName(Event event, String? override) {
  final trimmed = override?.trim();
  if (trimmed != null && trimmed.isNotEmpty) return trimmed;
  return event.title;
}

String _eventCreatedWhenLabel(Event event) {
  final day = EventFormatters.shortWeekday(event.startTime);
  final month = EventFormatters.shortMonth(event.startTime);
  final time = EventFormatters.timeRange(event.startTime, event.endTime);
  return '$day, ${event.startTime.day} $month · $time';
}

String _eventCreatedActivityLabel(Event event) {
  if (!event.eventFormat.isDistanceBased) return event.activitySummaryLabel;
  final distance = EventFormatters.distanceKm(
    event.distanceKm,
  ).replaceFirst('km', ' km');
  return '$distance ${event.pace.label.toLowerCase()} ${event.eventFormat.label.toLowerCase()}';
}
