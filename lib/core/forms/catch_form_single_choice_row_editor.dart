import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

import 'catch_form_descriptors.dart';
import 'catch_form_save_state.dart';

class CatchFormSingleChoiceRowEditor<P, T> extends StatefulWidget {
  const CatchFormSingleChoiceRowEditor({
    super.key,
    required this.descriptor,
    required this.scope,
    required this.errorText,
  });

  final CatchFormSingleChoiceRow<P, T> descriptor;
  final CatchFormRowScope<P> scope;
  final CatchFormErrorText errorText;

  @override
  State<CatchFormSingleChoiceRowEditor<P, T>> createState() =>
      _CatchFormSingleChoiceRowEditorState<P, T>();
}

class _CatchFormSingleChoiceRowEditorState<P, T>
    extends State<CatchFormSingleChoiceRowEditor<P, T>> {
  late T? _selected = widget.descriptor.value;
  final _saveState = CatchFormSaveState();

  @override
  void didUpdateWidget(CatchFormSingleChoiceRowEditor<P, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.descriptor.value != widget.descriptor.value) {
      _selected = widget.descriptor.value;
    }
  }

  @override
  void dispose() {
    _saveState.dispose();
    super.dispose();
  }

  void _cancel() {
    setState(() {
      _selected = widget.descriptor.value;
      _saveState.reset();
    });
    widget.scope.collapse();
  }

  Future<void> _submit() async {
    if (_saveState.saving) return;
    if (_selected == widget.descriptor.value) {
      _cancel();
      return;
    }
    await _save(widget.descriptor.patchForValue(_selected));
  }

  Future<void> _save(P patch) async {
    setState(() {
      _saveState
        ..saving = true
        ..error = null
        ..status = CatchFieldStatus.saving;
    });
    try {
      final saved = await widget.scope.save(patch);
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
    final addable = _selected == null;
    return CatchField.choices<T>(
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
      selected: {?_selected},
      allowEmptySelection: descriptor.allowEmptySelection,
      onSelectionChanged: (selection) {
        setState(() {
          _selected = selection.isEmpty ? null : selection.first;
          _saveState.reset();
        });
      },
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }
}
