import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/chats/presentation/inbox/chat_inbox_screen.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/presentation/app_shell_keys.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../support/profile_readiness_fixtures.dart';

void main() {
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

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
    expect(find.text('Catches'), findsNothing);
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
    expect(find.text('Catches'), findsNothing);
    expect(find.text('Chats'), findsNothing);
    expect(find.text('Profile'), findsNothing);

    await tester.tap(find.text('Continue with phone'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Auth /clubs'), findsOneWidget);
  });

  testWidgets('authenticated app shell loads Chats and Profile branches', (
    tester,
  ) async {
    AppConfig.configureEntrypointRole(AppRole.consumer);
    final router = GoRouter(
      initialLocation: Routes.dashboardScreen.path,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, navigationShell) =>
              AppShell(navigationShell: navigationShell),
          branches: [
            _branch(Routes.dashboardScreen.path, 'Home screen loaded'),
            _branch(Routes.exploreScreen.path, 'Explore screen loaded'),
            _branch(Routes.matchesListScreen.path, 'Chats screen loaded'),
            _branch(Routes.profileScreen.path, 'Profile screen loaded'),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value('runner-1')),
          appShellFcmInitializationProvider(
            'runner-1',
          ).overrideWith((ref) async {}),
          watchMatchesForUserProvider(
            'runner-1',
          ).overrideWith((ref) => Stream.value(const [])),
          watchEventParticipationsForUserProvider(
            'runner-1',
          ).overrideWith((ref) => Stream.value(const [])),
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

    expect(find.text('Home screen loaded'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('Chats')));
    await tester.pump();
    await tester.pump();

    expect(find.text('Chats screen loaded'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('You'));
    await tester.pump();
    await tester.pump();

    expect(find.text('Profile screen loaded'), findsOneWidget);
  });

  testWidgets('authenticated iOS shell overlays the floating tab bar', (
    tester,
  ) async {
    AppConfig.configureEntrypointRole(AppRole.consumer);
    final previousPlatformOverride = debugDefaultTargetPlatformOverride;
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    try {
      final router = GoRouter(
        initialLocation: Routes.dashboardScreen.path,
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (_, _, navigationShell) =>
                AppShell(navigationShell: navigationShell),
            branches: [
              _branch(Routes.dashboardScreen.path, 'Home screen loaded'),
              _branch(Routes.exploreScreen.path, 'Explore screen loaded'),
              _branch(Routes.matchesListScreen.path, 'Chats screen loaded'),
              _branch(Routes.profileScreen.path, 'Profile screen loaded'),
            ],
          ),
        ],
      );
      addTearDown(router.dispose);

      await tester.pumpWidget(
        _authenticatedShellProviderScope(
          child: MaterialApp.router(
            theme: AppTheme.light.copyWith(platform: TargetPlatform.iOS),
            routerConfig: router,
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      final shellScaffold = tester.widget<Scaffold>(
        find.byKey(AppShellKeys.scaffold),
      );
      expect(shellScaffold.bottomNavigationBar, isNull);
      expect(shellScaffold.body, isA<Stack>());
      expect(
        find.byKey(const ValueKey('catch_tab_bar.floating_chrome')),
        findsOneWidget,
      );
    } finally {
      debugDefaultTargetPlatformOverride = previousPlatformOverride;
    }
  });

  testWidgets('production router opens Chats for social-ready users', (
    tester,
  ) async {
    await _pumpProductionRouter(
      tester,
      initialLocation: Routes.matchesListScreen.path,
    );

    expect(find.byType(ChatsListScreen), findsOneWidget);
    expect(find.text('Continue with phone'), findsNothing);
  });

  testWidgets('production router opens Profile for social-ready users', (
    tester,
  ) async {
    await _pumpProductionRouter(
      tester,
      initialLocation: Routes.profileScreen.path,
    );

    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Your profile'), findsOneWidget);
    expect(find.text('Continue with phone'), findsNothing);
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

Future<void> _pumpProductionRouter(
  WidgetTester tester, {
  required String initialLocation,
}) async {
  AppConfig.configureEntrypointRole(AppRole.consumer);

  await tester.pumpWidget(
    _authenticatedShellProviderScope(
      initialLocation: initialLocation,
      child: const _ProductionRouterApp(),
    ),
  );
  await tester.pump();
  await tester.pump();
}

Widget _authenticatedShellProviderScope({
  required Widget child,
  String? initialLocation,
}) {
  final user = buildSocialReadyUser(name: 'Runner One');

  return UncontrolledProviderScope(
    container: ProviderContainer(
      overrides: [
        if (initialLocation != null)
          initialAppLocationProvider.overrideWith((ref) => initialLocation),
        // ignore: scoped_providers_should_specify_dependencies
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        // ignore: scoped_providers_should_specify_dependencies
        appShellFcmInitializationProvider(
          'runner-1',
        ).overrideWith((ref) async {}),
        // ignore: scoped_providers_should_specify_dependencies
        watchMatchesForUserProvider(
          'runner-1',
        ).overrideWith((ref) => Stream.value(const [])),
        // ignore: scoped_providers_should_specify_dependencies
        watchEventParticipationsForUserProvider(
          'runner-1',
        ).overrideWith((ref) => Stream.value(const [])),
        // ignore: scoped_providers_should_specify_dependencies
        watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
        // ignore: scoped_providers_should_specify_dependencies
        appConnectivityProvider.overrideWith(
          (ref) => Stream.value(const [ConnectivityResult.wifi]),
        ),
        // ignore: scoped_providers_should_specify_dependencies
        appAnalyticsProvider.overrideWithValue(
          AppAnalytics(
            reporter: _NoOpAnalyticsReporter(),
            shouldCollect: false,
          ),
        ),
      ],
    ),
    child: child,
  );
}

class _ProductionRouterApp extends ConsumerWidget {
  const _ProductionRouterApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      theme: AppTheme.light,
      routerConfig: ref.watch(goRouterProvider),
    );
  }
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
