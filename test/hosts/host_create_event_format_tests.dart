part of 'host_create_event_screen_test.dart';

void runHostCreateEventFormatTests() {
  testWidgets('event type previews the operating format Catch prepares', (
    tester,
  ) async {
    await _pumpCreateEventFlow(tester);
    await _openCreateEventFlow(tester);

    expect(find.text('Pace pods · timed legs · finish sweep'), findsOneWidget);

    await _tapActivityKind(tester, 'Pub quiz');

    expect(find.text('Catch prepares'), findsOneWidget);
    expect(
      find.text('Teams · points by round · standings reveal'),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('host.event_format_pack_preview')),
      findsOneWidget,
    );
  });

  testWidgets(
    'route operations adapt across walks, crawls, and custom events',
    (tester) async {
      await _pumpCreateEventFlow(tester);
      await _openCreateEventFlow(tester);

      expect(find.text('Run · Pace groups · Continuous'), findsOneWidget);

      await _tapActivityKind(tester, 'Walking');
      expect(find.text('Walk · One group · Flexible stops'), findsOneWidget);

      await _tapActivityKind(tester, 'Bar crawl');
      expect(find.text('Walk · One group · Hosted stops'), findsOneWidget);
      await _openCatchField(tester, 'Route operations');
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
      await tester.ensureVisible(
        find.byKey(CreateEventFormKeys.routePlanEnabled),
      );
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
}
