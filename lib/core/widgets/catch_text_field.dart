import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
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
    this.onFocusChanged,
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
    this.showClearButton = false,
  });

  static const double compactControlHeight =
      CatchControlMetrics.compactMinHeight;
  static const double mdControlHeight = CatchControlMetrics.mdMinHeight;

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
  final ValueChanged<bool>? onFocusChanged;
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

  /// When true, replaces [suffixIcon] with a clear (X) button when the field
  /// has non-empty text. Pressing it clears the controller and calls
  /// [onChanged] with an empty string.
  final bool showClearButton;

  @override
  State<CatchTextField> createState() => _CatchTextFieldState();
}

enum CatchTextFieldSize { floating, compact, md }

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
    if (widget.controller == null &&
        oldWidget.controller == null &&
        widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _internalController.text) {
      _internalController.value = TextEditingValue(
        text: widget.initialValue ?? '',
      );
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

  void _handleFocusChanged() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
    setState(() {});
  }

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
        final canInteract = !widget.readOnly || widget.onTap != null;
        final t = CatchTokens.of(context);
        final inputShell = CatchControlShell(
          size: _controlSize,
          shape: _controlShape,
          tone: _controlTone,
          enabled: widget.enabled,
          hasError: hasError,
          focused: _focusNode.hasFocus,
          padding: EdgeInsets.zero,
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            readOnly: widget.readOnly,
            canRequestFocus: canInteract,
            enableInteractiveSelection: canInteract,
            autofocus: widget.autofocus,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction ?? TextInputAction.done,
            textCapitalization: widget.textCapitalization,
            inputFormatters: widget.inputFormatters,
            autofillHints: widget.autofillHints,
            obscureText: widget.obscureText,
            maxLines: widget.obscureText ? 1 : widget.maxLines,
            minLines: widget.minLines,
            textAlignVertical: _textAlignVertical,
            onTap: widget.onTap,
            onTapOutside: (_) => _focusNode.unfocus(),
            onChanged: (value) {
              state.didChange(value);
              widget.onChanged?.call(value);
            },
            onSubmitted: _handleSubmitted,
            style: _textStyle(context, color: widget.enabled ? t.ink : t.ink3),
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
              hintStyle: _textStyle(context, color: t.ink3),
              prefixText: widget.prefixText,
              prefixStyle: _textStyle(context, color: t.ink2),
              suffixText: widget.suffixText,
              suffixStyle: CatchTextStyles.bodyLead(context, color: t.ink2),
              prefixIconConstraints: _iconConstraints,
              prefixIcon: widget.prefixIcon == null
                  ? null
                  : IconTheme(
                      data: IconThemeData(color: t.ink3, size: CatchIcon.md),
                      child: widget.prefixIcon!,
                    ),
              suffixIconConstraints: _iconConstraints,
              suffixIcon: _buildSuffixIcon(t),
            ),
          ),
        );
        final sizedInputShell = _singleLineControlHeight == null
            ? inputShell
            : SizedBox(height: _singleLineControlHeight, child: inputShell);

        final field = widget.showLabel
            ? sizedInputShell
            : Semantics(
                label: widget.label,
                textField: true,
                child: sizedInputShell,
              );

        if (!widget.showLabel && supportText == null) {
          return field;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showLabel) ...[
              CatchFormFieldLabel(
                label: widget.label,
                isOptional: widget.isOptional,
                hasError: hasError,
              ),
              const SizedBox(height: CatchSpacing.s2),
            ],
            field,
            if (supportText != null) ...[
              const SizedBox(height: CatchSpacing.s1),
              Text(
                supportText,
                style: CatchTextStyles.supporting(
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

  Color _supportColor(CatchTokens t) {
    return switch (widget.helperTone) {
      CatchTextFieldSupportTone.neutral => t.ink3,
      CatchTextFieldSupportTone.brand => t.primary,
      CatchTextFieldSupportTone.success => t.success,
    };
  }

  void _handleSubmitted(String value) {
    widget.onSubmitted?.call(value);
    _focusNode.unfocus();
  }

  Widget? _buildSuffixIcon(CatchTokens t) {
    if (widget.showClearButton) {
      return ValueListenableBuilder(
        valueListenable: _controller,
        builder: (_, TextEditingValue value, _) {
          if (value.text.isEmpty) {
            if (widget.suffixIcon == null) return const SizedBox.shrink();
            return IconTheme(
              data: IconThemeData(color: t.ink3, size: CatchIcon.md),
              child: widget.suffixIcon!,
            );
          }
          return IconButton(
            tooltip: 'Clear ${widget.label}',
            icon: Icon(CatchIcons.closeRounded, size: 16),
            onPressed: () {
              _controller.clear();
              widget.onChanged?.call('');
            },
          );
        },
      );
    }

    if (widget.suffixIcon == null) return null;
    return IconTheme(
      data: IconThemeData(color: t.ink3, size: CatchIcon.md),
      child: widget.suffixIcon!,
    );
  }

  EdgeInsets get _contentPadding {
    return CatchControlMetrics.textFieldContentPadding(_controlSize);
  }

  TextStyle _textStyle(BuildContext context, {required Color color}) {
    return widget.size == CatchTextFieldSize.floating
        ? CatchTextStyles.bodyLead(context, color: color)
        : CatchTextStyles.bodyL(context, color: color);
  }

  BoxConstraints? get _iconConstraints {
    if (widget.maxLines != 1 || widget.minLines != null) return null;

    final extent = CatchControlMetrics.iconExtent(_controlSize);
    return BoxConstraints.tightFor(width: extent, height: extent);
  }

  CatchControlSize get _controlSize {
    return switch (widget.size) {
      CatchTextFieldSize.floating => CatchControlSize.floating,
      CatchTextFieldSize.compact => CatchControlSize.compact,
      CatchTextFieldSize.md => CatchControlSize.md,
    };
  }

  CatchControlShape get _controlShape {
    return switch (widget.shape) {
      CatchTextFieldShape.rounded => CatchControlShape.rounded,
      CatchTextFieldShape.pill => CatchControlShape.pill,
    };
  }

  CatchControlTone get _controlTone {
    return switch (widget.tone) {
      CatchTextFieldTone.surface => CatchControlTone.surface,
      CatchTextFieldTone.raised => CatchControlTone.raised,
    };
  }

  TextAlignVertical? get _textAlignVertical {
    if (widget.maxLines != 1 || widget.minLines != null) return null;
    return TextAlignVertical.center;
  }

  double? get _singleLineControlHeight {
    if (widget.maxLines != 1 || widget.minLines != null) return null;
    return CatchControlMetrics.minHeight(_controlSize);
  }
}
