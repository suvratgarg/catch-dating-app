import 'dart:async';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/labs/design_fixtures/profile_surface_fixtures.dart';
import 'package:catch_dating_app/user_analytics/data/user_analytics_repository.dart';
import 'package:catch_dating_app/user_analytics/presentation/user_analytics_panel.dart';
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
