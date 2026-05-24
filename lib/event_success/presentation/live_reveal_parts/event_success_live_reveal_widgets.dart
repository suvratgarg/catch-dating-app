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
    required this.kind,
    required this.clue,
  });

  final EventSuccessPlan plan;
  final DateTime now;
  final EventSuccessRevealAssignmentKind kind;
  final String clue;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final seconds = _remainingSeconds(plan, now);
    final progress = plan.revealProgress(now);
    final urgency = seconds <= 3
        ? 1.0
        : seconds <= 7
        ? 0.72
        : 0.38;
    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF170F24),
              const Color(0xFF2A1844),
              Color.lerp(t.ink, t.primary, 0.42)!,
            ],
          ),
          border: Border.all(color: t.gold.withValues(alpha: 0.34)),
          boxShadow: [
            BoxShadow(
              color: t.primary.withValues(alpha: 0.20 + urgency * 0.12),
              blurRadius: 26 + urgency * 18,
              offset: const Offset(0, 14),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _CountdownAtmospherePainter(
                  progress: progress,
                  intensity: urgency,
                  accent: t.gold,
                  foreground: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(CatchSpacing.s4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Wrap(
                    spacing: CatchSpacing.s2,
                    runSpacing: CatchSpacing.s2,
                    alignment: WrapAlignment.center,
                    children: [
                      CatchBadge(
                        label: 'Room hold',
                        tone: CatchBadgeTone.live,
                        icon: Icons.lock_clock_rounded,
                        backgroundColor: Colors.white.withValues(alpha: 0.14),
                        foregroundColor: Colors.white,
                        borderColor: Colors.white.withValues(alpha: 0.16),
                      ),
                      CatchBadge(
                        label: kind.label,
                        tone: CatchBadgeTone.neutral,
                        icon: kind.icon,
                        backgroundColor: t.gold.withValues(alpha: 0.18),
                        foregroundColor: Colors.white,
                        borderColor: t.gold.withValues(alpha: 0.24),
                      ),
                    ],
                  ),
                  gapH18,
                  _CountdownStageDial(
                    seconds: seconds,
                    progress: progress,
                    intensity: urgency,
                  ),
                  gapH16,
                  Text(
                    _countdownStageHeadline(seconds),
                    textAlign: TextAlign.center,
                    style: CatchTextStyles.displayS(
                      context,
                      color: Colors.white,
                    ).copyWith(letterSpacing: 0),
                  ),
                  gapH8,
                  Text(
                    'Everyone gets this ${kind.assignmentNoun} at the same time. No names shown yet.',
                    textAlign: TextAlign.center,
                    style: CatchTextStyles.bodyM(
                      context,
                      color: Colors.white.withValues(alpha: 0.78),
                    ),
                  ),
                  gapH18,
                  _CountdownBeatRail(progress: progress),
                  gapH14,
                  _CountdownCueStack(clue: clue),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CountdownStageDial extends StatelessWidget {
  const _CountdownStageDial({
    required this.seconds,
    required this.progress,
    required this.intensity,
  });

  final int seconds;
  final double progress;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = (constraints.maxWidth * 0.68)
            .clamp(168.0, 228.0)
            .toDouble();
        return Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress.clamp(0, 1).toDouble()),
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutCubic,
            builder: (context, animatedProgress, _) {
              return SizedBox.square(
                dimension: side,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size.square(side),
                      painter: _CountdownDialPainter(
                        progress: animatedProgress,
                        intensity: intensity,
                        accent: CatchTokens.of(context).gold,
                        foreground: Colors.white,
                      ),
                    ),
                    AnimatedScale(
                      scale: seconds <= 3
                          ? 1.08
                          : seconds.isEven
                          ? 0.96
                          : 1.0,
                      duration: CatchMotion.fast,
                      curve: CatchMotion.springCurve,
                      child: AnimatedSwitcher(
                        duration: CatchMotion.fast,
                        switchInCurve: Curves.easeOutBack,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0, -0.16),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slide,
                              child: ScaleTransition(
                                scale: Tween<double>(
                                  begin: 0.86,
                                  end: 1,
                                ).animate(animation),
                                child: child,
                              ),
                            ),
                          );
                        },
                        child: Text(
                          '$seconds',
                          key: ValueKey(seconds),
                          style:
                              CatchTextStyles.displayL(
                                context,
                                color: Colors.white,
                              ).copyWith(
                                fontSize: side * 0.45,
                                height: 0.9,
                                letterSpacing: 0,
                                shadows: [
                                  Shadow(
                                    color: CatchTokens.of(
                                      context,
                                    ).gold.withValues(alpha: 0.48),
                                    blurRadius: 22 + intensity * 16,
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: side * 0.18,
                      child: Text(
                        'SECONDS',
                        style: CatchTextStyles.labelS(
                          context,
                          color: Colors.white.withValues(alpha: 0.68),
                        ).copyWith(letterSpacing: 0),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _CountdownBeatRail extends StatelessWidget {
  const _CountdownBeatRail({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final activeIndex = progress >= 0.78
        ? 2
        : progress >= 0.42
        ? 1
        : 0;
    return Row(
      children: [
        for (final entry in const [
          (label: 'Hold', icon: Icons.pan_tool_alt_outlined),
          (label: 'Watch', icon: Icons.visibility_outlined),
          (label: 'Move', icon: Icons.bolt_rounded),
        ].indexed) ...[
          Expanded(
            child: _CountdownBeatPill(
              label: entry.$2.label,
              icon: entry.$2.icon,
              active: entry.$1 == activeIndex,
              complete: entry.$1 < activeIndex,
            ),
          ),
          if (entry.$1 < 2) gapW8,
        ],
      ],
    );
  }
}

class _CountdownBeatPill extends StatelessWidget {
  const _CountdownBeatPill({
    required this.label,
    required this.icon,
    required this.active,
    required this.complete,
  });

  final String label;
  final IconData icon;
  final bool active;
  final bool complete;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = active || complete ? t.gold : Colors.white;
    return AnimatedContainer(
      duration: CatchMotion.fast,
      curve: CatchMotion.standardCurve,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s2,
        vertical: CatchSpacing.s2,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: active ? 0.24 : 0.10),
        borderRadius: BorderRadius.circular(CatchRadius.pill),
        border: Border.all(
          color: color.withValues(alpha: active ? 0.52 : 0.16),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 14, color: color),
          gapW4,
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: CatchTextStyles.labelS(
                context,
                color: color,
              ).copyWith(letterSpacing: 0),
            ),
          ),
        ],
      ),
    );
  }
}

class _CountdownCueStack extends StatelessWidget {
  const _CountdownCueStack({required this.clue});

  final String clue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _CountdownCuePill(
          icon: Icons.visibility_off_outlined,
          title: 'No names shown yet',
          body: 'Partner details stay locked until the shared release.',
        ),
        gapH8,
        _CountdownCuePill(
          icon: Icons.tips_and_updates_outlined,
          title: 'Clue is live',
          body: clue,
        ),
      ],
    );
  }
}

class _CountdownCuePill extends StatelessWidget {
  const _CountdownCuePill({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: CatchTokens.of(context).gold, size: 18),
            gapW10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: CatchTextStyles.titleS(context, color: Colors.white),
                  ),
                  gapH2,
                  Text(
                    body,
                    style: CatchTextStyles.bodyS(
                      context,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
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

class _CountdownAtmospherePainter extends CustomPainter {
  const _CountdownAtmospherePainter({
    required this.progress,
    required this.intensity,
    required this.accent,
    required this.foreground,
  });

  final double progress;
  final double intensity;
  final Color accent;
  final Color foreground;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.28);
    final glowPaint = Paint()
      ..color = accent.withValues(alpha: 0.08 + intensity * 0.07)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 36 + intensity * 18);
    canvas.drawCircle(center, size.shortestSide * 0.42, glowPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = foreground.withValues(alpha: 0.10);
    final hotLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = accent.withValues(alpha: 0.22 + intensity * 0.16);

    for (var i = 0; i < 9; i++) {
      final y = size.height * (0.18 + i * 0.075);
      final offset = math.sin((progress * math.pi * 2) + i) * 22;
      canvas.drawLine(
        Offset(size.width * -0.05, y + offset),
        Offset(size.width * 1.05, y - offset),
        i.isEven ? hotLinePaint : linePaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _CountdownAtmospherePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.intensity != intensity ||
      oldDelegate.accent != accent ||
      oldDelegate.foreground != foreground;
}

class _CountdownDialPainter extends CustomPainter {
  const _CountdownDialPainter({
    required this.progress,
    required this.intensity,
    required this.accent,
    required this.foreground,
  });

  final double progress;
  final double intensity;
  final Color accent;
  final Color foreground;

  @override
  void paint(Canvas canvas, Size size) {
    final clampedProgress = progress.clamp(0, 1).toDouble();
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 14;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 9
      ..strokeCap = StrokeCap.round
      ..color = foreground.withValues(alpha: 0.13);
    canvas.drawCircle(center, radius, basePaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18 + intensity * 8
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(alpha: 0.16 + intensity * 0.10)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 14 + intensity * 8);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * clampedProgress,
      false,
      glowPaint,
    );

    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10 + intensity * 4
      ..strokeCap = StrokeCap.round
      ..shader = SweepGradient(
        transform: const GradientRotation(-math.pi / 2),
        colors: [
          accent.withValues(alpha: 0.40),
          foreground.withValues(alpha: 0.90),
          accent,
        ],
      ).createShader(rect);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * clampedProgress,
      false,
      sweepPaint,
    );

    final tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    const tickCount = 36;
    for (var i = 0; i < tickCount; i++) {
      final tickProgress = i / tickCount;
      final angle = -math.pi / 2 + math.pi * 2 * tickProgress;
      final isHot = tickProgress <= clampedProgress;
      tickPaint.color = (isHot ? accent : foreground).withValues(
        alpha: isHot ? 0.60 : 0.16,
      );
      final outer = Offset(
        center.dx + math.cos(angle) * (radius + 12),
        center.dy + math.sin(angle) * (radius + 12),
      );
      final inner = Offset(
        center.dx + math.cos(angle) * (radius + (isHot ? 2 : 5)),
        center.dy + math.sin(angle) * (radius + (isHot ? 2 : 5)),
      );
      canvas.drawLine(inner, outer, tickPaint);
    }

    canvas.drawCircle(
      center,
      radius * 0.68,
      Paint()..color = foreground.withValues(alpha: 0.045),
    );
    canvas.drawCircle(
      center,
      radius * (0.35 + intensity * 0.06),
      Paint()
        ..color = accent.withValues(alpha: 0.08 + intensity * 0.06)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20),
    );
  }

  @override
  bool shouldRepaint(covariant _CountdownDialPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.intensity != intensity ||
      oldDelegate.accent != accent ||
      oldDelegate.foreground != foreground;
}

String _countdownStageHeadline(int seconds) {
  if (seconds <= 3) return 'Get ready to move.';
  if (seconds <= 7) return 'The room is leaning in.';
  return 'The room is holding together.';
}

class _WaitingRevealCue extends StatelessWidget {
  const _WaitingRevealCue({required this.kind});

  final EventSuccessRevealAssignmentKind kind;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.primarySoft,
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        border: Border.all(color: t.primary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: Row(
          children: [
            Icon(Icons.lock_clock_rounded, color: t.primary),
            gapW10,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'The room is holding for the reveal.',
                    style: CatchTextStyles.titleS(context),
                  ),
                  gapH2,
                  Text(
                    'The host controls the ${kind.assignmentNoun} unlock from live mode.',
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
    return _AssignmentUnlockedShell(
      title: 'Unlocked together',
      child: Wrap(
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
      ),
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
    return _AssignmentUnlockedShell(
      title: 'Unlocked together',
      child: Column(
        children: [
          for (final slot in slots)
            _RevealSlotRow(
              slot: slot,
              peerName: profilesByUid[slot.peerUid]?.name ?? 'Partner',
            ),
        ],
      ),
    );
  }
}

class _AssignmentUnlockedShell extends StatelessWidget {
  const _AssignmentUnlockedShell({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Container(
      padding: const EdgeInsets.all(CatchSpacing.s3),
      decoration: BoxDecoration(
        color: t.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        border: Border.all(color: t.success.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchBadge(
            label: title,
            tone: CatchBadgeTone.success,
            icon: Icons.auto_awesome_rounded,
          ),
          gapH10,
          child,
        ],
      ),
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
