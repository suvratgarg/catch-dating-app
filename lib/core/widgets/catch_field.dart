import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:flutter/foundation.dart';
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
  const CatchField._({
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
    this._onCancel,
    this._onSubmit,
    this._isLoading = false,
    this._actionLeading,
  }) : assert(
         mode != CatchFieldMode.select ||
             (_selectValues != null && _selectItemLabel != null),
         'Use CatchField.select to build select fields.',
       ),
       assert(
         controller == null || initialValue == null,
         'CatchField.input cannot include both controller and initialValue.',
       );

  const CatchField.read({
    Key? key,
    String? title,
    String? body,
    Widget? action,
    int titleMaxLines = 1,
    int bodyMaxLines = 2,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    String? valueText,
    int valueMaxLines = 1,
    String? placeholder,
    bool valid = false,
    bool divider = false,
  }) : this._(
         key: key,
         title: title,
         body: body,
         action: action,
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         mode: CatchFieldMode.read,
         emphasis: emphasis,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         valueText: valueText,
         valueMaxLines: valueMaxLines,
         placeholder: placeholder,
         valid: valid,
         divider: divider,
       );

  const CatchField.nav({
    Key? key,
    String? title,
    String? body,
    Widget? action,
    VoidCallback? onTap,
    int titleMaxLines = 1,
    int bodyMaxLines = 2,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    String? valueText,
    int valueMaxLines = 1,
    bool? showChevron,
    String? placeholder,
    String? error,
    String? errorText,
    bool valid = false,
    bool divider = false,
  }) : this._(
         key: key,
         title: title,
         body: body,
         action: action,
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         mode: CatchFieldMode.nav,
         emphasis: emphasis,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         valueText: valueText,
         valueMaxLines: valueMaxLines,
         showChevron: showChevron,
         placeholder: placeholder,
         error: error,
         errorText: errorText,
         valid: valid,
         divider: divider,
         onTap: onTap,
       );

  const CatchField.toggle({
    Key? key,
    String? title,
    String? body,
    required bool value,
    required ValueChanged<bool>? onChanged,
    int titleMaxLines = 1,
    int bodyMaxLines = 2,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    bool divider = false,
  }) : this._(
         key: key,
         title: title,
         body: body,
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         mode: CatchFieldMode.toggle,
         emphasis: emphasis,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         toggled: value,
         onToggle: onChanged,
         divider: divider,
       );

  const CatchField.input({
    Key? key,
    required String title,
    String? placeholder,
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    ValueChanged<bool>? onFocusChanged,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    bool obscureText = false,
    int? maxLines = 1,
    int? minLines,
    bool readOnly = false,
    bool autofocus = false,
    bool enabled = true,
    bool isOptional = false,
    bool showLabel = true,
    String? helperText,
    CatchFieldSupportTone helperTone = CatchFieldSupportTone.neutral,
    CatchFieldSize size = CatchFieldSize.md,
    TextAlign textAlign = TextAlign.start,
    bool focused = false,
    bool mono = false,
    Widget? prefixIcon,
    String? prefixText,
    Widget? suffixIcon,
    String? suffixText,
    bool showClearButton = false,
    bool floatingLabel = true,
    CatchFieldVariant variant = CatchFieldVariant.row,
    IconData? icon,
    Color? iconColor,
    String? leadingUnit,
    Widget? action,
    String? error,
    String? errorText,
    bool divider = false,
    VoidCallback? onTap,
  }) : this._(
         key: key,
         title: title,
         action: action,
         mode: CatchFieldMode.edit,
         variant: variant,
         icon: icon,
         iconColor: iconColor,
         leadingUnit: leadingUnit,
         placeholder: placeholder,
         error: error,
         errorText: errorText,
         divider: divider,
         onTap: onTap,
         controller: controller,
         initialValue: initialValue,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         onFocusChanged: onFocusChanged,
         validator: validator,
         keyboardType: keyboardType,
         textInputAction: textInputAction,
         textCapitalization: textCapitalization,
         inputFormatters: inputFormatters,
         autofillHints: autofillHints,
         obscureText: obscureText,
         maxLines: maxLines,
         minLines: minLines,
         readOnly: readOnly,
         autofocus: autofocus,
         enabled: enabled,
         isOptional: isOptional,
         showLabel: showLabel,
         helperText: helperText,
         helperTone: helperTone,
         size: size,
         textAlign: textAlign,
         focused: focused,
         mono: mono,
         prefixIcon: prefixIcon,
         prefixText: prefixText,
         suffixIcon: suffixIcon,
         suffixText: suffixText,
         showClearButton: showClearButton,
         floatingLabel: floatingLabel,
       );

  const CatchField.expanding({
    Key? key,
    required String title,
    String? body,
    required Widget control,
    bool initiallyExpanded = false,
    int titleMaxLines = 1,
    int bodyMaxLines = 2,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    String? placeholder,
    String? error,
    String? errorText,
    bool divider = false,
    VoidCallback? onTap,
  }) : this._(
         key: key,
         title: title,
         body: body,
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         mode: CatchFieldMode.nav,
         emphasis: emphasis,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         placeholder: placeholder,
         control: control,
         initiallyExpanded: initiallyExpanded,
         error: error,
         errorText: errorText,
         divider: divider,
         onTap: onTap,
       );

  const CatchField.actions({
    Key? key,
    required String title,
    String? body,
    required Widget control,
    required VoidCallback onCancel,
    required VoidCallback onSubmit,
    bool isLoading = false,
    Widget? actionLeading,
    bool initiallyExpanded = false,
    int titleMaxLines = 1,
    int bodyMaxLines = 2,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    String? placeholder,
    String? error,
    String? errorText,
    bool divider = false,
    VoidCallback? onTap,
  }) : this._(
         key: key,
         title: title,
         body: body,
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         mode: CatchFieldMode.nav,
         emphasis: emphasis,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         placeholder: placeholder,
         control: control,
         initiallyExpanded: initiallyExpanded,
         error: error,
         errorText: errorText,
         divider: divider,
         onTap: onTap,
         onCancel: onCancel,
         onSubmit: onSubmit,
         isLoading: isLoading,
         actionLeading: actionLeading,
       );

  const CatchField.add({
    Key? key,
    required String title,
    VoidCallback? onTap,
    IconData? icon,
    CatchFieldTone tone = CatchFieldTone.primary,
  }) : this._(
         key: key,
         title: title,
         mode: CatchFieldMode.nav,
         tone: tone,
         icon: icon,
         add: true,
         onTap: onTap,
       );

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
    bool showLabel = true,
    CatchFieldSize size = CatchFieldSize.md,
    String? helperText,
    CatchFieldSupportTone helperTone = CatchFieldSupportTone.neutral,
  }) {
    assert(
      values.toSet().length == values.length,
      'CatchField.select values must be unique.',
    );
    return CatchField._(
      key: key,
      title: title,
      placeholder: hintText ?? 'Select ${title.toLowerCase()}',
      prefixIcon: prefixIcon,
      mode: CatchFieldMode.select,
      enabled: enabled,
      showLabel: showLabel,
      size: size,
      helperText: helperText,
      helperTone: helperTone,
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

  final VoidCallback? _onCancel;
  final VoidCallback? _onSubmit;
  final bool _isLoading;
  final Widget? _actionLeading;

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
  late bool _inputWasEmpty;
  bool _textEntryHasValidationError = false;

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
    _inputWasEmpty = _controller.text.isEmpty;
    _attachControllerListener(_controller);
  }

  @override
  void didUpdateWidget(covariant CatchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.control != widget.control && widget.control == null) {
      _open = false;
    }
    if (oldWidget.initiallyExpanded != widget.initiallyExpanded) {
      _open = widget.initiallyExpanded && widget.control != null;
    }
    if (oldWidget._selectValue != widget._selectValue ||
        !listEquals(oldWidget._selectValues, widget._selectValues)) {
      _scheduleSelectFieldSync();
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
    final focused = _focusNode.hasFocus;
    if (_focused == focused) return;
    _focused = focused;
    widget.onFocusChanged?.call(_focused);
    setState(() {});
  }

  void _attachControllerListener(TextEditingController controller) {
    _listenedController?.removeListener(_syncFieldValue);
    _listenedController = controller..addListener(_syncFieldValue);
  }

  void _syncFieldValue() {
    final text = _controller.text;
    final field = _fieldKey.currentState;
    if (field != null && field.value != text) {
      field.didChange(text);
    }
    final isEmpty = text.isEmpty;
    final needsParentRebuild = isEmpty != _inputWasEmpty;
    _inputWasEmpty = isEmpty;
    if (mounted && needsParentRebuild) setState(() {});
  }

  void _scheduleSelectFieldSync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final field = _selectFieldKey.currentState;
      final value = _normalizedSelectValue(widget._selectValue);
      if (field != null && field.value != value) {
        field.didChange(value);
      }
    });
  }

  void _setTextEntryValidationError(bool hasError) {
    if (_textEntryHasValidationError == hasError) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _textEntryHasValidationError == hasError) return;
      setState(() => _textEntryHasValidationError = hasError);
    });
  }

  void _expandAndFocusTextEntry() {
    setState(() {
      if (!_focused) {
        _focused = true;
        widget.onFocusChanged?.call(true);
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _focusNode.requestFocus();
    });
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
  bool get _hasFieldValidationError => _textEntryHasValidationError;
  bool get _hasError =>
      (_displayError != null && _displayError!.isNotEmpty) ||
      _hasFieldValidationError;
  bool get _active => _focused || widget.focused || _open;
  bool get _isEdit => _mode == CatchFieldMode.edit;
  bool get _hasInputValue => !_inputWasEmpty;
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
  bool get _usesUnderlineChrome =>
      _isEdit && widget.variant == CatchFieldVariant.underline;
  bool get _usesRowPrefixIcon =>
      _isEdit &&
      !_usesUnderlineChrome &&
      !_compactTextEntry &&
      widget.showLabel &&
      widget.prefixIcon != null;
  bool get _usesRowTextEntryTrailing =>
      _isEdit &&
      !_usesUnderlineChrome &&
      !_compactTextEntry &&
      (widget.showClearButton || widget.suffixIcon != null || _action != null);
  bool get _hasLeadingSlot => widget.icon != null || _usesRowPrefixIcon;
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

  bool get _textEntryCanCollapse =>
      _isEdit && widget.showLabel && (_title?.isNotEmpty ?? false);
  bool get _textEntryExpanded =>
      !_textEntryCanCollapse ||
      _hasInputValue ||
      _active ||
      _hasError ||
      widget.autofocus;
  bool _textEntryExpandedWith({required bool hasError}) =>
      !_textEntryCanCollapse ||
      _hasInputValue ||
      _active ||
      hasError ||
      widget.autofocus;
  bool get _textEntryCollapsed => _textEntryCanCollapse && !_textEntryExpanded;
  bool get _compactTextEntry =>
      _isEdit && widget.size == CatchFieldSize.floating && !widget.showLabel;

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
            left:
                _rowPadding.left +
                (_hasLeadingSlot ? CatchFieldRow.textLaneInset : 0),
            right: _rowPadding.right,
            child: ColoredBox(
              color: CatchDivider.colorFor(t, CatchDividerRole.fieldRow),
              child: const SizedBox(height: CatchStroke.hairline),
            ),
          ),
        widget.add ? _buildAdd(t) : _buildRow(t),
      ],
    );
  }

  Widget _buildAdd(CatchTokens t) {
    return CatchFieldRow.add(
      onTap: widget.onTap,
      leading: Icon(
        widget.icon ?? CatchIcons.add,
        size: CatchIcon.md,
        color: t.primary,
      ),
      content: Text(
        _title ?? '',
        style: CatchTextStyles.fieldRowTitle(
          context,
          color: _toneColor(t, primaryFallback: t.primary),
        ),
      ),
    );
  }

  Widget _buildRow(CatchTokens t) {
    final canFocusCollapsedTextEntry =
        _textEntryCollapsed &&
        widget.enabled &&
        (!widget.readOnly || widget.onTap != null);
    final canToggleRow =
        _mode == CatchFieldMode.toggle && widget.onToggle != null;
    final clickable =
        _hasControl ||
        canToggleRow ||
        (widget.onTap != null && !_isEdit) ||
        canFocusCollapsedTextEntry;
    return CatchFieldRow.standard(
      constraints: _rowConstraints,
      padding: _rowPadding,
      leading: _buildLeadingSlot(t),
      trailing: _buildTrailingSlot(t),
      onTap: clickable
          ? () {
              if (canFocusCollapsedTextEntry) {
                if (widget.readOnly && widget.onTap != null) {
                  widget.onTap!();
                  return;
                }
                _expandAndFocusTextEntry();
                return;
              }
              if (_hasControl) setState(() => _open = !_open);
              if (canToggleRow) {
                widget.onToggle!(!widget.toggled);
                return;
              }
              widget.onTap?.call();
            }
          : null,
      content: _buildBody(t),
    );
  }

  Widget? _buildLeadingSlot(CatchTokens t) {
    if (widget.icon != null) {
      return Icon(
        widget.icon,
        size: CatchFieldRow.leadingSlotIconSize,
        color:
            widget.iconColor ?? (_focused ? t.ink : _toneColor(t, muted: true)),
      );
    }

    if (_usesRowPrefixIcon) {
      return IconTheme(
        data: IconThemeData(
          color: _hasError ? t.danger : t.ink2,
          size: CatchFieldRow.leadingSlotIconSize,
        ),
        child: widget.prefixIcon!,
      );
    }

    return null;
  }

  Widget? _buildSelectLeadingSlot(CatchTokens t) {
    if (widget.prefixIcon == null) return null;
    return IconTheme(
      data: IconThemeData(
        color: widget.enabled ? t.ink2 : t.ink3,
        size: CatchFieldRow.leadingSlotIconSize,
      ),
      child: widget.prefixIcon!,
    );
  }

  Widget? _buildTrailingSlot(CatchTokens t) {
    if (widget.valid && !_hasError) return CatchFieldTrailing.valid();

    if (_mode == CatchFieldMode.toggle) {
      return CatchFieldTrailing.toggle(
        value: widget.toggled,
        onChanged: widget.onToggle,
        semanticLabel: _title,
      );
    }

    if (_usesRowTextEntryTrailing) {
      return _buildTextEntryTrailingSlot(t);
    }

    if (_hasControl) {
      return CatchFieldTrailing.rotatingChevron(
        open: _open,
        color: _active ? t.ink : t.ink3,
        topPadding: _rowTrailingTopPadding,
      );
    }

    if (_mode == CatchFieldMode.nav) {
      return _buildTrailingGroup(t, includeChevron: _shouldShowChevron);
    }

    return _buildTrailingGroup(t);
  }

  Widget? _buildTextEntryTrailingSlot(CatchTokens t) {
    final fallback = _buildCustomTrailingSlot(t, _action ?? widget.suffixIcon);
    if (!widget.showClearButton) return fallback;

    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _controller,
      builder: (_, value, _) {
        if (value.text.isEmpty) return fallback ?? const SizedBox.shrink();
        return CatchFieldTrailing.clear(
          tooltip: 'Clear ${_title ?? 'field'}',
          onPressed: () {
            _controller.clear();
            widget.onChanged?.call('');
          },
          topPadding: _rowTrailingTopPadding,
        );
      },
    );
  }

  Widget? _buildTrailingGroup(CatchTokens t, {bool includeChevron = false}) {
    final children = <Widget>[];
    final flexibleIndices = <int>{};
    final valueText = widget.valueText?.trim();
    if (valueText != null && valueText.isNotEmpty) {
      flexibleIndices.add(children.length);
      children.add(
        CatchFieldTrailing.valueText(
          text: valueText,
          maxLines: widget.valueMaxLines,
          topPadding: _rowTrailingTopPadding,
        ),
      );
    }

    final custom = _buildCustomTrailingSlot(t, _action);
    if (custom != null) children.add(custom);

    if (includeChevron) {
      children.add(
        CatchFieldTrailing.fixedChevron(
          color: t.ink3,
          topPadding: _rowTrailingTopPadding,
        ),
      );
    }

    if (children.isEmpty) return null;
    if (children.length == 1) return children.single;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < children.length; i++) ...[
          if (i > 0) const SizedBox(width: CatchSpacing.s2),
          if (flexibleIndices.contains(i))
            Flexible(child: children[i])
          else
            children[i],
        ],
      ],
    );
  }

  Widget? _buildCustomTrailingSlot(CatchTokens t, Widget? child) {
    if (child == null) return null;
    return CatchFieldTrailing.custom(
      topPadding: _rowTrailingTopPadding,
      color: t.ink3,
      child: child,
    );
  }

  double get _rowTrailingTopPadding {
    if (!_isEdit && widget.emphasis == CatchFieldEmphasis.title) {
      return CatchSpacing.micro2;
    }

    final textEntryValueLine =
        _isEdit &&
        !_textEntryCollapsed &&
        widget.showLabel &&
        (_title?.isNotEmpty ?? false);
    final canonicalValueLine =
        !_isEdit &&
        ((_body?.trim().isNotEmpty ?? false) ||
            (_placeholderText?.trim().isNotEmpty ?? false));
    return textEntryValueLine || canonicalValueLine
        ? CatchSpacing.micro18
        : CatchSpacing.micro2;
  }

  Widget _buildBody(CatchTokens t) {
    if (_isEdit) return _buildTextEntryBody(t);

    final title = _title?.trim();
    final value = _body?.trim().isNotEmpty == true
        ? _body!.trim()
        : _placeholderText?.trim();
    final error = _displayError?.trim();
    final hasValue = value != null && value.isNotEmpty;

    return _buildFieldContent(
      t,
      label: title,
      value: value,
      supportText: error?.isNotEmpty == true ? error : null,
      control: _open ? widget.control : null,
      labelEmphasized: widget.emphasis == CatchFieldEmphasis.title || !hasValue,
      valueIsPlaceholder: !_hasValue,
      valueMaxLines: widget.bodyMaxLines,
      hasError: error?.isNotEmpty == true,
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

  Widget _buildTextEntryBody(CatchTokens t) {
    return _buildTextEntryField(
      context,
      showLabelOverride: false,
      variantOverride: CatchFieldVariant.bare,
      valueEmphasis: true,
      rowBody: true,
    );
  }

  Widget _buildFieldContent(
    CatchTokens t, {
    String? label,
    String? value,
    Widget? valueWidget,
    String? supportText,
    Widget? control,
    bool hasError = false,
    bool labelEmphasized = false,
    bool valueIsPlaceholder = false,
    int valueMaxLines = 1,
    TextStyle? labelStyle,
    TextStyle? valueStyle,
  }) {
    final labelText = label?.trim();
    final valueText = value?.trim();
    final hasLabel = labelText != null && labelText.isNotEmpty;
    final hasValue =
        valueWidget != null || (valueText != null && valueText.isNotEmpty);
    final support = supportText?.trim();
    final hasSupport = support != null && support.isNotEmpty;
    final hasControl = control != null;

    if (!hasLabel && !hasValue && !hasSupport && !hasControl) {
      return const SizedBox.shrink();
    }

    final effectiveLabelStyle =
        labelStyle ??
        (labelEmphasized
            ? CatchTextStyles.fieldRowTitle(
                context,
                color: hasError
                    ? t.danger
                    : _toneColor(t, primaryFallback: t.ink),
              )
            : CatchTextStyles.fieldLabel(
                context,
                color: hasError ? t.danger : t.ink3,
              ));
    final effectiveValueStyle =
        valueStyle ??
        (labelEmphasized
            ? CatchTextStyles.supporting(context, color: t.ink3)
            : CatchTextStyles.fieldRowTitle(
                context,
                color: valueIsPlaceholder
                    ? t.ink3
                    : _toneColor(t, primaryFallback: t.ink),
              ));
    final actionBar = LayoutBuilder(
      builder: (context, constraints) {
        final cancelButton = CatchTextButton(
          label: 'Cancel',
          onPressed: widget._isLoading
              ? null
              : () {
                  setState(() => _open = false);
                  widget._onCancel?.call();
                },
          tone: CatchTextButtonTone.neutral,
        );
        final doneButton = CatchButton(
          label: 'Done',
          onPressed: widget._isLoading ? null : widget._onSubmit,
          isLoading: widget._isLoading,
          size: CatchButtonSize.sm,
        );

        if (constraints.maxWidth < CatchLayout.fieldActionBarWrapBreakpoint) {
          return Wrap(
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: CatchSpacing.s3,
            runSpacing: CatchSpacing.s2,
            children: [
              if (widget._actionLeading != null) widget._actionLeading!,
              cancelButton,
              doneButton,
            ],
          );
        }

        return Row(
          children: [
            if (widget._actionLeading != null)
              Expanded(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: widget._actionLeading,
                ),
              )
            else
              const Spacer(),
            cancelButton,
            gapW12,
            doneButton,
          ],
        );
      },
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CatchSpacing.micro2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasLabel)
            Text(
              labelText,
              maxLines: widget.titleMaxLines,
              overflow: TextOverflow.ellipsis,
              style: effectiveLabelStyle,
            ),
          if (hasValue) ...[
            if (hasLabel) const SizedBox(height: CatchSpacing.micro3),
            valueWidget ??
                Text(
                  valueText!,
                  maxLines: valueMaxLines,
                  overflow: TextOverflow.ellipsis,
                  style: effectiveValueStyle,
                ),
          ],
          if (hasSupport) ...[
            if (hasLabel || hasValue) const SizedBox(height: CatchSpacing.s1),
            Text(
              support,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.supporting(
                context,
                color: hasError ? t.danger : _supportColor(t),
              ),
            ),
          ],
          if (hasControl) ...[
            if (hasLabel || hasValue || hasSupport)
              const SizedBox(height: CatchSpacing.s3),
            control,
            if (widget._onSubmit != null) ...[
              const SizedBox(height: CatchSpacing.s3),
              actionBar,
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTextEntryField(
    BuildContext context, {
    bool? showLabelOverride,
    CatchFieldVariant? variantOverride,
    bool valueEmphasis = false,
    bool rowBody = false,
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
        _setTextEntryValidationError(state.hasError);
        final supportText = error ?? widget.helperText;

        if (rowBody) {
          final expanded = _textEntryExpandedWith(hasError: hasError);
          final body = expanded
              ? _buildFieldContent(
                  t,
                  label: widget.showLabel ? _title : null,
                  supportText: supportText,
                  hasError: hasError,
                  labelStyle: CatchTextStyles.fieldLabel(
                    context,
                    color: hasError
                        ? t.danger
                        : _active
                        ? t.ink
                        : t.ink3,
                  ),
                  valueWidget: Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      if (widget.leadingUnit != null) ...[
                        Text(
                          widget.leadingUnit!,
                          style: CatchTextStyles.fieldRowTitle(
                            context,
                            color: t.ink2,
                          ),
                        ),
                        const SizedBox(width: CatchSpacing.s1),
                      ],
                      Expanded(
                        child: _buildTextEntryInput(
                          context,
                          state,
                          variant: effectiveVariant,
                          showLabel: effectiveShowLabel,
                          valueEmphasis: valueEmphasis,
                          hasError: hasError,
                        ),
                      ),
                    ],
                  ),
                )
              : _buildFieldLabel(
                  style: CatchTextStyles.fieldRowTitle(
                    context,
                    color: _toneColor(t, primaryFallback: t.ink),
                  ),
                );

          return _buildTextEntryMotion(context, child: body);
        }

        final field = _buildTextEntryInput(
          context,
          state,
          variant: effectiveVariant,
          showLabel: effectiveShowLabel,
          valueEmphasis: valueEmphasis,
          hasError: hasError,
        );

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

  Widget _buildTextEntryInput(
    BuildContext context,
    FormFieldState<String> state, {
    required CatchFieldVariant variant,
    required bool showLabel,
    required bool valueEmphasis,
    required bool hasError,
  }) {
    final t = CatchTokens.of(context);
    final canInteract = !widget.readOnly || widget.onTap != null;
    final effectiveFocused = _focusNode.hasFocus || widget.focused;
    final inputStyle = valueEmphasis
        ? CatchTextStyles.fieldRowTitle(
            context,
            color: widget.enabled ? t.ink : t.ink3,
          )
        : _textStyle(context, color: widget.enabled ? t.ink : t.ink3);
    final hintStyle = valueEmphasis
        ? CatchTextStyles.fieldRowTitle(context, color: t.ink3)
        : _textStyle(context, color: t.ink3);
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
      style: inputStyle,
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
        contentPadding: _contentPadding(variant),
        labelText: _useFloatingLabel(variant, showLabel) ? _title : null,
        labelStyle: _useFloatingLabel(variant, showLabel)
            ? CatchTextStyles.bodyL(
                context,
                color: hasError ? t.danger : t.ink3,
              )
            : null,
        floatingLabelStyle: _useFloatingLabel(variant, showLabel)
            ? CatchTextStyles.fieldLabel(
                context,
                color: hasError
                    ? t.danger
                    : effectiveFocused
                    ? t.ink
                    : t.ink3,
              )
            : null,
        floatingLabelBehavior: _useFloatingLabel(variant, showLabel)
            ? FloatingLabelBehavior.auto
            : FloatingLabelBehavior.never,
        hintText: _placeholderText,
        hintStyle: hintStyle,
        prefixText: widget.prefixText,
        prefixStyle: _textStyle(context, color: t.ink2),
        suffixText: widget.suffixText,
        suffixStyle: CatchTextStyles.bodyLead(context, color: t.ink2),
        prefixIconConstraints: _iconConstraints,
        prefixIcon: _usesRowPrefixIcon || widget.prefixIcon == null
            ? null
            : IconTheme(
                data: IconThemeData(color: t.ink3, size: CatchIcon.md),
                child: widget.prefixIcon!,
              ),
        suffixIconConstraints: _suffixIconConstraints,
        suffixIcon: _usesRowTextEntryTrailing ? null : _buildSuffixIcon(t),
      ),
    );
    final inputShell = _buildFieldChrome(
      context: context,
      tokens: t,
      hasError: hasError,
      focused: effectiveFocused,
      variant: variant,
      child: textField,
    );
    final singleLineControlHeight = _singleLineControlHeight(variant);
    final sizedInputShell = singleLineControlHeight == null
        ? inputShell
        : SizedBox(height: singleLineControlHeight, child: inputShell);

    if (showLabel) return sizedInputShell;
    return Semantics(label: _title, textField: true, child: sizedInputShell);
  }

  Widget _buildTextEntryMotion(BuildContext context, {required Widget child}) {
    return AnimatedSize(
      duration: _motionDuration(context),
      curve: CatchMotion.standardCurve,
      alignment: Alignment.topCenter,
      child: child,
    );
  }

  Duration _motionDuration(BuildContext context) {
    return _catchFieldMotionDuration(context);
  }

  Widget _buildSelectField(BuildContext context) {
    return FormField<Object?>(
      key: _selectFieldKey,
      initialValue: _normalizedSelectValue(widget._selectValue),
      validator: (value) =>
          widget._selectValidator?.call(_normalizedSelectValue(value)),
      enabled: widget.enabled,
      builder: (state) {
        final t = CatchTokens.of(context);
        final value = _normalizedSelectValue(state.value);
        if (state.value != value) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            final field = _selectFieldKey.currentState;
            if (field != null && field.value != value) {
              field.didChange(value);
            }
          });
        }
        final rawError = widget.errorText ?? widget.error ?? state.errorText;
        final error = rawError?.trim().isNotEmpty == true
            ? rawError!.trim()
            : null;
        final hasError = error != null;
        final supportText = error ?? widget.helperText;
        return _buildSelectTrigger(
          context: context,
          tokens: t,
          value: value,
          hasError: hasError,
          supportText: supportText,
          onChanged: widget.enabled && widget._onSelectChanged != null
              ? (next) {
                  state.didChange(next);
                  widget._onSelectChanged?.call(next);
                }
              : null,
        );
      },
    );
  }

  Widget _buildSelectTrigger({
    required BuildContext context,
    required CatchTokens tokens,
    required Object? value,
    required bool hasError,
    required String? supportText,
    required ValueChanged<Object?>? onChanged,
  }) {
    final values = widget._selectValues ?? const <Object?>[];
    final labelOf = widget._selectItemLabel!;
    final label = value == null ? null : labelOf(value);
    final canOpen = widget.enabled && onChanged != null && values.isNotEmpty;

    return LayoutBuilder(
      builder: (context, constraints) {
        final menuWidth = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : null;
        return MenuAnchor(
          controller: _menuController,
          // The panel itself is the shared CatchMenu surface; the anchor
          // chrome stays transparent (same contract as CatchActionMenu).
          style: const MenuStyle(
            backgroundColor: WidgetStatePropertyAll(Colors.transparent),
            elevation: WidgetStatePropertyAll(0),
            shadowColor: WidgetStatePropertyAll(Colors.transparent),
            surfaceTintColor: WidgetStatePropertyAll(Colors.transparent),
            padding: WidgetStatePropertyAll(EdgeInsets.zero),
          ),
          menuChildren: [
            CatchMenu<Object?>(
              width: menuWidth,
              items: [
                for (final item in values)
                  CatchMenuItem<Object?>(
                    value: item,
                    label: labelOf(item),
                    selected: item == value,
                  ),
              ],
              onSelected: (item, _) {
                onChanged?.call(item);
                _menuController.close();
              },
            ),
          ],
          builder: (context, controller, child) {
            final selectHasLabel =
                widget.showLabel && (_title?.trim().isNotEmpty ?? false);
            return Semantics(
              button: true,
              enabled: canOpen,
              label: _title,
              value: label,
              child: Focus(
                focusNode: _focusNode,
                child: CatchFieldRow.standard(
                  onTap: canOpen
                      ? () {
                          _focusNode.requestFocus();
                          controller.isOpen
                              ? controller.close()
                              : controller.open();
                        }
                      : null,
                  constraints: _rowConstraints,
                  padding: _rowPadding,
                  leading: _buildSelectLeadingSlot(tokens),
                  content: _buildFieldContent(
                    tokens,
                    label: widget.showLabel ? _title?.trim() : null,
                    value: label ?? widget.placeholder ?? 'Select',
                    supportText: supportText,
                    hasError: hasError,
                    valueIsPlaceholder: label == null,
                    labelStyle: CatchTextStyles.fieldLabel(
                      context,
                      color: hasError ? tokens.danger : tokens.ink3,
                    ),
                    valueStyle: CatchTextStyles.fieldRowTitle(
                      context,
                      color: label == null || !widget.enabled
                          ? tokens.ink3
                          : tokens.ink,
                    ),
                  ),
                  trailing: CatchFieldTrailing.rotatingChevron(
                    open: controller.isOpen,
                    color: tokens.ink3,
                    topPadding: selectHasLabel
                        ? CatchSpacing.micro18
                        : CatchSpacing.micro2,
                  ),
                ),
              ),
            );
          },
        );
      },
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
      duration: _motionDuration(context),
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

  EdgeInsets get _rowPadding {
    final flush = CatchFieldInsetScope.flushOf(context);
    if (_compactTextEntry) {
      return flush
          ? EdgeInsets.zero
          : const EdgeInsets.symmetric(horizontal: CatchSpacing.s1);
    }
    if (flush) {
      return const EdgeInsets.symmetric(vertical: CatchSpacing.micro14);
    }
    return const EdgeInsets.fromLTRB(
      CatchSpacing.s4,
      CatchSpacing.micro14,
      CatchSpacing.s4,
      CatchSpacing.micro14,
    );
  }

  BoxConstraints get _rowConstraints {
    if (_compactTextEntry) {
      return const BoxConstraints(
        minHeight: CatchControlMetrics.floatingMinHeight,
      );
    }
    if (_mode == CatchFieldMode.select && !widget.showLabel) {
      return BoxConstraints(
        minHeight: CatchControlMetrics.minHeight(_controlSize),
      );
    }
    return const BoxConstraints();
  }
}

Duration _catchFieldMotionDuration(BuildContext context) {
  final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
  return disableAnimations == true ? Duration.zero : CatchMotion.fast;
}

/// Ambient contract for who owns a field row's horizontal gutter.
///
/// By default a [CatchField] row insets itself horizontally so it can sit
/// directly on a background or inside an unpadded surface. A container that
/// owns the horizontal gutter itself (e.g. [CatchSection.divided]) publishes
/// `flush: true`, and every field row below it drops its own horizontal
/// inset so content, trailing affordances, and container-drawn dividers all
/// share the container's edges.
class CatchFieldInsetScope extends InheritedWidget {
  const CatchFieldInsetScope({
    super.key,
    required this.flush,
    required super.child,
  });

  final bool flush;

  static bool flushOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CatchFieldInsetScope>()
          ?.flush ??
      false;

  @override
  bool updateShouldNotify(CatchFieldInsetScope oldWidget) =>
      flush != oldWidget.flush;
}

class CatchFieldRow extends StatelessWidget {
  const CatchFieldRow.standard({
    super.key,
    required this.content,
    this.leading,
    this.trailing,
    this.onTap,
    this.constraints = const BoxConstraints(),
    this.padding = _defaultPadding,
  }) : leadingTopPadding = CatchSpacing.micro2,
       leadingGap = leadingSlotGap,
       trailingGap = CatchSpacing.s2;

  const CatchFieldRow.add({
    super.key,
    required this.leading,
    required this.content,
    this.onTap,
  }) : trailing = null,
       constraints = const BoxConstraints(),
       padding = const EdgeInsets.symmetric(
         horizontal: CatchSpacing.s4,
         vertical: CatchSpacing.micro14,
       ),
       leadingTopPadding = 0,
       leadingGap = leadingSlotGap,
       trailingGap = CatchSpacing.s2;

  /// Render size of icons in the leading slot.
  static const double leadingSlotIconSize = CatchIcon.md;

  /// Gap between the leading slot and the content lane.
  static const double leadingSlotGap = CatchSpacing.s3;

  /// Horizontal distance from the row's padded edge to where the content
  /// lane starts when a leading slot is present. Containers that draw
  /// text-lane-aligned dividers derive their indent from this instead of
  /// hardcoding it, so resizing the leading icon moves the dividers too.
  static const double textLaneInset = CatchLayout.fieldRowTextLaneInset;

  static const _defaultPadding = EdgeInsets.fromLTRB(
    CatchSpacing.s4,
    CatchSpacing.micro14,
    CatchSpacing.s4,
    CatchSpacing.micro14,
  );

  final Widget content;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry padding;
  final double leadingTopPadding;
  final double leadingGap;
  final double trailingGap;

  @override
  Widget build(BuildContext context) {
    final row = ConstrainedBox(
      constraints: constraints,
      child: Padding(
        padding: padding,
        child: LayoutBuilder(
          builder: (context, rowConstraints) {
            // The trailing slot is intrinsic so trailing affordances pin to
            // the row's trailing edge; the content lane owns all remaining
            // width. Capping the slot at half the row keeps long trailing
            // values from starving the content lane on narrow rows.
            final trailingMaxWidth = rowConstraints.hasBoundedWidth
                ? rowConstraints.maxWidth / 2
                : double.infinity;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (leading != null) ...[
                  Padding(
                    padding: EdgeInsets.only(top: leadingTopPadding),
                    child: leading,
                  ),
                  SizedBox(width: leadingGap),
                ],
                Expanded(child: content),
                if (trailing != null) ...[
                  SizedBox(width: trailingGap),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: trailingMaxWidth),
                    child: trailing,
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );

    if (onTap == null) return row;
    return CatchRowPressSurface(onTap: onTap, child: row);
  }
}

class CatchFieldTrailing extends StatelessWidget {
  factory CatchFieldTrailing.custom({
    Key? key,
    required Widget child,
    Color? color,
    double topPadding = CatchSpacing.micro2,
  }) {
    return CatchFieldTrailing._(
      key: key,
      topPadding: topPadding,
      builder: (context) {
        final t = CatchTokens.of(context);
        final resolvedColor = color ?? t.ink3;
        return IconTheme(
          data: IconThemeData(color: resolvedColor, size: CatchIcon.md),
          child: DefaultTextStyle.merge(
            style: CatchTextStyles.bodyLead(context, color: resolvedColor),
            child: child,
          ),
        );
      },
    );
  }

  factory CatchFieldTrailing.valueText({
    Key? key,
    required String text,
    int maxLines = 1,
    double topPadding = CatchSpacing.micro2,
  }) {
    return CatchFieldTrailing._(
      key: key,
      topPadding: topPadding,
      builder: (context) {
        final t = CatchTokens.of(context);
        return ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: CatchLayout.fieldTrailingValueMaxWidth,
          ),
          child: Text(
            text,
            textAlign: TextAlign.right,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.supporting(context, color: t.ink),
          ),
        );
      },
    );
  }

  factory CatchFieldTrailing.fixedChevron({
    Key? key,
    Color? color,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => Icon(
      CatchIcons.chevronRightRounded,
      size: CatchIcon.control,
      color: color ?? CatchTokens.of(context).ink3,
    ),
  );

  factory CatchFieldTrailing.rotatingChevron({
    Key? key,
    required bool open,
    Color? color,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => AnimatedRotation(
      turns: open ? 0.5 : 0,
      duration: _catchFieldMotionDuration(context),
      child: Icon(
        CatchIcons.expandMoreRounded,
        size: CatchIcon.control,
        color: color ?? CatchTokens.of(context).ink3,
      ),
    ),
  );

  factory CatchFieldTrailing.toggle({
    Key? key,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? semanticLabel,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (_) => CatchToggle(
      value: value,
      semanticLabel: semanticLabel,
      onChanged: onChanged,
    ),
  );

  factory CatchFieldTrailing.clear({
    Key? key,
    required String tooltip,
    required VoidCallback onPressed,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => IconButton(
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
      padding: EdgeInsets.zero,
      constraints: CatchControlMetrics.squareConstraints(CatchSpacing.s6),
      icon: Icon(
        CatchIcons.closeRounded,
        size: CatchIcon.xs,
        color: CatchTokens.of(context).ink3,
      ),
      onPressed: onPressed,
    ),
  );

  factory CatchFieldTrailing.valid({
    Key? key,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => Icon(
      CatchIcons.checkCircle,
      size: CatchIcon.md,
      color: CatchTokens.of(context).success,
    ),
  );

  const CatchFieldTrailing._({
    super.key,
    required this.builder,
    this.topPadding = CatchSpacing.micro2,
  });

  final WidgetBuilder builder;
  final double topPadding;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: topPadding),
    child: builder(context),
  );
}
