import 'dart:async';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/user_analytics/data/user_analytics_repository.dart';
import 'package:catch_dating_app/user_analytics/presentation/user_analytics_panel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'UserAnalyticsPanel renders a report-shaped skeleton while loading',
    (tester) async {
      final repository = _LoadingUserAnalyticsRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userAnalyticsRepositoryProvider.overrideWithValue(repository),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            home: const Scaffold(
              body: SingleChildScrollView(child: UserAnalyticsPanel()),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(CatchSkeleton), findsWidgets);
      expect(find.text('PROFILE INSIGHTS'), findsOneWidget);
    },
  );
}

class _LoadingUserAnalyticsRepository extends Fake
    implements UserAnalyticsRepository {
  @override
  Future<UserAnalyticsReport> getUserAnalytics(UserAnalyticsQuery query) {
    return Completer<UserAnalyticsReport>().future;
  }
}
