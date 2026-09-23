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
  RangeValues? _committed;

  RangeValues get _savedRange =>
      _committed ??
      RangeValues(
        widget.descriptor.currentMin.toDouble(),
        widget.descriptor.currentMax.toDouble(),
      );

  @override
  void initState() {
    super.initState();
    _saveState.addListener(_saveChanged);
  }

  void _saveChanged() => setState(() {});

  @override
  void didUpdateWidget(CatchFormRangeField<P> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.descriptor;
    final current = widget.descriptor;
    if (old.id != current.id ||
        old.currentMin != current.currentMin ||
        old.currentMax != current.currentMax) {
      _committed = null;
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
      _range = _savedRange;
      _saveState.reset();
    });
    widget.scope.collapse();
  }

  Future<void> _submit() async {
    if (_saveState.saving) return;
    final min = _range.start.round();
    final max = _range.end.round();
    if (min == _savedRange.start && max == _savedRange.end) {
      _cancel();
      return;
    }
    final range = _range;
    final saved = await _saveState.submit(
      () => widget.scope.save(widget.descriptor.patchForRange(min, max)),
    );
    if (!saved || !mounted) return;
    _committed = range;
    widget.scope.collapse();
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
      body: widget.scope.isExpanded || _committed != null
          ? '${descriptor.labelText(_range.start)} - ${descriptor.labelText(_range.end)}'
          : descriptor.value,
      disclosureMode: widget.scope.isExpanded
          ? CatchFieldMode.controlledExpanded
          : CatchFieldMode.controlledCollapsed,
      onOpenChanged: (_) => widget.scope.toggle(),
      status: _saveState.status,
      error: error == null ? null : widget.errorTextBuilder(context, error),

      onCancel: _cancel,
      onSubmit: _submit,
      child: CatchRangeInput(
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
    );
  }
}
