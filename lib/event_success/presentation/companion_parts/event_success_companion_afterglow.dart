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
                icon: CatchIcons.autoAwesomeRounded,
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
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH14,
          _AfterglowBeatGrid(
            beats: [
              _AfterglowBeat(
                icon: CatchIcons.eventAvailableOutlined,
                label: 'You showed up',
                value: '${event.longDateLabel} | ${event.activitySummaryLabel}',
              ),
              _AfterglowBeat(
                icon: CatchIcons.forumOutlined,
                label: openersEnabled ? 'Openers ready' : 'Memory saved',
                value: openersEnabled
                    ? 'Use the shared event context when a match opens.'
                    : 'Keep the useful parts of the room for yourself.',
              ),
              _AfterglowBeat(
                icon: CatchIcons.favoriteBorderRounded,
                label: feedback == null ? 'Your read' : 'Your read saved',
                value: feedback == null
                    ? feedbackEnabled
                          ? 'Leave a quick note while the event is fresh.'
                          : 'Catch keeps this recap private to you.'
                    : '${feedback.metNewPeopleCount} people remembered, welcome ${feedback.welcomeRating}/5.',
                // Counter animates the first number ("X people remembered")
                // up to its final value to give the recap a Wrapped-style
                // landing beat. Skipped when no feedback exists.
                countValue: feedback?.metNewPeopleCount,
              ),
            ],
          ),
          gapH14,
          _StageSoftBand(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CatchIcons.lockOutlineRounded,
                  size: CatchIcon.md,
                  color: t.primary,
                ),
                gapW8,
                Expanded(
                  child: Text(
                    'Only you see this recap. Hosts get aggregate coaching, never your private notes or individual opener choices.',
                    style: CatchTextStyles.supporting(context, color: t.ink),
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
    this.countValue,
  });

  final IconData icon;
  final String label;
  final String value;

  /// When non-null, the first run of digits in `value` is replaced by a
  /// counter that animates from 0 → countValue. Keeps the surrounding copy
  /// intact (e.g. "3 people remembered" counts the "3" up while the rest of
  /// the sentence stays put).
  final int? countValue;
}

/// Beats land in sequence, 1.4s apart, each sliding up from below with a
/// fade. Counter values animate from 0 to their final number over 600ms once
/// the row has finished entering. Gives the afterglow recap a Spotify-Wrapped
/// style paced reveal instead of dumping all three rows at once.
class _AfterglowBeatGrid extends StatefulWidget {
  const _AfterglowBeatGrid({required this.beats});

  final List<_AfterglowBeat> beats;

  @override
  State<_AfterglowBeatGrid> createState() => _AfterglowBeatGridState();
}

class _AfterglowBeatGridState extends State<_AfterglowBeatGrid> {
  @override
  Widget build(BuildContext context) {
    final beats = widget.beats;
    return Column(
      children: [
        for (var index = 0; index < beats.length; index++) ...[
          if (index > 0) gapH8,
          _AfterglowBeatRow(
            beat: beats[index],
            // Stagger entry by 1.4s per beat. Tests skip the animation gate
            // so the rows just render in their final state.
            entryDelay: _kStageAnimationsEnabled
                ? Duration(milliseconds: index * 1400)
                : Duration.zero,
          ),
        ],
      ],
    );
  }
}

class _AfterglowBeatRow extends StatefulWidget {
  const _AfterglowBeatRow({required this.beat, required this.entryDelay});

  final _AfterglowBeat beat;
  final Duration entryDelay;

  @override
  State<_AfterglowBeatRow> createState() => _AfterglowBeatRowState();
}

class _AfterglowBeatRowState extends State<_AfterglowBeatRow>
    with TickerProviderStateMixin {
  late final AnimationController _entry = AnimationController(
    duration: CatchMotion.afterglowBeatEntry,
    vsync: this,
  );
  late final AnimationController _count = AnimationController(
    duration: CatchMotion.afterglowCountUp,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    if (!_kStageAnimationsEnabled) {
      _entry.value = 1;
      _count.value = 1;
      return;
    }
    // Delay the entry, then once entry completes run the count-up.
    Future<void>.delayed(widget.entryDelay).then((_) async {
      if (!mounted) return;
      await _entry.forward();
      if (!mounted) return;
      if (widget.beat.countValue != null) {
        await _count.forward();
      } else {
        _count.value = 1;
      }
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    _count.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final beat = widget.beat;
    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _count]),
      builder: (context, _) {
        final entry = CatchMotion.easeOutCubicCurve.transform(_entry.value);
        final slide = (1 - entry) * CatchLayout.afterglowBeatSlideOffset;
        return Opacity(
          opacity: entry,
          child: Transform.translate(
            offset: Offset(0, slide),
            child: CatchSurface(
              backgroundColor: t.surface,
              borderColor: t.line,
              radius: CatchRadius.sm,
              padding: CatchInsets.contentDense,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(beat.icon, size: CatchIcon.control, color: t.primary),
                  gapW10,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          beat.label,
                          style: CatchTextStyles.sectionTitle(context),
                        ),
                        gapH2,
                        Text(
                          _animatedValueString(beat),
                          style: CatchTextStyles.supporting(
                            context,
                            color: t.ink2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Replaces the first run of digits in `beat.value` with an animated
  /// counter when `countValue` is set. Lets "${count} people remembered..."
  /// animate the "3" without touching the surrounding copy.
  String _animatedValueString(_AfterglowBeat beat) {
    final target = beat.countValue;
    if (target == null) return beat.value;
    final eased = CatchMotion.easeOutCubicCurve.transform(_count.value);
    final live = (target * eased).round();
    final pattern = RegExp(r'\d+');
    final match = pattern.firstMatch(beat.value);
    if (match == null) return beat.value;
    return beat.value.replaceRange(match.start, match.end, live.toString());
  }
}
