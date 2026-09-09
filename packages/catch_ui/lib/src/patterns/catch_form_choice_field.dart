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

  @override
  void didUpdateWidget(CatchFormChoiceField<P, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.descriptor.id != widget.descriptor.id ||
        oldWidget.descriptor.isMultiple != widget.descriptor.isMultiple ||
        !setEquals(
          oldWidget.descriptor.selectedValues,
          widget.descriptor.selectedValues,
        )) {
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
      _selected = widget.descriptor.selectedValues;
      _saveState.reset();
    });
    widget.scope.collapse();
  }

  Future<void> _submit() async {
    if (_saveState.saving) return;
    final current = widget.descriptor.selectedValues;
    if (_selected.length == current.length && _selected.containsAll(current)) {
      _cancel();
      return;
    }
    setState(() {
      _saveState
        ..saving = true
        ..error = null
        ..status = CatchFieldStatus.saving;
    });
    try {
      final saved = await widget.scope.save(
        widget.descriptor.patchForSelection(_selected),
      );
      if (!mounted) return;
      if (!saved) {
        setState(() {
          _saveState
            ..saving = false
            ..status = CatchFieldStatus.idle;
        });
        return;
      }
      setState(() {
        _saveState
          ..saving = false
          ..status = CatchFieldStatus.saved;
      });
      widget.scope.collapse();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saveState
          ..saving = false
          ..status = CatchFieldStatus.idle
          ..error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final descriptor = widget.descriptor;
    final error = _saveState.error;
    final addable = _selected.isEmpty && descriptor.isAddAffordanceWhenEmpty;
    return CatchField<T>.choices(
      copy: widget.scope.fieldCopy,
      icon: descriptor.icon,
      title: descriptor.label,
      emptyValueText: descriptor.emptyValueText,
      helperText: descriptor.helperText,
      itemAccent: descriptor.itemAccent,
      addable: addable,
      isOptional: descriptor.showOptionalLabel,
      tone: addable ? CatchFieldTone.primary : CatchFieldTone.normal,
      open: widget.scope.isExpanded,
      onOpenChanged: (_) => widget.scope.toggle(),
      isLoading: _saveState.saving,
      status: _saveState.status,
      error: error == null ? null : widget.errorTextBuilder(context, error),
      values: descriptor.values,
      contract: descriptor.contract,
      contractValue: descriptor.contractValue,
      itemLabel: descriptor.itemLabel,
      selected: _selected,
      multi: descriptor.isMultiple,
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
