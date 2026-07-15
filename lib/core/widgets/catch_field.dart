import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum CatchFieldMode { edit, read, nav, toggle, select }

enum CatchFieldEmphasis { body, title }

enum CatchFieldTone { normal, primary, danger }

enum CatchFieldVariant { row, underline, bare }

enum CatchFieldSize { floating, compact, md }

enum CatchFieldSupportTone { neutral, brand, success }

/// Save-state affordance rendered in the canonical field trailing lane.
enum CatchFieldStatus { idle, saving, saved }

class _CatchFieldDismissIntent extends Intent {
  const _CatchFieldDismissIntent();
}

class _CatchFieldChoicePickedNotification extends Notification {
  const _CatchFieldChoicePickedNotification({required this.autoClose});

  final bool autoClose;
}

/// Design-system `Field`: the unified field primitive for row, text-entry,
/// navigation, toggle, disclosure-control, add, validation, and helper states.
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
    this._contentRow = false,
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
    this.emptyValueText,
    this.inputHint,
    this.toggled = false,
    this.onToggle,
    this.control,
    this.initiallyOpen = false,
    this.open,
    this.onOpenChanged,
    this._explicitSaveInput = false,
    this._supporting,
    this._secondaryAction,
    this._feedback,
    this.add = false,
    this.addable = false,
    this.error,
    this.errorText,
    this.valid = false,
    this.divider = false,
    this.onTap,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onBlur,
    this.onFocusChanged,
    this.focusNode,
    this.retainFocusOnSubmitted = false,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autofillHints,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
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
    this._closeLocallyOnSubmit = true,
    this._isLoading = false,
    this._actionLeading,
    this.status = CatchFieldStatus.idle,
  }) : assert(
         mode != CatchFieldMode.select ||
             (_selectValues != null && _selectItemLabel != null),
         'Use CatchField.select to build select fields.',
       ),
       assert(
         inputHint == null || placeholder == null,
         'Use inputHint for editable fields; do not also pass placeholder.',
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
    CatchFieldStatus status = CatchFieldStatus.idle,
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
         status: status,
         divider: divider,
       );

  /// A natural-height title plus supporting-copy row.
  ///
  /// The React handoff calls its supporting copy `body`, while legacy Flutter
  /// CatchField rows use [body] as their primary value. Keeping this as an
  /// explicit constructor preserves those existing value rows while exposing
  /// the handoff's independent two-line title and three-line body contract.
  const CatchField.content({
    Key? key,
    required String title,
    required String body,
    Widget? action,
    VoidCallback? onTap,
    int titleMaxLines = 2,
    int bodyMaxLines = 3,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    String? valueText,
    int valueMaxLines = 1,
    bool? showChevron,
    bool isOptional = false,
    bool valid = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    bool divider = false,
  }) : this._(
         key: key,
         title: title,
         body: body,
         action: action,
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         contentRow: true,
         mode: onTap == null ? CatchFieldMode.read : CatchFieldMode.nav,
         emphasis: emphasis,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         valueText: valueText,
         valueMaxLines: valueMaxLines,
         showChevron: showChevron,
         isOptional: isOptional,
         valid: valid,
         status: status,
         divider: divider,
         onTap: onTap,
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
    CatchFieldStatus status = CatchFieldStatus.idle,
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
         status: status,
         divider: divider,
         onTap: onTap,
       );

  /// A tappable field-shaped row whose action does not navigate or edit the
  /// value. Unlike [CatchField.nav], this constructor never renders a chevron.
  const CatchField.action({
    Key? key,
    String? title,
    String? body,
    Widget? action,
    required VoidCallback? onTap,
    int titleMaxLines = 1,
    int bodyMaxLines = 2,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    String? valueText,
    int valueMaxLines = 1,
    String? placeholder,
    String? error,
    String? errorText,
    bool valid = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
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
         error: error,
         errorText: errorText,
         valid: valid,
         status: status,
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
    CatchFieldStatus status = CatchFieldStatus.idle,
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
         status: status,
         divider: divider,
       );

  const CatchField.input({
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
    bool retainFocusOnSubmitted = false,
    FormFieldValidator<String>? validator,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    bool obscureText = false,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
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
    CatchFieldStatus status = CatchFieldStatus.idle,
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
         emptyValueText: emptyValueText,
         inputHint: inputHint,
         error: error,
         errorText: errorText,
         divider: divider,
         onTap: onTap,
         controller: controller,
         initialValue: initialValue,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         onBlur: onBlur,
         onFocusChanged: onFocusChanged,
         focusNode: focusNode,
         retainFocusOnSubmitted: retainFocusOnSubmitted,
         validator: validator,
         keyboardType: keyboardType,
         textInputAction: textInputAction,
         textCapitalization: textCapitalization,
         inputFormatters: inputFormatters,
         autofillHints: autofillHints,
         obscureText: obscureText,
         maxLines: maxLines,
         minLines: minLines,
         maxLength: maxLength,
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
         status: status,
         mono: mono,
         prefixIcon: prefixIcon,
         prefixText: prefixText,
         suffixIcon: suffixIcon,
         suffixText: suffixText,
         showClearButton: showClearButton,
         floatingLabel: floatingLabel,
       );

  /// A row-owned disclosure control. The row remains stable while [control]
  /// reveals below it. Use [open] for caller-owned edit flows or
  /// [initiallyOpen] for local disclosure state. Save and error state remain
  /// caller-owned.
  const CatchField.control({
    Key? key,
    required String title,
    String? body,
    required Widget control,
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
    int titleMaxLines = 1,
    int bodyMaxLines = 2,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    String? placeholder,
    String? emptyValueText,
    String? error,
    String? errorText,
    bool divider = false,
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
         emptyValueText: emptyValueText,
         control: control,
         initiallyOpen: initiallyOpen,
         open: open,
         onOpenChanged: onOpenChanged,
         error: error,
         errorText: errorText,
         divider: divider,
         onCancel: onCancel,
         onSubmit: onSubmit,
         isLoading: isLoading,
         status: status,
         enabled: enabled,
         addable: addable,
         isOptional: isOptional,
       );

  /// Deprecated source-compatible adapter for the pre-handoff disclosure API.
  ///
  /// New code should use [CatchField.control], which also supports controlled
  /// expansion and commit actions. This constructor intentionally routes to
  /// the same canonical renderer so retaining source compatibility does not
  /// create a second visual implementation.
  @Deprecated('Use CatchField.control instead.')
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
         initiallyOpen: initiallyExpanded,
         error: error,
         errorText: errorText,
         divider: divider,
         onTap: onTap,
       );

  /// Backwards-compatible explicit-save disclosure field.
  ///
  /// This preserves the original public contract while routing its rendering
  /// through the canonical control disclosure and commit-bar implementation.
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
         initiallyOpen: initiallyExpanded,
         error: error,
         errorText: errorText,
         divider: divider,
         onTap: onTap,
         onCancel: onCancel,
         onSubmit: onSubmit,
         closeLocallyOnSubmit: false,
         isLoading: isLoading,
         actionLeading: actionLeading,
       );

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
      icon: icon,
      iconColor: iconColor,
      tone: tone,
      emptyValueText: emptyValueText,
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
  const CatchField.inputActions({
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
    bool isLoading = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    bool enabled = true,
    IconData? icon,
    Color? iconColor,
    CatchFieldTone tone = CatchFieldTone.normal,
    String? error,
    bool divider = false,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onBlur,
    ValueChanged<bool>? onFocusChanged,
    FocusNode? focusNode,
  }) : this._(
         key: key,
         title: title,
         mode: CatchFieldMode.edit,
         variant: CatchFieldVariant.row,
         icon: icon,
         iconColor: iconColor,
         tone: tone,
         placeholder: placeholder,
         emptyValueText: emptyValueText,
         inputHint: inputHint,
         controller: controller,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         onBlur: onBlur,
         onFocusChanged: onFocusChanged,
         focusNode: focusNode,
         keyboardType: keyboardType,
         textInputAction: textInputAction,
         textCapitalization: textCapitalization,
         inputFormatters: inputFormatters,
         autofillHints: autofillHints,
         maxLines: maxLines,
         minLines: minLines,
         maxLength: maxLength,
         enabled: enabled,
         floatingLabel: false,
         error: error,
         divider: divider,
         open: open,
         onOpenChanged: onOpenChanged,
         explicitSaveInput: true,
         supporting: supporting,
         secondaryAction: secondaryAction,
         feedback: feedback,
         onCancel: onCancel,
         onSubmit: onSubmit,
         isLoading: isLoading,
         status: status,
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
      placeholder: hintText,
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

  /// Canonical at-rest copy for an empty editable row.
  static String defaultEmptyValueText(BuildContext context, String title) {
    final l10n = context.l10n;
    final label = title.trim();
    final fieldLabel = l10n.localeName.startsWith('en')
        ? label.toLowerCase()
        : label;
    return l10n.coreCatchFieldVisiblecopyAddFieldLabel(fieldLabel: fieldLabel);
  }

  /// Resolves an optional domain override without allowing it to collapse back
  /// to a duplicate of the field label.
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

  /// End-aligned row action or input suffix widget.
  final Widget? action;

  /// End-aligned text lane for compact read/nav rows. Use [body] for text
  /// beneath the title; use [valueText] for settings-style metadata on the
  /// right edge.
  final String? valueText;

  final int valueMaxLines;

  final int titleMaxLines;
  final int bodyMaxLines;
  final bool _contentRow;

  final CatchFieldMode? mode;
  final CatchFieldEmphasis emphasis;
  final CatchFieldTone tone;
  final CatchFieldVariant variant;
  final IconData? icon;
  final Color? iconColor;
  final String? leadingUnit;
  final bool? showChevron;

  /// Legacy empty/read fallback and text-entry hint. New editable-row callers
  /// should use [emptyValueText] and [inputHint] so display and entry semantics
  /// cannot drift together.
  final String? placeholder;

  /// Text rendered in an empty editable row while it is at rest. When omitted,
  /// editable row constructors derive `Add <lowercase title>`.
  final String? emptyValueText;

  /// Concise example or instruction rendered only inside an active text input.
  /// A value that merely repeats [title] is suppressed.
  final String? inputHint;
  final bool toggled;
  final ValueChanged<bool>? onToggle;

  /// A control (Stepper / Chips / OptionCards) revealed on tap; the value shows
  /// as text at rest.
  final Widget? control;
  final bool initiallyOpen;

  /// Caller-owned disclosure state. When null, CatchField owns local state
  /// initialized from [initiallyOpen].
  final bool? open;

  /// Reports disclosure changes in both controlled and local-state modes.
  final ValueChanged<bool>? onOpenChanged;
  final bool _explicitSaveInput;
  final Widget? _supporting;
  final Widget? _secondaryAction;
  final Widget? _feedback;

  /// Whether this field owns an explicit-save text-entry flow.
  bool get usesExplicitSave => _explicitSaveInput;
  final bool add;
  final bool addable;
  final String? error;
  final String? errorText;
  final bool valid;
  final bool divider;
  final VoidCallback? onTap;

  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onBlur;
  final ValueChanged<bool>? onFocusChanged;
  final FocusNode? focusNode;
  final bool retainFocusOnSubmitted;
  final FormFieldValidator<String>? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
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
  final bool _closeLocallyOnSubmit;
  final bool _isLoading;
  final Widget? _actionLeading;
  final CatchFieldStatus status;

  @override
  State<CatchField> createState() => _CatchFieldState();
}

class _CatchFieldState extends State<CatchField>
    with SingleTickerProviderStateMixin {
  final _fieldKey = GlobalKey<FormFieldState<String>>();
  final _selectFieldKey = GlobalKey<FormFieldState<Object?>>();
  final _disclosureRevealTargetKey = GlobalKey();
  final _actionBarRevealTargetKey = GlobalKey();
  final _menuController = MenuController();
  final Object _tapRegionGroup = Object();
  final FocusNode _rowFocusNode = FocusNode(debugLabel: 'CatchField row');
  late FocusNode _focusNode;
  late bool _ownsFocusNode;
  late final TextEditingController _internalController;
  TextEditingController? _listenedController;

  bool _focused = false;
  bool _rowFocused = false;
  bool _pressed = false;
  int? _pressedPointer;
  Offset? _pressedDownPosition;
  int? _outsidePointer;
  Offset? _outsideDownPosition;
  late bool _open;
  late bool _disclosureOffstage;
  bool _pendingExpansionFocus = false;
  bool _expandedContentRevealScheduled = false;
  late final AnimationController _expandedContentRevealController;
  ScrollPosition? _activeExpandedContentRevealPosition;
  double _expandedContentRevealStart = 0;
  double _expandedContentRevealDestination = 0;
  Timer? _singleChoiceCloseTimer;
  late bool _inputWasEmpty;
  bool _textEntryHasValidationError = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _expandedContentRevealController = AnimationController(vsync: this)
      ..addListener(_handleExpandedContentRevealTick)
      ..addStatusListener(_handleExpandedContentRevealStatus);
    _open = widget.open ?? (widget.initiallyOpen && widget.control != null);
    _disclosureOffstage = !_isOpen;
    _attachFocusNode(widget.focusNode);
    _internalController = TextEditingController(
      text: widget.controller == null ? widget.initialValue : null,
    );
    _inputWasEmpty = _controller.text.isEmpty;
    _attachControllerListener(_controller);
    if (widget._explicitSaveInput && _isOpen) {
      _pendingExpansionFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _requestPendingExpansionFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant CatchField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _detachFocusNode();
      _attachFocusNode(widget.focusNode);
    }
    final wasOpen = oldWidget.open ?? _open;
    if (oldWidget.control != widget.control &&
        widget.control == null &&
        !widget._explicitSaveInput) {
      _open = false;
    } else if (widget.open != null) {
      _open = widget.open!;
    } else if (oldWidget.open != null) {
      _open = oldWidget.open!;
    } else if (oldWidget.initiallyOpen != widget.initiallyOpen) {
      _open = widget.initiallyOpen && widget.control != null;
    }
    final isOpen = _isOpen;
    if (!wasOpen && isOpen) {
      _disclosureOffstage = false;
      _scheduleExpandedContentReveal();
    } else if (wasOpen && !isOpen) {
      _cancelExpandedContentReveal();
    }
    if (widget._explicitSaveInput && !wasOpen && isOpen) {
      _pendingExpansionFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _requestPendingExpansionFocus();
      });
    } else if (wasOpen && !isOpen) {
      _pendingExpansionFocus = false;
      _focusNode.unfocus();
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
    _activeExpandedContentRevealPosition = null;
    _expandedContentRevealController.dispose();
    _singleChoiceCloseTimer?.cancel();
    _listenedController?.removeListener(_syncFieldValue);
    _detachFocusNode();
    _rowFocusNode.dispose();
    _internalController.dispose();
    super.dispose();
  }

  void _attachFocusNode(FocusNode? supplied) {
    _focusNode = supplied ?? FocusNode();
    _ownsFocusNode = supplied == null;
    _focused = _focusNode.hasFocus;
    _focusNode.addListener(_handleFocusChanged);
  }

  void _detachFocusNode() {
    _focusNode.removeListener(_handleFocusChanged);
    if (_ownsFocusNode) _focusNode.dispose();
  }

  void _handleFocusChanged() {
    final focused = _focusNode.hasFocus;
    if (_focused == focused) return;
    _focused = focused;
    widget.onFocusChanged?.call(_focused);
    if (!focused) widget.onBlur?.call(_controller.text);
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
    // Let EditableText own subsequent taps so it can position the native
    // insertion cursor. Re-requesting focus in a post-frame callback would
    // collapse every tap to the existing selection and make editing feel like
    // a two-step interaction.
    if (_focusNode.hasFocus) return;
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

  void _requestExpansion(bool expanded) {
    if (_isOpen == expanded) return;
    if (!expanded) {
      _singleChoiceCloseTimer?.cancel();
      _cancelExpandedContentReveal();
    }
    if (widget.open == null) {
      setState(() {
        _open = expanded;
        if (expanded) _disclosureOffstage = false;
      });
      if (expanded) _scheduleExpandedContentReveal();
    }
    widget.onOpenChanged?.call(expanded);
  }

  void _cancelExpandedContentReveal() {
    _expandedContentRevealController.stop();
    _activeExpandedContentRevealPosition = null;
  }

  void _startExpandedContentReveal({
    required ScrollPosition position,
    required double destination,
    required Duration duration,
  }) {
    _expandedContentRevealController.stop();
    _activeExpandedContentRevealPosition = position;
    _expandedContentRevealStart = position.pixels;
    _expandedContentRevealDestination = destination;
    _expandedContentRevealController
      ..duration = duration
      ..value = 0
      ..forward();
  }

  void _handleExpandedContentRevealTick() {
    final position = _activeExpandedContentRevealPosition;
    if (!_isOpen || position == null || !position.hasPixels) {
      _expandedContentRevealController.stop();
      _activeExpandedContentRevealPosition = null;
      return;
    }
    if (position.isScrollingNotifier.value) {
      // A direct user drag always wins over the automatic field reveal.
      _expandedContentRevealController.stop();
      _activeExpandedContentRevealPosition = null;
      return;
    }

    final progress = CatchFieldTokens.curve.transform(
      _expandedContentRevealController.value,
    );
    final requested =
        _expandedContentRevealStart +
        (_expandedContentRevealDestination - _expandedContentRevealStart) *
            progress;
    final available = requested
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (available > position.pixels) position.jumpTo(available);
  }

  void _handleExpandedContentRevealStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      _activeExpandedContentRevealPosition = null;
    }
  }

  ScrollableState? _expandedContentRevealScrollable() {
    BuildContext searchContext = context;
    ScrollableState? nearestVertical;
    final visited = <ScrollableState>{};
    while (true) {
      final candidate = Scrollable.maybeOf(searchContext);
      if (candidate == null || !visited.add(candidate)) break;
      final position = candidate.position;
      if (position.axis == Axis.vertical) {
        nearestVertical ??= candidate;
        if (position.hasContentDimensions &&
            position.maxScrollExtent > position.minScrollExtent) {
          return candidate;
        }
      }
      // A Scrollable's own context sits outside its private inherited scope,
      // so the next lookup walks to the next enclosing scroll owner.
      searchContext = candidate.context;
    }
    return nearestVertical;
  }

  void _scheduleExpandedContentReveal({Duration? duration}) {
    if (_expandedContentRevealScheduled) return;
    _expandedContentRevealScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _expandedContentRevealScheduled = false;
      if (!mounted || !_isOpen) return;

      final targetContext =
          _actionBarRevealTargetKey.currentContext ??
          _disclosureRevealTargetKey.currentContext;
      final target = targetContext?.findRenderObject();
      if (target is! RenderBox || !target.attached || !target.hasSize) return;

      final visibility = CatchFieldVisibilityScope.maybeOf(context);
      final bottomClearance =
          (visibility?.bottomObstruction ?? 0) +
          (visibility?.revealPadding ?? CatchSpacing.s2);
      final prioritizesActionBar =
          _actionBarRevealTargetKey.currentContext != null;
      final targetTop = prioritizesActionBar
          ? 0.0
          : target.size.height > 1
          ? target.size.height - 1
          : 0.0;
      final targetHeight = prioritizesActionBar ? target.size.height : 1.0;
      final revealDuration = duration ?? _expansionMotionDuration(context);
      final scrollable = _expandedContentRevealScrollable();
      final scrollPosition = scrollable?.position;
      final scrollViewport = scrollable?.context.findRenderObject();
      if (scrollPosition != null &&
          scrollPosition.axis == Axis.vertical &&
          scrollViewport is RenderBox &&
          scrollViewport.attached &&
          scrollViewport.hasSize) {
        final targetBottom = target
            .localToGlobal(Offset(0, targetTop + targetHeight))
            .dy;
        final viewportBottom = scrollViewport
            .localToGlobal(Offset(0, scrollViewport.size.height))
            .dy;
        final scrollDelta = targetBottom + bottomClearance - viewportBottom;
        if (scrollDelta > 0) {
          final destination = scrollPosition.pixels + scrollDelta;
          if (revealDuration == Duration.zero) {
            _expandedContentRevealController.stop();
            _activeExpandedContentRevealPosition = null;
            final available = destination
                .clamp(
                  scrollPosition.minScrollExtent,
                  scrollPosition.maxScrollExtent,
                )
                .toDouble();
            if (available > scrollPosition.pixels) {
              scrollPosition.jumpTo(available);
              return;
            }
          } else {
            // The field and viewport share one motion curve. Driving the
            // offset frame-by-frame lets the scroll extent grow with the
            // disclosure instead of clamping an animateTo target to the
            // collapsed card and snapping at the end.
            _startExpandedContentReveal(
              position: scrollPosition,
              destination: destination,
              duration: revealDuration,
            );
            return;
          }
        }
      }

      target.showOnScreen(
        rect: Rect.fromLTWH(
          0,
          targetTop,
          target.size.width,
          targetHeight + bottomClearance,
        ),
        duration: revealDuration,
        curve: CatchFieldTokens.curve,
      );
    });
  }

  void _handleExpansionAnimationEnd() {
    if (!_isOpen && !_disclosureOffstage) {
      setState(() => _disclosureOffstage = true);
    } else if (_isOpen) {
      // The Align height factor reaches its final scroll extent only at the
      // end of the reveal. Correct any earlier clamp without introducing a
      // second visible animation.
      _scheduleExpandedContentReveal(duration: Duration.zero);
    }
    _requestPendingExpansionFocus();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pressedPointer != null || event.buttons & kPrimaryButton == 0) return;
    _pressedPointer = event.pointer;
    _pressedDownPosition = event.position;
    if (!_pressed) setState(() => _pressed = true);
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_pressedPointer != event.pointer) return;
    final origin = _pressedDownPosition;
    if (origin == null || (event.position - origin).distance <= kTouchSlop) {
      return;
    }
    _clearPressedPointer(event.pointer);
  }

  void _handlePointerEnd(PointerEvent event) {
    if (_pressedPointer != event.pointer) return;
    _pressedPointer = null;
    _pressedDownPosition = null;
    // Keep the contact outline alive through GestureDetector's onTap. The tap
    // may activate focus/disclosure in the same frame, so deferring this reset
    // prevents a transparent frame between pressed and focused chrome.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pressedPointer == null && _pressed) {
        setState(() => _pressed = false);
      }
    });
  }

  void _handlePointerCancel(PointerEvent event) {
    _clearPressedPointer(event.pointer);
  }

  void _handlePointerExit(PointerExitEvent event) {
    _clearPressedPointer(event.pointer);
  }

  void _clearPressedPointer(int pointer) {
    if (_pressedPointer != pointer) return;
    _pressedPointer = null;
    _pressedDownPosition = null;
    if (_pressed && mounted) setState(() => _pressed = false);
  }

  void _handleOutsidePointerDown(PointerDownEvent event) {
    _outsidePointer = event.pointer;
    _outsideDownPosition = event.position;
  }

  void _handleOutsidePointerUp(PointerUpEvent event) {
    if (_outsidePointer != event.pointer) return;
    final downPosition = _outsideDownPosition;
    _outsidePointer = null;
    _outsideDownPosition = null;
    if (downPosition != null &&
        (event.position - downPosition).distance <= kTouchSlop) {
      _dismiss();
    }
  }

  void _clearOutsidePointer(PointerEvent event) {
    if (_outsidePointer != event.pointer) return;
    _outsidePointer = null;
    _outsideDownPosition = null;
  }

  void _requestPendingExpansionFocus() {
    if (!_pendingExpansionFocus ||
        !widget._explicitSaveInput ||
        !_isOpen ||
        !widget.enabled) {
      return;
    }
    _pendingExpansionFocus = false;
    _focusNode.requestFocus();
  }

  bool _handleChoicePicked(_CatchFieldChoicePickedNotification notification) {
    if (!notification.autoClose || _isSaving) return true;
    _singleChoiceCloseTimer?.cancel();
    _singleChoiceCloseTimer = Timer(
      CatchFieldTokens.singleChoiceCloseDelay,
      () {
        if (mounted && !_isSaving) _requestExpansion(false);
      },
    );
    return true;
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
  bool get _inlineAddAtRest => widget.addable && !_hasValue && !_isOpen;
  bool get _hasControl => widget.control != null || widget._explicitSaveInput;
  Object get _textFieldTapRegionGroup =>
      widget._explicitSaveInput ? _tapRegionGroup : EditableText;
  bool get _hasSelect =>
      widget._selectValues != null && widget._selectItemLabel != null;
  bool get _hasFieldValidationError => _textEntryHasValidationError;
  bool get _hasError =>
      (_displayError != null && _displayError!.isNotEmpty) ||
      _hasFieldValidationError;
  bool get _isOpen => widget.open ?? _open;
  bool get _isSaving =>
      widget._isLoading || widget.status == CatchFieldStatus.saving;
  bool get _active => _focused || _rowFocused || widget.focused || _isOpen;
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
      widget.maxLength != null ||
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
  bool get _usesPositionedClearTrailing =>
      _usesRowTextEntryTrailing &&
      widget.showClearButton &&
      widget.showLabel &&
      (_title?.isNotEmpty ?? false) &&
      _hasInputValue &&
      !_isSaving &&
      widget.status == CatchFieldStatus.idle &&
      !(widget.valid && !_hasError);
  bool get _hasLeadingSlot => widget.icon != null || _usesRowPrefixIcon;
  String? get _title => widget.title;
  String? get _body => widget.body;
  Widget? get _action => widget.action;
  String? get _displayError => widget.errorText ?? widget.error;
  String? get _placeholderText => widget.placeholder;
  String? get _inputHintText {
    final hint = (widget.inputHint ?? widget.placeholder)?.trim();
    if (hint == null || hint.isEmpty) return null;

    final label = _title?.trim();
    if (widget.showLabel &&
        label != null &&
        label.toLowerCase() == hint.toLowerCase()) {
      return null;
    }
    return hint;
  }

  String? get _emptyEditableValueText {
    final label = _title?.trim();
    final isEditableRow =
        (_isEdit && !widget.readOnly) ||
        widget._onSubmit != null ||
        widget.addable;
    if (!isEditableRow || label == null || label.isEmpty) return null;
    return CatchField.resolveEmptyValueText(
      context,
      title: label,
      emptyValueText: widget.emptyValueText,
    );
  }

  bool get _shouldShowChevron =>
      widget.showChevron ??
      (_mode == CatchFieldMode.nav &&
          (widget.mode == CatchFieldMode.nav || _action == null) &&
          widget.onTap != null &&
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
    late final Widget field;
    if (_mode == CatchFieldMode.select) {
      field = _buildSelectField(context);
    } else if (_usesUnderlineChrome) {
      field = _buildTextEntryField(context);
    } else {
      final t = CatchTokens.of(context);
      final rowStack = Stack(
        children: [
          if (widget.divider)
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
      if (!_isEdit && !_hasControl) {
        field = rowStack;
      } else {
        field = Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.escape):
                _CatchFieldDismissIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              _CatchFieldDismissIntent:
                  CallbackAction<_CatchFieldDismissIntent>(
                    onInvoke: (_) {
                      _dismiss();
                      return null;
                    },
                  ),
            },
            child: _isEdit
                ? TextFieldTapRegion(
                    groupId: _textFieldTapRegionGroup,
                    onTapOutside: _handleOutsidePointerDown,
                    onTapUpOutside: _handleOutsidePointerUp,
                    onTapInside: _clearOutsidePointer,
                    onTapUpInside: _clearOutsidePointer,
                    child: rowStack,
                  )
                : TapRegion(
                    groupId: _tapRegionGroup,
                    onTapOutside: _handleOutsidePointerDown,
                    onTapUpOutside: _handleOutsidePointerUp,
                    onTapInside: _clearOutsidePointer,
                    onTapUpInside: _clearOutsidePointer,
                    child: rowStack,
                  ),
          ),
        );
      }
    }
    final listeningField =
        NotificationListener<_CatchFieldChoicePickedNotification>(
          onNotification: _handleChoicePicked,
          child: field,
        );
    if (widget.enabled) return listeningField;
    return IgnorePointer(
      child: Opacity(
        opacity: CatchFieldTokens.disabledOpacity,
        child: listeningField,
      ),
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
        style: _fieldValueTextStyle(
          context,
          color: _toneColor(t, primaryFallback: t.primary),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildRow(CatchTokens t) {
    final canFocusTextEntry =
        _isEdit &&
        !widget._explicitSaveInput &&
        widget.enabled &&
        (!widget.readOnly || widget.onTap != null);
    final canToggleRow =
        _mode == CatchFieldMode.toggle && widget.onToggle != null && !_isSaving;
    final canExpand =
        _hasControl &&
        widget.enabled &&
        !_isSaving &&
        (widget.open == null || widget.onOpenChanged != null);
    final VoidCallback? rowAction;
    if (widget._explicitSaveInput && widget.enabled && !_isSaving) {
      rowAction = _isOpen
          ? _focusNode.requestFocus
          : () {
              _requestExpansion(true);
              widget.onTap?.call();
            };
    } else if (canFocusTextEntry) {
      rowAction = () {
        if (widget.readOnly && widget.onTap != null) {
          widget.onTap!();
          return;
        }
        _expandAndFocusTextEntry();
        widget.onTap?.call();
      };
    } else if (canExpand) {
      rowAction = () {
        _requestExpansion(!_isOpen);
        widget.onTap?.call();
      };
    } else if (canToggleRow) {
      rowAction = () => widget.onToggle!(!widget.toggled);
    } else if (widget.onTap != null && !_isEdit) {
      rowAction = widget.onTap;
    } else {
      rowAction = null;
    }
    final centerVertically =
        _mode == CatchFieldMode.toggle ||
        (widget._contentRow && widget.emphasis == CatchFieldEmphasis.title);
    final leadingTopPadding = centerVertically
        ? 0.0
        : widget._contentRow
        ? CatchSpacing.micro2
        : _rowTrailingTopPadding;
    final trailingSlot = _buildTrailingSlot(t);
    final positionsTrailing = _hasControl || _usesPositionedClearTrailing;
    final rowContent = CatchFieldRow.standard(
      constraints: _rowConstraints,
      padding: _rowHeaderPadding,
      leading: _buildLeadingSlot(t),
      trailing: positionsTrailing ? null : trailingSlot,
      crossAxisAlignment: centerVertically
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.start,
      leadingTopPadding: leadingTopPadding,
      paddingDuration: _hasControl
          ? _expansionMotionDuration(context)
          : Duration.zero,
      paddingCurve: CatchFieldTokens.curve,
      content: _buildBody(t),
    );
    final row = positionsTrailing && trailingSlot != null
        ? Stack(
            children: [
              rowContent,
              PositionedDirectional(
                top: _usesPositionedClearTrailing
                    ? _rowHeaderPadding.top +
                          CatchFieldTokens.captionExtent +
                          (CatchFieldTokens.valueLineExtent - CatchSpacing.s6) /
                              2 +
                          CatchSpacing.micro3
                    : _rowHeaderPadding.top + _rowTrailingTopPadding,
                end: _rowHeaderPadding.right,
                child: trailingSlot,
              ),
            ],
          )
        : rowContent;
    final action = rowAction;
    final canInteract = action != null;
    if (!canInteract && !_active && !_hasControl) return row;
    final highlighted = _active || _pressed;
    final decoration = BoxDecoration(
      color: _pressed
          ? CatchFieldTokens.pressedSurface(t)
          : _active
          ? CatchFieldTokens.activeSurface(t)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(CatchFieldTokens.tileRadius),
      border: highlighted ? Border.all(color: t.line) : null,
      boxShadow: _active
          ? CatchElevation.fieldActive(Theme.of(context).brightness)
          : CatchElevation.none,
    );
    final overlayBleed = CatchFieldInsetScope.flushOf(context)
        ? CatchFieldTokens.dividedRowBleed
        : 0.0;
    final mouseCursor = canInteract
        ? _isEdit
              ? SystemMouseCursors.text
              : SystemMouseCursors.click
        : SystemMouseCursors.basic;
    final tapRegion = _isEdit
        ? TextFieldTapRegion(groupId: _textFieldTapRegionGroup, child: row)
        : row;
    final isToggle = _mode == CatchFieldMode.toggle;
    final toggleStatusValue = switch (widget.status) {
      CatchFieldStatus.idle => null,
      CatchFieldStatus.saving => context.l10n.coreCatchFieldSemanticSaving,
      CatchFieldStatus.saved => context.l10n.coreCatchFieldSemanticSaved,
    };
    final pointerTarget = Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: canInteract ? _handlePointerDown : null,
      onPointerMove: canInteract ? _handlePointerMove : null,
      onPointerUp: canInteract ? _handlePointerEnd : null,
      onPointerCancel: canInteract ? _handlePointerCancel : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: action,
        child: tapRegion,
      ),
    );
    final keyboardTarget = _isEdit || isToggle
        // Editable rows already own one native focus target through TextField.
        // Toggle rows likewise delegate keyboard ownership to their nested
        // switch. A second row Focus node would insert an empty Tab stop.
        ? pointerTarget
        : FocusableActionDetector(
            enabled: canInteract,
            focusNode: _rowFocusNode,
            mouseCursor: mouseCursor,
            onShowFocusHighlight: (focused) {
              if (_rowFocused == focused) return;
              setState(() => _rowFocused = focused);
            },
            actions: <Type, Action<Intent>>{
              if (action != null)
                ActivateIntent: CallbackAction<ActivateIntent>(
                  onInvoke: (_) {
                    if (_rowFocusNode.hasPrimaryFocus) action();
                    return null;
                  },
                ),
            },
            child: pointerTarget,
          );
    final rowPadding = _rowPadding;
    final disclosureStartPadding =
        rowPadding.left + (_hasLeadingSlot ? CatchFieldRow.textLaneInset : 0.0);
    final disclosureControl = widget._explicitSaveInput
        ? CatchFieldExplicitSaveControl(
            supporting: widget._supporting,
            feedback: widget._feedback,
            secondaryAction: widget._secondaryAction,
          )
        : widget.control;
    final actionBar = widget._onSubmit == null
        ? null
        : CatchFieldActionBar(
            revealTargetKey: _actionBarRevealTargetKey,
            loading: _isSaving,
            actionLeading: widget._actionLeading,
            onCancel: _handleCancel,
            onSubmit: _handleSubmit,
          );
    final rootError = _hasControl ? _displayError?.trim() : null;
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        keyboardTarget,
        if (_hasControl)
          CatchFieldDisclosureDrawer(
            open: _isOpen,
            offstage: _disclosureOffstage,
            revealTargetKey: _disclosureRevealTargetKey,
            control: disclosureControl!,
            actionBar: actionBar,
            startPadding: disclosureStartPadding,
            endPadding: rowPadding.right,
            bottomPadding: rowPadding.bottom,
            revealDuration: _expansionMotionDuration(context),
            opacityDuration: _fieldDuration(context, CatchFieldTokens.standard),
            onRevealEnd: _handleExpansionAnimationEnd,
          ),
        if (rootError?.isNotEmpty == true)
          CatchFieldSupportRow(
            key: const ValueKey('catch-field-root-support'),
            text: rootError,
            color: t.danger,
            showErrorIcon: true,
            padding: EdgeInsetsDirectional.only(
              start: disclosureStartPadding,
              end: rowPadding.right,
              bottom: rowPadding.bottom,
            ),
          ),
      ],
    );
    final stack = Stack(
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        PositionedDirectional(
          start: -overlayBleed,
          end: -overlayBleed,
          top: -CatchStroke.hairline,
          bottom: -CatchStroke.hairline,
          child: IgnorePointer(
            child: AnimatedContainer(
              key: const ValueKey('catch-field-active-overlay'),
              duration: _fieldDuration(
                context,
                _pressed
                    ? CatchFieldTokens.pressIn
                    : _active
                    ? CatchFieldTokens.standard
                    : CatchFieldTokens.pressOut,
              ),
              curve: CatchFieldTokens.curve,
              decoration: decoration,
            ),
          ),
        ),
        content,
      ],
    );
    return Semantics(
      container: isToggle,
      excludeSemantics: isToggle,
      label: isToggle ? _title : null,
      button: !isToggle && !_isEdit && canInteract,
      enabled: canInteract,
      expanded: _hasControl ? _isOpen : null,
      toggled: isToggle ? widget.toggled : null,
      value: isToggle ? toggleStatusValue : null,
      liveRegion: isToggle && toggleStatusValue != null,
      onTap: isToggle && canInteract ? action : null,
      child: MouseRegion(
        cursor: mouseCursor,
        onExit: canInteract ? _handlePointerExit : null,
        child: stack,
      ),
    );
  }

  void _dismiss() {
    if (_isSaving) return;
    if (_isOpen) {
      _handleCancel();
    }
    if (_focusNode.hasFocus) _focusNode.unfocus();
    if (_menuController.isOpen) _menuController.close();
  }

  void _handleCancel() {
    if (_isSaving) return;
    _requestExpansion(false);
    widget._onCancel?.call();
  }

  void _handleSubmit() {
    if (_isSaving) return;
    widget._onSubmit?.call();
    // The handoff closes locally-owned disclosures after Done. Controlled
    // editors remain parent-owned so async validation/save state can decide
    // when their card collapses.
    if (mounted &&
        widget._closeLocallyOnSubmit &&
        widget.open == null &&
        !_isSaving) {
      _requestExpansion(false);
    }
  }

  Widget? _buildLeadingSlot(CatchTokens t) {
    if (widget.icon != null) {
      return Icon(
        widget.icon,
        size: CatchFieldRow.leadingSlotIconSize,
        color:
            widget.iconColor ??
            (_active
                ? t.ink
                : _inlineAddAtRest
                ? t.primary
                : _toneColor(t, muted: true)),
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
    if (_mode == CatchFieldMode.toggle) {
      return CatchFieldTrailing.toggle(
        value: widget.toggled,
        onChanged: _isSaving ? null : widget.onToggle,
        semanticLabel: _title,
        status: widget.status,
        topPadding: 0,
      );
    }
    if (_isSaving) {
      return CatchFieldTrailing.saving(topPadding: _rowTrailingTopPadding);
    }
    if (widget.status == CatchFieldStatus.saved) {
      return CatchFieldTrailing.saved(topPadding: _rowTrailingTopPadding);
    }
    if (widget.valid && !_hasError) return CatchFieldTrailing.valid();

    if (_usesRowTextEntryTrailing) {
      return _buildTextEntryTrailingSlot(t);
    }

    if (_hasControl) {
      return CatchFieldTrailing.rotatingChevron(
        open: _isOpen,
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
          tooltip: context.l10n.coreCatchFieldTooltipClearValue1(
            value1: _title ?? context.l10n.coreCatchFieldTooltipField,
          ),
          onPressed: () {
            _controller.clear();
            widget.onChanged?.call('');
          },
          topPadding: _usesPositionedClearTrailing ? 0 : _rowTrailingTopPadding,
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
    if (widget._contentRow) return 0;
    if (!_isEdit && widget.emphasis == CatchFieldEmphasis.title) {
      return 0;
    }

    final textEntryValueLine =
        _isEdit &&
        widget.showLabel &&
        (_title?.isNotEmpty ?? false) &&
        (!_textEntryCollapsed || _emptyEditableValueText != null);
    final canonicalValueLine =
        !_isEdit &&
        ((_body?.trim().isNotEmpty ?? false) ||
            (_placeholderText?.trim().isNotEmpty ?? false));
    return textEntryValueLine || canonicalValueLine ? CatchSpacing.micro18 : 0;
  }

  Widget _buildBody(CatchTokens t) {
    if (_inlineAddAtRest) {
      final addText = _emptyEditableValueText ?? _title ?? '';
      final optionalSuffix = widget.isOptional
          ? context.l10n.coreCatchFieldTextOptionalSuffix
          : null;
      return Semantics(
        label: widget.isOptional
            ? context.l10n.coreCatchFormFieldLabelLabelLabelOptional(
                label: addText,
              )
            : addText,
        excludeSemantics: true,
        child: Text.rich(
          TextSpan(
            children: [
              TextSpan(
                text: addText,
                style: _fieldValueTextStyle(
                  context,
                  color: t.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (optionalSuffix != null)
                TextSpan(
                  text: optionalSuffix,
                  style: _fieldValueTextStyle(
                    context,
                    color: t.ink3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
            ],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    }
    if (widget._explicitSaveInput) {
      final error = _displayError?.trim();
      final input = IgnorePointer(
        ignoring: !_isOpen,
        child: _buildTextEntryField(
          context,
          showLabelOverride: false,
          variantOverride: CatchFieldVariant.bare,
          valueEmphasis: true,
          canInteractOverride: _isOpen && widget.enabled,
          readOnlyOverride: !_isOpen,
          includeSupport: false,
          inputHintOverride: _isOpen ? _inputHintText : _emptyEditableValueText,
        ),
      );
      return _buildFieldContent(
        t,
        label: _title,
        valueWidget: input,
        hasError: error?.isNotEmpty == true,
        labelStyle: _fieldCaptionTextStyle(
          context,
          color: error?.isNotEmpty == true
              ? t.danger
              : _active
              ? t.ink
              : t.ink3,
        ),
      );
    }
    if (_isEdit) return _buildTextEntryBody(t);
    if (widget._contentRow) {
      final hasError = _displayError?.trim().isNotEmpty == true;
      return CatchFieldContentRow(
        title: _title?.trim() ?? '',
        body: _body?.trim() ?? '',
        titleMaxLines: widget.titleMaxLines,
        bodyMaxLines: widget.bodyMaxLines,
        isOptional: widget.isOptional,
        titleColor: hasError ? t.danger : _toneColor(t, primaryFallback: t.ink),
        bodyColor: t.ink2,
      );
    }

    final title = _title?.trim();
    final value = _body?.trim().isNotEmpty == true
        ? _body!.trim()
        : widget._onSubmit != null
        ? _emptyEditableValueText
        : _placeholderText?.trim();
    final error = _displayError?.trim();
    final hasValue = value != null && value.isNotEmpty;

    return _buildFieldContent(
      t,
      label: title,
      value: value,
      supportText: !_hasControl && error?.isNotEmpty == true ? error : null,
      labelEmphasized: widget.emphasis == CatchFieldEmphasis.title || !hasValue,
      valueIsPlaceholder: !_hasValue,
      valueMaxLines: widget.bodyMaxLines,
      hasError: error?.isNotEmpty == true,
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
    String? counterText,
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
    final counter = counterText?.trim();
    final hasCounter = counter != null && counter.isNotEmpty;
    final hasSupport = (support != null && support.isNotEmpty) || hasCounter;
    final headerTrailingReserve = _hasControl
        ? CatchFieldTokens.trailingGap + CatchFieldTokens.disclosureGlyphExtent
        : _usesPositionedClearTrailing
        ? CatchFieldTokens.trailingGap + CatchSpacing.s6
        : 0.0;

    if (!hasLabel && !hasValue && !hasSupport) {
      return const SizedBox.shrink();
    }

    final effectiveLabelStyle =
        labelStyle ??
        (labelEmphasized
            ? _fieldValueTextStyle(
                context,
                color: hasError
                    ? t.danger
                    : _toneColor(t, primaryFallback: t.ink),
              )
            : _fieldCaptionTextStyle(
                context,
                color: hasError ? t.danger : t.ink3,
              ));
    final effectiveValueStyle =
        valueStyle ??
        (labelEmphasized
            ? _fieldCaptionTextStyle(context, color: t.ink2)
            : _fieldValueTextStyle(
                context,
                color: valueIsPlaceholder
                    ? t.ink3
                    : _toneColor(t, primaryFallback: t.ink),
              ));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hasLabel)
          Padding(
            padding: EdgeInsetsDirectional.only(end: headerTrailingReserve),
            child: SizedBox(
              height: labelEmphasized
                  ? CatchFieldTokens.valueLineExtent
                  : CatchFieldTokens.captionExtent,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: CatchFormFieldLabel.inline(
                  label: labelText,
                  style: effectiveLabelStyle,
                  maxLines: widget.titleMaxLines,
                  isOptional: widget.isOptional && widget.showLabel,
                ),
              ),
            ),
          ),
        if (hasValue) ...[
          Padding(
            padding: EdgeInsetsDirectional.only(end: headerTrailingReserve),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                minHeight: CatchFieldTokens.valueLineExtent,
              ),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child:
                    valueWidget ??
                    Text(
                      valueText!,
                      maxLines: valueMaxLines,
                      overflow: TextOverflow.ellipsis,
                      style: effectiveValueStyle,
                    ),
              ),
            ),
          ),
        ],
        if (hasSupport) ...[
          if (hasLabel || hasValue)
            const SizedBox(height: CatchFieldTokens.supportingTopGap),
          CatchFieldSupportRow(
            text: support,
            counter: hasCounter ? counter : null,
            color: hasError ? t.danger : _supportColor(t),
            showErrorIcon: hasError,
          ),
        ],
      ],
    );
  }

  Widget _buildTextEntryField(
    BuildContext context, {
    bool? showLabelOverride,
    CatchFieldVariant? variantOverride,
    bool valueEmphasis = false,
    bool rowBody = false,
    bool? canInteractOverride,
    bool? readOnlyOverride,
    bool includeSupport = true,
    String? inputHintOverride,
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
        final supportText = includeSupport ? error ?? widget.helperText : null;

        if (rowBody) {
          final expanded = _textEntryExpandedWith(hasError: hasError);
          final body = _buildFieldContent(
            t,
            label: widget.showLabel ? _title : null,
            supportText: supportText,
            counterText:
                widget.maxLength != null &&
                    (_focused || widget.focused || hasError)
                ? '${_controller.text.characters.length} / ${widget.maxLength}'
                : null,
            hasError: hasError,
            labelStyle: _fieldCaptionTextStyle(
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
                    style: _fieldValueTextStyle(context, color: t.ink2),
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
                    canInteractOverride: canInteractOverride,
                    readOnlyOverride: readOnlyOverride,
                    inputHintOverride: expanded
                        ? inputHintOverride
                        : _emptyEditableValueText,
                  ),
                ),
              ],
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
          canInteractOverride: canInteractOverride,
          readOnlyOverride: readOnlyOverride,
          inputHintOverride: inputHintOverride,
        );

        final counterText =
            effectiveVariant == CatchFieldVariant.underline &&
                widget.maxLength != null &&
                (_focused || widget.focused)
            ? '${_controller.text.characters.length} / ${widget.maxLength}'
            : null;
        final hasMeta = supportText != null || counterText != null;

        if (!effectiveShowLabel && !hasMeta) {
          return field;
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (effectiveShowLabel &&
                !_useFloatingLabel(effectiveVariant, effectiveShowLabel)) ...[
              CatchFormFieldLabel.inline(
                label: _title ?? '',
                style: _fieldCaptionTextStyle(
                  context,
                  color: hasError ? t.danger : t.ink3,
                ),
                isOptional: widget.isOptional && widget.showLabel,
              ),
              const SizedBox(height: CatchSpacing.s2),
            ],
            field,
            if (hasMeta) ...[
              const SizedBox(height: CatchFieldTokens.supportingTopGap),
              CatchFieldSupportRow(
                text: supportText,
                counter: counterText,
                color: hasError ? t.danger : _supportColor(t),
                showErrorIcon:
                    hasError && effectiveVariant != CatchFieldVariant.underline,
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
    bool? canInteractOverride,
    bool? readOnlyOverride,
    String? inputHintOverride,
  }) {
    final t = CatchTokens.of(context);
    final canInteract =
        canInteractOverride ?? (!widget.readOnly || widget.onTap != null);
    final readOnly = readOnlyOverride ?? widget.readOnly;
    final effectiveFocused = _focusNode.hasFocus || widget.focused;
    final multiline =
        !widget.obscureText &&
        (widget.maxLines != 1 || (widget.minLines ?? 1) > 1);
    final multilineValueStyle = _fieldValueTextStyle(
      context,
      color: widget.enabled ? t.ink : t.ink3,
      fontWeight: FontWeight.w500,
    ).copyWith(height: CatchFieldTokens.multilineValueLineHeight);
    final multilineHintStyle = _fieldValueTextStyle(
      context,
      color: t.ink2,
      fontWeight: FontWeight.w500,
    ).copyWith(height: CatchFieldTokens.multilineValueLineHeight);
    final inputStyle = valueEmphasis
        ? multiline
              ? multilineValueStyle
              : _fieldValueTextStyle(
                  context,
                  color: widget.enabled ? t.ink : t.ink3,
                )
        : _textStyle(context, color: widget.enabled ? t.ink : t.ink3);
    final hintStyle = valueEmphasis
        ? multiline
              ? multilineHintStyle
              : _fieldValueTextStyle(context, color: t.ink2)
        : widget.size == CatchFieldSize.floating
        ? CatchTextStyles.bodyL(context, color: t.ink2)
        : _textStyle(context, color: t.ink2);
    final resolvedHintText = inputHintOverride ?? _inputHintText;
    final visualOnlyHint = !showLabel && resolvedHintText != null;
    final textField = TextField(
      groupId: _textFieldTapRegionGroup,
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: readOnly,
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
      maxLength: widget.maxLength,
      textAlign: widget.textAlign,
      textAlignVertical: _textAlignVertical,
      onTap: widget.onTap,
      onTapOutside: widget._explicitSaveInput
          ? null
          : (_) => _focusNode.unfocus(),
      onChanged: (value) {
        state.didChange(value);
        widget.onChanged?.call(value);
      },
      onEditingComplete: widget.retainFocusOnSubmitted ? () {} : null,
      onSubmitted: _handleSubmitted,
      style: inputStyle,
      cursorColor: t.primary,
      decoration: InputDecoration(
        counterText: '',
        isDense: true,
        isCollapsed: variant == CatchFieldVariant.bare,
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
            ? _fieldCaptionTextStyle(
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
        hint: visualOnlyHint
            ? ExcludeSemantics(child: Text(resolvedHintText))
            : null,
        hintText: visualOnlyHint ? null : resolvedHintText,
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
    return MergeSemantics(
      child: Semantics(label: _title, child: sizedInputShell),
    );
  }

  Widget _buildTextEntryMotion(BuildContext context, {required Widget child}) {
    return AnimatedSize(
      duration: _motionDuration(context),
      curve: CatchFieldTokens.curve,
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
                    value:
                        label ??
                        widget.placeholder ??
                        _selectPlaceholder(context.l10n, _title),
                    supportText: supportText,
                    hasError: hasError,
                    valueIsPlaceholder: label == null,
                    labelStyle: _fieldCaptionTextStyle(
                      context,
                      color: hasError ? tokens.danger : tokens.ink3,
                    ),
                    valueStyle: _fieldValueTextStyle(
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
    final baselineColor = hasError
        ? tokens.danger
        : widget.enabled
        ? tokens.line2
        : tokens.line;
    final sweepColor = hasError ? tokens.danger : tokens.ink;
    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: CatchControlMetrics.minHeight(_controlSize),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DecoratedBox(
            key: const ValueKey('catch-field-underline-baseline'),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: baselineColor)),
            ),
            child: child,
          ),
          PositionedDirectional(
            start: 0,
            end: 0,
            bottom: -(CatchStroke.underline - CatchStroke.hairline),
            height: CatchStroke.underline,
            child: LayoutBuilder(
              builder: (context, constraints) => TweenAnimationBuilder<double>(
                key: const ValueKey('catch-field-underline-sweep'),
                duration: _fieldDuration(context, CatchFieldTokens.reveal),
                curve: CatchFieldTokens.curve,
                tween: Tween<double>(end: active ? 1 : 0),
                builder: (context, progress, _) => Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: SizedBox(
                    key: const ValueKey('catch-field-underline-sweep-bar'),
                    width: constraints.maxWidth * progress,
                    height: CatchStroke.underline,
                    child: ColoredBox(color: sweepColor),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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
            tooltip: context.l10n.coreCatchFieldTooltipClearValue1(
              value1: _title ?? context.l10n.coreCatchFieldTooltipField,
            ),
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
    if (!widget.retainFocusOnSubmitted) _focusNode.unfocus();
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
      return const EdgeInsets.fromLTRB(
        0,
        CatchSpacing.micro2,
        0,
        CatchSpacing.s2,
      );
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
      return const EdgeInsets.symmetric(
        vertical: CatchFieldTokens.rowVerticalPadding,
      );
    }
    return const EdgeInsets.fromLTRB(
      CatchFieldTokens.rowHorizontalPadding,
      CatchFieldTokens.rowVerticalPadding,
      CatchFieldTokens.rowHorizontalPadding,
      CatchFieldTokens.rowVerticalPadding,
    );
  }

  EdgeInsets get _rowHeaderPadding {
    final padding = _rowPadding;
    if (!_hasControl) return padding;
    return EdgeInsets.fromLTRB(
      padding.left,
      padding.top,
      padding.right,
      _isOpen ? 0 : padding.bottom,
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

String _selectPlaceholder(AppLocalizations l10n, String? title) {
  final normalizedTitle = title?.trim();
  if (normalizedTitle == null || normalizedTitle.isEmpty) {
    return l10n.coreCatchFieldVisiblecopySelect;
  }
  return l10n.coreCatchFieldVisiblecopySelectTolowercase(
    toLowerCase: normalizedTitle.toLowerCase(),
  );
}

Duration _catchFieldMotionDuration(BuildContext context) {
  return _fieldDuration(context, CatchFieldTokens.fast);
}

Duration _expansionMotionDuration(BuildContext context) {
  return _fieldDuration(context, CatchFieldTokens.reveal);
}

Duration _fieldDuration(BuildContext context, Duration duration) {
  final disableAnimations = MediaQuery.maybeOf(context)?.disableAnimations;
  return disableAnimations == true ? Duration.zero : duration;
}

TextStyle _fieldValueTextStyle(
  BuildContext context, {
  required Color color,
  FontWeight fontWeight = FontWeight.w700,
}) => CatchTextStyles.fieldRowTitle(context, color: color).copyWith(
  fontSize: CatchFieldTokens.valueFontSize,
  fontWeight: fontWeight,
  height: CatchFieldTokens.valueLineHeight,
);

TextStyle _fieldCaptionTextStyle(
  BuildContext context, {
  required Color color,
}) => CatchTextStyles.fieldLabel(context, color: color).copyWith(
  fontSize: CatchFieldTokens.captionFontSize,
  fontWeight: FontWeight.w500,
  height: CatchFieldTokens.supportLineHeight,
);

/// Ambient visibility contract for disclosure fields inside obstructed scroll
/// surfaces.
///
/// A shell that overlays navigation on top of its body publishes the covered
/// bottom extent here. When a [CatchField] opens, it asks the nearest viewport
/// to reveal its commit controls plus this clearance, keeping the entire
/// interaction one gesture even when the field starts near the screen edge.
class CatchFieldVisibilityScope extends InheritedWidget {
  const CatchFieldVisibilityScope({
    super.key,
    required this.bottomObstruction,
    this.revealPadding = CatchSpacing.s2,
    required super.child,
  }) : assert(bottomObstruction >= 0),
       assert(revealPadding >= 0);

  final double bottomObstruction;
  final double revealPadding;

  static CatchFieldVisibilityScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CatchFieldVisibilityScope>();

  @override
  bool updateShouldNotify(CatchFieldVisibilityScope oldWidget) =>
      bottomObstruction != oldWidget.bottomObstruction ||
      revealPadding != oldWidget.revealPadding;
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

/// Exact natural-height title and supporting-copy lane used by
/// [CatchField.content].
class CatchFieldContentRow extends StatelessWidget {
  const CatchFieldContentRow({
    super.key,
    required this.title,
    required this.body,
    this.titleMaxLines = 2,
    this.bodyMaxLines = 3,
    this.isOptional = false,
    this.titleColor,
    this.bodyColor,
  });

  final String title;
  final String body;
  final int titleMaxLines;
  final int bodyMaxLines;
  final bool isOptional;
  final Color? titleColor;
  final Color? bodyColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final normalizedBody = body.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchFormFieldLabel.inline(
          label: title.trim(),
          style: _fieldValueTextStyle(
            context,
            color: titleColor ?? t.ink,
            fontWeight: FontWeight.w600,
          ),
          maxLines: titleMaxLines,
          isOptional: isOptional,
        ),
        if (normalizedBody.isNotEmpty) ...[
          const SizedBox(height: CatchFieldTokens.contentBodyTopGap),
          Text(
            normalizedBody,
            key: const ValueKey('catch-field-content-body'),
            maxLines: bodyMaxLines,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.bodyS(context, color: bodyColor ?? t.ink2)
                .copyWith(
                  fontSize: CatchFieldTokens.contentBodyFontSize,
                  fontWeight: FontWeight.w400,
                  height: CatchFieldTokens.contentBodyLineHeight,
                ),
          ),
        ],
      ],
    );
  }
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
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.leadingTopPadding = 0,
    this.paddingDuration = Duration.zero,
    this.paddingCurve = Curves.linear,
  }) : leadingGap = leadingSlotGap,
       trailingGap = CatchFieldTokens.trailingGap;

  const CatchFieldRow.add({
    super.key,
    required this.leading,
    required this.content,
    this.onTap,
  }) : trailing = null,
       constraints = const BoxConstraints(),
       padding = const EdgeInsets.symmetric(
         horizontal: CatchFieldTokens.rowHorizontalPadding,
         vertical: CatchFieldTokens.rowVerticalPadding,
       ),
       crossAxisAlignment = CrossAxisAlignment.start,
       leadingTopPadding = 0,
       paddingDuration = Duration.zero,
       paddingCurve = Curves.linear,
       leadingGap = leadingSlotGap,
       trailingGap = CatchFieldTokens.trailingGap;

  /// Render size of icons in the leading slot.
  static const double leadingSlotIconSize = CatchFieldTokens.leadingIconExtent;

  /// Gap between the leading slot and the content lane.
  static const double leadingSlotGap = CatchFieldTokens.leadingGap;

  /// Horizontal distance from the row's padded edge to where the content
  /// lane starts when a leading slot is present. Containers that draw
  /// text-lane-aligned dividers derive their indent from this instead of
  /// hardcoding it, so resizing the leading icon moves the dividers too.
  static const double textLaneInset = CatchLayout.fieldRowTextLaneInset;

  static const _defaultPadding = EdgeInsets.fromLTRB(
    CatchFieldTokens.rowHorizontalPadding,
    CatchFieldTokens.rowVerticalPadding,
    CatchFieldTokens.rowHorizontalPadding,
    CatchFieldTokens.rowVerticalPadding,
  );

  final Widget content;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final BoxConstraints constraints;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;
  final double leadingTopPadding;
  final double leadingGap;
  final double trailingGap;
  final Duration paddingDuration;
  final Curve paddingCurve;

  @override
  Widget build(BuildContext context) {
    final row = ConstrainedBox(
      constraints: constraints,
      child: AnimatedPadding(
        duration: paddingDuration,
        curve: paddingCurve,
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
              crossAxisAlignment: crossAxisAlignment,
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
            style: _fieldValueTextStyle(
              context,
              color: t.ink2,
              fontWeight: FontWeight.w400,
            ),
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
      size: CatchFieldTokens.disclosureGlyphExtent,
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
      duration: _fieldDuration(context, CatchFieldTokens.reveal),
      curve: CatchFieldTokens.curve,
      child: Icon(
        CatchIcons.expandMoreRounded,
        size: CatchFieldTokens.disclosureGlyphExtent,
        color: color ?? CatchTokens.of(context).ink3,
      ),
    ),
  );

  factory CatchFieldTrailing.toggle({
    Key? key,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? semanticLabel,
    CatchFieldStatus status = CatchFieldStatus.idle,
    double topPadding = CatchSpacing.micro2,
  }) => CatchFieldTrailing._(
    key: key,
    topPadding: topPadding,
    builder: (context) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (status == CatchFieldStatus.saving)
          SizedBox.square(
            dimension: CatchFieldTokens.spinnerExtent,
            child: CatchFieldSpinner(color: CatchTokens.of(context).ink3),
          )
        else if (status == CatchFieldStatus.saved)
          Icon(
            CatchIcons.checkCircleFilled,
            key: const ValueKey('catch-field-saved'),
            size: CatchFieldTokens.disclosureGlyphExtent,
            color: CatchTokens.of(context).success,
          ),
        if (status != CatchFieldStatus.idle)
          const SizedBox(width: CatchFieldTokens.trailingGap),
        CatchFieldToggle(
          value: value,
          semanticLabel: semanticLabel,
          onChanged: onChanged,
        ),
      ],
    ),
  );

  factory CatchFieldTrailing.saving({Key? key, double topPadding = 0}) =>
      CatchFieldTrailing._(
        key: key,
        topPadding: topPadding,
        builder: (context) => Semantics(
          label: context.l10n.coreCatchFieldSemanticSaving,
          liveRegion: true,
          child: ExcludeSemantics(
            child: SizedBox.square(
              dimension: CatchFieldTokens.spinnerExtent,
              child: CatchFieldSpinner(color: CatchTokens.of(context).ink3),
            ),
          ),
        ),
      );

  factory CatchFieldTrailing.saved({Key? key, double topPadding = 0}) =>
      CatchFieldTrailing._(
        key: key,
        topPadding: topPadding,
        builder: (context) => Semantics(
          label: context.l10n.coreCatchFieldSemanticSaved,
          liveRegion: true,
          child: ExcludeSemantics(
            child: Icon(
              CatchIcons.checkCircleFilled,
              key: const ValueKey('catch-field-saved'),
              size: CatchFieldTokens.disclosureGlyphExtent,
              color: CatchTokens.of(context).success,
            ),
          ),
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
      style: IconButton.styleFrom(
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      icon: Icon(
        CatchIcons.clearCircle,
        size: CatchFieldTokens.largeGlyphExtent,
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

/// Field helper/error and optional counter row.
class CatchFieldSupportRow extends StatelessWidget {
  const CatchFieldSupportRow({
    super.key,
    this.text,
    this.counter,
    required this.color,
    this.showErrorIcon = false,
    this.padding = EdgeInsets.zero,
  });

  final String? text;
  final String? counter;
  final Color color;
  final bool showErrorIcon;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final normalizedText = text?.trim();
    final normalizedCounter = counter?.trim();
    final hasText = normalizedText?.isNotEmpty == true;
    final hasCounter = normalizedCounter?.isNotEmpty == true;
    if (!hasText && !hasCounter) return const SizedBox.shrink();

    final label = Text(
      normalizedText ?? '',
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      style: CatchTextStyles.supporting(context, color: color).copyWith(
        fontSize: CatchFieldTokens.captionFontSize,
        fontWeight: FontWeight.w500,
        height: CatchFieldTokens.supportLineHeight,
      ),
    );
    final support = showErrorIcon
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(
                  CatchIcons.fieldWarning,
                  size: CatchFieldTokens.errorGlyphExtent,
                  color: color,
                ),
              ),
              const SizedBox(width: CatchFieldTokens.errorGlyphGap),
              Flexible(child: label),
            ],
          )
        : label;

    return Padding(
      padding: padding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        children: [
          if (hasText) Expanded(child: support) else const Spacer(),
          if (hasCounter) ...[
            if (hasText)
              const SizedBox(width: CatchFieldTokens.supportingCounterGap),
            Text(
              normalizedCounter!,
              style: CatchTextStyles.monoLabel(
                context,
                color: CatchTokens.of(context).ink3,
              ).copyWith(fontSize: CatchFieldTokens.counterFontSize),
            ),
          ],
        ],
      ),
    );
  }
}

/// Supporting metadata shown inside an explicit-save disclosure before its
/// commit bar. Validation remains a root-level [CatchFieldSupportRow].
class CatchFieldExplicitSaveControl extends StatelessWidget {
  const CatchFieldExplicitSaveControl({
    super.key,
    this.supporting,
    this.feedback,
    this.secondaryAction,
  });

  final Widget? supporting;
  final Widget? feedback;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    void addChild(Widget child) {
      if (children.isNotEmpty) {
        children.add(const SizedBox(height: CatchSpacing.s2));
      }
      children.add(child);
    }

    if (supporting case final supporting?) {
      addChild(Align(alignment: Alignment.centerRight, child: supporting));
    }
    if (feedback case final feedback?) addChild(feedback);
    if (secondaryAction case final secondaryAction?) {
      addChild(secondaryAction);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: children,
    );
  }
}

/// Trailing Cancel/Done group used by explicit-save field drawers.
class CatchFieldActionBar extends StatelessWidget {
  const CatchFieldActionBar({
    super.key,
    required this.onCancel,
    required this.onSubmit,
    this.loading = false,
    this.actionLeading,
    this.revealTargetKey,
  });

  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final bool loading;
  final Widget? actionLeading;
  final Key? revealTargetKey;

  @override
  Widget build(BuildContext context) {
    final cancelButton = CatchFieldCommitButton(
      key: const ValueKey('catch-field-cancel'),
      label: context.l10n.coreCatchFieldLabelCancel,
      onPressed: loading ? null : onCancel,
    );
    final doneButton = CatchFieldCommitButton(
      key: const ValueKey('catch-field-done'),
      label: loading
          ? context.l10n.coreCatchFieldLabelSaving
          : context.l10n.coreCatchFieldLabelDone,
      primary: true,
      loading: loading,
      onPressed: loading ? null : onSubmit,
    );

    return KeyedSubtree(
      key: revealTargetKey,
      child: SizedBox(
        key: const ValueKey('catch-field-action-bar'),
        width: double.infinity,
        child: Row(
          children: [
            if (actionLeading != null)
              Expanded(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: actionLeading,
                ),
              )
            else
              const Spacer(),
            cancelButton,
            const SizedBox(width: CatchFieldTokens.actionButtonGap),
            doneButton,
          ],
        ),
      ),
    );
  }
}

/// Full-row disclosure sibling below a [CatchField] header.
class CatchFieldDisclosureDrawer extends StatelessWidget {
  const CatchFieldDisclosureDrawer({
    super.key,
    required this.open,
    required this.offstage,
    required this.control,
    required this.startPadding,
    required this.endPadding,
    required this.bottomPadding,
    required this.revealDuration,
    required this.opacityDuration,
    required this.onRevealEnd,
    this.actionBar,
    this.revealTargetKey,
  });

  final bool open;
  final bool offstage;
  final Widget control;
  final Widget? actionBar;
  final double startPadding;
  final double endPadding;
  final double bottomPadding;
  final Duration revealDuration;
  final Duration opacityDuration;
  final VoidCallback onRevealEnd;
  final Key? revealTargetKey;

  @override
  Widget build(BuildContext context) {
    final revealedContent = KeyedSubtree(
      key: revealTargetKey,
      child: GestureDetector(
        key: const ValueKey('catch-field-control-tap-barrier'),
        behavior: HitTestBehavior.opaque,
        onTap: () {},
        child: Padding(
          padding: EdgeInsetsDirectional.only(
            start: startPadding,
            end: endPadding,
            top: CatchFieldTokens.controlTopGap,
            bottom: bottomPadding,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              control,
              if (actionBar != null) ...[
                const SizedBox(height: CatchFieldTokens.actionBarTopGap),
                actionBar!,
              ],
            ],
          ),
        ),
      ),
    );

    return ExcludeSemantics(
      excluding: !open,
      child: ExcludeFocus(
        excluding: !open,
        child: IgnorePointer(
          ignoring: !open,
          child: TweenAnimationBuilder<double>(
            key: const ValueKey('catch-field-expansion'),
            duration: revealDuration,
            curve: CatchFieldTokens.curve,
            tween: Tween<double>(end: open ? 1 : 0),
            onEnd: onRevealEnd,
            child: revealedContent,
            builder: (context, reveal, child) => Offstage(
              offstage: offstage || (!open && reveal == 0),
              child: ClipRect(
                clipper: const _CatchFieldDisclosureClipper(),
                child: AnimatedOpacity(
                  key: const ValueKey('catch-field-control-opacity'),
                  duration: opacityDuration,
                  curve: CatchFieldTokens.curve,
                  opacity: open ? 1 : 0,
                  child: Align(
                    alignment: Alignment.topCenter,
                    heightFactor: reveal,
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Fixed-cadence Phosphor spinner from the Field handoff.
class CatchFieldSpinner extends StatefulWidget {
  const CatchFieldSpinner({
    super.key,
    this.size = CatchFieldTokens.spinnerExtent,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  State<CatchFieldSpinner> createState() => _CatchFieldSpinnerState();
}

class _CatchFieldSpinnerState extends State<CatchFieldSpinner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _rotation = AnimationController(
    vsync: this,
    duration: CatchFieldTokens.spinnerPeriod,
  )..repeat();

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      key: const ValueKey('catch-field-spinner'),
      turns: _rotation,
      child: Icon(
        CatchIcons.fieldSpinner,
        size: widget.size,
        color: widget.color,
      ),
    );
  }
}

/// Exact Cancel/Done action used by a disclosed [CatchField] editor.
class CatchFieldCommitButton extends StatefulWidget {
  const CatchFieldCommitButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.primary = false,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool primary;
  final bool loading;

  @override
  State<CatchFieldCommitButton> createState() => _CatchFieldCommitButtonState();
}

class _CatchFieldCommitButtonState extends State<CatchFieldCommitButton> {
  late final FocusNode _focusNode = FocusNode(
    debugLabel: widget.primary
        ? 'CatchField Done button'
        : 'CatchField Cancel button',
  );
  bool _showFocusHighlight = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_updateFocusHighlight);
    FocusManager.instance.addHighlightModeListener(_updateFocusHighlight);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_updateFocusHighlight)
      ..dispose();
    FocusManager.instance.removeHighlightModeListener(_updateFocusHighlight);
    super.dispose();
  }

  void _updateFocusHighlight([FocusHighlightMode? _]) {
    final show =
        _focusNode.hasFocus &&
        FocusManager.instance.highlightMode == FocusHighlightMode.traditional;
    if (show != _showFocusHighlight && mounted) {
      setState(() => _showFocusHighlight = show);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final background = widget.primary ? t.ink : t.surface;
    final foreground = widget.primary ? t.primaryInk : t.ink;
    final button = CatchTextButton(
      label: widget.label,
      onPressed: widget.onPressed,
      foregroundColor: foreground,
      backgroundColor: background,
      disabledForegroundColor: foreground,
      disabledBackgroundColor: background,
      focusNode: _focusNode,
      minimumSize: Size.zero,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchFieldTokens.actionButtonHorizontalPadding,
        vertical: CatchFieldTokens.actionButtonVerticalPadding,
      ),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide(color: widget.primary ? Colors.transparent : t.line2),
      shape: const StadiumBorder(),
      textStyle: CatchTextStyles.fieldRowTitle(context).copyWith(
        fontSize: CatchFieldTokens.actionButtonFontSize,
        fontWeight: FontWeight.w600,
        height: 1,
      ),
      leading: widget.loading
          ? ExcludeSemantics(
              child: SizedBox.square(
                dimension: CatchFieldTokens.actionSpinnerExtent,
                child: CatchFieldSpinner(
                  size: CatchFieldTokens.actionSpinnerExtent,
                  color: foreground,
                ),
              ),
            )
          : null,
      leadingGap: CatchFieldTokens.actionButtonSpinnerGap,
    );
    return Semantics(
      liveRegion: widget.loading,
      child: AnimatedOpacity(
        duration: _fieldDuration(context, CatchFieldTokens.fast),
        curve: CatchFieldTokens.curve,
        opacity: widget.onPressed == null && !widget.primary
            ? CatchFieldTokens.savingCancelOpacity
            : 1,
        child: CatchFieldFocusOutline(
          debugKey: ValueKey(
            widget.primary
                ? 'catch-field-done-focus-outline'
                : 'catch-field-cancel-focus-outline',
          ),
          show: _showFocusHighlight,
          borderRadius: BorderRadius.circular(CatchRadius.pill),
          child: button,
        ),
      ),
    );
  }
}

/// Exact 44x26 switch used by [CatchField.toggle].
class CatchFieldToggle extends StatelessWidget {
  const CatchFieldToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return CatchToggle.field(
      value: value,
      onChanged: onChanged,
      semanticLabel: semanticLabel,
    );
  }
}

/// Exact wrapping chip control used by [CatchField.choices].
class CatchFieldChoiceControl<T> extends StatelessWidget {
  const CatchFieldChoiceControl({
    super.key,
    required this.values,
    required this.itemLabel,
    required this.selected,
    required this.multi,
    required this.onSelectionChanged,
    this.allowEmptySelection = false,
    this.autoClose = false,
    this.enabled = true,
  });

  final List<T> values;
  final String Function(T value) itemLabel;
  final Set<T> selected;
  final bool multi;
  final bool allowEmptySelection;
  final bool autoClose;
  final bool enabled;
  final ValueChanged<Set<T>>? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Wrap(
        spacing: CatchFieldTokens.chipHorizontalGap,
        runSpacing: CatchFieldTokens.chipRunSpacing,
        children: [
          for (final value in values)
            CatchFieldChoiceChip(
              label: itemLabel(value),
              selected: selected.contains(value),
              multi: multi,
              enabled: enabled && onSelectionChanged != null,
              onPressed: () {
                final next = Set<T>.from(selected);
                if (multi) {
                  if (next.contains(value)) {
                    if (!allowEmptySelection && next.length == 1) return;
                    next.remove(value);
                  } else {
                    next.add(value);
                  }
                } else {
                  final wasSelected = next.contains(value);
                  next.clear();
                  if (!wasSelected || !allowEmptySelection) {
                    next.add(value);
                  }
                }
                onSelectionChanged?.call(next);
                if (!multi && autoClose && onSelectionChanged != null) {
                  const _CatchFieldChoicePickedNotification(
                    autoClose: true,
                  ).dispatch(context);
                }
              },
            ),
        ],
      ),
    );
  }
}

class CatchFieldChoiceChip extends StatefulWidget {
  const CatchFieldChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.multi,
    required this.enabled,
    required this.onPressed,
  });

  final String label;
  final bool selected;
  final bool multi;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<CatchFieldChoiceChip> createState() => _CatchFieldChoiceChipState();
}

class CatchFieldFocusOutline extends StatelessWidget {
  const CatchFieldFocusOutline({
    super.key,
    required this.debugKey,
    required this.show,
    required this.borderRadius,
    required this.child,
  });

  final Key debugKey;
  final bool show;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Stack(
      key: debugKey,
      fit: StackFit.passthrough,
      clipBehavior: Clip.none,
      children: [
        child,
        if (show)
          Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: _CatchFieldFocusOutlinePainter(
                  color: t.ink,
                  borderRadius: borderRadius,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _CatchFieldFocusOutlinePainter extends CustomPainter {
  const _CatchFieldFocusOutlinePainter({
    required this.color,
    required this.borderRadius,
  });

  final Color color;
  final BorderRadius borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final reach =
        CatchFieldTokens.focusRingOffset + CatchFieldTokens.focusRingWidth / 2;
    final outline = borderRadius.toRRect(Offset.zero & size).inflate(reach);
    canvas.drawRRect(
      outline,
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = CatchFieldTokens.focusRingWidth,
    );
  }

  @override
  bool shouldRepaint(_CatchFieldFocusOutlinePainter oldDelegate) =>
      color != oldDelegate.color || borderRadius != oldDelegate.borderRadius;
}

class _CatchFieldDisclosureClipper extends CustomClipper<Rect> {
  const _CatchFieldDisclosureClipper();

  @override
  Rect getClip(Size size) => Rect.fromLTRB(
    0,
    0,
    size.width,
    size.height +
        CatchFieldTokens.focusRingOffset +
        CatchFieldTokens.focusRingWidth,
  );

  @override
  bool shouldReclip(_CatchFieldDisclosureClipper oldClipper) => false;
}

class _CatchFieldChoiceChipState extends State<CatchFieldChoiceChip> {
  bool _pressed = false;
  bool _showFocusHighlight = false;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final foreground = widget.selected ? t.primaryInk : t.ink;
    final background = widget.selected ? t.ink : t.surface;
    final visual = AnimatedScale(
      duration: _fieldDuration(
        context,
        _pressed ? CatchFieldTokens.pressIn : CatchFieldTokens.pressOut,
      ),
      curve: CatchFieldTokens.curve,
      scale: _pressed ? CatchFieldTokens.chipPressedScale : 1,
      child: AnimatedContainer(
        key: ValueKey('catch-field-choice-${widget.label}'),
        duration: _fieldDuration(context, CatchFieldTokens.fast),
        curve: CatchFieldTokens.curve,
        constraints: const BoxConstraints(
          minHeight: CatchFieldTokens.chipVisualMinHeight,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: CatchFieldTokens.chipHorizontalPadding,
          vertical: CatchFieldTokens.chipVerticalPadding,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(CatchRadius.pill),
          border: Border.all(color: widget.selected ? t.ink : t.line2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.multi && widget.selected) ...[
              Icon(
                CatchIcons.checkRounded,
                size: CatchFieldTokens.chipSelectedGlyphExtent,
                color: foreground,
              ),
              const SizedBox(width: CatchFieldTokens.chipSelectedGlyphGap),
            ],
            Flexible(
              child: Text(
                widget.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.fieldRowTitle(context, color: foreground)
                    .copyWith(
                      fontSize: CatchFieldTokens.chipFontSize,
                      fontWeight: FontWeight.w600,
                      height: 1,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: widget.enabled,
      checked: widget.selected,
      inMutuallyExclusiveGroup: !widget.multi,
      label: widget.label,
      child: FocusableActionDetector(
        enabled: widget.enabled,
        shortcuts: const <ShortcutActivator, Intent>{
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              widget.onPressed();
              return null;
            },
          ),
        },
        onShowFocusHighlight: (show) {
          if (_showFocusHighlight != show) {
            setState(() => _showFocusHighlight = show);
          }
        },
        child: Opacity(
          opacity: widget.enabled ? 1 : CatchFieldTokens.disabledOpacity,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.enabled ? widget.onPressed : null,
            onTapDown: widget.enabled
                ? (_) => setState(() => _pressed = true)
                : null,
            onTapUp: widget.enabled
                ? (_) => setState(() => _pressed = false)
                : null,
            onTapCancel: widget.enabled
                ? () => setState(() => _pressed = false)
                : null,
            child: CatchFieldFocusOutline(
              debugKey: ValueKey(
                'catch-field-choice-${widget.label}-focus-outline',
              ),
              show: _showFocusHighlight,
              borderRadius: BorderRadius.circular(CatchRadius.pill),
              child: visual,
            ),
          ),
        ),
      ),
    );
  }
}

/// Exact numeric control used by [CatchField.stepper].
class CatchFieldStepper extends StatelessWidget {
  const CatchFieldStepper({
    super.key,
    required this.value,
    required this.onChanged,
    required this.decreaseSemanticLabel,
    required this.increaseSemanticLabel,
    this.min,
    this.max,
    this.step = 1,
    this.unit,
    this.formatter,
    this.enabled = true,
  });

  final num value;
  final ValueChanged<num>? onChanged;
  final num? min;
  final num? max;
  final num step;
  final String? unit;
  final String Function(num value)? formatter;
  final String decreaseSemanticLabel;
  final String increaseSemanticLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final number = formatter?.call(value) ?? _formatNumber(value);
    final formatted = unit == null ? number : '$number $unit';
    return Align(
      alignment: AlignmentDirectional.centerStart,
      child: Row(
        key: const ValueKey('catch-field-stepper'),
        mainAxisSize: MainAxisSize.min,
        children: [
          CatchFieldRepeatButton(
            icon: CatchIcons.removeRounded,
            semanticLabel: decreaseSemanticLabel,
            enabled:
                enabled && onChanged != null && (min == null || value > min!),
            onStep: () => onChanged?.call(_nextValue(-step)),
          ),
          const SizedBox(width: CatchFieldTokens.stepperLayoutGap),
          ConstrainedBox(
            constraints: const BoxConstraints(
              minWidth: CatchFieldTokens.stepperValueMinWidth,
            ),
            child: Text(
              formatted,
              key: const ValueKey('catch-field-stepper-value'),
              maxLines: 1,
              textAlign: TextAlign.center,
              style: CatchTextStyles.fieldRowTitle(context, color: t.ink)
                  .copyWith(
                    fontSize: CatchFieldTokens.stepperValueFontSize,
                    fontWeight: FontWeight.w700,
                    height: CatchFieldTokens.valueLineHeight,
                  ),
            ),
          ),
          const SizedBox(width: CatchFieldTokens.stepperLayoutGap),
          CatchFieldRepeatButton(
            icon: CatchIcons.addRounded,
            semanticLabel: increaseSemanticLabel,
            enabled:
                enabled && onChanged != null && (max == null || value < max!),
            onStep: () => onChanged?.call(_nextValue(step)),
          ),
        ],
      ),
    );
  }

  String _formatNumber(num number) => number == number.roundToDouble()
      ? number.toInt().toString()
      : number.toString();

  num _nextValue(num delta) {
    num next = ((value + delta) * 100).round() / 100;
    if (min != null && next < min!) next = min!;
    if (max != null && next > max!) next = max!;
    return next;
  }
}

/// Hold-to-repeat 44px stepper target used by [CatchFieldStepper].
class CatchFieldRepeatButton extends StatefulWidget {
  const CatchFieldRepeatButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.enabled,
    required this.onStep,
    this.visualAlignment = Alignment.center,
  });

  final IconData icon;
  final String semanticLabel;
  final bool enabled;
  final VoidCallback onStep;
  final AlignmentGeometry visualAlignment;

  @override
  State<CatchFieldRepeatButton> createState() => _CatchFieldRepeatButtonState();
}

class _CatchFieldRepeatButtonState extends State<CatchFieldRepeatButton> {
  Timer? _delay;
  Timer? _repeat;
  int? _pressedPointer;
  int _ticks = 0;
  bool _pressed = false;
  bool _showFocusHighlight = false;

  @override
  void didUpdateWidget(CatchFieldRepeatButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) _stop();
  }

  @override
  void dispose() {
    _stop(updateState: false);
    super.dispose();
  }

  void _start() {
    if (!widget.enabled || _pressed) return;
    _stop();
    setState(() => _pressed = true);
    widget.onStep();
    _delay = Timer(CatchFieldTokens.repeatDelay, _repeatOnce);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pressedPointer != null || event.buttons & kPrimaryButton == 0) return;
    _start();
    if (_pressed) _pressedPointer = event.pointer;
  }

  void _handlePointerEnd(PointerEvent event) {
    if (_pressedPointer != event.pointer) return;
    _pressedPointer = null;
    _stop();
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (_pressedPointer != event.pointer) return;
    final bounds =
        Offset.zero & const Size.square(CatchFieldTokens.stepperHitExtent);
    if (!bounds.contains(event.localPosition)) {
      _pressedPointer = null;
      _stop();
    }
  }

  void _handlePointerExit(PointerExitEvent event) {
    if (_pressedPointer == null) return;
    _pressedPointer = null;
    _stop();
  }

  void _repeatOnce() {
    if (!mounted || !_pressed || !widget.enabled) return;
    widget.onStep();
    _ticks += 1;
    final interval = _ticks > CatchFieldTokens.repeatAccelerationTicks
        ? CatchFieldTokens.repeatAccelerated
        : CatchFieldTokens.repeatNormal;
    _repeat = Timer(interval, _repeatOnce);
  }

  void _stop({bool updateState = true}) {
    _delay?.cancel();
    _repeat?.cancel();
    _delay = null;
    _repeat = null;
    _pressedPointer = null;
    _ticks = 0;
    if (_pressed && updateState && mounted) setState(() => _pressed = false);
    if (!updateState) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = AnimatedScale(
      duration: _fieldDuration(
        context,
        _pressed ? CatchFieldTokens.pressIn : CatchFieldTokens.pressOut,
      ),
      curve: CatchFieldTokens.curve,
      scale: _pressed ? CatchFieldTokens.stepperPressedScale : 1,
      child: DecoratedBox(
        key: ValueKey('catch-field-stepper-${widget.semanticLabel}-visual'),
        decoration: BoxDecoration(
          color: t.surface,
          shape: BoxShape.circle,
          border: Border.all(color: t.line2),
        ),
        child: SizedBox.square(
          dimension: CatchFieldTokens.stepperVisualExtent,
          child: Icon(
            widget.icon,
            size: CatchFieldTokens.stepperGlyphExtent,
            color: t.ink,
          ),
        ),
      ),
    );
    return Tooltip(
      message: widget.semanticLabel,
      child: Semantics(
        button: true,
        enabled: widget.enabled,
        label: widget.semanticLabel,
        onTap: widget.enabled ? widget.onStep : null,
        child: FocusableActionDetector(
          enabled: widget.enabled,
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
            SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
          },
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                widget.onStep();
                return null;
              },
            ),
          },
          onShowFocusHighlight: (show) {
            if (_showFocusHighlight != show) {
              setState(() => _showFocusHighlight = show);
            }
          },
          child: Opacity(
            opacity: widget.enabled
                ? 1
                : CatchFieldTokens.boundedStepperOpacity,
            child: MouseRegion(
              onExit: widget.enabled ? _handlePointerExit : null,
              child: Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: widget.enabled ? _handlePointerDown : null,
                onPointerMove: widget.enabled ? _handlePointerMove : null,
                onPointerUp: widget.enabled ? _handlePointerEnd : null,
                onPointerCancel: widget.enabled ? _handlePointerEnd : null,
                child: CatchFieldFocusOutline(
                  debugKey: ValueKey(
                    'catch-field-stepper-${widget.semanticLabel}-focus-outline',
                  ),
                  show: _showFocusHighlight,
                  borderRadius: BorderRadius.circular(CatchRadius.pill),
                  child: SizedBox.square(
                    dimension: CatchFieldTokens.stepperHitExtent,
                    child: Align(
                      alignment: widget.visualAlignment,
                      child: visual,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
