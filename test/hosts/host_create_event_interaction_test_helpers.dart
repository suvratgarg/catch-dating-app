part of 'host_create_event_screen_test.dart';

Future<void> _openCreateEventFlow(WidgetTester tester) async {
  await tester.tap(find.text('Open'));
  await _pumpTestAnimation(tester);
  final nameField = find.byKey(CreateEventFormKeys.name, skipOffstage: false);
  if (nameField.evaluate().isNotEmpty) {
    await _enterCreateEventText(tester, CreateEventFormKeys.name, 'Test event');
  }
}

Future<void> _tapActivityKind(WidgetTester tester, String label) async {
  await _openCatchField(tester, 'Activity type');
  await _tapCreateEventChip(tester, label);
}

Future<void> _openCatchField(WidgetTester tester, String title) async {
  final field = find.byWidgetPredicate(
    (widget) => widget is CatchField && widget.title == title,
  );
  await Scrollable.ensureVisible(tester.element(field), alignment: 0.25);
  await tester.pump();
  await tester.tap(field);
  await _pumpTestAnimation(tester);
}

Future<void> _tapCreateEventChip(WidgetTester tester, String label) async {
  final finder = find.byWidgetPredicate(
    (widget) => widget is CatchFieldChoiceChip && widget.label == label,
    description: 'selectable chip labeled $label',
  );
  await Scrollable.ensureVisible(tester.element(finder), alignment: 0.25);
  await tester.pump();
  await tester.tap(finder.hitTestable());
  await _pumpTestAnimation(tester);
}
