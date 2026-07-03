import 'dart:async';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_analytics_bar.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/labs/design_fixtures/profile_surface_fixtures.dart';
import 'package:catch_dating_app/user_analytics/data/user_analytics_repository.dart';
import 'package:catch_dating_app/user_analytics/shared/user_analytics_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Panel states',
  type: UserAnalyticsPanel,
  path: '[P1 product surfaces]/User analytics',
)
Widget userAnalyticsPanelStates(BuildContext context) {
  return _UserAnalyticsCatalog(
    title: 'UserAnalyticsPanel',
    contractId: 'component.profile.user_analytics',
    children: [
      _StateCard(
        label: 'loaded report',
        child: _DeviceFrame(
          child: _UserAnalyticsScope(
            repository: ProfileFixtureUserAnalyticsRepository(
              report: ProfileSurfaceFixtures.analyticsReport,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'empty report',
        child: _DeviceFrame(
          child: _UserAnalyticsScope(
            repository: ProfileFixtureUserAnalyticsRepository(
              report: ProfileSurfaceFixtures.emptyAnalyticsReport,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'loading skeleton',
        child: _DeviceFrame(
          child: _UserAnalyticsScope(
            repository: _LoadingUserAnalyticsRepository(),
          ),
        ),
      ),
      _StateCard(
        label: 'load error',
        child: _DeviceFrame(
          child: _UserAnalyticsScope(
            repository: _ErrorUserAnalyticsRepository(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Report states',
  type: UserAnalyticsReportView,
  path: '[P1 product surfaces]/User analytics',
)
Widget userAnalyticsReportViewStates(BuildContext context) {
  return _UserAnalyticsCatalog(
    title: 'UserAnalyticsReportView',
    contractId: 'component.profile.user_analytics.report',
    children: [
      _StateCard(
        label: 'loaded',
        child: UserAnalyticsReportView(
          report: ProfileSurfaceFixtures.analyticsReport,
        ),
      ),
      _StateCard(
        label: 'empty',
        child: UserAnalyticsReportView(
          report: ProfileSurfaceFixtures.emptyAnalyticsReport,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Empty state',
  type: UserAnalyticsEmptyState,
  path: '[P1 product surfaces]/User analytics',
)
Widget userAnalyticsEmptyState(BuildContext context) {
  return const _UserAnalyticsCatalog(
    title: 'UserAnalyticsEmptyState',
    contractId: 'component.profile.user_analytics.empty',
    children: [
      _StateCard(label: 'no measurable data', child: UserAnalyticsEmptyState()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Report skeleton',
  type: UserAnalyticsReportSkeleton,
  path: '[P1 product surfaces]/User analytics',
)
Widget userAnalyticsReportSkeleton(BuildContext context) {
  return const _UserAnalyticsCatalog(
    title: 'UserAnalyticsReportSkeleton',
    contractId: 'component.profile.user_analytics.skeleton',
    children: [
      _StateCard(label: 'loading report', child: UserAnalyticsReportSkeleton()),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Trend panel states',
  type: UserAnalyticsTrendPanel,
  path: '[P1 product surfaces]/User analytics',
)
Widget userAnalyticsTrendPanelStates(BuildContext context) {
  return _UserAnalyticsCatalog(
    title: 'UserAnalyticsTrendPanel',
    contractId: 'component.profile.user_analytics.trend_panel',
    children: [
      _StateCard(
        label: 'trend',
        child: UserAnalyticsTrendPanel(
          points: ProfileSurfaceFixtures.analyticsReport.trend,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Bar states',
  type: CatchAnalyticsBar,
  path: '[P1 product surfaces]/User analytics',
)
Widget userAnalyticsBarStates(BuildContext context) {
  return const _UserAnalyticsCatalog(
    title: 'CatchAnalyticsBar',
    contractId: 'component.profile.user_analytics.bar',
    children: [
      _StateCard(
        label: 'range',
        child: SizedBox(
          height: 96,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(child: CatchAnalyticsBar(value: 0, maxValue: 12)),
              SizedBox(width: CatchSpacing.micro6),
              Expanded(child: CatchAnalyticsBar(value: 3, maxValue: 12)),
              SizedBox(width: CatchSpacing.micro6),
              Expanded(child: CatchAnalyticsBar(value: 8, maxValue: 12)),
              SizedBox(width: CatchSpacing.micro6),
              Expanded(child: CatchAnalyticsBar(value: 12, maxValue: 12)),
            ],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Tips panel states',
  type: UserAnalyticsTipsPanel,
  path: '[P1 product surfaces]/User analytics',
)
Widget userAnalyticsTipsPanelStates(BuildContext context) {
  return _UserAnalyticsCatalog(
    title: 'UserAnalyticsTipsPanel',
    contractId: 'component.profile.user_analytics.tips_panel',
    children: [
      _StateCard(
        label: 'coaching tips',
        child: UserAnalyticsTipsPanel(
          tips: ProfileSurfaceFixtures.analyticsReport.coachingTipRefs,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Tip row states',
  type: UserAnalyticsTipRow,
  path: '[P1 product surfaces]/User analytics',
)
Widget userAnalyticsTipRowStates(BuildContext context) {
  return _UserAnalyticsCatalog(
    title: 'UserAnalyticsTipRow',
    contractId: 'component.profile.user_analytics.tip_row',
    children: [
      _StateCard(
        label: 'prompt refresh',
        child: UserAnalyticsTipRow(
          tip: ProfileSurfaceFixtures.analyticsReport.coachingTipRefs.first,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Data quality panel states',
  type: UserAnalyticsDataQualityPanel,
  path: '[P1 product surfaces]/User analytics',
)
Widget userAnalyticsDataQualityPanelStates(BuildContext context) {
  return _UserAnalyticsCatalog(
    title: 'UserAnalyticsDataQualityPanel',
    contractId: 'component.profile.user_analytics.data_quality_panel',
    children: [
      _StateCard(
        label: 'quality rows',
        child: UserAnalyticsDataQualityPanel(
          rows: ProfileSurfaceFixtures.analyticsReport.dataQuality,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Data quality row states',
  type: UserAnalyticsDataQualityRow,
  path: '[P1 product surfaces]/User analytics',
)
Widget userAnalyticsDataQualityRowStates(BuildContext context) {
  final rows = ProfileSurfaceFixtures.analyticsReport.dataQuality;
  return _UserAnalyticsCatalog(
    title: 'UserAnalyticsDataQualityRow',
    contractId: 'component.profile.user_analytics.data_quality_row',
    children: [
      _StateCard(
        label: 'ready',
        child: UserAnalyticsDataQualityRow(row: rows[0]),
      ),
      _StateCard(
        label: 'partial',
        child: UserAnalyticsDataQualityRow(row: rows[1]),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Inline stat states',
  type: CatchStatColumn,
  path: '[P1 product surfaces]/User analytics',
)
Widget userAnalyticsInlineStatStates(BuildContext context) {
  return const _UserAnalyticsCatalog(
    title: 'CatchStatColumn',
    contractId: 'component.profile.user_analytics.inline_stat',
    children: [
      _StateCard(
        label: 'count',
        child: CatchStatColumn(label: 'Mutual catches', value: '9'),
      ),
    ],
  );
}

class _UserAnalyticsScope extends StatelessWidget {
  const _UserAnalyticsScope({required this.repository});

  final UserAnalyticsRepository repository;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        userAnalyticsRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: CatchInsets.pageBody,
              child: const UserAnalyticsPanel(),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadingUserAnalyticsRepository implements UserAnalyticsRepository {
  @override
  Future<UserAnalyticsReport> getUserAnalytics(UserAnalyticsQuery query) {
    return Completer<UserAnalyticsReport>().future;
  }
}

class _ErrorUserAnalyticsRepository implements UserAnalyticsRepository {
  @override
  Future<UserAnalyticsReport> getUserAnalytics(UserAnalyticsQuery query) async {
    throw StateError('User analytics failed');
  }
}

class _UserAnalyticsCatalog extends StatelessWidget {
  const _UserAnalyticsCatalog({
    required this.title,
    required this.contractId,
    required this.children,
  });

  final String title;
  final String contractId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: ListView(
          padding: CatchInsets.pageBody,
          children: [
            Text(title, style: CatchTextStyles.titleL(context, color: t.ink)),
            gapH4,
            Text(
              contractId,
              style: CatchTextStyles.monoLabel(context, color: t.ink2),
            ),
            gapH16,
            Wrap(
              spacing: CatchSpacing.s4,
              runSpacing: CatchSpacing.s4,
              children: children,
            ),
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
    return SizedBox(
      width: 390,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: CatchTextStyles.labelM(context, color: t.ink2)),
          gapH8,
          child,
        ],
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: SizedBox(width: 390, height: 720, child: child),
    );
  }
}
