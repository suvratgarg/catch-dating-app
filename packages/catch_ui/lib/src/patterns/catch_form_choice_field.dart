import 'package:catch_ui/catch_ui.dart';
import 'package:catch_ui/src/patterns/catch_form_row_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Form-owned choice drafts, explicit commits and save feedback.
/// Single and multiple selection share one lifecycle; descriptors retain types.
class CatchFormChoiceField<P, T> extends StatefulWidget {
  const CatchFormChoiceField.single({
    super.key,
    required CatchFormSingleChoiceRow<P, T> this.descriptor,
    required this.scope,
    required this.errorTextBuilder,
  });

  const CatchFormChoiceField.multiple({
    super.key,
    required CatchFormMultiChoiceRow<P, T> this.descriptor,
    required this.scope,
    required this.errorTextBuilder,
  });

  final CatchFormChoiceRow<P, T> descriptor;
  final CatchFormRowScope<P> scope;
  final CatchFormErrorText errorTextBuilder;

  @override
  State<CatchFormChoiceField<P, T>> createState() =>
      _CatchFormChoiceFieldState<P, T>();
}

class _CatchFormChoiceFieldState<P, T>
    extends State<CatchFormChoiceField<P, T>> {
  late Set<T> _selected = widget.descriptor.selectedValues;
  final _saveState = CatchFormSaveState();
  Set<T>? _committed;

  Set<T> get _savedSelection => _committed ?? widget.descriptor.selectedValues;

  @override
  void initState() {
    super.initState();
    _saveState.addListener(_saveChanged);
  }

  void _saveChanged() => setState(() {});

  @override
  void didUpdateWidget(CatchFormChoiceField<P, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.descriptor.id != widget.descriptor.id ||
        oldWidget.descriptor.isMultiple != widget.descriptor.isMultiple ||
        !setEquals(
          oldWidget.descriptor.selectedValues,
          widget.descriptor.selectedValues,
        )) {
      _committed = null;
      _selected = widget.descriptor.selectedValues;
    }
  }

  @override
  void dispose() {
    _saveState.dispose();
    super.dispose();
  }

  void _cancel() {
    setState(() {
      _selected = Set.of(_savedSelection);
      _saveState.reset();
    });
    widget.scope.collapse();
  }

  Future<void> _submit() async {
    if (_saveState.saving) return;
    final current = _savedSelection;
    if (_selected.length == current.length && _selected.containsAll(current)) {
      _cancel();
      return;
    }
    final selection = Set<T>.of(_selected);
    final saved = await _saveState.submit(
      () => widget.scope.save(widget.descriptor.patchForSelection(selection)),
    );
    if (!saved || !mounted) return;
    _committed = selection;
    widget.scope.collapse();
  }

  @override
  Widget build(BuildContext context) {
    final descriptor = widget.descriptor;
    final error = _saveState.error;
    final addable = _selected.isEmpty && descriptor.isAddAffordanceWhenEmpty;
    return CatchField<T>.choices(
      copy:
          descriptor.allowEmptySelection &&
              _selected.isEmpty &&
              _savedSelection.isNotEmpty
          ? widget.scope.fieldCopy.copyWith(
              doneLabel: widget.scope.fieldCopy.clearLabel,
            )
          : widget.scope.fieldCopy,
      icon: descriptor.icon,
      title: descriptor.label,
      emptyValueText: descriptor.emptyValueText,
      helperText: descriptor.helperText,
      itemAccentBuilder: descriptor.itemAccent,
      addable: addable,
      labelMode: descriptor.showOptionalLabel
          ? CatchFieldLabelTextMode.optional
          : CatchFieldLabelTextMode.visible,
      tone: addable ? CatchFieldTone.primary : CatchFieldTone.normal,
      disclosureMode: widget.scope.isExpanded
          ? CatchFieldMode.controlledExpanded
          : CatchFieldMode.controlledCollapsed,
      onOpenChanged: (_) => widget.scope.toggle(),
      status: _saveState.status,
      error: error == null ? null : widget.errorTextBuilder(context, error),
      values: descriptor.values,
      contract: descriptor.contract,
      contractValueBuilder: descriptor.contractValue,
      itemLabelBuilder: descriptor.itemLabel,
      selected: _selected,
      mode: descriptor.isMultiple
          ? CatchChipMode.multiple
          : CatchChipMode.single,
      allowEmptySelection: descriptor.allowEmptySelection,
      onSelectionChanged: (selection) {
        setState(() {
          _selected = selection;
          _saveState.reset();
        });
      },
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }
}
