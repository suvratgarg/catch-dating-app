import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_option_card.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

part 'catch_field_control.dart';
part 'catch_field_configs.dart';
part 'catch_field_edit.dart';
part 'catch_field_lanes.dart';
part 'catch_field_row_modes.dart';
part 'catch_field_scopes.dart';
part 'catch_field_state.dart';

enum CatchFieldEmphasis { body, title }

enum CatchFieldTone { normal, primary, danger }

enum CatchFieldVariant { row, underline, bare }

enum CatchFieldSize { floating, compact, md }

enum CatchFieldSupportTone { neutral, brand, success }

/// Save status rendered in the canonical trailing or explicit-commit lane.
enum CatchFieldStatus { idle, saving, saved }

/// Design-system `Field`: the unified field primitive for row, text-entry,
/// navigation, toggle, disclosure-control, add, validation, and helper states.
/// Stack fields in a CatchSection when the surrounding section owns box or
/// divider chrome.
///
/// Each named constructor owns one sealed private configuration. Illegal mode
/// mixtures are therefore rejected by the type system:
///
/// ```dart
/// // Intentionally does not compile: toggle fields cannot own controllers.
/// CatchField.toggle(
///   title: 'Notifications',
///   value: true,
///   onChanged: null,
///   controller: TextEditingController(),
/// );
/// ```
abstract class CatchField extends StatefulWidget {
  const CatchField._shared({
    super.key,
    required this.title,
    this.body,
    this.action,
    this.emphasis = CatchFieldEmphasis.body,
    this.tone = CatchFieldTone.normal,
    this.variant = CatchFieldVariant.row,
    this.icon,
    this.iconColor,
    this.leading,
    this.leadingExtent,
    this.divider = false,
    this.enabled = true,
    this.status = CatchFieldStatus.idle,
  });

  const factory CatchField.read({
    Key? key,
    String? title,
    String? body,
    Widget? action,
    int titleMaxLines,
    int bodyMaxLines,
    CatchFieldEmphasis emphasis,
    CatchFieldTone tone,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    double? leadingExtent,
    String? valueText,
    int valueMaxLines,
    String? placeholder,
    bool valid,
    CatchFieldStatus status,
    bool divider,
  }) = _RowConfig.read;

  /// A natural-height title plus supporting-copy row.
  ///
  /// The React handoff calls its supporting copy `body`, while legacy Flutter
  /// CatchField rows use [body] as their primary value. Keeping this as an
  /// explicit constructor preserves those existing value rows while exposing
  /// the handoff's independent two-line title and three-line body contract.
  const factory CatchField.content({
    Key? key,
    required String title,
    required String body,
    Widget? action,
    VoidCallback? onTap,
    int titleMaxLines,
    int bodyMaxLines,
    CatchFieldEmphasis emphasis,
    CatchFieldTone tone,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    double? leadingExtent,
    String? valueText,
    int valueMaxLines,
    bool? showChevron,
    bool isOptional,
    bool valid,
    CatchFieldStatus status,
    bool divider,
  }) = _RowConfig.content;

  const factory CatchField.nav({
    Key? key,
    String? title,
    String? body,
    Widget? action,
    VoidCallback? onTap,
    int titleMaxLines,
    int bodyMaxLines,
    CatchFieldEmphasis emphasis,
    CatchFieldTone tone,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    double? leadingExtent,
    String? valueText,
    int valueMaxLines,
    bool? showChevron,
    String? placeholder,
    String? error,
    String? errorText,
    bool valid,
    CatchFieldStatus status,
    bool divider,
  }) = _RowConfig.nav;

  /// A tappable field-shaped row whose action does not navigate or edit the
  /// value. Unlike [CatchField.nav], this constructor never renders a chevron.
  const factory CatchField.action({
    Key? key,
    String? title,
    String? body,
    Widget? action,
    required VoidCallback? onTap,
    int titleMaxLines,
    int bodyMaxLines,
    CatchFieldEmphasis emphasis,
    CatchFieldTone tone,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    double? leadingExtent,
    String? valueText,
    int valueMaxLines,
    String? placeholder,
    String? error,
    String? errorText,
    bool valid,
    CatchFieldStatus status,
    bool divider,
  }) = _RowConfig.action;

  const factory CatchField.toggle({
    Key? key,
    String? title,
    String? body,
    required bool value,
    required ValueChanged<bool>? onChanged,
    int titleMaxLines,
    int bodyMaxLines,
    CatchFieldEmphasis emphasis,
    CatchFieldTone tone,
    IconData? icon,
    Color? iconColor,
    String? helperText,
    String? badgeLabel,
    CatchBadgeTone? badgeTone,
    CatchFieldStatus status,
    bool divider,
  }) = _ToggleConfig.toggle;

  const factory CatchField.input({
    Key? key,
    required String title,
    String? placeholder,
    String? emptyValueText,
    String? inputHint,
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onBlur,
    ValueChanged<bool>? onFocusChanged,
    FocusNode? focusNode,
    bool retainFocusOnSubmitted,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    bool obscureText,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool readOnly,
    bool autofocus,
    bool enabled,
    bool isOptional,
    bool showLabel,
    String? helperText,
    CatchFieldSupportTone helperTone,
    CatchFieldSize size,
    TextAlign textAlign,
    bool focused,
    CatchFieldStatus status,
    bool mono,
    Widget? prefixIcon,
    String? prefixText,
    Widget? suffixIcon,
    String? suffixText,
    bool showClearButton,
    bool floatingLabel,
    CatchFieldVariant variant,
    IconData? icon,
    Color? iconColor,
    String? leadingUnit,
    Widget? action,
    String? error,
    String? errorText,
    bool divider,
    VoidCallback? onTap,
  }) = _EditConfig.input;

  /// A row-owned disclosure control. The row remains stable while [control]
  /// reveals below it. Use [open] for caller-owned edit flows or
  /// [initiallyOpen] for local disclosure state. Save and error state remain
  /// caller-owned.
  const factory CatchField.control({
    Key? key,
    required String title,
    String? body,
    required Widget control,
    bool? open,
    bool initiallyOpen,
    ValueChanged<bool>? onOpenChanged,
    VoidCallback? onCancel,
    VoidCallback? onSubmit,
    bool isLoading,
    CatchFieldStatus status,
    bool enabled,
    bool addable,
    bool isOptional,
    String? helperText,
    int titleMaxLines,
    int bodyMaxLines,
    CatchFieldEmphasis emphasis,
    CatchFieldTone tone,
    IconData? icon,
    Color? iconColor,
    String? placeholder,
    String? emptyValueText,
    String? error,
    String? errorText,
    bool divider,
  }) = _ControlConfig.control;

  /// Canonical disclosure field for a wrapping set of single- or multi-select
  /// options. Selection state stays caller-owned; this method owns the exact
  /// chip geometry, wrapping, press motion, and field commit bar.
  static CatchField choices<T>({
    Key? key,
    required String title,
    String? body,
    required List<T> values,
    required String Function(T value) itemLabel,
    required Set<T> selected,
    required ValueChanged<Set<T>>? onSelectionChanged,
    bool multi = false,
    bool allowEmptySelection = false,
    bool? open,
    bool initiallyOpen = false,
    ValueChanged<bool>? onOpenChanged,
    VoidCallback? onCancel,
    VoidCallback? onSubmit,
    bool isLoading = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    bool enabled = true,
    bool addable = false,
    bool isOptional = false,
    String? helperText,
    Color? Function(T item)? itemAccent,
    IconData? icon,
    Color? iconColor,
    CatchFieldTone tone = CatchFieldTone.normal,
    String? emptyValueText,
    String? error,
    String? errorText,
    bool divider = false,
  }) {
    final selectedSummary = values
        .where(selected.contains)
        .map(itemLabel)
        .join(' · ');
    return CatchField.control(
      key: key,
      title: title,
      body: body ?? (selectedSummary.isEmpty ? null : selectedSummary),
      control: CatchFieldChoiceControl<T>(
        values: values,
        itemLabel: itemLabel,
        selected: selected,
        multi: multi,
        allowEmptySelection: allowEmptySelection,
        autoClose: !multi && onSubmit == null,
        enabled: !isLoading,
        itemAccent: itemAccent,
        onSelectionChanged: onSelectionChanged,
      ),
      open: open,
      initiallyOpen: initiallyOpen,
      onOpenChanged: onOpenChanged,
      onCancel: onCancel,
      onSubmit: onSubmit,
      isLoading: isLoading,
      status: status,
      enabled: enabled,
      addable: addable,
      isOptional: isOptional,
      helperText: helperText,
      icon: icon,
      iconColor: iconColor,
      tone: tone,
      emptyValueText: emptyValueText,
      error: error,
      errorText: errorText,
      divider: divider,
    );
  }

  /// Canonical single-select disclosure for choices that need both a title
  /// and explanatory copy. Terse labels stay in [choices]; policy, admission,
  /// and setup choices use the existing [CatchOptionCard] primitive through
  /// this field-owned facade.
  static CatchField optionCards<T>({
    Key? key,
    required String title,
    String? body,
    required List<T> values,
    required String Function(T value) itemTitle,
    required String Function(T value) itemDescription,
    required T selected,
    required ValueChanged<T>? onChanged,
    bool? open,
    bool initiallyOpen = false,
    ValueChanged<bool>? onOpenChanged,
    VoidCallback? onCancel,
    VoidCallback? onSubmit,
    bool isLoading = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    bool enabled = true,
    String? helperText,
    IconData? icon,
    Color? iconColor,
    CatchFieldTone tone = CatchFieldTone.normal,
    String? error,
    String? errorText,
    bool divider = false,
  }) {
    assert(
      values.isNotEmpty,
      'CatchField.optionCards needs at least one value.',
    );
    assert(
      values.contains(selected),
      'CatchField.optionCards selected must be present in values.',
    );
    return CatchField.control(
      key: key,
      title: title,
      body: body ?? itemTitle(selected),
      control: CatchFieldOptionCardControl<T>(
        values: values,
        itemTitle: itemTitle,
        itemDescription: itemDescription,
        selected: selected,
        autoClose: onSubmit == null,
        enabled: enabled && !isLoading,
        onChanged: onChanged,
      ),
      open: open,
      initiallyOpen: initiallyOpen,
      onOpenChanged: onOpenChanged,
      onCancel: onCancel,
      onSubmit: onSubmit,
      isLoading: isLoading,
      status: status,
      enabled: enabled,
      helperText: helperText,
      icon: icon,
      iconColor: iconColor,
      tone: tone,
      error: error,
      errorText: errorText,
      divider: divider,
    );
  }

  /// Canonical numeric disclosure field. The revealed control includes a
  /// centered value and accelerated hold-to-repeat on both 44px targets.
  static CatchField stepper({
    Key? key,
    required String title,
    String? body,
    required num value,
    required ValueChanged<num>? onChanged,
    num? min,
    num? max,
    num step = 1,
    String? unit,
    String Function(num value)? formatter,
    required String decreaseSemanticLabel,
    required String increaseSemanticLabel,
    bool? open,
    bool initiallyOpen = false,
    ValueChanged<bool>? onOpenChanged,
    VoidCallback? onCancel,
    VoidCallback? onSubmit,
    bool isLoading = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    bool enabled = true,
    bool addable = false,
    bool isOptional = false,
    IconData? icon,
    Color? iconColor,
    CatchFieldTone tone = CatchFieldTone.normal,
    String? emptyValueText,
    String? error,
    String? errorText,
    bool divider = false,
  }) {
    assert(step > 0, 'CatchField.stepper requires a positive step.');
    return CatchField.control(
      key: key,
      title: title,
      body: body,
      control: CatchFieldStepper(
        value: value,
        min: min,
        max: max,
        step: step,
        unit: unit,
        formatter: formatter,
        decreaseSemanticLabel: decreaseSemanticLabel,
        increaseSemanticLabel: increaseSemanticLabel,
        enabled: !isLoading,
        onChanged: onChanged,
      ),
      open: open,
      initiallyOpen: initiallyOpen,
      onOpenChanged: onOpenChanged,
      onCancel: onCancel,
      onSubmit: onSubmit,
      isLoading: isLoading,
      status: status,
      enabled: enabled,
      addable: addable,
      isOptional: isOptional,
      icon: icon,
      iconColor: iconColor,
      tone: tone,
      emptyValueText: emptyValueText,
      error: error,
      errorText: errorText,
      divider: divider,
    );
  }

  /// A controlled, explicit-save row editor. The label and value lane stay in
  /// place while supporting content and commit actions animate below them.
  /// Trailing edit affordances, focus timing, typography, and content order are
  /// owned by this primitive rather than by feature call sites.
  const factory CatchField.inputActions({
    Key? key,
    required String title,
    required TextEditingController controller,
    required bool open,
    required ValueChanged<bool> onOpenChanged,
    required VoidCallback onCancel,
    required VoidCallback onSubmit,
    String? placeholder,
    String? emptyValueText,
    String? inputHint,
    Widget? supporting,
    Widget? secondaryAction,
    Widget? feedback,
    bool isLoading,
    CatchFieldStatus status,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    int? maxLines,
    int? minLines,
    int? maxLength,
    bool enabled,
    IconData? icon,
    Color? iconColor,
    CatchFieldTone tone,
    String? error,
    bool divider,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onBlur,
    ValueChanged<bool>? onFocusChanged,
    FocusNode? focusNode,
  }) = _EditConfig.inputActions;

  const factory CatchField.add({
    Key? key,
    required String title,
    VoidCallback? onTap,
    IconData? icon,
    CatchFieldTone tone,
  }) = _RowConfig.add;

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
    return _SelectConfig.select(
      key: key,
      title: title,
      values: List<Object?>.unmodifiable(values),
      itemLabel: (item) => itemLabel(item as T),
      value: value,
      onSelectChanged: onChanged == null
          ? null
          : (item) => onChanged(item as T?),
      selectValidator: validator == null
          ? null
          : (item) => validator(item as T?),
      placeholder: hintText,
      prefixIcon: prefixIcon,
      showLabel: showLabel,
      size: size,
      helperText: helperText,
      helperTone: helperTone,
      enabled: enabled,
    );
  }

  static const double compactControlHeight =
      CatchControlMetrics.compactMinHeight;
  static const double mdControlHeight = CatchControlMetrics.mdMinHeight;

  /// Canonical at-rest copy for an empty editable row.
  static String defaultEmptyValueText(BuildContext context, String title) {
    final l10n = context.l10n;
    final label = title.trim();
    final fieldLabel = l10n.localeName.startsWith('en')
        ? label.toLowerCase()
        : label;
    return l10n.coreCatchFieldVisiblecopyAddFieldLabel(fieldLabel: fieldLabel);
  }

  /// Resolves an optional domain override without repeating the field label.
  static String resolveEmptyValueText(
    BuildContext context, {
    required String title,
    String? emptyValueText,
  }) {
    final label = title.trim();
    final explicit = emptyValueText?.trim();
    if (explicit != null &&
        explicit.isNotEmpty &&
        explicit.toLowerCase() != label.toLowerCase()) {
      return explicit;
    }
    return defaultEmptyValueText(context, label);
  }

  /// Primary row text or input label.
  final String? title;

  /// Supporting row text.
  final String? body;

  /// End-aligned row action or input suffix.
  final Widget? action;

  _CatchFieldConfig get _config => this as _CatchFieldConfig;
  final CatchFieldEmphasis emphasis;
  final CatchFieldTone tone;
  final CatchFieldVariant variant;
  final IconData? icon;
  final Color? iconColor;

  /// Caller-owned leading content used instead of [icon].
  final Widget? leading;

  /// Horizontal extent of caller-owned [leading] content. Sections use this
  /// to align dividers to the actual text lane instead of assuming icon size.
  final double? leadingExtent;
  final bool divider;
  final bool enabled;
  final CatchFieldStatus status;

  _RowConfig? get _rowConfig => switch (_config) {
    final _RowConfig config => config,
    _ => null,
  };
  _ToggleConfig? get _toggleConfig => switch (_config) {
    final _ToggleConfig config => config,
    _ => null,
  };
  _EditConfig? get _editConfig => switch (_config) {
    final _EditConfig config => config,
    _ => null,
  };
  _SelectConfig? get _selectConfig => switch (_config) {
    final _SelectConfig config => config,
    _ => null,
  };
  _ControlConfig? get _controlConfig => switch (_config) {
    final _ControlConfig config => config,
    _ => null,
  };

  /// End-aligned text for compact read and navigation rows.
  String? get valueText => _rowConfig?.valueText;
  int get valueMaxLines => _rowConfig?.valueMaxLines ?? 1;
  int get titleMaxLines => switch (_config) {
    final _RowConfig config => config.titleMaxLines,
    final _ToggleConfig config => config.titleMaxLines,
    final _ControlConfig config => config.titleMaxLines,
    _ => 1,
  };
  int get bodyMaxLines => switch (_config) {
    final _RowConfig config => config.bodyMaxLines,
    final _ToggleConfig config => config.bodyMaxLines,
    final _ControlConfig config => config.bodyMaxLines,
    _ => 2,
  };
  bool get _contentRow => _rowConfig?.contentRow ?? false;
  String? get leadingUnit => _editConfig?.leadingUnit;
  bool? get showChevron => _rowConfig?.showChevron;

  String? get placeholder => switch (_config) {
    final _RowConfig config => config.placeholder,
    final _EditConfig config => config.placeholder,
    final _SelectConfig config => config.placeholder,
    final _ControlConfig config => config.placeholder,
    _ => null,
  };
  String? get emptyValueText => switch (_config) {
    final _EditConfig config => config.emptyValueText,
    final _ControlConfig config => config.emptyValueText,
    _ => null,
  };
  String? get inputHint => _editConfig?.inputHint;
  bool get toggled => _toggleConfig?.value ?? false;
  ValueChanged<bool>? get onToggle => _toggleConfig?.onToggleChanged;

  /// Control revealed by a navigation-mode disclosure field.
  Widget? get control => _controlConfig?.control;
  bool get initiallyOpen => _controlConfig?.initiallyOpen ?? false;

  /// Caller-owned disclosure state; null keeps expansion local.
  bool? get open => _controlConfig?.open ?? _editConfig?.open;
  ValueChanged<bool>? get onOpenChanged =>
      _controlConfig?.onOpenChanged ?? _editConfig?.onOpenChanged;
  bool get _explicitSaveInput => _editConfig?.explicitSave ?? false;
  Widget? get _supporting => _editConfig?.supporting;
  Widget? get _secondaryAction => _editConfig?.secondaryAction;
  Widget? get _feedback => _editConfig?.feedback;

  bool get usesExplicitSave => _explicitSaveInput;
  bool get add => _rowConfig?.add ?? false;
  bool get addable => _controlConfig?.addable ?? false;
  String? get error => switch (_config) {
    final _RowConfig config => config.error,
    final _EditConfig config => config.error,
    final _ControlConfig config => config.error,
    _ => null,
  };
  String? get errorText => switch (_config) {
    final _RowConfig config => config.errorText,
    final _EditConfig config => config.errorText,
    final _ControlConfig config => config.errorText,
    _ => null,
  };
  bool get valid => _rowConfig?.valid ?? false;
  VoidCallback? get onTap => _rowConfig?.onTap ?? _editConfig?.onTap;

  _EditConfig? get _inputConfig => _editConfig;
  TextEditingController? get controller => _inputConfig?.controller;
  String? get initialValue => _inputConfig?.initialValue;
  ValueChanged<String>? get onChanged => _inputConfig?.onChanged;
  ValueChanged<String>? get onSubmitted => _inputConfig?.onSubmitted;
  ValueChanged<String>? get onBlur => _inputConfig?.onBlur;
  ValueChanged<bool>? get onFocusChanged => _inputConfig?.onFocusChanged;
  FocusNode? get focusNode => _inputConfig?.focusNode;
  bool get retainFocusOnSubmitted =>
      _inputConfig?.retainFocusOnSubmitted ?? false;
  FormFieldValidator<String>? get validator => _inputConfig?.validator;
  TextInputType? get keyboardType => _inputConfig?.keyboardType;
  TextInputAction? get textInputAction => _inputConfig?.textInputAction;
  TextCapitalization get textCapitalization =>
      _inputConfig?.textCapitalization ?? TextCapitalization.none;
  List<TextInputFormatter>? get inputFormatters =>
      _inputConfig?.inputFormatters;
  Iterable<String>? get autofillHints => _inputConfig?.autofillHints;
  bool get obscureText => _inputConfig?.obscureText ?? false;
  int? get maxLines => _inputConfig == null ? 1 : _inputConfig!.maxLines;
  int? get minLines => _inputConfig?.minLines;
  int? get maxLength => _inputConfig?.maxLength;
  bool get readOnly => _inputConfig?.readOnly ?? false;
  bool get autofocus => _inputConfig?.autofocus ?? false;
  bool get isOptional => switch (_config) {
    final _RowConfig config => config.isOptional,
    final _EditConfig config => config.isOptional,
    final _ControlConfig config => config.isOptional,
    _ => false,
  };
  bool get showLabel => switch (_config) {
    final _EditConfig config => config.showLabel,
    final _SelectConfig config => config.showLabel,
    _ => true,
  };
  String? get helperText => switch (_config) {
    final _ToggleConfig config => config.helperText,
    final _EditConfig config => config.helperText,
    final _SelectConfig config => config.helperText,
    final _ControlConfig config => config.helperText,
    _ => null,
  };
  CatchFieldSupportTone get helperTone => switch (_config) {
    final _EditConfig config => config.helperTone,
    final _SelectConfig config => config.helperTone,
    _ => CatchFieldSupportTone.neutral,
  };
  String? get badgeLabel => _toggleConfig?.badgeLabel;
  CatchBadgeTone? get badgeTone => _toggleConfig?.badgeTone;
  CatchFieldSize get size => switch (_config) {
    final _EditConfig config => config.size,
    final _SelectConfig config => config.size,
    _ => CatchFieldSize.md,
  };
  TextAlign get textAlign => _inputConfig?.textAlign ?? TextAlign.start;
  bool get focused => _editConfig?.focused ?? false;
  bool get mono => _inputConfig?.mono ?? false;
  Widget? get prefixIcon =>
      _inputConfig?.prefixIcon ?? _selectConfig?.prefixIcon;
  String? get prefixText => _inputConfig?.prefixText;
  Widget? get suffixIcon => _inputConfig?.suffixIcon;
  String? get suffixText => _inputConfig?.suffixText;
  bool get showClearButton => _inputConfig?.showClearButton ?? false;
  bool get floatingLabel => _inputConfig?.floatingLabel ?? true;

  List<Object?>? get _selectValues => _selectConfig?.values;
  String Function(Object? item)? get _selectItemLabel =>
      _selectConfig?.itemLabel;
  Object? get _selectValue => _selectConfig?.value;
  ValueChanged<Object?>? get _onSelectChanged => _selectConfig?.onSelectChanged;
  FormFieldValidator<Object?>? get _selectValidator =>
      _selectConfig?.selectValidator;

  VoidCallback? get _onCancel =>
      _controlConfig?.onCancel ?? _editConfig?.onCancel;
  VoidCallback? get _onSubmit =>
      _controlConfig?.onSubmit ?? _editConfig?.onSubmit;
  bool get _closeLocallyOnSubmit => true;
  bool get _isLoading =>
      _controlConfig?.isLoading ?? _editConfig?.isLoading ?? false;

  /// Private per-mode implementations retain one public widget identity so
  /// Flutter preserves [_CatchFieldState] when a keyed field changes mode.
  @override
  Type get runtimeType => CatchField;

  @override
  State<CatchField> createState() => _CatchFieldState();
}
