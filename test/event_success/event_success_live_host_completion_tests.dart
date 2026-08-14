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
    var nextPressed = 0;
    var completePressed = 0;
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
                child: EventSuccessHostPanel(
                  event: event,
                  plan: _racketPlan(event),
                  planIsPersisted: true,
                  roster: const EventParticipationRoster(
                    bookedIds: ['runner-1', 'runner-2'],
                    checkedInIds: ['runner-1'],
                    waitlistedIds: [],
                  ),
                  fixtureActions: EventSuccessHostFixtureActions(
                    onNextStep: () => nextPressed++,
                    onCompletePlan: () => completePressed++,
                  ),
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

    expect(nextPressed, 1);
    expect(completePressed, 1);
    expect(effects.playedKinds, [
      EventSuccessLiveEffectKind.stepChange,
      EventSuccessLiveEffectKind.guideComplete,
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
                child: EventSuccessHostPanel(
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
                child: EventSuccessHostPanel(
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
