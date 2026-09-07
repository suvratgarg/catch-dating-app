import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

const _tilePreviewWidth = CatchLayout.analyticsMetricPreviewWidth;
const _gridPreviewWidth = CatchLayout.confirmDialogMaxWidth;

final _readyAnalyticsMetric = CatchMetricCardData(
  partialBadgeLabel: 'Partial',
  missingBadgeLabel: 'Missing',
  icon: CatchIcons.visibilityOutlined,
  value: '12.4K',
  label: 'Profile views',
  caption: 'Last 30 days',
);

final _partialAnalyticsMetric = CatchMetricCardData(
  partialBadgeLabel: 'Partial',
  missingBadgeLabel: 'Missing',
  icon: CatchIcons.confirmationNumberOutlined,
  value: '126',
  label: 'Bookings',
  caption: 'Confirmed seats',
  status: CatchMetricStatus.partial,
);

final _missingAnalyticsMetric = CatchMetricCardData(
  partialBadgeLabel: 'Partial',
  missingBadgeLabel: 'Missing',
  icon: CatchIcons.accountBalanceWalletOutlined,
  value: '--',
  label: 'Revenue',
  caption: 'Connect payments to report revenue.',
  status: CatchMetricStatus.missing,
);

final _analyticsMetrics = [
  _readyAnalyticsMetric,
  _partialAnalyticsMetric,
  _missingAnalyticsMetric,
];

@widgetbook.UseCase(
  name: 'Tile states',
  type: CatchAnalyticsMetricTile,
  path: '[Core primitives]/Analytics kit',
)
Widget catchAnalyticsMetricTileStates(BuildContext context) {
  return _AnalyticsKitCatalog(
    title: 'CatchAnalyticsMetricTile',
    children: [
      _StateCard(
        label: 'ready',
        child: SizedBox(
          width: _tilePreviewWidth,
          child: CatchAnalyticsMetricTile(data: _readyAnalyticsMetric),
        ),
      ),
      _StateCard(
        label: 'partial',
        child: SizedBox(
          width: _tilePreviewWidth,
          child: CatchAnalyticsMetricTile(data: _partialAnalyticsMetric),
        ),
      ),
      _StateCard(
        label: 'missing',
        child: SizedBox(
          width: _tilePreviewWidth,
          child: CatchAnalyticsMetricTile(data: _missingAnalyticsMetric),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Grid states',
  type: CatchAnalyticsMetricGrid,
  path: '[Core primitives]/Analytics kit',
)
Widget catchAnalyticsMetricGridStates(BuildContext context) {
  return _AnalyticsKitCatalog(
    title: 'CatchAnalyticsMetricGrid',
    children: [
      _StateCard(
        label: 'two-column metrics',
        child: SizedBox(
          width: _gridPreviewWidth,
          child: CatchAnalyticsMetricGrid(metrics: _analyticsMetrics),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Ready, partial and missing data',
  type: CatchAnalyticsDataQualityList,
  path: '[Core primitives]/Analytics kit',
)
Widget catchAnalyticsDataQualityStates(
  BuildContext context,
) => const WidgetbookCatalogFrame(
  title: 'Analytics data quality',
  catalogId: 'catch.analytics_data_quality',
  children: [
    CatchAnalyticsDataQualityList(
      rows: [
        CatchDataQualityRowData(
          status: CatchMetricStatus.ready,
          detail: 'Attendance data is ready.',
        ),
        CatchDataQualityRowData(
          status: CatchMetricStatus.partial,
          detail: 'Recent bookings are still being counted.',
        ),
        CatchDataQualityRowData(
          status: CatchMetricStatus.missing,
          detail:
              'Revenue is unavailable until a payment account is connected.',
        ),
      ],
    ),
  ],
);

@widgetbook.UseCase(
  name: 'Analytics composition',
  type: CatchSection,
  path: '[Core primitives]/Analytics kit',
)
Widget catchAnalyticsSectionComposition(BuildContext context) {
  return _AnalyticsKitCatalog(
    title: 'CatchSection analytics composition',
    children: [
      _StateCard(
        label: 'labeled analytics group',
        child: SizedBox(
          width: _gridPreviewWidth,
          child: CatchSection.divided(
            title: 'Funnel',
            first: true,
            child: CatchAnalyticsMetricGrid(metrics: _analyticsMetrics),
          ),
        ),
      ),
    ],
  );
}

class _AnalyticsKitCatalog extends StatelessWidget {
  const _AnalyticsKitCatalog({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.content,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleLarge),
            gapH20,
            for (final child in children) ...[child, gapH16],
          ],
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.titleSmall),
          gapH12,
          child,
        ],
      ),
    );
  }
}
