import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/presentation/host_app_shell.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const _uid = 'host-user';

void main() {
  testWidgets('real Host shell owns the lifecycle IA and switches branches', (
    tester,
  ) async {
    final router = GoRouter(
      initialLocation: '/host',
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) =>
              HostAppShell(navigationShell: navigationShell),
          branches: [
            _branch('/host', 'TODAY BODY'),
            _branch('/host/events', 'EVENTS BODY'),
            _branch('/host/inbox', 'INBOX BODY'),
            _branch('/host/organizer', 'ORGANIZER BODY'),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWith((ref) => Stream.value(_uid)),
          totalUnreadCountProvider(_uid).overrideWithValue(0),
          appConnectivityProvider.overrideWith(
            (ref) => Stream.value(const [ConnectivityResult.wifi]),
          ),
          appShellFcmInitializationProvider(_uid).overrideWith((ref) async {}),
          errorLoggerProvider.overrideWithValue(ErrorLogger()),
          appAnalyticsProvider.overrideWithValue(AppAnalytics()),
        ],
        child: MaterialApp.router(theme: AppTheme.light, routerConfig: router),
      ),
    );
    await tester.pumpAndSettle();

    final navigationBar = tester.widget<AppShellNavigationBar>(
      find.byType(AppShellNavigationBar),
    );
    expect(
      navigationBar.items!.map((item) => item.destination),
      orderedEquals(const [
        AppShellNavigationDestination.hostToday,
        AppShellNavigationDestination.hostEvents,
        AppShellNavigationDestination.hostInbox,
        AppShellNavigationDestination.hostOrganizer,
      ]),
    );
    expect(find.text('TODAY BODY'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('Events')));
    await tester.pumpAndSettle();
    expect(find.text('EVENTS BODY'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('Inbox')));
    await tester.pumpAndSettle();
    expect(find.text('INBOX BODY'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('Organizer')));
    await tester.pumpAndSettle();
    expect(find.text('ORGANIZER BODY'), findsOneWidget);
  });
}

StatefulShellBranch _branch(String path, String label) {
  return StatefulShellBranch(
    routes: [
      GoRoute(
        path: path,
        builder: (context, state) => Scaffold(body: Center(child: Text(label))),
      ),
    ],
  );
}
