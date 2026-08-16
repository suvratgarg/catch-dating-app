part of 'host_create_event_screen_test.dart';

void runHostCreateEventLifecycleTests() {
  testWidgets('host manage exposes one lifecycle workspace and roster edge', (
    tester,
  ) async {
    final participationRepository = FakeEventParticipationRepository();
    final now = DateTime(2026, 8, 17, 12);
    final event = buildEvent(
      id: 'event-preview',
      startTime: now.add(const Duration(hours: 2)),
      endTime: now.add(const Duration(hours: 3)),
    );

    await pumpEventsTestApp(
      tester,
      HostEventManageScreen(
        club: buildClub(),
        event: event,
        onBackToSuccess: () {},
        referenceNow: now,
      ),
      overrides: [
        eventParticipationRepositoryProvider.overrideWith(
          (ref) => participationRepository,
        ),
      ],
      signedInUid: 'host-1',
    );
    await _pumpHostActionFrame(tester);

    expect(find.text('Event preparation'), findsOneWidget);
    expect(find.byType(HostEventRosterDrawer), findsOneWidget);
    expect(find.text('SETUP'), findsNothing);
    expect(find.text('GUESTS'), findsNothing);
    expect(find.text('LIVE'), findsNothing);
    expect(find.text('REPORT'), findsNothing);
    expect(find.text('Event success'), findsNothing);
    expect(find.text('Open event success'), findsNothing);
  });

  testWidgets('past event opens recap without setup or live navigation', (
    tester,
  ) async {
    final participationRepository = FakeEventParticipationRepository();
    final now = DateTime(2026, 8, 17, 12);
    final event = buildEvent(
      id: 'event-past-recap',
      startTime: now.subtract(const Duration(hours: 3)),
      endTime: now.subtract(const Duration(hours: 1)),
    );

    await pumpEventsTestApp(
      tester,
      HostEventManageScreen(
        club: buildClub(),
        event: event,
        onBackToSuccess: () {},
        referenceNow: now,
      ),
      overrides: [
        eventParticipationRepositoryProvider.overrideWith(
          (ref) => participationRepository,
        ),
      ],
      signedInUid: 'host-1',
    );
    await _pumpHostActionFrame(tester);

    expect(find.text('Event recap'), findsOneWidget);
    expect(find.text('SETUP'), findsNothing);
    expect(find.text('GUESTS'), findsNothing);
    expect(find.text('LIVE'), findsNothing);
    expect(find.text('REPORT'), findsNothing);
    expect(find.byType(HostEventRosterDrawer), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Review event setup'),
      300,
      scrollable: hostManageScrollable(),
    );
    expect(find.text('Review event setup'), findsOneWidget);
  });
}
