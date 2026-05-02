import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Canonical Catch input primitive.
///
/// This wraps text input in a token-driven shell so screens can configure
/// labels, helper/error copy, multiline behavior, and icons without restyling
/// individual [TextFormField] instances.
class CatchTextField extends StatefulWidget {
  const CatchTextField({
    super.key,
    required this.label,
    this.isOptional = false,
    this.showLabel = true,
    this.controller,
    this.initialValue,
    this.hintText,
    this.helperText,
    this.helperTone = CatchTextFieldSupportTone.neutral,
    this.errorText,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.onTap,
    this.enabled = true,
    this.readOnly = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.size = CatchTextFieldSize.md,
    this.shape = CatchTextFieldShape.rounded,
    this.tone = CatchTextFieldTone.surface,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.suffixText,
  });

  final String label;
  final bool isOptional;
  final bool showLabel;
  final TextEditingController? controller;
  final String? initialValue;
  final String? hintText;
  final String? helperText;
  final CatchTextFieldSupportTone helperTone;
  final String? errorText;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final bool enabled;
  final bool readOnly;
  final bool autofocus;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final CatchTextFieldSize size;
  final CatchTextFieldShape shape;
  final CatchTextFieldTone tone;
  final Widget? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final String? suffixText;

  @override
  State<CatchTextField> createState() => _CatchTextFieldState();
}

enum CatchTextFieldSize { compact, md }

enum CatchTextFieldShape { rounded, pill }

enum CatchTextFieldTone { surface, raised }

enum CatchTextFieldSupportTone { neutral, brand, success }

class _CatchTextFieldState extends State<CatchTextField> {
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  late final FocusNode _focusNode;
  late final TextEditingController _internalController;
  TextEditingController? _listenedController;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
    _internalController = TextEditingController(
      text: widget.controller == null ? widget.initialValue : null,
    );
    _attachControllerListener(_controller);
  }

  @override
  void didUpdateWidget(covariant CatchTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldController = oldWidget.controller ?? _internalController;
    if (oldController != _controller) {
      _attachControllerListener(_controller);
      _syncFieldValue();
    }
  }

  @override
  void dispose() {
    _listenedController?.removeListener(_syncFieldValue);
    _focusNode
      ..removeListener(_handleFocusChanged)
      ..dispose();
    _internalController.dispose();
    super.dispose();
  }

  void _handleFocusChanged() => setState(() {});

  void _attachControllerListener(TextEditingController controller) {
    _listenedController?.removeListener(_syncFieldValue);
    _listenedController = controller..addListener(_syncFieldValue);
  }

  void _syncFieldValue() {
    final field = _fieldKey.currentState;
    if (field != null && field.value != _controller.text) {
      field.didChange(_controller.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      key: _fieldKey,
      initialValue: _controller.text,
      validator: widget.validator,
      enabled: widget.enabled,
      builder: (state) {
        final error = widget.errorText ?? state.errorText;
        final hasError = error != null;
        final supportText = error ?? widget.helperText;
        final t = CatchTokens.of(context);
        final borderColor = _borderColor(t, hasError);
        final inputShell = AnimatedContainer(
          duration: CatchMotion.fast,
          curve: CatchMotion.standardCurve,
          decoration: BoxDecoration(
            color: _fillColor(t),
            borderRadius: BorderRadius.circular(_radius),
            border: Border.all(color: borderColor, width: 1.5),
            boxShadow: _focusNode.hasFocus && !hasError
                ? [
                    BoxShadow(
                      color: t.primarySoft,
                      blurRadius: 0,
                      spreadRadius: 3,
                    ),
                  ]
                : CatchElevation.none,
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            autofillHints: widget.autofillHints,
            obscureText: widget.obscureText,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            onTap: widget.onTap,
            onChanged: (value) {
              state.didChange(value);
              widget.onChanged?.call(value);
            },
            onSubmitted: widget.onSubmitted,
            style: CatchTextStyles.bodyL(
              context,
              color: widget.enabled ? t.ink : t.ink3,
            ),
            cursorColor: t.primary,
            decoration: InputDecoration(
              isDense: true,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              focusedErrorBorder: InputBorder.none,
              contentPadding: _contentPadding,
              hintText: widget.hintText,
              hintStyle: CatchTextStyles.bodyL(context, color: t.ink3),
              prefixText: widget.prefixText,
              prefixStyle: CatchTextStyles.bodyL(context, color: t.ink2),
              suffixText: widget.suffixText,
              suffixStyle: CatchTextStyles.bodyM(context, color: t.ink2),
              prefixIcon: widget.prefixIcon == null
                  ? null
                  : IconTheme(
                      data: IconThemeData(color: t.ink3, size: CatchIcon.md),
                      child: widget.prefixIcon!,
                    ),
              suffixIcon: widget.suffixIcon == null
                  ? null
                  : IconTheme(
                      data: IconThemeData(color: t.ink3, size: CatchIcon.md),
                      child: widget.suffixIcon!,
                    ),
            ),
          ),
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.showLabel) ...[
              CatchFormFieldLabel(
                label: widget.label,
                isOptional: widget.isOptional,
                hasError: hasError,
              ),
              const SizedBox(height: CatchSpacing.s2),
            ],
            if (widget.showLabel)
              inputShell
            else
              Semantics(
                label: widget.label,
                textField: true,
                child: inputShell,
              ),
            if (supportText != null) ...[
              const SizedBox(height: CatchSpacing.s1),
              Text(
                supportText,
                style: CatchTextStyles.bodyS(
                  context,
                  color: hasError ? t.danger : _supportColor(t),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  Color _borderColor(CatchTokens t, bool hasError) {
    if (hasError) return t.danger;
    if (!widget.enabled) return t.line;
    if (_focusNode.hasFocus) return t.primary;
    return t.line2;
  }

  Color _fillColor(CatchTokens t) {
    if (!widget.enabled) return t.raised;
    return switch (widget.tone) {
      CatchTextFieldTone.surface => t.surface,
      CatchTextFieldTone.raised => t.raised,
    };
  }

  Color _supportColor(CatchTokens t) {
    return switch (widget.helperTone) {
      CatchTextFieldSupportTone.neutral => t.ink3,
      CatchTextFieldSupportTone.brand => t.primary,
      CatchTextFieldSupportTone.success => t.success,
    };
  }

  double get _radius {
    return switch (widget.shape) {
      CatchTextFieldShape.rounded => CatchRadius.sm,
      CatchTextFieldShape.pill => CatchRadius.pill,
    };
  }

  EdgeInsets get _contentPadding {
    return switch (widget.size) {
      CatchTextFieldSize.compact => const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 10,
      ),
      CatchTextFieldSize.md => const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
    };
  }
}
