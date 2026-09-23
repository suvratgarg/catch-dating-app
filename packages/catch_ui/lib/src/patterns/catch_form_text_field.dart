import 'dart:async';

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:catch_ui/src/patterns/catch_form_row_list.dart';
import 'package:flutter/material.dart';

/// Form-owned text draft, normalization and validation with list-owned commit policy.
class CatchFormTextField<P> extends StatefulWidget {
  const CatchFormTextField({
    super.key,
    required this.descriptor,
    required this.scope,
    required this.errorTextBuilder,
  });

  final CatchFormTextRow<P> descriptor;
  final CatchFormRowScope<P> scope;
  final CatchFormErrorText errorTextBuilder;

  @override
  State<CatchFormTextField<P>> createState() => _CatchFormTextFieldState<P>();
}

class _CatchFormTextFieldState<P> extends State<CatchFormTextField<P>> {
  late final TextEditingController _controller;
  final _saveState = CatchFormSaveState();
  Object? _lastCommittedValue;
  bool _hasCommittedValue = false;
  String? _lastCommittedText;
  String? _validationError;
  bool _hasFocus = false;
  bool _lastClearIntent = false;

  bool get _isClearDraft {
    final descriptor = widget.descriptor;
    if (widget.scope.fieldCopy.clearLabel == null ||
        descriptor.contract?.required != false ||
        _savedText.trim().isEmpty) {
      return false;
    }
    final draft =
        descriptor.normalizeInput?.call(_controller.text) ??
        _controller.text.trim();
    return draft.isEmpty;
  }

  String get _savedText =>
      _hasCommittedValue ? _lastCommittedText! : widget.descriptor.currentValue;

  bool get _usesExplicitCommit =>
      widget.scope.textCommitMode == CatchFormRowListMode.explicit;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.descriptor.currentValue)
      ..addListener(_clearErrors);
  }

  @override
  void didUpdateWidget(CatchFormTextField<P> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget.descriptor;
    final current = widget.descriptor;
    if (old.id != current.id ||
        old.currentValue != current.currentValue ||
        old.currentFieldValue != current.currentFieldValue) {
      _lastCommittedValue = null;
      _hasCommittedValue = false;
    }
    if (_usesExplicitCommit &&
        oldWidget.scope.isExpanded &&
        !widget.scope.isExpanded &&
        !_saveState.saving &&
        _saveState.status != CatchFieldStatus.saved) {
      _controller.text = _savedText;
      _validationError = null;
      _saveState.reset();
    }
    if (!_hasFocus &&
        !widget.scope.isExpanded &&
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
    final clearIntent = _isClearDraft;
    if (clearIntent == _lastClearIntent &&
        _validationError == null &&
        _saveState.error == null &&
        _saveState.status == CatchFieldStatus.idle) {
      return;
    }
    setState(() {
      _lastClearIntent = clearIntent;
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
    final validationError = descriptor.validate(normalized);
    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }
    final Object? value = descriptor.toFieldValue != null
        ? descriptor.toFieldValue!(normalized)
        : normalized;
    final comparable = _hasCommittedValue
        ? _lastCommittedValue
        : descriptor.currentFieldValue ?? descriptor.currentValue;
    if (value == comparable ||
        ((value == null || value == '') &&
            (comparable == null || comparable == ''))) {
      if (_usesExplicitCommit) widget.scope.collapse();
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
      _hasCommittedValue = true;
      _lastCommittedText = normalized;
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
      if (_usesExplicitCommit) widget.scope.collapse();
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
        (saveError == null
            ? null
            : widget.errorTextBuilder(context, saveError));
    if (_usesExplicitCommit) {
      return CatchField.inputActions(
        copy: _isClearDraft
            ? widget.scope.fieldCopy.copyWith(
                doneLabel: widget.scope.fieldCopy.clearLabel,
              )
            : widget.scope.fieldCopy,
        icon: descriptor.icon,
        title: descriptor.label,
        contract: descriptor.contract,
        placeholder: descriptor.placeholder,
        emptyValueText: descriptor.emptyValueText,
        inputHint: descriptor.inputHint,
        controller: _controller,
        showClearButton: descriptor.showClearButton,
        onFocusChanged: (focused) => _hasFocus = focused,
        open: widget.scope.isExpanded,
        onOpenChanged: (_) => widget.scope.toggle(),
        onCancel: () {
          _controller.text = _savedText;
          _validationError = null;
          _saveState.reset();
          widget.scope.collapse();
        },
        onSubmit: _submit,

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
        states: <WidgetState>{if (_saveState.saving) WidgetState.disabled},
        error: error,
        onSubmitted: descriptor.maxLines == 1 ? (_) => _submit() : null,
      );
    }
    return CatchField.input(
      copy: widget.scope.fieldCopy,
      icon: descriptor.icon,
      title: descriptor.label,
      contract: descriptor.contract,
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
      inputMode: _saveState.saving
          ? CatchTextInputMode.inactiveWithoutSelection
          : CatchTextInputMode.editable,
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
