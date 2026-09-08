import 'package:catch_dating_app/core/forms/catch_form_save_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class CatchFormRangeRowEditor<P> extends StatefulWidget {
  const CatchFormRangeRowEditor({
    super.key,
    required this.descriptor,
    required this.scope,
    required this.errorText,
  });

  final CatchFormRangeRow<P> descriptor;
  final CatchFormRowScope<P> scope;
  final CatchFormErrorText errorText;

  @override
  State<CatchFormRangeRowEditor<P>> createState() =>
      _CatchFormRangeRowEditorState<P>();
}

class _CatchFormRangeRowEditorState<P>
    extends State<CatchFormRangeRowEditor<P>> {
  late RangeValues _range = RangeValues(
    widget.descriptor.currentMin.toDouble(),
    widget.descriptor.currentMax.toDouble(),
  );
  final _saveState = CatchFormSaveState();

  @override
  void dispose() {
    _saveState.dispose();
    super.dispose();
  }

  void _cancel() {
    setState(() {
      _range = RangeValues(
        widget.descriptor.currentMin.toDouble(),
        widget.descriptor.currentMax.toDouble(),
      );
      _saveState.reset();
    });
    widget.scope.collapse();
  }

  Future<void> _submit() async {
    final min = _range.start.round();
    final max = _range.end.round();
    if (min == widget.descriptor.currentMin &&
        max == widget.descriptor.currentMax) {
      _cancel();
      return;
    }
    setState(() => _saveState.saving = true);
    try {
      final saved = await widget.scope.save(
        widget.descriptor.patchForRange(min, max),
      );
      if (!mounted) return;
      setState(() => _saveState.saving = false);
      if (saved) widget.scope.collapse();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saveState
          ..saving = false
          ..error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final descriptor = widget.descriptor;
    final error = _saveState.error;
    // Composite exception: a bounded two-handle slider commits one range.
    return CatchField.control(
      copy: widget.scope.fieldCopy,
      icon: descriptor.icon,
      title: descriptor.label,
      contract: descriptor.contract,
      body: widget.scope.isExpanded
          ? '${descriptor.labelText(_range.start)} - ${descriptor.labelText(_range.end)}'
          : descriptor.value,
      open: widget.scope.isExpanded,
      onOpenChanged: (_) => widget.scope.toggle(),
      isLoading: _saveState.saving,
      error: error == null ? null : widget.errorText(context, error),
      control: CatchRangeSlider(
        minimumContract: descriptor.contract,
        maximumContract: descriptor.contract,
        min: descriptor.sliderMin,
        max: descriptor.sliderMax,
        divisions: descriptor.divisions,
        values: _range,
        onChanged: _saveState.saving
            ? null
            : (range) => setState(() {
                _range = range;
                _saveState.reset();
              }),
      ),
      onCancel: _cancel,
      onSubmit: _submit,
    );
  }
}
