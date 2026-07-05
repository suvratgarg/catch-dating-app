part of '../host_operations_screen.dart';

class HostClubInsightsPane extends ConsumerStatefulWidget {
  const HostClubInsightsPane({super.key, required this.club});

  final Club club;

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
  }

  @override
  void didUpdateWidget(covariant HostClubInsightsPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    _state = _state.selectClub(widget.club.id);
  }

  @override
  Widget build(BuildContext context) {
    final query = _hostAnalyticsQueryFor(_state.query);
    final analyticsAsync = ref.watch(hostAnalyticsProvider(query));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HostMetaRow(club: widget.club, roleLabel: 'Insights', owner: true),
        gapH24,
        HostAnalyticsControls(
          rangePreset: _state.rangePreset,
          granularity: _state.granularity,
          customStartDate: _state.customStartDate,
          customEndDate: _state.customEndDate,
          selectedEventId: _state.selectedEventId,
          onRangeChanged: (preset) =>
              setState(() => _state = _state.selectRange(preset)),
          onGranularityChanged: (granularity) =>
              setState(() => _state = _state.selectGranularity(granularity)),
          onPickStartDate: _pickCustomStartDate,
          onPickEndDate: _pickCustomEndDate,
          onClearEvent: _clearEventScope,
        ),
        gapH20,
        CatchAsyncValueView<HostAnalyticsReport>(
          value: analyticsAsync,
          loadingBuilder: (_) => const HostAnalyticsReportSkeleton(),
          errorBuilder: (_, error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.club,
            onRetry: () => ref.invalidate(hostAnalyticsProvider(query)),
          ),
          builder: (context, report) => HostAnalyticsReportView(
            report: report,
            selectedEventId: _state.selectedEventId,
            onEventSelected: _selectEventScope,
            onClearEvent: _clearEventScope,
          ),
        ),
      ],
    );
  }

  Future<void> _pickCustomStartDate() async {
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: _state.customStartDate,
      firstDate: _analyticsDateDaysAgo(366),
      lastDate: _state.customEndDate,
      title: 'Start date',
    );
    if (picked == null || !mounted) return;
    setState(() => _state = _state.selectCustomStartDate(picked));
  }

  Future<void> _pickCustomEndDate() async {
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: _state.customEndDate,
      firstDate: _state.customStartDate,
      lastDate: DateUtils.dateOnly(DateTime.now()),
      title: 'End date',
    );
    if (picked == null || !mounted) return;
    setState(() => _state = _state.selectCustomEndDate(picked));
  }

  void _selectEventScope(String eventId) {
    setState(() => _state = _state.selectEvent(eventId));
  }

  void _clearEventScope() {
    setState(() => _state = _state.clearEvent());
  }
}

HostAnalyticsQuery _hostAnalyticsQueryFor(HostClubInsightsQueryState state) {
  return HostAnalyticsQuery(
    clubId: state.clubId,
    eventId: state.eventId,
    rangePreset: switch (state.rangePreset) {
      HostClubInsightsRangePreset.sevenDays =>
        HostAnalyticsRangePreset.sevenDays,
      HostClubInsightsRangePreset.thirtyDays =>
        HostAnalyticsRangePreset.thirtyDays,
      HostClubInsightsRangePreset.ninetyDays =>
        HostAnalyticsRangePreset.ninetyDays,
      HostClubInsightsRangePreset.month => HostAnalyticsRangePreset.month,
      HostClubInsightsRangePreset.custom => HostAnalyticsRangePreset.custom,
    },
    startDate: state.startDate,
    endDate: state.endDate,
    granularity: switch (state.granularity) {
      HostClubInsightsGranularity.day => HostAnalyticsGranularity.day,
      HostClubInsightsGranularity.week => HostAnalyticsGranularity.week,
      HostClubInsightsGranularity.month => HostAnalyticsGranularity.month,
    },
  );
}

class HostAnalyticsControls extends StatelessWidget {
  const HostAnalyticsControls({
    super.key,
    required this.rangePreset,
    required this.granularity,
    required this.customStartDate,
    required this.customEndDate,
    required this.selectedEventId,
    required this.onRangeChanged,
    required this.onGranularityChanged,
    required this.onPickStartDate,
    required this.onPickEndDate,
    required this.onClearEvent,
  });

  final HostClubInsightsRangePreset rangePreset;
  final HostClubInsightsGranularity granularity;
  final DateTime customStartDate;
  final DateTime customEndDate;
  final String? selectedEventId;
  final ValueChanged<HostClubInsightsRangePreset> onRangeChanged;
  final ValueChanged<HostClubInsightsGranularity> onGranularityChanged;
  final VoidCallback onPickStartDate;
  final VoidCallback onPickEndDate;
  final VoidCallback onClearEvent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchOptionGroup<HostClubInsightsRangePreset>(
          selected: rangePreset,
          onChanged: onRangeChanged,
          variant: CatchOptionGroupVariant.mono,
          options: const [
            CatchOption(
              value: HostClubInsightsRangePreset.sevenDays,
              label: '7D',
            ),
            CatchOption(
              value: HostClubInsightsRangePreset.thirtyDays,
              label: '30D',
            ),
            CatchOption(
              value: HostClubInsightsRangePreset.ninetyDays,
              label: '90D',
            ),
            CatchOption(
              value: HostClubInsightsRangePreset.month,
              label: 'MONTH',
            ),
            CatchOption(
              value: HostClubInsightsRangePreset.custom,
              label: 'CUSTOM',
            ),
          ],
        ),
        gapH12,
        CatchOptionGroup<HostClubInsightsGranularity>(
          selected: granularity,
          onChanged: onGranularityChanged,
          variant: CatchOptionGroupVariant.mono,
          options: const [
            CatchOption(value: HostClubInsightsGranularity.day, label: 'DAY'),
            CatchOption(value: HostClubInsightsGranularity.week, label: 'WEEK'),
            CatchOption(
              value: HostClubInsightsGranularity.month,
              label: 'MONTH',
            ),
          ],
        ),
        if (rangePreset == HostClubInsightsRangePreset.custom) ...[
          gapH12,
          Row(
            children: [
              Expanded(
                child: HostAnalyticsDateButton(
                  label: 'Start',
                  value: _formatAnalyticsDate(customStartDate),
                  onTap: onPickStartDate,
                ),
              ),
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: HostAnalyticsDateButton(
                  label: 'End',
                  value: _formatAnalyticsDate(customEndDate),
                  onTap: onPickEndDate,
                ),
              ),
            ],
          ),
        ],
        if (selectedEventId != null) ...[
          gapH12,
          CatchSurface(
            padding: CatchInsets.contentDense,
            borderColor: t.line,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Event scoped',
                    style: CatchTextStyles.labelM(context, color: t.ink2),
                  ),
                ),
                CatchButton(
                  label: 'All events',
                  onPressed: onClearEvent,
                  variant: CatchButtonVariant.ghost,
                  size: CatchButtonSize.sm,
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class HostAnalyticsDateButton extends StatelessWidget {
  const HostAnalyticsDateButton({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.contentDense,
      borderColor: t.line,
      onTap: onTap,
      child: Row(
        children: [
          Icon(CatchIcons.calendarTodayOutlined, size: CatchIcon.sm),
          const SizedBox(width: CatchSpacing.s2),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: CatchTextStyles.labelS(context, color: t.ink3),
                ),
                gapH2,
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.monoLabel(context, color: t.ink),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class HostAnalyticsReportView extends StatelessWidget {
  const HostAnalyticsReportView({
    super.key,
    required this.report,
    required this.selectedEventId,
    required this.onEventSelected,
    required this.onClearEvent,
  });

  final HostAnalyticsReport report;
  final String? selectedEventId;
  final ValueChanged<String> onEventSelected;
  final VoidCallback onClearEvent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchAnalyticsMetricGrid(
          metrics: [
            for (final metric in report.summaryCards)
              _hostMetricCardData(metric),
          ],
        ),
        gapH24,
        HostAnalyticsTrendPanel(points: report.trend),
        gapH24,
        HostAnalyticsEventList(
          events: report.topEvents,
          selectedEventId: selectedEventId,
          onEventSelected: onEventSelected,
          onClearEvent: onClearEvent,
        ),
        gapH24,
        HostAnalyticsReviewDiscoveryPanel(report: report),
        gapH24,
        CatchAnalyticsSection(
          label: 'Data quality',
          child: CatchAnalyticsDataQualityList(
            rows: [
              for (final row in report.dataQuality)
                _hostDataQualityRowData(row),
            ],
          ),
        ),
      ],
    );
  }
}

class HostAnalyticsTrendPanel extends StatelessWidget {
  const HostAnalyticsTrendPanel({super.key, required this.points});

  final List<HostAnalyticsTrendPoint> points;

  @override
  Widget build(BuildContext context) {
    final totalBookings = points.fold<num>(
      0,
      (sum, point) => sum + (point.metrics['bookings'] ?? 0),
    );
    final totalDemand = points.fold<num>(
      0,
      (sum, point) => sum + (point.metrics['demand'] ?? 0),
    );
    final maxBookings = points.fold<num>(0, (max, point) {
      final value = point.metrics['bookings'] ?? 0;
      return value > max ? value : max;
    });

    return CatchAnalyticsSection(
      label: 'Funnel',
      child: CatchSurface(
        padding: CatchInsets.content,
        borderColor: CatchTokens.of(context).line,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: CatchStatColumn(
                    label: 'Demand',
                    value: _formatCount(totalDemand),
                  ),
                ),
                Expanded(
                  child: CatchStatColumn(
                    label: 'Bookings',
                    value: _formatCount(totalBookings),
                  ),
                ),
              ],
            ),
            gapH16,
            SizedBox(
              height: CatchSpacing.s16,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final point in points.take(18)) ...[
                    if (point != points.first)
                      const SizedBox(width: CatchSpacing.micro6),
                    Expanded(
                      child: CatchAnalyticsBar(
                        value: point.metrics['bookings'] ?? 0,
                        maxValue: maxBookings,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HostAnalyticsEventList extends StatelessWidget {
  const HostAnalyticsEventList({
    super.key,
    required this.events,
    required this.selectedEventId,
    required this.onEventSelected,
    required this.onClearEvent,
  });

  final List<HostAnalyticsEventRow> events;
  final String? selectedEventId;
  final ValueChanged<String> onEventSelected;
  final VoidCallback onClearEvent;

  @override
  Widget build(BuildContext context) {
    return CatchAnalyticsSection(
      label: selectedEventId == null ? 'Top events' : 'Selected event',
      child: Column(
        children: [
          if (selectedEventId != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: CatchButton(
                label: 'All events',
                onPressed: onClearEvent,
                variant: CatchButtonVariant.ghost,
                size: CatchButtonSize.sm,
              ),
            ),
            gapH8,
          ],
          if (events.isEmpty)
            CatchSurface(
              padding: CatchInsets.content,
              borderColor: CatchTokens.of(context).line,
              child: Text(
                'No events in this range.',
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).ink2,
                ),
              ),
            )
          else
            for (final event in events.take(5))
              HostAnalyticsEventTile(
                event: event,
                divider: event != events.first,
                selected: event.eventId == selectedEventId,
                onTap: () => onEventSelected(event.eventId),
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
    required this.selected,
    required this.onTap,
  });

  final HostAnalyticsEventRow event;
  final bool divider;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      children: [
        if (divider) const CatchDivider(),
        CatchSurface(
          tone: CatchSurfaceTone.transparent,
          borderWidth: 0,
          padding: CatchInsets.contentVertical,
          onTap: onTap,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CatchIcons.eventOutlined, color: t.ink2),
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            event.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.labelL(
                              context,
                              color: t.ink,
                            ),
                          ),
                        ),
                        if (selected) ...[
                          const SizedBox(width: CatchSpacing.s2),
                          const CatchBadge(label: 'Selected'),
                        ],
                      ],
                    ),
                    gapH4,
                    Text(
                      EventFormatters.shortDate(event.startTime),
                      style: CatchTextStyles.supporting(context, color: t.ink3),
                    ),
                    gapH8,
                    Wrap(
                      spacing: CatchSpacing.s2,
                      runSpacing: CatchSpacing.s2,
                      children: [
                        CatchBadge(
                          label: _analyticsEventStatusLabel(event.status),
                          tone: _analyticsEventStatusTone(event.status),
                        ),
                        CatchBadge(label: '${event.demandCount} demand'),
                        CatchBadge(label: '${event.bookedCount} booked'),
                        if (event.waitlistedCount > 0)
                          CatchBadge(
                            label: '${event.waitlistedCount} waitlisted',
                            tone: CatchBadgeTone.warning,
                          ),
                        CatchBadge(
                          label: '${event.checkedInCount} attended',
                          tone: CatchBadgeTone.success,
                        ),
                        if (event.mutualMatchCount > 0)
                          CatchBadge(
                            label: '${event.mutualMatchCount} matches',
                            tone: CatchBadgeTone.brand,
                          ),
                        if (event.chatStartedCount > 0)
                          CatchBadge(label: '${event.chatStartedCount} chats'),
                        if (event.repeatAttendeeCount > 0)
                          CatchBadge(
                            label: '${event.repeatAttendeeCount} repeat',
                          ),
                        if (event.checkoutStartedCount > 0)
                          CatchBadge(
                            label: '${event.checkoutStartedCount} checkouts',
                          ),
                        if (event.checkoutDropoffCount > 0)
                          CatchBadge(
                            label: '${event.checkoutDropoffCount} drop-off',
                            tone: CatchBadgeTone.warning,
                          ),
                        if (event.paymentFailedCount > 0)
                          CatchBadge(
                            label: '${event.paymentFailedCount} failed',
                            tone: CatchBadgeTone.danger,
                          ),
                        if (event.paymentRefundedCount > 0)
                          CatchBadge(
                            label: '${event.paymentRefundedCount} refunded',
                            tone: CatchBadgeTone.warning,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CatchSpacing.s3),
              Text(
                EventFormatters.priceInPaise(
                  event.grossRevenueMinor,
                  currencyCode: event.currency,
                ),
                style: CatchTextStyles.monoLabel(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

String _formatAnalyticsDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '$day/$month/${date.year}';
}

DateTime _analyticsDateDaysAgo(int days) {
  final today = DateUtils.dateOnly(DateTime.now());
  return DateTime(today.year, today.month, today.day - days);
}

class HostAnalyticsReviewDiscoveryPanel extends StatelessWidget {
  const HostAnalyticsReviewDiscoveryPanel({super.key, required this.report});

  final HostAnalyticsReport report;

  @override
  Widget build(BuildContext context) {
    return CatchAnalyticsSection(
      label: 'Reviews and saves',
      child: CatchSurface(
        padding: CatchInsets.content,
        borderColor: CatchTokens.of(context).line,
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: CatchStatColumn(
                    label: 'New reviews',
                    value: '${report.reviewSummary.newReviews}',
                  ),
                ),
                Expanded(
                  child: CatchStatColumn(
                    label: 'Average rating',
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
                    label: 'Event saves',
                    value: '${report.discoverySummary.eventSaves}',
                  ),
                ),
                Expanded(
                  child: CatchStatColumn(
                    label: 'Responses',
                    value: '${report.reviewSummary.ownerResponseCount}',
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

IconData _metricIcon(String metricId) {
  return switch (metricId) {
    'listingViews' || 'eventViews' => CatchIcons.visibilityOutlined,
    'bookings' => CatchIcons.confirmationNumberOutlined,
    'attendanceRate' => CatchIcons.factCheckOutlined,
    'revenue' => CatchIcons.accountBalanceWalletOutlined,
    'checkoutDropoff' ||
    'checkoutConversionRate' => CatchIcons.paymentsOutlined,
    'newReviews' => CatchIcons.rateReviewOutlined,
    'connections' => CatchIcons.favoriteOutlineRounded,
    'chats' => CatchIcons.chatBubbleOutlineRounded,
    _ => CatchIcons.insightsOutlined,
  };
}

CatchMetricCardData _hostMetricCardData(HostAnalyticsMetricCard metric) {
  return CatchMetricCardData(
    icon: _metricIcon(metric.id),
    value: _formatMetricValue(metric),
    label: metric.label,
    caption: metric.caption,
    status: switch (metric.status) {
      HostAnalyticsMetricStatus.ready => CatchMetricStatus.ready,
      HostAnalyticsMetricStatus.partial => CatchMetricStatus.partial,
      HostAnalyticsMetricStatus.missing => CatchMetricStatus.missing,
    },
  );
}

CatchDataQualityRowData _hostDataQualityRowData(HostAnalyticsDataQuality row) {
  return CatchDataQualityRowData(
    status: switch (row.state) {
      HostAnalyticsDataQualityState.ok => CatchMetricStatus.ready,
      HostAnalyticsDataQualityState.partial => CatchMetricStatus.partial,
      HostAnalyticsDataQualityState.missing => CatchMetricStatus.missing,
    },
    detail: row.detail,
  );
}

String _formatMetricValue(HostAnalyticsMetricCard metric) {
  return switch (metric.unit) {
    HostAnalyticsMetricUnit.percent => '${metric.value.round()}%',
    HostAnalyticsMetricUnit.moneyMinor => EventFormatters.priceInPaise(
      metric.value.round(),
    ),
    HostAnalyticsMetricUnit.rating =>
      metric.value <= 0 ? '—' : metric.value.toStringAsFixed(1),
    HostAnalyticsMetricUnit.count => _formatCount(metric.value),
  };
}

String _analyticsEventStatusLabel(String status) {
  final normalized = status.trim();
  if (normalized.isEmpty || normalized == 'unknown') return 'Unknown';
  return normalized
      .split(RegExp(r'[_\-\s]+'))
      .where((part) => part.isNotEmpty)
      .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
      .join(' ');
}

CatchBadgeTone _analyticsEventStatusTone(String status) {
  return switch (status.trim().toLowerCase()) {
    'live' || 'active' || 'open' || 'published' => CatchBadgeTone.live,
    'completed' || 'past' => CatchBadgeTone.success,
    'draft' || 'pending' || 'scheduled' => CatchBadgeTone.warning,
    'cancelled' || 'canceled' => CatchBadgeTone.danger,
    _ => CatchBadgeTone.neutral,
  };
}

String _formatCount(num value) {
  final rounded = value.round();
  if (rounded >= 1000000) {
    return '${(rounded / 1000000).toStringAsFixed(1)}M';
  }
  if (rounded >= 1000) return '${(rounded / 1000).toStringAsFixed(1)}K';
  return '$rounded';
}
