import 'dart:async';

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:catch_ui/src/patterns/catch_form_row_list.dart';
import 'package:flutter/material.dart';

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
  final _saveState = CatchFormSaveState();
  Object? _lastCommittedValue;
  String? _validationError;
  bool _hasFocus = false;

  bool get _usesExplicitCommit =>
      widget.scope.textCommitMode == CatchFormTextCommitMode.explicit;

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
    final validationError = descriptor.validate(normalized);
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
        (saveError == null ? null : widget.errorText(context, saveError));
    if (_usesExplicitCommit) {
      return CatchField.inputActions(
        copy: widget.scope.fieldCopy,
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
      copy: widget.scope.fieldCopy,
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
