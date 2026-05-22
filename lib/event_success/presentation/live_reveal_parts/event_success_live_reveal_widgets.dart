part of '../event_success_live_reveal_card.dart';

class _CountdownNumber extends StatelessWidget {
  const _CountdownNumber({required this.value, required this.caption});

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 112),
      child: CatchSurface(
        backgroundColor: t.surface.withValues(alpha: 0.12),
        borderColor: t.surface.withValues(alpha: 0.18),
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s4,
          vertical: CatchSpacing.s3,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: CatchMotion.fast,
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: Tween<double>(begin: 0.88, end: 1).animate(animation),
                child: FadeTransition(opacity: animation, child: child),
              ),
              child: Text(
                value,
                key: ValueKey(value),
                style: CatchTextStyles.displayL(
                  context,
                  color: t.surface,
                ).copyWith(fontSize: 48, height: 1, letterSpacing: 0),
              ),
            ),
            gapH4,
            Text(
              caption,
              style: CatchTextStyles.labelS(
                context,
                color: t.surface.withValues(alpha: 0.78),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RevealHostCopy extends StatelessWidget {
  const _RevealHostCopy({required this.headline, required this.body});

  final String headline;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          headline,
          style: CatchTextStyles.titleL(context, color: t.surface),
        ),
        gapH6,
        Text(
          body,
          style: CatchTextStyles.bodyS(
            context,
            color: t.surface.withValues(alpha: 0.78),
          ),
        ),
      ],
    );
  }
}

class _RevealProgressBar extends StatelessWidget {
  const _RevealProgressBar({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.pill),
      child: LinearProgressIndicator(
        minHeight: 7,
        value: progress.clamp(0, 1).toDouble(),
        backgroundColor: t.surface.withValues(alpha: 0.14),
        valueColor: AlwaysStoppedAnimation<Color>(t.gold),
      ),
    );
  }
}

class _AttendeeCountdown extends StatelessWidget {
  const _AttendeeCountdown({
    required this.plan,
    required this.now,
    required this.clue,
  });

  final EventSuccessPlan plan;
  final DateTime now;
  final String clue;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.primarySoft,
      borderColor: Colors.transparent,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Row(
        children: [
          SizedBox(
            width: 62,
            child: Column(
              children: [
                Text(
                  '${_remainingSeconds(plan, now)}',
                  style: CatchTextStyles.displayM(context, color: t.primary),
                ),
                Text(
                  'seconds',
                  style: CatchTextStyles.labelS(context, color: t.ink2),
                ),
              ],
            ),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _RevealProgressBar(progress: plan.revealProgress(now)),
                gapH8,
                Text(
                  clue,
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

class _WaitingRevealCue extends StatelessWidget {
  const _WaitingRevealCue({required this.kind});

  final EventSuccessRevealAssignmentKind kind;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      tone: CatchSurfaceTone.raised,
      borderColor: t.line,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Row(
        children: [
          Icon(Icons.lock_clock_rounded, color: t.ink3),
          gapW10,
          Expanded(
            child: Text(
              'The host controls the ${kind.assignmentNoun} reveal from live mode.',
              style: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisiblePodAssignment extends StatelessWidget {
  const _VisiblePodAssignment({
    required this.assignment,
    required this.peerProfiles,
    required this.peersLoading,
  });

  final EventSuccessAssignment assignment;
  final List<PublicProfile> peerProfiles;
  final bool peersLoading;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        CatchBadge(
          label: '${assignment.peerUids.length + 1} people',
          tone: CatchBadgeTone.neutral,
          icon: Icons.group_outlined,
        ),
        if (peersLoading)
          const CatchBadge(
            label: 'Loading podmates',
            tone: CatchBadgeTone.neutral,
            icon: Icons.hourglass_empty_rounded,
          )
        else
          for (final profile in peerProfiles)
            CatchBadge(
              label: profile.name,
              tone: CatchBadgeTone.neutral,
              icon: Icons.person_outline_rounded,
            ),
      ],
    );
  }
}

class _VisibleRotationSlots extends StatelessWidget {
  const _VisibleRotationSlots({
    required this.slots,
    required this.profilesByUid,
    required this.peersLoading,
  });

  final List<EventSuccessRotationSlot> slots;
  final Map<String, PublicProfile> profilesByUid;
  final bool peersLoading;

  @override
  Widget build(BuildContext context) {
    if (peersLoading) {
      return const CatchBadge(
        label: 'Loading partners',
        tone: CatchBadgeTone.neutral,
        icon: Icons.hourglass_empty_rounded,
      );
    }
    return Column(
      children: [
        for (final slot in slots)
          _RevealSlotRow(
            slot: slot,
            peerName: profilesByUid[slot.peerUid]?.name ?? 'Partner',
          ),
      ],
    );
  }
}

class _RevealSlotRow extends StatelessWidget {
  const _RevealSlotRow({required this.slot, required this.peerName});

  final EventSuccessRotationSlot slot;
  final String peerName;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final timeRange =
        '${TimeOfDay.fromDateTime(slot.startsAt).format(context)}-'
        '${TimeOfDay.fromDateTime(slot.endsAt).format(context)}';
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
      child: CatchSurface(
        tone: CatchSurfaceTone.raised,
        borderColor: t.line,
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: Row(
          children: [
            CatchBadge(
              label: slot.label,
              tone: _isStrongCompatibilitySignal(slot.compatibility)
                  ? CatchBadgeTone.success
                  : CatchBadgeTone.neutral,
            ),
            gapW8,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$timeRange · $peerName',
                    style: CatchTextStyles.titleS(context),
                  ),
                  gapH2,
                  Text(
                    _compatibilityExplanation(slot.compatibility),
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

class _RevealRoundRail extends StatelessWidget {
  const _RevealRoundRail({
    required this.roundCount,
    required this.activeRoundIndex,
    required this.revealedThrough,
    this.foreground,
  });

  final int roundCount;
  final int activeRoundIndex;
  final int revealedThrough;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = foreground ?? t.surface;
    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (var index = 0; index < roundCount; index++)
          CatchBadge(
            label: 'R${index + 1}',
            tone: index <= revealedThrough
                ? CatchBadgeTone.success
                : index == activeRoundIndex
                ? CatchBadgeTone.warning
                : CatchBadgeTone.neutral,
            backgroundColor: foreground == null
                ? color.withValues(
                    alpha: index <= revealedThrough ? 0.18 : 0.10,
                  )
                : null,
            foregroundColor: foreground == null ? color : null,
            borderColor: foreground == null
                ? color.withValues(alpha: 0.14)
                : null,
          ),
      ],
    );
  }
}

class _RevealTicker extends StatefulWidget {
  const _RevealTicker({required this.enabled, required this.builder});

  final bool enabled;
  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  State<_RevealTicker> createState() => _RevealTickerState();
}

class _RevealTickerState extends State<_RevealTicker> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant _RevealTicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) _syncTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(context, _now);

  void _syncTimer() {
    _timer?.cancel();
    _timer = null;
    _now = DateTime.now();
    if (!widget.enabled) return;
    _timer = Timer.periodic(const Duration(milliseconds: 250), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }
}

final class _HostRevealSet {
  const _HostRevealSet({
    required this.kind,
    required this.assignments,
    required this.roundCount,
  });

  final EventSuccessRevealAssignmentKind kind;
  final List<EventSuccessAssignment> assignments;
  final int roundCount;
}
