part of '../event_success_companion_screen.dart';

class _CompanionHero extends StatelessWidget {
  const _CompanionHero({
    required this.event,
    required this.plan,
    required this.attended,
    required this.showSelfCheckIn,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool attended;
  final bool showSelfCheckIn;

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
            label: attended
                ? 'Checked in'
                : showSelfCheckIn
                ? 'Check in open'
                : 'Booked',
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
            '${plan.playbook.title} · ${event.meetingPoint}',
            style: CatchTextStyles.bodyS(
              context,
              color: t.surface.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _NoCompanionActionsCard extends StatelessWidget {
  const _NoCompanionActionsCard();

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      borderColor: CatchTokens.of(context).line,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      child: Text(
        'No companion actions are active for this event.',
        style: CatchTextStyles.bodyS(context),
      ),
    );
  }
}
