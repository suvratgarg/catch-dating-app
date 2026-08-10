import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Canonical low-level text-entry primitive.
///
/// Feature-facing fields should use `CatchField`. Specialized composites such
/// as search and OTP use this primitive so raw platform text controls remain
/// owned by one design-system implementation seam.
class CatchTextInput extends StatelessWidget {
  const CatchTextInput({
    super.key,
    required this.controller,
    this.focusNode,
    this.autofocus = false,
    this.enabled,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.inputFormatters,
    this.decoration = const InputDecoration(),
    this.style,
    this.cursorColor,
    this.enableInteractiveSelection = true,
    this.showCursor,
    this.onSubmitted,
    this.onChanged,
    this.onTapOutside,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final bool autofocus;
  final bool? enabled;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final List<TextInputFormatter>? inputFormatters;
  final InputDecoration decoration;
  final TextStyle? style;
  final Color? cursorColor;
  final bool enableInteractiveSelection;
  final bool? showCursor;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final void Function(PointerDownEvent)? onTapOutside;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      focusNode: focusNode,
      autofocus: autofocus,
      enabled: enabled,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      inputFormatters: inputFormatters,
      decoration: decoration,
      style: style,
      cursorColor: cursorColor,
      enableInteractiveSelection: enableInteractiveSelection,
      showCursor: showCursor,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      onTapOutside: onTapOutside,
    );
  }
}
