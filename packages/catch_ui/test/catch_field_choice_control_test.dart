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
                      : CatchFieldChoiceControl<String>(
                          values: const ['Morning', 'Evening'],
                          itemLabel: (value) => value,
                          selected: const {'Morning'},
                          multi: false,
                          autoClose: autoClose,
                          onSelectionChanged: (values) =>
                              events.add(values.single),
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
            child: CatchFieldChoiceControl<String>(
              values: const ['Morning', 'Evening'],
              itemLabel: (value) => value,
              selected: const {'Morning'},
              multi: true,
              autoClose: true,
              onSelectionChanged: (values) => selection = values,
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
