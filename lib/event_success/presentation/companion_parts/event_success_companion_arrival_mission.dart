part of '../event_success_companion_screen.dart';

class _FirstHelloCheckInCard extends ConsumerStatefulWidget {
  const _FirstHelloCheckInCard({
    required this.mission,
    required this.onStart,
    required this.onComplete,
    required this.onSkip,
  });

  final EventSuccessArrivalMission? mission;
  final Future<void> Function()? onStart;
  final Future<void> Function(
    EventSuccessArrivalMission mission,
    String answerId,
  )?
  onComplete;
  final VoidCallback? onSkip;

  @override
  ConsumerState<_FirstHelloCheckInCard> createState() =>
      _FirstHelloCheckInCardState();
}

class _FirstHelloCheckInCardState extends ConsumerState<_FirstHelloCheckInCard>
    with SingleTickerProviderStateMixin {
  String? _answerId;
  bool _starting = false;
  bool _saving = false;
  bool _celebrating = false;

  late final AnimationController _celebration;

  @override
  void initState() {
    super.initState();
    _celebration = AnimationController(
      duration: CatchMotion.arrivalCelebration,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _celebration.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final mission = widget.mission;
    if (mission == null) {
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
                  icon: CatchIcons.wavingHandOutlined,
                  label: 'First Hello',
                  color: t.primary,
                ),
                const _PrivacyBadge(_PrivacyAudience.catchPrivate),
              ],
            ),
            gapH12,
            Text(
              'Start your First Hello.',
              style: CatchTextStyles.titleL(context),
            ),
            gapH6,
            Text(
              'We will confirm you are at the venue, then give you one person and one tiny question. Complete it to check in.',
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
            gapH14,
            _StageSoftBand(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    CatchIcons.nearMeOutlined,
                    size: CatchIcon.md,
                    color: t.primary,
                  ),
                  gapW8,
                  Expanded(
                    child: Text(
                      'This is a private prompt. It is designed to make the first conversation easier, not to put your answers on display.',
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                  ),
                ],
              ),
            ),
            gapH14,
            _StageActionDock(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CatchButton(
                    label: 'Start First Hello',
                    icon: Icon(CatchIcons.playArrowRounded),
                    isLoading: _starting,
                    onPressed: _starting || widget.onStart == null
                        ? null
                        : _start,
                    fullWidth: true,
                  ),
                  gapH8,
                  CatchButton(
                    label: 'Use normal check-in',
                    variant: CatchButtonVariant.ghost,
                    icon: Icon(CatchIcons.qrCode2Rounded),
                    onPressed: _starting ? null : widget.onSkip,
                    fullWidth: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    final selectedAnswerId = _answerId;
    return Stack(
      children: [
        _StagePanel(
          child: _missionEditor(context, mission, selectedAnswerId, t),
        ),
        if (_celebrating)
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: _celebration,
                builder: (context, _) {
                  final v = _celebration.value;
                  // Triangle wave: alpha rises 0→peak then falls back to 0.
                  final alpha =
                      (v < CatchOpacity.arrivalCelebrationLowMultiplier
                          ? v * 2
                          : (1 - v) * 2) *
                      CatchOpacity.arrivalCelebrationPeak;
                  return DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(CatchRadius.sm),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          CatchEventSuccessColors.arrivalCelebrationWarm
                              .withValues(alpha: alpha),
                          CatchEventSuccessColors.arrivalCelebrationHot
                              .withValues(
                                alpha:
                                    alpha *
                                    CatchOpacity
                                        .arrivalCelebrationMidMultiplier,
                              ),
                          CatchEventSuccessColors.arrivalCelebrationGold
                              .withValues(
                                alpha:
                                    alpha *
                                    CatchOpacity
                                        .arrivalCelebrationLowMultiplier,
                              ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
      ],
    );
  }

  Widget _missionEditor(
    BuildContext context,
    EventSuccessArrivalMission mission,
    String? selectedAnswerId,
    CatchTokens t,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StageSectionLabel(
              icon: CatchIcons.wavingHandOutlined,
              label: 'First Hello',
              color: t.primary,
            ),
            const _PrivacyBadge(_PrivacyAudience.catchPrivate),
          ],
        ),
        gapH12,
        Text(
          'Find ${mission.targetDisplayName}.',
          style: CatchTextStyles.titleL(context),
        ),
        gapH6,
        Text(
          mission.targetContext,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
        gapH14,
        _StageSoftBand(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                CatchIcons.questionAnswerOutlined,
                size: CatchIcon.md,
                color: t.primary,
              ),
              gapW8,
              Expanded(
                child: Text(
                  mission.question,
                  style: CatchTextStyles.sectionTitle(context),
                ),
              ),
            ],
          ),
        ),
        gapH14,
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            for (final option in mission.answerOptions)
              _StageBouncyChip(
                label: option.label,
                active: selectedAnswerId == option.id,
                onTap: _saving
                    ? null
                    : () => setState(() => _answerId = option.id),
              ),
          ],
        ),
        gapH14,
        Text(
          'Complete this tiny mission to check in. If the room is crowded or the person is late, use the fallback.',
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
        gapH14,
        _StageActionDock(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchButton(
                label: 'Complete check-in',
                icon: Icon(CatchIcons.checkRounded),
                isLoading: _saving,
                onPressed:
                    selectedAnswerId == null ||
                        _saving ||
                        widget.onComplete == null
                    ? null
                    : () => _complete(selectedAnswerId),
                fullWidth: true,
              ),
              gapH8,
              CatchButton(
                label: 'Can\'t find them',
                variant: CatchButtonVariant.ghost,
                icon: Icon(CatchIcons.swapHorizRounded),
                onPressed: _saving ? null : widget.onSkip,
                fullWidth: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _start() async {
    final onStart = widget.onStart;
    if (onStart == null) return;
    setState(() => _starting = true);
    try {
      await onStart();
    } finally {
      if (mounted) setState(() => _starting = false);
    }
  }

  Future<void> _complete(String answerId) async {
    final mission = widget.mission;
    final onComplete = widget.onComplete;
    if (mission == null || onComplete == null) return;
    setState(() {
      _saving = true;
      _celebrating = true;
    });
    // Layer haptic + chime first so the user feels the celebration land
    // before the gradient sweep finishes.
    unawaited(
      ref
          .read(eventSuccessLiveEffectsControllerProvider)
          .play(EventSuccessLiveEffectKind.guideComplete),
    );
    final celebrationFuture = _kStageAnimationsEnabled
        ? _celebration.forward(from: 0)
        : Future<void>.value();
    try {
      // Run the celebration animation in parallel with the network call.
      // Both must complete before we hand off to the next moment, otherwise
      // the gradient sweep snaps off mid-animation when the moment changes.
      await Future.wait([celebrationFuture, onComplete(mission, answerId)]);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
          _celebrating = false;
        });
      }
    }
  }
}
