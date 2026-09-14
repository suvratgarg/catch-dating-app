import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Native editing and focus ownership for a text control.
enum CatchTextInputMode {
  editable,
  readOnly,
  inactive,
  editableWithoutSelection,
  readOnlyWithoutSelection,
  inactiveWithoutSelection;

  bool get readOnlyText => switch (this) {
    editable || editableWithoutSelection => false,
    _ => true,
  };

  bool get canRequestFocus => switch (this) {
    inactive || inactiveWithoutSelection => false,
    _ => true,
  };

  bool get allowsSelection => switch (this) {
    editableWithoutSelection ||
    readOnlyWithoutSelection ||
    inactiveWithoutSelection => false,
    _ => true,
  };
}

/// Whether the native field inherits its decoration's enabled state or overrides it.
enum CatchTextInputStatus { inherited, enabled, disabled }

/// Whether the platform text control conceals entered characters.
enum CatchTextInputVariant { plain, obscured }

/// Canonical low-level text-entry primitive.
///
/// Feature-facing fields should use `CatchField`. Specialized composites such
/// as search and OTP use this primitive so raw platform text controls remain
/// centralized in this shared primitive.
class CatchTextInput extends StatelessWidget {
  const CatchTextInput({
    super.key,
    required this.controller,
    this.inputKey,
    this.groupId = EditableText,
    this.mode = CatchTextInputMode.editable,
    this.variant = CatchTextInputVariant.plain,
    this.focusNode,
    this.autofocus = false,
    this.status = CatchTextInputStatus.inherited,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.textAlign = TextAlign.start,
    this.textAlignVertical,
    this.autofillHints,
    this.inputFormatters,
    this.decoration = const InputDecoration(),
    this.style,
    this.cursorColor,
    this.showCursor,
    this.onSubmitted,
    this.onChanged,
    this.onTapOutside,
    this.onTap,
    this.onEditingComplete,
  });

  final TextEditingController controller;
  final Key? inputKey;
  final Object groupId;
  final CatchTextInputMode mode;
  final CatchTextInputVariant variant;
  final FocusNode? focusNode;
  final bool autofocus;
  final CatchTextInputStatus status;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final TextAlign textAlign;
  final TextAlignVertical? textAlignVertical;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration decoration;
  final TextStyle? style;
  final Color? cursorColor;
  final bool? showCursor;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final void Function(PointerDownEvent)? onTapOutside;
  final VoidCallback? onTap;
  final VoidCallback? onEditingComplete;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: inputKey,
      groupId: groupId,
      readOnly: mode.readOnlyText,
      canRequestFocus: mode.canRequestFocus,
      obscureText: variant == CatchTextInputVariant.obscured,
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      enabled: switch (status) {
        CatchTextInputStatus.inherited => null,
        CatchTextInputStatus.enabled => true,
        CatchTextInputStatus.disabled => false,
      },
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      textCapitalization: textCapitalization,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      textAlign: textAlign,
      textAlignVertical: textAlignVertical,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      decoration: decoration,
      style: style,
      cursorColor: cursorColor,
      enableInteractiveSelection: mode.allowsSelection,
      showCursor: showCursor,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      onTapOutside: onTapOutside,
      onTap: onTap,
      onEditingComplete: onEditingComplete,
    );
  }
}
