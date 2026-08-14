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
  const CompanionStageScaffold._({
    required this.event,
    required this.plan,
    required this.presentation,
    required this._stageTheme,
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
  final _CompanionStageTheme _stageTheme;
  final bool attended;
  final bool showSelfCheckIn;
  final bool eventEnded;
  final String momentKey;
  final EventSuccessAttendeeMomentKind momentKind;
  final DateTime referenceNow;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final stageTheme = _stageTheme;
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
                child: AnimatedStageMotifBackground._(
                  accent: stageTheme.accent,
                  foreground: stageTheme.foreground,
                  visualAsset: stageTheme.visualAsset,
                  idlePulsePeriodMs:
                      presentation.choreography.idlePulsePeriodMs,
                ),
              ),
            ),
            // Sits between motif background and content. Renders nothing
            // when not in the reveal moment, so other beats are untouched.
            Positioned.fill(
              child: RevealCinematicOverlay._(
                eventId: event.id,
                plan: plan,
                presentation: presentation.choreography,
                referenceNow: referenceNow,
                momentKind: momentKind,
                stageTheme: stageTheme,
                checkedInCount: event.checkedInCount ?? 0,
                tickInterval: eventSuccessCeremonyTickInterval,
              ),
            ),
            SafeArea(
              child: CatchFillViewportScrollView(
                scrollViewKey: EventSuccessCompanionKeys.scrollView,
                maxContentWidth: CatchLayout.maxContentWidth,
                padding: _companionMomentStagePadding,
                child: CompanionMomentStage._(
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
          ],
        ),
      ),
    );
  }
}

class CompanionPaperScaffold extends StatelessWidget {
  const CompanionPaperScaffold({
    super.key,
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
  final Future<void> Function(String venueSessionToken) onSelfCheckIn;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      key: const ValueKey('eventSuccessCompanionPaper'),
      backgroundColor: t.bg,
      bottomNavigationBar: showSelfCheckIn
          ? SafeArea(
              minimum: CatchInsets.pageBody.copyWith(
                top: CatchSpacing.s2,
                bottom: CatchSpacing.s3,
              ),
              child: PaperSelfCheckInBar(
                event: event,
                actionState: selfCheckInActionState,
                onSelfCheckIn: onSelfCheckIn,
              ),
            )
          : null,
      body: SafeArea(
        child: CatchFillViewportScrollView(
          scrollViewKey: EventSuccessCompanionKeys.scrollView,
          maxContentWidth: CatchLayout.maxContentWidth,
          padding: CatchInsets.pageBody.copyWith(
            top: CatchSpacing.s2,
            bottom: CatchSpacing.s8,
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
    );
  }
}

class PaperCompanionNav extends StatelessWidget {
  const PaperCompanionNav({super.key, required this.plan});

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
                context
                    .l10n
                    .eventSuccessEventSuccessCompanionSharedTextEventCompanion,
                textAlign: TextAlign.center,
                style: CatchTextStyles.fieldRowTitle(context),
              ),
            ),
            gapW8,
            SizedBox(
              width: CatchLayout.eventSuccessStageNavExtent,
              child: Text(
                context.l10n
                    .eventSuccessEventSuccessCompanionSharedTextPadleftTotalsteps(
                      padLeft: activeStep.toString().padLeft(2, '0'),
                      totalSteps: totalSteps,
                    ),
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
  const PaperProgressRail({
    super.key,
    required this.active,
    required this.total,
  });

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
            child: CatchSurface(
              backgroundColor: index < active ? t.primary : t.line2,
              radius: CatchRadius.pill,
              height: CatchSpacing.micro3,
              padding: EdgeInsets.zero,
              duration: Duration.zero,
              child: const SizedBox.expand(),
            ),
          ),
          if (index != count - 1) gapW4,
        ],
      ],
    );
  }
}

class PaperCompanionTicket extends StatelessWidget {
  const PaperCompanionTicket({
    super.key,
    required this.event,
    required this.plan,
  });

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
          context
              .l10n
              .eventSuccessEventSuccessCompanionSharedTextYourTicketToday,
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
                          label: context
                              .l10n
                              .eventSuccessEventSuccessCompanionSharedLabelWhen,
                          value: _paperTicketTime(event),
                        ),
                      ),
                      gapW12,
                      Expanded(
                        child: PaperTicketDetail(
                          label: context
                              .l10n
                              .eventSuccessEventSuccessCompanionSharedLabelWhere,
                          value: event.locationName,
                        ),
                      ),
                      gapW12,
                      Expanded(
                        child: PaperTicketDetail(
                          label: context
                              .l10n
                              .eventSuccessEventSuccessCompanionSharedLabelEntry,
                          value: event.isFree
                              ? context
                                    .l10n
                                    .eventSuccessEventSuccessCompanionSharedVisiblecopyFree
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
                  padding: CatchInsets.contentBlock,
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
    super.key,
    required this.event,
    required this.plan,
    required this.swatch,
  });

  final Event event;
  final EventSuccessPlan plan;
  final ActivitySwatch swatch;

  @override
  Widget build(BuildContext context) {
    final foreground = CatchTokens.editorialWhite;
    return CatchSurface(
      radius: CatchRadius.none,
      backgroundColor: swatch.deep,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _PaperTicketHeaderPainter(
                lineColor: swatch.accent.withValues(
                  alpha: CatchOpacity.eventSuccessPaperLine,
                ),
                markColor: foreground.withValues(
                  alpha: CatchOpacity.eventSuccessPaperMark,
                ),
              ),
            ),
          ),
          Padding(
            padding: CatchInsets.paperTicketHeader,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n
                      .eventSuccessEventSuccessCompanionSharedTextTitleLocationname(
                        title: plan.playbook.title,
                        locationName: event.locationName,
                      )
                      .toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.sectionTitle(
                    context,
                    color: foreground.withValues(
                      alpha: CatchOpacity.eventSuccessProminent,
                    ),
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
  const PaperTicketDetail({
    super.key,
    required this.label,
    required this.value,
  });

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
  const PaperTicketPerforation({super.key});

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
  const PaperTicketSerial({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final booked = event.bookedCount ?? 0;
    final capacity = event.capacityLimit;
    final label = context.l10n
        .eventSuccessEventSuccessCompanionSharedLabelAdmitOneNoPadleft(
          padLeft: booked.toString().padLeft(2, '0'),
          capacity: capacity,
        );
    final value = _paperTicketCode(event);

    return PaperTicketDetail(label: label, value: value);
  }
}

class PaperBarcode extends StatelessWidget {
  const PaperBarcode({super.key});

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
    super.key,
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
      l10n: context.l10n,
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
            label: context
                .l10n
                .eventSuccessEventSuccessCompanionSharedLabelWhatToExpect,
            color: t.primary,
          ),
          gapH12,
          for (final item in items) ...[
            PaperExpectationRow._(item: item),
            if (item != items.last) gapH12,
          ],
        ],
      ),
    );
  }
}

class PaperExpectationRow extends StatelessWidget {
  const PaperExpectationRow._({required this._item});

  final _PaperExpectationItem _item;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final item = _item;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: CatchInsets.inlineIconTopTight,
          child: Icon(item.icon, size: CatchIcon.sm, color: t.ink3),
        ),
        gapW12,
        Expanded(
          child: Text(item.label, style: CatchTextStyles.supporting(context)),
        ),
      ],
    );
  }
}

class PaperPrivacyCard extends StatelessWidget {
  const PaperPrivacyCard({super.key, required this.text});

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
    super.key,
    required this.event,
    required this.actionState,
    required this.onSelfCheckIn,
  });

  final Event event;
  final SelfCheckInActionState actionState;
  final Future<void> Function(String venueSessionToken) onSelfCheckIn;

  @override
  Widget build(BuildContext context) {
    return CatchButton(
      label:
          context.l10n.eventSuccessEventSuccessCompanionSharedLabelIMHereCheck,
      icon: Icon(CatchIcons.locationOnOutlined),
      isLoading: actionState.isCheckingIn,
      onPressed: actionState.isCheckingIn
          ? null
          : () => unawaited(_scanAndCheckIn(context)),
      fullWidth: true,
      size: CatchButtonSize.lg,
    );
  }

  Future<void> _scanAndCheckIn(BuildContext context) async {
    final venueSessionToken = await showCatchBottomSheet<String>(
      context: context,
      builder: (context) => EventCheckInQrScannerSheet(eventId: event.id),
    );
    if (venueSessionToken != null && context.mounted) {
      await onSelfCheckIn(venueSessionToken);
    }
  }
}

class _PaperExpectationItem {
  const _PaperExpectationItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

List<_PaperExpectationItem> _paperExpectationItems({
  required AppLocalizations l10n,
  required Event event,
  required EventSuccessPlan plan,
  required bool showSelfCheckIn,
  required bool eventEnded,
}) {
  if (eventEnded) {
    return [
      _PaperExpectationItem(
        icon: CatchIcons.favoriteBorderRounded,
        label:
            l10n.eventSuccessEventSuccessCompanionSharedLabelPostEventFollowUp,
      ),
      _PaperExpectationItem(
        icon: CatchIcons.chatBubbleOutlineRounded,
        label: l10n
            .eventSuccessEventSuccessCompanionSharedLabelConversationStartersStayPrivate,
      ),
    ];
  }
  return [
    _PaperExpectationItem(
      icon: showSelfCheckIn
          ? CatchIcons.locationOnOutlined
          : CatchIcons.groups2Outlined,
      label: showSelfCheckIn
          ? l10n.eventSuccessEventSuccessCompanionSharedLabelCheckInWhenYou(
              locationName: event.locationName,
            )
          : l10n.eventSuccessEventSuccessCompanionSharedLabelASmallStarterGroup,
    ),
    if (plan.hasModule(EventSuccessModuleCatalog.guidedRotations.id))
      _PaperExpectationItem(
        icon: CatchIcons.syncAltRounded,
        label: l10n
            .eventSuccessEventSuccessCompanionSharedLabelTimedPartnerRotationsAs,
      )
    else
      _PaperExpectationItem(
        icon: CatchIcons.forumOutlined,
        label: l10n
            .eventSuccessEventSuccessCompanionSharedLabelConversationCuesAppearWhen,
      ),
    if (plan.hasModule(EventSuccessModuleCatalog.liveReveal.id))
      _PaperExpectationItem(
        icon: CatchIcons.boltRounded,
        label: l10n
            .eventSuccessEventSuccessCompanionSharedLabelOneSynchronizedRevealEvery,
      )
    else
      _PaperExpectationItem(
        icon: CatchIcons.lockOutlineRounded,
        label: l10n
            .eventSuccessEventSuccessCompanionSharedLabelYourGuideStaysPrivate,
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
  const CompanionMomentStage._({
    required this.event,
    required this.plan,
    required this.presentation,
    required this._stageTheme,
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
  final _CompanionStageTheme _stageTheme;
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
    final stageTheme = _stageTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StageNav(foreground: stageTheme.foreground),
        gapH16,
        CompanionHero._(
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
            child: LiveArrivalRing._(
              checkedInCount: event.checkedInCount ?? 0,
              stageTheme: stageTheme,
              idlePulsePeriodMs: presentation.choreography.idlePulsePeriodMs,
            ),
          ),
          gapH18,
        ] else ...[
          StageGlyph._(stageTheme: stageTheme, icon: presentation.icon),
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
                StagePrivacyLine._(
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
  const StageNav({super.key, required this.foreground});

  final Color foreground;

  @override
  Widget build(BuildContext context) {
    final canPop = _companionCanPop(context);
    return Row(
      children: [
        Tooltip(
          message:
              context.l10n.eventSuccessEventSuccessCompanionSharedMessageBack,
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
            context
                .l10n
                .eventSuccessEventSuccessCompanionSharedTextEventCompanion,
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
  const CompanionHero._({
    required this.event,
    required this.plan,
    required this.presentation,
    required this._stageTheme,
    required this.attended,
    required this.showSelfCheckIn,
    required this.eventEnded,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventSuccessMomentPresentation presentation;
  final _CompanionStageTheme _stageTheme;
  final bool attended;
  final bool showSelfCheckIn;
  final bool eventEnded;

  @override
  Widget build(BuildContext context) {
    final fg = _stageTheme.foreground;
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
              tone: attended ? CatchBadgeTone.success : CatchBadgeTone.brand,
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
          context.l10n
              .eventSuccessEventSuccessCompanionSharedTextTitleLocationname29e462(
                title: plan.playbook.title,
                locationName: event.locationName,
              ),
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
  const StageGlyph._({required this._stageTheme, required this.icon});

  final _CompanionStageTheme _stageTheme;
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
            backgroundColor: widget._stageTheme.foreground.withValues(
              alpha: CatchOpacity.subtleFill,
            ),
            borderColor: widget._stageTheme.foreground.withValues(
              alpha: CatchOpacity.eventSuccessSubtleBorder,
            ),
            boxShadow: CatchElevation.glow(
              widget._stageTheme.accent.withValues(alpha: glowAlpha),
              blurRadius: glow,
            ),
            child: Icon(
              widget.icon,
              size: CatchLayout.eventSuccessStageGlyphIconSize,
              color: widget._stageTheme.foreground,
            ),
          ),
        );
      },
    );
  }
}

class StagePrivacyLine extends StatelessWidget {
  const StagePrivacyLine._({required this.text, required this._stageTheme});

  final String text;
  final _CompanionStageTheme _stageTheme;

  @override
  Widget build(BuildContext context) {
    final stageTheme = _stageTheme;
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
            size: CatchIcon.md,
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
  const CompanionMomentStageContent({super.key, required this.children});

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
  const StagePanel({super.key, required this.child});

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
  const StageActionDock({super.key, required this.child});

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
  const StageSoftBand({super.key, required this.child});

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
    required this.visualAsset,
  });

  final Color background;
  final Color foreground;
  final Color accent;
  final Gradient gradient;
  final EventSuccessMotionAsset visualAsset;

  static _CompanionStageTheme forMoment(
    BuildContext context, {
    required EventSuccessMomentPresentation presentation,
    required EventSuccessPlan plan,
  }) {
    const d = CatchTokens.editorialDark;
    final activityPalette = ActivityPalette.of(context);
    final choreography = presentation.choreography;

    Color backgroundFor(ActivitySwatch s) => Color.alphaBlend(
      s.deep.withValues(alpha: CatchOpacity.eventSuccessStageBgBlend),
      d.bg,
    );
    Color midFor(ActivitySwatch s) => Color.alphaBlend(
      s.accent.withValues(alpha: CatchOpacity.eventSuccessStageMidBlend),
      s.deep,
    );

    if (choreography.paletteTokenId == 'editorial.dark') {
      final mid = Color.lerp(d.ink, d.primary, 0.46)!;
      return _CompanionStageTheme(
        background: d.ink,
        foreground: d.ink,
        accent: d.gold,
        visualAsset: eventSuccessMotionAssetForMotif(choreography.motifId),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [d.ink, Color.lerp(d.ink, mid, 0.72)!, mid],
        ),
      );
    }

    final swatch = activityPalette.forKind(
      _activityKindForPaletteTokenId(choreography.paletteTokenId),
    );
    final secondaryTokenId = choreography.accentPaletteTokenId;
    final secondarySwatch = secondaryTokenId == null
        ? null
        : activityPalette.forKind(
            _activityKindForPaletteTokenId(secondaryTokenId),
          );
    final accent = switch (choreography.accentPalettePolicyId) {
      'primary' => swatch.accent,
      'secondary' => secondarySwatch!.accent,
      'secondaryUntilReveal' =>
        plan.revealStatus == EventSuccessRevealStatus.revealed
            ? swatch.accent
            : secondarySwatch!.accent,
      _ => throw StateError(
        'Unsupported Event Success accent palette policy: '
        '${choreography.accentPalettePolicyId}',
      ),
    };
    final background = backgroundFor(swatch);
    final mid = midFor(swatch);

    return _CompanionStageTheme(
      background: background,
      foreground: d.ink,
      accent: accent,
      visualAsset: eventSuccessMotionAssetForMotif(choreography.motifId),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [background, Color.lerp(background, mid, 0.72)!, mid],
      ),
    );
  }
}

ActivityKind _activityKindForPaletteTokenId(String id) => switch (id) {
  'activity.running' => ActivityKind.running,
  'activity.walking' => ActivityKind.walking,
  'activity.pickleball' => ActivityKind.pickleball,
  'activity.padel' => ActivityKind.padel,
  'activity.tennis' => ActivityKind.tennis,
  'activity.badminton' => ActivityKind.badminton,
  'activity.cycling' => ActivityKind.cycling,
  'activity.spinClass' => ActivityKind.spinClass,
  'activity.yoga' => ActivityKind.yoga,
  'activity.strengthTraining' => ActivityKind.strengthTraining,
  'activity.pubQuiz' => ActivityKind.pubQuiz,
  'activity.dinner' => ActivityKind.dinner,
  'activity.singlesMixer' => ActivityKind.singlesMixer,
  _ => throw StateError('Unsupported Event Success palette token id: $id'),
};

/// Plays the portable stage asset on the idle-pulse period owned by the
/// generated moment contract.
class AnimatedStageMotifBackground extends StatefulWidget {
  const AnimatedStageMotifBackground._({
    required this.accent,
    required this.foreground,
    required this.visualAsset,
    required this.idlePulsePeriodMs,
  });

  final Color accent;
  final Color foreground;
  final EventSuccessMotionAsset visualAsset;
  final int idlePulsePeriodMs;

  @override
  State<AnimatedStageMotifBackground> createState() =>
      _AnimatedStageMotifBackgroundState();
}

class _AnimatedStageMotifBackgroundState
    extends State<AnimatedStageMotifBackground>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: CatchMotion.eventSuccessPulsePeriod(widget.idlePulsePeriodMs),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    if (!_kStageAnimationsEnabled) _controller.value = 0.5;
  }

  @override
  void didUpdateWidget(covariant AnimatedStageMotifBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.idlePulsePeriodMs != widget.idlePulsePeriodMs) {
      _controller.duration = CatchMotion.eventSuccessPulsePeriod(
        widget.idlePulsePeriodMs,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = Color.lerp(widget.foreground, widget.accent, 0.72)!;
    return RepaintBoundary(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          color.withValues(alpha: CatchOpacity.eventSuccessMotifAccent),
          BlendMode.srcIn,
        ),
        child: Lottie.asset(
          widget.visualAsset.path,
          controller: _controller,
          fit: BoxFit.cover,
          repeat: false,
          onLoaded: (_) {
            if (_kStageAnimationsEnabled && !_controller.isAnimating) {
              _controller.repeat();
            }
          },
        ),
      ),
    );
  }
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

class CompanionStageContentTransition extends StatelessWidget {
  const CompanionStageContentTransition({
    super.key,
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

/// Gives the wrapped widget a kinetic press response: scale down on tap-down,
/// brief glow flare, then a spring-back to rest. Drop-in replacement for
/// InkWell-style affordances on the stage where Material's ink ripple feels
/// out of place against the gradient + motif backdrop.
class StageBouncyPress extends StatefulWidget {
  const StageBouncyPress({
    super.key,
    required this.child,
    required this.onTap,
    this.glowColor,
    this.borderRadius,
    this.semanticLabel,
    this.selected,
  });

  final Widget child;
  final VoidCallback? onTap;
  final Color? glowColor;
  final BorderRadius? borderRadius;
  final String? semanticLabel;
  final bool? selected;

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
      selected: widget.selected,
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
          child: widget.semanticLabel == null
              ? widget.child
              : ExcludeSemantics(child: widget.child),
        ),
      ),
    );
  }
}

/// Stage-native chip that mirrors `CatchChip.selectable`'s selected/unselected
/// styling while using [StageBouncyPress] instead of Material ink.
class StageBouncyChip extends StatelessWidget {
  const StageBouncyChip({
    super.key,
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
  const LiveArrivalRing._({
    required this.checkedInCount,
    required this._stageTheme,
    required this.idlePulsePeriodMs,
  });

  final int checkedInCount;
  final _CompanionStageTheme _stageTheme;
  final int idlePulsePeriodMs;

  @override
  State<LiveArrivalRing> createState() => _LiveArrivalRingState();
}

class _LiveArrivalRingState extends State<LiveArrivalRing>
    with TickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    duration: CatchMotion.pulse,
    vsync: this,
  );
  late final AnimationController _motion = AnimationController(
    duration: CatchMotion.eventSuccessPulsePeriod(widget.idlePulsePeriodMs),
    vsync: this,
  );

  int _lastCount = 0;

  @override
  void initState() {
    super.initState();
    _lastCount = widget.checkedInCount;
    if (_kStageAnimationsEnabled) {
      _motion.repeat();
    } else {
      _motion.value = 0.5;
    }
  }

  @override
  void didUpdateWidget(covariant LiveArrivalRing oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.idlePulsePeriodMs != widget.idlePulsePeriodMs) {
      _motion.duration = CatchMotion.eventSuccessPulsePeriod(
        widget.idlePulsePeriodMs,
      );
    }
    if (widget.checkedInCount > _lastCount && _kStageAnimationsEnabled) {
      _pulse.forward(from: 0);
    }
    _lastCount = widget.checkedInCount;
  }

  @override
  void dispose() {
    _pulse.dispose();
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget._stageTheme;
    return AnimatedBuilder(
      animation: _pulse,
      builder: (context, child) {
        // 0 at rest → 1 at peak. Sine-shaped curve gives a soft "heartbeat"
        // when a new check-in arrives.
        final pulse = math.sin(_pulse.value * math.pi);
        final scale = 1.0 + pulse * 0.08;
        return Transform.scale(scale: scale, child: child);
      },
      child: ArrivalRingCard._(
        checkedInCount: widget.checkedInCount,
        stageTheme: theme,
        motion: _motion,
      ),
    );
  }
}

class ArrivalRingCard extends StatelessWidget {
  const ArrivalRingCard._({
    required this.checkedInCount,
    required this._stageTheme,
    required this.motion,
  });

  final int checkedInCount;
  final _CompanionStageTheme _stageTheme;
  final Animation<double> motion;

  @override
  Widget build(BuildContext context) {
    final fg = _stageTheme.foreground;
    final hasArrivals = checkedInCount > 0;
    final caption = hasArrivals
        ? (checkedInCount == 1
              ? context
                    .l10n
                    .eventSuccessEventSuccessCompanionSharedVisiblecopyPersonHereSoFar
              : context
                    .l10n
                    .eventSuccessEventSuccessCompanionSharedVisiblecopyPeopleHereSoFar)
        : context
              .l10n
              .eventSuccessEventSuccessCompanionSharedVisiblecopyWaitingForTheRoom;
    return SizedBox(
      width: CatchLayout.eventSuccessArrivalRingExtent,
      height: CatchLayout.eventSuccessArrivalRingExtent,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: ColorFiltered(
              colorFilter: ColorFilter.mode(
                _stageTheme.accent.withValues(
                  alpha: CatchOpacity.eventSuccessArrivalAccent,
                ),
                BlendMode.srcIn,
              ),
              child: Lottie.asset(
                EventSuccessMotionAsset.theatrical.path,
                controller: motion,
                fit: BoxFit.contain,
                repeat: false,
              ),
            ),
          ),
          ...List<Widget>.generate(24, (index) {
            final angle = (math.pi * 2 / 24) * index - math.pi / 2;
            final filled = index < math.min(checkedInCount, 24);
            final highlight = filled && index % 6 == 0;
            final color = highlight
                ? _stageTheme.accent.withValues(
                    alpha: CatchOpacity.eventSuccessArrivalHighlight,
                  )
                : fg.withValues(
                    alpha: filled
                        ? CatchOpacity.eventSuccessArrivalAccent
                        : CatchOpacity.eventSuccessSubtleBorder,
                  );
            return Positioned.fill(
              child: Align(
                alignment: Alignment(
                  math.cos(angle) * 0.84,
                  math.sin(angle) * 0.84,
                ),
                child: ClipOval(
                  child: ColoredBox(
                    color: color,
                    child: SizedBox.square(dimension: filled ? 7 : 4),
                  ),
                ),
              ),
            );
          }),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CatchLayout.eventSuccessArrivalRingInnerPadding,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    context.l10n
                        .eventSuccessEventSuccessCompanionSharedTextCheckedincount(
                          checkedInCount: checkedInCount,
                        ),
                    style: CatchTextStyles.headlineS(context, color: fg)
                        .copyWith(
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
        ],
      ),
    );
  }
}

/// Compact co-presence indicator. Tells the attendee they're not in here
/// alone, with a brief alpha-pulse the moment the count climbs. Used on
/// solo-feeling surfaces (questionnaire, eventually First Hello / wingman).
class LiveOthersInRoomLine extends StatefulWidget {
  const LiveOthersInRoomLine({super.key, required this.checkedInCount});

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
                        ? context
                              .l10n
                              .eventSuccessEventSuccessCompanionSharedText1PersonIsChecked
                        : context.l10n
                              .eventSuccessEventSuccessCompanionSharedTextCountPeopleInThe(
                                count: count,
                              ),
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

class NoCompanionActionsCard extends StatelessWidget {
  const NoCompanionActionsCard({super.key});

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
                  context
                      .l10n
                      .eventSuccessEventSuccessCompanionSharedTextTheHostIsRunning,
                  style: CatchTextStyles.sectionTitle(context),
                ),
                gapH4,
                Text(
                  context
                      .l10n
                      .eventSuccessEventSuccessCompanionSharedTextYourNextPromptOr,
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
