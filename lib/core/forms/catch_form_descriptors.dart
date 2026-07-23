import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/schema_contracts/catch_contract_field_policy.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_field_accordion.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef CatchFormSave<P> = Future<bool> Function(P patch);
typedef CatchFormErrorText =
    String Function(BuildContext context, Object error);

/// P is the patch type committed by the owning surface.
sealed class CatchFormRowDescriptor<P> {
  const CatchFormRowDescriptor({
    required this.id,
    required this.icon,
    required this.label,
  });

  final String id;
  final IconData icon;
  final String label;

  String get accordionKey => id;

  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  );
}

final class CatchFormReadRow<P> extends CatchFormRowDescriptor<P> {
  const CatchFormReadRow({
    required super.id,
    required super.icon,
    required super.label,
    required this.body,
    this.bodyMaxLines = 4,
  });

  final String body;
  final int bodyMaxLines;

  @override
  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  ) {
    return CatchField.read(
      icon: icon,
      title: label,
      body: body,
      bodyMaxLines: bodyMaxLines,
    );
  }
}

final class CatchFormTextRow<P> extends CatchFormRowDescriptor<P> {
  const CatchFormTextRow({
    required super.id,
    required super.icon,
    required super.label,
    required this.currentValue,
    required this.patchForValue,
    this.fieldName,
    this.currentFieldValue,
    this.emptyValueText,
    this.placeholder,
    this.inputHint,
    this.leadingUnit,
    this.showClearButton = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
    this.validator,
    this.toFieldValue,
    this.contract,
    this.maxLength,
    this.inputFormatters,
    this.explicitSave = false,
    this.maxLines = 1,
    this.minLines,
    this.normalizeInput,
  });

  final String currentValue;
  final Object? currentFieldValue;
  final String? fieldName;
  final String? emptyValueText;
  final String? placeholder;
  final String? inputHint;
  final String? leadingUnit;
  final bool showClearButton;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;
  final CatchContractFieldConstraints? contract;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final bool explicitSave;
  final int? maxLines;
  final int? minLines;
  final String Function(String value)? normalizeInput;
  final P Function(Object? value) patchForValue;

  int? get effectiveMaxLength =>
      CatchContractFieldPolicy.effectiveMaxLength(contract, maxLength);

  List<TextInputFormatter>? get effectiveInputFormatters =>
      CatchContractFieldPolicy.effectiveInputFormatters(
        contract,
        inputFormatters,
        explicitMaxLength: maxLength,
      );

  String? validate(BuildContext context, String value) =>
      CatchContractFieldPolicy.validateText(
        context,
        label: label,
        value: value,
        contract: contract,
        explicitValidator: validator,
      );

  @override
  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  ) {
    assert(
      maxLength == null ||
          contract?.maxLength == null ||
          maxLength! <= contract!.maxLength!,
      'An explicit maxLength cannot exceed the schema contract.',
    );
    return CatchFormTextRowEditor<P>(
      key: ValueKey('catch-form-text-$id'),
      descriptor: this,
      scope: scope,
      errorText: errorText,
    );
  }
}

final class CatchFormSingleChoiceRow<P, T extends Labelled>
    extends CatchFormRowDescriptor<P> {
  const CatchFormSingleChoiceRow({
    required super.id,
    required super.icon,
    required super.label,
    required this.values,
    required this.value,
    required this.patchForValue,
    this.fieldName,
    this.emptyValueText,
    this.helperText,
    this.itemAccent,
    this.contractValue,
    this.allowEmptySelection = true,
    this.showOptionalLabel = false,
    this.contract,
  });

  final List<T> values;
  final T? value;
  final String? fieldName;
  final String? emptyValueText;
  final String? helperText;
  final Color? Function(T item)? itemAccent;
  final String Function(T value)? contractValue;
  final bool allowEmptySelection;
  final bool showOptionalLabel;
  final CatchContractFieldConstraints? contract;
  final P Function(T? value) patchForValue;

  @override
  String get accordionKey => fieldName ?? id;

  @override
  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  ) {
    assert(
      contract?.enumValues == null || contractValue != null,
      'Schema-enumerated single-choice rows require contractValue.',
    );
    return CatchFormSingleChoiceRowEditor<P, T>(
      key: ValueKey('catch-form-single-choice-$id'),
      descriptor: this,
      scope: scope,
      errorText: errorText,
    );
  }
}

final class CatchFormMultiChoiceRow<P, T extends Labelled>
    extends CatchFormRowDescriptor<P> {
  const CatchFormMultiChoiceRow({
    required super.id,
    required super.icon,
    required super.label,
    required this.values,
    required this.selected,
    required this.patchForValues,
    this.fieldName,
    this.emptyValueText,
    this.helperText,
    this.itemAccent,
    this.contractValue,
    this.isAddAffordanceWhenEmpty = true,
    this.allowEmptySelection = true,
    this.showOptionalLabel = false,
    this.contract,
  });

  final List<T> values;
  final List<T> selected;
  final String? fieldName;
  final String? emptyValueText;
  final String? helperText;
  final Color? Function(T item)? itemAccent;
  final String Function(T value)? contractValue;
  final bool isAddAffordanceWhenEmpty;
  final bool allowEmptySelection;
  final bool showOptionalLabel;
  final CatchContractFieldConstraints? contract;
  final P Function(List<T> values) patchForValues;

  @override
  String get accordionKey => fieldName ?? id;

  @override
  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  ) {
    assert(
      contract?.itemEnumValues == null || contractValue != null,
      'Schema-enumerated multi-choice rows require contractValue.',
    );
    return CatchFormMultiChoiceRowEditor<P, T>(
      key: ValueKey('catch-form-multi-choice-$id'),
      descriptor: this,
      scope: scope,
      errorText: errorText,
    );
  }
}

final class CatchFormRangeRow<P> extends CatchFormRowDescriptor<P> {
  const CatchFormRangeRow({
    required super.id,
    required super.icon,
    required super.label,
    required this.value,
    required this.currentMin,
    required this.currentMax,
    required this.sliderMin,
    required this.sliderMax,
    required this.divisions,
    required this.labelText,
    required this.patchForRange,
    this.contract,
  });

  final String value;
  final int currentMin;
  final int currentMax;
  final double sliderMin;
  final double sliderMax;
  final int divisions;
  final String Function(double value) labelText;
  final CatchContractFieldConstraints? contract;
  final P Function(int min, int max) patchForRange;

  @override
  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  ) {
    assert(
      contract?.minimum == null || sliderMin >= contract!.minimum!,
      'The slider minimum cannot undercut the schema contract.',
    );
    assert(
      contract?.maximum == null || sliderMax <= contract!.maximum!,
      'The slider maximum cannot exceed the schema contract.',
    );
    return CatchFormRangeRowEditor<P>(
      key: ValueKey('catch-form-range-$id'),
      descriptor: this,
      scope: scope,
      errorText: errorText,
    );
  }
}

final class CatchFormCustomRow<P> extends CatchFormRowDescriptor<P> {
  const CatchFormCustomRow({
    required super.id,
    required super.icon,
    required super.label,
    required this.build,
    this.fieldName,
    this.contract,
  });

  final String? fieldName;
  final CatchContractFieldConstraints? contract;
  final Widget Function(BuildContext context, CatchFormRowScope<P> scope) build;

  @override
  String get accordionKey => fieldName ?? id;

  @override
  Widget buildRow(
    BuildContext context,
    CatchFormRowScope<P> scope,
    CatchFormErrorText errorText,
  ) {
    return build(context, scope);
  }
}

/// Field-local access to the list's shared accordion and save pipeline.
class CatchFormRowScope<P> {
  const CatchFormRowScope({
    required this.isExpanded,
    required this.toggle,
    required this.collapse,
    required this.save,
  });

  final bool isExpanded;
  final VoidCallback toggle;
  final VoidCallback collapse;
  final CatchFormSave<P> save;
}

/// Maps typed form descriptors to canonical CatchField rows inside one
/// CatchSection, with one accordion and one per-field patch save delegate.
class CatchFormRowList<P> extends StatefulWidget {
  const CatchFormRowList({
    super.key,
    required this.rows,
    required this.savePatch,
    required this.errorText,
    this.accordion,
    this.title,
    this.count,
    this.trailing,
    this.activityKind,
    this.lead = false,
    this.first = false,
    this.footer,
    this.dividerColor,
    this.dividerInset,
    this.dividerRole = CatchDividerRole.section,
    this.titleColor,
    this.bodyGap = CatchFieldTokens.sectionRuleGap,
    this.showInternalDividers = true,
  });

  final List<CatchFormRowDescriptor<P>> rows;
  final CatchFormSave<P> savePatch;
  final CatchFormErrorText errorText;
  final CatchFieldAccordion? accordion;
  final String? title;
  final Object? count;
  final Widget? trailing;
  final ActivityKind? activityKind;
  final bool lead;
  final bool first;
  final Widget? footer;
  final Color? dividerColor;
  final double? dividerInset;
  final CatchDividerRole dividerRole;
  final Color? titleColor;
  final double bodyGap;
  final bool showInternalDividers;

  @override
  State<CatchFormRowList<P>> createState() => _CatchFormRowListState<P>();
}

class _CatchFormRowListState<P> extends State<CatchFormRowList<P>> {
  CatchFieldAccordion? _ownedAccordion;

  CatchFieldAccordion get _accordion =>
      widget.accordion ?? (_ownedAccordion ??= CatchFieldAccordion());

  @override
  void initState() {
    super.initState();
    _accordion.addListener(_handleAccordionChanged);
  }

  @override
  void didUpdateWidget(CatchFormRowList<P> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.accordion == widget.accordion) return;
    (oldWidget.accordion ?? _ownedAccordion)?.removeListener(
      _handleAccordionChanged,
    );
    _ownedAccordion?.dispose();
    _ownedAccordion = null;
    _accordion.addListener(_handleAccordionChanged);
  }

  void _handleAccordionChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _accordion.removeListener(_handleAccordionChanged);
    _ownedAccordion?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CatchSection.fieldRows(
      title: widget.title,
      count: widget.count,
      trailing: widget.trailing,
      activityKind: widget.activityKind,
      lead: widget.lead,
      first: widget.first,
      footer: widget.footer,
      dividerColor: widget.dividerColor,
      dividerInset: widget.dividerInset,
      dividerRole: widget.dividerRole,
      titleColor: widget.titleColor,
      bodyGap: widget.bodyGap,
      showInternalDividers: widget.showInternalDividers,
      children: [
        for (final row in widget.rows)
          row.buildRow(context, _scopeFor(row), widget.errorText),
      ],
    );
  }

  CatchFormRowScope<P> _scopeFor(CatchFormRowDescriptor<P> row) {
    final key = row.accordionKey;
    return CatchFormRowScope<P>(
      isExpanded: _accordion.isExpanded(key),
      toggle: () => _accordion.toggle(key),
      collapse: _accordion.collapse,
      save: widget.savePatch,
    );
  }
}

class _CatchFormSaveState {
  Object? error;
  bool saving = false;
  CatchFieldStatus status = CatchFieldStatus.idle;
  Timer? savedTimer;

  void reset() {
    savedTimer?.cancel();
    error = null;
    status = CatchFieldStatus.idle;
  }

  void dispose() => savedTimer?.cancel();
}

class CatchFormTextRowEditor<P> extends StatefulWidget {
  const CatchFormTextRowEditor({
    super.key,
    required this.descriptor,
    required this.scope,
    required this.errorText,
  });

  final CatchFormTextRow<P> descriptor;
  final CatchFormRowScope<P> scope;
  final CatchFormErrorText errorText;

  @override
  State<CatchFormTextRowEditor<P>> createState() =>
      _CatchFormTextRowEditorState<P>();
}

class _CatchFormTextRowEditorState<P> extends State<CatchFormTextRowEditor<P>> {
  late final TextEditingController _controller;
  final _saveState = _CatchFormSaveState();
  Object? _lastCommittedValue;
  String? _validationError;
  bool _hasFocus = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.descriptor.currentValue)
      ..addListener(_clearErrors);
  }

  @override
  void didUpdateWidget(CatchFormTextRowEditor<P> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.descriptor;
    final current = widget.descriptor;
    if (old.currentFieldValue != current.currentFieldValue) {
      _lastCommittedValue = null;
    }
    if (!_hasFocus &&
        (old.id != current.id || old.currentValue != current.currentValue) &&
        _controller.text != current.currentValue) {
      _controller.text = current.currentValue;
    }
  }

  @override
  void dispose() {
    _saveState.dispose();
    _controller
      ..removeListener(_clearErrors)
      ..dispose();
    super.dispose();
  }

  void _clearErrors() {
    if (_validationError == null &&
        _saveState.error == null &&
        _saveState.status == CatchFieldStatus.idle) {
      return;
    }
    setState(() {
      _validationError = null;
      _saveState.reset();
    });
  }

  Future<void> _submit() async {
    if (_saveState.saving) return;
    final descriptor = widget.descriptor;
    final normalized =
        descriptor.normalizeInput?.call(_controller.text) ??
        _controller.text.trim();
    if (normalized != _controller.text) {
      _controller.value = TextEditingValue(
        text: normalized,
        selection: TextSelection.collapsed(offset: normalized.length),
      );
    }
    final validationError = descriptor.validate(context, normalized);
    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }
    final Object? value = descriptor.toFieldValue != null
        ? descriptor.toFieldValue!(normalized)
        : normalized;
    final comparable =
        _lastCommittedValue ??
        descriptor.currentFieldValue ??
        descriptor.currentValue;
    if (value == comparable ||
        (value == null && descriptor.currentValue.trim().isEmpty) ||
        (value == '' && descriptor.currentFieldValue == null)) {
      if (descriptor.explicitSave) widget.scope.collapse();
      return;
    }
    setState(() {
      _saveState
        ..saving = true
        ..error = null
        ..status = CatchFieldStatus.saving;
    });
    try {
      final saved = await widget.scope.save(descriptor.patchForValue(value));
      if (!mounted) return;
      if (!saved) {
        setState(() {
          _saveState
            ..saving = false
            ..status = CatchFieldStatus.idle;
        });
        return;
      }
      _lastCommittedValue = value;
      setState(() {
        _saveState
          ..saving = false
          ..status = CatchFieldStatus.saved;
      });
      _saveState.savedTimer = Timer(CatchFieldTokens.savedStatusHold, () {
        if (mounted) {
          setState(() => _saveState.status = CatchFieldStatus.idle);
        }
      });
      if (descriptor.explicitSave) widget.scope.collapse();
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
    final saveError = _saveState.error;
    final error =
        _validationError ??
        (saveError == null ? null : widget.errorText(context, saveError));
    if (descriptor.explicitSave) {
      return CatchField.inputActions(
        icon: descriptor.icon,
        title: descriptor.label,
        placeholder: descriptor.placeholder,
        emptyValueText: descriptor.emptyValueText,
        inputHint: descriptor.inputHint,
        controller: _controller,
        open: widget.scope.isExpanded,
        onOpenChanged: (_) => widget.scope.toggle(),
        onCancel: () {
          _controller.text = descriptor.currentValue;
          _validationError = null;
          _saveState.reset();
          widget.scope.collapse();
        },
        onSubmit: _submit,
        isLoading: _saveState.saving,
        status: _saveState.status,
        keyboardType: descriptor.keyboardType,
        textInputAction: descriptor.maxLines == 1
            ? TextInputAction.done
            : TextInputAction.newline,
        textCapitalization: descriptor.textCapitalization,
        inputFormatters: descriptor.effectiveInputFormatters,
        autofillHints: descriptor.autofillHints,
        maxLines: descriptor.maxLines,
        minLines: descriptor.minLines,
        maxLength: descriptor.effectiveMaxLength,
        enabled: !_saveState.saving,
        error: error,
        onSubmitted: descriptor.maxLines == 1 ? (_) => _submit() : null,
      );
    }
    return CatchField.input(
      icon: descriptor.icon,
      title: descriptor.label,
      placeholder: descriptor.placeholder,
      emptyValueText: descriptor.emptyValueText,
      inputHint: descriptor.inputHint,
      leadingUnit: descriptor.leadingUnit,
      showClearButton: descriptor.showClearButton,
      controller: _controller,
      keyboardType: descriptor.keyboardType,
      textInputAction: TextInputAction.done,
      textCapitalization: descriptor.textCapitalization,
      autofillHints: descriptor.autofillHints,
      inputFormatters: descriptor.effectiveInputFormatters,
      maxLines: descriptor.maxLines,
      minLines: descriptor.minLines,
      maxLength: descriptor.effectiveMaxLength,
      readOnly: _saveState.saving,
      status: _saveState.status,
      error: error,
      onFocusChanged: (focused) {
        _hasFocus = focused;
        if (!focused) unawaited(_submit());
      },
      onSubmitted: (_) => _submit(),
    );
  }
}

class CatchFormSingleChoiceRowEditor<P, T extends Labelled>
    extends StatefulWidget {
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

class _CatchFormSingleChoiceRowEditorState<P, T extends Labelled>
    extends State<CatchFormSingleChoiceRowEditor<P, T>> {
  late T? _selected = widget.descriptor.value;
  final _saveState = _CatchFormSaveState();

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
      itemLabel: (value) => value.label,
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

class CatchFormMultiChoiceRowEditor<P, T extends Labelled>
    extends StatefulWidget {
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

class _CatchFormMultiChoiceRowEditorState<P, T extends Labelled>
    extends State<CatchFormMultiChoiceRowEditor<P, T>> {
  late Set<T> _selected = widget.descriptor.selected.toSet();
  final _saveState = _CatchFormSaveState();

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
    return CatchField.choices<T>(
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
      itemLabel: (value) => value.label,
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
  final _saveState = _CatchFormSaveState();

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
