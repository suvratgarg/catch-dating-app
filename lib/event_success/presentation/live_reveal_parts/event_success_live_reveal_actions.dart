part of '../event_success_live_reveal_card.dart';

class _HostRevealActions extends ConsumerWidget {
  const _HostRevealActions({
    required this.eventId,
    required this.roundCount,
    required this.nextRound,
    required this.activeRound,
    required this.countdownSeconds,
    required this.isCountingDown,
    required this.allRevealed,
    required this.isLoading,
    this.onStartCountdown,
    this.onRevealRound,
    this.onResetReveal,
  });

  final String eventId;
  final int roundCount;
  final int? nextRound;
  final int activeRound;
  final int countdownSeconds;
  final bool isCountingDown;
  final bool allRevealed;
  final bool isLoading;
  final void Function(int roundIndex, int countdownSeconds)? onStartCountdown;
  final ValueChanged<int>? onRevealRound;
  final VoidCallback? onResetReveal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (roundCount == 0) {
      return CatchButton(
        label: 'Generate assignments first',
        icon: const Icon(Icons.auto_awesome_outlined),
        onPressed: null,
        fullWidth: true,
      );
    }
    if (isCountingDown) {
      return Row(
        children: [
          Expanded(
            child: CatchButton(
              label: 'Reveal now',
              icon: const Icon(Icons.visibility_outlined),
              isLoading: isLoading,
              onPressed: isLoading ? null : () => _reveal(ref, activeRound),
              fullWidth: true,
            ),
          ),
          gapW10,
          Expanded(
            child: CatchButton(
              label: 'Reset',
              icon: const Icon(Icons.restart_alt_rounded),
              variant: CatchButtonVariant.secondary,
              isLoading: isLoading,
              onPressed: isLoading ? null : () => _reset(ref),
              fullWidth: true,
            ),
          ),
        ],
      );
    }
    if (allRevealed) {
      return CatchButton(
        label: 'Reset reveal',
        icon: const Icon(Icons.restart_alt_rounded),
        variant: CatchButtonVariant.secondary,
        isLoading: isLoading,
        onPressed: isLoading ? null : () => _reset(ref),
        fullWidth: true,
      );
    }
    final roundIndex = nextRound ?? 0;
    return Row(
      children: [
        Expanded(
          child: CatchButton(
            label: countdownSeconds == 0
                ? 'Reveal round ${roundIndex + 1}'
                : 'Drop ${countdownSeconds}s countdown',
            icon: const Icon(Icons.timer_outlined),
            isLoading: isLoading,
            onPressed: isLoading
                ? null
                : () {
                    if (countdownSeconds == 0) {
                      _reveal(ref, roundIndex);
                    } else {
                      _start(ref, roundIndex);
                    }
                  },
            fullWidth: true,
          ),
        ),
        gapW10,
        Expanded(
          child: CatchButton(
            label: 'Reveal now',
            icon: const Icon(Icons.visibility_outlined),
            variant: CatchButtonVariant.secondary,
            isLoading: isLoading,
            onPressed: isLoading ? null : () => _reveal(ref, roundIndex),
            fullWidth: true,
          ),
        ),
      ],
    );
  }

  void _start(WidgetRef ref, int roundIndex) {
    unawaited(
      ref
          .read(eventSuccessLiveEffectsControllerProvider)
          .play(EventSuccessLiveEffectKind.countdownStart),
    );
    final fixtureAction = onStartCountdown;
    if (fixtureAction != null) {
      fixtureAction(roundIndex, countdownSeconds);
      return;
    }
    EventSuccessController.startRevealCountdownMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .startRevealCountdown(eventId: eventId, roundIndex: roundIndex),
    );
  }

  void _reveal(WidgetRef ref, int roundIndex) {
    unawaited(
      ref
          .read(eventSuccessLiveEffectsControllerProvider)
          .play(EventSuccessLiveEffectKind.assignmentRevealed),
    );
    final fixtureAction = onRevealRound;
    if (fixtureAction != null) {
      fixtureAction(roundIndex);
      return;
    }
    EventSuccessController.revealRoundMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .revealRound(eventId: eventId, roundIndex: roundIndex),
    );
  }

  void _reset(WidgetRef ref) {
    unawaited(
      ref
          .read(eventSuccessLiveEffectsControllerProvider)
          .play(EventSuccessLiveEffectKind.revealReset),
    );
    final fixtureAction = onResetReveal;
    if (fixtureAction != null) {
      fixtureAction();
      return;
    }
    EventSuccessController.resetRevealMutation.run(
      ref,
      (tx) => tx
          .get(eventSuccessControllerProvider.notifier)
          .resetReveal(eventId: eventId),
    );
  }
}
