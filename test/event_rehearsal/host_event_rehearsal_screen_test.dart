import 'dart:async';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_status_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_rehearsal/data/event_rehearsal_repository.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/host_event_rehearsal_screen.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/host_event_rehearsal_start_screen.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_link_and_run.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_simulator.dart';
import 'package:catch_dating_app/events/domain/event_itinerary.dart';
import 'package:catch_dating_app/events/domain/route_event_plan.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../test_pump_helpers.dart';

void main() {
  testWidgets('start screen makes the practice boundary and choices explicit', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(const HostEventRehearsalStartScreen(clubId: 'club-1')),
    );
    await tester.pump();

    expect(find.text('Dress rehearsal'), findsWidgets);
    expect(find.byType(CatchTopBar), findsOneWidget);
    final topBar = tester.widget<CatchTopBar>(find.byType(CatchTopBar));
    expect(topBar.title, 'Dress rehearsal');
    expect(topBar.titleWidget, isNull);
    final titleFinder = find.descendant(
      of: find.byType(CatchTopBar),
      matching: find.text('Dress rehearsal'),
    );
    final titleContext = tester.element(titleFinder);
    expect(
      tester.widget<Text>(titleFinder).style,
      CatchTextStyles.routeTitle(
        titleContext,
        color: CatchTokens.of(titleContext).ink,
      ),
    );
    expect(find.byType(CatchScreenHeaderTitle), findsNothing);
    expect(find.byType(CatchResponsiveSectionPage), findsOneWidget);
    expect(
      find.textContaining('No real guests, messages, payments'),
      findsOneWidget,
    );
    expect(find.text('Smooth run'), findsOneWidget);
    await tester.drag(
      find.byType(SingleChildScrollView),
      const Offset(0, -500),
    );
    await tester.pump();
    expect(find.text('Create rehearsal'), findsOneWidget);
  });

  testWidgets('host console renders an isolated live rehearsal projection', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _app(
        const HostEventRehearsalScreen(
          clubId: 'club-1',
          sessionId: 'session-1',
        ),
        overrides: [
          eventRehearsalProvider(
            'session-1',
          ).overrideWith((ref) => Stream.value(_bootstrap())),
        ],
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.text('Courtyard practice'), findsOneWidget);
    expect(find.text('REHEARSAL'), findsOneWidget);
    final topBar = tester.widget<CatchTopBar>(find.byType(CatchTopBar));
    expect(topBar.title, 'Courtyard practice');
    expect(topBar.titleWidget, isNull);
    final titleFinder = find.descendant(
      of: find.byType(CatchTopBar),
      matching: find.text('Courtyard practice'),
    );
    final titleContext = tester.element(titleFinder);
    expect(
      tester.widget<Text>(titleFinder).style,
      CatchTextStyles.routeTitle(
        titleContext,
        color: CatchTokens.of(titleContext).ink,
      ),
    );
    expect(find.text('Synthetic guests'), findsOneWidget);
    final strip = tester.widget<CatchStatusStrip>(
      find.byType(CatchStatusStrip),
    );
    expect(strip.statuses.single.id, 'rehearsal.session-1');
    expect(strip.statuses.single.actions, hasLength(2));
    expect(
      tester.getTopLeft(find.byType(CatchStatusStrip)).dy,
      tester.getBottomLeft(find.byType(CatchTopBar)).dy,
    );
    expect(find.text('Setup'), findsNothing);
    expect(find.text('Report'), findsNothing);
    expect(find.text('Live guest phone'), findsNothing);
    expect(find.textContaining('Task 3 of 8'), findsOneWidget);

    await tester.tap(find.text('Room'));
    await tester.pump();
    expect(find.text('Room'), findsOneWidget);

    await tester.tap(find.byIcon(CatchIcons.more));
    await pumpFeatureUi(tester);

    expect(find.text('Practice tools'), findsOneWidget);
    expect(find.text('Movement simulation'), findsOneWidget);
    expect(find.textContaining('1 itinerary steps'), findsOneWidget);
    expect(find.text('Meet the group at Courtyard stop.'), findsOneWidget);
    expect(find.text('Live guest phone'), findsOneWidget);
    expect(find.textContaining('anonymous synthetic guest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('virtual run controls expose legal actions for a running room', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Scaffold(
          body: EventRehearsalRunSection(
            session: _bootstrap().session,
            isLoading: false,
            onControl: (_, _) {},
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('VIRTUAL EVENT'), findsOneWidget);
    expect(find.text('Pause'), findsOneWidget);
    expect(find.text('Next moment'), findsOneWidget);
    expect(find.text('+15 min'), findsOneWidget);
  });

  testWidgets('host console reflows at 2x text without hiding live controls', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final rehearsal = _bootstrap(title: 'Sunday Morning Singles Mixer');

    await tester.pumpWidget(
      _app(
        const HostEventRehearsalScreen(
          clubId: 'club-1',
          sessionId: 'session-1',
        ),
        textScale: 2,
        overrides: [
          eventRehearsalProvider(
            'session-1',
          ).overrideWith((ref) => Stream.value(rehearsal)),
        ],
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Sunday Morning Singles Mixer'), findsOneWidget);
    expect(find.text('REHEARSAL'), findsOneWidget);
    expect(find.text('Room'), findsOneWidget);
    expect(find.text('Show Coach'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('placement Coach task opens Room on the real guest control', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 932);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final base = _bootstrap();
    final rehearsal = EventRehearsalBootstrap(
      session: base.session,
      actors: const [
        EventRehearsalActor(
          actorId: 'actor-01',
          displayName: 'Maya Shah',
          persona: 'placementPractice',
          status: EventRehearsalActorStatus.present,
          guestMoment: EventRehearsalGuestMoment.assignment,
          optedOut: false,
          keepApartActorIds: [],
          helpRequested: false,
          promptCompleted: true,
          layoutUnitId: 'table-1',
        ),
      ],
      actions: base.actions,
      guestUrl: base.guestUrl,
      canUseInternalFaults: base.canUseInternalFaults,
    );

    await tester.pumpWidget(
      _app(
        const HostEventRehearsalScreen(
          clubId: 'club-1',
          sessionId: 'session-1',
        ),
        overrides: [
          eventRehearsalProvider(
            'session-1',
          ).overrideWith((ref) => Stream.value(rehearsal)),
        ],
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Room'), findsOneWidget);
    expect(find.textContaining('Task 4 of 8'), findsOneWidget);
    expect(find.text('Place Maya in the current round'), findsOneWidget);
    expect(find.text('Maya Shah'), findsWidgets);
    expect(find.textContaining('Move to Table'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('issue injection follows the virtual event lifecycle', (
    tester,
  ) async {
    var appliedCount = 0;
    Widget simulator(EventRehearsalStatus status) => Scaffold(
      body: SingleChildScrollView(
        child: EventRehearsalSimulator(
          rehearsal: _bootstrap(status: status),
          isLoading: false,
          onBehavior: (_, _) => appliedCount += 1,
          onFault: (_) {},
        ),
      ),
    );

    await tester.pumpWidget(_app(simulator(EventRehearsalStatus.draft)));
    await tester.pump();

    expect(find.textContaining('Start the virtual event'), findsOneWidget);
    await tester.tap(find.text('Apply issue'));
    expect(appliedCount, 0);

    await tester.pumpWidget(_app(simulator(EventRehearsalStatus.running)));
    await tester.pump();
    await tester.tap(find.text('Apply issue'));
    expect(appliedCount, 1);
  });
}

Widget _app(Widget child, {List overrides = const [], double textScale = 1}) =>
    ProviderScope(
      overrides: overrides.cast(),
      child: MaterialApp(
        theme: AppTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: child,
      ),
    );

EventRehearsalBootstrap _bootstrap({
  EventRehearsalStatus status = EventRehearsalStatus.running,
  String title = 'Courtyard practice',
}) => EventRehearsalBootstrap(
  session: EventRehearsalSession(
    id: 'session-1',
    organizerId: 'club-1',
    sourceEventId: null,
    scenario: EventRehearsalScenario.lateAndNoShow,
    seed: 42,
    actorCount: 12,
    actionCount: 2,
    status: status,
    setup: EventRehearsalSetup(
      title: title,
      locationName: 'Practice studio',
      durationMinutes: 120,
      hostGoal: 'Learn the live flow',
      attendeePrompt: 'Say hello to someone new',
      modules: [EventRehearsalModule.arrival, EventRehearsalModule.firstHello],
      movementSimulation: const EventRehearsalMovementSimulation(
        itinerary: [
          EventItineraryItem(
            id: 'stop-1',
            kind: EventItineraryKind.stop,
            offsetMinutes: 30,
            durationMinutes: 20,
            title: 'Courtyard stop',
          ),
        ],
        routePlan: RouteEventPlan(
          version: 2,
          movementMode: RouteMovementMode.walk,
          routeShape: RouteShape.pointToPoint,
          groupStrategy: RouteGroupStrategy.together,
          stopCadence: RouteStopCadence.hostedStops,
          stopKinds: [RouteStopKind.venue],
          roleKinds: [RouteRoleKind.routeLead],
          path: [
            RoutePoint(latitude: 12.9716, longitude: 77.5946),
            RoutePoint(latitude: 12.975, longitude: 77.6),
          ],
          liveTrackingPolicy: RouteLiveTrackingPolicy(
            mode: RouteLiveTrackingMode.hostOnly,
            staleAfterSeconds: 120,
            retentionMinutes: 60,
          ),
        ),
        livePositions: [
          EventRehearsalLivePosition(
            role: 'host',
            latitude: 12.972,
            longitude: 77.595,
            recordedOffsetMinutes: 15,
          ),
        ],
        lateArrivalGuidance: 'Meet the group at Courtyard stop.',
      ),
    ),
    setupRevision: 1,
    runtimeRevision: 2,
    activeStepIndex: 1,
    virtualNow: DateTime.utc(2026, 8, 19, 18),
    fault: EventRehearsalFault.none,
    expiresAt: DateTime.utc(2026, 8, 20, 18),
  ),
  actors: const [
    EventRehearsalActor(
      actorId: 'actor-01',
      displayName: 'Rhea',
      persona: 'firstTimer',
      status: EventRehearsalActorStatus.present,
      guestMoment: EventRehearsalGuestMoment.firstHello,
      optedOut: false,
      keepApartActorIds: [],
      helpRequested: false,
      promptCompleted: false,
    ),
  ],
  actions: [
    EventRehearsalActionRecord(
      clientActionId: 'action-1',
      actorId: 'actor-01',
      kind: 'behavior',
      name: 'arrive',
      runtimeRevision: 2,
      virtualNow: DateTime.utc(2026, 8, 19, 18),
    ),
  ],
  guestUrl: 'https://catchdates.com/rehearse/practice-1',
  canUseInternalFaults: true,
);
