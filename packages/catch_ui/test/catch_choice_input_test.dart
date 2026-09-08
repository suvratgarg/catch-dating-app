import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final useCards in [false, true]) {
    for (final autoClose in [false, true]) {
      testWidgets(
        '${useCards ? 'cards' : 'chips'} commit before notifying, autoClose=$autoClose',
        (tester) async {
          final events = <String>[];
          await tester.pumpWidget(
            MaterialApp(
              theme: CatchTheme.light,
              home: Scaffold(
                body: NotificationListener<CatchFieldChoicePickedNotification>(
                  onNotification: (notification) {
                    events.add('close:${notification.autoClose}');
                    return true;
                  },
                  child: useCards
                      ? CatchFieldOptionCardControl<String>(
                          values: const ['Morning', 'Evening'],
                          itemTitle: (value) => value,
                          itemDescription: (value) => '$value details',
                          selected: 'Morning',
                          autoClose: autoClose,
                          onChanged: (value) => events.add(value),
                        )
                      : CatchChoiceInput<String>(
                          values: const ['Morning', 'Evening'],
                          selected: const {'Morning'},
                          autoClose: autoClose,
                          mode: CatchChipMode.single,
                          itemLabelBuilder: (value) => value,
                          onChanged: (values) => events.add(values.single),
                        ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('Evening'));
          expect(events, ['Evening', if (autoClose) 'close:true']);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }

  testWidgets('multi-choice commits without requesting disclosure close', (
    tester,
  ) async {
    var notifications = 0;
    Set<String>? selection;
    await tester.pumpWidget(
      MaterialApp(
        theme: CatchTheme.light,
        home: Scaffold(
          body: NotificationListener<CatchFieldChoicePickedNotification>(
            onNotification: (_) {
              notifications++;
              return true;
            },
            child: CatchChoiceInput<String>(
              values: const ['Morning', 'Evening'],
              selected: const {'Morning'},
              autoClose: true,
              mode: CatchChipMode.multiple,
              itemLabelBuilder: (value) => value,
              onChanged: (values) => selection = values,
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Evening'));
    expect(selection, {'Morning', 'Evening'});
    expect(notifications, 0);
  });
}
