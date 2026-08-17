part of '../event_success_live_reveal_card.dart';

const EdgeInsets _revealBeatPadding = EdgeInsets.symmetric(
  horizontal: CatchSpacing.s2,
  vertical: CatchSpacing.s2,
);
const EdgeInsets _revealAssignmentRowGap = EdgeInsets.only(
  bottom: CatchSpacing.s2,
);

class CountdownNumber extends StatelessWidget {
  const CountdownNumber({
    super.key,
    required this.value,
    required this.caption,
  });

  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 112),
      child: CatchSurface(
        backgroundColor: t.surface.withValues(
          alpha: CatchOpacity.revealSurfaceFill,
        ),
        borderColor: t.surface.withValues(
          alpha: CatchOpacity.revealSurfaceBorder,
        ),
        padding: CatchInsets.listBody,
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
                style: CatchTextStyles.display(context, color: t.surface),
              ),
            ),
            gapH4,
            Text(
              caption,
              style: CatchTextStyles.labelS(
                context,
                color: t.surface.withValues(
                  alpha: CatchOpacity.revealMutedForeground,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RevealHostCopy extends StatelessWidget {
  const RevealHostCopy({super.key, required this.headline, required this.body});

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
          style: CatchTextStyles.supporting(
            context,
            color: t.surface.withValues(
              alpha: CatchOpacity.revealMutedForeground,
            ),
          ),
        ),
      ],
    );
  }
}

class RevealProgressBar extends StatelessWidget {
  const RevealProgressBar({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.pill),
      child: LinearProgressIndicator(
        minHeight: 7,
        value: progress.clamp(0, 1).toDouble(),
        backgroundColor: t.surface.withValues(alpha: CatchOpacity.warningFill),
        valueColor: AlwaysStoppedAnimation<Color>(t.gold),
      ),
    );
  }
}

class AttendeeCountdown extends StatelessWidget {
  const AttendeeCountdown({
    super.key,
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
    // Reveal pacing is Event Success policy. The reusable rail receives only
    // ordered display items and the resulting sequence position.
    final currentBeatIndex = progress >= 0.78
        ? 2
        : progress >= 0.42
        ? 1
        : 0;
    final beatItems = [
      (
        label: context.l10n.eventSuccessEventSuccessLiveRevealWidgetsLabelHold,
        icon: CatchIcons.panToolAltOutlined,
      ),
      (
        label: context.l10n.eventSuccessEventSuccessLiveRevealWidgetsLabelWatch,
        icon: CatchIcons.visibilityOutlined,
      ),
      (
        label: context.l10n.eventSuccessEventSuccessLiveRevealWidgetsLabelMove,
        icon: CatchIcons.boltRounded,
      ),
    ];
    final urgency = seconds <= 3
        ? 1.0
        : seconds <= 7
        ? 0.72
        : 0.38;
    return CatchSurface(
      tone: CatchSurfaceTone.transparent,
      radius: CatchRadius.sm,
      padding: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      duration: Duration.zero,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color.alphaBlend(
            t.primary.withValues(alpha: CatchOpacity.revealGradientStart),
            t.bg,
          ),
          Color.alphaBlend(
            t.primary.withValues(alpha: CatchOpacity.revealSurfaceBorder),
            t.bg,
          ),
          Color.lerp(t.ink, t.primary, 0.42)!,
        ],
      ),
      borderColor: t.gold.withValues(alpha: CatchOpacity.revealGoldBorder),
      boxShadow: CatchElevation.glow(
        t.primary.withValues(
          alpha:
              CatchOpacity.revealGlowBase +
              urgency * CatchOpacity.revealGlowUrgency,
        ),
        blurRadius: 26 + urgency * 18,
        spreadRadius: 0,
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _CountdownAtmospherePainter(
                progress: progress,
                intensity: urgency,
                accent: t.gold,
                foreground: t.ink,
              ),
            ),
          ),
          Padding(
            padding: CatchInsets.content,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  alignment: WrapAlignment.center,
                  children: [
                    CatchBadge.onDarkStatus(
                      label: context
                          .l10n
                          .eventSuccessEventSuccessLiveRevealWidgetsLabelRoomHold,
                      icon: CatchIcons.lockClockRounded,
                    ),
                    CatchBadge.onDarkStatus(
                      label: kind.label(context.l10n),
                      icon: kind.icon,
                    ),
                  ],
                ),
                gapH18,
                CountdownStageDial(
                  seconds: seconds,
                  progress: progress,
                  intensity: urgency,
                ),
                gapH16,
                Text(
                  _countdownStageHeadline(seconds),
                  textAlign: TextAlign.center,
                  style: CatchTextStyles.titleL(
                    context,
                    color: t.ink,
                  ).copyWith(),
                ),
                gapH8,
                Text(
                  context.l10n
                      .eventSuccessEventSuccessLiveRevealWidgetsTextEveryoneGetsThisAssignmentnoun(
                        assignmentNoun: kind.assignmentNoun,
                      ),
                  textAlign: TextAlign.center,
                  style: CatchTextStyles.proseM(
                    context,
                    color: t.ink.withValues(
                      alpha: CatchOpacity.revealMutedForeground,
                    ),
                  ),
                ),
                gapH18,
                CountdownBeatRail(
                  items: beatItems,
                  currentIndex: currentBeatIndex,
                ),
                gapH14,
                CountdownCueStack(clue: clue),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CountdownStageDial extends StatelessWidget {
  const CountdownStageDial({
    super.key,
    required this.seconds,
    required this.progress,
    required this.intensity,
  });

  final int seconds;
  final double progress;
  final double intensity;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: FractionallySizedBox(
        widthFactor: CatchLayout.eventSuccessCountdownDialWidthFactor,
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: CatchLayout.eventSuccessCountdownDialMinExtent,
            maxWidth: CatchLayout.eventSuccessCountdownDialMaxExtent,
          ),
          child: AspectRatio(
            aspectRatio: 1,
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(end: progress.clamp(0, 1).toDouble()),
              duration: CatchMotion.revealDrop,
              curve: CatchMotion.easeOutCubicCurve,
              builder: (context, animatedProgress, _) => Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    painter: _CountdownDialPainter(
                      progress: animatedProgress,
                      intensity: intensity,
                      accent: CatchTokens.of(context).gold,
                      foreground: t.ink,
                    ),
                  ),
                  Center(
                    child: FractionallySizedBox(
                      widthFactor:
                          CatchLayout.eventSuccessCountdownNumberWidthFactor,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: AnimatedScale(
                          scale: seconds <= 3
                              ? 1.08
                              : seconds.isEven
                              ? 0.96
                              : 1.0,
                          duration: CatchMotion.fast,
                          curve: CatchMotion.springCurve,
                          child: AnimatedSwitcher(
                            duration: CatchMotion.fast,
                            switchInCurve: CatchMotion.easeOutBackCurve,
                            switchOutCurve: CatchMotion.easeInCubicCurve,
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
                              context.l10n
                                  .eventSuccessEventSuccessLiveRevealWidgetsTextSeconds(
                                    seconds: seconds,
                                  ),
                              key: ValueKey(seconds),
                              style:
                                  CatchTextStyles.headline(
                                    context,
                                    color: t.ink,
                                  ).copyWith(
                                    fontSize: CatchLayout
                                        .eventSuccessCountdownNumberReferenceSize,
                                    height: 0.9,
                                    shadows: [
                                      Shadow(
                                        color: CatchTokens.of(context).gold
                                            .withValues(
                                              alpha: CatchOpacity
                                                  .lightOverlayBorder,
                                            ),
                                        blurRadius: 22 + intensity * 16,
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Align(
                    alignment:
                        CatchLayout.eventSuccessCountdownCaptionAlignment,
                    child: Text(
                      context
                          .l10n
                          .eventSuccessEventSuccessLiveRevealWidgetsTextSeconds3fb8f1,
                      style: CatchTextStyles.labelS(
                        context,
                        color: t.ink.withValues(
                          alpha: CatchOpacity.darkPillFill,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CountdownBeatRail extends StatelessWidget {
  const CountdownBeatRail({
    super.key,
    required this.items,
    required this.currentIndex,
  }) : assert(items.length > 0),
       assert(currentIndex >= 0),
       assert(currentIndex < items.length);

  final List<({String label, IconData icon})> items;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final resolvedItems = [
      for (final entry in items.indexed)
        (
          item: entry.$2,
          state: CatchProgressCueState.fromPosition(
            index: entry.$1,
            currentIndex: currentIndex,
          ),
        ),
    ];

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final entry in resolvedItems.indexed) ...[
            Expanded(
              child: CatchSurface(
                radius: CatchRadius.pill,
                backgroundColor: switch (entry.$2.state) {
                  CatchProgressCueState.current => t.gold.withValues(
                    alpha: CatchOpacity.revealBeatFillActive,
                  ),
                  CatchProgressCueState.complete => t.success.withValues(
                    alpha: CatchOpacity.revealBeatFillInactive,
                  ),
                  CatchProgressCueState.future => t.ink3.withValues(
                    alpha: CatchOpacity.revealBeatFillInactive,
                  ),
                },
                borderColor: switch (entry.$2.state) {
                  CatchProgressCueState.current => t.gold.withValues(
                    alpha: CatchOpacity.revealBeatBorderActive,
                  ),
                  CatchProgressCueState.complete => t.success.withValues(
                    alpha: CatchOpacity.revealBeatBorderInactive,
                  ),
                  CatchProgressCueState.future => t.ink3.withValues(
                    alpha: CatchOpacity.revealBeatBorderInactive,
                  ),
                },
                padding: _revealBeatPadding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      entry.$2.state == CatchProgressCueState.complete
                          ? CatchIcons.checkCircleRounded
                          : entry.$2.item.icon,
                      size: CatchIcon.sm,
                      color: switch (entry.$2.state) {
                        CatchProgressCueState.current => t.gold,
                        CatchProgressCueState.complete => t.success,
                        CatchProgressCueState.future => t.ink3,
                      },
                    ),
                    gapW4,
                    Flexible(
                      child: Text(
                        entry.$2.item.label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: CatchTextStyles.labelS(
                          context,
                          color: switch (entry.$2.state) {
                            CatchProgressCueState.current => t.gold,
                            CatchProgressCueState.complete => t.success,
                            CatchProgressCueState.future => t.ink3,
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (entry.$1 < resolvedItems.length - 1) gapW8,
          ],
        ],
      ),
    );
  }
}

class CountdownCueStack extends StatelessWidget {
  const CountdownCueStack({super.key, required this.clue});

  final String clue;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CountdownCuePill(
          icon: CatchIcons.visibilityOffOutlined,
          title: context
              .l10n
              .eventSuccessEventSuccessLiveRevealWidgetsTitleNoNamesShownYet,
          body: context
              .l10n
              .eventSuccessEventSuccessLiveRevealWidgetsBodyPartnerDetailsStayLocked,
        ),
        gapH8,
        CountdownCuePill(
          icon: CatchIcons.tipsAndUpdatesOutlined,
          title: context
              .l10n
              .eventSuccessEventSuccessLiveRevealWidgetsTitleClueIsLive,
          body: clue,
        ),
      ],
    );
  }
}

class CountdownCuePill extends StatelessWidget {
  const CountdownCuePill({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      radius: CatchRadius.sm,
      backgroundColor: t.ink.withValues(alpha: CatchOpacity.revealCueFill),
      borderColor: t.ink.withValues(alpha: CatchOpacity.revealCueBorder),
      padding: CatchInsets.contentDense,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: t.gold, size: CatchIcon.md),
          gapW10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: CatchTextStyles.sectionTitle(context, color: t.ink),
                ),
                gapH2,
                Text(
                  body,
                  style: CatchTextStyles.supporting(
                    context,
                    color: t.ink.withValues(
                      alpha: CatchOpacity.eventSuccessMutedInk,
                    ),
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
      ..color = accent.withValues(
        alpha:
            CatchOpacity.revealAtmosphereGlowBase +
            intensity * CatchOpacity.revealAtmosphereGlowUrgency,
      )
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 36 + intensity * 18);
    canvas.drawCircle(center, size.shortestSide * 0.42, glowPaint);

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = foreground.withValues(
        alpha: CatchOpacity.revealAtmosphereLineBase,
      );
    final hotLinePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..color = accent.withValues(
        alpha:
            CatchOpacity.revealAtmosphereHotLineBase +
            intensity * CatchOpacity.revealAtmosphereHotLineUrgency,
      );

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
      ..color = foreground.withValues(alpha: CatchOpacity.revealDialBase);
    canvas.drawCircle(center, radius, basePaint);

    final glowPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 18 + intensity * 8
      ..strokeCap = StrokeCap.round
      ..color = accent.withValues(
        alpha:
            CatchOpacity.revealDialGlowBase +
            intensity * CatchOpacity.revealDialGlowUrgency,
      )
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
          accent.withValues(alpha: CatchOpacity.revealDialSweepAccent),
          foreground.withValues(alpha: CatchOpacity.revealDialSweepForeground),
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
      Paint()
        ..color = foreground.withValues(
          alpha: CatchOpacity.revealDialCenterFill,
        ),
    );
    canvas.drawCircle(
      center,
      radius * (0.35 + intensity * 0.06),
      Paint()
        ..color = accent.withValues(
          alpha:
              CatchOpacity.revealDialInnerGlowBase +
              intensity * CatchOpacity.revealDialInnerGlowUrgency,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
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

class WaitingRevealCue extends StatelessWidget {
  const WaitingRevealCue({super.key, required this.kind});

  final EventSuccessRevealAssignmentKind kind;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      radius: CatchRadius.sm,
      backgroundColor: t.primarySoft,
      borderColor: t.primary.withValues(
        alpha: CatchOpacity.revealSurfaceBorder,
      ),
      padding: CatchInsets.contentDense,
      child: Row(
        children: [
          Icon(CatchIcons.lockClockRounded, color: t.primary),
          gapW10,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context
                      .l10n
                      .eventSuccessEventSuccessLiveRevealWidgetsTextTheRoomIsHolding,
                  style: CatchTextStyles.sectionTitle(context),
                ),
                gapH2,
                Text(
                  context.l10n
                      .eventSuccessEventSuccessLiveRevealWidgetsTextTheHostControlsThe(
                        assignmentNoun: kind.assignmentNoun,
                      ),
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class VisiblePodAssignment extends StatelessWidget {
  const VisiblePodAssignment({
    super.key,
    required this.assignment,
    required this.peerProfiles,
    required this.peersLoading,
  });

  final EventSuccessAssignment assignment;
  final List<PublicProfile> peerProfiles;
  final bool peersLoading;

  @override
  Widget build(BuildContext context) {
    return AssignmentUnlockedShell(
      title: context
          .l10n
          .eventSuccessEventSuccessLiveRevealWidgetsTitleUnlockedTogether,
      child: Wrap(
        spacing: CatchSpacing.s2,
        runSpacing: CatchSpacing.s2,
        children: [
          CatchBadge(
            label: context.l10n
                .eventSuccessEventSuccessLiveRevealWidgetsLabelValue1People(
                  value1: assignment.peerUids.length + 1,
                ),
            icon: CatchIcons.groupOutlined,
          ),
          if (peersLoading)
            CatchBadge(
              label: context
                  .l10n
                  .eventSuccessEventSuccessLiveRevealWidgetsLabelLoadingPodmates,
              icon: CatchIcons.hourglassEmptyRounded,
            )
          else
            for (final profile in peerProfiles)
              CatchBadge(
                label: profile.name,
                icon: CatchIcons.personOutlineRounded,
              ),
        ],
      ),
    );
  }
}

class VisibleStandings extends StatelessWidget {
  const VisibleStandings({
    super.key,
    required this.entries,
    required this.unitOutcome,
  });

  final List<EventSuccessStandingEntry> entries;
  final EventSuccessUnitOutcome unitOutcome;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return AssignmentUnlockedShell(
      title: context
          .l10n
          .eventSuccessEventSuccessLiveRevealWidgetsTitleUnlockedTogether,
      child: Column(
        children: [
          for (var index = 0; index < entries.length; index++) ...[
            if (index > 0) Divider(height: CatchSpacing.s4, color: t.line),
            Row(
              children: [
                SizedBox(
                  width: CatchSpacing.s9,
                  child: Text(
                    '#${entries[index].position}',
                    style: CatchTextStyles.labelM(context),
                  ),
                ),
                Expanded(
                  child: Text(
                    entries[index].unitLabel,
                    style: CatchTextStyles.proseM(context),
                  ),
                ),
                gapW12,
                Text(
                  unitOutcome == EventSuccessUnitOutcome.score
                      ? context.l10n.eventSuccessLiveControlPointsValue(
                          points: entries[index].value,
                        )
                      : context.l10n.eventSuccessLiveControlRankValue(
                          rank: entries[index].value.toInt(),
                        ),
                  style: CatchTextStyles.labelM(context, color: t.primary),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class EventSuccessOutcomeRecorder extends StatefulWidget {
  const EventSuccessOutcomeRecorder({
    super.key,
    required this.unitOutcome,
    required this.units,
    required this.nextRoundIndex,
    required this.expectedRevision,
    required this.actionState,
    this.onRecord,
  });

  final EventSuccessUnitOutcome unitOutcome;
  final List<EventSuccessOutcomeUnit> units;
  final int nextRoundIndex;
  final int expectedRevision;
  final EventSuccessOutcomeActionState actionState;
  final Future<void> Function({
    required int expectedRevision,
    required int roundIndex,
    required List<EventSuccessUnitOutcomeEntryInput> entries,
  })?
  onRecord;

  @override
  State<EventSuccessOutcomeRecorder> createState() =>
      _EventSuccessOutcomeRecorderState();
}

class _EventSuccessOutcomeRecorderState
    extends State<EventSuccessOutcomeRecorder> {
  final Map<String, TextEditingController> _controllers = {};

  @override
  void didUpdateWidget(covariant EventSuccessOutcomeRecorder oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.nextRoundIndex != widget.nextRoundIndex ||
        oldWidget.unitOutcome != widget.unitOutcome) {
      _clearControllers();
    }
  }

  @override
  void dispose() {
    _clearControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isRank = widget.unitOutcome == EventSuccessUnitOutcome.rank;
    return Padding(
      padding: CatchInsets.contentDense,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.eventSuccessLiveControlRecordRoundTitle(
              roundNumber: widget.nextRoundIndex + 1,
            ),
            style: CatchTextStyles.sectionTitle(context, color: t.surface),
          ),
          gapH6,
          Text(
            isRank
                ? context.l10n.eventSuccessLiveControlRankEntryInstructions
                : context.l10n.eventSuccessLiveControlScoreEntryInstructions,
            style: CatchTextStyles.supporting(
              context,
              color: t.surface.withValues(
                alpha: CatchOpacity.revealMutedForeground,
              ),
            ),
          ),
          gapH12,
          if (widget.units.isEmpty)
            Text(
              isRank
                  ? context.l10n.eventSuccessLiveControlEmptyUnitsMessage
                  : context.l10n.eventSuccessLiveControlEmptyScoreTeamsMessage,
              style: CatchTextStyles.supporting(context, color: t.surface),
            )
          else
            CatchSection.fieldRows(
              children: [
                for (var index = 0; index < widget.units.length; index++)
                  CatchField.input(
                    key: ValueKey(
                      'event_success.outcome.${widget.nextRoundIndex}.${widget.units[index].id}',
                    ),
                    title: widget.units[index].label,
                    contract: isRank
                        ? CatchContractConstraints
                              .recordEventSuccessUnitOutcomesCallablePayloadEntriesItemsRank
                        : CatchContractConstraints
                              .recordEventSuccessUnitOutcomesCallablePayloadEntriesItemsScore,
                    placeholder: isRank ? '${index + 1}' : '0',
                    controller: _controllerFor(widget.units[index].id),
                    keyboardType: TextInputType.numberWithOptions(
                      decimal: !isRank,
                      signed: !isRank,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
              ],
            ),
          if (widget.actionState.error != null) ...[
            gapH10,
            Text(
              appErrorMessage(
                widget.actionState.error!,
                l10n: context.l10n,
                context: AppErrorContext.event,
              ),
              style: CatchTextStyles.supporting(context, color: t.surface),
            ),
          ],
          gapH12,
          CatchButton(
            label: context.l10n.eventSuccessLiveControlSaveRoundLabel,
            isLoading: widget.actionState.isLoading,
            onPressed:
                widget.actionState.isLoading ||
                    widget.onRecord == null ||
                    _entries() == null
                ? null
                : () => unawaited(
                    widget.onRecord!(
                      expectedRevision: widget.expectedRevision,
                      roundIndex: widget.nextRoundIndex,
                      entries: _entries()!,
                    ),
                  ),
            fullWidth: true,
          ),
        ],
      ),
    );
  }

  List<EventSuccessUnitOutcomeEntryInput>? _entries() {
    if (widget.units.isEmpty) return null;
    if (widget.unitOutcome == EventSuccessUnitOutcome.score) {
      final entries = <EventSuccessUnitOutcomeEntryInput>[];
      for (final unit in widget.units) {
        final score = num.tryParse(_controllers[unit.id]?.text.trim() ?? '');
        if (score == null) return null;
        entries.add(
          EventSuccessScoreOutcomeInput(
            unitId: unit.id,
            unitLabel: unit.label,
            score: score,
          ),
        );
      }
      return entries;
    }
    if (widget.unitOutcome == EventSuccessUnitOutcome.rank) {
      final entries = <EventSuccessUnitOutcomeEntryInput>[];
      final ranks = <int>{};
      for (final unit in widget.units) {
        final rank = int.tryParse(_controllers[unit.id]?.text.trim() ?? '');
        if (rank == null || !ranks.add(rank)) return null;
        entries.add(
          EventSuccessRankOutcomeInput(
            unitId: unit.id,
            unitLabel: unit.label,
            rank: rank,
          ),
        );
      }
      final sorted = ranks.toList()..sort();
      if (sorted.indexed.any((item) => item.$2 != item.$1 + 1)) return null;
      return entries;
    }
    return null;
  }

  TextEditingController _controllerFor(String unitId) =>
      _controllers.putIfAbsent(unitId, TextEditingController.new);

  void _clearControllers() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
  }
}

class VisibleRotationSlots extends StatelessWidget {
  const VisibleRotationSlots({
    super.key,
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
      return CatchBadge(
        label: context
            .l10n
            .eventSuccessEventSuccessLiveRevealWidgetsLabelLoadingPartners,
        icon: CatchIcons.hourglassEmptyRounded,
      );
    }
    return AssignmentUnlockedShell(
      title: context
          .l10n
          .eventSuccessEventSuccessLiveRevealWidgetsTitleUnlockedTogether,
      child: Column(
        children: [
          for (final slot in slots)
            RevealSlotRow(
              slot: slot,
              peerName:
                  profilesByUid[slot.peerUid]?.name ??
                  context
                      .l10n
                      .eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyPartner,
            ),
        ],
      ),
    );
  }
}

class VisibleGroupRotationSlots extends StatelessWidget {
  const VisibleGroupRotationSlots({
    super.key,
    required this.slots,
    required this.profilesByUid,
    required this.peersLoading,
  });

  final List<EventSuccessGroupRotationSlot> slots;
  final Map<String, PublicProfile> profilesByUid;
  final bool peersLoading;

  @override
  Widget build(BuildContext context) {
    if (peersLoading) {
      return CatchBadge(
        label: context
            .l10n
            .eventSuccessEventSuccessLiveRevealWidgetsLabelLoadingGroupMembers,
        icon: CatchIcons.hourglassEmptyRounded,
      );
    }
    return AssignmentUnlockedShell(
      title: context
          .l10n
          .eventSuccessEventSuccessLiveRevealWidgetsTitleUnlockedTogether,
      child: Column(
        children: [
          for (final slot in slots)
            RevealGroupSlotRow(slot: slot, profilesByUid: profilesByUid),
        ],
      ),
    );
  }
}

class AssignmentUnlockedShell extends StatelessWidget {
  const AssignmentUnlockedShell({
    super.key,
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.contentDense,
      radius: CatchRadius.sm,
      backgroundColor: t.success.withValues(
        alpha: CatchOpacity.revealGradientStart,
      ),
      borderColor: t.success.withValues(alpha: CatchOpacity.subtleBorder),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchBadge(
            label: title,
            tone: CatchBadgeTone.success,
            icon: CatchIcons.autoAwesomeRounded,
          ),
          gapH10,
          child,
        ],
      ),
    );
  }
}

class RevealGroupSlotRow extends StatelessWidget {
  const RevealGroupSlotRow({
    super.key,
    required this.slot,
    required this.profilesByUid,
  });

  final EventSuccessGroupRotationSlot slot;
  final Map<String, PublicProfile> profilesByUid;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final timeRange = context.l10n
        .eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyFormatFormat2(
          format: TimeOfDay.fromDateTime(slot.startsAt).format(context),
          format2: TimeOfDay.fromDateTime(slot.endsAt).format(context),
        );
    final peerNames = slot.peerUids
        .map((uid) => profilesByUid[uid]?.name)
        .whereType<String>()
        .toList(growable: false);
    return Padding(
      padding: _revealAssignmentRowGap,
      child: CatchSurface(
        tone: CatchSurfaceTone.raised,
        borderColor: t.line,
        padding: CatchInsets.contentDense,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                CatchBadge(
                  label: slot.label,
                  tone: _isStrongCompatibilitySignal(slot.compatibility)
                      ? CatchBadgeTone.success
                      : CatchBadgeTone.neutral,
                ),
                CatchBadge(
                  label: slot.unitLabel,
                  icon: CatchIcons.tableRestaurantOutlined,
                ),
              ],
            ),
            gapH8,
            Text(timeRange, style: CatchTextStyles.sectionTitle(context)),
            gapH4,
            Text(
              _compatibilityExplanation(slot.compatibility),
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
            gapH10,
            Wrap(
              spacing: CatchSpacing.s2,
              runSpacing: CatchSpacing.s2,
              children: [
                CatchBadge(
                  label: context.l10n
                      .eventSuccessEventSuccessLiveRevealWidgetsLabelValue1People(
                        value1: slot.peerUids.length + 1,
                      ),
                  icon: CatchIcons.groupOutlined,
                ),
                for (final name in peerNames)
                  CatchBadge(
                    label: name,
                    icon: CatchIcons.personOutlineRounded,
                  ),
                if (peerNames.isEmpty)
                  CatchBadge(
                    label: context
                        .l10n
                        .eventSuccessEventSuccessLiveRevealWidgetsLabelNamesLoading,
                    icon: CatchIcons.hourglassEmptyRounded,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class RevealSlotRow extends StatelessWidget {
  const RevealSlotRow({super.key, required this.slot, required this.peerName});

  final EventSuccessRotationSlot slot;
  final String peerName;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final timeRange = context.l10n
        .eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyFormatFormat2(
          format: TimeOfDay.fromDateTime(slot.startsAt).format(context),
          format2: TimeOfDay.fromDateTime(slot.endsAt).format(context),
        );
    return Padding(
      padding: _revealAssignmentRowGap,
      child: CatchSurface(
        tone: CatchSurfaceTone.raised,
        borderColor: t.line,
        padding: CatchInsets.contentDense,
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
                    context.l10n
                        .eventSuccessEventSuccessLiveRevealWidgetsTextTimerangePeername(
                          timeRange: timeRange,
                          peerName: peerName,
                        ),
                    style: CatchTextStyles.sectionTitle(context),
                  ),
                  gapH2,
                  Text(
                    _compatibilityExplanation(slot.compatibility),
                    style: CatchTextStyles.supporting(context, color: t.ink2),
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

enum _RevealRoundState { done, now, hidden }

/// Design-system `RotationCard` round list, dark-adapted for the reveal stage:
/// a config mono line over one row per round — `R{n}`, the pairings (or
/// "Hidden until reveal" while masked), and a Done / Now / Hidden state badge.
/// Pairings only render for rounds the host has already released.
class RevealRoundList extends StatelessWidget {
  const RevealRoundList({
    super.key,
    required this.config,
    required this.roundCount,
    required this.revealedThrough,
    required this.assignments,
    required this.profilesByUid,
  });

  final String config;
  final int roundCount;
  final int revealedThrough;
  final List<EventSuccessAssignment> assignments;
  final Map<String, PublicProfile> profilesByUid;

  @override
  Widget build(BuildContext context) {
    final fg = CatchTokens.of(context).surface;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (config.isNotEmpty) ...[
          Text(
            config.toUpperCase(),
            style: CatchTextStyles.monoLabel(
              context,
              color: fg.withValues(alpha: CatchOpacity.revealMutedForeground),
            ),
          ),
          gapH8,
        ],
        for (var index = 0; index < roundCount; index++)
          RevealRoundRow._(
            index: index,
            state: index < revealedThrough
                ? _RevealRoundState.done
                : index == revealedThrough
                ? _RevealRoundState.now
                : _RevealRoundState.hidden,
            pairs: index <= revealedThrough
                ? _revealRoundPairsLabel(assignments, index, profilesByUid)
                : null,
            foreground: fg,
            showDivider: index > 0,
          ),
      ],
    );
  }
}

class RevealRoundRow extends StatelessWidget {
  const RevealRoundRow._({
    required this.index,
    required this._state,
    required this.pairs,
    required this.foreground,
    required this.showDivider,
  });

  final int index;
  final _RevealRoundState _state;
  final String? pairs;
  final Color foreground;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final hidden = state == _RevealRoundState.hidden;
    final label =
        pairs ??
        (hidden
            ? context
                  .l10n
                  .eventSuccessEventSuccessLiveRevealWidgetsLabelHiddenUntilReveal
            : context.l10n
                  .eventSuccessEventSuccessLiveRevealWidgetsLabelRoundValue1(
                    value1: index + 1,
                  ));
    final (badgeLabel, tone) = switch (state) {
      _RevealRoundState.done => (
        context.l10n.eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyDone,
        CatchBadgeTone.success,
      ),
      _RevealRoundState.now => (
        context.l10n.eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyNow,
        CatchBadgeTone.brand,
      ),
      _RevealRoundState.hidden => (
        context.l10n.eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyHidden,
        CatchBadgeTone.neutral,
      ),
    };
    return Container(
      padding: CatchInsets.contentVerticalCompact,
      decoration: showDivider
          ? BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: foreground.withValues(alpha: CatchOpacity.warningFill),
                ),
              ),
            )
          : null,
      child: Row(
        children: [
          Text(
            context.l10n.eventSuccessEventSuccessLiveRevealWidgetsTextRValue1(
              value1: index + 1,
            ),
            style: CatchTextStyles.monoLabel(
              context,
              color: foreground.withValues(
                alpha: CatchOpacity.revealMutedForeground,
              ),
            ),
          ),
          gapW10,
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style:
                  CatchTextStyles.supporting(
                    context,
                    color: hidden
                        ? foreground.withValues(
                            alpha: CatchOpacity.revealMutedForeground,
                          )
                        : foreground,
                  ).copyWith(
                    fontStyle: hidden ? FontStyle.italic : FontStyle.normal,
                  ),
            ),
          ),
          gapW8,
          CatchBadge(
            label: badgeLabel,
            tone: tone,
            size: CatchBadgeSize.action,
            backgroundColor: foreground.withValues(
              alpha: state == _RevealRoundState.now
                  ? CatchOpacity.revealSurfaceBorder
                  : CatchOpacity.revealBeatFillInactive,
            ),
            foregroundColor: foreground,
            borderColor: foreground.withValues(alpha: CatchOpacity.warningFill),
          ),
        ],
      ),
    );
  }
}

class RevealRoundRail extends StatelessWidget {
  const RevealRoundRail({
    super.key,
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
            label: context.l10n
                .eventSuccessEventSuccessLiveRevealWidgetsLabelRValue1(
                  value1: index + 1,
                ),
            tone: index <= revealedThrough
                ? CatchBadgeTone.success
                : index == activeRoundIndex
                ? CatchBadgeTone.warning
                : CatchBadgeTone.neutral,
            backgroundColor: foreground == null
                ? color.withValues(
                    alpha: index <= revealedThrough
                        ? CatchOpacity.revealSurfaceBorder
                        : CatchOpacity.revealBeatFillInactive,
                  )
                : null,
            foregroundColor: foreground == null ? color : null,
            borderColor: foreground == null
                ? color.withValues(alpha: CatchOpacity.warningFill)
                : null,
          ),
      ],
    );
  }
}

class RevealHostStatusLayout extends StatelessWidget {
  const RevealHostStatusLayout({
    super.key,
    required this.number,
    required this.copy,
  });

  final CountdownNumber number;
  final RevealHostCopy copy;

  @override
  Widget build(BuildContext context) {
    return ComponentResponsiveBuilder(
      breakpoint: ComponentBreakpoints.eventSuccessRevealHostCompactBreakpoint,
      compact: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [number, gapH14, copy],
      ),
      expanded: (context) => Row(
        children: [
          number,
          gapW16,
          Expanded(child: copy),
        ],
      ),
    );
  }
}

class RevealTicker extends StatefulWidget {
  const RevealTicker({super.key, required this.enabled, required this.builder});

  final bool enabled;
  final Widget Function(BuildContext context, DateTime now) builder;

  @override
  State<RevealTicker> createState() => _RevealTickerState();
}

class _RevealTickerState extends State<RevealTicker> {
  Timer? _timer;
  DateTime _now = DateTime.now();

  @override
  void initState() {
    super.initState();
    _syncTimer();
  }

  @override
  void didUpdateWidget(covariant RevealTicker oldWidget) {
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
    _timer = Timer.periodic(CatchMotion.liveRevealClockTick, (_) {
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
