import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;
import 'package:widgetbook_workspace/support/widgetbook_harness.dart';

@widgetbook.UseCase(
  name: 'Typed rows and commit modes',
  type: CatchFormRowDescriptor,
  path: '[Core patterns]/Form rows',
)
Widget formDescriptorStates(BuildContext context) => WidgetbookCatalogFrame(
  title: 'Typed form descriptions',
  catalogId: 'catch.field.form_row_descriptor',
  children: [
    for (final mode in CatchFormRowListMode.values)
      _FormDescriptorFields(mode: mode),
  ],
);

@widgetbook.UseCase(
  name: 'Typed rows and commit modes',
  type: CatchFormRowList,
  path: '[Core patterns]/Form rows',
)
Widget formRowListStates(BuildContext context) => formDescriptorStates(context);

@widgetbook.UseCase(
  name: 'Typed rows and commit modes',
  type: CatchFormTextField,
  path: '[Core patterns]/Form rows',
)
Widget formTextFieldStates(BuildContext context) =>
    formDescriptorStates(context);

@widgetbook.UseCase(
  name: 'Typed rows and commit modes',
  type: CatchFormChoiceField,
  path: '[Core patterns]/Form rows',
)
Widget formChoiceFieldStates(BuildContext context) =>
    formDescriptorStates(context);

@widgetbook.UseCase(
  name: 'Typed rows and commit modes',
  type: CatchFormChoiceRow,
  path: '[Core patterns]/Form rows',
)
Widget formChoiceRowStates(BuildContext context) =>
    formDescriptorStates(context);

@widgetbook.UseCase(
  name: 'Typed rows and commit modes',
  type: CatchFormRangeField,
  path: '[Core patterns]/Form rows',
)
Widget formRangeFieldStates(BuildContext context) =>
    formDescriptorStates(context);

class _FormDescriptorFields extends StatefulWidget {
  const _FormDescriptorFields({required this.mode});

  final CatchFormRowListMode mode;

  @override
  State<_FormDescriptorFields> createState() => _FormDescriptorFieldsState();
}

class _FormDescriptorFieldsState extends State<_FormDescriptorFields> {
  final _accordion = CatchAccordionController(initialExpanded: 'single');
  String _name = 'Alex';
  int? _choice = 2;
  List<int> _choices = [1, 3];
  RangeValues _range = const RangeValues(2, 4);

  @override
  void dispose() {
    _accordion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CatchFormRowList<(String, Object?)>(
    fieldCopy: catchFieldCopy(context.l10n),
    title: widget.mode == CatchFormRowListMode.explicit
        ? 'Explicit confirmation'
        : 'Save text on blur',
    accordion: _accordion,
    textCommitMode: widget.mode,
    rows: [
      CatchFormReadRow<(String, Object?)>(
        id: 'identity',
        icon: CatchIcons.personOutlined,
        label: 'Identity',
        body: 'Verified',
      ),
      CatchFormTextRow<(String, Object?)>(
        id: 'name',
        icon: CatchIcons.personOutlined,
        label: 'Name',
        currentValue: _name,
        validationCopy: catchFormValidationCopy(context.l10n),
        patchForValue: (value) => ('name', value),
      ),
      CatchFormSingleChoiceRow<(String, Object?), int>(
        id: 'single',
        icon: CatchIcons.tabEvents,
        label: 'One option',
        values: const [1, 2, 3],
        itemLabel: (value) => 'Option $value',
        value: _choice,
        patchForValue: (value) => ('single', value),
      ),
      CatchFormMultiChoiceRow<(String, Object?), int>(
        id: 'multiple',
        icon: CatchIcons.groupsOutlined,
        label: 'Several options',
        values: const [1, 2, 3],
        itemLabel: (value) => 'Option $value',
        selected: _choices,
        patchForValues: (values) => ('multiple', values),
      ),
      CatchFormRangeRow<(String, Object?)>(
        id: 'range',
        icon: CatchIcons.tuneRounded,
        label: 'Range',
        value: '${_range.start.round()} - ${_range.end.round()}',
        currentMin: _range.start.round(),
        currentMax: _range.end.round(),
        sliderMin: 0,
        sliderMax: 10,
        divisions: 10,
        labelText: (value) => value.round().toString(),
        patchForRange: (min, max) =>
            ('range', RangeValues(min.toDouble(), max.toDouble())),
      ),
      CatchFormCustomRow<(String, Object?)>(
        id: 'custom',
        icon: CatchIcons.infoOutline,
        label: 'Custom row',
        build: (context, scope) => CatchField.read(
          copy: scope.fieldCopy,
          icon: CatchIcons.infoOutline,
          title: 'Custom row',
          body: 'Content supplied by the owning feature',
        ),
      ),
    ],
    onSave: (patch) async {
      setState(() {
        switch (patch.$1) {
          case 'name':
            _name = patch.$2 as String;
          case 'single':
            _choice = patch.$2 as int?;
          case 'multiple':
            _choices = patch.$2 as List<int>;
          case 'range':
            _range = patch.$2 as RangeValues;
        }
      });
      return true;
    },
    errorTextBuilder: (_, error) => error.toString(),
  );
}
