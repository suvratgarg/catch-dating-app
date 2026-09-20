import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'const input labels keep one line by default and allow caller wrapping',
    () {
      const defaultInput = CatchField.input(copy: _copy, title: 'Label');
      const wrappedInput = CatchField.input(
        copy: _copy,
        title: 'A longer dependent input label',
        titleMaxLines: 3,
      );
      expect(defaultInput.titleMaxLines, 1);
      expect(wrappedInput.titleMaxLines, 3);
    },
  );

  test(
    'row modes retain const construction and distinct behavior defaults',
    () {
      const fields = [
        CatchField.read(
          content: CatchRecordLayout(title: 'Record', icon: Icons.event),
        ),
        CatchField.content(copy: _copy, title: 'Title', body: 'Body'),
        CatchField.navigate(
          content: CatchRecordLayout(title: 'Record', icon: Icons.event),
          onActivate: _activate,
        ),
        CatchField.loading(
          content: CatchRecordLayout(title: 'Record', icon: Icons.event),
        ),
        CatchField.nav(copy: _copy, title: 'Title'),
        CatchField.sortable(
          copy: _copy,
          title: 'Title',
          metadata: 'Metadata',
          leading: Icon(Icons.drag_handle),
          onTap: _activate,
        ),
        CatchField.action(copy: _copy, title: 'Title', onTap: _activate),
        CatchField.add(copy: _copy, title: 'Title', onTap: _activate),
      ];
      for (final field in fields) {
        expect(field.variant, CatchFieldVariant.row);
        expect(field.status, CatchFieldStatus.idle);
        expect(field.enabled, isTrue);
        expect(field.contract, isNull);
      }
      expect(fields[0].titleMaxLines, 1);
      expect(fields[0].bodyMaxLines, 2);
      expect(fields[1].titleMaxLines, 2);
      expect(fields[1].bodyMaxLines, 3);
      expect(fields[2].onTap, same(_activate));
      expect(fields[3].showChevron, isTrue);
      expect(fields[3].onTap, isNull);
      expect(fields[4].showChevron, isNull);
      expect(fields[5].inlineMetadata, 'Metadata');
      expect(fields[5].bodyMaxLines, 1);
      expect(fields[5].emphasis, CatchFieldEmphasis.title);
      expect(fields[6].showChevron, isNull);
      expect(fields[7].add, isTrue);
      expect(fields[7].tone, CatchFieldTone.primary);
    },
  );

  test(
    'row forwarding preserves supplied slots, limits and disabled actions',
    () {
      const key = ValueKey('custom-action');
      const action = CatchField.action(
        key: key,
        copy: _copy,
        title: 'Title',
        body: 'Body',
        onTap: _activate,
        states: {WidgetState.disabled},
        titleMaxLines: 3,
        bodyMaxLines: 4,
        valueText: 'Value',
        valueMaxLines: 5,
        placeholder: 'Placeholder',
        error: 'Error',
        errorText: 'Error text',
        valid: true,
        leading: Icon(Icons.person),
        leadingExtent: 48,
        emphasis: CatchFieldEmphasis.title,
        tone: CatchFieldTone.primary,
      );
      expect(action.key, key);
      expect(action.title, 'Title');
      expect(action.body, 'Body');
      expect(action.onTap, same(_activate));
      expect(action.enabled, isFalse);
      expect(action.titleMaxLines, 3);
      expect(action.bodyMaxLines, 4);
      expect(action.valueText, 'Value');
      expect(action.valueMaxLines, 5);
      expect(action.placeholder, 'Placeholder');
      expect(action.error, 'Error');
      expect(action.errorText, 'Error text');
      expect(action.valid, isTrue);
      expect(action.leadingExtent, 48);
      expect(action.emphasis, CatchFieldEmphasis.title);
      expect(action.tone, CatchFieldTone.primary);
      const loading = CatchField.loading(
        content: CatchRecordLayout(title: 'Record', icon: Icons.event),
        navigable: false,
      );
      expect(loading.showChevron, isFalse);
      expect(loading.onTap, isNull);
    },
  );
}

void _activate() {}
String _label(String value) => value;

String _nullableLabel(String? value) => value ?? '';
String _length(String label, int length) => '$label $length';
const _copy = CatchFieldCopy(
  label: CatchFieldLabelTextCopy(
    optionalLabel: 'Optional',
    optionalSuffix: ' Optional',
    optionalSemantics: _label,
  ),
  validation: CatchFormValidationCopy(
    requiredMessage: _label,
    minLengthMessage: _length,
    maxLengthMessage: _length,
    patternMessage: _label,
  ),
  cancelLabel: 'Cancel',
  doneLabel: 'Done',
  savingLabel: 'Saving',
  savingSemanticLabel: 'Saving',
  savedSemanticLabel: 'Saved',
  emptyValueText: _label,
  selectPlaceholder: _nullableLabel,
  clearTooltip: _nullableLabel,
);
