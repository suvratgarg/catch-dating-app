part of '../event_success_companion_screen.dart';

class _PrivateAfterglowRecapCard extends StatelessWidget {
  const _PrivateAfterglowRecapCard({
    required this.event,
    required this.openersEnabled,
    required this.feedbackEnabled,
    this.feedback,
  });

  final Event event;
  final bool openersEnabled;
  final bool feedbackEnabled;
  final EventSuccessFeedback? feedback;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final feedback = this.feedback;
    return _StagePanel(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StageSectionLabel(
                icon: Icons.auto_awesome_rounded,
                label: 'Private afterglow',
                color: t.primary,
              ),
              const _PrivacyBadge(_PrivacyAudience.privateToYou),
            ],
          ),
          gapH10,
          Text(
            'Your night at ${event.title}',
            style: CatchTextStyles.titleL(context),
          ),
          gapH4,
          Text(
            'A small recap for you, not a public share card.',
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          gapH14,
          _AfterglowBeatGrid(
            beats: [
              _AfterglowBeat(
                icon: Icons.event_available_outlined,
                label: 'You showed up',
                value: '${event.longDateLabel} | ${event.activitySummaryLabel}',
              ),
              _AfterglowBeat(
                icon: Icons.forum_outlined,
                label: openersEnabled ? 'Openers ready' : 'Memory saved',
                value: openersEnabled
                    ? 'Use the shared event context when a match opens.'
                    : 'Keep the useful parts of the room for yourself.',
              ),
              _AfterglowBeat(
                icon: Icons.favorite_border_rounded,
                label: feedback == null ? 'Your read' : 'Your read saved',
                value: feedback == null
                    ? feedbackEnabled
                          ? 'Leave a quick note while the event is fresh.'
                          : 'Catch keeps this recap private to you.'
                    : '${feedback.metNewPeopleCount} people remembered, welcome ${feedback.welcomeRating}/5.',
              ),
            ],
          ),
          gapH14,
          _StageSoftBand(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.lock_outline_rounded, size: 18, color: t.primary),
                gapW8,
                Expanded(
                  child: Text(
                    'Only you see this recap. Hosts get aggregate coaching, never your private notes or individual opener choices.',
                    style: CatchTextStyles.bodyS(context, color: t.ink),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AfterglowBeat {
  const _AfterglowBeat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;
}

class _AfterglowBeatGrid extends StatelessWidget {
  const _AfterglowBeatGrid({required this.beats});

  final List<_AfterglowBeat> beats;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < beats.length; index++) ...[
          if (index > 0) gapH8,
          _AfterglowBeatRow(beat: beats[index]),
        ],
      ],
    );
  }
}

class _AfterglowBeatRow extends StatelessWidget {
  const _AfterglowBeatRow({required this.beat});

  final _AfterglowBeat beat;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        border: Border.all(color: t.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(beat.icon, size: 20, color: t.primary),
            gapW10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(beat.label, style: CatchTextStyles.titleS(context)),
                  gapH2,
                  Text(
                    beat.value,
                    style: CatchTextStyles.bodyS(context, color: t.ink2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
