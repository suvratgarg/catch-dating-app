import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchFieldTokens, CatchTokens;
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/inline_editor_save.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfileDirectTextEntryField extends ConsumerStatefulWidget {
  const ProfileDirectTextEntryField({
    super.key,
    required this.icon,
    required this.label,
    required this.currentValue,
    required this.currentFieldValue,
    required this.fieldName,
    required this.patchForValue,
    this.emptyValueText,
    this.inputHint,
    this.leadingUnit,
    this.showClearButton = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
    this.validator,
    this.toFieldValue,
  });

  final IconData icon;
  final String label;

  final String? emptyValueText;
  final String? inputHint;
  final String? leadingUnit;
  final bool showClearButton;
  final String currentValue;
  final Object? currentFieldValue;
  final String fieldName;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;
  final UpdateUserProfilePatch Function(Object? value) patchForValue;

  @override
  ConsumerState<ProfileDirectTextEntryField> createState() =>
      _ProfileDirectTextEntryFieldState();
}

class _ProfileDirectTextEntryFieldState
    extends ConsumerState<ProfileDirectTextEntryField>
    with InlineSaveState<ProfileDirectTextEntryField> {
  late final TextEditingController _controller;
  String? _validationError;
  Object? _lastCommittedFieldValue;
  bool _hasFocus = false;
  CatchFieldStatus _status = CatchFieldStatus.idle;
  Timer? _savedStatusTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
    _controller.addListener(_clearInlineErrors);
  }

  @override
  void didUpdateWidget(covariant ProfileDirectTextEntryField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentFieldValue != widget.currentFieldValue) {
      _lastCommittedFieldValue = null;
    }
    if (!_hasFocus &&
        (oldWidget.fieldName != widget.fieldName ||
            oldWidget.currentValue != widget.currentValue) &&
        _controller.text != widget.currentValue) {
      _controller.text = widget.currentValue;
    }
  }

  @override
  void dispose() {
    _savedStatusTimer?.cancel();
    _controller.removeListener(_clearInlineErrors);
    _controller.dispose();
    super.dispose();
  }

  void _clearInlineErrors() {
    if (_validationError == null &&
        saveError == null &&
        _status == CatchFieldStatus.idle) {
      return;
    }
    _savedStatusTimer?.cancel();
    setState(() {
      _validationError = null;
      _status = CatchFieldStatus.idle;
      clearSaveError();
    });
  }

  void _handleFocusChanged(bool focused) {
    _hasFocus = focused;
    if (!focused) {
      unawaited(_submit());
    }
  }

  Future<void> _submit() async {
    if (isSaving) return;
    final normalizedText = _controller.text.trim();
    if (normalizedText != _controller.text) {
      _controller.value = TextEditingValue(
        text: normalizedText,
        selection: TextSelection.collapsed(offset: normalizedText.length),
      );
    }

    final validationError = widget.validator?.call(normalizedText);
    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }

    final Object? fieldValue = widget.toFieldValue != null
        ? widget.toFieldValue!(normalizedText)
        : normalizedText;
    final currentFieldValue = widget.currentFieldValue;
    final comparableCurrentValue =
        _lastCommittedFieldValue ?? currentFieldValue ?? widget.currentValue;
    final isUnchanged =
        fieldValue == comparableCurrentValue ||
        (fieldValue == null && widget.currentValue.trim().isEmpty) ||
        (fieldValue == '' && currentFieldValue == null);
    if (isUnchanged) return;

    setState(() => _status = CatchFieldStatus.saving);
    final saved = await saveFields(widget.patchForValue(fieldValue));
    if (!mounted) return;
    if (!saved) {
      setState(() => _status = CatchFieldStatus.idle);
      return;
    }
    _lastCommittedFieldValue = fieldValue;
    setState(() => _status = CatchFieldStatus.saved);
    _savedStatusTimer?.cancel();
    _savedStatusTimer = Timer(CatchFieldTokens.savedStatusHold, () {
      if (mounted) setState(() => _status = CatchFieldStatus.idle);
    });
  }

  @override
  Widget build(BuildContext context) {
    final error = saveError;
    final errorText =
        _validationError ??
        (error == null
            ? null
            : appErrorMessage(
                error,
                l10n: context.l10n,
                context: AppErrorContext.profile,
              ));
    return CatchField.input(
      icon: widget.icon,
      title: widget.label,
      emptyValueText: widget.emptyValueText,
      inputHint: widget.inputHint,
      leadingUnit: widget.leadingUnit,
      showClearButton: widget.showClearButton,
      controller: _controller,
      keyboardType: widget.keyboardType,
      textInputAction: TextInputAction.done,
      textCapitalization: widget.textCapitalization,
      autofillHints: widget.autofillHints,
      readOnly: isSaving,
      status: isSaving ? CatchFieldStatus.saving : _status,
      error: errorText,
      onFocusChanged: _handleFocusChanged,
      onSubmitted: (_) => _submit(),
    );
  }
}

/// Shared legacy inline-value adapter retained for host editor compatibility.
///
/// New profile text rows use [ProfileDirectTextEntryField], while existing
/// explicit-save host flows continue to render their editor through the
/// canonical [CatchField.input] primitive.
class ProfileInlineTextValue extends StatelessWidget {
  const ProfileInlineTextValue({
    super.key,
    required this.label,
    required this.displayValue,
    required this.controller,
    required this.isEditing,
    required this.enabled,
    this.placeholder,
    this.isAddAffordance = false,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.collapseStackedBlankLines = false,
    this.autofillHints,
    this.onSubmitted,
  });

  final String label;
  final String displayValue;
  final String? placeholder;
  final TextEditingController controller;
  final bool isEditing;
  final bool enabled;
  final bool isAddAffordance;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool collapseStackedBlankLines;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final valueStyle = CatchTextStyles.profileAnswer(
      context,
      color: isAddAffordance && !isEditing ? t.ink3 : t.ink,
    );

    if (!isEditing) {
      return Text(
        isAddAffordance
            ? context.l10n.userProfileInlineEditorTextTextDisplayvalue(
                displayValue: displayValue,
              )
            : displayValue,
        key: ValueKey(
          context.l10n.userProfileInlineEditorTextTextProfileInlineDisplayLabel(
            label: label,
            displayValue: displayValue,
            isAddAffordance: isAddAffordance,
          ),
        ),
        style: valueStyle,
      );
    }

    final inputFormatters = <TextInputFormatter>[
      if (collapseStackedBlankLines) const _StackedBlankLinesFormatter(),
      if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
    ];

    return CatchField.input(
      title: label,
      placeholder: placeholder ?? displayValue,
      controller: controller,
      keyboardType: keyboardType,
      textInputAction:
          textInputAction ??
          (maxLines == 1 ? TextInputAction.done : TextInputAction.newline),
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters.isEmpty ? null : inputFormatters,
      autofillHints: autofillHints,
      maxLines: maxLines,
      minLines: minLines,
      enabled: enabled,
      autofocus: true,
      showLabel: false,
      size: CatchFieldSize.floating,
      variant: CatchFieldVariant.underline,
      onSubmitted: onSubmitted,
    );
  }
}

class _StackedBlankLinesFormatter extends TextInputFormatter {
  const _StackedBlankLinesFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final collapsed = collapseStackedPromptBlankLines(newValue.text);
    if (collapsed == newValue.text) return newValue;

    final selectionEnd = newValue.selection.end;
    final normalizedOffset = selectionEnd < 0
        ? collapsed.length
        : collapseStackedPromptBlankLines(
            newValue.text.substring(0, selectionEnd),
          ).length;
    final offset = normalizedOffset.clamp(0, collapsed.length);
    return TextEditingValue(
      text: collapsed,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}
