import 'dart:async';

import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/event_rehearsal/data/event_rehearsal_repository.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/host_event_rehearsal_screen.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/host_event_rehearsal_start_screen.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_link_and_run.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_simulator.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
    expect(
      find.textContaining('No real guests, messages, payments'),
      findsOneWidget,
    );
    expect(find.text('Smooth run'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -500));
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
    expect(find.text('Synthetic guests'), findsOneWidget);
    expect(find.text('Setup'), findsOneWidget);
    expect(find.text('Live'), findsWidgets);
    expect(find.text('Report'), findsOneWidget);
    expect(find.text('Live guest phone'), findsNothing);
    expect(find.textContaining('Task 3 of 8'), findsOneWidget);

    await tester.tap(find.byIcon(CatchIcons.more));
    await pumpFeatureUi(tester);

    expect(find.text('Practice tools'), findsOneWidget);
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

Widget _app(Widget child, {List overrides = const []}) => ProviderScope(
  overrides: overrides.cast(),
  child: MaterialApp(
    theme: AppTheme.light,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: child,
  ),
);

EventRehearsalBootstrap _bootstrap({
  EventRehearsalStatus status = EventRehearsalStatus.running,
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
    setup: const EventRehearsalSetup(
      title: 'Courtyard practice',
      locationName: 'Practice studio',
      durationMinutes: 120,
      hostGoal: 'Learn the live flow',
      attendeePrompt: 'Say hello to someone new',
      modules: [EventRehearsalModule.arrival, EventRehearsalModule.firstHello],
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
