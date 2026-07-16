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
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_toggle.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'catch_field_control.dart';
part 'catch_field_edit.dart';
part 'catch_field_lanes.dart';
part 'catch_field_row_modes.dart';
part 'catch_field_scopes.dart';
part 'catch_field_state.dart';

enum CatchFieldMode { edit, read, nav, toggle, select }

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
class CatchField extends StatefulWidget {
  /// Internal mode/parameter contract.
  ///
  /// | Parameter group | edit | read | nav | toggle | select |
  /// | --- | --- | --- | --- | --- | --- |
  /// | text controller, validation, input chrome | yes | no | no | no | no |
  /// | read/content/value lanes | no | yes | yes | yes | no |
  /// | disclosure control and commit actions | explicit-save only | no | yes | no | no |
  /// | toggle value and callback | no | no | no | yes | no |
  /// | select values, label, validator, callback | no | no | no | no | yes |
  ///
  /// Public named constructors are the supported way to satisfy this matrix.
  /// These assertions keep internal wiring mistakes visible without changing
  /// release behavior or weakening the const facade API.
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
    this.leading,
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
    this.badgeLabel,
    this.badgeTone,
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
       ),
       assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       assert(
         mode == CatchFieldMode.toggle || onToggle == null,
         'Toggle callbacks are only valid for CatchField.toggle.',
       ),
       assert(
         mode == CatchFieldMode.select ||
             (_selectValues == null &&
                 _selectItemLabel == null &&
                 _onSelectChanged == null &&
                 _selectValidator == null),
         'Select configuration is only valid for CatchField.select.',
       ),
       assert(
         control == null || mode == CatchFieldMode.nav,
         'Disclosure controls are only valid for navigation-mode fields.',
       ),
       assert(
         !_explicitSaveInput ||
             (mode == CatchFieldMode.edit &&
                 controller != null &&
                 open != null),
         'Explicit-save fields require edit mode, a controller, and controlled open state.',
       ),
       assert(
         (_onCancel == null && _onSubmit == null) ||
             control != null ||
             _explicitSaveInput,
         'Commit actions require a disclosure control or explicit-save input.',
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
    Widget? leading,
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
         leading: leading,
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
    Widget? leading,
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
         leading: leading,
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
    Widget? leading,
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
         leading: leading,
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
    Widget? leading,
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
         leading: leading,
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
    String? helperText,
    String? badgeLabel,
    CatchBadgeTone? badgeTone,
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
         helperText: helperText,
         badgeLabel: badgeLabel,
         badgeTone: badgeTone,
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
    String? helperText,
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
         helperText: helperText,
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

  /// End-aligned text for compact read and navigation rows.
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

  /// Caller-owned leading content used instead of [icon].
  final Widget? leading;
  final String? leadingUnit;
  final bool? showChevron;

  final String? placeholder;
  final String? emptyValueText;
  final String? inputHint;
  final bool toggled;
  final ValueChanged<bool>? onToggle;

  /// Control revealed by a navigation-mode disclosure field.
  final Widget? control;
  final bool initiallyOpen;

  /// Caller-owned disclosure state; null keeps expansion local.
  final bool? open;
  final ValueChanged<bool>? onOpenChanged;
  final bool _explicitSaveInput;
  final Widget? _supporting;
  final Widget? _secondaryAction;
  final Widget? _feedback;

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
  final String? badgeLabel;
  final CatchBadgeTone? badgeTone;
  final CatchFieldSize size;
  final TextAlign textAlign;
  final bool focused;
  final bool mono;
  final Widget? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final String? suffixText;

  final bool showClearButton;
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
  final CatchFieldStatus status;

  @override
  State<CatchField> createState() => _CatchFieldState();
}
