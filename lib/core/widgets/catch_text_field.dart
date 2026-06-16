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
    this.variant = CatchTextFieldVariant.box,
    this.textAlign = TextAlign.start,
    this.focused = false,
    this.mono = false,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.suffixText,
    this.trailing,
    this.showClearButton = false,
    this.floatingLabel = true,
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
  final CatchTextFieldVariant variant;
  final TextAlign textAlign;
  final bool focused;
  final bool mono;
  final Widget? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final String? suffixText;
  final Widget? trailing;

  /// When true, replaces [suffixIcon] with a clear (X) button when the field
  /// has non-empty text. Pressing it clears the controller and calls
  /// [onChanged] with an empty string.
  final bool showClearButton;

  /// Render [label] as a Material-style floating caption inside the field
  /// (design-system Field) instead of a static label above it. Gated by
  /// [showLabel]; on by default so forms adopt the DS treatment with no churn.
  final bool floatingLabel;

  @override
  State<CatchTextField> createState() => _CatchTextFieldState();
}

enum CatchTextFieldSize { floating, compact, md }

enum CatchTextFieldShape { rounded, pill }

enum CatchTextFieldTone { surface, raised }

enum CatchTextFieldVariant { box, underline, bare }

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
        final effectiveFocused = _focusNode.hasFocus || widget.focused;
        final textField = TextField(
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
          textAlign: widget.textAlign,
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
            labelText: _useFloatingLabel ? widget.label : null,
            labelStyle: _useFloatingLabel
                ? CatchTextStyles.bodyL(context, color: t.ink3)
                : null,
            floatingLabelStyle: _useFloatingLabel
                ? CatchTextStyles.fieldLabel(
                    context,
                    color: hasError
                        ? t.danger
                        : effectiveFocused
                        ? t.ink
                        : t.ink3,
                  )
                : null,
            floatingLabelBehavior: _useFloatingLabel
                ? FloatingLabelBehavior.auto
                : FloatingLabelBehavior.never,
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
            suffixIconConstraints: _suffixIconConstraints,
            suffixIcon: _buildSuffixIcon(t),
          ),
        );
        final inputShell = _buildInputShell(
          context: context,
          tokens: t,
          hasError: hasError,
          focused: effectiveFocused,
          child: textField,
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
            if (widget.showLabel && !_useFloatingLabel) ...[
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

  Widget _buildInputShell({
    required BuildContext context,
    required CatchTokens tokens,
    required bool hasError,
    required bool focused,
    required Widget child,
  }) {
    // Bare: no border or shell — for embedding inside a CatchField row that owns
    // its own chrome (floating label + FieldGroup dividers).
    if (widget.variant == CatchTextFieldVariant.bare) {
      return child;
    }
    if (widget.variant == CatchTextFieldVariant.box) {
      return CatchControlShell(
        size: _controlSize,
        shape: _controlShape,
        tone: _controlTone,
        enabled: widget.enabled,
        hasError: hasError,
        focused: focused,
        padding: EdgeInsets.zero,
        child: child,
      );
    }

    final active = focused || hasError;
    return AnimatedContainer(
      duration: CatchMotion.fast,
      curve: CatchMotion.standardCurve,
      constraints: BoxConstraints(
        minHeight: CatchControlMetrics.minHeight(_controlSize),
      ),
      padding: EdgeInsets.zero,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: _borderColor(tokens, hasError: hasError, focused: focused),
            width: active ? CatchStroke.underline : CatchStroke.hairline,
          ),
        ),
      ),
      child: child,
    );
  }

  Color _borderColor(
    CatchTokens t, {
    required bool hasError,
    required bool focused,
  }) {
    if (hasError) return t.danger;
    if (!widget.enabled) return t.line;
    if (focused) return t.primary;
    return t.line2;
  }

  Widget? _buildSuffixIcon(CatchTokens t) {
    final trailing = widget.trailing;

    if (widget.showClearButton) {
      return ValueListenableBuilder(
        valueListenable: _controller,
        builder: (_, TextEditingValue value, _) {
          if (value.text.isEmpty) {
            return _quietTrailing(
                  t,
                  trailing ?? widget.suffixIcon,
                  padded: trailing != null,
                ) ??
                const SizedBox.shrink();
          }
          return IconButton(
            tooltip: 'Clear ${widget.label}',
            icon: Icon(CatchIcons.closeRounded, size: CatchIcon.xs),
            onPressed: () {
              _controller.clear();
              widget.onChanged?.call('');
            },
          );
        },
      );
    }

    return _quietTrailing(
      t,
      trailing ?? widget.suffixIcon,
      padded: trailing != null,
    );
  }

  Widget? _quietTrailing(CatchTokens t, Widget? child, {required bool padded}) {
    if (child == null) return null;
    final styledChild = IconTheme(
      data: IconThemeData(color: t.ink3, size: CatchIcon.md),
      child: DefaultTextStyle.merge(
        style: CatchTextStyles.bodyLead(context, color: t.ink3),
        child: child,
      ),
    );
    if (!padded) return styledChild;
    return Padding(
      padding: const EdgeInsets.only(left: CatchSpacing.s2),
      child: styledChild,
    );
  }

  bool get _useFloatingLabel =>
      widget.floatingLabel &&
      widget.showLabel &&
      // Optional fields keep the explicit static label + "(optional)" badge,
      // which the inline floating caption can't carry.
      !widget.isOptional &&
      widget.variant != CatchTextFieldVariant.bare;

  EdgeInsets get _contentPadding {
    if (widget.variant == CatchTextFieldVariant.bare) return EdgeInsets.zero;
    if (widget.variant == CatchTextFieldVariant.underline) {
      final multiline = widget.maxLines != 1 || widget.minLines != null;
      return EdgeInsets.only(bottom: multiline ? CatchSpacing.s1 : 0);
    }
    return CatchControlMetrics.textFieldContentPadding(_controlSize);
  }

  TextStyle _textStyle(BuildContext context, {required Color color}) {
    final style = widget.size == CatchTextFieldSize.floating
        ? CatchTextStyles.bodyLead(context, color: color)
        : CatchTextStyles.bodyL(context, color: color);

    if (!widget.mono) return style;

    return style.copyWith(
      fontFeatures: [
        ...?style.fontFeatures,
        const FontFeature.tabularFigures(),
      ],
    );
  }

  BoxConstraints? get _iconConstraints {
    if (widget.maxLines != 1 || widget.minLines != null) return null;

    final extent = CatchControlMetrics.iconExtent(_controlSize);
    return CatchControlMetrics.squareConstraints(extent);
  }

  BoxConstraints? get _suffixIconConstraints {
    if (widget.trailing == null) return _iconConstraints;
    return const BoxConstraints();
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
