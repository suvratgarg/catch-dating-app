import 'package:catch_ui/catch_ui.dart';
import 'package:catch_ui/src/patterns/catch_form_row_list.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CatchFormMultiChoiceRowEditor<P, T> extends StatefulWidget {
  const CatchFormMultiChoiceRowEditor({
    super.key,
    required this.descriptor,
    required this.scope,
    required this.errorText,
  });

  final CatchFormMultiChoiceRow<P, T> descriptor;
  final CatchFormRowScope<P> scope;
  final CatchFormErrorText errorText;

  @override
  State<CatchFormMultiChoiceRowEditor<P, T>> createState() =>
      _CatchFormMultiChoiceRowEditorState<P, T>();
}

class _CatchFormMultiChoiceRowEditorState<P, T>
    extends State<CatchFormMultiChoiceRowEditor<P, T>> {
  late Set<T> _selected = widget.descriptor.selected.toSet();
  final _saveState = CatchFormSaveState();

  @override
  void didUpdateWidget(CatchFormMultiChoiceRowEditor<P, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!setEquals(
      oldWidget.descriptor.selected.toSet(),
      widget.descriptor.selected.toSet(),
    )) {
      _selected = widget.descriptor.selected.toSet();
    }
  }

  @override
  void dispose() {
    _saveState.dispose();
    super.dispose();
  }

  void _cancel() {
    setState(() {
      _selected = widget.descriptor.selected.toSet();
      _saveState.reset();
    });
    widget.scope.collapse();
  }

  Future<void> _submit() async {
    if (_saveState.saving) return;
    final current = widget.descriptor.selected;
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
        widget.descriptor.patchForValues(_selected.toList(growable: false)),
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
      error: error == null ? null : widget.errorText(context, error),
      values: descriptor.values,
      contract: descriptor.contract,
      contractValue: descriptor.contractValue,
      itemLabel: descriptor.itemLabel,
      selected: _selected,
      multi: true,
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
