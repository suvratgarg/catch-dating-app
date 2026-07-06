import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('guest app shell waits for auth before showing phone CTA', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: Routes.exploreScreen.path,
      routes: [
        GoRoute(
          path: Routes.authScreen.path,
          builder: (_, _) =>
              const Text('Auth', textDirection: TextDirection.ltr),
        ),
        StatefulShellRoute.indexedStack(
          builder: (_, _, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            _branch(Routes.dashboardScreen.path, 'Home'),
            _branch(Routes.exploreScreen.path, 'Explore'),
            _branch(Routes.matchesListScreen.path, 'Chats'),
            _branch(Routes.profileScreen.path, 'Profile'),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(const AsyncLoading<String?>()),
          watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
          appConnectivityProvider.overrideWith(
            (ref) => Stream.value(const [ConnectivityResult.wifi]),
          ),
          appAnalyticsProvider.overrideWithValue(
            AppAnalytics(
              reporter: _NoOpAnalyticsReporter(),
              shouldCollect: false,
            ),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pump();

    expect(find.text('Continue with phone'), findsNothing);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Chats'), findsNothing);
    expect(find.text('Profile'), findsNothing);
  });

  testWidgets('guest app shell shows phone CTA without tab destinations', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: Routes.exploreScreen.path,
      routes: [
        GoRoute(
          path: Routes.authScreen.path,
          builder: (_, state) => Text(
            'Auth ${state.uri.queryParameters['from']}',
            textDirection: TextDirection.ltr,
          ),
        ),
        StatefulShellRoute.indexedStack(
          builder: (_, _, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            _branch(Routes.dashboardScreen.path, 'Home'),
            _branch(Routes.exploreScreen.path, 'Explore'),
            _branch(Routes.matchesListScreen.path, 'Chats'),
            _branch(Routes.profileScreen.path, 'Profile'),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(null)),
          watchUserProfileProvider.overrideWith((ref) => Stream.value(null)),
          appConnectivityProvider.overrideWith(
            (ref) => Stream.value(const [ConnectivityResult.wifi]),
          ),
          appAnalyticsProvider.overrideWithValue(
            AppAnalytics(
              reporter: _NoOpAnalyticsReporter(),
              shouldCollect: false,
            ),
          ),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Continue with phone'), findsOneWidget);
    expect(find.text('Home'), findsNothing);
    expect(find.text('Chats'), findsNothing);
    expect(find.text('Profile'), findsNothing);

    await tester.tap(find.text('Continue with phone'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Auth /clubs'), findsOneWidget);
  });
}

StatefulShellBranch _branch(String path, String label) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (_, _) => Scaffold(body: Text(label)),
      ),
    ],
  );
}

final class _NoOpAnalyticsReporter implements AnalyticsReporter {
  @override
  Future<void> logEvent(String name, {Map<String, Object>? parameters}) async {}

  @override
  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) async {}

  @override
  Future<void> setCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserId(String? userId) async {}
}
