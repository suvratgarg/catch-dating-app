part of 'host_create_event_screen_test.dart';

void runHostCreateEventFormatTests() {
  testWidgets('activity selection stays compact and changes the saved format', (
    tester,
  ) async {
    await _pumpCreateEventFlow(tester);
    await _openCreateEventFlow(tester);
    expect(
      find.byKey(const ValueKey('host.event_format_pack_preview')),
      findsNothing,
    );
    await _tapActivityKind(tester, 'Pub quiz');
    expect(
      find.byWidgetPredicate(
        (w) =>
            w is CatchField &&
            w.title == 'Activity type' &&
            w.body == 'Pub quiz',
      ),
      findsOneWidget,
    );
  });

  testWidgets(
    'route operations adapt across walks, crawls, and custom events',
    (tester) async {
      await _pumpCreateEventFlow(tester);
      await _openCreateEventFlow(tester);

      await _openCatchField(tester, 'Route & itinerary · Optional');
      expect(find.text('Run · Pace groups · Continuous'), findsOneWidget);
      expect(
        find.byKey(
          const ValueKey('create-event-itinerary-add'),
          skipOffstage: false,
        ),
        findsOneWidget,
      );

      await _tapActivityKind(tester, 'Walking');
      expect(find.text('Walk · One group · Flexible stops'), findsOneWidget);

      await _tapActivityKind(tester, 'Bar crawl');
      expect(find.text('Walk · One group · Hosted stops'), findsOneWidget);
      await _openCatchField(tester, 'Route operations');
      expect(find.text('Route path'), findsOneWidget);
      expect(find.text('Pace groups'), findsOneWidget);
      expect(find.text('Live Host position'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CatchField &&
              widget.title == 'Stops to prepare' &&
              widget.body != null &&
              widget.body!.contains('Venue'),
        ),
        findsOneWidget,
      );

      await _tapActivityKind(tester, 'Pub quiz');
      expect(find.text('Route plan'), findsNothing);

      await _tapActivityKind(tester, 'Open activity');
      expect(find.text('Route-based event'), findsOneWidget);
      await Scrollable.ensureVisible(
        tester.element(find.byKey(CreateEventFormKeys.routePlanEnabled)),
        alignment: 0.25,
      );
      await tester.pump();
      await tester.tap(find.byKey(CreateEventFormKeys.routePlanEnabled));
      await _pumpTestAnimation(tester);
      await _openCatchField(tester, 'Route operations');
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CatchField &&
              widget.title == 'Stops to prepare' &&
              widget.body != null &&
              widget.body!.contains('Photo spot'),
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is CatchField &&
              widget.title == 'Route roles' &&
              widget.body != null &&
              widget.body!.contains('Photographer'),
        ),
        findsOneWidget,
      );
    },
  );

  testWidgets('adds a real run-of-show entry', (tester) async {
    await _pumpCreateEventFlow(tester);
    await _openCreateEventFlow(tester);

    await _openCatchField(tester, 'Route & itinerary · Optional');
    final addStep = find.byKey(
      const ValueKey('create-event-itinerary-add'),
      skipOffstage: false,
    );
    await Scrollable.ensureVisible(tester.element(addStep), alignment: 0.25);
    await tester.pump();
    await tester.tap(addStep);
    await _pumpTestAnimation(tester);
    await _enterCreateEventText(
      tester,
      CreateEventFormKeys.itineraryTitle,
      'Water and regroup stop',
    );
    await _enterCreateEventText(
      tester,
      CreateEventFormKeys.itineraryOffset,
      '35',
    );
    await tester.tap(find.widgetWithText(CatchButton, 'Save step'));
    await _pumpTestAnimation(tester);

    expect(find.text('Water and regroup stop'), findsOneWidget);
    expect(
      find.text('Starts 35 minutes after the event begins'),
      findsOneWidget,
    );
  });
}
