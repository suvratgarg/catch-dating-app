import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/core/analytics/app_analytics.dart';
import 'package:catch_dating_app/core/data/cursor_page.dart';
import 'package:catch_dating_app/core/data/read_limit_policy.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/data/host_attendance_outbox.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/private_event_setup_capability.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/hosts/today/data/host_attention_repository.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:catch_dating_app/hosts/today/personalization/domain/host_today_preference.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalization_state.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalized_layout.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_preference_controller.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_roadmap_provider.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_screen.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/hosts/today/presentation/widgets/host_today_body.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../clubs/clubs_test_helpers.dart' show buildClub;
import '../../events/events_test_helpers.dart' show buildEvent;
import '../../test_pump_helpers.dart';

typedef _EventPage = CursorPage<Event, DocumentSnapshot<Event>>;
typedef _Read = ({String organizerId, DateTime boundary, int limit});

void main() {
  testWidgets('task push/pop refreshes the retained Today projection', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.mount(tester);
    final originalState = fixture.todayState(tester);
    final task = find.byKey(const ValueKey('host-today-attention-before'));
    await tester.ensureVisible(task);
    await tester.tap(task);
    await pumpFeatureUi(tester);
    expect(fixture.router.state.name, Routes.hostClubPaymentsScreen.name);
    expect(find.text('Task destination'), findsOneWidget);
    fixture.attention.version = 'after';
    fixture.router.pop();
    await pumpFeatureUi(tester);
    fixture.expectRetained(tester, originalState);
    expect(fixture.attention.organizers.length, greaterThan(1));
    expect(fixture.taskIds(tester), ['after']);
    expect(task, findsNothing);
  });

  testWidgets('tab return observes another actor task on the retained Today', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.mount(tester);
    final originalState = fixture.todayState(tester);
    fixture.navigation.goBranch(1);
    await pumpFeatureUi(tester);
    expect(find.text('Other tab'), findsOneWidget);
    fixture.attention.version = 'another-actor-task';
    fixture.navigation.goBranch(0);
    await pumpFeatureUi(tester);
    fixture.expectRetained(tester, originalState);
    expect(fixture.attention.organizers.length, greaterThan(1));
    expect(fixture.taskIds(tester), ['another-actor-task']);
  });

  testWidgets('embedded event return refreshes the retained Today projection', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.mount(tester);
    final originalState = fixture.todayState(tester);
    // Invoke the real event action; production query routing builds the actual
    // embedded detail boundary. Its missing record is a terminal fixture.
    final body = tester.widget<HostTodayBody>(find.byType(HostTodayBody));
    body.onOpenEvent(body.state.featuredEvent!);
    await pumpFeatureUi(tester);
    expect(fixture.router.state.uri.queryParameters['eventId'], 'org-a-event');
    expect(find.byType(HostEventManageRouteScreen), findsOneWidget);
    fixture.attention.version = 'after-event-work';
    fixture.router.goNamed(Routes.hostTodayScreen.name);
    await pumpFeatureUi(tester);
    fixture.expectRetained(tester, originalState);
    expect(fixture.attention.organizers.length, greaterThan(1));
    expect(fixture.taskIds(tester), ['after-event-work']);
  });

  testWidgets('resume refreshes server tasks without remounting Today', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.mount(tester);
    final originalState = fixture.todayState(tester);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    fixture.attention.version = 'while-backgrounded';
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await pumpFeatureUi(tester);
    fixture.expectRetained(tester, originalState);
    expect(fixture.attention.organizers.length, greaterThan(1));
    expect(fixture.taskIds(tester), ['while-backgrounded']);
  });

  testWidgets('minute timer rebuilds retain the boundary without fetch loops', (
    tester,
  ) async {
    final fixture = _Fixture();
    await fixture.mount(tester);
    final originalState = fixture.todayState(tester);
    final boundary = fixture.events.active.single.boundary;
    final clockBefore = tester
        .widget<HostTodayHeader>(find.byType(HostTodayHeader))
        .now!;
    for (var minute = 0; minute < 3; minute += 1) {
      await pumpFeatureUiFor(tester, const Duration(minutes: 1, seconds: 1));
      await tester.pump();
    }
    fixture.expectRetained(tester, originalState);
    expect(fixture.events.active, hasLength(1));
    expect(fixture.events.history, hasLength(1));
    expect(fixture.attention.organizers, ['org-a']);
    expect(fixture.outbox.accounts, ['actor-a']);
    expect(fixture.events.active.single.boundary, boundary);
    // Flutter advances timer time, not DateTime.now(). Check non-regression,
    // not a fabricated three-minute wall-clock advance.
    expect(
      tester.widget<HostTodayHeader>(find.byType(HostTodayHeader)).now!,
      isNot(lessThan(clockBefore)),
    );
  });

  for (final failure in ['active', 'attention']) {
    testWidgets('existing $failure retry refreshes the retained feed', (
      tester,
    ) async {
      final fixture = _Fixture();
      if (failure == 'active') {
        fixture.events.failNextActive = true;
      } else {
        fixture.attention.failNext = true;
      }
      await fixture.mount(tester);
      final originalState = fixture.todayState(tester);
      final body = tester.widget<HostTodayBody>(find.byType(HostTodayBody));
      expect(
        failure == 'active'
            ? body.state.status == HostTodayStatus.error
            : body.state.attentionIssues.isNotEmpty,
        isTrue,
      );
      body.onRetry();
      await pumpFeatureUi(tester);
      fixture.expectRetained(tester, originalState);
      expect(fixture.events.active, hasLength(2));
      expect(fixture.taskIds(tester), ['before']);
      expect(fixture.display(tester).attentionIssues, isEmpty);
    });
  }

  testWidgets('existing event entry return refreshes the retained feed', (
    tester,
  ) async {
    final fixture = _Fixture()
      ..events.empty = true
      ..attention.version = null;
    await fixture.mount(tester);
    final originalState = fixture.todayState(tester);
    final create = find.byKey(const ValueKey('host-today-create-event'));
    await tester.ensureVisible(create);
    await tester.tap(create);
    await pumpFeatureUi(tester);
    await tester.tap(
      find.byKey(const ValueKey('host-event-entry-createEvent')),
    );
    await pumpFeatureUi(tester);
    expect(fixture.router.state.name, Routes.hostCreateEventScreen.name);
    expect(fixture.router.state.pathParameters['clubId'], 'org-a');
    expect(find.text('Create destination'), findsOneWidget);
    fixture.attention.version = 'created-elsewhere';
    fixture.router.pop();
    await pumpFeatureUi(tester);
    fixture.expectRetained(tester, originalState);
    expect(fixture.events.active, hasLength(2));
    expect(fixture.taskIds(tester), ['created-elsewhere']);
  });

  for (final scope in ['actor', 'organizer']) {
    for (final returnToA in [false, true]) {
      for (final failOld in [false, true]) {
        testWidgets('held old $scope ${returnToA ? 'ABA' : 'A-B'} '
            '${failOld ? 'failure' : 'success'} cannot affect current Today', (
          tester,
        ) async {
          final fixture = _Fixture();
          final held = Completer<_EventPage>();
          fixture.events.holdNextActive = held;
          await fixture.mount(tester, loading: true);
          final originalState = fixture.todayState(tester);
          expect(fixture.events.active, hasLength(1));
          expect(fixture.attention.organizers, isEmpty);
          try {
            await fixture.changeScope(tester, scope, toB: true);
            expect(fixture.display(tester).status, HostTodayStatus.content);
            if (returnToA) {
              await fixture.changeScope(tester, scope, toB: false);
            }
            final currentEvent = fixture.display(tester).featuredEvent!.id;
            final historyBefore = List.of(fixture.events.history);
            final attentionBefore = List.of(fixture.attention.organizers);
            final outboxBefore = List.of(fixture.outbox.accounts);
            if (failOld) {
              held.completeError(StateError('old request failed'));
            } else {
              held.complete(
                _EventPage(
                  items: [fixture.events.event('org-a', 'obsolete-event')],
                  hasMore: false,
                ),
              );
            }
            await pumpFeatureUi(tester);
            fixture.expectRetained(tester, originalState);
            expect(fixture.display(tester).featuredEvent!.id, currentEvent);
            expect(fixture.display(tester).status, HostTodayStatus.content);
            expect(fixture.taskIds(tester), ['before']);
            expect(
              fixture.events.history,
              historyBefore,
              reason: 'An obsolete active read must not start history.',
            );
            expect(fixture.attention.organizers, attentionBefore);
            expect(fixture.outbox.accounts, outboxBefore);
            expect(tester.takeException(), isNull);
          } finally {
            if (!held.isCompleted) {
              held.complete(const _EventPage(items: [], hasMore: false));
              await tester.pump();
            }
          }
        });
      }
    }
  }
}

class _Fixture {
  final events = _Events();
  final attention = _Attention();
  final outbox = _OutboxStore();
  final identities = StreamController<String?>.broadcast();
  late GoRouter router;
  late StatefulNavigationShell navigation;
  late ProviderContainer container;

  Future<void> mount(WidgetTester tester, {bool loading = false}) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1200, 1000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final production = hostWorkspaceRouteGraph(
      AppAnalytics(shouldCollect: false),
    );
    // Keep the real Today branch builder, index recipe, indexed-stack lifetime
    // and query-driven embedded detail. Only unrelated tab/task contents are
    // sentinels; no Today provider, view model or controller is replaced.
    router = GoRouter(
      initialLocation: Routes.hostTodayScreen.path,
      routes: [
        StatefulShellRoute.indexedStack(
          builder: (_, _, shell) {
            navigation = shell;
            return Scaffold(body: shell);
          },
          branches: [
            production.branches.first,
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: Routes.hostEventsScreen.path,
                  name: Routes.hostEventsScreen.name,
                  builder: (_, _) => const Material(child: Text('Other tab')),
                ),
              ],
            ),
          ],
        ),
        for (final destination in [
          (Routes.hostClubPaymentsScreen, 'Task destination'),
          (Routes.hostCreateEventScreen, 'Create destination'),
        ])
          GoRoute(
            path: destination.$1.path,
            name: destination.$1.name,
            builder: (_, _) => Material(child: Text(destination.$2)),
          ),
      ],
    );
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      router.dispose();
      await identities.close();
    });
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          uidProvider.overrideWith((_) => identities.stream),
          eventRepositoryProvider.overrideWithValue(events),
          hostAttentionRepositoryProvider.overrideWithValue(attention),
          hostAttendanceOutboxProvider.overrideWithValue(
            HostAttendanceOutbox(store: outbox, mutator: _NoMutations()),
          ),
          privateEventSetupAvailableProvider.overrideWithValue(false),
          for (final actor in ['actor-a', 'actor-b'])
            hostOperableClubsProvider(actor).overrideWithValue(
              AsyncData([
                for (final org in ['org-a', 'org-b'])
                  buildClub(id: org, ownerUserId: actor),
              ]),
            ),
          for (final org in ['org-a', 'org-b']) ...[
            clubEventDraftsProvider(clubId: org).overrideWith((_) async => []),
            fetchClubProvider(org).overrideWithValue(const AsyncData(null)),
            watchEventProvider(
              '$org-event',
            ).overrideWith((_) => Stream.value(null)),
            for (final actor in ['actor-a', 'actor-b']) ...[
              hostTodayPreferenceProvider(
                HostTodayPreferenceScope(accountId: actor, organizerId: org),
              ).overrideWith((_) async => const HostTodayPreference.skipped()),
              hostTodayRoadmapProvider(
                HostTodayPreferenceScope(accountId: actor, organizerId: org),
              ).overrideWithValue(const HostTodayRoadmapEvidence()),
            ],
          ],
        ],
        child: MaterialApp.router(
          theme: AppTheme.light,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: catchNoticeOverlayBuilder,
          routerConfig: router,
        ),
      ),
    );
    identities.add('actor-a');
    if (loading) {
      await pumpUntilFound(tester, find.byType(HostTodayBody));
      expect(display(tester).status, HostTodayStatus.loading);
    } else {
      await pumpFeatureUi(tester);
    }
    container = ProviderScope.containerOf(
      tester.element(find.byType(HostTodayScreen)),
      listen: false,
    );
    expect(tester.takeException(), isNull);
  }

  State todayState(WidgetTester tester) =>
      tester.state(find.byType(HostTodayScreen, skipOffstage: false));

  HostTodayState display(WidgetTester tester) => tester
      .widget<HostTodayPersonalizedLayout>(
        find.byType(HostTodayPersonalizedLayout, skipOffstage: false),
      )
      .today;

  List<String> taskIds(WidgetTester tester) =>
      display(tester).attentionItems.map((item) => item.item.id).toList();

  void expectRetained(WidgetTester tester, State original) {
    expect(todayState(tester), same(original));
    expect(tester.takeException(), isNull);
  }

  Future<void> changeScope(
    WidgetTester tester,
    String scope, {
    required bool toB,
  }) async {
    if (scope == 'actor') {
      identities.add(toB ? 'actor-b' : 'actor-a');
    } else {
      container
          .read(hostOrganizerSelectionProvider('actor-a').notifier)
          .select(toB ? 'org-b' : 'org-a');
    }
    await pumpFeatureUi(tester);
    final route = tester.widget<HostTodayLoadedRoute>(
      find.byType(HostTodayLoadedRoute),
    );
    expect(
      route.routeState.uid,
      scope == 'actor' && toB ? 'actor-b' : 'actor-a',
    );
    expect(
      tester.widget<HostTodayBody>(find.byType(HostTodayBody)).organizer.id,
      scope == 'organizer' && toB ? 'org-b' : 'org-a',
    );
  }
}

class _Events extends Fake implements EventRepository {
  final active = <_Read>[];
  final history = <_Read>[];
  Completer<_EventPage>? holdNextActive;
  bool failNextActive = false;
  bool empty = false;

  Event event(String organizerId, String id) => buildEvent(
    id: id,
    clubId: organizerId,
    name: id,
    startTime: DateTime.now().add(const Duration(hours: 2)),
    endTime: DateTime.now().add(const Duration(hours: 4)),
  );

  @override
  Future<_EventPage> fetchActiveEventsPage({
    required String organizerId,
    required DateTime sessionBoundary,
    DocumentSnapshot<Event>? startAfter,
    int limit = ReadLimitPolicy.directoryPage,
  }) async {
    active.add((
      organizerId: organizerId,
      boundary: sessionBoundary,
      limit: limit,
    ));
    expect(startAfter, isNull);
    expect(limit, ReadLimitPolicy.directoryPage);
    final held = holdNextActive;
    holdNextActive = null;
    if (held != null) return held.future;
    if (failNextActive) {
      failNextActive = false;
      throw StateError('active unavailable');
    }
    return _EventPage(
      items: empty ? [] : [event(organizerId, '$organizerId-event')],
      hasMore: false,
    );
  }

  @override
  Future<_EventPage> fetchPastEventsPage({
    required String organizerId,
    required DateTime sessionBoundary,
    DocumentSnapshot<Event>? startAfter,
    int limit = ReadLimitPolicy.directoryPage,
  }) async {
    history.add((
      organizerId: organizerId,
      boundary: sessionBoundary,
      limit: limit,
    ));
    expect(startAfter, isNull);
    expect(limit, ReadLimitPolicy.directoryPage);
    return const _EventPage(items: [], hasMore: false);
  }
}

class _Attention implements HostAttentionRepository {
  final organizers = <String>[];
  String? version = 'before';
  bool failNext = false;

  @override
  Future<HostAttentionProjection> fetch(String organizerId) async {
    organizers.add(organizerId);
    if (failNext) {
      failNext = false;
      throw StateError('attention unavailable');
    }
    final now = DateTime.now();
    return HostAttentionProjection(
      organizerId: organizerId,
      policyVersion: 1,
      generatedAt: now,
      horizonEndsAt: now.add(const Duration(days: 7)),
      coverage: [
        for (final kind in HostAttentionKind.values)
          HostAttentionCoverage(
            kind: kind,
            state: HostAttentionCoverageState.complete,
            reason: 'Fixture source complete.',
          ),
      ],
      items: [
        if (version case final id?)
          HostAttentionItem(
            id: id,
            kind: HostAttentionKind.payoutSetup,
            scope: HostAttentionScope.organizer,
            sourceOwner: HostAttentionSourceOwner.hostPaymentAccounts,
            sourceId: organizerId,
            sourceRevision: id,
            eventId: null,
            status: HostAttentionStatus.open,
            consequence: HostAttentionConsequence.risksRevenue,
            blocking: false,
            urgency: HostAttentionUrgency.immediate,
            destination: const HostAttentionDestination(
              route: HostAttentionDestinationRoute.hostOrganizerPayments,
            ),
            context: const HostAttentionContext(
              provider: 'Fixture provider',
              count: 1,
            ),
            dedupeKey: 'payout:$organizerId',
            policyVersion: 1,
            resolutionVersion: 1,
            assignedHostUid: null,
            openedAt: now,
            dueAt: now,
            expiresAt: null,
          ),
      ],
    );
  }
}

class _OutboxStore extends Fake implements HostAttendanceOutboxStore {
  final accounts = <String>[];
  @override
  Future<List<HostAttendanceOutboxEntry>> load(
    String accountId, {
    String? scope,
    DateTime? now,
  }) async {
    accounts.add(accountId);
    return [];
  }
}

class _NoMutations extends Fake implements HostAttendanceMutator {}
