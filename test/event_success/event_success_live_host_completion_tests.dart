part of 'event_success_live_screens_test.dart';

void _hostLiveCompletionTests() {
  testWidgets('host live actions dispatch ceremony effects once per tap', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 5000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final effects = _FakeEventSuccessLiveEffectsController();
    final stepIndexes = <int>[];
    final completionAcknowledgements = <bool>[];
    final start = DateTime(2026, 5, 21, 8);
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(minutes: 30)),
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          eventSuccessLiveEffectsControllerProvider.overrideWithValue(effects),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostWorkspacePageBody(
                  event: event,
                  plan: _racketPlan(event),
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2'],
                    checkedInIds: ['runner-1'],
                    waitlistedIds: [],
                  ),
                  onSetLiveStep: (stepIndex) async {
                    await effects.play(EventSuccessLiveEffectKind.stepChange);
                    stepIndexes.add(stepIndex);
                  },
                  onCompleteLiveGuide: (acknowledged) async {
                    await effects.play(
                      EventSuccessLiveEffectKind.guideComplete,
                    );
                    completionAcknowledgements.add(acknowledged);
                  },
                  onPlayLiveEffect: effects.play,
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('eventSuccessNextStepButton')));
    await tester.tap(find.byKey(const ValueKey('eventSuccessNextStepButton')));
    await tester.pump();
    await tester.tap(
      find.widgetWithText(CatchButton, 'Mark live guide complete'),
    );
    await tester.pump();

    expect(stepIndexes, [1]);
    expect(completionAcknowledgements, [false]);
    expect(effects.playedKinds, [
      EventSuccessLiveEffectKind.stepChange,
      EventSuccessLiveEffectKind.guideComplete,
    ]);
  });

  Future<void> pumpCallbacks(
    WidgetTester tester, {
    Future<void> Function(int)? onSetStep,
    Future<void> Function(bool)? onComplete,
    Future<void> Function(int, int)? onStartCountdown,
    Future<void> Function(int)? onReveal,
    Future<void> Function()? onReset,
    Future<void> Function(EventSuccessLiveEffectKind)? onEffect,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 5000);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final event = _racketEvent(
      startTime: DateTime(2026, 5, 21, 8),
      endTime: DateTime(2026, 5, 21, 9),
    );
    // Exercise the provider-free workspace with ordinary callback owners.
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: EventSuccessHostWorkspacePageBody(
            event: event,
            plan: _racketPlan(event).copyWith(activeStepIndex: 1),
            planIsPersisted: true,
            roster: EventParticipationRoster.empty(),
            initialTab: EventSuccessHostTab.live,
            showTabs: false,
            onSetLiveStep: onSetStep,
            onCompleteLiveGuide: onComplete,
            onStartRevealCountdown: onStartCountdown,
            onRevealRound: onReveal,
            onResetReveal: onReset,
            onPlayLiveEffect: onEffect,
          ),
        ),
      ),
    );
  }

  EventSuccessHostLivePageBody liveBody(WidgetTester tester) =>
      tester.widget<EventSuccessHostLivePageBody>(
        find.byType(EventSuccessHostLivePageBody),
      );

  testWidgets('missing callbacks disable actions without playing effects', (
    tester,
  ) async {
    final effects = <EventSuccessLiveEffectKind>[];
    await pumpCallbacks(tester, onEffect: (kind) async => effects.add(kind));
    final body = liveBody(tester);
    expect(body.onPreviousStep, isNull);
    expect(body.onNextStep, isNull);
    expect(body.onCompleteGuide, isNull);
    expect(body.onStartRevealCountdown, isNull);
    expect(body.onRevealRound, isNull);
    expect(body.onResetReveal, isNull);
    expect(
      tester
          .widget<CatchButton>(
            find.byKey(const ValueKey('eventSuccessNextStepButton')),
          )
          .onPressed,
      isNull,
    );
    expect(
      tester
          .widget<CatchButton>(
            find.widgetWithText(CatchButton, 'Mark live guide complete'),
          )
          .onPressed,
      isNull,
    );
    expect(effects, isEmpty);
  });

  testWidgets(
    'pending step blocks competing actions and recovers after error',
    (tester) async {
      final pending = Completer<void>();
      final steps = <int>[];
      final completions = <bool>[];
      await pumpCallbacks(
        tester,
        onSetStep: (index) {
          steps.add(index);
          return index == 2 ? pending.future : Future.value();
        },
        onComplete: (acknowledged) async => completions.add(acknowledged),
      );
      final body = liveBody(tester);
      final next = body.onNextStep!(2);
      final failure = StateError('step rejected');
      final nextExpectation = expectLater(next, throwsA(same(failure)));
      await body.onNextStep!(2);
      await body.onPreviousStep!(0);
      await body.onCompleteGuide!(false);
      await tester.pump();
      expect(steps, [2]);
      expect(completions, isEmpty);
      expect(liveBody(tester).actionState.isChangingStep, isTrue);
      expect(
        tester
            .widget<CatchButton>(
              find.byKey(const ValueKey('eventSuccessNextStepButton')),
            )
            .onPressed,
        isNull,
      );
      pending.completeError(failure);
      await nextExpectation;
      await tester.pump();
      expect(liveBody(tester).actionState.isChangingStep, isFalse);
      await tester.tap(
        find.byKey(const ValueKey('eventSuccessPreviousStepButton')),
      );
      await tester.pump();
      expect(steps, [2, 0]);
      await tester.tap(
        find.widgetWithText(CatchButton, 'Mark live guide complete'),
      );
      await tester.pump();
      expect(completions, [false]);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('reveal callbacks retain arguments and await their effects', (
    tester,
  ) async {
    final firstEffect = Completer<void>();
    final order = <Object>[];
    await pumpCallbacks(
      tester,
      onEffect: (kind) {
        order.add(kind);
        return kind == EventSuccessLiveEffectKind.countdownStart
            ? firstEffect.future
            : Future.value();
      },
      onStartCountdown: (round, seconds) async {
        order.add([round, seconds]);
      },
      onReveal: (round) async => order.add(round),
      onReset: () async => order.add('reset'),
    );
    final body = liveBody(tester);
    final countdown = body.onStartRevealCountdown!(3, 10);
    expect(order, [EventSuccessLiveEffectKind.countdownStart]);
    firstEffect.complete();
    await countdown;
    await body.onRevealRound!(3);
    await body.onResetReveal!();
    expect(order, [
      EventSuccessLiveEffectKind.countdownStart,
      [3, 10],
      EventSuccessLiveEffectKind.assignmentRevealed,
      3,
      EventSuccessLiveEffectKind.revealReset,
      'reset',
    ]);
  });

  testWidgets(
    'unresolved sweep warns while review and finish-anyway stay available',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(430, 5000);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final event = buildEvent(id: 'event-accountability-warning');
      final plan = EventSuccessPlan.defaultForEvent(
        event,
        now: event.startTime,
      );
      bool? acknowledged;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SafeArea(
                child: EventSuccessHostWorkspacePageBody(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['guest-1'],
                    checkedInIds: ['guest-1'],
                    waitlistedIds: [],
                  ),
                  accountabilityAttendees: [
                    _accountabilityAttendee(
                      event: event,
                      id: 'imported-guest-1',
                      displayName: 'Ari Guest',
                    ),
                  ],
                  onCompleteLiveGuide: (value) async {
                    acknowledged = value;
                  },
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Return sweep'), findsOneWidget);
      expect(find.text('Ari Guest'), findsOneWidget);

      await tester.tap(
        find.widgetWithText(CatchButton, 'Mark live guide complete'),
      );
      await pumpUntilFound(tester, find.text('Some guests aren’t marked yet'));

      expect(find.text('Some guests aren’t marked yet'), findsOneWidget);
      expect(find.textContaining('leave without checking out'), findsOneWidget);
      expect(acknowledged, isNull);

      await tester.tap(find.text('Review sweep'));
      await pumpFeatureUi(tester);
      expect(acknowledged, isNull);

      await tester.tap(
        find.widgetWithText(CatchButton, 'Mark live guide complete'),
      );
      await pumpUntilFound(tester, find.text('Finish anyway'));
      await tester.tap(find.text('Finish anyway'));
      await pumpFeatureUi(tester);

      expect(acknowledged, isTrue);
    },
  );

  testWidgets('host live mode requires generation before rotation edits', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(430, 1600);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final start = DateTime(2026, 5, 21, 8);
    final event = _racketEvent(
      startTime: start,
      endTime: start.add(const Duration(minutes: 30)),
    );
    final plan = _racketPlan(event);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: EventSuccessHostWorkspacePageBody(
                  event: event,
                  plan: plan,
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2'],
                    checkedInIds: ['runner-1', 'runner-2'],
                    waitlistedIds: [],
                  ),
                  initialTab: EventSuccessHostTab.live,
                  showTabs: false,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Timed partner rotations'), findsOneWidget);
    expect(find.text('0 rounds'), findsOneWidget);
    expect(find.text('Generate rotations'), findsOneWidget);
    expect(find.text('Edit rotations'), findsNothing);
  });
}
