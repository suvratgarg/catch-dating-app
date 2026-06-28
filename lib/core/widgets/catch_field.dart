import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CatchFieldMode { edit, read, nav, toggle, select }

enum CatchFieldEmphasis { body, title }

enum CatchFieldTone { normal, primary, danger }

enum CatchFieldVariant { row, underline, bare }

enum CatchFieldSize { floating, compact, md }

enum CatchFieldSupportTone { neutral, brand, success }

/// Design-system `Field`: the unified field primitive for row, text-entry,
/// navigation, toggle, expanded-control, add, validation, and helper states.
/// Stack fields in a CatchSection when the surrounding section owns box or
/// divider chrome.
class CatchField extends StatefulWidget {
  const CatchField({
    super.key,
    this.title,
    this.body,
    this.action,
    this.titleMaxLines = 1,
    this.bodyMaxLines = 2,
    this.mode,
    this.emphasis = CatchFieldEmphasis.body,
    this.tone = CatchFieldTone.normal,
    this.variant = CatchFieldVariant.row,
    this.icon,
    this.iconColor,
    this.leadingUnit,
    this.valueText,
    this.valueMaxLines = 1,
    this.showChevron,
    this.placeholder,
    this.toggled = false,
    this.onToggle,
    this.control,
    this.initiallyExpanded = false,
    this.add = false,
    this.error,
    this.errorText,
    this.valid = false,
    this.divider = false,
    this.tint = true,
    this.onTap,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onFocusChanged,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.readOnly = false,
    this.autofocus = false,
    this.enabled = true,
    this.isOptional = false,
    this.showLabel = true,
    this.helperText,
    this.helperTone = CatchFieldSupportTone.neutral,
    this.size = CatchFieldSize.md,
    this.textAlign = TextAlign.start,
    this.focused = false,
    this.mono = false,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.suffixText,
    this.showClearButton = false,
    this.floatingLabel = true,
    this._selectValues,
    this._selectItemLabel,
    this._selectValue,
    this._onSelectChanged,
    this._selectValidator,
  });

  static CatchField select<T>({
    Key? key,
    required String title,
    required List<T> values,
    required String Function(T item) itemLabel,
    T? value,
    String? hintText,
    Widget? prefixIcon,
    ValueChanged<T?>? onChanged,
    FormFieldValidator<T>? validator,
    bool enabled = true,
    bool isOptional = false,
    bool showLabel = true,
    CatchFieldSize size = CatchFieldSize.md,
    CatchFieldTone tone = CatchFieldTone.normal,
    CatchFieldVariant variant = CatchFieldVariant.row,
    String? helperText,
    CatchFieldSupportTone helperTone = CatchFieldSupportTone.neutral,
    bool floatingLabel = false,
  }) {
    return CatchField(
      key: key,
      title: title,
      placeholder: hintText ?? 'Select ${title.toLowerCase()}',
      prefixIcon: prefixIcon,
      mode: CatchFieldMode.select,
      enabled: enabled,
      isOptional: isOptional,
      showLabel: showLabel,
      size: size,
      tone: tone,
      variant: variant,
      helperText: helperText,
      helperTone: helperTone,
      floatingLabel: floatingLabel,
      selectValues: List<Object?>.unmodifiable(values),
      selectValue: value,
      selectItemLabel: (item) => itemLabel(item as T),
      selectValidator: validator == null
          ? null
          : (item) => validator(item as T?),
      onSelectChanged: onChanged == null
          ? null
          : (item) => onChanged(item as T?),
    );
  }

  static const double compactControlHeight =
      CatchControlMetrics.compactMinHeight;
  static const double mdControlHeight = CatchControlMetrics.mdMinHeight;

  /// Primary row text or input label.
  final String? title;

  /// Supporting row text.
  final String? body;

  /// End-aligned row action or input suffix widget.
  final Widget? action;

  /// End-aligned text lane for compact read/nav rows. Use [body] for text
  /// beneath the title; use [valueText] for settings-style metadata on the
  /// right edge.
  final String? valueText;

  final int valueMaxLines;

  final int titleMaxLines;
  final int bodyMaxLines;

  final CatchFieldMode? mode;
  final CatchFieldEmphasis emphasis;
  final CatchFieldTone tone;
  final CatchFieldVariant variant;
  final IconData? icon;
  final Color? iconColor;
  final String? leadingUnit;
  final bool? showChevron;
  final String? placeholder;
  final bool toggled;
  final ValueChanged<bool>? onToggle;

  /// A control (Stepper / Chips / OptionCards) revealed on tap; the value shows
  /// as text at rest.
  final Widget? control;
  final bool initiallyExpanded;
  final bool add;
  final String? error;
  final String? errorText;
  final bool valid;
  final bool divider;
  final bool tint;
  final VoidCallback? onTap;

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<bool>? onFocusChanged;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final bool readOnly;
  final bool autofocus;
  final bool enabled;
  final bool isOptional;
  final bool showLabel;
  final String? helperText;
  final CatchFieldSupportTone helperTone;
  final CatchFieldSize size;
  final TextAlign textAlign;
  final bool focused;
  final bool mono;
  final Widget? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final String? suffixText;

  /// When true, replaces [suffixIcon] with a clear target when the field has
  /// non-empty text.
  final bool showClearButton;

  /// Render the title as a Material-style floating caption for underline input
  /// chrome instead of a static label above it.
  final bool floatingLabel;

  final List<Object?>? _selectValues;
  final String Function(Object? item)? _selectItemLabel;
  final Object? _selectValue;
  final ValueChanged<Object?>? _onSelectChanged;
  final FormFieldValidator<Object?>? _selectValidator;

  @override
  State<CatchField> createState() => _CatchFieldState();
}

class _CatchFieldState extends State<CatchField> {
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  final _selectFieldKey = GlobalKey<FormFieldState<Object?>>();
  final _menuController = MenuController();
  late final FocusNode _focusNode;
  late final TextEditingController _internalController;
  TextEditingController? _listenedController;

  bool _focused = false;
  late bool _open;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _open = widget.initiallyExpanded && widget.control != null;
    _focusNode = FocusNode()..addListener(_handleFocusChanged);
    _internalController = TextEditingController(
      text: widget.controller == null ? widget.initialValue : null,
    );
    _attachControllerListener(_controller);
  }

  @override
  void didUpdateWidget(covariant CatchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.control != widget.control && widget.control == null) {
      _open = false;
    }
    if (oldWidget._selectValue != widget._selectValue) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final field = _selectFieldKey.currentState;
        final value = _normalizedSelectValue(widget._selectValue);
        if (field != null && field.value != value) {
          field.didChange(value);
        }
      });
    }

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
    _focused = _focusNode.hasFocus;
    widget.onFocusChanged?.call(_focused);
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

  CatchFieldMode get _mode => _hasSelect
      ? CatchFieldMode.select
      : widget.mode ??
            (_hasTextEntryConfiguration
                ? CatchFieldMode.edit
                : widget.onToggle != null
                ? CatchFieldMode.toggle
                : (widget.showChevron == true || widget.onTap != null)
                ? CatchFieldMode.nav
                : CatchFieldMode.read);

  bool get _hasValue => _body != null && _body!.isNotEmpty;
  bool get _hasControl => widget.control != null;
  bool get _hasSelect =>
      widget._selectValues != null && widget._selectItemLabel != null;
  bool get _hasError => _displayError != null && _displayError!.isNotEmpty;
  bool get _active => _focused || _open;
  bool get _isEdit => _mode == CatchFieldMode.edit;
  bool get _hasTextEntryConfiguration =>
      widget.controller != null ||
      widget.initialValue != null ||
      widget.onChanged != null ||
      widget.onSubmitted != null ||
      widget.onFocusChanged != null ||
      widget.validator != null ||
      widget.keyboardType != null ||
      widget.textInputAction != null ||
      widget.inputFormatters != null ||
      widget.autofillHints != null ||
      widget.obscureText ||
      widget.maxLines != 1 ||
      widget.minLines != null ||
      widget.readOnly ||
      widget.autofocus ||
      widget.prefixIcon != null ||
      widget.prefixText != null ||
      widget.suffixIcon != null ||
      widget.suffixText != null ||
      widget.showClearButton;
  bool get _titlePrimary => widget.emphasis == CatchFieldEmphasis.title;
  bool get _usesCanonicalContent =>
      widget.title != null || widget.body != null || widget.action != null;
  bool get _usesUnderlineChrome =>
      _isEdit && widget.variant == CatchFieldVariant.underline;
  String? get _title => widget.title;
  String? get _body => widget.body;
  Widget? get _action => widget.action;
  String? get _displayError => widget.errorText ?? widget.error;
  String? get _placeholderText => widget.placeholder;
  bool get _shouldShowChevron =>
      widget.showChevron ??
      (_mode == CatchFieldMode.nav &&
          (widget.mode == CatchFieldMode.nav || _action == null) &&
          widget.tone != CatchFieldTone.danger);

  /// A value-less read/nav/toggle row where the title is the primary text.
  bool get _inline =>
      !_isEdit && !_hasControl && !_hasValue && !_open && !_titlePrimary;

  bool get _floated => !_isEdit || _hasValue || _active;

  @override
  Widget build(BuildContext context) {
    if (_mode == CatchFieldMode.select) return _buildSelectField(context);
    if (_usesUnderlineChrome) return _buildTextEntryField(context);

    final t = CatchTokens.of(context);

    return Stack(
      children: [
        if (widget.divider && !_active)
          Positioned(
            top: 0,
            left: widget.icon != null
                ? CatchLayout.settingsRowDividerIconInset
                : CatchSpacing.s4,
            right: CatchSpacing.s4,
            child: ColoredBox(
              color: t.line,
              child: const SizedBox(height: CatchStroke.hairline),
            ),
          ),
        widget.add ? _buildAdd(t) : _buildRow(t),
      ],
    );
  }

  Widget _buildAdd(CatchTokens t) {
    return InkWell(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s4,
          vertical: CatchSpacing.micro14,
        ),
        child: Row(
          children: [
            Icon(
              widget.icon ?? CatchIcons.add,
              size: CatchIcon.md,
              color: t.primary,
            ),
            const SizedBox(width: CatchSpacing.s3),
            Text(
              _title ?? '',
              style: CatchTextStyles.titleS(
                context,
                color: _toneColor(t, primaryFallback: t.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRow(CatchTokens t) {
    final clickable = _hasControl || (widget.onTap != null && !_isEdit);

    return InkWell(
      onTap: clickable
          ? () {
              if (_hasControl) setState(() => _open = !_open);
              widget.onTap?.call();
            }
          : null,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s4,
          CatchSpacing.micro14,
          CatchSpacing.s4,
          CatchSpacing.micro14,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.icon != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: CatchSpacing.micro2),
                child: Icon(
                  widget.icon,
                  size: CatchIcon.md,
                  color:
                      widget.iconColor ??
                      (_focused ? t.ink : _toneColor(t, muted: true)),
                ),
              ),
              const SizedBox(width: CatchSpacing.s3),
            ],
            Expanded(child: _buildBody(t)),
            ..._buildEndControls(t),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(CatchTokens t) {
    if (_usesCanonicalContent && !_isEdit) return _buildCanonicalBody(t);

    final labelInPlace = _inline || _titlePrimary;
    return Padding(
      padding: EdgeInsets.only(top: labelInPlace ? 0 : CatchSpacing.s4),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (_title != null && _title!.isNotEmpty)
            labelInPlace
                ? _buildFieldLabel(
                    style: _titlePrimary
                        ? CatchTextStyles.fieldRowTitle(
                            context,
                            color: _hasError
                                ? t.danger
                                : _toneColor(t, primaryFallback: t.ink),
                          )
                        : CatchTextStyles.bodyM(
                            context,
                            color: _hasError
                                ? t.danger
                                : _toneColor(t, primaryFallback: t.ink),
                          ),
                  )
                : AnimatedPositioned(
                    duration: CatchMotion.fast,
                    curve: CatchMotion.standardCurve,
                    left: 0,
                    right: 0,
                    top: _floated ? 0 : CatchSpacing.s4,
                    child: _buildFieldLabel(
                      style: _floated
                          ? CatchTextStyles.fieldLabel(
                              context,
                              color: _hasError
                                  ? t.danger
                                  : _focused
                                  ? t.ink
                                  : t.ink3,
                            )
                          : CatchTextStyles.bodyM(
                              context,
                              color: _hasError ? t.danger : t.ink3,
                            ),
                    ),
                  ),
          _buildContent(t),
        ],
      ),
    );
  }

  Widget _buildFieldLabel({required TextStyle style}) {
    final title = _title;
    if (title == null || title.isEmpty) return const SizedBox.shrink();

    if (widget.isOptional && widget.showLabel) {
      return CatchFormFieldLabel(
        label: title,
        isOptional: true,
        hasError: _hasError,
      );
    }

    return Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
  }

  Widget _buildCanonicalBody(CatchTokens t) {
    final title = _title?.trim();
    final body = _body?.trim().isNotEmpty == true
        ? _body!.trim()
        : _placeholderText?.trim();
    final error = _displayError?.trim();
    final hasTitle = title != null && title.isNotEmpty;
    final hasBody = body != null && body.isNotEmpty;
    final hasError = error != null && error.isNotEmpty;
    final control = _open ? widget.control : null;

    if (!hasTitle && !hasBody && !hasError && control == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CatchSpacing.micro2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasTitle)
            Text(
              title,
              maxLines: widget.titleMaxLines,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.fieldRowTitle(
                context,
                color: _hasError
                    ? t.danger
                    : _toneColor(t, primaryFallback: t.ink),
              ),
            ),
          if (hasBody) ...[
            if (hasTitle) const SizedBox(height: CatchSpacing.micro3),
            Text(
              body,
              maxLines: widget.bodyMaxLines,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.bodyS(context, color: t.ink3),
            ),
          ],
          if (hasError) ...[
            if (hasTitle || hasBody) const SizedBox(height: CatchSpacing.s1),
            Text(
              error,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.supporting(context, color: t.danger),
            ),
          ],
          if (control != null) ...[
            if (hasTitle || hasBody || hasError)
              const SizedBox(height: CatchSpacing.s3),
            control,
          ],
        ],
      ),
    );
  }

  Widget _buildContent(CatchTokens t) {
    if (_isEdit) {
      return Padding(
        padding: EdgeInsets.only(
          top: _title == null || _title!.isEmpty || !widget.showLabel
              ? 0
              : CatchSpacing.s8,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            if (widget.leadingUnit != null) ...[
              Text(
                widget.leadingUnit!,
                style: CatchTextStyles.titleS(context, color: t.ink2),
              ),
              const SizedBox(width: CatchSpacing.s1),
            ],
            Expanded(
              child: _buildTextEntryField(
                context,
                showLabelOverride: false,
                variantOverride: CatchFieldVariant.bare,
              ),
            ),
          ],
        ),
      );
    }

    if (_open && _hasControl) {
      return Padding(
        padding: const EdgeInsets.only(top: CatchSpacing.s1),
        child: widget.control,
      );
    }

    if (_titlePrimary) {
      return _hasValue
          ? Padding(
              padding: const EdgeInsets.only(top: CatchSpacing.micro2),
              child: Text(
                _body!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.fieldLabel(
                  context,
                  color: _hasError ? t.danger : null,
                ),
              ),
            )
          : const SizedBox.shrink();
    }

    if (_inline) return const SizedBox.shrink();

    return Text(
      _hasValue ? _body! : (_placeholderText ?? ''),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: _hasValue
          ? CatchTextStyles.fieldRowTitle(context)
          : CatchTextStyles.bodyM(context, color: t.ink3),
    );
  }

  Widget _buildTextEntryField(
    BuildContext context, {
    bool? showLabelOverride,
    CatchFieldVariant? variantOverride,
  }) {
    final effectiveVariant = variantOverride ?? widget.variant;
    final effectiveShowLabel = showLabelOverride ?? widget.showLabel;

    return FormField<String>(
      key: _fieldKey,
      initialValue: _controller.text,
      validator: widget.validator,
      enabled: widget.enabled,
      builder: (state) {
        final t = CatchTokens.of(context);
        final rawError = widget.errorText ?? widget.error ?? state.errorText;
        final error = rawError?.trim().isNotEmpty == true
            ? rawError!.trim()
            : null;
        final hasError = error != null;
        final supportText = error ?? widget.helperText;
        final canInteract = !widget.readOnly || widget.onTap != null;
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
            contentPadding: _contentPadding(effectiveVariant),
            labelText: _useFloatingLabel(effectiveVariant, effectiveShowLabel)
                ? _title
                : null,
            labelStyle: _useFloatingLabel(effectiveVariant, effectiveShowLabel)
                ? CatchTextStyles.bodyL(
                    context,
                    color: hasError ? t.danger : t.ink3,
                  )
                : null,
            floatingLabelStyle:
                _useFloatingLabel(effectiveVariant, effectiveShowLabel)
                ? CatchTextStyles.fieldLabel(
                    context,
                    color: hasError
                        ? t.danger
                        : effectiveFocused
                        ? t.ink
                        : t.ink3,
                  )
                : null,
            floatingLabelBehavior:
                _useFloatingLabel(effectiveVariant, effectiveShowLabel)
                ? FloatingLabelBehavior.auto
                : FloatingLabelBehavior.never,
            hintText: _placeholderText,
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
        final inputShell = _buildFieldChrome(
          context: context,
          tokens: t,
          hasError: hasError,
          focused: effectiveFocused,
          variant: effectiveVariant,
          child: textField,
        );
        final singleLineControlHeight = _singleLineControlHeight(
          effectiveVariant,
        );
        final sizedInputShell = singleLineControlHeight == null
            ? inputShell
            : SizedBox(height: singleLineControlHeight, child: inputShell);

        final field = effectiveShowLabel
            ? sizedInputShell
            : Semantics(label: _title, textField: true, child: sizedInputShell);

        if (!effectiveShowLabel && supportText == null) {
          return field;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (effectiveShowLabel &&
                !_useFloatingLabel(effectiveVariant, effectiveShowLabel)) ...[
              CatchFormFieldLabel(
                label: _title ?? '',
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

  Widget _buildSelectField(BuildContext context) {
    return FormField<Object?>(
      key: _selectFieldKey,
      initialValue: _normalizedSelectValue(widget._selectValue),
      validator: widget._selectValidator,
      enabled: widget.enabled,
      builder: (state) {
        final t = CatchTokens.of(context);
        final value = _normalizedSelectValue(state.value);
        final rawError = widget.errorText ?? widget.error ?? state.errorText;
        final error = rawError?.trim().isNotEmpty == true
            ? rawError!.trim()
            : null;
        final hasError = error != null;
        final supportText = error ?? widget.helperText;
        final field = _buildSelectTrigger(
          context: context,
          tokens: t,
          value: value,
          hasError: hasError,
          onChanged: widget.enabled && widget._onSelectChanged != null
              ? (next) {
                  state.didChange(next);
                  widget._onSelectChanged?.call(next);
                }
              : null,
        );

        if (!widget.showLabel && supportText == null) return field;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.showLabel &&
                !_useFloatingLabel(widget.variant, widget.showLabel)) ...[
              CatchFormFieldLabel(
                label: _title ?? '',
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

  Widget _buildSelectTrigger({
    required BuildContext context,
    required CatchTokens tokens,
    required Object? value,
    required bool hasError,
    required ValueChanged<Object?>? onChanged,
  }) {
    final values = widget._selectValues ?? const <Object?>[];
    final labelOf = widget._selectItemLabel!;
    final label = value == null ? null : labelOf(value);
    final canOpen = widget.enabled && onChanged != null && values.isNotEmpty;
    final menuBorderRadius = BorderRadius.circular(CatchRadius.sm);

    return LayoutBuilder(
      builder: (context, constraints) {
        final menuWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : null;
        return MenuAnchor(
          controller: _menuController,
          style: MenuStyle(
            backgroundColor: WidgetStatePropertyAll(tokens.surface),
            elevation: const WidgetStatePropertyAll(CatchElevation.menu),
            shadowColor: WidgetStatePropertyAll(tokens.overlay),
            surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
            shape: WidgetStatePropertyAll(
              RoundedRectangleBorder(borderRadius: menuBorderRadius),
            ),
            padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(vertical: CatchSpacing.s1),
            ),
          ),
          menuChildren: [
            for (final item in values)
              SizedBox(
                width: menuWidth,
                child: MenuItemButton(
                  style: ButtonStyle(
                    minimumSize: WidgetStatePropertyAll(
                      Size(0, _menuItemHeight),
                    ),
                    padding: const WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: CatchSpacing.s4),
                    ),
                    foregroundColor: WidgetStatePropertyAll(tokens.ink),
                    backgroundColor: WidgetStatePropertyAll(
                      item == value ? tokens.primarySoft : Colors.transparent,
                    ),
                    overlayColor: WidgetStatePropertyAll(tokens.primarySoft),
                    textStyle: WidgetStatePropertyAll(
                      CatchTextStyles.bodyLead(context, color: tokens.ink),
                    ),
                  ),
                  trailingIcon: item == value
                      ? Icon(
                          CatchIcons.checkRounded,
                          color: tokens.primary,
                          size: CatchIcon.sm,
                        )
                      : null,
                  onPressed: () {
                    onChanged?.call(item);
                    _menuController.close();
                  },
                  child: Text(
                    labelOf(item),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.labelL(context, color: tokens.ink),
                  ),
                ),
              ),
          ],
          builder: (context, controller, child) {
            return Semantics(
              button: true,
              enabled: canOpen,
              label: _title,
              value: label,
              child: Focus(
                focusNode: _focusNode,
                child: InkWell(
                  onTap: canOpen
                      ? () {
                          _focusNode.requestFocus();
                          controller.isOpen
                              ? controller.close()
                              : controller.open();
                        }
                      : null,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: CatchControlMetrics.minHeight(_controlSize),
                    ),
                    child: Padding(
                      padding: CatchControlMetrics.contentPadding(_controlSize),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.prefixIcon != null) ...[
                            IconTheme(
                              data: IconThemeData(
                                color: hasError ? tokens.danger : tokens.ink3,
                                size: CatchIcon.md,
                              ),
                              child: widget.prefixIcon!,
                            ),
                            const SizedBox(width: CatchSpacing.s2),
                          ],
                          if (constraints.hasBoundedWidth)
                            Expanded(child: _selectLabel(tokens, label))
                          else
                            _selectLabel(tokens, label),
                          const SizedBox(width: CatchSpacing.s1),
                          Icon(
                            controller.isOpen
                                ? CatchIcons.expandLessRounded
                                : CatchIcons.expandMoreRounded,
                            size: CatchIcon.md,
                            color: hasError ? tokens.danger : tokens.ink3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _selectLabel(CatchTokens t, String? label) {
    return Text(
      label ?? widget.placeholder ?? 'Select',
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: CatchTextStyles.bodyL(
        context,
        color: label == null ? t.ink3 : t.ink,
      ),
    );
  }

  Widget _buildFieldChrome({
    required BuildContext context,
    required CatchTokens tokens,
    required bool hasError,
    required bool focused,
    required CatchFieldVariant variant,
    required Widget child,
  }) {
    if (variant == CatchFieldVariant.bare || variant == CatchFieldVariant.row) {
      return child;
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

  List<Widget> _buildEndControls(CatchTokens t) {
    final top = const SizedBox(width: CatchSpacing.s2);
    if (widget.valid && !_hasError) {
      return [
        top,
        Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.micro3),
          child: Icon(
            CatchIcons.checkCircle,
            size: CatchIcon.md,
            color: t.success,
          ),
        ),
      ];
    }
    if (_mode == CatchFieldMode.toggle) {
      return [
        top,
        Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.micro2),
          child: CatchToggle(value: widget.toggled, onChanged: widget.onToggle),
        ),
      ];
    }
    if (_hasControl) {
      return [
        top,
        Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.micro3),
          child: AnimatedRotation(
            turns: _open ? 0.5 : 0,
            duration: CatchMotion.fast,
            child: Icon(
              CatchIcons.expandMoreRounded,
              size: CatchIcon.control,
              color: _active ? t.ink : t.ink3,
            ),
          ),
        ),
      ];
    }
    if (_mode == CatchFieldMode.nav) {
      return [
        ..._buildAction(t),
        if (_shouldShowChevron) ...[
          top,
          Padding(
            padding: const EdgeInsets.only(top: CatchSpacing.micro3),
            child: Icon(
              CatchIcons.chevronRightRounded,
              size: CatchIcon.control,
              color: t.ink3,
            ),
          ),
        ],
      ];
    }
    return _buildAction(t);
  }

  List<Widget> _buildAction(CatchTokens t) {
    final action = _action;
    final valueText = widget.valueText?.trim();
    if (action == null && (valueText == null || valueText.isEmpty)) {
      return const [];
    }
    return [
      if (valueText != null && valueText.isNotEmpty) ...[
        const SizedBox(width: CatchSpacing.s3),
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(top: CatchSpacing.micro2),
            child: Text(
              valueText,
              textAlign: TextAlign.right,
              maxLines: widget.valueMaxLines,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.bodyS(context, color: t.ink),
            ),
          ),
        ),
      ],
      if (action != null) ...[
        const SizedBox(width: CatchSpacing.s2),
        Padding(
          padding: const EdgeInsets.only(top: CatchSpacing.micro2),
          child: action,
        ),
      ],
    ];
  }

  Widget? _buildSuffixIcon(CatchTokens t) {
    final action = _action;

    if (widget.showClearButton) {
      return ValueListenableBuilder(
        valueListenable: _controller,
        builder: (_, TextEditingValue value, _) {
          if (value.text.isEmpty) {
            return _quietSuffix(
                  t,
                  action ?? widget.suffixIcon,
                  padded: action != null,
                ) ??
                const SizedBox.shrink();
          }
          return IconButton(
            tooltip: 'Clear ${_title ?? 'field'}',
            icon: Icon(CatchIcons.closeRounded, size: CatchIcon.xs),
            onPressed: () {
              _controller.clear();
              widget.onChanged?.call('');
            },
          );
        },
      );
    }

    return _quietSuffix(t, action ?? widget.suffixIcon, padded: action != null);
  }

  Widget? _quietSuffix(CatchTokens t, Widget? child, {required bool padded}) {
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

  void _handleSubmitted(String value) {
    widget.onSubmitted?.call(value);
    _focusNode.unfocus();
  }

  bool _useFloatingLabel(CatchFieldVariant variant, bool showLabel) {
    return widget.floatingLabel &&
        showLabel &&
        !widget.isOptional &&
        variant == CatchFieldVariant.underline;
  }

  EdgeInsets _contentPadding(CatchFieldVariant variant) {
    if (variant == CatchFieldVariant.bare || variant == CatchFieldVariant.row) {
      return EdgeInsets.zero;
    }
    if (variant == CatchFieldVariant.underline) {
      final multiline = widget.maxLines != 1 || widget.minLines != null;
      return EdgeInsets.only(bottom: multiline ? CatchSpacing.s1 : 0);
    }
    return CatchControlMetrics.textFieldContentPadding(_controlSize);
  }

  TextStyle _textStyle(BuildContext context, {required Color color}) {
    final style = widget.size == CatchFieldSize.floating
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

  Color _supportColor(CatchTokens t) {
    return switch (widget.helperTone) {
      CatchFieldSupportTone.neutral => t.ink3,
      CatchFieldSupportTone.brand => t.primary,
      CatchFieldSupportTone.success => t.success,
    };
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

  BoxConstraints? get _iconConstraints {
    if (widget.maxLines != 1 || widget.minLines != null) return null;

    final extent = CatchControlMetrics.iconExtent(_controlSize);
    return CatchControlMetrics.squareConstraints(extent);
  }

  BoxConstraints? get _suffixIconConstraints {
    if (_action == null) return _iconConstraints;
    return const BoxConstraints();
  }

  CatchControlSize get _controlSize {
    return switch (widget.size) {
      CatchFieldSize.floating => CatchControlSize.floating,
      CatchFieldSize.compact => CatchControlSize.compact,
      CatchFieldSize.md => CatchControlSize.md,
    };
  }

  double get _menuItemHeight {
    return switch (widget.size) {
      CatchFieldSize.compact => CatchLayout.menuItemHeightCompact,
      _ => CatchLayout.menuItemHeight,
    };
  }

  Object? _normalizedSelectValue(Object? value) {
    if (value == null) return null;
    final values = widget._selectValues;
    if (values == null || !values.contains(value)) return null;
    return value;
  }

  TextAlignVertical? get _textAlignVertical {
    if (widget.maxLines != 1 || widget.minLines != null) return null;
    return TextAlignVertical.center;
  }

  double? _singleLineControlHeight(CatchFieldVariant variant) {
    if (variant == CatchFieldVariant.bare || variant == CatchFieldVariant.row) {
      return null;
    }
    if (widget.maxLines != 1 || widget.minLines != null) return null;
    return CatchControlMetrics.minHeight(_controlSize);
  }

  Color _toneColor(
    CatchTokens t, {
    bool muted = false,
    Color? primaryFallback,
  }) {
    return switch (widget.tone) {
      CatchFieldTone.primary => t.primary,
      CatchFieldTone.danger => t.danger,
      _ => primaryFallback ?? (muted ? t.ink2 : t.ink),
    };
  }
}
