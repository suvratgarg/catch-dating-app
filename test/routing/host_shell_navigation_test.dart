import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:catch_dating_app/core/presentation/app_shell_active_tab.dart';
import 'package:catch_dating_app/core/presentation/app_shell_keys.dart';
import 'package:catch_dating_app/core/presentation/host_app_shell.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_bar.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../test_pump_helpers.dart';

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
    await pumpFeatureUi(tester);

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
    await pumpFeatureUi(tester);
    expect(find.text('EVENTS BODY'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('Inbox')));
    await pumpFeatureUi(tester);
    expect(find.text('INBOX BODY'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel(RegExp('Organizer')));
    await pumpFeatureUi(tester);
    expect(find.text('ORGANIZER BODY'), findsOneWidget);
  });

  testWidgets(
    'real Host shell publishes adaptive placement through keyboard changes',
    (tester) async {
      const editorKey = ValueKey('host-shell-focus-continuity-editor');
      final editorController = TextEditingController(text: 'Host draft');
      final editorFocusNode = FocusNode();
      addTearDown(editorController.dispose);
      addTearDown(editorFocusNode.dispose);
      addTearDown(tester.view.resetViewInsets);

      final router = GoRouter(
        initialLocation: '/host',
        routes: [
          StatefulShellRoute.indexedStack(
            builder: (context, state, navigationShell) =>
                HostAppShell(navigationShell: navigationShell),
            branches: [
              StatefulShellBranch(
                routes: [
                  GoRoute(
                    path: '/host',
                    builder: (context, state) => Scaffold(
                      body: TextField(
                        key: editorKey,
                        controller: editorController,
                        focusNode: editorFocusNode,
                      ),
                    ),
                  ),
                ],
              ),
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
            appShellFcmInitializationProvider(
              _uid,
            ).overrideWith((ref) async {}),
            errorLoggerProvider.overrideWithValue(ErrorLogger()),
            appAnalyticsProvider.overrideWithValue(AppAnalytics()),
          ],
          child: MaterialApp.router(
            theme: AppTheme.light.copyWith(platform: defaultTargetPlatform),
            routerConfig: router,
          ),
        ),
      );
      await pumpFeatureUi(tester);

      final tabBarFloats = CatchTabBar.floatsFor(
        tester.element(find.byType(HostAppShell)),
      );
      final expectedPlacement = tabBarFloats
          ? AppShellBottomBarPlacement.floating
          : AppShellBottomBarPlacement.anchored;
      final shellScaffold = tester.widget<Scaffold>(
        find.byKey(AppShellKeys.scaffold),
      );
      final activeTab = tester.widget<AppShellActiveTab>(
        find.byType(AppShellActiveTab),
      );
      expect(shellScaffold.extendBody, tabBarFloats);
      expect(
        shellScaffold.body,
        tabBarFloats ? isA<Stack>() : isA<AppShellActiveTab>(),
      );
      expect(
        shellScaffold.bottomNavigationBar,
        tabBarFloats ? isNull : isNotNull,
      );
      expect(activeTab.bottomBarPlacement, expectedPlacement);
      expect(activeTab.bottomOverlayInset, tabBarFloats ? greaterThan(0) : 0);

      final editor = find.byKey(editorKey);
      await tester.tap(editor);
      await tester.pump();
      editorController
        ..text = 'Host reply draft'
        ..selection = const TextSelection.collapsed(offset: 7);
      final editorElement = tester.element(editor);

      // A focused editor with zero viewInsets models a hardware keyboard.
      expect(tester.view.viewInsets.bottom, 0);
      expect(editorFocusNode.hasFocus, isTrue);
      expect(find.byType(AppShellNavigationBar), findsOneWidget);
      expect(
        tester
            .widget<AppShellActiveTab>(find.byType(AppShellActiveTab))
            .bottomBarPlacement,
        expectedPlacement,
      );

      tester.view.viewInsets = const FakeViewPadding(bottom: 318);
      await tester.pump();

      final keyboardScaffold = tester.widget<Scaffold>(
        find.byKey(AppShellKeys.scaffold),
      );
      final keyboardActiveTab = tester.widget<AppShellActiveTab>(
        find.byType(AppShellActiveTab),
      );
      expect(find.byType(AppShellNavigationBar), findsNothing);
      expect(keyboardScaffold.extendBody, isFalse);
      expect(keyboardScaffold.bottomNavigationBar, isNull);
      expect(
        keyboardScaffold.body,
        tabBarFloats ? isA<Stack>() : isA<AppShellActiveTab>(),
      );
      expect(
        keyboardActiveTab.bottomBarPlacement,
        AppShellBottomBarPlacement.none,
      );
      expect(keyboardActiveTab.bottomOverlayInset, 0);
      expect(tester.element(editor), same(editorElement));
      expect(editorFocusNode.hasFocus, isTrue);
      expect(editorController.text, 'Host reply draft');
      expect(
        editorController.selection,
        const TextSelection.collapsed(offset: 7),
      );

      tester.view.resetViewInsets();
      await tester.pump();

      final restoredScaffold = tester.widget<Scaffold>(
        find.byKey(AppShellKeys.scaffold),
      );
      expect(find.byType(AppShellNavigationBar), findsOneWidget);
      expect(
        restoredScaffold.bottomNavigationBar,
        tabBarFloats ? isNull : isNotNull,
      );
      expect(
        tester
            .widget<AppShellActiveTab>(find.byType(AppShellActiveTab))
            .bottomBarPlacement,
        expectedPlacement,
      );
    },
    variant: const TargetPlatformVariant({
      TargetPlatform.android,
      TargetPlatform.iOS,
    }),
  );
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
