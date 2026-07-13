part of '../event_success_live_reveal_card.dart';

const EdgeInsets _revealBeatPadding = EdgeInsets.symmetric(
  horizontal: CatchSpacing.s2,
  vertical: CatchSpacing.s2,
);
const EdgeInsets _revealAssignmentRowGap = EdgeInsets.only(
  bottom: CatchSpacing.s2,
);

class CountdownNumber extends StatelessWidget {
  const CountdownNumber({required this.value, required this.caption});

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
  const RevealHostCopy({required this.headline, required this.body});

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
  const RevealProgressBar({required this.progress});

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
    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
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
          border: Border.all(
            color: t.gold.withValues(alpha: CatchOpacity.revealGoldBorder),
          ),
          boxShadow: CatchElevation.glow(
            t.primary.withValues(
              alpha:
                  CatchOpacity.revealGlowBase +
                  urgency * CatchOpacity.revealGlowUrgency,
            ),
            blurRadius: 26 + urgency * 18,
            spreadRadius: 0,
          ),
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
                      CatchBadge(
                        label: context
                            .l10n
                            .eventSuccessEventSuccessLiveRevealWidgetsLabelRoomHold,
                        tone: CatchBadgeTone.live,
                        icon: CatchIcons.lockClockRounded,
                        backgroundColor: t.ink.withValues(
                          alpha: CatchOpacity.warningFill,
                        ),
                        foregroundColor: t.ink,
                        borderColor: t.ink.withValues(
                          alpha: CatchOpacity.revealBeatBorderInactive,
                        ),
                      ),
                      CatchBadge(
                        label: kind.label(context.l10n),
                        icon: kind.icon,
                        backgroundColor: t.gold.withValues(
                          alpha: CatchOpacity.revealSurfaceBorder,
                        ),
                        foregroundColor: t.ink,
                        borderColor: t.gold.withValues(
                          alpha: CatchOpacity.revealBeatFillActive,
                        ),
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
      ),
    );
  }
}

class CountdownStageDial extends StatelessWidget {
  const CountdownStageDial({
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = (constraints.maxWidth * 0.68)
            .clamp(168.0, 228.0)
            .toDouble();
        return Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(end: progress.clamp(0, 1).toDouble()),
            duration: CatchMotion.revealDrop,
            curve: CatchMotion.easeOutCubicCurve,
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
                        foreground: t.ink,
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
                          style: CatchTextStyles.headline(context, color: t.ink)
                              .copyWith(
                                fontSize: side * 0.45,
                                height: 0.9,
                                shadows: [
                                  Shadow(
                                    color: CatchTokens.of(context).gold
                                        .withValues(
                                          alpha:
                                              CatchOpacity.lightOverlayBorder,
                                        ),
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
              );
            },
          ),
        );
      },
    );
  }
}

class CountdownBeatRail extends StatelessWidget {
  const CountdownBeatRail({required this.items, required this.currentIndex})
    : assert(items.length > 0),
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
  const CountdownCueStack({required this.clue});

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
  const WaitingRevealCue({required this.kind});

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

class VisibleRotationSlots extends StatelessWidget {
  const VisibleRotationSlots({
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
  const AssignmentUnlockedShell({required this.title, required this.child});

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
  const RevealGroupSlotRow({required this.slot, required this.profilesByUid});

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
  const RevealSlotRow({required this.slot, required this.peerName});

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
          RevealRoundRow(
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
  const RevealRoundRow({
    required this.index,
    required this.state,
    required this.pairs,
    required this.foreground,
    required this.showDivider,
  });

  final int index;
  final _RevealRoundState state;
  final String? pairs;
  final Color foreground;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
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
        CatchBadgeTone.solid,
      ),
      _RevealRoundState.hidden => (
        context.l10n.eventSuccessEventSuccessLiveRevealWidgetsVisiblecopyHidden,
        CatchBadgeTone.neutral,
      ),
    };
    return Container(
      padding: const EdgeInsets.symmetric(vertical: CatchSpacing.s2),
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

class RevealTicker extends StatefulWidget {
  const RevealTicker({required this.enabled, required this.builder});

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
