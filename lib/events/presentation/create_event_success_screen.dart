import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/celebration/catch_celebration_screen.dart';
import 'package:catch_dating_app/core/celebration/celebration_effects_controller.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:flutter/material.dart';

class CreateEventSuccessScreen extends StatelessWidget {
  const CreateEventSuccessScreen({
    super.key,
    required this.club,
    required this.event,
    this.inviteCode,
    required this.onManageEvent,
    required this.onDone,
  });

  final Club club;
  final Event event;
  final String? inviteCode;
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
    final message = inviteLink == null
        ? '${event.title} is now listed on ${club.name}. Followers can discover it from their home feed.'
        : '${event.title} is now listed on ${club.name}. People can discover it, but only attendees with the invite code or private link can book.';

    return CatchCelebrationScreen(
      kind: CelebrationMomentKind.eventCreated,
      eyebrow: 'Event created',
      title: 'Your event is live.',
      message: message,
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
          value: event.activitySummaryLabel,
        ),
        CelebrationDetail(
          icon: Icons.group_outlined,
          label: 'Capacity',
          value: '${event.capacityLimit} attendees',
        ),
        if (normalizedInviteCode != null && normalizedInviteCode.isNotEmpty)
          CelebrationDetail(
            icon: Icons.key_outlined,
            label: 'Invite code',
            value: normalizedInviteCode,
          ),
        if (inviteLink != null)
          CelebrationDetail(
            icon: Icons.link_outlined,
            label: 'Private link',
            value: inviteLink,
          ),
      ],
      note: 'Bookings, waitlist, and attendance are tracked from Manage event.',
      primaryAction: CelebrationAction(
        label: 'Manage event',
        onPressed: onManageEvent,
        icon: const Icon(Icons.tune_rounded),
      ),
      secondaryAction: CelebrationAction(
        label: 'Back to club',
        onPressed: onDone,
      ),
      onClose: onDone,
    );
  }
}
