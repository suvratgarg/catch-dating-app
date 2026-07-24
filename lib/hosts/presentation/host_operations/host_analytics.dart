part of '../host_operations_screen.dart';

class HostClubInsightsRefreshController {
  Future<void> Function()? _onRefresh;

  Future<void> refresh() => _onRefresh?.call() ?? Future<void>.value();

  void _attach(Future<void> Function() onRefresh) {
    _onRefresh = onRefresh;
  }

  void _detach(Future<void> Function() onRefresh) {
    if (identical(_onRefresh, onRefresh)) _onRefresh = null;
  }
}

class HostClubInsightsPane extends ConsumerStatefulWidget {
  const HostClubInsightsPane({
    super.key,
    required this.club,
    this.refreshController,
    this.onOpenEventReport,
    this.onOpenAllEvents,
    this.onOpenEventDefaults,
  });

  final Club club;
  final HostClubInsightsRefreshController? refreshController;
  final ValueChanged<String>? onOpenEventReport;
  final VoidCallback? onOpenAllEvents;
  final VoidCallback? onOpenEventDefaults;

  @override
  ConsumerState<HostClubInsightsPane> createState() =>
      _HostClubInsightsPaneState();
}

class _HostClubInsightsPaneState extends ConsumerState<HostClubInsightsPane> {
  late HostClubInsightsState _state;

  @override
  void initState() {
    super.initState();
    _state = HostClubInsightsState.initial(clubId: widget.club.id);
    widget.refreshController?._attach(_refresh);
  }

  @override
  void didUpdateWidget(covariant HostClubInsightsPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    _state = _state.selectClub(widget.club.id);
    if (!identical(oldWidget.refreshController, widget.refreshController)) {
      oldWidget.refreshController?._detach(_refresh);
      widget.refreshController?._attach(_refresh);
    }
  }

  @override
  void dispose() {
    widget.refreshController?._detach(_refresh);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fallbackTimezone = marketForCityName(widget.club.location).timeZone;
    final timezone =
        ref.watch(hostAnalyticsDeviceTimezoneProvider).value ??
        fallbackTimezone;
    final query = _hostAnalyticsQueryFor(_state.query, timezone: timezone);
    final analyticsAsync = ref.watch(hostAnalyticsProvider(query));
    return CatchAsyncValueView<HostAnalyticsReport>(
      value: analyticsAsync,
      onRetry: () => ref.invalidate(hostAnalyticsProvider(query)),
      loadingBuilder: (_) => const HostAnalyticsReportSkeleton(),
      errorBuilder: (_, error, _) => CatchErrorState.fromError(
        error,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(hostAnalyticsProvider(query)),
      ),
      builder: (context, report) => HostAnalyticsReportView(
        report: report,
        rangePreset: _state.rangePreset,
        currencyCode: currencyCodeForCityName(widget.club.location),
        allTimeOverview: HostClubOrganizerOverviewController(club: widget.club),
        onRangeChanged: (preset) {
          setState(() => _state = _state.selectRange(preset));
        },
        onOpenEventReport: widget.onOpenEventReport ?? _openEventReport,
        onOpenAllEvents:
            widget.onOpenAllEvents ??
            () => context.goNamed(Routes.hostEventsScreen.name),
        onOpenEventDefaults:
            widget.onOpenEventDefaults ??
            () => context.pushNamed(
              Routes.hostClubEventDefaultsScreen.name,
              queryParameters: {'clubId': widget.club.id},
            ),
      ),
    );
  }

  Future<void> _refresh() async {
    final fallbackTimezone = marketForCityName(widget.club.location).timeZone;
    final timezone =
        await ref.read(hostAnalyticsDeviceTimezoneProvider.future) ??
        fallbackTimezone;
    final query = _hostAnalyticsQueryFor(_state.query, timezone: timezone);
    ref.invalidate(hostAnalyticsProvider(query));
    await ref.read(hostAnalyticsProvider(query).future);
  }

  void _openEventReport(String eventId) {
    context.pushNamed(
      Routes.hostAppEventManageScreen.name,
      pathParameters: {'clubId': widget.club.id, 'eventId': eventId},
      queryParameters: const {'section': 'report'},
    );
  }
}

enum HostAnalyticsCoachRecommendationKind {
  attendance,
  checkoutDropoff,
  demandCapacity,
  noRepeatAttendees,
}

class HostAnalyticsCoachRecommendation {
  const HostAnalyticsCoachRecommendation({
    required this.kind,
    this.eventId,
    this.eventTitle,
  });

  final HostAnalyticsCoachRecommendationKind kind;
  final String? eventId;
  final String? eventTitle;
}

const hostAnalyticsCoachAttendanceThreshold = 60;
const hostAnalyticsCoachCheckoutDropoffThreshold = 0.30;
const hostAnalyticsCoachDemandMultiplier = 2;
const hostAnalyticsCoachMaximumRecommendations = 2;

List<HostAnalyticsCoachRecommendation> hostAnalyticsCoachRecommendations(
  HostAnalyticsReport report,
) {
  final recommendations = <HostAnalyticsCoachRecommendation>[];
  final events = report.topEvents;
  HostAnalyticsMetricCard? attendance;
  for (final card in report.summaryCards) {
    if (card.id == HostAnalyticsMetricIds.attendanceRate) {
      attendance = card;
      break;
    }
  }

  void add(HostAnalyticsCoachRecommendation recommendation) {
    if (recommendations.length < hostAnalyticsCoachMaximumRecommendations) {
      recommendations.add(recommendation);
    }
  }

  if (events.length >= 2 &&
      attendance != null &&
      attendance.value < hostAnalyticsCoachAttendanceThreshold) {
    add(
      HostAnalyticsCoachRecommendation(
        kind: HostAnalyticsCoachRecommendationKind.attendance,
        eventId: events.first.eventId,
        eventTitle: events.first.title,
      ),
    );
  }

  final checkoutStarted = _trendMetricTotal(
    report,
    HostAnalyticsTrendKeys.checkoutStarted,
  );
  final checkoutDropoff = _trendMetricTotal(
    report,
    HostAnalyticsTrendKeys.checkoutDropoff,
  );
  if (checkoutStarted > 0 &&
      checkoutDropoff / checkoutStarted >=
          hostAnalyticsCoachCheckoutDropoffThreshold) {
    add(
      const HostAnalyticsCoachRecommendation(
        kind: HostAnalyticsCoachRecommendationKind.checkoutDropoff,
      ),
    );
  }

  for (final event in events) {
    if (event.demandCount > 0 &&
        event.demandCount >=
            hostAnalyticsCoachDemandMultiplier * event.bookedCount) {
      add(
        HostAnalyticsCoachRecommendation(
          kind: HostAnalyticsCoachRecommendationKind.demandCapacity,
          eventId: event.eventId,
          eventTitle: event.title,
        ),
      );
      break;
    }
  }

  // The callable caps recent events at 25. Avoid claiming there were no repeat
  // attendees when the range may contain events outside that visible slice.
  if (events.length >= 3 &&
      events.length < 25 &&
      events.every((event) => event.repeatAttendeeCount == 0)) {
    add(
      const HostAnalyticsCoachRecommendation(
        kind: HostAnalyticsCoachRecommendationKind.noRepeatAttendees,
      ),
    );
  }

  return recommendations;
}

num _trendMetricTotal(HostAnalyticsReport report, String key) {
  return report.trend.fold<num>(
    0,
    (total, point) => total + (point.metrics[key] ?? 0),
  );
}

HostAnalyticsQuery _hostAnalyticsQueryFor(
  HostClubInsightsQueryState state, {
  required String timezone,
}) {
  return HostAnalyticsQuery(
    clubId: state.clubId,
    rangePreset: switch (state.rangePreset) {
      HostClubInsightsRangePreset.thirtyDays =>
        HostAnalyticsRangePreset.thirtyDays,
      HostClubInsightsRangePreset.ninetyDays =>
        HostAnalyticsRangePreset.ninetyDays,
      HostClubInsightsRangePreset.twelveMonths =>
        HostAnalyticsRangePreset.twelveMonths,
    },
    granularity: switch (state.rangePreset) {
      HostClubInsightsRangePreset.thirtyDays ||
      HostClubInsightsRangePreset.ninetyDays => HostAnalyticsGranularity.week,
      HostClubInsightsRangePreset.twelveMonths =>
        HostAnalyticsGranularity.month,
    },
    timezone: timezone,
  );
}

class HostAnalyticsReportView extends StatefulWidget {
  const HostAnalyticsReportView({
    super.key,
    required this.report,
    required this.rangePreset,
    required this.currencyCode,
    required this.allTimeOverview,
    required this.onRangeChanged,
    required this.onOpenEventReport,
    required this.onOpenAllEvents,
    required this.onOpenEventDefaults,
    this.now,
  });

  final HostAnalyticsReport report;
  final HostClubInsightsRangePreset rangePreset;
  final String currencyCode;
  final Widget allTimeOverview;
  final ValueChanged<HostClubInsightsRangePreset> onRangeChanged;
  final ValueChanged<String> onOpenEventReport;
  final VoidCallback onOpenAllEvents;
  final VoidCallback onOpenEventDefaults;
  final DateTime? now;

  @override
  State<HostAnalyticsReportView> createState() =>
      _HostAnalyticsReportViewState();
}

class _HostAnalyticsReportViewState extends State<HostAnalyticsReportView> {
  bool _moreMetricsOpen = false;

  @override
  Widget build(BuildContext context) {
    final primaryMetrics = _primaryMetricCards(widget.report);
    final secondaryMetrics = _secondaryMetricCards(widget.report);
    final coachRecommendations = hostAnalyticsCoachRecommendations(
      widget.report,
    );
    final showSyncFootnote =
        widget.report.dataQuality.any(
          (row) => row.state != HostAnalyticsDataQualityState.ok,
        ) ||
        widget.report.summaryCards.any(
          (card) => card.status != HostAnalyticsMetricStatus.ready,
        );

    return CatchSectionStack(
      padding: EdgeInsets.zero,
      children: [
        CatchSection.divided(
          first: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.hostsHostAnalyticsTextUpdatedRelative(
                  relative: AppTimeFormatters.compactRelativeTime(
                    widget.report.generatedAt,
                    now: widget.now,
                  ),
                ),
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).ink3,
                ),
              ),
              if (showSyncFootnote) ...[
                gapH4,
                Text(
                  context
                      .l10n
                      .hostsHostAnalyticsTextSomeDataIsStillSyncingNumbersMayUpdate,
                  key: const ValueKey('host-analytics-sync-footnote'),
                  style: CatchTextStyles.supporting(
                    context,
                    color: CatchTokens.of(context).warning,
                  ),
                ),
              ],
            ],
          ),
        ),
        CatchSection.divided(
          title: context.l10n.hostsHostAnalyticsLabelAllTime,
          child: widget.allTimeOverview,
        ),
        CatchSection.divided(
          title: context.l10n.hostsHostAnalyticsLabelPerformancePeriod,
          child: CatchOptionGroup<HostClubInsightsRangePreset>(
            contract: CatchContractConstraints
                .hostAnalyticsQueryCallablePayloadRangePreset,
            contractValue: (preset) => switch (preset) {
              HostClubInsightsRangePreset.thirtyDays => '30d',
              HostClubInsightsRangePreset.ninetyDays => '90d',
              HostClubInsightsRangePreset.twelveMonths => '12m',
            },
            selected: widget.rangePreset,
            onChanged: widget.onRangeChanged,
            options: [
              CatchOption(
                value: HostClubInsightsRangePreset.thirtyDays,
                label: context.l10n.hostsHostAnalyticsLabel30Days,
              ),
              CatchOption(
                value: HostClubInsightsRangePreset.ninetyDays,
                label: context.l10n.hostsHostAnalyticsLabel90Days,
              ),
              CatchOption(
                value: HostClubInsightsRangePreset.twelveMonths,
                label: context.l10n.hostsHostAnalyticsLabel12Months,
              ),
            ],
          ),
        ),
        CatchSection.divided(
          title: context.l10n.hostsHostAnalyticsLabelPerformance,
          child: Column(
            children: [
              CatchAnalyticsMetricGrid(
                key: const ValueKey('host-analytics-primary-grid'),
                metrics: [
                  for (final metric in primaryMetrics)
                    _hostMetricCardData(
                      context,
                      metric,
                      rangePreset: widget.rangePreset,
                      currencyCode: widget.currencyCode,
                    ),
                ],
              ),
              gapH12,
              // Composite exception: the disclosure reveals a complete
              // secondary analytics grid, not a scalar field choice.
              CatchField.control(
                key: const ValueKey('host-analytics-more-metrics'),
                title: context.l10n.hostsHostAnalyticsLabelMoreMetrics,
                contractExemption:
                    'Disclosure-only analytics layout; no editable value is '
                    'submitted or persisted.',
                body: context.l10n.hostsHostAnalyticsBodyCheckoutChatsAndSaves,
                open: _moreMetricsOpen,
                onOpenChanged: (open) {
                  setState(() => _moreMetricsOpen = open);
                },
                control: CatchAnalyticsMetricGrid(
                  key: const ValueKey('host-analytics-secondary-grid'),
                  metrics: [
                    for (final metric in secondaryMetrics)
                      _hostMetricCardData(
                        context,
                        metric,
                        rangePreset: widget.rangePreset,
                        currencyCode: widget.currencyCode,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        HostAnalyticsTrendPanel(
          points: widget.report.trend,
          granularity: _granularityFor(widget.rangePreset),
        ),
        if (coachRecommendations.isNotEmpty)
          CatchSection.divided(
            title: context.l10n.hostsHostAnalyticsTitleCoach,
            child: CatchSection.contained(
              children: [
                for (final recommendation in coachRecommendations.indexed)
                  switch (recommendation.$2.kind) {
                    HostAnalyticsCoachRecommendationKind.attendance =>
                      CatchField.nav(
                        key: const ValueKey('host-analytics-coach-attendance'),
                        title: context.l10n.hostsHostAnalyticsCoachAttendance,
                        titleMaxLines: 3,
                        divider: recommendation.$1 > 0,
                        onTap: () => widget.onOpenEventReport(
                          recommendation.$2.eventId!,
                        ),
                      ),
                    HostAnalyticsCoachRecommendationKind.checkoutDropoff =>
                      CatchField.nav(
                        key: const ValueKey(
                          'host-analytics-coach-checkout-dropoff',
                        ),
                        title:
                            context.l10n.hostsHostAnalyticsCoachCheckoutDropoff,
                        titleMaxLines: 3,
                        divider: recommendation.$1 > 0,
                        onTap: widget.onOpenEventDefaults,
                      ),
                    HostAnalyticsCoachRecommendationKind.demandCapacity =>
                      CatchField.nav(
                        key: const ValueKey(
                          'host-analytics-coach-demand-capacity',
                        ),
                        title: context.l10n
                            .hostsHostAnalyticsCoachDemandCapacity(
                              event: recommendation.$2.eventTitle!,
                            ),
                        titleMaxLines: 3,
                        divider: recommendation.$1 > 0,
                        onTap: () => widget.onOpenEventReport(
                          recommendation.$2.eventId!,
                        ),
                      ),
                    HostAnalyticsCoachRecommendationKind.noRepeatAttendees =>
                      CatchField.read(
                        key: const ValueKey(
                          'host-analytics-coach-no-repeat-attendees',
                        ),
                        title: context
                            .l10n
                            .hostsHostAnalyticsCoachNoRepeatAttendees,
                        titleMaxLines: 3,
                        divider: recommendation.$1 > 0,
                      ),
                  },
              ],
            ),
          ),
        HostAnalyticsEventList(
          events: widget.report.topEvents,
          onOpenEventReport: widget.onOpenEventReport,
          onOpenAllEvents: widget.onOpenAllEvents,
        ),
        HostAnalyticsReviewsPanel(report: widget.report),
      ],
    );
  }
}

class HostAnalyticsTrendPanel extends StatefulWidget {
  const HostAnalyticsTrendPanel({
    super.key,
    required this.points,
    required this.granularity,
  });

  final List<HostAnalyticsTrendPoint> points;
  final HostAnalyticsGranularity granularity;

  @override
  State<HostAnalyticsTrendPanel> createState() =>
      _HostAnalyticsTrendPanelState();
}

class _HostAnalyticsTrendPanelState extends State<HostAnalyticsTrendPanel> {
  int? _selectedIndex;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final maxValue = widget.points.fold<num>(0, (max, point) {
      final demand = point.metrics[HostAnalyticsTrendKeys.demand] ?? 0;
      final bookings = point.metrics[HostAnalyticsTrendKeys.bookings] ?? 0;
      return math.max(max, math.max(demand, bookings));
    });
    final selectedPoint =
        _selectedIndex == null || _selectedIndex! >= widget.points.length
        ? null
        : widget.points[_selectedIndex!];

    return CatchSection.divided(
      title: context.l10n.hostsHostAnalyticsLabelTrendBookingsVsDemand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              for (final entry in <(Color, String)>[
                (t.primarySoft, context.l10n.hostsHostAnalyticsLabelDemand),
                (t.ink, context.l10n.hostsHostAnalyticsLabelBookings),
              ].indexed) ...[
                if (entry.$1 > 0) gapW16,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Material(
                      color: entry.$2.$1,
                      borderRadius: BorderRadius.circular(CatchRadius.xs),
                      child: const SizedBox(
                        width: CatchSpacing.s3,
                        height: CatchSpacing.s2,
                      ),
                    ),
                    gapW6,
                    Text(
                      entry.$2.$2,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ],
            ],
          ),
          gapH16,
          if (widget.points.isEmpty)
            Text(
              context.l10n.hostsHostAnalyticsTextNoAnalyticsInThisRange,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final indexed in widget.points.indexed) ...[
                    if (indexed.$1 > 0) gapW12,
                    HostAnalyticsDualBar(
                      point: indexed.$2,
                      maxValue: maxValue,
                      label: _trendBucketLabel(
                        indexed.$2.periodStart,
                        widget.granularity,
                        indexed.$1,
                      ),
                      selected: indexed.$1 == _selectedIndex,
                      onTap: () => setState(() => _selectedIndex = indexed.$1),
                    ),
                  ],
                ],
              ),
            ),
          if (selectedPoint != null) ...[
            gapH12,
            Text(
              context.l10n.hostsHostAnalyticsTextPeriodDemandBookings(
                period: _trendDetailPeriod(
                  selectedPoint.periodStart,
                  widget.granularity,
                ),
                demand:
                    selectedPoint.metrics[HostAnalyticsTrendKeys.demand]
                        ?.round() ??
                    0,
                bookings:
                    selectedPoint.metrics[HostAnalyticsTrendKeys.bookings]
                        ?.round() ??
                    0,
              ),
              key: const ValueKey('host-analytics-trend-detail'),
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
        ],
      ),
    );
  }
}

class HostAnalyticsDualBar extends StatelessWidget {
  const HostAnalyticsDualBar({
    super.key,
    required this.point,
    required this.maxValue,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final HostAnalyticsTrendPoint point;
  final num maxValue;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final demand = point.metrics[HostAnalyticsTrendKeys.demand] ?? 0;
    final bookings = point.metrics[HostAnalyticsTrendKeys.bookings] ?? 0;
    double heightFor(num value) => maxValue <= 0
        ? 0
        : CatchLayout.analyticsTrendHeight * (value / maxValue).clamp(0, 1);

    return Semantics(
      button: true,
      selected: selected,
      label: context.l10n.hostsHostAnalyticsTextPeriodDemandBookings(
        period: label,
        demand: demand.round(),
        bookings: bookings.round(),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CatchRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s1),
          child: Column(
            children: [
              SizedBox(
                width: CatchSpacing.s6,
                height: CatchLayout.analyticsTrendHeight,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    TweenAnimationBuilder<double>(
                      duration: CatchMotion.fast,
                      tween: Tween(
                        begin: 0,
                        end: math.max(CatchSpacing.micro2, heightFor(demand)),
                      ),
                      builder: (_, height, child) => SizedBox(
                        width: CatchSpacing.s6,
                        height: height,
                        child: child,
                      ),
                      child: Material(
                        color: t.primarySoft,
                        borderRadius: BorderRadius.circular(CatchRadius.xs),
                      ),
                    ),
                    TweenAnimationBuilder<double>(
                      duration: CatchMotion.fast,
                      tween: Tween(
                        begin: 0,
                        end: math.max(CatchSpacing.micro2, heightFor(bookings)),
                      ),
                      builder: (_, height, child) => SizedBox(
                        width: CatchSpacing.s3,
                        height: height,
                        child: child,
                      ),
                      child: Material(
                        color: t.ink,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(CatchRadius.xs),
                          side: selected
                              ? BorderSide(color: t.primary)
                              : BorderSide.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              gapH6,
              SizedBox(
                width: CatchSpacing.s8,
                child: Text(
                  label,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(context, color: t.ink3),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HostAnalyticsEventList extends StatelessWidget {
  const HostAnalyticsEventList({
    super.key,
    required this.events,
    required this.onOpenEventReport,
    required this.onOpenAllEvents,
  });

  final List<HostAnalyticsEventRow> events;
  final ValueChanged<String> onOpenEventReport;
  final VoidCallback onOpenAllEvents;

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: context.l10n.hostsHostAnalyticsLabelRecentEvents,
      child: CatchSection.contained(
        children: [
          if (events.isEmpty)
            Padding(
              padding: CatchInsets.content,
              child: Text(
                context.l10n.hostsHostAnalyticsTextNoEventsInThis,
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).ink2,
                ),
              ),
            )
          else
            for (final indexed in events.take(5).indexed)
              HostAnalyticsEventTile(
                event: indexed.$2,
                divider: indexed.$1 > 0,
                onTap: () => onOpenEventReport(indexed.$2.eventId),
              ),
          CatchField.nav(
            title: context.l10n.hostsHostAnalyticsLabelAllEvents,
            icon: CatchIcons.calendarMonthOutlined,
            divider: events.isNotEmpty,
            onTap: onOpenAllEvents,
          ),
        ],
      ),
    );
  }
}

class HostAnalyticsEventTile extends StatelessWidget {
  const HostAnalyticsEventTile({
    super.key,
    required this.event,
    required this.divider,
    required this.onTap,
  });

  final HostAnalyticsEventRow event;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasPaymentIssues =
        event.paymentFailedCount > 0 || event.checkoutDropoffCount > 0;
    final dateAndStatus = context.l10n.hostsHostAnalyticsTextEventDateStatus(
      date: EventFormatters.shortDate(event.startTime),
      status: _analyticsEventStatusLabel(context, event.status),
    );
    final attendance = context.l10n.hostsHostAnalyticsTextBookedAttendedMatches(
      booked: event.bookedCount,
      attended: event.checkedInCount,
      matches: event.mutualMatchCount,
    );
    return CatchField.nav(
      key: ValueKey('host-analytics-event-${event.eventId}'),
      title: event.title,
      body: '$dateAndStatus\n$attendance',
      icon: CatchIcons.eventOutlined,
      divider: divider,
      onTap: onTap,
      showChevron: false,
      valueText: EventFormatters.priceInPaise(
        event.grossRevenueMinor,
        currencyCode: event.currency,
      ),
      action: hasPaymentIssues
          ? CatchBadge(
              label: context.l10n.hostsHostAnalyticsLabelPaymentIssues,
              tone: CatchBadgeTone.warning,
            )
          : null,
    );
  }
}

class HostAnalyticsReviewsPanel extends StatelessWidget {
  const HostAnalyticsReviewsPanel({super.key, required this.report});

  final HostAnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      title: context.l10n.hostsHostAnalyticsLabelReviews,
      child: CatchSurface(
        padding: CatchInsets.content,
        borderColor: CatchTokens.of(context).line,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CatchStatColumn(
                    label: context.l10n.hostsHostAnalyticsLabelNewReviews,
                    value: _compactCount(report.reviewSummary.newReviews),
                  ),
                ),
                Expanded(
                  child: CatchStatColumn(
                    label: context.l10n.hostsHostAnalyticsLabelAverageRating,
                    value: report.reviewSummary.averageRating <= 0
                        ? '—'
                        : report.reviewSummary.averageRating.toStringAsFixed(1),
                  ),
                ),
              ],
            ),
            gapH16,
            Row(
              children: [
                Expanded(
                  child: CatchStatColumn(
                    label: context.l10n.hostsHostAnalyticsLabelPublishedReviews,
                    value: _compactCount(report.reviewSummary.publishedReviews),
                  ),
                ),
                Expanded(
                  child: CatchStatColumn(
                    label: context.l10n.hostsHostAnalyticsLabelResponses,
                    value: _compactCount(
                      report.reviewSummary.ownerResponseCount,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

List<HostAnalyticsMetricCard> _primaryMetricCards(HostAnalyticsReport report) {
  final cards = {for (final card in report.summaryCards) card.id: card};
  final listing = cards[HostAnalyticsMetricIds.listingViews];
  final events = cards[HostAnalyticsMetricIds.eventViews];
  final views = HostAnalyticsMetricCard(
    id: HostAnalyticsMetricIds.combinedViews,
    label: '',
    value: (listing?.value ?? 0) + (events?.value ?? 0),
    unit: HostAnalyticsMetricUnit.count,
    status: _combinedMetricStatus(listing?.status, events?.status),
    previousValue:
        listing?.previousValue == null || events?.previousValue == null
        ? null
        : listing!.previousValue! + events!.previousValue!,
  );
  return [
    views,
    _metricOrMissing(cards, HostAnalyticsMetricIds.bookings),
    _metricOrMissing(
      cards,
      HostAnalyticsMetricIds.attendanceRate,
      unit: HostAnalyticsMetricUnit.percent,
    ),
    _metricOrMissing(
      cards,
      HostAnalyticsMetricIds.revenue,
      unit: HostAnalyticsMetricUnit.moneyMinor,
    ),
    _metricOrMissing(cards, HostAnalyticsMetricIds.connections),
    _metricOrMissing(cards, HostAnalyticsMetricIds.newReviews),
  ];
}

List<HostAnalyticsMetricCard> _secondaryMetricCards(
  HostAnalyticsReport report,
) {
  final cards = {for (final card in report.summaryCards) card.id: card};
  return [
    _metricOrMissing(cards, HostAnalyticsMetricIds.checkoutDropoff),
    _metricOrMissing(
      cards,
      HostAnalyticsMetricIds.checkoutConversionRate,
      unit: HostAnalyticsMetricUnit.percent,
    ),
    _metricOrMissing(cards, HostAnalyticsMetricIds.chats),
    HostAnalyticsMetricCard(
      id: HostAnalyticsMetricIds.eventSaves,
      label: '',
      value: report.discoverySummary.eventSaves,
      unit: HostAnalyticsMetricUnit.count,
      status:
          report.dataQuality.any(
            (row) => row.state == HostAnalyticsDataQualityState.missing,
          )
          ? HostAnalyticsMetricStatus.missing
          : HostAnalyticsMetricStatus.ready,
    ),
  ];
}

HostAnalyticsMetricCard _metricOrMissing(
  Map<String, HostAnalyticsMetricCard> cards,
  String id, {
  HostAnalyticsMetricUnit unit = HostAnalyticsMetricUnit.count,
}) {
  return cards[id] ??
      HostAnalyticsMetricCard(
        id: id,
        label: '',
        value: 0,
        unit: unit,
        status: HostAnalyticsMetricStatus.missing,
      );
}

HostAnalyticsMetricStatus _combinedMetricStatus(
  HostAnalyticsMetricStatus? first,
  HostAnalyticsMetricStatus? second,
) {
  if (first == HostAnalyticsMetricStatus.missing ||
      second == HostAnalyticsMetricStatus.missing ||
      first == null ||
      second == null) {
    return HostAnalyticsMetricStatus.missing;
  }
  if (first == HostAnalyticsMetricStatus.partial ||
      second == HostAnalyticsMetricStatus.partial) {
    return HostAnalyticsMetricStatus.partial;
  }
  return HostAnalyticsMetricStatus.ready;
}

IconData _metricIcon(String metricId) {
  return switch (metricId) {
    HostAnalyticsMetricIds.listingViews ||
    HostAnalyticsMetricIds.eventViews ||
    HostAnalyticsMetricIds.combinedViews => CatchIcons.visibilityOutlined,
    HostAnalyticsMetricIds.bookings => CatchIcons.confirmationNumberOutlined,
    HostAnalyticsMetricIds.attendanceRate => CatchIcons.factCheckOutlined,
    HostAnalyticsMetricIds.revenue => CatchIcons.accountBalanceWalletOutlined,
    HostAnalyticsMetricIds.checkoutDropoff ||
    HostAnalyticsMetricIds.checkoutConversionRate =>
      CatchIcons.paymentsOutlined,
    HostAnalyticsMetricIds.newReviews => CatchIcons.rateReviewOutlined,
    HostAnalyticsMetricIds.connections => CatchIcons.favoriteOutlineRounded,
    HostAnalyticsMetricIds.chats => CatchIcons.chatBubbleOutlineRounded,
    HostAnalyticsMetricIds.eventSaves => CatchIcons.bookmarkBorderRounded,
    _ => CatchIcons.insightsOutlined,
  };
}

CatchMetricCardData _hostMetricCardData(
  BuildContext context,
  HostAnalyticsMetricCard metric, {
  required HostClubInsightsRangePreset rangePreset,
  required String currencyCode,
}) {
  return CatchMetricCardData(
    icon: _metricIcon(metric.id),
    value: _formatMetricValue(metric, currencyCode: currencyCode),
    label: _metricLabel(context, metric),
    caption: _deltaCaption(context, metric, rangePreset),
    partialBadgeLabel: context.l10n.hostsHostAnalyticsLabelPartial,
    missingBadgeLabel: context.l10n.hostsHostAnalyticsLabelMissing,
    status: switch (metric.status) {
      HostAnalyticsMetricStatus.ready => CatchMetricStatus.ready,
      HostAnalyticsMetricStatus.partial => CatchMetricStatus.partial,
      HostAnalyticsMetricStatus.missing => CatchMetricStatus.missing,
    },
  );
}

String _metricLabel(BuildContext context, HostAnalyticsMetricCard metric) {
  return switch (metric.id) {
    HostAnalyticsMetricIds.combinedViews =>
      context.l10n.hostsHostAnalyticsLabelProfileAndEventViews,
    HostAnalyticsMetricIds.listingViews =>
      context.l10n.hostsHostAnalyticsLabelProfileViews,
    HostAnalyticsMetricIds.eventViews =>
      context.l10n.hostsHostAnalyticsLabelEventViews,
    HostAnalyticsMetricIds.bookings =>
      context.l10n.hostsHostAnalyticsLabelBookings,
    HostAnalyticsMetricIds.attendanceRate =>
      context.l10n.hostsHostAnalyticsLabelAttendanceRate,
    HostAnalyticsMetricIds.revenue =>
      context.l10n.hostsHostAnalyticsLabelRevenue,
    HostAnalyticsMetricIds.checkoutDropoff =>
      context.l10n.hostsHostAnalyticsLabelCheckoutDropOff,
    HostAnalyticsMetricIds.checkoutConversionRate =>
      context.l10n.hostsHostAnalyticsLabelCheckoutConversion,
    HostAnalyticsMetricIds.newReviews =>
      context.l10n.hostsHostAnalyticsLabelNewReviews,
    HostAnalyticsMetricIds.connections =>
      context.l10n.hostsHostAnalyticsLabelConnections,
    HostAnalyticsMetricIds.chats =>
      context.l10n.hostsHostAnalyticsLabelChatsStarted,
    HostAnalyticsMetricIds.eventSaves =>
      context.l10n.hostsHostAnalyticsLabelEventSaves,
    _ => metric.label,
  };
}

String? _deltaCaption(
  BuildContext context,
  HostAnalyticsMetricCard metric,
  HostClubInsightsRangePreset rangePreset,
) {
  final previous = metric.previousValue;
  if (previous == null || previous == 0) return null;
  final delta = ((metric.value - previous) / previous) * 100;
  return context.l10n.hostsHostAnalyticsTextDirectionPercentVsPreviousPeriod(
    direction: delta >= 0 ? '↑' : '↓',
    percent: delta.abs().round(),
    period: _rangeLabel(context, rangePreset),
  );
}

String _rangeLabel(
  BuildContext context,
  HostClubInsightsRangePreset rangePreset,
) {
  return switch (rangePreset) {
    HostClubInsightsRangePreset.thirtyDays =>
      context.l10n.hostsHostAnalyticsLabel30Days,
    HostClubInsightsRangePreset.ninetyDays =>
      context.l10n.hostsHostAnalyticsLabel90Days,
    HostClubInsightsRangePreset.twelveMonths =>
      context.l10n.hostsHostAnalyticsLabel12Months,
  };
}

HostAnalyticsGranularity _granularityFor(
  HostClubInsightsRangePreset rangePreset,
) {
  return switch (rangePreset) {
    HostClubInsightsRangePreset.thirtyDays ||
    HostClubInsightsRangePreset.ninetyDays => HostAnalyticsGranularity.week,
    HostClubInsightsRangePreset.twelveMonths => HostAnalyticsGranularity.month,
  };
}

String _formatMetricValue(
  HostAnalyticsMetricCard metric, {
  required String currencyCode,
}) {
  return switch (metric.unit) {
    HostAnalyticsMetricUnit.percent => '${metric.value.round()}%',
    HostAnalyticsMetricUnit.moneyMinor => EventFormatters.priceInPaise(
      metric.value.round(),
      currencyCode: currencyCode,
    ),
    HostAnalyticsMetricUnit.rating =>
      metric.value <= 0 ? '—' : metric.value.toStringAsFixed(1),
    HostAnalyticsMetricUnit.count => _compactCount(metric.value.round()),
  };
}

String _analyticsEventStatusLabel(BuildContext context, String status) {
  return switch (status.trim().toLowerCase()) {
    'live' => context.l10n.hostsHostAnalyticsStatusLive,
    'active' => context.l10n.hostsHostAnalyticsStatusActive,
    'open' => context.l10n.hostsHostAnalyticsStatusOpen,
    'published' => context.l10n.hostsHostAnalyticsStatusPublished,
    'completed' => context.l10n.hostsHostAnalyticsStatusCompleted,
    'past' => context.l10n.hostsHostAnalyticsStatusPast,
    'draft' => context.l10n.hostsHostAnalyticsStatusDraft,
    'pending' => context.l10n.hostsHostAnalyticsStatusPending,
    'scheduled' => context.l10n.hostsHostAnalyticsStatusScheduled,
    'cancelled' || 'canceled' => context.l10n.hostsHostAnalyticsStatusCancelled,
    _ => _titleCaseIdentifier(status),
  };
}

String _titleCaseIdentifier(String value) {
  final normalized = value.trim();
  if (normalized.isEmpty || normalized == 'unknown') return '—';
  return normalized
      .split(RegExp(r'[_\-\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

String _trendBucketLabel(
  DateTime date,
  HostAnalyticsGranularity granularity,
  int index,
) {
  if (granularity == HostAnalyticsGranularity.month) {
    return AppTimeFormatters.shortMonth(date);
  }
  return index.isEven ? AppTimeFormatters.monthDay(date) : '';
}

String _trendDetailPeriod(DateTime date, HostAnalyticsGranularity granularity) {
  return granularity == HostAnalyticsGranularity.month
      ? AppTimeFormatters.longMonth(date)
      : AppTimeFormatters.shortDate(date);
}
