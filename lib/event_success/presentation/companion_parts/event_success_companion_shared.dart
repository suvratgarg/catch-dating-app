part of '../event_success_companion_screen.dart';

const EdgeInsets _companionMomentStagePadding = EdgeInsets.fromLTRB(
  CatchSpacing.s4,
  CatchSpacing.s3,
  CatchSpacing.s4,
  CatchSpacing.s5,
);
const EdgeInsets _companionStagePillPadding = EdgeInsets.symmetric(
  horizontal: CatchSpacing.micro14,
  vertical: CatchSpacing.s2,
);

/// Repeating Tickers schedule frames forever, which deadlocks Flutter's
/// `pumpAndSettle` in widget tests. We auto-disable continuous animations
/// when the `FLUTTER_TEST` env var is set (the test runner provides it).
/// Production runs untouched; tests that genuinely want kinetic behaviour
/// can use `pump(Duration(...))` with explicit time advancement.
final bool _kStageAnimationsEnabled = !Platform.environment.containsKey(
  'FLUTTER_TEST',
);

class CompanionStageScaffold extends StatelessWidget {
  const CompanionStageScaffold({
    required this.event,
    required this.plan,
    required this.presentation,
    required this.stageTheme,
    required this.attended,
    required this.showSelfCheckIn,
    required this.eventEnded,
    required this.momentKey,
    required this.momentKind,
    required this.referenceNow,
    required this.content,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventSuccessMomentPresentation presentation;
  final _CompanionStageTheme stageTheme;
  final bool attended;
  final bool showSelfCheckIn;
  final bool eventEnded;
  final String momentKey;
  final EventSuccessAttendeeMomentKind momentKind;
  final DateTime referenceNow;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const ValueKey('eventSuccessCompanionStage'),
      backgroundColor: stageTheme.background,
      body: CatchSurface(
        duration: CatchMotion.slow,
        radius: CatchRadius.none,
        gradient: stageTheme.gradient,
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedStageMotifBackground(
                  accent: stageTheme.accent,
                  foreground: stageTheme.foreground,
                  motif: stageTheme.motif,
                ),
              ),
            ),
            // Sits between motif background and content. Renders nothing
            // when not in the reveal moment, so other beats are untouched.
            Positioned.fill(
              child: RevealCinematicOverlay(
                plan: plan,
                referenceNow: referenceNow,
                momentKind: momentKind,
                stageTheme: stageTheme,
                checkedInCount: event.checkedInCount ?? 0,
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                          maxWidth: CatchLayout.maxContentWidth,
                        ),
                        child: Padding(
                          padding: _companionMomentStagePadding,
                          child: CompanionMomentStage(
                            event: event,
                            plan: plan,
                            presentation: presentation,
                            stageTheme: stageTheme,
                            attended: attended,
                            showSelfCheckIn: showSelfCheckIn,
                            eventEnded: eventEnded,
                            momentKey: momentKey,
                            momentKind: momentKind,
                            content: content,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanionPaperScaffold extends StatelessWidget {
  const CompanionPaperScaffold({
    required this.event,
    required this.plan,
    required this.presentation,
    required this.showSelfCheckIn,
    required this.eventEnded,
    required this.selfCheckInActionState,
    required this.onSelfCheckIn,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventSuccessMomentPresentation presentation;
  final bool showSelfCheckIn;
  final bool eventEnded;
  final SelfCheckInActionState selfCheckInActionState;
  final Future<void> Function() onSelfCheckIn;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      key: const ValueKey('eventSuccessCompanionPaper'),
      backgroundColor: t.bg,
      bottomNavigationBar: showSelfCheckIn
          ? SafeArea(
              minimum: const EdgeInsets.fromLTRB(
                CatchSpacing.screenPx,
                CatchSpacing.s2,
                CatchSpacing.screenPx,
                CatchSpacing.s3,
              ),
              child: PaperSelfCheckInBar(
                event: event,
                actionState: selfCheckInActionState,
                onSelfCheckIn: onSelfCheckIn,
              ),
            )
          : null,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                    maxWidth: CatchLayout.maxContentWidth,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      CatchSpacing.screenPx,
                      CatchSpacing.s2,
                      CatchSpacing.screenPx,
                      CatchSpacing.s8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PaperCompanionNav(plan: plan),
                        gapH20,
                        PaperCompanionTicket(event: event, plan: plan),
                        gapH24,
                        PaperExpectationCard(
                          event: event,
                          plan: plan,
                          showSelfCheckIn: showSelfCheckIn,
                          eventEnded: eventEnded,
                        ),
                        if (!showSelfCheckIn) ...[
                          gapH16,
                          PaperPrivacyCard(text: presentation.privacyLine),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class PaperCompanionNav extends StatelessWidget {
  const PaperCompanionNav({required this.plan});

  final EventSuccessPlan plan;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final canPop = _companionCanPop(context);
    final totalSteps = math.max(1, plan.playbook.runOfShow.length);
    final activeStep = (plan.activeStepIndex + 1).clamp(1, totalSteps);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Tooltip(
              message: MaterialLocalizations.of(context).backButtonTooltip,
              child: CatchIconButton(
                background: Colors.transparent,
                onTap: canPop ? () => _popCompanion(context) : null,
                child: Icon(
                  CatchIcons.arrowBackRounded,
                  size: CatchIcon.md,
                  color: canPop ? t.ink3 : t.line2,
                ),
              ),
            ),
            gapW8,
            Expanded(
              child: Text(
                'Event companion',
                textAlign: TextAlign.center,
                style: CatchTextStyles.titleS(context),
              ),
            ),
            gapW8,
            SizedBox(
              width: CatchLayout.eventSuccessStageNavExtent,
              child: Text(
                '${activeStep.toString().padLeft(2, '0')} / $totalSteps',
                textAlign: TextAlign.end,
                style: CatchTextStyles.labelS(context, color: t.ink2),
              ),
            ),
          ],
        ),
        gapH18,
        PaperProgressRail(active: activeStep, total: totalSteps),
      ],
    );
  }
}

class PaperProgressRail extends StatelessWidget {
  const PaperProgressRail({required this.active, required this.total});

  final int active;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final count = total.clamp(1, 13);
    return Row(
      children: [
        for (var index = 0; index < count; index++) ...[
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: index < active ? t.primary : t.line2,
                borderRadius: BorderRadius.circular(CatchRadius.pill),
              ),
              child: const SizedBox(height: CatchSpacing.micro3),
            ),
          ),
          if (index != count - 1) gapW4,
        ],
      ],
    );
  }
}

class PaperCompanionTicket extends StatelessWidget {
  const PaperCompanionTicket({required this.event, required this.plan});

  final Event event;
  final EventSuccessPlan plan;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activitySwatch = ActivityPalette.of(
      context,
    ).forKind(event.activityKind);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YOUR TICKET - TODAY',
          style: CatchTextStyles.sectionTitle(context, color: t.ink2),
        ),
        gapH12,
        CatchSurface(
          padding: EdgeInsets.zero,
          radius: CatchRadius.md,
          backgroundColor: t.surface,
          borderColor: t.line,
          boxShadow: CatchElevation.card,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PaperTicketHeader(
                  event: event,
                  plan: plan,
                  swatch: activitySwatch,
                ),
                Padding(
                  padding: CatchInsets.contentDense,
                  child: Row(
                    children: [
                      Expanded(
                        child: PaperTicketDetail(
                          label: 'WHEN',
                          value: _paperTicketTime(event),
                        ),
                      ),
                      gapW12,
                      Expanded(
                        child: PaperTicketDetail(
                          label: 'WHERE',
                          value: event.locationName,
                        ),
                      ),
                      gapW12,
                      Expanded(
                        child: PaperTicketDetail(
                          label: 'ENTRY',
                          value: event.isFree
                              ? 'Free'
                              : EventFormatters.priceInPaise(
                                  event.priceInPaise,
                                  currencyCode: event.currency,
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const PaperTicketPerforation(),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CatchSpacing.s4,
                    CatchSpacing.s3,
                    CatchSpacing.s4,
                    CatchSpacing.s4,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: PaperTicketSerial(event: event)),
                      gapW16,
                      const PaperBarcode(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class PaperTicketHeader extends StatelessWidget {
  const PaperTicketHeader({
    required this.event,
    required this.plan,
    required this.swatch,
  });

  final Event event;
  final EventSuccessPlan plan;
  final ActivitySwatch swatch;

  @override
  Widget build(BuildContext context) {
    final foreground = CatchTokens.editorialLight;
    return CatchSurface(
      radius: CatchRadius.none,
      backgroundColor: swatch.deep,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PaperTicketHeaderPainter(
                lineColor: swatch.accent.withValues(alpha: 0.26),
                markColor: foreground.withValues(alpha: 0.10),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s4,
              CatchSpacing.s9,
              CatchSpacing.s4,
              CatchSpacing.s4,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${plan.playbook.title} - ${event.locationName}'
                      .toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.sectionTitle(
                    context,
                    color: foreground.withValues(alpha: 0.82),
                  ),
                ),
                gapH6,
                Text(
                  event.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.titleL(context, color: foreground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PaperTicketHeaderPainter extends CustomPainter {
  const _PaperTicketHeaderPainter({
    required this.lineColor,
    required this.markColor,
  });

  final Color lineColor;
  final Color markColor;

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (var index = -2; index < 12; index++) {
      final start = Offset(size.width * -0.2 + index * 34, size.height);
      final end = Offset(start.dx + size.height, 0);
      canvas.drawLine(start, end, linePaint);
    }

    final markPaint = Paint()
      ..color = markColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final center = Offset(size.width * 0.82, size.height * 0.52);
    canvas.drawCircle(center, 30, markPaint);
    canvas.drawCircle(center.translate(22, -2), 30, markPaint);
  }

  @override
  bool shouldRepaint(covariant _PaperTicketHeaderPainter oldDelegate) =>
      oldDelegate.lineColor != lineColor || oldDelegate.markColor != markColor;
}

class PaperTicketDetail extends StatelessWidget {
  const PaperTicketDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.sectionTitle(context, color: t.ink3),
        ),
        gapH6,
        Text(
          value,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.labelL(context),
        ),
      ],
    );
  }
}

class PaperTicketPerforation extends StatelessWidget {
  const PaperTicketPerforation();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      height: CatchSpacing.s3,
      child: CustomPaint(
        painter: _PaperTicketPerforationPainter(color: t.line2),
      ),
    );
  }
}

class _PaperTicketPerforationPainter extends CustomPainter {
  const _PaperTicketPerforationPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = CatchStroke.hairline
      ..style = PaintingStyle.stroke;
    const dashWidth = 6.0;
    const gapWidth = 4.0;
    var x = 0.0;
    final y = size.height / 2;
    while (x < size.width) {
      canvas.drawLine(Offset(x, y), Offset(x + dashWidth, y), paint);
      x += dashWidth + gapWidth;
    }
  }

  @override
  bool shouldRepaint(covariant _PaperTicketPerforationPainter oldDelegate) =>
      oldDelegate.color != color;
}

class PaperTicketSerial extends StatelessWidget {
  const PaperTicketSerial({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final booked = event.bookedCount ?? 0;
    final capacity = event.capacityLimit;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADMIT ONE - NO ${booked.toString().padLeft(2, '0')} / $capacity',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.sectionTitle(context, color: t.ink3),
        ),
        gapH6,
        Text(
          _paperTicketCode(event),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.labelL(context),
        ),
      ],
    );
  }
}

class PaperBarcode extends StatelessWidget {
  const PaperBarcode();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return SizedBox(
      width: CatchLayout.eventSuccessPaperBarcodeWidth,
      height: CatchLayout.eventSuccessPaperBarcodeHeight,
      child: CustomPaint(painter: _PaperBarcodePainter(color: t.ink)),
    );
  }
}

class _PaperBarcodePainter extends CustomPainter {
  const _PaperBarcodePainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    const widths = [2.0, 1.0, 4.0, 1.0, 2.0, 3.0, 1.0, 1.0, 4.0, 2.0];
    var x = 0.0;
    var index = 0;
    while (x < size.width) {
      final width = widths[index % widths.length];
      canvas.drawRect(Rect.fromLTWH(x, 0, width, size.height), paint);
      x += width + (index.isEven ? 3 : 2);
      index++;
    }
  }

  @override
  bool shouldRepaint(covariant _PaperBarcodePainter oldDelegate) =>
      oldDelegate.color != color;
}

class PaperExpectationCard extends StatelessWidget {
  const PaperExpectationCard({
    required this.event,
    required this.plan,
    required this.showSelfCheckIn,
    required this.eventEnded,
  });

  final Event event;
  final EventSuccessPlan plan;
  final bool showSelfCheckIn;
  final bool eventEnded;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final items = _paperExpectationItems(
      event: event,
      plan: plan,
      showSelfCheckIn: showSelfCheckIn,
      eventEnded: eventEnded,
    );
    return CatchSurface(
      radius: CatchRadius.md,
      backgroundColor: t.surface,
      borderColor: t.line,
      padding: CatchInsets.content,
      boxShadow: CatchElevation.card,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StageSectionLabel(
            icon: CatchIcons.eventAvailableRounded,
            label: 'What to expect',
            color: t.primary,
          ),
          gapH12,
          for (final item in items) ...[
            PaperExpectationRow(item: item),
            if (item != items.last) gapH12,
          ],
        ],
      ),
    );
  }
}

class PaperExpectationRow extends StatelessWidget {
  const PaperExpectationRow({required this.item});

  final _PaperExpectationItem item;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.micro2),
          child: Icon(item.icon, size: CatchIcon.sm, color: t.ink3),
        ),
        gapW12,
        Expanded(
          child: Text(item.label, style: CatchTextStyles.bodyM(context)),
        ),
      ],
    );
  }
}

class PaperPrivacyCard extends StatelessWidget {
  const PaperPrivacyCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      radius: CatchRadius.sm,
      backgroundColor: t.primarySoft,
      borderWidth: 0,
      padding: CatchInsets.contentDense,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CatchIcons.lockOutlineRounded,
            size: CatchIcon.sm,
            color: t.ink2,
          ),
          gapW8,
          Expanded(
            child: Text(
              text,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ),
        ],
      ),
    );
  }
}

class PaperSelfCheckInBar extends StatelessWidget {
  const PaperSelfCheckInBar({
    required this.event,
    required this.actionState,
    required this.onSelfCheckIn,
  });

  final Event event;
  final SelfCheckInActionState actionState;
  final Future<void> Function() onSelfCheckIn;

  @override
  Widget build(BuildContext context) {
    return CatchButton(
      label: "I'm here - check me in",
      icon: Icon(CatchIcons.locationOnOutlined),
      isLoading: actionState.isCheckingIn,
      onPressed: actionState.isCheckingIn
          ? null
          : () => unawaited(onSelfCheckIn()),
      fullWidth: true,
      size: CatchButtonSize.lg,
    );
  }
}

class _PaperExpectationItem {
  const _PaperExpectationItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

List<_PaperExpectationItem> _paperExpectationItems({
  required Event event,
  required EventSuccessPlan plan,
  required bool showSelfCheckIn,
  required bool eventEnded,
}) {
  if (eventEnded) {
    return [
      _PaperExpectationItem(
        icon: CatchIcons.favoriteBorderRounded,
        label: 'Post-event follow-up opens after attendance is confirmed.',
      ),
      _PaperExpectationItem(
        icon: CatchIcons.chatBubbleOutlineRounded,
        label: 'Conversation starters stay private to your event context.',
      ),
    ];
  }
  return [
    _PaperExpectationItem(
      icon: showSelfCheckIn
          ? CatchIcons.locationOnOutlined
          : CatchIcons.groups2Outlined,
      label: showSelfCheckIn
          ? 'Check in when you reach ${event.locationName}.'
          : 'A small starter group will form when arrivals open.',
    ),
    if (plan.hasModule(EventSuccessModuleCatalog.guidedRotations.id))
      _PaperExpectationItem(
        icon: CatchIcons.syncAltRounded,
        label: 'Timed partner rotations as the event unfolds.',
      )
    else
      _PaperExpectationItem(
        icon: CatchIcons.forumOutlined,
        label: 'Conversation cues appear when the room needs an easy opener.',
      ),
    if (plan.hasModule(EventSuccessModuleCatalog.liveReveal.id))
      _PaperExpectationItem(
        icon: CatchIcons.boltRounded,
        label: 'One synchronized reveal - every phone at once.',
      )
    else
      _PaperExpectationItem(
        icon: CatchIcons.lockOutlineRounded,
        label: 'Your guide stays private to your ticket and attendance.',
      ),
  ];
}

String _paperTicketTime(Event event) {
  final day = AppTimeFormatters.shortWeekday(event.startTime);
  final time = AppTimeFormatters.time(event.startTime);
  return '$day - $time';
}

String _paperTicketCode(Event event) {
  final compactId = event.id
      .replaceAll(RegExp('[^A-Za-z0-9]'), '')
      .toUpperCase()
      .padRight(7, 'X');
  return 'CTH-${compactId.substring(0, 4)}-${compactId.substring(4, 7)}';
}

class CompanionMomentStage extends StatelessWidget {
  const CompanionMomentStage({
    required this.event,
    required this.plan,
    required this.presentation,
    required this.stageTheme,
    required this.attended,
    required this.showSelfCheckIn,
    required this.eventEnded,
    required this.momentKey,
    required this.momentKind,
    required this.content,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventSuccessMomentPresentation presentation;
  final _CompanionStageTheme stageTheme;
  final bool attended;
  final bool showSelfCheckIn;
  final bool eventEnded;
  final String momentKey;
  final EventSuccessAttendeeMomentKind momentKind;
  final Widget content;

  /// Co-presence ring is meaningful only while the room is still gathering.
  /// During the live event itself, the room composition is already known and
  /// the ring just clutters the stage.
  bool get _showArrivalRing => switch (momentKind) {
    EventSuccessAttendeeMomentKind.preArrival ||
    EventSuccessAttendeeMomentKind.selfCheckIn ||
    EventSuccessAttendeeMomentKind.firstHelloCheckIn => true,
    _ => false,
  };

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StageNav(foreground: stageTheme.foreground),
        gapH16,
        CompanionHero(
          event: event,
          plan: plan,
          presentation: presentation,
          stageTheme: stageTheme,
          attended: attended,
          showSelfCheckIn: showSelfCheckIn,
          eventEnded: eventEnded,
        ),
        gapH32,
        if (_showArrivalRing) ...[
          Center(
            child: LiveArrivalRing(
              checkedInCount: event.checkedInCount ?? 0,
              stageTheme: stageTheme,
            ),
          ),
          gapH18,
        ] else ...[
          StageGlyph(stageTheme: stageTheme, icon: presentation.icon),
          gapH18,
        ],
        AnimatedSwitcher(
          duration: CatchMotion.slow,
          switchInCurve: CatchMotion.standardCurve,
          switchOutCurve: CatchMotion.easeInCubicCurve,
          transitionBuilder: (child, animation) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: CatchMotion.standardCurve,
              reverseCurve: CatchMotion.easeInCubicCurve,
            );
            final offset = Tween<Offset>(
              begin: const Offset(0, 0.16),
              end: Offset.zero,
            ).animate(curved);
            final scale = Tween<double>(begin: 0.94, end: 1).animate(curved);
            return FadeTransition(
              opacity: curved,
              child: SlideTransition(
                position: offset,
                child: ScaleTransition(scale: scale, child: child),
              ),
            );
          },
          child: KeyedSubtree(
            key: ValueKey(momentKey),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  presentation.headline,
                  style: CatchTextStyles.headline(
                    context,
                    color: stageTheme.foreground,
                  ),
                ),
                gapH10,
                Text(
                  presentation.body,
                  style: CatchTextStyles.bodyL(
                    context,
                    color: stageTheme.foreground.withValues(
                      alpha: CatchOpacity.eventSuccessProminent,
                    ),
                  ),
                ),
                gapH16,
                StagePrivacyLine(
                  text: presentation.privacyLine,
                  stageTheme: stageTheme,
                ),
                gapH20,
                content,
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class StageNav extends StatelessWidget {
  const StageNav({required this.foreground});

  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final canPop = _companionCanPop(context);
    return Row(
      children: [
        Tooltip(
          message: 'Back',
          child: CatchIconButton(
            background: foreground.withValues(alpha: CatchOpacity.subtleFill),
            onTap: canPop ? () => _popCompanion(context) : null,
            child: Icon(
              CatchIcons.arrowBackRounded,
              size: CatchIcon.md,
              color: canPop
                  ? foreground
                  : foreground.withValues(
                      alpha: CatchOpacity.eventSuccessDisabled,
                    ),
            ),
          ),
        ),
        gapW8,
        Expanded(
          child: Text(
            'Event companion',
            textAlign: TextAlign.center,
            style: CatchTextStyles.labelL(
              context,
              color: foreground.withValues(
                alpha: CatchOpacity.eventSuccessChrome,
              ),
            ),
          ),
        ),
        gapW8,
        SizedBox(
          width: CatchLayout.eventSuccessStageNavExtent,
          height: CatchLayout.eventSuccessStageNavExtent,
          child: Icon(
            CatchIcons.radioButtonCheckedRounded,
            color: foreground.withValues(alpha: CatchOpacity.eventSuccessMuted),
          ),
        ),
      ],
    );
  }
}

class CompanionHero extends StatelessWidget {
  const CompanionHero({
    required this.event,
    required this.plan,
    required this.presentation,
    required this.stageTheme,
    required this.attended,
    required this.showSelfCheckIn,
    required this.eventEnded,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventSuccessMomentPresentation presentation;
  final _CompanionStageTheme stageTheme;
  final bool attended;
  final bool showSelfCheckIn;
  final bool eventEnded;

  @override
  Widget build(BuildContext context) {
    final fg = stageTheme.foreground;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchBadge(
              label: _heroBadgeLabel(
                attended: attended,
                showSelfCheckIn: showSelfCheckIn,
                eventEnded: eventEnded,
              ),
              tone: attended ? CatchBadgeTone.success : CatchBadgeTone.live,
              icon: attended
                  ? CatchIcons.checkRounded
                  : CatchIcons.qrCode2Rounded,
              backgroundColor: fg.withValues(alpha: CatchOpacity.subtleFill),
              foregroundColor: fg,
              borderColor: fg.withValues(
                alpha: CatchOpacity.eventSuccessSubtleBorder,
              ),
            ),
            CatchBadge(
              label: presentation.badgeLabel,
              tone: presentation.badgeTone,
              icon: presentation.icon,
              backgroundColor: fg.withValues(alpha: CatchOpacity.subtleFill),
              foregroundColor: fg,
              borderColor: fg.withValues(
                alpha: CatchOpacity.eventSuccessSubtleBorder,
              ),
            ),
          ],
        ),
        gapH14,
        Text(event.title, style: CatchTextStyles.titleL(context, color: fg)),
        gapH4,
        Text(
          '${plan.playbook.title} · ${event.locationName}',
          style: CatchTextStyles.supporting(
            context,
            color: fg.withValues(alpha: CatchOpacity.eventSuccessMutedInk),
          ),
        ),
      ],
    );
  }
}

/// Animates a one-shot entry on first build, then breathes the glyph
/// continuously so the hero element never reads as static between moments.
class StageGlyph extends StatefulWidget {
  const StageGlyph({required this.stageTheme, required this.icon});

  final _CompanionStageTheme stageTheme;
  final IconData icon;

  @override
  State<StageGlyph> createState() => _StageGlyphState();
}

class _StageGlyphState extends State<StageGlyph> with TickerProviderStateMixin {
  late final AnimationController _entryController = AnimationController(
    duration: CatchMotion.slow,
    vsync: this,
  );
  late final AnimationController _breathController = AnimationController(
    duration: CatchMotion.cinematicShort,
    vsync: this,
  );

  late final Animation<double> _entry = CurvedAnimation(
    parent: _entryController,
    curve: CatchMotion.springCurve,
  );

  @override
  void initState() {
    super.initState();
    // Entry is one-shot — safe to always run. Breath repeats and would
    // deadlock pumpAndSettle, so gate it on the test guard.
    _entryController.forward();
    if (_kStageAnimationsEnabled) {
      _breathController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _entryController.dispose();
    _breathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entry, _breathController]),
      builder: (context, _) {
        final entryValue = _entry.value;
        // Smooth 0-1 sine-shaped breath so the glyph never reads as static.
        final breath = 0.5 - 0.5 * math.cos(_breathController.value * math.pi);
        final scale = (0.92 + entryValue * 0.08) + (breath * 0.02);
        final glow = 24 + (breath * 16);
        final glowAlpha = 0.20 + (breath * 0.12);
        return Transform.scale(
          scale: scale,
          child: CatchSurface(
            width: CatchLayout.eventSuccessStageGlyphExtent,
            height: CatchLayout.eventSuccessStageGlyphExtent,
            borderRadius: BorderRadius.circular(CatchRadius.pill),
            backgroundColor: widget.stageTheme.foreground.withValues(
              alpha: CatchOpacity.subtleFill,
            ),
            borderColor: widget.stageTheme.foreground.withValues(
              alpha: CatchOpacity.eventSuccessSubtleBorder,
            ),
            boxShadow: CatchElevation.glow(
              widget.stageTheme.accent.withValues(alpha: glowAlpha),
              blurRadius: glow,
            ),
            child: Icon(
              widget.icon,
              size: CatchLayout.eventSuccessStageGlyphIconSize,
              color: widget.stageTheme.foreground,
            ),
          ),
        );
      },
    );
  }
}

class StagePrivacyLine extends StatelessWidget {
  const StagePrivacyLine({required this.text, required this.stageTheme});

  final String text;
  final _CompanionStageTheme stageTheme;

  @override
  Widget build(BuildContext context) {
    return CatchSurface(
      padding: CatchInsets.contentDense,
      radius: CatchRadius.sm,
      backgroundColor: stageTheme.foreground.withValues(
        alpha: CatchOpacity.clubCoverHighlightOverlay,
      ),
      borderColor: stageTheme.foreground.withValues(
        alpha: CatchOpacity.eventSuccessPrivacyBorder,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            CatchIcons.lockOutlineRounded,
            size: 18,
            color: stageTheme.foreground.withValues(
              alpha: CatchOpacity.eventSuccessProminent,
            ),
          ),
          gapW8,
          Expanded(
            child: Text(
              text,
              style: CatchTextStyles.supporting(
                context,
                color: stageTheme.foreground.withValues(
                  alpha: CatchOpacity.eventSuccessProminent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CompanionMomentStageContent extends StatelessWidget {
  const CompanionMomentStageContent({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0) gapH12,
          children[index],
        ],
      ],
    );
  }
}

/// Ambient stage card. The border alpha breathes on a 6s sine so the surface
/// never reads as static — even when no content is changing.
class StagePanel extends StatefulWidget {
  const StagePanel({required this.child});

  final Widget child;

  @override
  State<StagePanel> createState() => _StagePanelState();
}

class _StagePanelState extends State<StagePanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    duration: CatchMotion.cinematicMedium,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    if (_kStageAnimationsEnabled) _breath.repeat(reverse: true);
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        final breath = 0.5 - 0.5 * math.cos(_breath.value * math.pi);
        return CatchSurface(
          radius: CatchRadius.sm,
          backgroundColor: t.surface.withValues(
            alpha: CatchOpacity.eventSuccessPanelFill,
          ),
          borderColor: t.surface.withValues(
            alpha:
                CatchOpacity.eventSuccessPanelBorderBase +
                breath * CatchOpacity.eventSuccessPanelBorderBreath,
          ),
          child: child!,
        );
      },
      child: Padding(padding: CatchInsets.content, child: widget.child),
    );
  }
}

class StageActionDock extends StatelessWidget {
  const StageActionDock({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      radius: CatchRadius.sm,
      backgroundColor: t.ink.withValues(
        alpha: CatchOpacity.eventSuccessActionDockFill,
      ),
      borderColor: t.surface.withValues(alpha: CatchOpacity.warningFill),
      child: Padding(padding: CatchInsets.iconChipContent, child: child),
    );
  }
}

class StageSoftBand extends StatelessWidget {
  const StageSoftBand({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      radius: CatchRadius.sm,
      backgroundColor: t.primarySoft,
      child: Padding(padding: CatchInsets.contentDense, child: child),
    );
  }
}

class _CompanionStageTheme {
  const _CompanionStageTheme({
    required this.background,
    required this.foreground,
    required this.accent,
    required this.gradient,
    required this.motif,
  });

  final Color background;
  final Color foreground;
  final Color accent;
  final Gradient gradient;
  final _StageMotif motif;

  static _CompanionStageTheme forMoment(
    BuildContext context, {
    required EventSuccessAttendeeMoment moment,
    required EventSuccessPlan plan,
  }) {
    const d = CatchTokens.sunsetDark;
    final activityPalette = ActivityPalette.of(context);
    final kinds = ActivityKind.values;

    // Pick a distinct pigment per moment kind for visual variety.
    ActivitySwatch swatchFor(EventSuccessAttendeeMomentKind k) =>
        activityPalette.forKind(kinds[k.index % kinds.length]);
    final extraSwatch = activityPalette.forKind(
      kinds[(moment.kind.index + 5) % kinds.length],
    );

    Color backgroundFor(ActivitySwatch s) => Color.alphaBlend(
      s.deep.withValues(alpha: CatchOpacity.eventSuccessStageBgBlend),
      d.bg,
    );
    Color midFor(ActivitySwatch s) => Color.alphaBlend(
      s.accent.withValues(alpha: CatchOpacity.eventSuccessStageMidBlend),
      s.deep,
    );

    final palette = switch (moment.kind) {
      EventSuccessAttendeeMomentKind.preArrival => (
        bg: backgroundFor(swatchFor(moment.kind)),
        mid: midFor(swatchFor(moment.kind)),
        accent: swatchFor(moment.kind).accent,
        motif: _StageMotif.path,
      ),
      EventSuccessAttendeeMomentKind.selfCheckIn => (
        bg: backgroundFor(swatchFor(moment.kind)),
        mid: midFor(swatchFor(moment.kind)),
        accent: swatchFor(moment.kind).accent,
        motif: _StageMotif.gate,
      ),
      EventSuccessAttendeeMomentKind.firstHelloCheckIn => (
        bg: backgroundFor(swatchFor(moment.kind)),
        mid: midFor(swatchFor(moment.kind)),
        accent: swatchFor(moment.kind).accent,
        motif: _StageMotif.signal,
      ),
      EventSuccessAttendeeMomentKind.compatibilityQuestionnaire => (
        bg: backgroundFor(swatchFor(moment.kind)),
        mid: midFor(swatchFor(moment.kind)),
        accent: swatchFor(moment.kind).accent,
        motif: _StageMotif.spark,
      ),
      EventSuccessAttendeeMomentKind.liveStepContext ||
      EventSuccessAttendeeMomentKind.socialPrompt ||
      EventSuccessAttendeeMomentKind.conversationCues => (
        bg: backgroundFor(swatchFor(moment.kind)),
        mid: midFor(swatchFor(moment.kind)),
        accent: swatchFor(moment.kind).accent,
        motif: _StageMotif.rhythm,
      ),
      EventSuccessAttendeeMomentKind.assignment => (
        bg: backgroundFor(swatchFor(moment.kind)),
        mid: midFor(swatchFor(moment.kind)),
        accent: extraSwatch.accent,
        motif: _StageMotif.orbit,
      ),
      EventSuccessAttendeeMomentKind.liveReveal => (
        bg: backgroundFor(swatchFor(moment.kind)),
        mid: midFor(swatchFor(moment.kind)),
        accent: plan.revealStatus == EventSuccessRevealStatus.revealed
            ? swatchFor(moment.kind).accent
            : extraSwatch.accent,
        motif: _StageMotif.reveal,
      ),
      EventSuccessAttendeeMomentKind.wingmanRequest => (
        bg: backgroundFor(swatchFor(moment.kind)),
        mid: midFor(swatchFor(moment.kind)),
        accent: swatchFor(moment.kind).accent,
        motif: _StageMotif.signal,
      ),
      EventSuccessAttendeeMomentKind.postEvent => (
        bg: backgroundFor(swatchFor(moment.kind)),
        mid: midFor(swatchFor(moment.kind)),
        accent: swatchFor(moment.kind).accent,
        motif: _StageMotif.afterglow,
      ),
      EventSuccessAttendeeMomentKind.none => (
        bg: d.ink,
        mid: Color.lerp(d.ink, d.primary, 0.46)!,
        accent: d.gold,
        motif: _StageMotif.path,
      ),
    };

    return _CompanionStageTheme(
      background: palette.bg,
      foreground: d.ink,
      accent: palette.accent,
      motif: palette.motif,
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          palette.bg,
          Color.lerp(palette.bg, palette.mid, 0.72)!,
          palette.mid,
        ],
      ),
    );
  }
}

enum _StageMotif { path, gate, spark, rhythm, orbit, reveal, signal, afterglow }

/// Drives a continuous `phase` (0→1, looping) into [_StageMotifPainter] so the
/// stage background is perpetually alive — orbits rotate, sparks drift, rhythm
/// waves breathe, paths scroll. Loop period is intentionally long (16s) so
/// motion reads as ambient, not busy.
class AnimatedStageMotifBackground extends StatefulWidget {
  const AnimatedStageMotifBackground({
    required this.accent,
    required this.foreground,
    required this.motif,
  });

  final Color accent;
  final Color foreground;
  final _StageMotif motif;

  @override
  State<AnimatedStageMotifBackground> createState() =>
      _AnimatedStageMotifBackgroundState();
}

class _AnimatedStageMotifBackgroundState
    extends State<AnimatedStageMotifBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: CatchMotion.ambientLoop,
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    if (_kStageAnimationsEnabled) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return CustomPaint(
            painter: _StageMotifPainter(
              accent: widget.accent,
              foreground: widget.foreground,
              motif: widget.motif,
              phase: _controller.value,
            ),
          );
        },
      ),
    );
  }
}

class _StageMotifPainter extends CustomPainter {
  const _StageMotifPainter({
    required this.accent,
    required this.foreground,
    required this.motif,
    required this.phase,
  });

  final Color accent;
  final Color foreground;
  final _StageMotif motif;

  /// 0→1, loops every animation cycle. Used per-motif to drive rotation,
  /// drift, and pulse so the surface is never static.
  final double phase;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = foreground.withValues(
        alpha: CatchOpacity.eventSuccessMotifBase,
      );
    final accentPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..color = accent.withValues(alpha: CatchOpacity.eventSuccessMotifAccent);

    final twoPi = math.pi * 2;
    // Two phase rotations let secondary motion lead/lag the primary, giving
    // the surface depth without doubling the Ticker rate.
    final phaseA = phase * twoPi;
    final phaseB = (phase * twoPi * 0.6) + (math.pi / 3);

    switch (motif) {
      case _StageMotif.path:
      case _StageMotif.gate:
        // Diagonal filaments scroll along their length so the room reads as
        // moving forward instead of stationary.
        for (var i = 0; i < 5; i++) {
          final scroll = (phase + i * 0.18) % 1.0;
          final top = size.height * (0.18 + i * 0.12) + scroll * 18 - 9;
          canvas.drawLine(
            Offset(size.width * -0.08, top),
            Offset(size.width * 1.06, top + size.height * 0.18),
            i == 1 ? accentPaint : paint,
          );
        }
      case _StageMotif.spark:
      case _StageMotif.signal:
        // Sparks pulse alpha and drift along a slow loop. Each spark has its
        // own phase offset so the field shimmers rather than blinks in unison.
        for (var i = 0; i < 18; i++) {
          final baseX = size.width * (((i * 37) % 100) / 100);
          final baseY = size.height * (((i * 61) % 100) / 100);
          final localPhase = (phase + i * 0.057) % 1.0;
          final dx = math.cos(localPhase * twoPi) * 6;
          final dy = math.sin(localPhase * twoPi) * 4;
          final alpha =
              0.10 + 0.14 * (0.5 + 0.5 * math.sin(localPhase * twoPi));
          canvas.drawCircle(
            Offset(baseX + dx, baseY + dy),
            i.isEven ? 2.5 : 1.4,
            Paint()
              ..color = (i.isEven ? accent : foreground).withValues(
                alpha: alpha,
              ),
          );
        }
      case _StageMotif.rhythm:
        // Rhythm waves phase-shift so the curves swell and recede — like the
        // room is breathing in time.
        final path = Path();
        final swell = math.sin(phaseA) * 12;
        for (var i = 0; i < 4; i++) {
          final y = size.height * (0.28 + i * 0.14);
          final lead = math.sin(phaseA + i * 0.7) * 24;
          path
            ..moveTo(0, y)
            ..cubicTo(
              size.width * 0.24,
              y - 54 + lead,
              size.width * 0.56,
              y + 54 + swell,
              size.width,
              y - lead * 0.4,
            );
        }
        canvas.drawPath(path, paint);
      case _StageMotif.orbit:
      case _StageMotif.reveal:
      case _StageMotif.afterglow:
        // Orbits and reveal radii rotate counter-pulse so the eye sees depth.
        // Ring thicknesses subtly pulse to read as "alive."
        final center = Offset(size.width * 0.72, size.height * 0.28);
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(phaseA * 0.35);
        for (var i = 0; i < 5; i++) {
          final radius = 72 + i * 46;
          final pulse = 1.0 + 0.02 * math.sin(phaseB + i * 0.7);
          canvas.drawCircle(
            Offset.zero,
            radius * pulse,
            i == 2 ? accentPaint : paint,
          );
        }
        canvas.restore();
        if (motif == _StageMotif.reveal) {
          // Radial spokes accelerate on the second half of the loop, hinting
          // at the anticipation feel the cinematic reveal will land on.
          final accel = 0.6 + 0.6 * math.sin(phaseA * 0.5).abs();
          for (var i = 0; i < 10; i++) {
            final angle = (twoPi / 10) * i + phaseA * accel * 0.4;
            final start = Offset(
              center.dx + math.cos(angle) * 48,
              center.dy + math.sin(angle) * 48,
            );
            final end = Offset(
              center.dx + math.cos(angle) * 180,
              center.dy + math.sin(angle) * 180,
            );
            canvas.drawLine(start, end, accentPaint);
          }
        }
        if (motif == _StageMotif.afterglow) {
          // Afterglow gets a soft inner halo that breathes slowly, signaling
          // the night winding down rather than ramping up.
          final haloAlpha = 0.06 + 0.04 * math.sin(phaseA * 0.5);
          canvas.drawCircle(
            center,
            120,
            Paint()..color = accent.withValues(alpha: haloAlpha),
          );
        }
    }
  }

  @override
  bool shouldRepaint(covariant _StageMotifPainter oldDelegate) =>
      oldDelegate.accent != accent ||
      oldDelegate.foreground != foreground ||
      oldDelegate.motif != motif ||
      oldDelegate.phase != phase;
}

class EventSuccessMomentPresentation {
  EventSuccessMomentPresentation({
    required this.badgeLabel,
    required this.headline,
    required this.body,
    required this.privacyLine,
    required this.icon,
    required this.badgeTone,
    this.effectKind,
    this.ambientBed = EventSuccessAmbientBed.theatrical,
  });

  final String badgeLabel;
  final String headline;
  final String body;
  final String privacyLine;
  final IconData icon;
  final CatchBadgeTone badgeTone;
  final EventSuccessLiveEffectKind? effectKind;
  final EventSuccessAmbientBed ambientBed;

  static EventSuccessMomentPresentation forMoment({
    required Event event,
    required EventSuccessPlan plan,
    required EventSuccessAttendeeMoment moment,
    required bool attended,
    required bool showSelfCheckIn,
    required bool eventEnded,
  }) {
    final step = moment.activeStep;
    return switch (moment.kind) {
      EventSuccessAttendeeMomentKind.preArrival => EventSuccessMomentPresentation(
        badgeLabel: 'Before arrival',
        headline: 'Your event guide is warming up.',
        body:
            'When check-in opens, this screen turns into the live guide for ${event.locationName}.',
        privacyLine:
            'Pre-event details stay informational until the host starts the room.',
        icon: CatchIcons.eventAvailableOutlined,
        badgeTone: CatchBadgeTone.live,
        effectKind: EventSuccessLiveEffectKind.liveEntry,
      ),
      EventSuccessAttendeeMomentKind.selfCheckIn =>
        EventSuccessMomentPresentation(
          badgeLabel: 'Arrival cue',
          headline: 'Check in when you reach the venue.',
          body:
              'One tap tells the host you are in the room and ready for the live flow.',
          privacyLine:
              'Check-in only updates attendance and the event companion flow.',
          icon: CatchIcons.qrCode2Rounded,
          badgeTone: CatchBadgeTone.warning,
          effectKind: EventSuccessLiveEffectKind.liveEntry,
        ),
      EventSuccessAttendeeMomentKind.firstHelloCheckIn =>
        EventSuccessMomentPresentation(
          badgeLabel: 'First Hello',
          headline: 'Your first arrival mission is live.',
          body:
              'Find one person, ask one tiny question, and let the room start with permission instead of pressure.',
          privacyLine:
              'This checks you in. Hosts do not see the individual answer.',
          icon: CatchIcons.wavingHandOutlined,
          badgeTone: CatchBadgeTone.brand,
          effectKind: EventSuccessLiveEffectKind.liveEntry,
        ),
      EventSuccessAttendeeMomentKind.compatibilityQuestionnaire =>
        EventSuccessMomentPresentation(
          badgeLabel: 'Match clues',
          headline: 'Add a few clues before the room moves.',
          body:
              'Quick answers help Catch shape prompts without turning the event into a form.',
          privacyLine: 'Hosts do not see individual match clue answers.',
          icon: CatchIcons.tuneRounded,
          badgeTone: CatchBadgeTone.brand,
          effectKind: EventSuccessLiveEffectKind.liveEntry,
        ),
      EventSuccessAttendeeMomentKind.liveStepContext =>
        EventSuccessMomentPresentation(
          badgeLabel: step?.stage.label ?? 'Live now',
          headline: step?.title ?? 'Follow the host for the next beat.',
          body:
              step?.attendeeExperience ??
              'The host is pacing the room from live mode.',
          privacyLine:
              'Everyone sees the same room cue; personal details stay scoped to you.',
          icon: CatchIcons.locationOnOutlined,
          badgeTone: CatchBadgeTone.live,
          effectKind: EventSuccessLiveEffectKind.stepChange,
          ambientBed: EventSuccessAmbientBed.pulse,
        ),
      EventSuccessAttendeeMomentKind.socialPrompt =>
        EventSuccessMomentPresentation(
          badgeLabel: step?.stage.label ?? 'Live prompt',
          headline: 'A fresh prompt just dropped.',
          body:
              step?.attendeeExperience ??
              'Use it if the room needs an easy next line.',
          privacyLine:
              'Prompts are shared guidance, not a public record of what you say.',
          icon: CatchIcons.chatBubbleOutlineRounded,
          badgeTone: CatchBadgeTone.live,
          effectKind: EventSuccessLiveEffectKind.stepChange,
          ambientBed: EventSuccessAmbientBed.pulse,
        ),
      EventSuccessAttendeeMomentKind.conversationCues =>
        EventSuccessMomentPresentation(
          badgeLabel: step?.stage.label ?? 'Conversation cues',
          headline: 'Pick a cue and keep the room moving.',
          body:
              step?.attendeeExperience ??
              'These are light nudges for the current event moment.',
          privacyLine:
              'Conversation cues are suggestions only; nothing is sent for you.',
          icon: CatchIcons.forumOutlined,
          badgeTone: CatchBadgeTone.live,
          effectKind: EventSuccessLiveEffectKind.stepChange,
          ambientBed: EventSuccessAmbientBed.pulse,
        ),
      EventSuccessAttendeeMomentKind.assignment => EventSuccessMomentPresentation(
        badgeLabel: 'Your next group',
        headline: 'Your assignment is ready.',
        body:
            'Use it as a nudge into the next interaction, then let the room breathe.',
        privacyLine: 'Only your own assignment details appear on this screen.',
        icon: CatchIcons.groups2Outlined,
        badgeTone: CatchBadgeTone.success,
        effectKind: EventSuccessLiveEffectKind.stepChange,
        ambientBed: EventSuccessAmbientBed.pulse,
      ),
      EventSuccessAttendeeMomentKind.liveReveal => EventSuccessMomentPresentation(
        badgeLabel: 'Shared reveal',
        headline: _revealHeroHeadline(moment, plan),
        body:
            'The host controls the timing so the room unlocks together instead of leaking awkwardly.',
        privacyLine:
            'Your details stay hidden on this screen until the shared reveal moment.',
        icon: CatchIcons.boltRounded,
        badgeTone: CatchBadgeTone.live,
        effectKind: _revealHeroEffect(plan),
        // Cinematic owns the soundscape during anticipation/climax; the bed
        // resumes from the next moment's vibe.
        ambientBed: EventSuccessAmbientBed.silent,
      ),
      EventSuccessAttendeeMomentKind.wingmanRequest =>
        EventSuccessMomentPresentation(
          badgeLabel: 'Host help',
          headline: 'Ask for one specific intro.',
          body:
              'Choose someone you want help meeting and the host can use that as live facilitation context.',
          privacyLine:
              'Only the host sees this request; the other attendee is not notified.',
          icon: CatchIcons.volunteerActivismOutlined,
          badgeTone: CatchBadgeTone.brand,
          effectKind: EventSuccessLiveEffectKind.stepChange,
          ambientBed: EventSuccessAmbientBed.pulse,
        ),
      EventSuccessAttendeeMomentKind.postEvent => EventSuccessMomentPresentation(
        badgeLabel: 'Afterglow',
        headline: 'Your afterglow is ready.',
        body:
            'Keep the useful parts of the room, send private feedback, and use event-specific openers when a match appears.',
        privacyLine:
            'This recap is private to you. Hosts only see safe aggregate coaching.',
        icon: CatchIcons.nightlightRound,
        badgeTone: CatchBadgeTone.success,
        effectKind: EventSuccessLiveEffectKind.guideComplete,
        ambientBed: EventSuccessAmbientBed.sunrise,
      ),
      EventSuccessAttendeeMomentKind.none => EventSuccessMomentPresentation(
        badgeLabel: eventEnded
            ? 'Wrapped'
            : attended
            ? 'Live now'
            : 'Booked',
        headline: _heroOrientationLine(
          event: event,
          attended: attended,
          showSelfCheckIn: showSelfCheckIn,
          eventEnded: eventEnded,
        ),
        body:
            'The host is running the room. Your next prompt or reveal appears here when it is time.',
        privacyLine:
            'Catch only shows the live details that are relevant to this event moment.',
        icon: CatchIcons.eventOutlined,
        badgeTone: CatchBadgeTone.neutral,
        effectKind: attended ? EventSuccessLiveEffectKind.liveEntry : null,
        ambientBed: eventEnded
            ? EventSuccessAmbientBed.sunrise
            : EventSuccessAmbientBed.theatrical,
      ),
    };
  }
}

String _revealHeroHeadline(
  EventSuccessAttendeeMoment moment,
  EventSuccessPlan plan,
) {
  if (plan.revealStatus == EventSuccessRevealStatus.revealed) {
    if (moment.assignmentModuleId ==
        EventSuccessModuleCatalog.guidedRotations.id) {
      return 'Your rotation just unlocked.';
    }
    return 'Your group just unlocked.';
  }
  if (moment.assignmentModuleId ==
      EventSuccessModuleCatalog.guidedRotations.id) {
    return 'A rotation reveal is in motion.';
  }
  return 'A group reveal is in motion.';
}

EventSuccessLiveEffectKind _revealHeroEffect(EventSuccessPlan plan) {
  if (plan.revealStatus == EventSuccessRevealStatus.revealed) {
    return EventSuccessLiveEffectKind.assignmentRevealed;
  }
  return EventSuccessLiveEffectKind.countdownStart;
}

String _heroBadgeLabel({
  required bool attended,
  required bool showSelfCheckIn,
  required bool eventEnded,
}) {
  if (attended && eventEnded) return 'Event done';
  if (attended) return 'Checked in';
  if (showSelfCheckIn) return 'Check in open';
  return 'Booked';
}

String _heroOrientationLine({
  required Event event,
  required bool attended,
  required bool showSelfCheckIn,
  required bool eventEnded,
}) {
  if (attended && eventEnded) {
    return 'Thanks for coming. A quick feedback prompt is below.';
  }
  if (attended) {
    return 'You\'re in. Watch this screen for prompts and partner reveals.';
  }
  if (showSelfCheckIn) {
    return 'Glad you\'re coming. Check in when you arrive at ${event.locationName}.';
  }
  return 'Glad you\'re coming. We\'ll guide you here once check-in opens.';
}

class CompanionStageContentTransition extends StatelessWidget {
  const CompanionStageContentTransition({
    required this.momentKey,
    required this.child,
  });

  final String momentKey;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: CatchMotion.slow,
      switchInCurve: CatchMotion.standardCurve,
      switchOutCurve: CatchMotion.easeInCubicCurve,
      transitionBuilder: (child, animation) {
        final fade = CurvedAnimation(
          parent: animation,
          curve: CatchMotion.standardCurve,
        );
        final offset = Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(fade);
        final scale = Tween<double>(begin: 0.96, end: 1).animate(fade);
        return FadeTransition(
          opacity: fade,
          child: SlideTransition(
            position: offset,
            child: ScaleTransition(scale: scale, child: child),
          ),
        );
      },
      child: KeyedSubtree(key: ValueKey(momentKey), child: child),
    );
  }
}

/// Who else can see this card's data. Surfaces a consistent badge across
/// questionnaire, wingman, and feedback so the attendee can tell at a glance
/// what they're putting on the record.
enum _PrivacyAudience { privateToYou, hostCanSee, catchPrivate }

class PrivacyBadge extends StatelessWidget {
  const PrivacyBadge(this.audience);

  final _PrivacyAudience audience;

  @override
  Widget build(BuildContext context) {
    return switch (audience) {
      _PrivacyAudience.privateToYou => CatchBadge(
        label: 'Private to you',
        icon: CatchIcons.lockOutlineRounded,
      ),
      _PrivacyAudience.hostCanSee => CatchBadge(
        label: 'Host can see',
        icon: CatchIcons.visibilityOutlined,
      ),
      _PrivacyAudience.catchPrivate => CatchBadge(
        label: 'Catch private',
        icon: CatchIcons.shieldOutlined,
      ),
    };
  }
}

/// Gives the wrapped widget a kinetic press response: scale down on tap-down,
/// brief glow flare, then a spring-back to rest. Drop-in replacement for
/// InkWell-style affordances on the stage where Material's ink ripple feels
/// out of place against the gradient + motif backdrop.
class StageBouncyPress extends StatefulWidget {
  const StageBouncyPress({
    required this.child,
    required this.onTap,
    this.glowColor,
    this.borderRadius,
    this.semanticLabel,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? glowColor;
  final BorderRadius? borderRadius;
  final String? semanticLabel;

  /// How deep the press depresses. 1.0 = no scale, 0 = scale to zero.
  /// Tuned for chips and small CTAs; keep static for now.
  static const double _minScale = 0.94;

  @override
  State<StageBouncyPress> createState() => _StageBouncyPressState();
}

class _StageBouncyPressState extends State<StageBouncyPress>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: CatchMotion.base,
    vsync: this,
  );

  late final Animation<double> _press = TweenSequence<double>([
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 0,
        end: 1,
      ).chain(CurveTween(curve: CatchMotion.easeOutCurve)),
      weight: 35,
    ),
    TweenSequenceItem(
      tween: Tween<double>(
        begin: 1,
        end: 0,
      ).chain(CurveTween(curve: CatchMotion.elasticOutCurve)),
      weight: 65,
    ),
  ]).animate(_controller);

  bool _down = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _runPress() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final glow = widget.glowColor ?? t.primary;
    final enabled = widget.onTap != null;
    return Semantics(
      button: enabled,
      enabled: enabled,
      label: widget.semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _down = true) : null,
        onTapCancel: enabled ? () => setState(() => _down = false) : null,
        onTap: enabled
            ? () {
                setState(() => _down = false);
                _runPress();
                widget.onTap?.call();
              }
            : null,
        child: AnimatedBuilder(
          animation: _press,
          builder: (context, child) {
            // 0 at rest, 1 at deepest press. Mix held-down state into the curve
            // so dragging a finger off-target still releases visually.
            final press = _down ? 1.0 : _press.value;
            final scale =
                1.0 -
                (1.0 - StageBouncyPress._minScale) * press.clamp(0.0, 1.0);
            // Glow flare follows press up then decays through the elastic
            // release for a satisfying tail.
            final flare = _down ? 0.0 : (_press.value * (1 - _press.value) * 4);
            return Transform.scale(
              scale: scale,
              child: CatchSurface(
                tone: CatchSurfaceTone.transparent,
                borderRadius: widget.borderRadius,
                boxShadow: flare > CatchOpacity.controlOverlayHover
                    ? CatchElevation.glow(
                        glow.withValues(
                          alpha: CatchOpacity.eventSuccessBouncyGlow * flare,
                        ),
                        blurRadius:
                            CatchLayout.eventSuccessBouncyGlowBlur * flare,
                        spreadRadius: CatchStroke.underline * flare,
                      )
                    : CatchElevation.none,
                child: child!,
              ),
            );
          },
          child: widget.child,
        ),
      ),
    );
  }
}

/// Stage-native chip that mirrors `CatchChip`'s active/inactive styling but
/// uses [StageBouncyPress] for tactile feedback instead of Material ink.
class StageBouncyChip extends StatelessWidget {
  const StageBouncyChip({
    required this.label,
    required this.active,
    required this.onTap,
  });

  final String label;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final background = active ? t.ink : t.surface;
    final foreground = active ? t.surface : t.ink;
    final border = active
        ? t.surface.withValues(alpha: CatchOpacity.none)
        : t.line2;
    final radius = BorderRadius.circular(CatchRadius.pill);
    return StageBouncyPress(
      onTap: onTap,
      glowColor: t.primary,
      borderRadius: radius,
      semanticLabel: label,
      child: CatchSurface(
        borderRadius: radius,
        backgroundColor: background,
        borderColor: border,
        padding: _companionStagePillPadding,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.sectionTitle(context, color: foreground),
        ),
      ),
    );
  }
}

/// Live co-presence ring shown on arrival-class moments. Reads
/// `Event.checkedInCount` (denormalized + maintained by Cloud Functions, so
/// it updates in real time via the existing event listener — no separate
/// Firestore reads). Renders anonymous dots around a center count, with a
/// brief scale-pulse when the count climbs.
class LiveArrivalRing extends StatefulWidget {
  const LiveArrivalRing({
    required this.checkedInCount,
    required this.stageTheme,
  });

  final int checkedInCount;
  final _CompanionStageTheme stageTheme;

  @override
  State<LiveArrivalRing> createState() => _LiveArrivalRingState();
}

class _LiveArrivalRingState extends State<LiveArrivalRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    duration: CatchMotion.pulse,
    vsync: this,
  );

  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _lastCount = widget.checkedInCount;
  }

  @override
  void didUpdateWidget(covariant LiveArrivalRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checkedInCount > _lastCount && _kStageAnimationsEnabled) {
      _pulse.forward(from: 0);
    }
    _lastCount = widget.checkedInCount;
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.stageTheme;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        // 0 at rest → 1 at peak. Sine-shaped curve gives a soft "heartbeat"
        // when a new check-in arrives.
        final pulse = math.sin(_pulse.value * math.pi);
        final scale = 1.0 + pulse * 0.08;
        return Transform.scale(scale: scale, child: child);
      },
      child: ArrivalRingCard(
        checkedInCount: widget.checkedInCount,
        stageTheme: theme,
      ),
    );
  }
}

class ArrivalRingCard extends StatelessWidget {
  const ArrivalRingCard({
    required this.checkedInCount,
    required this.stageTheme,
  });

  final int checkedInCount;
  final _CompanionStageTheme stageTheme;

  @override
  Widget build(BuildContext context) {
    final fg = stageTheme.foreground;
    final hasArrivals = checkedInCount > 0;
    final caption = hasArrivals
        ? (checkedInCount == 1 ? 'person here so far' : 'people here so far')
        : 'waiting for the room to fill';
    return SizedBox(
      width: CatchLayout.eventSuccessArrivalRingExtent,
      height: CatchLayout.eventSuccessArrivalRingExtent,
      child: CustomPaint(
        painter: _ArrivalRingPainter(
          dotCount: math.min(checkedInCount, 24),
          activeAccent: stageTheme.accent,
          dimForeground: fg.withValues(
            alpha: CatchOpacity.eventSuccessSubtleBorder,
          ),
          accentForeground: fg.withValues(
            alpha: CatchOpacity.eventSuccessArrivalAccent,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: CatchLayout.eventSuccessArrivalRingInnerPadding,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$checkedInCount',
                  style: CatchTextStyles.headlineS(context, color: fg).copyWith(
                    height: 1.0,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                gapH2,
                Text(
                  caption,
                  textAlign: TextAlign.center,
                  style: CatchTextStyles.labelS(
                    context,
                    color: fg.withValues(
                      alpha: CatchOpacity.eventSuccessArrivalCaption,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact co-presence indicator. Tells the attendee they're not in here
/// alone, with a brief alpha-pulse the moment the count climbs. Used on
/// solo-feeling surfaces (questionnaire, eventually First Hello / wingman).
class LiveOthersInRoomLine extends StatefulWidget {
  const LiveOthersInRoomLine({required this.checkedInCount});

  final int checkedInCount;

  @override
  State<LiveOthersInRoomLine> createState() => _LiveOthersInRoomLineState();
}

class _LiveOthersInRoomLineState extends State<LiveOthersInRoomLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    duration: CatchMotion.pulse,
    vsync: this,
  );

  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _lastCount = widget.checkedInCount;
  }

  @override
  void didUpdateWidget(covariant LiveOthersInRoomLine oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.checkedInCount > _lastCount && _kStageAnimationsEnabled) {
      _pulse.forward(from: 0);
    }
    _lastCount = widget.checkedInCount;
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final count = widget.checkedInCount;
    // Anonymous-dot icon track: visualises co-presence without exposing
    // anyone's identity.
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, _) {
        final pulse = math.sin(_pulse.value * math.pi);
        final glowAlpha =
            CatchOpacity.eventSuccessRoomGlowBase +
            pulse * CatchOpacity.eventSuccessRoomGlowPulse;
        return CatchSurface(
          radius: CatchRadius.pill,
          backgroundColor: t.primarySoft,
          borderColor: t.primary.withValues(alpha: glowAlpha),
          child: Padding(
            padding: CatchInsets.compactControlContent,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CatchIcons.groups3Outlined,
                  size: CatchIcon.xs,
                  color: t.primary,
                ),
                gapW6,
                Flexible(
                  child: Text(
                    count == 1
                        ? '1 person is checked in alongside you'
                        : '$count people in the room with you',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.labelL(context, color: t.ink),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ArrivalRingPainter extends CustomPainter {
  const _ArrivalRingPainter({
    required this.dotCount,
    required this.activeAccent,
    required this.dimForeground,
    required this.accentForeground,
  });

  final int dotCount;
  final Color activeAccent;
  final Color dimForeground;
  final Color accentForeground;

  // Always paint 24 dot slots so the ring shape reads even with few
  // arrivals — filled dots represent attendees, dim dots represent slots
  // still empty.
  static const int _slotCount = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) * 0.42;
    for (var i = 0; i < _slotCount; i++) {
      final angle = (math.pi * 2 / _slotCount) * i - math.pi / 2;
      final position = Offset(
        center.dx + math.cos(angle) * radius,
        center.dy + math.sin(angle) * radius,
      );
      final filled = i < dotCount;
      final isHighlight = filled && (i % 6 == 0);
      final color = isHighlight
          ? activeAccent.withValues(
              alpha: CatchOpacity.eventSuccessArrivalHighlight,
            )
          : filled
          ? accentForeground
          : dimForeground;
      canvas.drawCircle(position, filled ? 3.4 : 2.0, Paint()..color = color);
    }
  }

  @override
  bool shouldRepaint(covariant _ArrivalRingPainter oldDelegate) =>
      oldDelegate.dotCount != dotCount ||
      oldDelegate.activeAccent != activeAccent ||
      oldDelegate.dimForeground != dimForeground ||
      oldDelegate.accentForeground != accentForeground;
}

class NoCompanionActionsCard extends StatelessWidget {
  const NoCompanionActionsCard();

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return StagePanel(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(CatchIcons.eventOutlined, color: t.primary),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'The host is running the room',
                  style: CatchTextStyles.sectionTitle(context),
                ),
                gapH4,
                Text(
                  'Your next prompt or partner reveal will show up here.',
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
