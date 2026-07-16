part of '../host_operations_screen.dart';

class HostClubInsightsPane extends ConsumerStatefulWidget {
  const HostClubInsightsPane({
    super.key,
    required this.club,
    this.dedicated = false,
    this.onOpenEventReport,
  });

  final Club club;
  final bool dedicated;
  final ValueChanged<String>? onOpenEventReport;

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
        if (widget.dedicated) ...[
          HostAnalyticsRangeChip(
            label: _state.rangePreset.label,
            onTap: _showRangePicker,
          ),
          gapH16,
        ],
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
          showRangeOptions: !widget.dedicated,
          showGranularity: !widget.dedicated,
        ),
        if (!widget.dedicated ||
            _state.rangePreset == HostClubInsightsRangePreset.custom ||
            _state.selectedEventId != null)
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
            onEventSelected: widget.onOpenEventReport ?? _selectEventScope,
            onClearEvent: _clearEventScope,
            granularity: widget.dedicated ? _state.granularity : null,
            onGranularityChanged: widget.dedicated
                ? (granularity) => setState(
                    () => _state = _state.selectGranularity(granularity),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  Future<void> _showRangePicker() async {
    final selected = await showCatchBottomSheet<HostClubInsightsRangePreset>(
      context: context,
      builder: (context) =>
          HostAnalyticsRangeSheet(selected: _state.rangePreset),
    );
    if (selected == null || !mounted) return;
    setState(() => _state = _state.selectRange(selected));
  }

  Future<void> _pickCustomStartDate() async {
    final picked = await showCatchDatePicker(
      context: context,
      initialDate: _state.customStartDate,
      firstDate: _analyticsDateDaysAgo(366),
      lastDate: _state.customEndDate,
      title: context.l10n.hostsHostAnalyticsTitleStartDate,
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
      title: context.l10n.hostsHostAnalyticsTitleEndDate,
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
    this.showRangeOptions = true,
    this.showGranularity = true,
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
  final bool showRangeOptions;
  final bool showGranularity;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showRangeOptions)
          CatchOptionGroup<HostClubInsightsRangePreset>(
            selected: rangePreset,
            onChanged: onRangeChanged,
            variant: CatchOptionGroupVariant.mono,
            options: [
              CatchOption(
                value: HostClubInsightsRangePreset.sevenDays,
                label: context.l10n.hostsHostAnalyticsLabel7d,
              ),
              CatchOption(
                value: HostClubInsightsRangePreset.thirtyDays,
                label: context.l10n.hostsHostAnalyticsLabel30d,
              ),
              CatchOption(
                value: HostClubInsightsRangePreset.ninetyDays,
                label: context.l10n.hostsHostAnalyticsLabel90d,
              ),
              CatchOption(
                value: HostClubInsightsRangePreset.month,
                label: context.l10n.hostsHostAnalyticsLabelMonth,
              ),
              CatchOption(
                value: HostClubInsightsRangePreset.custom,
                label: context.l10n.hostsHostAnalyticsLabelCustom,
              ),
            ],
          ),
        if (showRangeOptions && showGranularity) gapH12,
        if (showGranularity)
          CatchOptionGroup<HostClubInsightsGranularity>(
            selected: granularity,
            onChanged: onGranularityChanged,
            variant: CatchOptionGroupVariant.mono,
            options: [
              CatchOption(
                value: HostClubInsightsGranularity.day,
                label: context.l10n.hostsHostAnalyticsLabelDay,
              ),
              CatchOption(
                value: HostClubInsightsGranularity.week,
                label: context.l10n.hostsHostAnalyticsLabelWeek,
              ),
              CatchOption(
                value: HostClubInsightsGranularity.month,
                label: context.l10n.hostsHostAnalyticsLabelMonth,
              ),
            ],
          ),
        if (rangePreset == HostClubInsightsRangePreset.custom) ...[
          gapH12,
          Row(
            children: [
              Expanded(
                child: HostAnalyticsDateButton(
                  label: context.l10n.hostsHostAnalyticsLabelStart,
                  value: _formatAnalyticsDate(customStartDate),
                  onTap: onPickStartDate,
                ),
              ),
              const SizedBox(width: CatchSpacing.s3),
              Expanded(
                child: HostAnalyticsDateButton(
                  label: context.l10n.hostsHostAnalyticsLabelEnd,
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
                    context.l10n.hostsHostAnalyticsTextEventScoped,
                    style: CatchTextStyles.labelM(context, color: t.ink2),
                  ),
                ),
                CatchButton(
                  label: context.l10n.hostsHostAnalyticsLabelAllEvents,
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

class HostAnalyticsRangeChip extends StatelessWidget {
  const HostAnalyticsRangeChip({
    super.key,
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      radius: CatchRadius.pill,
      borderColor: t.line2,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.micro10,
      ),
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(CatchIcons.calendarTodayOutlined, size: CatchIcon.sm),
          const SizedBox(width: CatchSpacing.s2),
          Text(label, style: CatchTextStyles.monoLabel(context, color: t.ink)),
          const SizedBox(width: CatchSpacing.s2),
          Icon(CatchIcons.expandMoreRounded, size: CatchIcon.sm),
        ],
      ),
    );
  }
}

class HostAnalyticsRangeSheet extends StatefulWidget {
  const HostAnalyticsRangeSheet({super.key, required this.selected});

  final HostClubInsightsRangePreset selected;

  @override
  State<HostAnalyticsRangeSheet> createState() =>
      _HostAnalyticsRangeSheetState();
}

class _HostAnalyticsRangeSheetState extends State<HostAnalyticsRangeSheet> {
  late HostClubInsightsRangePreset _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.selected;
  }

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      title: context.l10n.hostsHostAnalyticsTitleDateRange,
      subtitle: context
          .l10n
          .hostsHostAnalyticsSubtitleCompareOrganizerPerformanceOver,
      action: CatchButton(
        label: context.l10n.hostsHostAnalyticsLabelApplyRange,
        onPressed: () => Navigator.of(context).pop(_selected),
        fullWidth: true,
      ),
      child: CatchOptionGroup<HostClubInsightsRangePreset>(
        selected: _selected,
        onChanged: (selected) => setState(() => _selected = selected),
        variant: CatchOptionGroupVariant.mono,
        options: [
          CatchOption(
            value: HostClubInsightsRangePreset.sevenDays,
            label: context.l10n.hostsHostAnalyticsLabel7Days,
          ),
          CatchOption(
            value: HostClubInsightsRangePreset.thirtyDays,
            label: context.l10n.hostsHostAnalyticsLabel30Days,
          ),
          CatchOption(
            value: HostClubInsightsRangePreset.ninetyDays,
            label: context.l10n.hostsHostAnalyticsLabel90Days,
          ),
          CatchOption(
            value: HostClubInsightsRangePreset.month,
            label: context.l10n.hostsHostAnalyticsLabelMonth5406de,
          ),
          CatchOption(
            value: HostClubInsightsRangePreset.custom,
            label: context.l10n.hostsHostAnalyticsLabelCustoma46c31,
          ),
        ],
      ),
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
    this.granularity,
    this.onGranularityChanged,
  });

  final HostAnalyticsReport report;
  final String? selectedEventId;
  final ValueChanged<String> onEventSelected;
  final VoidCallback onClearEvent;
  final HostClubInsightsGranularity? granularity;
  final ValueChanged<HostClubInsightsGranularity>? onGranularityChanged;

  @override
  Widget build(BuildContext context) {
    return CatchSectionStack(
      padding: EdgeInsets.zero,
      children: [
        CatchSection.divided(
          first: true,
          child: CatchAnalyticsMetricGrid(
            metrics: [
              for (final metric in report.summaryCards)
                _hostMetricCardData(metric),
            ],
          ),
        ),
        HostAnalyticsTrendPanel(
          points: report.trend,
          granularity: granularity,
          onGranularityChanged: onGranularityChanged,
        ),
        HostAnalyticsEventList(
          events: report.topEvents,
          selectedEventId: selectedEventId,
          onEventSelected: onEventSelected,
          onClearEvent: onClearEvent,
        ),
        HostAnalyticsReviewDiscoveryPanel(report: report),
        CatchSection.divided(
          title: context.l10n.hostsHostAnalyticsLabelDataQuality,
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
  const HostAnalyticsTrendPanel({
    super.key,
    required this.points,
    this.granularity,
    this.onGranularityChanged,
  });

  final List<HostAnalyticsTrendPoint> points;
  final HostClubInsightsGranularity? granularity;
  final ValueChanged<HostClubInsightsGranularity>? onGranularityChanged;

  @override
  Widget build(BuildContext context) {
    final totalBookings = points.fold<num>(
      0,
      (sum, point) =>
          sum +
          (point.metrics[context.l10n.hostsHostAnalyticsVisiblecopyBookings] ??
              0),
    );
    final totalDemand = points.fold<num>(
      0,
      (sum, point) =>
          sum +
          (point.metrics[context.l10n.hostsHostAnalyticsVisiblecopyDemand] ??
              0),
    );
    final maxValue = points.fold<num>(0, (max, point) {
      final value = [
        point.metrics[context.l10n.hostsHostAnalyticsVisiblecopyBookings] ?? 0,
        point.metrics[context.l10n.hostsHostAnalyticsVisiblecopyDemand] ?? 0,
      ].reduce((a, b) => a > b ? a : b);
      return value > max ? value : max;
    });

    return CatchSection.divided(
      title: context.l10n.hostsHostAnalyticsLabelTrendBookingsVsDemand,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (granularity != null && onGranularityChanged != null) ...[
            CatchOptionGroup<HostClubInsightsGranularity>(
              selected: granularity!,
              onChanged: onGranularityChanged!,
              options: [
                CatchOption(
                  value: HostClubInsightsGranularity.day,
                  label: context.l10n.hostsHostAnalyticsLabelDaycb7256,
                ),
                CatchOption(
                  value: HostClubInsightsGranularity.week,
                  label: context.l10n.hostsHostAnalyticsLabelWeek4cce87,
                ),
                CatchOption(
                  value: HostClubInsightsGranularity.month,
                  label: context.l10n.hostsHostAnalyticsLabelMonth5406de,
                ),
              ],
            ),
            gapH12,
          ],
          CatchSurface(
            padding: CatchInsets.content,
            borderColor: CatchTokens.of(context).line,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: CatchStatColumn(
                        label: context.l10n.hostsHostAnalyticsLabelDemand,
                        value: _formatCount(totalDemand),
                      ),
                    ),
                    Expanded(
                      child: CatchStatColumn(
                        label: context.l10n.hostsHostAnalyticsLabelBookings,
                        value: _formatCount(totalBookings),
                      ),
                    ),
                  ],
                ),
                gapH16,
                SizedBox(
                  height: CatchSpacing.s16,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final contentWidth = math
                          .max(
                            constraints.maxWidth,
                            points.length * CatchSpacing.s4,
                          )
                          .toDouble();
                      return SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        reverse: contentWidth > constraints.maxWidth,
                        child: SizedBox(
                          width: contentWidth,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              for (
                                var index = 0;
                                index < points.length;
                                index++
                              ) ...[
                                if (index > 0)
                                  const SizedBox(width: CatchSpacing.micro6),
                                Expanded(
                                  child: HostAnalyticsDualBar(
                                    demand:
                                        points[index].metrics[context
                                            .l10n
                                            .hostsHostAnalyticsVisiblecopyDemand] ??
                                        0,
                                    bookings:
                                        points[index].metrics[context
                                            .l10n
                                            .hostsHostAnalyticsVisiblecopyBookings] ??
                                        0,
                                    maxValue: maxValue,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
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

class HostAnalyticsDualBar extends StatelessWidget {
  const HostAnalyticsDualBar({
    super.key,
    required this.demand,
    required this.bookings,
    required this.maxValue,
  });

  final num demand;
  final num bookings;
  final num maxValue;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final denominator = maxValue <= 0 ? 1.0 : maxValue.toDouble();
    final demandFactor = (demand.toDouble() / denominator).clamp(0.0, 1.0);
    final bookingFactor = (bookings.toDouble() / denominator).clamp(0.0, 1.0);
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        FractionallySizedBox(
          heightFactor: demandFactor,
          widthFactor: 1,
          alignment: Alignment.bottomCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.ink.withValues(alpha: CatchOpacity.subtleFill),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(CatchSpacing.s1),
              ),
            ),
          ),
        ),
        FractionallySizedBox(
          heightFactor: bookingFactor,
          widthFactor: 0.5,
          alignment: Alignment.bottomCenter,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: t.ink.withValues(alpha: CatchOpacity.scrimFill),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(CatchSpacing.s1),
              ),
            ),
          ),
        ),
      ],
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
    return CatchSection.divided(
      title: selectedEventId == null
          ? context.l10n.hostsHostAnalyticsLabelTopEvents
          : context.l10n.hostsHostAnalyticsLabelSelectedEvent,
      child: Column(
        children: [
          if (selectedEventId != null) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: CatchButton(
                label: context.l10n.hostsHostAnalyticsLabelAllEvents,
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
                context.l10n.hostsHostAnalyticsTextNoEventsInThis,
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
                          CatchBadge(
                            label: context.l10n.hostsHostAnalyticsLabelSelected,
                          ),
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
                        CatchBadge(
                          label: context.l10n
                              .hostsHostAnalyticsLabelDemandcountDemand(
                                demandCount: event.demandCount,
                              ),
                        ),
                        CatchBadge(
                          label: context.l10n
                              .hostsHostAnalyticsLabelBookedcountBooked(
                                bookedCount: event.bookedCount,
                              ),
                        ),
                        if (event.waitlistedCount > 0)
                          CatchBadge(
                            label: context.l10n
                                .hostsHostAnalyticsLabelWaitlistedcountWaitlisted(
                                  waitlistedCount: event.waitlistedCount,
                                ),
                            tone: CatchBadgeTone.warning,
                          ),
                        CatchBadge(
                          label: context.l10n
                              .hostsHostAnalyticsLabelCheckedincountAttended(
                                checkedInCount: event.checkedInCount,
                              ),
                          tone: CatchBadgeTone.success,
                        ),
                        if (event.mutualMatchCount > 0)
                          CatchBadge(
                            label: context.l10n
                                .hostsHostAnalyticsLabelMutualmatchcountMatches(
                                  mutualMatchCount: event.mutualMatchCount,
                                ),
                            tone: CatchBadgeTone.brand,
                          ),
                        if (event.chatStartedCount > 0)
                          CatchBadge(
                            label: context.l10n
                                .hostsHostAnalyticsLabelChatstartedcountChats(
                                  chatStartedCount: event.chatStartedCount,
                                ),
                          ),
                        if (event.repeatAttendeeCount > 0)
                          CatchBadge(
                            label: context.l10n
                                .hostsHostAnalyticsLabelRepeatattendeecountRepeat(
                                  repeatAttendeeCount:
                                      event.repeatAttendeeCount,
                                ),
                          ),
                        if (event.checkoutStartedCount > 0)
                          CatchBadge(
                            label: context.l10n
                                .hostsHostAnalyticsLabelCheckoutstartedcountCheckouts(
                                  checkoutStartedCount:
                                      event.checkoutStartedCount,
                                ),
                          ),
                        if (event.checkoutDropoffCount > 0)
                          CatchBadge(
                            label: context.l10n
                                .hostsHostAnalyticsLabelCheckoutdropoffcountDropOff(
                                  checkoutDropoffCount:
                                      event.checkoutDropoffCount,
                                ),
                            tone: CatchBadgeTone.warning,
                          ),
                        if (event.paymentFailedCount > 0)
                          CatchBadge(
                            label: context.l10n
                                .hostsHostAnalyticsLabelPaymentfailedcountFailed(
                                  paymentFailedCount: event.paymentFailedCount,
                                ),
                            tone: CatchBadgeTone.danger,
                          ),
                        if (event.paymentRefundedCount > 0)
                          CatchBadge(
                            label: context.l10n
                                .hostsHostAnalyticsLabelPaymentrefundedcountRefunded(
                                  paymentRefundedCount:
                                      event.paymentRefundedCount,
                                ),
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
    return CatchSection.divided(
      title: context.l10n.hostsHostAnalyticsLabelReviewsAndSaves,
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
                    value: context.l10n.hostsHostAnalyticsVisiblecopyNewreviews(
                      newReviews: report.reviewSummary.newReviews,
                    ),
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
                    label: context.l10n.hostsHostAnalyticsLabelEventSaves,
                    value: context.l10n.hostsHostAnalyticsVisiblecopyEventsaves(
                      eventSaves: report.discoverySummary.eventSaves,
                    ),
                  ),
                ),
                Expanded(
                  child: CatchStatColumn(
                    label: context.l10n.hostsHostAnalyticsLabelResponses,
                    value: context.l10n
                        .hostsHostAnalyticsVisiblecopyOwnerresponsecount(
                          ownerResponseCount:
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
    'live' || 'active' || 'open' || 'published' => CatchBadgeTone.brand,
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
