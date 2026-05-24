part of '../event_success_companion_screen.dart';

class _FirstHelloCheckInCard extends StatefulWidget {
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
  State<_FirstHelloCheckInCard> createState() => _FirstHelloCheckInCardState();
}

class _FirstHelloCheckInCardState extends State<_FirstHelloCheckInCard> {
  String? _answerId;
  bool _starting = false;
  bool _saving = false;

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
                  icon: Icons.waving_hand_outlined,
                  label: 'First Hello',
                  color: t.primary,
                ),
                const _PrivacyBadge(_PrivacyAudience.catchPrivate),
              ],
            ),
            gapH12,
            Text(
              'Start your First Hello.',
              style: CatchTextStyles.displayS(context).copyWith(height: 1.04),
            ),
            gapH6,
            Text(
              'We will confirm you are at the venue, then give you one person and one tiny question. Complete it to check in.',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
            gapH14,
            _StageSoftBand(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.near_me_outlined, size: 18, color: t.primary),
                  gapW8,
                  Expanded(
                    child: Text(
                      'This is a private prompt. It is designed to make the first conversation easier, not to put your answers on display.',
                      style: CatchTextStyles.titleS(context),
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
                    icon: const Icon(Icons.play_arrow_rounded),
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
                    icon: const Icon(Icons.qr_code_2_rounded),
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
                icon: Icons.waving_hand_outlined,
                label: 'First Hello',
                color: t.primary,
              ),
              const _PrivacyBadge(_PrivacyAudience.catchPrivate),
            ],
          ),
          gapH12,
          Text(
            'Find ${mission.targetDisplayName}.',
            style: CatchTextStyles.displayS(context).copyWith(height: 1.04),
          ),
          gapH6,
          Text(
            mission.targetContext,
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          gapH14,
          _StageSoftBand(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.question_answer_outlined,
                  size: 18,
                  color: t.primary,
                ),
                gapW8,
                Expanded(
                  child: Text(
                    mission.question,
                    style: CatchTextStyles.titleS(context),
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
                CatchChip(
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
            style: CatchTextStyles.bodyS(context, color: t.ink2),
          ),
          gapH14,
          _StageActionDock(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CatchButton(
                  label: 'Complete check-in',
                  icon: const Icon(Icons.check_rounded),
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
                  icon: const Icon(Icons.swap_horiz_rounded),
                  onPressed: _saving ? null : widget.onSkip,
                  fullWidth: true,
                ),
              ],
            ),
          ),
        ],
      ),
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
    setState(() => _saving = true);
    try {
      await onComplete(mission, answerId);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
