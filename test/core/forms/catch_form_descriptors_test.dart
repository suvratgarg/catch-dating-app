import 'dart:async';

import 'package:catch_dating_app/core/forms/catch_form_descriptors.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CatchFormRowList maps rows through one accordion and save', (
    tester,
  ) async {
    final pendingSave = Completer<bool>();
    _Patch? savedPatch;

    await tester.pumpWidget(
      _wrap(
        CatchFormRowList<_Patch>(
          title: 'About you',
          dividerInset: CatchFieldRow.textLaneInset,
          rows: [
            CatchFormReadRow<_Patch>(
              id: 'identity',
              icon: CatchIcons.personOutlined,
              label: 'Identity',
              body: 'Verified',
            ),
            CatchFormSingleChoiceRow<_Patch, _Option>(
              id: 'city',
              icon: CatchIcons.locationOnOutlined,
              label: 'City',
              values: _Option.values,
              value: _Option.mumbai,
              patchForValue: (value) => _Patch(value?.label),
            ),
            CatchFormCustomRow<_Patch>(
              id: 'custom',
              icon: CatchIcons.tuneRounded,
              label: 'Custom',
              build: (context, scope) => CatchField.control(
                title: 'Custom',
                open: scope.isExpanded,
                onOpenChanged: (_) => scope.toggle(),
                control: const Text('Custom control'),
              ),
            ),
          ],
          savePatch: (patch) {
            savedPatch = patch;
            return pendingSave.future;
          },
          errorText: (_, error) => error.toString(),
        ),
      ),
    );

    expect(find.text('ABOUT YOU'), findsOneWidget);
    expect(find.text('Verified'), findsOneWidget);

    await tester.tap(find.text('City'));
    await _pumpFieldMotion(tester);
    expect(find.text('Delhi').hitTestable(), findsOneWidget);

    await tester.tap(find.text('Delhi'));
    await tester.tap(find.byKey(const ValueKey('catch-field-done')));
    await tester.pump();
    expect(savedPatch?.value, 'Delhi');
    expect(find.byKey(const ValueKey('catch-field-spinner')), findsOneWidget);

    pendingSave.complete(true);
    await tester.pump();
    await _pumpFieldMotion(tester);
    expect(find.byType(CatchFieldChoiceChip).hitTestable(), findsNothing);

    await tester.tap(find.text('Custom'));
    await _pumpFieldMotion(tester);
    expect(find.text('Custom control').hitTestable(), findsOneWidget);
  });

  test('descriptor family preserves typed patch factories', () {
    final text = CatchFormTextRow<_Patch>(
      id: 'name',
      icon: CatchIcons.personOutlined,
      label: 'Name',
      currentValue: 'Before',
      patchForValue: (value) => _Patch(value as String),
    );
    final multi = CatchFormMultiChoiceRow<_Patch, _Option>(
      id: 'cities',
      icon: CatchIcons.locationOnOutlined,
      label: 'Cities',
      values: _Option.values,
      selected: const [_Option.mumbai],
      patchForValues: (values) =>
          _Patch(values.map((item) => item.label).join()),
    );
    final range = CatchFormRangeRow<_Patch>(
      id: 'range',
      icon: CatchIcons.tuneRounded,
      label: 'Range',
      value: '1 - 2',
      currentMin: 1,
      currentMax: 2,
      sliderMin: 0,
      sliderMax: 10,
      divisions: 10,
      labelText: (value) => value.round().toString(),
      patchForRange: (min, max) => _Patch('$min-$max'),
    );

    expect(text.patchForValue('After').value, 'After');
    expect(multi.patchForValues(_Option.values).value, 'MumbaiDelhi');
    expect(range.patchForRange(3, 7).value, '3-7');
  });
}

class _Patch {
  const _Patch(this.value);

  final String? value;
}

enum _Option implements Labelled {
  mumbai('Mumbai'),
  delhi('Delhi');

  const _Option(this.label);

  @override
  final String label;
}

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.light,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

Future<void> _pumpFieldMotion(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(CatchFieldTokens.reveal);
  await tester.pump();
}
