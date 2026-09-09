import 'package:catch_ui/catch_ui.dart';
import 'package:catch_ui/src/patterns/catch_form_row_list.dart';
import 'package:flutter/material.dart';

/// Form-owned bounded range draft with explicit confirmation and patch saves.
class CatchFormRangeField<P> extends StatefulWidget {
  const CatchFormRangeField({
    super.key,
    required this.descriptor,
    required this.scope,
    required this.errorTextBuilder,
  });

  final CatchFormRangeRow<P> descriptor;
  final CatchFormRowScope<P> scope;
  final CatchFormErrorText errorTextBuilder;

  @override
  State<CatchFormRangeField<P>> createState() => _CatchFormRangeFieldState<P>();
}

class _CatchFormRangeFieldState<P> extends State<CatchFormRangeField<P>> {
  late RangeValues _range = RangeValues(
    widget.descriptor.currentMin.toDouble(),
    widget.descriptor.currentMax.toDouble(),
  );
  final _saveState = CatchFormSaveState();

  @override
  void didUpdateWidget(CatchFormRangeField<P> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.descriptor;
    final current = widget.descriptor;
    if (old.id != current.id ||
        old.currentMin != current.currentMin ||
        old.currentMax != current.currentMax) {
      _range = RangeValues(
        current.currentMin.toDouble(),
        current.currentMax.toDouble(),
      );
    }
  }

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
    if (_saveState.saving) return;
    final min = _range.start.round();
    final max = _range.end.round();
    if (min == widget.descriptor.currentMin &&
        max == widget.descriptor.currentMax) {
      _cancel();
      return;
    }
    setState(() {
      _saveState
        ..saving = true
        ..error = null;
    });
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
      error: error == null ? null : widget.errorTextBuilder(context, error),
      control: CatchRangeInput(
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
