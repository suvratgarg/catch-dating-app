part of '../event_success_live_reveal_card.dart';

class HostRevealActions extends StatelessWidget {
  const HostRevealActions({
    super.key,
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

  final int roundCount;
  final int? nextRound;
  final int activeRound;
  final int countdownSeconds;
  final bool isCountingDown;
  final bool allRevealed;
  final bool isLoading;
  final Future<void> Function(int roundIndex, int countdownSeconds)?
  onStartCountdown;
  final Future<void> Function(int roundIndex)? onRevealRound;
  final Future<void> Function()? onResetReveal;

  @override
  Widget build(BuildContext context) {
    if (roundCount == 0) {
      return CatchButton(
        label: 'Generate assignments first',
        icon: Icon(CatchIcons.autoAwesomeOutlined),
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
              icon: Icon(CatchIcons.visibilityOutlined),
              isLoading: isLoading,
              onPressed: isLoading || onRevealRound == null
                  ? null
                  : () => unawaited(onRevealRound!(activeRound)),
              fullWidth: true,
            ),
          ),
          gapW10,
          Expanded(
            child: CatchButton(
              label: 'Reset',
              icon: Icon(CatchIcons.restartAltRounded),
              variant: CatchButtonVariant.secondary,
              isLoading: isLoading,
              onPressed: isLoading || onResetReveal == null
                  ? null
                  : () => unawaited(onResetReveal!()),
              fullWidth: true,
            ),
          ),
        ],
      );
    }
    if (allRevealed) {
      return CatchButton(
        label: 'Reset reveal',
        icon: Icon(CatchIcons.restartAltRounded),
        variant: CatchButtonVariant.secondary,
        isLoading: isLoading,
        onPressed: isLoading || onResetReveal == null
            ? null
            : () => unawaited(onResetReveal!()),
        fullWidth: true,
      );
    }
    final roundIndex = nextRound ?? 0;
    final canUsePrimary = countdownSeconds == 0
        ? onRevealRound != null
        : onStartCountdown != null;
    return Row(
      children: [
        Expanded(
          child: CatchButton(
            label: countdownSeconds == 0
                ? 'Reveal round ${roundIndex + 1}'
                : 'Drop ${countdownSeconds}s countdown',
            icon: Icon(CatchIcons.timerOutlined),
            isLoading: isLoading,
            onPressed: isLoading || !canUsePrimary
                ? null
                : () {
                    if (countdownSeconds == 0) {
                      unawaited(onRevealRound!(roundIndex));
                    } else {
                      unawaited(
                        onStartCountdown!(roundIndex, countdownSeconds),
                      );
                    }
                  },
            fullWidth: true,
          ),
        ),
        gapW10,
        Expanded(
          child: CatchButton(
            label: 'Reveal now',
            icon: Icon(CatchIcons.visibilityOutlined),
            variant: CatchButtonVariant.secondary,
            isLoading: isLoading,
            onPressed: isLoading || onRevealRound == null
                ? null
                : () => unawaited(onRevealRound!(roundIndex)),
            fullWidth: true,
          ),
        ),
      ],
    );
  }
}
