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

    await tester.scrollUntilVisible(
      find.text('GUEST SOURCES'),
      300,
      scrollable: hostManageScrollable(),
    );
    expect(find.text('Website registration'), findsOneWidget);
    expect(find.text('Imported guest list'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('TEAM & ACCESS'),
      300,
      scrollable: hostManageScrollable(),
    );
    expect(find.text('Event staff access'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Open guest roster'));
    await _pumpTestAnimation(tester);

    final rosterPanel = find.byKey(
      const ValueKey<String>('host_event_roster_drawer.panel'),
    );
    expect(
      find.descendant(of: rosterPanel, matching: find.text('Guest roster')),
      findsWidgets,
    );
    expect(
      find.descendant(
        of: rosterPanel,
        matching: find.text('Imported guest list'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: rosterPanel,
        matching: find.text('Website registration'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: rosterPanel,
        matching: find.text('Event staff access'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(
        of: rosterPanel,
        matching: find.text('Import spreadsheet'),
      ),
      findsNothing,
    );
    expect(
      find.descendant(of: rosterPanel, matching: find.text('Add walk-in')),
      findsNothing,
    );
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

    await tester.tap(find.bySemanticsLabel('Open guest roster'));
    await _pumpTestAnimation(tester);
    final rosterPanel = find.byKey(
      const ValueKey<String>('host_event_roster_drawer.panel'),
    );
    expect(
      find.descendant(of: rosterPanel, matching: find.text('Add walk-in')),
      findsNothing,
    );
    expect(
      find.descendant(
        of: rosterPanel,
        matching: find.text('Import spreadsheet'),
      ),
      findsNothing,
    );
  });
}
