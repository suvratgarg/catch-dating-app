import 'package:catch_dating_app/core/widgets/catch_chip_field.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => MaterialApp(
  theme: CatchTheme.light,
  home: Scaffold(body: child),
);

CatchFormFieldLabelCopy _copy(String optional) => CatchFormFieldLabelCopy(
  optionalLabel: optional,
  optionalSuffix: ' ($optional)',
  optionalSemantics: (label) => '$label, $optional',
);

void main() {
  testWidgets(
    'plain values retain identity through caller labels and form state',
    (tester) async {
      final form = GlobalKey<FormState>();
      var selected = <int>{1};
      Set<int>? validated;
      await tester.pumpWidget(
        _app(
          Form(
            key: form,
            child: StatefulBuilder(
              builder: (context, setState) => CatchChipField<int>(
                label: 'Places',
                copy: _copy('facultatif'),
                itemLabel: (value) => '$value places',
                values: const [1, 2],
                selected: selected,
                multiSelect: true,
                isOptional: true,
                chipKeyBuilder: (value) => ValueKey(value),
                onChanged: (next) => setState(() => selected = next),
                validator: (value) {
                  validated = value;
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      expect(find.bySemanticsLabel('Places, facultatif'), findsOneWidget);
      expect(find.text('facultatif'), findsOneWidget);
      expect(find.text('2 places'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey(2)));
      await tester.pump();
      expect(selected, {1, 2});
      expect(form.currentState!.validate(), isTrue);
      expect(validated, {1, 2});
    },
  );

  testWidgets('new caller copy updates labels without changing schema values', (
    tester,
  ) async {
    var selected = <int>{1};
    var french = false;
    late StateSetter rebuild;
    await tester.pumpWidget(
      _app(
        StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return CatchChipField<int>(
              label: 'Places',
              copy: _copy(french ? 'facultatif' : 'optional'),
              itemLabel: (value) => french ? 'Choix $value' : 'Choice $value',
              contract: const CatchContractFieldConstraints(
                path: 'test.choice',
                valueTypes: ['string'],
                enumValues: ['value_1', 'value_2'],
              ),
              contractValue: (value) => 'value_$value',
              values: const [1, 2, 3],
              selected: selected,
              multiSelect: false,
              isOptional: true,
              allowEmptySingleSelection: true,
              onChanged: (next) => setState(() => selected = next),
            );
          },
        ),
      ),
    );

    expect(find.text('Choice 3'), findsNothing);
    rebuild(() => french = true);
    await tester.pump();
    expect(find.text('Choice 1'), findsNothing);
    expect(find.text('Choix 1'), findsOneWidget);
    expect(find.text('Choix 3'), findsNothing);
    expect(find.bySemanticsLabel('Places, facultatif'), findsOneWidget);
    expect(selected, {1});
    await tester.tap(find.text('Choix 2'));
    await tester.pump();
    expect(selected, {2});
    await tester.tap(find.text('Choix 2'));
    await tester.pump();
    expect(selected, isEmpty);
  });
}
