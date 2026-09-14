import 'dart:async';

import 'package:catch_dating_app/design_fixtures/host_operations_fixtures.dart';
import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import 'preview.dart';
import 'shell_fixture.dart';

@widgetbook.UseCase(
  name: 'Insights scorecard states',
  type: HostClubInsightsPane,
  path: '[P1 product surfaces]/Host operations',
)
Widget hostInsightsScorecardStates(BuildContext context) {
  return WidgetbookHostCatalog(
    title: 'HostClubInsightsPane',
    contractId: 'screen.host.clubs.insights',
    children: [
      WidgetbookHostStateCard(
        label: 'report loading',
        child: const WidgetbookHostDeviceFrame(
          child: WidgetbookHostShellScope(
            analyticsRepository: _HostLoadingAnalyticsRepository(),
            child: HostClubsScreen(initialTab: HostClubTab.insights),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'loaded narrative scorecard',
        child: WidgetbookHostDeviceFrame(
          child: const WidgetbookHostShellScope(
            child: HostClubsScreen(initialTab: HostClubTab.insights),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'empty range',
        child: WidgetbookHostDeviceFrame(
          child: WidgetbookHostShellScope(
            analyticsRepository: HostFixtureAnalyticsRepository(
              report: _emptyHostAnalyticsReport(),
            ),
            child: const HostClubsScreen(initialTab: HostClubTab.insights),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'partial data',
        child: WidgetbookHostDeviceFrame(
          child: WidgetbookHostShellScope(
            analyticsRepository: HostFixtureAnalyticsRepository(
              report: _partialHostAnalyticsReport(),
            ),
            child: const HostClubsScreen(initialTab: HostClubTab.insights),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'Coach recommendations',
        child: WidgetbookHostDeviceFrame(
          child: WidgetbookHostShellScope(
            analyticsRepository: HostFixtureAnalyticsRepository(
              report: _coachHostAnalyticsReport(),
            ),
            child: const HostClubsScreen(initialTab: HostClubTab.insights),
          ),
        ),
      ),
      WidgetbookHostStateCard(
        label: 'text scale 2.0',
        child: WidgetbookHostDeviceFrame(
          child: WidgetbookMediaOverride(
            textScaler: const TextScaler.linear(2),
            child: const WidgetbookHostShellScope(
              child: HostClubsScreen(initialTab: HostClubTab.insights),
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _hostAnalyticsExactCatalog(BuildContext context, String focus) {
  return WidgetbookHostCatalog(
    title: focus,
    contractId:
        'component.host.analytics.${widgetbookHostComponentSlug(focus)}',
    children: [
      WidgetbookHostStateCard(
        label: 'exact component',
        child: WidgetbookHostComponentFrame(
          child: _hostAnalyticsPreviewFor(focus),
        ),
      ),
    ],
  );
}

Widget _hostAnalyticsPreviewFor(String focus) {
  final report = HostOperationsFixtures.analyticsReport;
  return switch (focus) {
    'CatchBarIndicator' => const SizedBox(
      height: WidgetbookPreviewLayout.smallPreviewExtent,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(child: CatchBarIndicator(value: 18, maxValue: 42)),
          gapW8,
          Expanded(child: CatchBarIndicator(value: 32, maxValue: 42)),
          gapW8,
          Expanded(child: CatchBarIndicator(value: 42, maxValue: 42)),
        ],
      ),
    ),
    'HostAnalyticsEventList' => HostAnalyticsEventList(
      events: report.topEvents,
      onOpenEventReport: (_) {},
      onOpenAllEvents: () {},
    ),
    'HostAnalyticsEventTile' => HostAnalyticsEventTile(
      event: report.topEvents.first,
      onTap: () {},
    ),
    'HostAnalyticsReportView' => HostAnalyticsReportView(
      report: report,
      rangePreset: HostClubInsightsRangePreset.thirtyDays,
      currencyCode: 'INR',
      allTimeOverview: const Text('All-time club metrics'),
      onRangeChanged: (_) {},
      onOpenEventReport: (_) {},
      onOpenAllEvents: () {},
      onOpenEventDefaults: () {},
    ),
    'HostAnalyticsReviewsPanel' => HostAnalyticsReviewsPanel(report: report),
    'HostAnalyticsTrendPanel' => HostAnalyticsTrendPanel(
      points: report.trend,
      granularity: HostAnalyticsGranularity.week,
    ),
    'HostAnalyticsDualBar' => HostAnalyticsDualBar(
      point: report.trend.first,
      maxValue: 60,
      label: '2 Jun',
      selected: true,
      onTap: () {},
    ),
    _ => Text('No exact preview registered for $focus.'),
  };
}

HostAnalyticsReport _emptyHostAnalyticsReport() {
  final source = HostOperationsFixtures.analyticsReport;
  return HostAnalyticsReport(
    generatedAt: source.generatedAt,
    timezone: source.timezone,
    summaryCards: [
      for (final card in source.summaryCards)
        HostAnalyticsMetricCard(
          id: card.id,
          label: card.label,
          value: 0,
          unit: card.unit,
          status: HostAnalyticsMetricStatus.missing,
        ),
    ],
    trend: const [],
    topEvents: const [],
    reviewSummary: const HostAnalyticsReviewSummary(
      newReviews: 0,
      publishedReviews: 0,
      verifiedReviews: 0,
      publicReviews: 0,
      ownerResponseCount: 0,
      averageRating: 0,
    ),
    discoverySummary: const HostAnalyticsDiscoverySummary(
      listingViews: 0,
      searchAppearances: 0,
      eventViews: 0,
      organizerSaves: 0,
      eventSaves: 0,
      contactClicks: 0,
      claimClicks: 0,
      outboundClicks: 0,
    ),
    dataQuality: const [
      HostAnalyticsDataQuality(
        id: 'mart',
        state: HostAnalyticsDataQualityState.missing,
        detail: 'Fixture data is unavailable.',
      ),
    ],
  );
}

HostAnalyticsReport _partialHostAnalyticsReport() {
  final source = HostOperationsFixtures.analyticsReport;
  return HostAnalyticsReport(
    generatedAt: source.generatedAt,
    timezone: source.timezone,
    summaryCards: [
      for (final indexed in source.summaryCards.indexed)
        HostAnalyticsMetricCard(
          id: indexed.$2.id,
          label: indexed.$2.label,
          value: indexed.$2.value,
          previousValue: indexed.$2.previousValue,
          unit: indexed.$2.unit,
          status: indexed.$1 == 0
              ? HostAnalyticsMetricStatus.partial
              : indexed.$2.status,
        ),
    ],
    trend: source.trend,
    topEvents: source.topEvents,
    reviewSummary: source.reviewSummary,
    discoverySummary: source.discoverySummary,
    dataQuality: const [
      HostAnalyticsDataQuality(
        id: 'payments',
        state: HostAnalyticsDataQualityState.partial,
        detail: 'Payment metrics are still syncing.',
      ),
    ],
  );
}

HostAnalyticsReport _coachHostAnalyticsReport() {
  final source = HostOperationsFixtures.analyticsReport;
  return HostAnalyticsReport(
    generatedAt: source.generatedAt,
    timezone: source.timezone,
    summaryCards: [
      for (final card in source.summaryCards)
        HostAnalyticsMetricCard(
          id: card.id,
          label: card.label,
          value: card.id == HostAnalyticsMetricIds.attendanceRate
              ? 59
              : card.value,
          previousValue: card.previousValue,
          unit: card.unit,
          status: card.status,
        ),
    ],
    trend: source.trend,
    topEvents: source.topEvents,
    reviewSummary: source.reviewSummary,
    discoverySummary: source.discoverySummary,
    dataQuality: source.dataQuality,
  );
}

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: CatchBarIndicator,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictCatchBarIndicatorCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'CatchBarIndicator');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsEventList,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsEventListCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsEventList');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsEventTile,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsEventTileCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsEventTile');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsReportView,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsReportViewCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsReportView');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsReviewsPanel,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsReviewsPanelCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsReviewsPanel');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsTrendPanel,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsTrendPanelCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsTrendPanel');

@widgetbook.UseCase(
  name: 'Exact catalog',
  type: HostAnalyticsDualBar,
  path: '[P1 product surfaces]/Host operations/Strict coverage',
)
Widget hostStrictHostAnalyticsDualBarCatalogStates(BuildContext context) =>
    _hostAnalyticsExactCatalog(context, 'HostAnalyticsDualBar');

final class _HostLoadingAnalyticsRepository implements HostAnalyticsRepository {
  const _HostLoadingAnalyticsRepository();

  @override
  Future<HostAnalyticsReport> getHostAnalytics(HostAnalyticsQuery query) {
    return Completer<HostAnalyticsReport>().future;
  }
}
