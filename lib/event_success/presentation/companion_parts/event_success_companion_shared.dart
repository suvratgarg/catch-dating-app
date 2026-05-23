part of '../event_success_companion_screen.dart';

class _CompanionHero extends StatelessWidget {
  const _CompanionHero({
    required this.event,
    required this.plan,
    required this.attended,
    required this.showSelfCheckIn,
    required this.eventEnded,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool attended;
  final bool showSelfCheckIn;
  final bool eventEnded;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      backgroundColor: t.ink,
      borderWidth: 0,
      padding: const EdgeInsets.all(CatchSpacing.s5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchBadge(
            label: _heroBadgeLabel(
              attended: attended,
              showSelfCheckIn: showSelfCheckIn,
              eventEnded: eventEnded,
            ),
            tone: attended ? CatchBadgeTone.success : CatchBadgeTone.live,
            icon: attended ? Icons.check_rounded : Icons.qr_code_2_rounded,
          ),
          gapH12,
          Text(
            event.title,
            style: CatchTextStyles.displayM(context, color: t.surface),
          ),
          gapH6,
          Text(
            '${plan.playbook.title} · ${event.locationName}',
            style: CatchTextStyles.bodyS(
              context,
              color: t.surface.withValues(alpha: 0.72),
            ),
          ),
          gapH12,
          Text(
            _heroOrientationLine(
              event: event,
              attended: attended,
              showSelfCheckIn: showSelfCheckIn,
              eventEnded: eventEnded,
            ),
            style: CatchTextStyles.bodyM(context, color: t.surface),
          ),
        ],
      ),
    );
  }
}

String _heroBadgeLabel({
  required bool attended,
  required bool showSelfCheckIn,
  required bool eventEnded,
}) {
  if (attended && eventEnded) return 'Event done';
  if (attended) return 'Checked in';
  if (showSelfCheckIn) return 'Check in open';
  return 'Booked';
}

String _heroOrientationLine({
  required Event event,
  required bool attended,
  required bool showSelfCheckIn,
  required bool eventEnded,
}) {
  if (attended && eventEnded) {
    return 'Thanks for coming. A quick feedback prompt is below.';
  }
  if (attended) {
    return 'You\'re in. Watch this screen for prompts and partner reveals.';
  }
  if (showSelfCheckIn) {
    return 'Glad you\'re coming. Check in when you arrive at ${event.locationName}.';
  }
  return 'Glad you\'re coming. We\'ll guide you here once check-in opens.';
}

/// Who else can see this card's data. Surfaces a consistent badge across
/// questionnaire, wingman, and feedback so the attendee can tell at a glance
/// what they're putting on the record.
enum _PrivacyAudience { privateToYou, hostCanSee, catchPrivate }

class _PrivacyBadge extends StatelessWidget {
  const _PrivacyBadge(this.audience);

  final _PrivacyAudience audience;

  @override
  Widget build(BuildContext context) {
    return switch (audience) {
      _PrivacyAudience.privateToYou => const CatchBadge(
        label: 'Private to you',
        tone: CatchBadgeTone.neutral,
        icon: Icons.lock_outline_rounded,
      ),
      _PrivacyAudience.hostCanSee => const CatchBadge(
        label: 'Host can see',
        tone: CatchBadgeTone.neutral,
        icon: Icons.visibility_outlined,
      ),
      _PrivacyAudience.catchPrivate => const CatchBadge(
        label: 'Catch private',
        tone: CatchBadgeTone.neutral,
        icon: Icons.shield_outlined,
      ),
    };
  }
}

class _NoCompanionActionsCard extends StatelessWidget {
  const _NoCompanionActionsCard();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.event_outlined, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The host is running the room',
                  style: CatchTextStyles.titleS(context),
                ),
                gapH4,
                Text(
                  'Your next prompt or partner reveal will show up here.',
                  style: CatchTextStyles.bodyS(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
