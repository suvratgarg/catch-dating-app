import 'dart:async';

import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';

part 'catch_field_behavior.dart';
part 'catch_field_configs.dart';
part 'catch_field_control.dart';
part 'catch_field_edit.dart';
part 'catch_field_properties.dart';
part 'catch_field_row_modes.dart';
part 'catch_field_state.dart';
part 'catch_field_text_entry.dart';

/// Design-system `Field`: the unified field primitive for row, text-entry,
/// navigation, toggle, disclosure-control, add, validation, and helper states.
/// Stack fields in a CatchSection when the surrounding section owns box or
/// divider chrome.
///
/// Named constructors reject unsupported mode mixtures, such as a text
/// controller on a toggle. Sections consume its numeric divider geometry.
class CatchField<T> extends StatefulWidget
    with _CatchFieldProperties
    implements CatchFieldDividerGeometry {
  /// Stable key for the contextual pressed surface used by field rows.
  ///
  /// The enclosing section or lane supplies the interaction shape. Divided
  /// fields may reach a page/lane plane or use an inset rounded perimeter;
  /// contained rows remain rectangular bands inside one section-owned clip.
  static const pressOverlayKey = ValueKey<String>('catch-field-press-overlay');

  const CatchField.read({
    required this.copy,
    super.key,
    this.title,
    this.body,
    this.actions,
    int titleMaxLines = 1,
    int bodyMaxLines = 2,
    this.emphasis = CatchFieldEmphasis.body,
    this.tone = CatchFieldTone.normal,
    this.icon,
    this.iconColor,
    Widget? leading,
    this.leadingExtent,
    String? valueText,
    int valueMaxLines = 1,
    String? placeholder,
    bool valid = false,
    this.status = CatchFieldStatus.idle,
  }) : assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       assert(
         leading == null || leadingExtent != null,
         'CatchField.leading requires an explicit leadingExtent.',
       ),
       assert(
         leadingExtent == null || (leading != null && leadingExtent > 0),
         'CatchField.leadingExtent requires non-null leading content.',
       ),
       leading = leading,
       contract = null,
       variant = CatchFieldVariant.row,
       states = const <WidgetState>{},
       child = null,
       meta = null,
       trailing = null,
       _config = (
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         valueText: valueText,
         valueMaxLines: valueMaxLines,
         placeholder: placeholder,
         valid: valid,
         contentRow: false,
         inlineMetadata: null,
         showChevron: null,
         isOptional: false,
         error: null,
         errorText: null,
         onTap: null,
         add: false,
         navigation: false,
       );

  /// A natural-height title plus supporting-copy row.
  ///
  /// The React handoff calls its supporting copy `body`, while legacy Flutter
  /// CatchField rows use [body] as their primary value. Keeping this as an
  /// explicit constructor preserves those existing value rows while exposing
  /// the handoff's independent two-line title and three-line body contract.
  const CatchField.content({
    required this.copy,
    super.key,
    required String this.title,
    required String this.body,
    this.actions,
    VoidCallback? onTap,
    int titleMaxLines = 2,
    int bodyMaxLines = 3,
    this.emphasis = CatchFieldEmphasis.body,
    this.tone = CatchFieldTone.normal,
    this.icon,
    this.iconColor,
    Widget? leading,
    this.leadingExtent,
    String? valueText,
    int valueMaxLines = 1,
    bool? showChevron,
    bool isOptional = false,
    bool valid = false,
    this.status = CatchFieldStatus.idle,
  }) : assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       assert(
         leading == null || leadingExtent != null,
         'CatchField.leading requires an explicit leadingExtent.',
       ),
       assert(
         leadingExtent == null || (leading != null && leadingExtent > 0),
         'CatchField.leadingExtent requires non-null leading content.',
       ),
       leading = leading,
       contract = null,
       variant = CatchFieldVariant.row,
       states = const <WidgetState>{},
       child = null,
       meta = null,
       trailing = null,
       _config = (
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         valueText: valueText,
         valueMaxLines: valueMaxLines,
         showChevron: showChevron,
         isOptional: isOptional,
         valid: valid,
         onTap: onTap,
         contentRow: true,
         inlineMetadata: null,
         placeholder: null,
         error: null,
         errorText: null,
         add: false,
         navigation: onTap != null,
       );

  const CatchField.nav({
    required this.copy,
    super.key,
    this.title,
    this.body,
    this.actions,
    VoidCallback? onTap,
    int titleMaxLines = 1,
    int bodyMaxLines = 2,
    this.emphasis = CatchFieldEmphasis.body,
    this.tone = CatchFieldTone.normal,
    this.icon,
    this.iconColor,
    Widget? leading,
    this.leadingExtent,
    String? valueText,
    int valueMaxLines = 1,
    bool? showChevron,
    String? placeholder,
    String? error,
    String? errorText,
    bool valid = false,
    this.status = CatchFieldStatus.idle,
  }) : assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       assert(
         leading == null || leadingExtent != null,
         'CatchField.leading requires an explicit leadingExtent.',
       ),
       assert(
         leadingExtent == null || (leading != null && leadingExtent > 0),
         'CatchField.leadingExtent requires non-null leading content.',
       ),
       leading = leading,
       contract = null,
       variant = CatchFieldVariant.row,
       states = const <WidgetState>{},
       child = null,
       meta = null,
       trailing = null,
       _config = (
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         valueText: valueText,
         valueMaxLines: valueMaxLines,
         showChevron: showChevron,
         placeholder: placeholder,
         error: error,
         errorText: errorText,
         valid: valid,
         onTap: onTap,
         contentRow: false,
         inlineMetadata: null,
         isOptional: false,
         add: false,
         navigation: true,
       );

  /// A reorderable record with a full-width title and supporting metadata.
  ///
  /// The caller owns drag behavior through [leading]. The field owns the
  /// left-handle lane, naturally wrapping title and metadata, press semantics, and
  /// trailing disclosure affordance.
  const CatchField.sortable({
    required this.copy,
    super.key,
    required String this.title,
    required String metadata,
    required Widget leading,
    required VoidCallback? onTap,
    bool showChevron = true,
  }) : contract = null,
       body = null,
       actions = null,
       emphasis = CatchFieldEmphasis.title,
       tone = CatchFieldTone.normal,
       variant = CatchFieldVariant.row,
       icon = null,
       iconColor = null,
       leading = leading,
       leadingExtent = CatchSpacing.s11,
       states = const <WidgetState>{},
       status = CatchFieldStatus.idle,
       child = null,
       meta = null,
       trailing = null,
       _config = (
         showChevron: showChevron,
         onTap: onTap,
         titleMaxLines: 1,
         bodyMaxLines: 1,
         contentRow: false,
         inlineMetadata: metadata,
         valueText: null,
         valueMaxLines: 1,
         placeholder: null,
         isOptional: false,
         error: null,
         errorText: null,
         valid: false,
         add: false,
         navigation: true,
       );

  /// A tappable field-shaped row whose action does not navigate or edit the
  /// value. Unlike [CatchField.nav], this constructor never renders a chevron.
  const CatchField.action({
    required this.copy,
    super.key,
    this.title,
    this.body,
    this.actions,
    required VoidCallback? onTap,
    int titleMaxLines = 1,
    int bodyMaxLines = 2,
    this.emphasis = CatchFieldEmphasis.body,
    this.tone = CatchFieldTone.normal,
    this.icon,
    this.iconColor,
    Widget? leading,
    this.leadingExtent,
    String? valueText,
    int valueMaxLines = 1,
    String? placeholder,
    String? error,
    String? errorText,
    bool valid = false,
    this.status = CatchFieldStatus.idle,
  }) : assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       assert(
         leading == null || leadingExtent != null,
         'CatchField.leading requires an explicit leadingExtent.',
       ),
       assert(
         leadingExtent == null || (leading != null && leadingExtent > 0),
         'CatchField.leadingExtent requires non-null leading content.',
       ),
       leading = leading,
       contract = null,
       variant = CatchFieldVariant.row,
       states = const <WidgetState>{},
       child = null,
       meta = null,
       trailing = null,
       _config = (
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         valueText: valueText,
         valueMaxLines: valueMaxLines,
         placeholder: placeholder,
         error: error,
         errorText: errorText,
         valid: valid,
         onTap: onTap,
         contentRow: false,
         inlineMetadata: null,
         showChevron: null,
         isOptional: false,
         add: false,
         navigation: false,
       );

  const CatchField.toggle({
    required this.copy,
    super.key,
    this.title,
    this.body,
    this.contract,
    String? contractExemption,
    required bool value,
    required ValueChanged<bool>? onChanged,
    int titleMaxLines = 1,
    int bodyMaxLines = 2,
    this.emphasis = CatchFieldEmphasis.body,
    this.tone = CatchFieldTone.normal,
    this.icon,
    this.iconColor,
    String? helperText,
    String? badgeLabel,
    CatchBadgeTone? badgeTone,
    this.status = CatchFieldStatus.idle,
  }) : actions = null,
       variant = CatchFieldVariant.row,
       leading = null,
       leadingExtent = null,
       states = const <WidgetState>{},
       child = null,
       meta = null,
       trailing = null,
       _config = (
         value: value,
         contractExemption: contractExemption,
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         helperText: helperText,
         badgeLabel: badgeLabel,
         badgeTone: badgeTone,
         onToggleChanged: onChanged,
       );

  const CatchField.input({
    required this.copy,
    super.key,
    required String this.title,
    this.contract,
    String? contractExemption,
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
    FormFieldValidator<String>? onValidate,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    CatchTextInputVariant inputVariant = CatchTextInputVariant.plain,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    bool readOnly = false,
    bool autofocus = false,
    this.states = const <WidgetState>{},
    bool isOptional = false,
    bool showLabel = true,
    String? helperText,
    CatchFieldSupportRowTone helperTone = CatchFieldSupportRowTone.neutral,
    CatchFieldSize size = CatchFieldSize.md,
    TextAlign textAlign = TextAlign.start,
    this.status = CatchFieldStatus.idle,
    bool mono = false,
    Widget? leading,
    String? prefixText,
    this.trailing,
    String? suffixText,
    bool showClearButton = false,
    this.variant = CatchFieldVariant.row,
    this.icon,
    this.iconColor,
    String? leadingUnit,
    this.actions,
    String? error,
    String? errorText,
    VoidCallback? onTap,
  }) : assert(
         inputHint == null || placeholder == null,
         'Use inputHint for editable fields; do not also pass placeholder.',
       ),
       assert(
         controller == null || initialValue == null,
         'CatchField.input cannot include both controller and initialValue.',
       ),
       body = null,
       emphasis = CatchFieldEmphasis.body,
       tone = CatchFieldTone.normal,
       leading = leading,
       leadingExtent = null,
       child = null,
       meta = null,
       _config = (
         controller: controller,
         contractExemption: contractExemption,
         initialValue: initialValue,
         onChanged: onChanged,
         onSubmitted: onSubmitted,
         onBlur: onBlur,
         onFocusChanged: onFocusChanged,
         focusNode: focusNode,
         retainFocusOnSubmitted: retainFocusOnSubmitted,
         onValidate: onValidate,
         keyboardType: keyboardType,
         textInputAction: textInputAction,
         textCapitalization: textCapitalization,
         inputFormatters: inputFormatters,
         autofillHints: autofillHints,
         inputVariant: inputVariant,
         maxLines: maxLines,
         minLines: minLines,
         maxLength: maxLength,
         readOnly: readOnly,
         autofocus: autofocus,
         showLabel: showLabel,
         size: size,
         textAlign: textAlign,
         mono: mono,
         prefixText: prefixText,
         suffixText: suffixText,
         showClearButton: showClearButton,
         placeholder: placeholder,
         emptyValueText: emptyValueText,
         inputHint: inputHint,
         leadingUnit: leadingUnit,
         error: error,
         errorText: errorText,
         onTap: onTap,
         isOptional: isOptional,
         helperText: helperText,
         helperTone: helperTone,
         explicitSave: false,
         open: null,
         onOpenChanged: null,
         onCancel: null,
         onSubmit: null,
         isLoading: false,
       );

  /// A row-owned disclosure control. The row remains stable while [child]
  /// reveals below it. Use [open] for caller-owned edit flows or
  /// [initiallyOpen] for local disclosure state. Save and error state remain
  /// caller-owned.
  const CatchField.control({
    required this.copy,
    super.key,
    required String this.title,
    this.body,
    this.contract,
    String? contractExemption,
    required Widget this.child,
    bool? open,
    bool initiallyOpen = false,
    ValueChanged<bool>? onOpenChanged,
    VoidCallback? onCancel,
    VoidCallback? onSubmit,
    bool isLoading = false,
    this.status = CatchFieldStatus.idle,
    this.states = const <WidgetState>{},
    bool addable = false,
    bool isOptional = false,
    String? helperText,
    int titleMaxLines = 1,
    int bodyMaxLines = 2,
    this.emphasis = CatchFieldEmphasis.body,
    this.tone = CatchFieldTone.normal,
    this.icon,
    this.iconColor,
    String? placeholder,
    String? emptyValueText,
    String? error,
    String? errorText,
  }) : actions = null,
       variant = CatchFieldVariant.row,
       leading = null,
       leadingExtent = null,
       meta = null,
       trailing = null,
       _config = (
         contractExemption: contractExemption,
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         open: open,
         initiallyOpen: initiallyOpen,
         onOpenChanged: onOpenChanged,
         onCancel: onCancel,
         onSubmit: onSubmit,
         isLoading: isLoading,
         addable: addable,
         isOptional: isOptional,
         helperText: helperText,
         placeholder: placeholder,
         emptyValueText: emptyValueText,
         error: error,
         errorText: errorText,
       );

  /// Canonical disclosure field for a wrapping set of single- or multi-select
  /// options. Selection state stays caller-owned; this method owns the exact
  /// chip geometry, wrapping, press motion, and field commit bar.
  factory CatchField.choices({
    required CatchFieldCopy copy,
    Key? key,
    required String title,
    String? body,
    CatchContractFieldConstraints? contract,
    String Function(T value)? contractValueBuilder,
    required List<T> values,
    required String Function(T value) itemLabelBuilder,
    required Set<T> selected,
    required ValueChanged<Set<T>>? onSelectionChanged,
    CatchChipMode mode = CatchChipMode.single,
    bool allowEmptySelection = false,
    bool? open,
    bool initiallyOpen = false,
    ValueChanged<bool>? onOpenChanged,
    VoidCallback? onCancel,
    VoidCallback? onSubmit,
    bool isLoading = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    Set<WidgetState> states = const <WidgetState>{},
    bool addable = false,
    bool isOptional = false,
    String? helperText,
    Color? Function(T item)? itemAccentBuilder,
    IconData? icon,
    Color? iconColor,
    CatchFieldTone tone = CatchFieldTone.normal,
    String? emptyValueText,
    String? error,
    String? errorText,
  }) {
    final supportedValues = CatchContractFieldPolicy.supportedChoiceValues(
      contract,
      values,
      contractValueBuilder,
      multi: mode == CatchChipMode.multiple,
    );
    final supportedSelection = selected.intersection(supportedValues.toSet());
    final selectedSummary = supportedValues
        .where(supportedSelection.contains)
        .map(itemLabelBuilder)
        .join(' · ');
    return CatchField<T>.control(
      copy: copy,
      key: key,
      title: title,
      contract: contract,
      body: body ?? (selectedSummary.isEmpty ? null : selectedSummary),
      child: CatchChoiceInput<T>(
        values: supportedValues,
        selected: supportedSelection,
        allowEmptySelection: allowEmptySelection,
        autoClose: mode == CatchChipMode.single && onSubmit == null,
        mode: mode,
        itemLabelBuilder: itemLabelBuilder,
        itemAccentBuilder: itemAccentBuilder,
        onChanged: !states.contains(WidgetState.disabled) && !isLoading
            ? onSelectionChanged
            : null,
      ),
      open: open,
      initiallyOpen: initiallyOpen,
      onOpenChanged: onOpenChanged,
      onCancel: onCancel,
      onSubmit: onSubmit,
      isLoading: isLoading,
      status: status,
      states: states,
      addable: addable,
      isOptional: isOptional,
      helperText: helperText,
      icon: icon,
      iconColor: iconColor,
      tone: tone,
      emptyValueText: emptyValueText,
      error: error,
      errorText: errorText,
    );
  }

  /// Canonical single-select disclosure for choices that need both a title
  /// and explanatory copy. Terse labels stay in [choices]; policy, admission,
  /// and setup choices use the existing [CatchChoiceTile] primitive through
  /// this field-owned facade.
  factory CatchField.optionCards({
    required CatchFieldCopy copy,
    Key? key,
    required String title,
    String? body,
    CatchContractFieldConstraints? contract,
    String Function(T value)? contractValueBuilder,
    required List<T> values,
    required String Function(T value) itemTitleBuilder,
    required String Function(T value) itemDescriptionBuilder,
    required T selected,
    required ValueChanged<T>? onChanged,
    bool? open,
    bool initiallyOpen = false,
    ValueChanged<bool>? onOpenChanged,
    VoidCallback? onCancel,
    VoidCallback? onSubmit,
    bool isLoading = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    Set<WidgetState> states = const <WidgetState>{},
    String? helperText,
    IconData? icon,
    Color? iconColor,
    CatchFieldTone tone = CatchFieldTone.normal,
    String? error,
    String? errorText,
  }) {
    final supportedValues = CatchContractFieldPolicy.supportedChoiceValues(
      contract,
      values,
      contractValueBuilder,
      multi: false,
    );
    assert(
      supportedValues.isNotEmpty,
      'CatchField.optionCards needs at least one value.',
    );
    assert(
      supportedValues.contains(selected),
      'CatchField.optionCards selected must be allowed by the schema '
      'contract.',
    );
    return CatchField<T>.control(
      copy: copy,
      key: key,
      title: title,
      contract: contract,
      body: body ?? itemTitleBuilder(selected),
      child: CatchChoiceInput<T>.described(
        values: supportedValues,
        selected: {selected},
        autoClose: onSubmit == null,
        onChanged:
            !states.contains(WidgetState.disabled) &&
                !isLoading &&
                onChanged != null
            ? (selection) => onChanged(selection.single)
            : null,
        itemLabelBuilder: itemTitleBuilder,
        itemSubtitleBuilder: itemDescriptionBuilder,
      ),
      open: open,
      initiallyOpen: initiallyOpen,
      onOpenChanged: onOpenChanged,
      onCancel: onCancel,
      onSubmit: onSubmit,
      isLoading: isLoading,
      status: status,
      states: states,
      helperText: helperText,
      icon: icon,
      iconColor: iconColor,
      tone: tone,
      error: error,
      errorText: errorText,
    );
  }

  /// Canonical numeric disclosure field. The revealed control includes a
  /// centered value and accelerated hold-to-repeat on both 44px targets.
  factory CatchField.stepper({
    required CatchFieldCopy copy,
    Key? key,
    required String title,
    String? body,
    CatchContractFieldConstraints? contract,
    required num value,
    required ValueChanged<num>? onChanged,
    num? min,
    num? max,
    num? step,
    String? unit,
    String Function(num value)? valueLabelBuilder,
    required String decreaseSemanticLabel,
    required String increaseSemanticLabel,
    bool? open,
    bool initiallyOpen = false,
    ValueChanged<bool>? onOpenChanged,
    VoidCallback? onCancel,
    VoidCallback? onSubmit,
    bool isLoading = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    Set<WidgetState> states = const <WidgetState>{},
    bool addable = false,
    bool isOptional = false,
    IconData? icon,
    Color? iconColor,
    CatchFieldTone tone = CatchFieldTone.normal,
    String? emptyValueText,
    String? error,
    String? errorText,
  }) {
    assert(
      step == null || step > 0,
      'CatchField.stepper requires a positive step.',
    );
    final effectiveMin = CatchContractFieldPolicy.effectiveMinimum(
      contract,
      min,
    );
    final effectiveMax = CatchContractFieldPolicy.effectiveMaximum(
      contract,
      max,
    );
    final effectiveStep = CatchContractFieldPolicy.effectiveStep(
      contract,
      step,
    );
    return CatchField<T>.control(
      copy: copy,
      key: key,
      title: title,
      contract: contract,
      body: body,
      child: CatchStepper(
        value: value,
        min: effectiveMin,
        max: effectiveMax,
        step: effectiveStep,
        unit: unit,
        valueLabelBuilder: valueLabelBuilder,
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
      states: states,
      addable: addable,
      isOptional: isOptional,
      icon: icon,
      iconColor: iconColor,
      tone: tone,
      emptyValueText: emptyValueText,
      error: error,
      errorText: errorText,
    );
  }

  /// A controlled, explicit-save row editor. The label and value lane stay in
  /// place while supporting content and commit actions animate below them.
  /// Trailing edit affordances, focus timing, typography, and content order are
  /// owned by this primitive rather than by feature call sites.
  const CatchField.inputActions({
    required this.copy,
    super.key,
    required String this.title,
    this.contract,
    String? contractExemption,
    required TextEditingController controller,
    required bool open,
    required ValueChanged<bool> onOpenChanged,
    required VoidCallback onCancel,
    required VoidCallback onSubmit,
    String? placeholder,
    String? emptyValueText,
    String? inputHint,
    this.meta,
    this.actions,
    this.child,
    bool isLoading = false,
    this.status = CatchFieldStatus.idle,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    this.states = const <WidgetState>{},
    this.icon,
    this.iconColor,
    this.tone = CatchFieldTone.normal,
    String? error,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onBlur,
    ValueChanged<bool>? onFocusChanged,
    FocusNode? focusNode,
  }) : body = null,
       emphasis = CatchFieldEmphasis.body,
       variant = CatchFieldVariant.row,
       leading = null,
       leadingExtent = null,
       trailing = null,
       _config = (
         controller: controller,
         contractExemption: contractExemption,
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
         placeholder: placeholder,
         emptyValueText: emptyValueText,
         inputHint: inputHint,
         error: error,
         open: open,
         onOpenChanged: onOpenChanged,
         onCancel: onCancel,
         onSubmit: onSubmit,
         isLoading: isLoading,
         initialValue: null,
         retainFocusOnSubmitted: false,
         onValidate: null,
         inputVariant: CatchTextInputVariant.plain,
         readOnly: false,
         autofocus: false,
         isOptional: false,
         showLabel: true,
         helperText: null,
         helperTone: CatchFieldSupportRowTone.neutral,
         size: CatchFieldSize.md,
         textAlign: TextAlign.start,
         mono: false,
         prefixText: null,
         suffixText: null,
         showClearButton: false,
         leadingUnit: null,
         errorText: null,
         onTap: null,
         explicitSave: true,
       );

  const CatchField.add({
    required this.copy,
    super.key,
    required String this.title,
    VoidCallback? onTap,
    this.icon,
    this.tone = CatchFieldTone.primary,
  }) : contract = null,
       body = null,
       actions = null,
       emphasis = CatchFieldEmphasis.body,
       variant = CatchFieldVariant.row,
       iconColor = null,
       leading = null,
       leadingExtent = null,
       states = const <WidgetState>{},
       status = CatchFieldStatus.idle,
       child = null,
       meta = null,
       trailing = null,
       _config = (
         onTap: onTap,
         titleMaxLines: 1,
         bodyMaxLines: 2,
         contentRow: false,
         inlineMetadata: null,
         valueText: null,
         valueMaxLines: 1,
         showChevron: null,
         placeholder: null,
         isOptional: false,
         error: null,
         errorText: null,
         valid: false,
         add: true,
         navigation: true,
       );

  const CatchField._select({
    required this.copy,
    super.key,
    required String this.title,
    this.contract,
    String? contractExemption,
    required List<Object?> values,
    required String Function(Object? item) itemLabelBuilder,
    required Object? value,
    required ValueChanged<Object?>? onSelectChanged,
    required FormFieldValidator<Object?>? selectValidator,
    required String? placeholder,
    required Widget? leading,
    required bool showLabel,
    required CatchFieldSize size,
    required String? helperText,
    required CatchFieldSupportRowTone helperTone,
    required this.states,
  }) : body = null,
       actions = null,
       emphasis = CatchFieldEmphasis.body,
       tone = CatchFieldTone.normal,
       variant = CatchFieldVariant.row,
       icon = null,
       iconColor = null,
       leading = leading,
       leadingExtent = null,
       status = CatchFieldStatus.idle,
       child = null,
       meta = null,
       trailing = null,
       _config = (
         values: values,
         contractExemption: contractExemption,
         itemLabelBuilder: itemLabelBuilder,
         value: value,
         onSelectChanged: onSelectChanged,
         selectValidator: selectValidator,
         placeholder: placeholder,
         showLabel: showLabel,
         size: size,
         helperText: helperText,
         helperTone: helperTone,
       );

  factory CatchField.select({
    required CatchFieldCopy copy,
    Key? key,
    required String title,
    CatchContractFieldConstraints? contract,
    String? contractExemption,
    String Function(T value)? contractValueBuilder,
    required List<T> values,
    required String Function(T item) itemLabelBuilder,
    T? value,
    String? hintText,
    Widget? leading,
    ValueChanged<T?>? onChanged,
    FormFieldValidator<T>? onValidate,
    Set<WidgetState> states = const <WidgetState>{},
    bool showLabel = true,
    CatchFieldSize size = CatchFieldSize.md,
    String? helperText,
    CatchFieldSupportRowTone helperTone = CatchFieldSupportRowTone.neutral,
  }) {
    final supportedValues = CatchContractFieldPolicy.supportedChoiceValues(
      contract,
      values,
      contractValueBuilder,
      multi: false,
    );
    assert(
      supportedValues.toSet().length == supportedValues.length,
      'CatchField.select values must be unique.',
    );
    return CatchField<T>._select(
      copy: copy,
      key: key,
      title: title,
      contract: contract,
      contractExemption: contractExemption,
      values: List<Object?>.unmodifiable(supportedValues),
      itemLabelBuilder: (item) => itemLabelBuilder(item as T),
      value: value,
      onSelectChanged: onChanged == null
          ? null
          : (item) => onChanged(item as T?),
      selectValidator: onValidate == null
          ? null
          : (item) => onValidate(item as T?),
      placeholder: hintText,
      leading: leading,
      showLabel: showLabel,
      size: size,
      helperText: helperText,
      helperTone: helperTone,
      states: states,
    );
  }

  static const double compactControlHeight =
      CatchControlMetrics.compactMinHeight;
  static const double mdControlHeight = CatchControlMetrics.mdMinHeight;

  /// Canonical at-rest copy for an empty editable row.
  static String defaultEmptyValueText(CatchFieldCopy copy, String title) =>
      copy.emptyValueText(title);

  /// Resolves an optional domain override without repeating the field label.
  static String resolveEmptyValueText(
    CatchFieldCopy copy, {
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
    return defaultEmptyValueText(copy, label);
  }

  /// Resolved copy supplied by the caller for the current locale.
  final CatchFieldCopy copy;

  /// Primary row text or input label.
  final String? title;

  /// Generated schema constraint bound to this editable field.
  @override
  final CatchContractFieldConstraints? contract;

  /// Supporting row text.
  final String? body;

  /// End-aligned row action or input suffix.
  final Widget? actions;

  // Explicit-save actions belong to the revealed area, never the native suffix.
  bool get _hasRowActions => !_explicitSaveInput && actions != null;

  @override
  final Record _config;
  final CatchFieldEmphasis emphasis;
  final CatchFieldTone tone;
  final CatchFieldVariant variant;
  final IconData? icon;
  final Color? iconColor;

  /// Caller-owned leading content used instead of [icon].
  final Widget? leading;

  bool get _hasInputLeading =>
      leading != null && (_editConfig != null || _selectConfig != null);
  bool get _hasRowLeading => leading != null && !_hasInputLeading;

  /// Horizontal extent of caller-owned [leading] content. Sections use this
  /// to align dividers to the actual text lane instead of assuming icon size.
  final double? leadingExtent;

  /// Caller-owned disabled and focus presentation; native focus stays local.
  @override
  final Set<WidgetState> states;
  final CatchFieldStatus status;

  @override
  double get fieldDividerLeadingInset => add
      ? 0
      : _hasRowLeading
      ? (leadingExtent ?? CatchFieldTokens.leadingIconExtent) +
            CatchFieldTokens.leadingGap
      : icon != null || _hasInputLeading
      ? CatchFieldTokens.textLaneInset
      : 0;

  final Widget? child;
  final Widget? meta;
  final Widget? trailing;

  // All modes retain one identity when a keyed field changes generic input type.
  @override
  Type get runtimeType => CatchField;

  @override
  State<CatchField> createState() => _CatchFieldState();
}
