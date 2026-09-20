import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/hosts/today/personalization/data/host_today_preference_repository.dart';
import 'package:catch_dating_app/hosts/today/personalization/domain/host_today_preference.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_focus_screen.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalization_state.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalized_layout.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_roadmap_provider.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/route_contract.dart';
import 'package:catch_dating_app/routing/go_router.dart'
    show hostOrganizerScreenForUri;
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../clubs/clubs_test_helpers.dart' show buildClub;
import '../../../test_pump_helpers.dart';

void main() {
  final scope = HostTodayPreferenceScope(
    accountId: 'owner',
    organizerId: 'org',
  );
  late _MemoryPreferences preferences;
  setUp(() => preferences = _MemoryPreferences());

  Future<GoRouter> mount(
    WidgetTester tester, {
    HostTodayStatus status = HostTodayStatus.empty,
    ValueNotifier<HostTodayStatus>? statusChanges,
    String initialLocation = '/host/today',
  }) async {
    final statuses = statusChanges ?? ValueNotifier(status);
    if (statusChanges == null) addTearDown(statuses.dispose);
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/host/today',
          name: Routes.hostTodayScreen.name,
          builder: (_, _) => ValueListenableBuilder<HostTodayStatus>(
            valueListenable: statuses,
            builder: (_, currentStatus, _) => CatchRootScreenScaffold.sections(
              title: const Text('Today'),
              children: [
                HostTodayPersonalizedLayout(
                  scope: scope,
                  today: HostTodayState(status: currentStatus),
                  now: DateTime(2026, 9, 21),
                  operationalSurface: const SliverToBoxAdapter(
                    child: Text('Operational work'),
                  ),
                ),
              ],
            ),
          ),
          routes: [
            GoRoute(
              path: 'focus',
              name: Routes.hostTodayFocusScreen.name,
              builder: (_, _) => const HostTodayFocusScreen(organizerId: 'org'),
            ),
          ],
        ),
        GoRoute(
          path: '/host/organizer',
          name: Routes.hostOrganizerScreen.name,
          builder: (_, state) => Scaffold(
            body: Text(
              'Organizer ${hostOrganizerScreenForUri(state.uri).initialClubId}',
            ),
          ),
        ),
        GoRoute(
          path: '/host/events',
          name: Routes.hostEventsScreen.name,
          builder: (_, _) => const Scaffold(body: Text('Events')),
        ),
      ],
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          uidProvider.overrideWithValue(const AsyncData('owner')),
          hostOperableClubsProvider('owner').overrideWithValue(
            AsyncData([buildClub(id: 'org', ownerUserId: 'owner')]),
          ),
          hostTodayPreferenceRepositoryProvider.overrideWithValue(preferences),
          hostTodayRoadmapProvider(
            scope,
          ).overrideWithValue(const HostTodayRoadmapEvidence()),
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
    await pumpFeatureUi(tester);
    return router;
  }

  testWidgets(
    'first quiet visit opens full-screen focus and close persists skip',
    (tester) async {
      final router = await mount(tester);
      expect(router.state.uri.path, '/host/today/focus');
      expect(find.byType(HostTodayFocusScreen), findsOneWidget);
      await tester.ensureVisible(
        find.byKey(const ValueKey('host-today-focus-skip')),
      );
      await tester.tap(find.byKey(const ValueKey('host-today-focus-skip')));
      await pumpFeatureUi(tester);
      expect(preferences.values[scope], const HostTodayPreference.skipped());
      expect(router.state.uri.path, '/host/today');
      await tester.tap(find.byKey(const ValueKey('host-today-change-focus')));
      await pumpFeatureUi(tester);
      expect(find.byType(HostTodayFocusScreen), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('selection returns to personalized quiet Today', (tester) async {
    final router = await mount(tester);
    await tester.tap(find.byKey(const ValueKey('host-today-focus-audience')));
    await pumpFeatureUi(tester);
    await tester.ensureVisible(
      find.byKey(const ValueKey('host-today-focus-continue')),
    );
    await tester.tap(find.byKey(const ValueKey('host-today-focus-continue')));
    await pumpFeatureUi(tester);
    expect(
      preferences.values[scope],
      const HostTodayPreference.selected(HostTodayFocus.audience),
    );
    expect(router.state.uri.path, '/host/today');
    expect(
      find.byKey(const ValueKey('host-today-suggested-action')),
      findsOneWidget,
    );
    expect(find.text('Not yet verified'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('organizer presence action retains the selected organizer', (
    tester,
  ) async {
    preferences.values[scope] = const HostTodayPreference.selected(
      HostTodayFocus.organizerPresence,
    );
    final router = await mount(tester);
    await tester.tap(find.byKey(const ValueKey('host-today-suggested-action')));
    await pumpFeatureUi(tester);
    expect(router.state.uri.queryParameters['clubId'], scope.organizerId);
    expect(find.text('Organizer ${scope.organizerId}'), findsOneWidget);
  });

  testWidgets('operational uncertainty does not read or offer optional focus', (
    tester,
  ) async {
    final router = await mount(tester, status: HostTodayStatus.loading);
    expect(router.state.uri.path, '/host/today');
    expect(find.text('Operational work'), findsOneWidget);
    expect(preferences.loads, 0);
  });

  testWidgets(
    'operational work appearing closes optional focus without recording skip',
    (tester) async {
      final status = ValueNotifier(HostTodayStatus.empty);
      addTearDown(status.dispose);
      final router = await mount(tester, statusChanges: status);
      expect(find.byType(HostTodayFocusScreen), findsOneWidget);
      status.value = HostTodayStatus.loading;
      await pumpFeatureUi(tester);
      expect(router.state.uri.path, '/host/today');
      expect(find.text('Operational work'), findsOneWidget);
      expect(preferences.values, isEmpty);
    },
  );

  testWidgets('direct focus route yields to operational work', (tester) async {
    final router = await mount(
      tester,
      status: HostTodayStatus.content,
      initialLocation: '/host/today/focus?organizerId=org',
    );
    expect(router.state.uri.path, '/host/today');
    expect(find.text('Operational work'), findsOneWidget);
    expect(preferences.values, isEmpty);
  });

  testWidgets('system back persists the first-run skip', (tester) async {
    final router = await mount(tester);
    router.pop();
    await pumpFeatureUi(tester);
    expect(preferences.values[scope], const HostTodayPreference.skipped());
    expect(router.state.uri.path, '/host/today');
  });

  testWidgets('saved skip does not reopen focus on a later visit', (
    tester,
  ) async {
    preferences.values[scope] = const HostTodayPreference.skipped();
    final router = await mount(tester);
    expect(router.state.uri.path, '/host/today');
    expect(find.byType(HostTodayFocusScreen), findsNothing);
    expect(
      find.byKey(const ValueKey('host-today-suggested-action')),
      findsOneWidget,
    );
  });
}

class _MemoryPreferences implements HostTodayPreferenceRepository {
  final values = <HostTodayPreferenceScope, HostTodayPreference>{};
  int loads = 0;
  @override
  Future<HostTodayPreference> load(HostTodayPreferenceScope scope) async {
    loads++;
    return values[scope] ?? const HostTodayPreference.unanswered();
  }

  @override
  Future<void> save(
    HostTodayPreferenceScope scope,
    HostTodayPreference preference,
  ) async {
    values[scope] = preference;
  }
}
