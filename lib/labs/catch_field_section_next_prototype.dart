// TEMPORARY REVIEW PROTOTYPE.
//
// This file intentionally has no production imports. It is a compileable
// reference implementation for reviewing the proposed CatchField/CatchSection
// changes before any existing primitive, profile surface, contract, or caller
// is modified.

// Keep explicit design-token arguments even when they currently equal a
// Flutter constructor default; the lab is the executable token specification.
// ignore_for_file: avoid_redundant_argument_values

import 'dart:async';

import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_divider.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_menu.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

enum CatchFieldNextStatus { idle, saving, saved }

enum CatchFieldNextShell { row, underline }

enum CatchFieldNextSupportTone { neutral, brand, success }

enum CatchFieldSectionNextVariant { contained, divided }

typedef CatchFieldNextSaveCallback = FutureOr<void> Function();

/// Field-specific geometry and motion kept local until the prototype is
/// accepted. Promotion should move these values into the shared token source,
/// not duplicate them in production widgets.
abstract final class CatchFieldNextTokens {
  // Row geometry from the updated form-field handoff.
  static const double rowHorizontalPadding = 16;
  static const double flushBleed = 10;
  static const double rowVerticalPadding = 12;
  static const double leadingIcon = 18;
  static const double leadingGap = 14;
  static const double textLaneInset = leadingIcon + leadingGap;
  static const double captionHeight = 18;

  /// The handoff references `--field-value-line` without publishing its value.
  /// Nineteen keeps a 14px value at 1.35 line height on the documented grid.
  static const double valueLineHeight = 19;

  static const double controlTopGap = 10;
  static const double actionBarTopGap = 16;

  // Trailing lane and glyphs.
  static const double disclosureIcon = 16;
  static const double clearIcon = 17;
  static const double validIcon = 18;
  static const double statusSpinner = 15;
  static const double statusTick = 16;
  static const double statusSpinnerStroke = 1.8;
  static const double trailingGap = 8;
  static const double clearHitTarget = 32;
  static const double disclosureLaneReserve = disclosureIcon + trailingGap;
  static const double valueTextMaxWidth = 160;

  // Stroke, radii, and focus geometry.
  static const double underlineActive = 2;
  static const double focusRingWidth = 2;
  static const double raisedRingWidth = 1;
  static const double raisedVerticalOverlap = 1;
  static const double dividerHairline = 1;
  static const double sectionStroke = 1;
  static const double tileRadius = 12;
  static const double sectionRadius = 14;

  // Typography. These intentionally override older shared 13/15px roles only
  // inside the review lab; production typography remains untouched.
  static const double valueFontSize = 14;
  static const double captionFontSize = 11.5;
  static const double counterFontSize = 10.5;
  static const double chipFontSize = 14;
  static const double buttonFontSize = 14;
  static const double stepperValueFontSize = 14;
  static const double paceUnitFontSize = 10;
  static const double valueTextLineHeight = 1.35;
  static const double supportTextLineHeight = 1.45;
  static const double controlTextLineHeight = 1;

  // Toggle.
  static const double toggleWidth = 44;
  static const double toggleHeight = 26;
  static const double togglePadding = 3;
  static const double toggleKnob = toggleHeight - (togglePadding * 2);

  // Stepper.
  static const double stepperHitTarget = 44;
  static const double stepperVisual = 32;
  static const double stepperInlineGap = 12;
  static const double stepperCompactInlineGap = 10;
  static const double stepperVisualEdgeInset =
      (stepperHitTarget - stepperVisual) / 2;
  static const double stepperValueMinWidth = 56;
  static const double stepperCompactValueMinWidth = 52;
  static const double stepperPreferredWidth =
      (stepperHitTarget * 2) + (stepperInlineGap * 2) + stepperValueMinWidth;

  // Chips. The Wrap lays out 44px hit boxes around 40px visuals, so a 4px
  // outer run spacing produces the specified 8px visible chip-to-chip gap.
  static const double chipHitTarget = 44;
  static const double chipVisualHeight = 40;
  static const double chipHorizontalGap = 8;
  static const double chipVerticalGap = 8;
  static const double chipHorizontalPadding = 14;
  static const double chipVerticalPadding = 8;
  static const double chipRunSpacing =
      chipVerticalGap - (chipHitTarget - chipVisualHeight);
  static const double chipSelectedGlyphGap = 6;

  // Cancel / Done bar. Breakpoint and minimum widths are named provisional
  // values because the handoff lists their behavior but not their tokens.
  static const double actionBarWrapBreakpoint = 240;
  static const double actionButtonHorizontalPadding = 18;
  static const double actionButtonVerticalPadding = 10;
  static const double actionButtonGap = 8;
  static const double actionButtonHitTarget = 44;
  static const double actionButtonBorderWidth = 1;
  static const double cancelButtonMinWidth = 78;
  static const double doneButtonMinWidth = 68;

  // Custom-control and supporting geometry found as remaining raw constants in
  // the master example and this lab preview.
  static const double customControlHorizontalPadding = 14;
  static const double customControlVerticalPadding = 12;
  static const double customControlRowGap = 10;
  static const double customControlValueWidth = 52;
  static const double customControlLabelFontSize = 9.5;
  static const double customControlLabelSourceFontSize = 11;
  static const double customControlLabelScale =
      customControlLabelFontSize / customControlLabelSourceFontSize;
  static const FontWeight customControlLabelFontWeight = FontWeight.w400;
  static const double customControlValueFontSize = 15;
  static const FontWeight customControlValueFontWeight = FontWeight.w700;
  static const FontWeight paceUnitFontWeight = FontWeight.w500;
  static const double selectMenuWidth = 280;
  static const double supportBottomPadding = 10;
  static const double supportItemGap = 8;
  static const double errorIconGap = 6;
  static const double inputAdornmentGap = 4;
  static const double underlineLabelGap = 8;
  static const double underlineBottomPadding = 4;
  static const double sectionContentVerticalPadding = 12;
  static const double sectionHeaderGap = 8;
  static const double sectionFooterGap = 8;

  // State values.
  static const double activeTintAlpha = 0.04;
  static const double pressedTintAlpha = 0.06;
  static const double hoverTintAlpha = 0.03;
  static const double rowPressScale = 0.97;
  static const double chipPressScale = 0.97;
  static const double stepperPressScale = 0.92;
  static const double disabledForegroundAlpha = 0.4;
  static const double disabledBackgroundAlpha = 0.72;
  static const double chipSublabelAlpha = 0.72;
  static const int repeatAccelerationTicks = 10;

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration standard = Duration(milliseconds: 200);
  static const Duration reveal = Duration(milliseconds: 300);
  static const Duration pressIn = Duration(milliseconds: 80);
  static const Duration pressOut = Duration(milliseconds: 180);
  static const Duration repeatDelay = Duration(milliseconds: 400);
  static const Duration repeatNormal = Duration(milliseconds: 110);
  static const Duration repeatAccelerated = Duration(milliseconds: 55);
  static const Duration simulatedSave = Duration(seconds: 1);
  static const Duration savedStatusHold = Duration(milliseconds: 900);
  static const Curve curve = Cubic(0.2, 0.7, 0.2, 1);

  // The export says the lift deepens in dark mode but omits exact values. Keep
  // these provisional values isolated here until the shipped CSS is supplied.
  static const Color _lightLiftColor = Color.fromRGBO(26, 20, 16, 0.10);
  static const Color _darkLiftColor = Color.fromRGBO(0, 0, 0, 0.36);
  static const double _lightLiftBlur = 18;
  static const double _darkLiftBlur = 22;
  static const double _lightLiftOffset = 6;
  static const double _darkLiftOffset = 8;

  static List<BoxShadow> activeLift(Brightness brightness) => <BoxShadow>[
    BoxShadow(
      color: brightness == Brightness.dark ? _darkLiftColor : _lightLiftColor,
      blurRadius: brightness == Brightness.dark
          ? _darkLiftBlur
          : _lightLiftBlur,
      offset: Offset(
        0,
        brightness == Brightness.dark ? _darkLiftOffset : _lightLiftOffset,
      ),
    ),
  ];
}

enum _CatchFieldNextKind {
  read,
  navigation,
  action,
  toggle,
  input,
  disclosure,
  chips,
  stepper,
  select,
  add,
}

@immutable
class _CatchFieldNextConfig {
  const _CatchFieldNextConfig({
    required this.kind,
    required this.label,
    this.shell = CatchFieldNextShell.row,
    this.value,
    this.valueText,
    this.placeholder,
    this.emptyValueText,
    this.helper,
    this.helperTone = CatchFieldNextSupportTone.neutral,
    this.error,
    this.errorAction,
    this.optional = false,
    this.disabled = false,
    this.valid = false,
    this.clearable = false,
    this.mono = false,
    this.status = CatchFieldNextStatus.idle,
    this.statusSemanticsLabel,
    this.icon,
    this.iconColor,
    this.leading,
    this.trailing,
    this.onTap,
    this.toggleValue,
    this.onToggle,
    this.controller,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.onBlur,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.autofillHints,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.control,
    this.open,
    this.initiallyOpen = false,
    this.onOpenChanged,
    this.onSave,
    this.onCancel,
    this.saving = false,
    this.saveErrorText,
    this.options,
    this.optionLabel,
    this.optionSublabel,
    this.selectedValues,
    this.multi = false,
    this.allowEmptySingleSelection = false,
    this.onSelectionChanged,
    this.onImmediateCommit,
    this.numberValue,
    this.numberMin,
    this.numberMax,
    this.numberStep = 1,
    this.numberUnit,
    this.numberFormatter,
    this.onNumberChanged,
    this.onNumberValueTap,
    this.selectValue,
    this.onSelectChanged,
  }) : assert(
         controller == null || initialValue == null,
         'CatchFieldNext.input cannot take controller and initialValue.',
       ),
       assert(
         numberStep > 0,
         'CatchFieldNext.stepper requires a positive step.',
       );

  final _CatchFieldNextKind kind;
  final String label;
  final CatchFieldNextShell shell;
  final String? value;
  final String? valueText;
  final String? placeholder;
  final String? emptyValueText;
  final String? helper;
  final CatchFieldNextSupportTone helperTone;
  final String? error;
  final Widget? errorAction;
  final bool optional;
  final bool disabled;
  final bool valid;
  final bool clearable;
  final bool mono;
  final CatchFieldNextStatus status;
  final String? statusSemanticsLabel;
  final IconData? icon;
  final Color? iconColor;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final TextEditingController? controller;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onBlur;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final Widget? control;
  final bool? open;
  final bool initiallyOpen;
  final ValueChanged<bool>? onOpenChanged;
  final CatchFieldNextSaveCallback? onSave;
  final VoidCallback? onCancel;
  final bool saving;
  final String Function(Object error)? saveErrorText;
  final List<Object?>? options;
  final String Function(Object? value)? optionLabel;
  final String? Function(Object? value)? optionSublabel;
  final Set<Object?>? selectedValues;
  final bool multi;
  final bool allowEmptySingleSelection;
  final ValueChanged<Set<Object?>>? onSelectionChanged;
  final CatchFieldNextSaveCallback? onImmediateCommit;
  final num? numberValue;
  final num? numberMin;
  final num? numberMax;
  final num numberStep;
  final String? numberUnit;
  final String Function(num value)? numberFormatter;
  final ValueChanged<num>? onNumberChanged;
  final VoidCallback? onNumberValueTap;
  final Object? selectValue;
  final ValueChanged<Object?>? onSelectChanged;
}

/// Isolated vNext field prototype.
///
/// Named entry points remain capability-specific while every constructor
/// normalizes into one private configuration. This preserves compile-time
/// validity at Dart call sites without duplicating rendering/state behavior.
class CatchFieldNext extends StatefulWidget {
  const CatchFieldNext._({super.key, required this._config});

  CatchFieldNext.read({
    Key? key,
    required String label,
    String? value,
    String? valueText,
    String? placeholder,
    String? helper,
    CatchFieldNextSupportTone helperTone = CatchFieldNextSupportTone.neutral,
    String? error,
    Widget? errorAction,
    bool optional = false,
    bool disabled = false,
    bool valid = false,
    bool mono = false,
    CatchFieldNextStatus status = CatchFieldNextStatus.idle,
    String? statusSemanticsLabel,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    Widget? trailing,
  }) : this._(
         key: key,
         config: _CatchFieldNextConfig(
           kind: _CatchFieldNextKind.read,
           label: label,
           value: value,
           valueText: valueText,
           placeholder: placeholder,
           helper: helper,
           helperTone: helperTone,
           error: error,
           errorAction: errorAction,
           optional: optional,
           disabled: disabled,
           valid: valid,
           mono: mono,
           status: status,
           statusSemanticsLabel: statusSemanticsLabel,
           icon: icon,
           iconColor: iconColor,
           leading: leading,
           trailing: trailing,
         ),
       );

  CatchFieldNext.nav({
    Key? key,
    required String label,
    required VoidCallback? onTap,
    String? value,
    String? valueText,
    String? placeholder,
    String? emptyValueText,
    String? helper,
    String? error,
    Widget? errorAction,
    bool optional = false,
    bool disabled = false,
    bool valid = false,
    CatchFieldNextStatus status = CatchFieldNextStatus.idle,
    String? statusSemanticsLabel,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    Widget? trailing,
  }) : this._(
         key: key,
         config: _CatchFieldNextConfig(
           kind: _CatchFieldNextKind.navigation,
           label: label,
           value: value,
           valueText: valueText,
           placeholder: placeholder,
           emptyValueText: emptyValueText,
           helper: helper,
           error: error,
           errorAction: errorAction,
           optional: optional,
           disabled: disabled,
           valid: valid,
           status: status,
           statusSemanticsLabel: statusSemanticsLabel,
           icon: icon,
           iconColor: iconColor,
           leading: leading,
           trailing: trailing,
           onTap: onTap,
         ),
       );

  CatchFieldNext.action({
    Key? key,
    required String label,
    required VoidCallback? onTap,
    String? value,
    String? helper,
    String? error,
    Widget? errorAction,
    bool disabled = false,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    Widget? trailing,
  }) : this._(
         key: key,
         config: _CatchFieldNextConfig(
           kind: _CatchFieldNextKind.action,
           label: label,
           value: value,
           helper: helper,
           error: error,
           errorAction: errorAction,
           disabled: disabled,
           icon: icon,
           iconColor: iconColor,
           leading: leading,
           trailing: trailing,
           onTap: onTap,
         ),
       );

  CatchFieldNext.toggle({
    Key? key,
    required String label,
    required bool value,
    required ValueChanged<bool>? onChanged,
    String? helper,
    String? error,
    Widget? errorAction,
    bool optional = false,
    bool disabled = false,
    CatchFieldNextStatus status = CatchFieldNextStatus.idle,
    String? statusSemanticsLabel,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
  }) : this._(
         key: key,
         config: _CatchFieldNextConfig(
           kind: _CatchFieldNextKind.toggle,
           label: label,
           helper: helper,
           error: error,
           errorAction: errorAction,
           optional: optional,
           disabled: disabled,
           status: status,
           statusSemanticsLabel: statusSemanticsLabel,
           icon: icon,
           iconColor: iconColor,
           leading: leading,
           toggleValue: value,
           onToggle: onChanged,
         ),
       );

  CatchFieldNext.input({
    Key? key,
    required String label,
    CatchFieldNextShell shell = CatchFieldNextShell.row,
    TextEditingController? controller,
    String? initialValue,
    ValueChanged<String>? onChanged,
    ValueChanged<String>? onSubmitted,
    ValueChanged<String>? onBlur,
    FocusNode? focusNode,
    String? placeholder,
    String? emptyValueText,
    String? helper,
    CatchFieldNextSupportTone helperTone = CatchFieldNextSupportTone.neutral,
    String? error,
    Widget? errorAction,
    bool optional = false,
    bool disabled = false,
    bool valid = false,
    bool clearable = false,
    bool mono = false,
    CatchFieldNextStatus status = CatchFieldNextStatus.idle,
    String? statusSemanticsLabel,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    TextCapitalization textCapitalization = TextCapitalization.sentences,
    List<TextInputFormatter>? inputFormatters,
    Iterable<String>? autofillHints,
    bool obscureText = false,
    int? maxLines = 1,
    int? minLines,
    int? maxLength,
    bool autofocus = false,
  }) : this._(
         key: key,
         config: _CatchFieldNextConfig(
           kind: _CatchFieldNextKind.input,
           label: label,
           shell: shell,
           controller: controller,
           initialValue: initialValue,
           onChanged: onChanged,
           onSubmitted: onSubmitted,
           onBlur: onBlur,
           focusNode: focusNode,
           placeholder: placeholder,
           emptyValueText: emptyValueText,
           helper: helper,
           helperTone: helperTone,
           error: error,
           errorAction: errorAction,
           optional: optional,
           disabled: disabled,
           valid: valid,
           clearable: clearable,
           mono: mono,
           status: status,
           statusSemanticsLabel: statusSemanticsLabel,
           icon: icon,
           iconColor: iconColor,
           leading: leading,
           keyboardType: keyboardType,
           textInputAction: textInputAction,
           textCapitalization: textCapitalization,
           inputFormatters: inputFormatters,
           autofillHints: autofillHints,
           obscureText: obscureText,
           maxLines: maxLines,
           minLines: minLines,
           maxLength: maxLength,
           autofocus: autofocus,
         ),
       );

  CatchFieldNext.control({
    Key? key,
    required String label,
    required Widget control,
    String? value,
    String? valueText,
    String? placeholder,
    String? emptyValueText,
    String? helper,
    String? error,
    Widget? errorAction,
    bool optional = false,
    bool disabled = false,
    bool mono = false,
    CatchFieldNextStatus status = CatchFieldNextStatus.idle,
    String? statusSemanticsLabel,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    bool? open,
    bool initiallyOpen = false,
    ValueChanged<bool>? onOpenChanged,
    CatchFieldNextSaveCallback? onSave,
    VoidCallback? onCancel,
    bool saving = false,
    String Function(Object error)? saveErrorText,
  }) : this._(
         key: key,
         config: _CatchFieldNextConfig(
           kind: _CatchFieldNextKind.disclosure,
           label: label,
           value: value,
           valueText: valueText,
           placeholder: placeholder,
           emptyValueText: emptyValueText,
           helper: helper,
           error: error,
           errorAction: errorAction,
           optional: optional,
           disabled: disabled,
           mono: mono,
           status: status,
           statusSemanticsLabel: statusSemanticsLabel,
           icon: icon,
           iconColor: iconColor,
           leading: leading,
           control: control,
           open: open,
           initiallyOpen: initiallyOpen,
           onOpenChanged: onOpenChanged,
           onSave: onSave,
           onCancel: onCancel,
           saving: saving,
           saveErrorText: saveErrorText,
         ),
       );

  static CatchFieldNext chips<T>({
    Key? key,
    required String label,
    required List<T> options,
    required String Function(T option) optionLabel,
    String? Function(T option)? optionSublabel,
    required Set<T> selected,
    required ValueChanged<Set<T>> onChanged,
    bool multi = false,
    bool allowEmptySingleSelection = false,
    CatchFieldNextSaveCallback? onImmediateCommit,
    CatchFieldNextSaveCallback? onSave,
    VoidCallback? onCancel,
    bool? open,
    bool initiallyOpen = false,
    ValueChanged<bool>? onOpenChanged,
    bool saving = false,
    String? summaryText,
    String? valueText,
    String? placeholder,
    String? emptyValueText,
    String? helper,
    String? error,
    Widget? errorAction,
    bool optional = false,
    bool disabled = false,
    CatchFieldNextStatus status = CatchFieldNextStatus.idle,
    String? statusSemanticsLabel,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
  }) {
    final resolvedSummary =
        summaryText ??
        (selected.isEmpty
            ? null
            : selected.map(optionLabel).join(multi ? ' · ' : ''));
    return CatchFieldNext._(
      key: key,
      config: _CatchFieldNextConfig(
        kind: _CatchFieldNextKind.chips,
        label: label,
        value: resolvedSummary,
        valueText: valueText,
        placeholder: placeholder,
        emptyValueText: emptyValueText,
        helper: helper,
        error: error,
        errorAction: errorAction,
        optional: optional,
        disabled: disabled,
        status: status,
        statusSemanticsLabel: statusSemanticsLabel,
        icon: icon,
        iconColor: iconColor,
        leading: leading,
        open: open,
        initiallyOpen: initiallyOpen,
        onOpenChanged: onOpenChanged,
        onSave: onSave,
        onCancel: onCancel,
        saving: saving,
        options: List<Object?>.unmodifiable(options),
        optionLabel: (value) => optionLabel(value as T),
        optionSublabel: optionSublabel == null
            ? null
            : (value) => optionSublabel(value as T),
        selectedValues: Set<Object?>.unmodifiable(selected),
        multi: multi,
        allowEmptySingleSelection: allowEmptySingleSelection,
        onSelectionChanged: (next) => onChanged(Set<T>.from(next.cast<T>())),
        onImmediateCommit: onImmediateCommit,
      ),
    );
  }

  CatchFieldNext.stepper({
    Key? key,
    required String label,
    required num value,
    required ValueChanged<num> onChanged,
    num? min,
    num? max,
    num step = 1,
    String? unit,
    String Function(num value)? formatValue,
    VoidCallback? onValueTap,
    CatchFieldNextSaveCallback? onSave,
    VoidCallback? onCancel,
    bool? open,
    bool initiallyOpen = false,
    ValueChanged<bool>? onOpenChanged,
    bool saving = false,
    String? helper,
    String? error,
    Widget? errorAction,
    bool optional = false,
    bool disabled = false,
    CatchFieldNextStatus status = CatchFieldNextStatus.idle,
    String? statusSemanticsLabel,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
  }) : this._(
         key: key,
         config: _CatchFieldNextConfig(
           kind: _CatchFieldNextKind.stepper,
           label: label,
           value: unit == null ? '$value' : '$value $unit',
           helper: helper,
           error: error,
           errorAction: errorAction,
           optional: optional,
           disabled: disabled,
           status: status,
           statusSemanticsLabel: statusSemanticsLabel,
           icon: icon,
           iconColor: iconColor,
           leading: leading,
           open: open,
           initiallyOpen: initiallyOpen,
           onOpenChanged: onOpenChanged,
           onSave: onSave,
           onCancel: onCancel,
           saving: saving,
           numberValue: value,
           numberMin: min,
           numberMax: max,
           numberStep: step,
           numberUnit: unit,
           numberFormatter: formatValue,
           onNumberChanged: onChanged,
           onNumberValueTap: onValueTap,
         ),
       );

  static CatchFieldNext select<T>({
    Key? key,
    required String label,
    required List<T> options,
    required String Function(T option) optionLabel,
    String? Function(T option)? optionSublabel,
    T? value,
    required ValueChanged<T?>? onChanged,
    String? placeholder,
    String? helper,
    String? error,
    Widget? errorAction,
    bool optional = false,
    bool disabled = false,
    bool valid = false,
    CatchFieldNextStatus status = CatchFieldNextStatus.idle,
    String? statusSemanticsLabel,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
  }) {
    return CatchFieldNext._(
      key: key,
      config: _CatchFieldNextConfig(
        kind: _CatchFieldNextKind.select,
        label: label,
        value: value == null ? null : optionLabel(value),
        placeholder: placeholder,
        helper: helper,
        error: error,
        errorAction: errorAction,
        optional: optional,
        disabled: disabled,
        valid: valid,
        status: status,
        statusSemanticsLabel: statusSemanticsLabel,
        icon: icon,
        iconColor: iconColor,
        leading: leading,
        options: List<Object?>.unmodifiable(options),
        optionLabel: (option) => optionLabel(option as T),
        optionSublabel: optionSublabel == null
            ? null
            : (option) => optionSublabel(option as T),
        selectValue: value,
        onSelectChanged: onChanged == null
            ? null
            : (next) => onChanged(next as T?),
      ),
    );
  }

  CatchFieldNext.add({
    Key? key,
    required String label,
    required VoidCallback? onTap,
    bool disabled = false,
    IconData? icon,
  }) : this._(
         key: key,
         config: _CatchFieldNextConfig(
           kind: _CatchFieldNextKind.add,
           label: label,
           disabled: disabled,
           icon: icon,
           onTap: onTap,
         ),
       );

  final _CatchFieldNextConfig _config;

  bool get hasLeading =>
      _config.icon != null || _config.kind == _CatchFieldNextKind.add;

  @override
  State<CatchFieldNext> createState() => _CatchFieldNextState();
}

class _CatchFieldDismissIntent extends Intent {
  const _CatchFieldDismissIntent();
}

class _CatchFieldNextState extends State<CatchFieldNext> {
  late TextEditingController _controller;
  late FocusNode _inputFocusNode;
  final MenuController _menuController = MenuController();
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _open = false;
  bool _rowFocused = false;
  bool _pressed = false;
  int? _pressedPointer;
  bool _hovered = false;
  bool _submitting = false;
  bool _hadInputFocus = false;
  String? _saveFailure;

  _CatchFieldNextConfig get c => widget._config;
  bool get _isOpen => c.open ?? _open;
  bool get _disabled => c.disabled;
  bool get _isInput => c.kind == _CatchFieldNextKind.input;
  bool get _hasError => (c.error ?? _saveFailure)?.trim().isNotEmpty ?? false;
  bool get _isSaving =>
      c.saving || _submitting || c.status == CatchFieldNextStatus.saving;
  bool get _reducedMotion =>
      MediaQuery.maybeOf(context)?.disableAnimations ?? false;
  bool get _active => _isOpen || _inputFocusNode.hasFocus || _rowFocused;

  @override
  void initState() {
    super.initState();
    _open = c.initiallyOpen;
    _bindController();
    _bindFocusNode();
  }

  @override
  void didUpdateWidget(CatchFieldNext oldWidget) {
    super.didUpdateWidget(oldWidget);
    final old = oldWidget._config;
    if (old.controller != c.controller) {
      _controller.removeListener(_handleControllerChanged);
      if (_ownsController) _controller.dispose();
      _bindController();
    } else if (_ownsController && old.initialValue != c.initialValue) {
      final next = c.initialValue ?? '';
      if (_controller.text != next) _controller.text = next;
    }
    if (old.focusNode != c.focusNode) {
      _inputFocusNode.removeListener(_handleInputFocusChanged);
      if (_ownsFocusNode) _inputFocusNode.dispose();
      _bindFocusNode();
    }
    if (old.open != c.open && c.open != null && _open != c.open) {
      _open = c.open!;
    }
    if (old.error != c.error && c.error != null) _saveFailure = null;
  }

  @override
  void dispose() {
    _controller.removeListener(_handleControllerChanged);
    _inputFocusNode.removeListener(_handleInputFocusChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _inputFocusNode.dispose();
    super.dispose();
  }

  void _bindController() {
    _ownsController = c.controller == null;
    _controller = c.controller ?? TextEditingController(text: c.initialValue);
    _controller.addListener(_handleControllerChanged);
  }

  void _bindFocusNode() {
    _ownsFocusNode = c.focusNode == null;
    _inputFocusNode = c.focusNode ?? FocusNode();
    _inputFocusNode.addListener(_handleInputFocusChanged);
    _hadInputFocus = _inputFocusNode.hasFocus;
  }

  void _handleControllerChanged() {
    if (mounted) setState(() {});
  }

  void _handleInputFocusChanged() {
    final focused = _inputFocusNode.hasFocus;
    if (!focused && _hadInputFocus) c.onBlur?.call(_controller.text);
    _hadInputFocus = focused;
    if (mounted) setState(() {});
  }

  Duration _duration(Duration value) => _reducedMotion ? Duration.zero : value;

  void _setOpen(bool next, {bool cancel = false}) {
    if (_disabled || _isSaving || next == _isOpen) return;
    if (!next && cancel && c.onSave != null) c.onCancel?.call();
    _saveFailure = null;
    if (c.open == null) setState(() => _open = next);
    c.onOpenChanged?.call(next);
  }

  void _dismiss() {
    if (_isOpen) _setOpen(false, cancel: true);
    if (_inputFocusNode.hasFocus) _inputFocusNode.unfocus();
    if (_menuController.isOpen) _menuController.close();
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (_pressedPointer != null) return;
    _pressedPointer = event.pointer;
    if (!_pressed) setState(() => _pressed = true);
  }

  void _handlePointerEnd(PointerEvent event) {
    if (_pressedPointer != event.pointer) return;
    _pressedPointer = null;
    if (_pressed) setState(() => _pressed = false);
  }

  Future<void> _save() async {
    final callback = c.onSave;
    if (callback == null || _isSaving) return;
    setState(() {
      _submitting = true;
      _saveFailure = null;
    });
    try {
      await Future<void>.sync(callback);
      if (!mounted) return;
      if (c.open == null) setState(() => _open = false);
      c.onOpenChanged?.call(false);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saveFailure = c.saveErrorText?.call(error));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  VoidCallback? get _rowAction {
    if (_disabled || _isSaving) return null;
    return switch (c.kind) {
      _CatchFieldNextKind.navigation || _CatchFieldNextKind.action => c.onTap,
      _CatchFieldNextKind.toggle =>
        c.onToggle == null
            ? null
            : () => c.onToggle!.call(!(c.toggleValue ?? false)),
      _CatchFieldNextKind.input => () => _inputFocusNode.requestFocus(),
      _CatchFieldNextKind.disclosure ||
      _CatchFieldNextKind.chips ||
      _CatchFieldNextKind.stepper => () => _setOpen(!_isOpen),
      _CatchFieldNextKind.select => () {
        if (_menuController.isOpen) {
          _menuController.close();
        } else {
          _menuController.open();
        }
      },
      _CatchFieldNextKind.add => c.onTap,
      _CatchFieldNextKind.read => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final shortcuts = <ShortcutActivator, Intent>{
      const SingleActivator(LogicalKeyboardKey.escape):
          const _CatchFieldDismissIntent(),
    };
    final field = Shortcuts(
      shortcuts: shortcuts,
      child: Actions(
        actions: <Type, Action<Intent>>{
          _CatchFieldDismissIntent: CallbackAction<_CatchFieldDismissIntent>(
            onInvoke: (_) {
              _dismiss();
              return null;
            },
          ),
        },
        child: TapRegion(
          onTapOutside: (_) => _dismiss(),
          child: _buildForKind(context),
        ),
      ),
    );
    return Semantics(
      liveRegion: c.status != CatchFieldNextStatus.idle,
      label: c.statusSemanticsLabel,
      child: AnimatedOpacity(
        duration: _duration(CatchFieldNextTokens.fast),
        curve: CatchFieldNextTokens.curve,
        opacity: _disabled ? CatchOpacity.disabledControl : 1,
        child: IgnorePointer(ignoring: _disabled, child: field),
      ),
    );
  }

  Widget _buildForKind(BuildContext context) {
    if (c.kind == _CatchFieldNextKind.select) {
      final options = c.options ?? const <Object?>[];
      return MenuAnchor(
        controller: _menuController,
        menuChildren: <Widget>[
          CatchMenu<Object?>(
            width: CatchFieldNextTokens.selectMenuWidth,
            items: options
                .map(
                  (option) => CatchMenuItem<Object?>(
                    value: option,
                    label: c.optionLabel?.call(option) ?? '$option',
                    sublabel: c.optionSublabel?.call(option),
                    selected: option == c.selectValue,
                  ),
                )
                .toList(growable: false),
            onSelected: (value, _) {
              c.onSelectChanged?.call(value);
              _menuController.close();
            },
          ),
        ],
        builder: (context, controller, _) => _buildFieldBody(context),
      );
    }
    return _buildFieldBody(context);
  }

  Widget _buildFieldBody(BuildContext context) {
    if (c.shell == CatchFieldNextShell.underline && _isInput) {
      return _buildUnderlineField(context);
    }
    return _buildRowField(context);
  }

  Widget _buildRowField(BuildContext context) {
    final row = _buildInteractiveRow(context);
    final support = _buildSupport(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [row, ?support],
    );
  }

  Widget _buildInteractiveRow(BuildContext context) {
    final t = CatchTokens.of(context);
    final action = _rowAction;
    final horizontalInset = _rowContentInset(context);
    final sectionScope = CatchFieldSectionNextScope.maybeOf(context);
    final overlayBleed =
        sectionScope?.variant == CatchFieldSectionNextVariant.divided
        ? CatchFieldNextTokens.flushBleed
        : 0.0;
    final activeTint = Color.alphaBlend(
      t.ink.withValues(alpha: CatchFieldNextTokens.activeTintAlpha),
      t.surface,
    );
    final pressedTint = Color.alphaBlend(
      t.ink.withValues(alpha: CatchFieldNextTokens.pressedTintAlpha),
      t.surface,
    );
    final focusShadow = _rowFocused && action != null
        ? <BoxShadow>[
            BoxShadow(
              color: t.ink,
              spreadRadius: CatchFieldNextTokens.focusRingWidth,
            ),
          ]
        : const <BoxShadow>[];
    final lift = _active
        ? CatchFieldNextTokens.activeLift(Theme.of(context).brightness)
        : const <BoxShadow>[];
    final activeDecoration = BoxDecoration(
      color: _active ? activeTint : Colors.transparent,
      borderRadius: BorderRadius.circular(CatchFieldNextTokens.tileRadius),
      border: _active
          ? Border.all(
              color: t.line,
              width: CatchFieldNextTokens.raisedRingWidth,
            )
          : null,
      boxShadow: <BoxShadow>[...lift, ...focusShadow],
    );
    final pressedDecoration = BoxDecoration(
      color: _pressed ? pressedTint : Colors.transparent,
      borderRadius: BorderRadius.circular(CatchFieldNextTokens.tileRadius),
      border: _pressed
          ? Border.all(
              color: t.line,
              width: CatchFieldNextTokens.raisedRingWidth,
            )
          : null,
    );
    final leading = _leading(context);
    final trailing = _trailing(context);
    final rowContent = _buildRowContent(
      context,
      disclosureTrailing: _supportsDisclosure ? trailing : null,
    );
    final paddedRow = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalInset,
        vertical: CatchFieldNextTokens.rowVerticalPadding,
      ),
      child: Row(
        crossAxisAlignment: _centersRowVertically
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          if (leading != null) ...[
            Padding(
              padding: EdgeInsets.only(top: _baselineTopInset),
              child: leading,
            ),
            const SizedBox(width: CatchFieldNextTokens.leadingGap),
          ],
          Expanded(child: rowContent),
          if (!_supportsDisclosure && trailing != null) ...[
            const SizedBox(width: CatchFieldNextTokens.trailingGap),
            Padding(
              padding: EdgeInsets.only(top: _baselineTopInset),
              child: trailing,
            ),
          ],
        ],
      ),
    );
    final animated = Stack(
      clipBehavior: Clip.none,
      children: [
        PositionedDirectional(
          start: -overlayBleed,
          end: -overlayBleed,
          top: -CatchFieldNextTokens.raisedVerticalOverlap,
          bottom: -CatchFieldNextTokens.raisedVerticalOverlap,
          child: IgnorePointer(
            child: AnimatedContainer(
              duration: _duration(CatchFieldNextTokens.standard),
              curve: CatchFieldNextTokens.curve,
              decoration: activeDecoration,
            ),
          ),
        ),
        PositionedDirectional(
          start: -overlayBleed,
          end: -overlayBleed,
          top: -CatchFieldNextTokens.raisedVerticalOverlap,
          bottom: -CatchFieldNextTokens.raisedVerticalOverlap,
          child: IgnorePointer(
            child: AnimatedContainer(
              duration: _duration(
                _pressed
                    ? CatchFieldNextTokens.pressIn
                    : CatchFieldNextTokens.pressOut,
              ),
              curve: CatchFieldNextTokens.curve,
              decoration: pressedDecoration,
            ),
          ),
        ),
        paddedRow,
      ],
    );
    final scaled = AnimatedScale(
      duration: _duration(CatchFieldNextTokens.pressIn),
      curve: CatchFieldNextTokens.curve,
      scale: _pressed && c.kind == _CatchFieldNextKind.add
          ? CatchFieldNextTokens.rowPressScale
          : 1,
      child: animated,
    );
    if (action == null) return scaled;
    final mouseCursor = _isInput
        ? SystemMouseCursors.text
        : SystemMouseCursors.click;
    final hoverLayer = AnimatedContainer(
      duration: _duration(CatchFieldNextTokens.fast),
      color: _hovered && !_pressed && !_active
          ? t.ink.withValues(alpha: CatchFieldNextTokens.hoverTintAlpha)
          : Colors.transparent,
      child: scaled,
    );
    final tapRegion = _isInput
        ? TextFieldTapRegion(child: hoverLayer)
        : hoverLayer;
    return Semantics(
      button: c.kind != _CatchFieldNextKind.input,
      enabled: !_disabled,
      expanded: _supportsDisclosure ? _isOpen : null,
      toggled: c.kind == _CatchFieldNextKind.toggle ? c.toggleValue : null,
      child: MouseRegion(
        cursor: mouseCursor,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: FocusableActionDetector(
          mouseCursor: mouseCursor,
          onShowFocusHighlight: (focused) =>
              setState(() => _rowFocused = focused),
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) {
                action();
                return null;
              },
            ),
          },
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: _handlePointerDown,
            onPointerUp: _handlePointerEnd,
            onPointerCancel: _handlePointerEnd,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: action,
              child: tapRegion,
            ),
          ),
        ),
      ),
    );
  }

  Widget? _leading(BuildContext context) {
    final t = CatchTokens.of(context);
    if (c.kind == _CatchFieldNextKind.add) {
      return Icon(
        c.icon ?? CatchIcons.add,
        size: CatchFieldNextTokens.leadingIcon,
        color: CatchTokens.of(context).primary,
      );
    }
    if (c.icon == null) return null;
    return Icon(
      c.icon,
      size: CatchFieldNextTokens.leadingIcon,
      color: c.iconColor ?? (_active ? t.ink : t.ink2),
    );
  }

  Widget _buildRowContent(BuildContext context, {Widget? disclosureTrailing}) {
    final t = CatchTokens.of(context);
    if (c.kind == _CatchFieldNextKind.add) {
      return Text(
        c.label,
        style: CatchTextStyles.fieldRowTitle(context, color: t.primary),
      );
    }
    if (_supportsDisclosure) {
      return _buildDisclosureRowContent(context, trailing: disclosureTrailing);
    }
    final emptyAdd = _emptyAddText;
    if (_isInput && (_inputFocusNode.hasFocus || _controller.text.isNotEmpty)) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [_buildLabel(context), _buildTextField(context, row: true)],
      );
    }
    if (emptyAdd != null) {
      return Text.rich(
        TextSpan(
          text: emptyAdd,
          children: [
            if (c.optional)
              TextSpan(
                text: ' · ${context.l10n.coreCatchFormFieldLabelTextOptional}',
                style: CatchTextStyles.fieldRowTitle(context, color: t.ink3),
              ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: CatchTextStyles.fieldRowTitle(context, color: t.primary),
      );
    }
    final displayed = _displayValue;
    if (displayed == null &&
        (c.kind == _CatchFieldNextKind.read ||
            c.kind == _CatchFieldNextKind.toggle ||
            c.kind == _CatchFieldNextKind.action)) {
      return Text(
        c.label,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: CatchTextStyles.fieldRowTitle(context, color: t.ink),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(context),
        if (displayed != null) ...[
          _buildValueLine(
            Text(
              displayed,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _rowValueStyle(context, color: t.ink),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDisclosureRowContent(BuildContext context, {Widget? trailing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildDisclosureHeader(context)),
            if (trailing != null) ...[
              const SizedBox(width: CatchFieldNextTokens.trailingGap),
              Padding(
                padding: EdgeInsets.only(top: _baselineTopInset),
                child: trailing,
              ),
            ],
          ],
        ),
        _buildDisclosureDrawer(context),
      ],
    );
  }

  Widget _buildDisclosureHeader(BuildContext context) {
    final t = CatchTokens.of(context);
    final emptyAdd = _emptyAddText;
    if (emptyAdd != null) {
      return Text.rich(
        TextSpan(
          text: emptyAdd,
          children: [
            if (c.optional)
              TextSpan(
                text: ' · ${context.l10n.coreCatchFormFieldLabelTextOptional}',
                style: CatchTextStyles.fieldRowTitle(context, color: t.ink3),
              ),
          ],
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: CatchTextStyles.fieldRowTitle(context, color: t.primary),
      );
    }
    final displayed = _displayValue;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildLabel(context),
        if (displayed != null) ...[
          _buildValueLine(
            Text(
              displayed,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: _rowValueStyle(context, color: t.ink),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLabel(BuildContext context) {
    final t = CatchTokens.of(context);
    final color = _hasError
        ? t.danger
        : _active
        ? t.ink
        : t.ink3;
    return Semantics(
      label: c.optional
          ? context.l10n.coreCatchFormFieldLabelLabelLabelOptional(
              label: c.label,
            )
          : c.label,
      excludeSemantics: true,
      child: SizedBox(
        height: CatchFieldNextTokens.captionHeight,
        child: Align(
          alignment: AlignmentDirectional.centerStart,
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: _isInput && c.leading != null
                  ? CatchFieldNextTokens.leadingIcon
                  : 0,
            ),
            child: Text.rich(
              TextSpan(
                text: c.label,
                children: [
                  if (c.optional)
                    TextSpan(
                      text:
                          ' · ${context.l10n.coreCatchFormFieldLabelTextOptional}',
                      style: CatchTextStyles.fieldLabel(context, color: t.ink3)
                          .copyWith(
                            fontSize: CatchFieldNextTokens.captionFontSize,
                          ),
                    ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.fieldLabel(
                context,
                color: color,
              ).copyWith(fontSize: CatchFieldNextTokens.captionFontSize),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildValueLine(Widget child) {
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: CatchFieldNextTokens.valueLineHeight,
      ),
      child: Align(alignment: AlignmentDirectional.centerStart, child: child),
    );
  }

  String? get _displayValue {
    if (_isInput) {
      if (_controller.text.isNotEmpty) return _controller.text;
      return c.placeholder;
    }
    if (c.value?.trim().isNotEmpty ?? false) return c.value;
    return c.placeholder;
  }

  String? get _emptyAddText {
    if (_isOpen) return null;
    final hasValue =
        (c.value?.trim().isNotEmpty ?? false) ||
        (c.valueText?.trim().isNotEmpty ?? false) ||
        (_isInput && _controller.text.isNotEmpty);
    if (hasValue || c.placeholder != null) return null;
    final editable = switch (c.kind) {
      _CatchFieldNextKind.navigation ||
      _CatchFieldNextKind.input ||
      _CatchFieldNextKind.disclosure ||
      _CatchFieldNextKind.chips ||
      _CatchFieldNextKind.stepper ||
      _CatchFieldNextKind.select => true,
      _ => false,
    };
    if (!editable) return null;
    return c.emptyValueText ??
        context.l10n.coreCatchFieldVisiblecopyAddFieldLabel(
          fieldLabel: c.label,
        );
  }

  bool get _supportsDisclosure => switch (c.kind) {
    _CatchFieldNextKind.disclosure ||
    _CatchFieldNextKind.chips ||
    _CatchFieldNextKind.stepper => true,
    _ => false,
  };

  bool get _rowUsesSingleLine =>
      !_isOpen && c.kind == _CatchFieldNextKind.add ||
      (!_isOpen && _emptyAddText != null) ||
      (!_isOpen && !_isInput && _displayValue == null);

  bool get _centersRowVertically => c.kind == _CatchFieldNextKind.toggle;

  double get _baselineTopInset =>
      _centersRowVertically || _rowUsesSingleLine || _clearVisible
      ? 0
      : CatchFieldNextTokens.captionHeight;

  bool get _clearVisible =>
      _isInput && c.clearable && _controller.text.isNotEmpty && !_isSaving;

  Widget? _trailing(BuildContext context) {
    final t = CatchTokens.of(context);
    if (c.status == CatchFieldNextStatus.saving || c.saving || _submitting) {
      return SizedBox.square(
        dimension: CatchFieldNextTokens.statusSpinner,
        child: CatchLoadingIndicator(
          strokeWidth: CatchFieldNextTokens.statusSpinnerStroke,
          color: t.ink,
        ),
      );
    }
    if (c.status == CatchFieldNextStatus.saved) {
      return Icon(
        CatchIcons.checkRounded,
        key: const ValueKey<String>('catch-field-next-saved'),
        size: CatchFieldNextTokens.statusTick,
        color: t.success,
      );
    }
    if (c.valid) {
      return Icon(
        CatchIcons.checkCircle,
        size: CatchFieldNextTokens.validIcon,
        color: t.success,
      );
    }
    if (c.kind == _CatchFieldNextKind.toggle) {
      return CatchFieldNextToggle(
        value: c.toggleValue ?? false,
        enabled: !_disabled && c.onToggle != null,
        semanticLabel: c.label,
        onChanged: c.onToggle,
      );
    }
    if (_clearVisible) {
      return IconButton(
        tooltip: context.l10n.coreCatchFieldTooltipClearValue1(value1: c.label),
        visualDensity: VisualDensity.compact,
        constraints: const BoxConstraints.tightFor(
          width: CatchFieldNextTokens.clearHitTarget,
          height: CatchFieldNextTokens.clearHitTarget,
        ),
        alignment: Alignment.centerRight,
        padding: EdgeInsets.zero,
        style: IconButton.styleFrom(
          minimumSize: const Size.square(CatchFieldNextTokens.clearHitTarget),
          fixedSize: const Size.square(CatchFieldNextTokens.clearHitTarget),
          maximumSize: const Size.square(CatchFieldNextTokens.clearHitTarget),
          padding: EdgeInsets.zero,
          visualDensity: VisualDensity.compact,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          alignment: Alignment.centerRight,
        ),
        onPressed: () {
          _controller.clear();
          c.onChanged?.call('');
        },
        icon: Icon(
          CatchIcons.clearCircle,
          size: CatchFieldNextTokens.clearIcon,
          color: t.ink3,
        ),
      );
    }
    if (c.trailing != null) return c.trailing;
    final valueText = !_isOpen && (c.valueText?.trim().isNotEmpty ?? false)
        ? ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: CatchFieldNextTokens.valueTextMaxWidth,
            ),
            child: Text(
              c.valueText!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: CatchTextStyles.supporting(context, color: t.ink),
            ),
          )
        : null;
    if (_supportsDisclosure) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?valueText,
          if (valueText != null)
            const SizedBox(width: CatchFieldNextTokens.trailingGap),
          AnimatedRotation(
            duration: _duration(CatchFieldNextTokens.standard),
            curve: CatchFieldNextTokens.curve,
            turns: _isOpen ? 0.5 : 0,
            child: Icon(
              PhosphorIconsRegular.caretDown,
              size: CatchFieldNextTokens.disclosureIcon,
              color: _isOpen ? t.ink : t.ink3,
            ),
          ),
        ],
      );
    }
    if (c.kind == _CatchFieldNextKind.navigation && c.onTap != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?valueText,
          if (valueText != null)
            const SizedBox(width: CatchFieldNextTokens.trailingGap),
          Icon(
            PhosphorIconsRegular.caretRight,
            size: CatchFieldNextTokens.disclosureIcon,
            color: t.ink3,
          ),
        ],
      );
    }
    if (c.kind == _CatchFieldNextKind.select && c.onSelectChanged != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?valueText,
          if (valueText != null)
            const SizedBox(width: CatchFieldNextTokens.trailingGap),
          Icon(
            PhosphorIconsRegular.caretDown,
            size: CatchFieldNextTokens.disclosureIcon,
            color: t.ink3,
          ),
        ],
      );
    }
    return valueText;
  }

  Widget? _buildSupport(BuildContext context) {
    final t = CatchTokens.of(context);
    final error = c.error ?? _saveFailure;
    final showCounter =
        _isInput && c.maxLength != null && _inputFocusNode.hasFocus;
    if ((error == null || error.isEmpty) && c.helper == null && !showCounter) {
      return null;
    }
    final hasLeading = widget.hasLeading;
    final contentInset = _rowContentInset(context);
    final start =
        contentInset + (hasLeading ? CatchFieldNextTokens.textLaneInset : 0);
    final helperColor = switch (c.helperTone) {
      CatchFieldNextSupportTone.neutral => t.ink3,
      CatchFieldNextSupportTone.brand => t.primary,
      CatchFieldNextSupportTone.success => t.success,
    };
    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(
        start,
        0,
        contentInset,
        CatchFieldNextTokens.supportBottomPadding,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: error != null && error.isNotEmpty
                ? Semantics(
                    liveRegion: true,
                    container: true,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          CatchIcons.errorOutlineRounded,
                          size: CatchIcon.sm,
                          color: t.danger,
                        ),
                        const SizedBox(
                          width: CatchFieldNextTokens.errorIconGap,
                        ),
                        Expanded(
                          child: Text(
                            error,
                            style:
                                CatchTextStyles.supporting(
                                  context,
                                  color: t.danger,
                                ).copyWith(
                                  fontSize:
                                      CatchFieldNextTokens.captionFontSize,
                                ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Text(
                    c.helper ?? '',
                    style:
                        CatchTextStyles.fieldLabel(
                          context,
                          color: helperColor,
                        ).copyWith(
                          fontSize: CatchFieldNextTokens.captionFontSize,
                          fontWeight: FontWeight.w400,
                          height: CatchFieldNextTokens.supportTextLineHeight,
                        ),
                  ),
          ),
          if (showCounter) ...[
            const SizedBox(width: CatchFieldNextTokens.supportItemGap),
            Text(
              '${_controller.text.characters.length} / ${c.maxLength}',
              style: CatchTextStyles.monoLabel(
                context,
                color: t.ink3,
              ).copyWith(fontSize: CatchFieldNextTokens.counterFontSize),
            ),
          ],
          if (error != null && error.isNotEmpty && c.errorAction != null) ...[
            const SizedBox(width: CatchFieldNextTokens.supportItemGap),
            c.errorAction!,
          ],
        ],
      ),
    );
  }

  Widget _buildDisclosureDrawer(BuildContext context) {
    final content = switch (c.kind) {
      _CatchFieldNextKind.disclosure => c.control,
      _CatchFieldNextKind.chips => _buildChips(context),
      _CatchFieldNextKind.stepper => _buildStepper(context),
      _ => null,
    };
    if (content == null) return const SizedBox.shrink();

    final drawer = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: CatchFieldNextTokens.controlTopGap),
        content,
        if (c.onSave != null) ...[
          const SizedBox(height: CatchFieldNextTokens.actionBarTopGap),
          _buildCommitBar(context),
        ],
      ],
    );
    return ExcludeSemantics(
      excluding: !_isOpen,
      child: IgnorePointer(
        ignoring: !_isOpen,
        child: TweenAnimationBuilder<double>(
          duration: _duration(CatchFieldNextTokens.reveal),
          curve: CatchFieldNextTokens.curve,
          tween: Tween<double>(end: _isOpen ? 1 : 0),
          child: drawer,
          builder: (context, reveal, child) => ClipRect(
            child: Align(
              alignment: Alignment.topCenter,
              heightFactor: reveal,
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCommitBar(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cancel = _buildCommitButton(
          context,
          key: const ValueKey<String>('catch-field-next-cancel'),
          label: context.l10n.coreCatchFieldLabelCancel,
          primary: false,
          minimumWidth: CatchFieldNextTokens.cancelButtonMinWidth,
          onPressed: _isSaving ? null : () => _setOpen(false, cancel: true),
        );
        final done = _buildCommitButton(
          context,
          key: const ValueKey<String>('catch-field-next-done'),
          label: _isSaving ? 'Saving…' : context.l10n.coreCatchFieldLabelDone,
          primary: true,
          loading: _isSaving,
          minimumWidth: CatchFieldNextTokens.doneButtonMinWidth,
          onPressed: _isSaving ? null : _save,
        );
        if (constraints.maxWidth <
            CatchFieldNextTokens.actionBarWrapBreakpoint) {
          return Wrap(
            key: const ValueKey<String>('catch-field-next-commit-bar'),
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: CatchFieldNextTokens.actionButtonGap,
            runSpacing: CatchFieldNextTokens.actionButtonGap,
            children: [cancel, done],
          );
        }
        return Row(
          key: const ValueKey<String>('catch-field-next-commit-bar'),
          children: [
            const Spacer(),
            cancel,
            const SizedBox(width: CatchFieldNextTokens.actionButtonGap),
            done,
          ],
        );
      },
    );
  }

  Widget _buildCommitButton(
    BuildContext context, {
    required Key key,
    required String label,
    required bool primary,
    required double minimumWidth,
    required VoidCallback? onPressed,
    bool loading = false,
  }) {
    final t = CatchTokens.of(context);
    final background = primary ? t.ink : t.surface;
    final foreground = primary ? t.bg : t.ink;
    return TextButton(
      key: key,
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: foreground,
        backgroundColor: background,
        disabledForegroundColor: foreground.withValues(
          alpha: CatchFieldNextTokens.disabledForegroundAlpha,
        ),
        disabledBackgroundColor: background.withValues(
          alpha: CatchFieldNextTokens.disabledBackgroundAlpha,
        ),
        minimumSize: Size(
          minimumWidth,
          CatchFieldNextTokens.actionButtonHitTarget,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: CatchFieldNextTokens.actionButtonHorizontalPadding,
          vertical: CatchFieldNextTokens.actionButtonVerticalPadding,
        ),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        side: BorderSide(
          color: primary ? Colors.transparent : t.line2,
          width: CatchFieldNextTokens.actionButtonBorderWidth,
        ),
        shape: const StadiumBorder(),
        textStyle: CatchTextStyles.fieldRowTitle(context, color: foreground)
            .copyWith(
              fontSize: CatchFieldNextTokens.buttonFontSize,
              height: CatchFieldNextTokens.controlTextLineHeight,
            ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (loading) ...[
            SizedBox.square(
              dimension: CatchFieldNextTokens.statusSpinner,
              child: CatchLoadingIndicator(
                strokeWidth: CatchFieldNextTokens.statusSpinnerStroke,
                color: foreground,
              ),
            ),
            const SizedBox(width: CatchFieldNextTokens.actionButtonGap),
          ],
          Text(label),
        ],
      ),
    );
  }

  Widget _buildChips(BuildContext context) {
    final options = c.options ?? const <Object?>[];
    final selected = c.selectedValues ?? const <Object?>{};
    return Wrap(
      spacing: CatchFieldNextTokens.chipHorizontalGap,
      runSpacing: CatchFieldNextTokens.chipRunSpacing,
      children: options
          .map((option) {
            final isSelected = selected.contains(option);
            return CatchFieldNextChoiceChip(
              label: c.optionLabel?.call(option) ?? '$option',
              sublabel: c.optionSublabel?.call(option),
              selected: isSelected,
              multi: c.multi,
              enabled: !_disabled && !_isSaving,
              onPressed: () async {
                final next = Set<Object?>.from(selected);
                if (c.multi) {
                  if (isSelected) {
                    next.remove(option);
                  } else {
                    next.add(option);
                  }
                } else {
                  next.clear();
                  if (!(isSelected &&
                      c.allowEmptySingleSelection &&
                      c.optional)) {
                    next.add(option);
                  }
                }
                c.onSelectionChanged?.call(next);
                if (!c.multi && c.onSave == null) {
                  final commit = Future<void>.sync(
                    c.onImmediateCommit ?? () {},
                  );
                  _setOpen(false);
                  await commit;
                  if (!mounted) return;
                }
              },
            );
          })
          .toList(growable: false),
    );
  }

  Widget _buildStepper(BuildContext context) {
    return CatchFieldNextStepper(
      value: c.numberValue ?? 0,
      min: c.numberMin,
      max: c.numberMax,
      step: c.numberStep,
      unit: c.numberUnit,
      formatter: c.numberFormatter,
      enabled: !_disabled && !_isSaving,
      onChanged: c.onNumberChanged,
      onValueTap: c.onNumberValueTap,
    );
  }

  Widget _buildUnderlineField(BuildContext context) {
    final t = CatchTokens.of(context);
    final focused = _inputFocusNode.hasFocus;
    final lineColor = _hasError ? t.danger : t.line2;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildLabel(context),
        const SizedBox(height: CatchFieldNextTokens.underlineLabelGap),
        Stack(
          alignment: Alignment.bottomLeft,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: lineColor,
                    width: CatchFieldNextTokens.dividerHairline,
                  ),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: CatchFieldNextTokens.underlineBottomPadding,
                ),
                child: _buildTextField(context, row: false),
              ),
            ),
            PositionedDirectional(
              start: 0,
              end: 0,
              bottom: 0,
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: AnimatedFractionallySizedBox(
                  duration: _duration(CatchFieldNextTokens.reveal),
                  curve: CatchFieldNextTokens.curve,
                  widthFactor: focused || _hasError ? 1 : 0,
                  child: ColoredBox(
                    color: _hasError ? t.danger : t.ink,
                    child: const SizedBox(
                      height: CatchFieldNextTokens.underlineActive,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        ?_buildSupport(context),
      ],
    );
  }

  Widget _buildTextField(BuildContext context, {required bool row}) {
    final t = CatchTokens.of(context);
    final formatters = <TextInputFormatter>[
      ...?c.inputFormatters,
      if (c.maxLength != null) LengthLimitingTextInputFormatter(c.maxLength),
    ];
    final field = TextField(
      controller: _controller,
      focusNode: _inputFocusNode,
      enabled: !_disabled,
      autofocus: c.autofocus,
      keyboardType: c.keyboardType,
      textInputAction: c.textInputAction ?? TextInputAction.done,
      textCapitalization: c.textCapitalization,
      inputFormatters: formatters,
      autofillHints: c.autofillHints,
      obscureText: c.obscureText,
      maxLines: c.obscureText ? 1 : c.maxLines,
      minLines: c.minLines,
      onChanged: c.onChanged,
      onSubmitted: c.onSubmitted,
      cursorColor: t.ink,
      style: row
          ? _rowValueStyle(context, color: t.ink)
          : CatchTextStyles.bodyL(context, color: t.ink),
      decoration: InputDecoration(
        isDense: true,
        isCollapsed: true,
        filled: false,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
        hintText: c.placeholder,
        hintStyle: row
            ? CatchTextStyles.fieldRowTitle(context, color: t.ink3)
            : CatchTextStyles.bodyL(context, color: t.ink3),
        counterText: '',
      ),
    );
    final resolvedField = row && c.maxLines == 1
        ? SizedBox(height: CatchFieldNextTokens.valueLineHeight, child: field)
        : field;
    final leading = c.leading;
    if (leading == null) return resolvedField;
    return Row(
      children: [
        DefaultTextStyle.merge(
          style: row
              ? CatchTextStyles.bodyLead(
                  context,
                  color: t.ink2,
                ).copyWith(height: CatchFieldNextTokens.controlTextLineHeight)
              : CatchTextStyles.bodyL(context, color: t.ink2),
          child: leading,
        ),
        const SizedBox(width: CatchFieldNextTokens.inputAdornmentGap),
        Expanded(child: resolvedField),
      ],
    );
  }

  double _rowContentInset(BuildContext context) {
    if (c.shell == CatchFieldNextShell.underline) return 0;
    final scope = CatchFieldSectionNextScope.maybeOf(context);
    return switch (scope?.variant) {
      CatchFieldSectionNextVariant.divided => 0,
      CatchFieldSectionNextVariant.contained =>
        CatchFieldNextTokens.rowHorizontalPadding,
      null => CatchFieldNextTokens.rowHorizontalPadding,
    };
  }

  TextStyle _rowValueStyle(BuildContext context, {required Color color}) {
    return CatchTextStyles.fieldRowTitle(context, color: color).copyWith(
      fontSize: CatchFieldNextTokens.valueFontSize,
      height: CatchFieldNextTokens.valueTextLineHeight,
      fontFeatures: c.mono
          ? const <FontFeature>[FontFeature.tabularFigures()]
          : null,
    );
  }
}

/// Press-scaled chip with radio/checkbox semantics for the field prototype.
class CatchFieldNextChoiceChip extends StatefulWidget {
  const CatchFieldNextChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.multi,
    required this.onPressed,
    this.sublabel,
    this.enabled = true,
  });

  final String label;
  final String? sublabel;
  final bool selected;
  final bool multi;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  State<CatchFieldNextChoiceChip> createState() =>
      _CatchFieldNextChoiceChipState();
}

class _CatchFieldNextChoiceChipState extends State<CatchFieldNextChoiceChip> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final foreground = widget.selected ? t.primaryInk : t.ink;
    final background = widget.selected ? t.primary : t.surface;
    final chip = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: CatchFieldNextTokens.chipHitTarget,
        minHeight: CatchFieldNextTokens.chipHitTarget,
      ),
      child: Center(
        // Wrap can only flow chips when each child reports its content width.
        // Without widthFactor, Center expands to the Wrap's full run width and
        // forces every option onto its own line.
        widthFactor: 1,
        heightFactor: 1,
        child: AnimatedScale(
          duration: reduced ? Duration.zero : CatchFieldNextTokens.pressIn,
          curve: CatchFieldNextTokens.curve,
          scale: _pressed ? CatchFieldNextTokens.chipPressScale : 1,
          child: AnimatedContainer(
            key: ValueKey<String>(
              'catch-field-next-chip-visual-${widget.label}',
            ),
            duration: reduced ? Duration.zero : CatchFieldNextTokens.fast,
            curve: CatchFieldNextTokens.curve,
            constraints: const BoxConstraints(
              minHeight: CatchFieldNextTokens.chipVisualHeight,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: CatchFieldNextTokens.chipHorizontalPadding,
              vertical: CatchFieldNextTokens.chipVerticalPadding,
            ),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(CatchRadius.pill),
              border: Border.all(
                color: widget.selected ? t.primary : t.line2,
                width: CatchFieldNextTokens.dividerHairline,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.multi && widget.selected) ...[
                  Icon(
                    CatchIcons.checkRounded,
                    size: CatchIcon.xs,
                    color: foreground,
                  ),
                  const SizedBox(
                    width: CatchFieldNextTokens.chipSelectedGlyphGap,
                  ),
                ],
                Flexible(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.buttonSm(
                          context,
                          color: foreground,
                        ).copyWith(fontSize: CatchFieldNextTokens.chipFontSize),
                      ),
                      if (widget.sublabel?.trim().isNotEmpty ?? false)
                        Text(
                          widget.sublabel!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: CatchTextStyles.supporting(
                            context,
                            color: foreground.withValues(
                              alpha: CatchFieldNextTokens.chipSublabelAlpha,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: widget.enabled,
      checked: widget.selected,
      inMutuallyExclusiveGroup: !widget.multi,
      label: widget.label,
      child: Opacity(
        opacity: widget.enabled ? 1 : CatchOpacity.disabledControl,
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
          child: chip,
        ),
      ),
    );
  }
}

/// 44px-target stepper with accelerated hold-to-repeat and an optional value
/// tap escape hatch for large jumps.
class CatchFieldNextStepper extends StatelessWidget {
  const CatchFieldNextStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min,
    this.max,
    this.step = 1,
    this.unit,
    this.formatter,
    this.enabled = true,
    this.onValueTap,
  });

  final num value;
  final ValueChanged<num>? onChanged;
  final num? min;
  final num? max;
  final num step;
  final String? unit;
  final String Function(num value)? formatter;
  final bool enabled;
  final VoidCallback? onValueTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final number = formatter?.call(value) ?? _formatNumber(value);
    final formatted = unit == null ? number : '$number $unit';
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact =
            constraints.hasBoundedWidth &&
            constraints.maxWidth < CatchFieldNextTokens.stepperPreferredWidth;
        final inlineGap = compact
            ? CatchFieldNextTokens.stepperCompactInlineGap
            : CatchFieldNextTokens.stepperInlineGap;
        final valueMinWidth = compact
            ? CatchFieldNextTokens.stepperCompactValueMinWidth
            : CatchFieldNextTokens.stepperValueMinWidth;
        return Transform.translate(
          offset: const Offset(-CatchFieldNextTokens.stepperVisualEdgeInset, 0),
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: Row(
              key: const ValueKey<String>('catch-field-next-stepper'),
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchFieldNextRepeatButton(
                  icon: CatchIcons.removeRounded,
                  semanticLabel: 'Decrease',
                  enabled:
                      enabled &&
                      onChanged != null &&
                      (min == null || value - step >= min!),
                  onStep: () => onChanged?.call(value - step),
                ),
                SizedBox(width: inlineGap),
                Semantics(
                  button: onValueTap != null,
                  label: formatted,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onValueTap,
                    child: SizedBox(
                      width: valueMinWidth,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          formatted,
                          maxLines: 1,
                          textAlign: TextAlign.center,
                          style:
                              CatchTextStyles.fieldRowTitle(
                                context,
                                color: t.ink,
                              ).copyWith(
                                fontSize:
                                    CatchFieldNextTokens.stepperValueFontSize,
                              ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: inlineGap),
                CatchFieldNextRepeatButton(
                  icon: CatchIcons.addRounded,
                  semanticLabel: 'Increase',
                  enabled:
                      enabled &&
                      onChanged != null &&
                      (max == null || value + step <= max!),
                  onStep: () => onChanged?.call(value + step),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatNumber(num number) {
    if (number == number.roundToDouble()) return number.toInt().toString();
    return number.toString();
  }
}

class CatchFieldNextRepeatButton extends StatefulWidget {
  const CatchFieldNextRepeatButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    required this.enabled,
    required this.onStep,
    this.visualSize = CatchFieldNextTokens.stepperVisual,
    this.hitTarget = CatchFieldNextTokens.stepperHitTarget,
    this.iconSize = CatchIcon.sm,
  });

  final IconData icon;
  final String semanticLabel;
  final bool enabled;
  final VoidCallback onStep;
  final double visualSize;
  final double hitTarget;
  final double iconSize;

  @override
  State<CatchFieldNextRepeatButton> createState() =>
      _CatchFieldNextRepeatButtonState();
}

class _CatchFieldNextRepeatButtonState
    extends State<CatchFieldNextRepeatButton> {
  Timer? _delay;
  Timer? _repeat;
  int _ticks = 0;
  bool _pressed = false;

  @override
  void didUpdateWidget(CatchFieldNextRepeatButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled) _stop();
  }

  @override
  void dispose() {
    _stop(updateState: false);
    super.dispose();
  }

  void _start() {
    if (!widget.enabled) return;
    _stop();
    setState(() => _pressed = true);
    widget.onStep();
    _delay = Timer(CatchFieldNextTokens.repeatDelay, _scheduleRepeat);
  }

  void _scheduleRepeat() {
    if (!mounted || !_pressed || !widget.enabled) return;
    final interval = _ticks >= CatchFieldNextTokens.repeatAccelerationTicks
        ? CatchFieldNextTokens.repeatAccelerated
        : CatchFieldNextTokens.repeatNormal;
    _repeat = Timer(interval, () {
      if (!mounted || !_pressed || !widget.enabled) return;
      _ticks += 1;
      widget.onStep();
      _scheduleRepeat();
    });
  }

  void _stop({bool updateState = true}) {
    _delay?.cancel();
    _repeat?.cancel();
    _delay = null;
    _repeat = null;
    _ticks = 0;
    if (_pressed && updateState && mounted) setState(() => _pressed = false);
    if (!updateState) _pressed = false;
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    final visual = AnimatedScale(
      duration: reduced ? Duration.zero : CatchFieldNextTokens.pressIn,
      curve: CatchFieldNextTokens.curve,
      scale: _pressed ? CatchFieldNextTokens.stepperPressScale : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface,
          shape: BoxShape.circle,
          border: Border.all(
            color: t.line2,
            width: CatchFieldNextTokens.dividerHairline,
          ),
        ),
        child: SizedBox.square(
          dimension: widget.visualSize,
          child: Icon(widget.icon, size: widget.iconSize, color: t.ink),
        ),
      ),
    );
    return Semantics(
      button: true,
      enabled: widget.enabled,
      label: widget.semanticLabel,
      onTap: widget.enabled ? widget.onStep : null,
      child: FocusableActionDetector(
        enabled: widget.enabled,
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              if (widget.enabled) widget.onStep();
              return null;
            },
          ),
        },
        child: Opacity(
          opacity: widget.enabled ? 1 : CatchOpacity.disabledControl,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTapDown: widget.enabled ? (_) => _start() : null,
            onTapUp: widget.enabled ? (_) => _stop() : null,
            onTapCancel: widget.enabled ? _stop : null,
            child: SizedBox.square(
              dimension: widget.hitTarget,
              child: Center(child: visual),
            ),
          ),
        ),
      ),
    );
  }
}

/// Exact 44x26 toggle geometry for the prototype.
class CatchFieldNextToggle extends StatelessWidget {
  const CatchFieldNextToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.semanticLabel,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final String semanticLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final canChange = enabled && onChanged != null;
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return Semantics(
      button: true,
      enabled: canChange,
      toggled: value,
      label: semanticLabel,
      child: Opacity(
        opacity: canChange ? 1 : CatchOpacity.disabledControl,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: canChange ? () => onChanged!.call(!value) : null,
          child: SizedBox(
            width: CatchFieldNextTokens.toggleWidth,
            height: CatchFieldNextTokens.toggleHeight,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: value ? t.primary : t.line2,
                borderRadius: BorderRadius.circular(CatchRadius.pill),
              ),
              child: AnimatedAlign(
                duration: reduced
                    ? Duration.zero
                    : CatchFieldNextTokens.standard,
                curve: CatchFieldNextTokens.curve,
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.all(
                    CatchFieldNextTokens.togglePadding,
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: t.surface,
                      shape: BoxShape.circle,
                      boxShadow: CatchElevation.toggleKnob,
                    ),
                    child: const SizedBox.square(
                      dimension: CatchFieldNextTokens.toggleKnob,
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

/// Ambient form-section information used by fields for divided-row bleed.
class CatchFieldSectionNextScope extends InheritedWidget {
  const CatchFieldSectionNextScope({
    super.key,
    required this.variant,
    required super.child,
  });

  final CatchFieldSectionNextVariant variant;

  static CatchFieldSectionNextScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CatchFieldSectionNextScope>();

  @override
  bool updateShouldNotify(CatchFieldSectionNextScope oldWidget) =>
      variant != oldWidget.variant;
}

/// Form-specific section prototype. It deliberately does not replace the
/// broader CatchSection family and is named `Next` only while under review.
class CatchFieldSectionNext extends StatefulWidget {
  const CatchFieldSectionNext.contained({
    super.key,
    this.title,
    this.count,
    this.trailing,
    this.footer,
    this.lines = true,
    this.focused = false,
    this.hasError = false,
    this.dividerInset,
    required this.children,
  }) : variant = CatchFieldSectionNextVariant.contained;

  const CatchFieldSectionNext.divided({
    super.key,
    this.title,
    this.count,
    this.trailing,
    this.footer,
    this.lines = true,
    this.focused = false,
    this.hasError = false,
    this.dividerInset,
    required this.children,
  }) : variant = CatchFieldSectionNextVariant.divided;

  final CatchFieldSectionNextVariant variant;
  final String? title;
  final Object? count;
  final Widget? trailing;
  final Widget? footer;
  final bool lines;
  final bool focused;
  final bool hasError;
  final double? dividerInset;
  final List<Widget> children;

  @override
  State<CatchFieldSectionNext> createState() => _CatchFieldSectionNextState();
}

class _CatchFieldSectionNextState extends State<CatchFieldSectionNext> {
  bool _descendantFocused = false;

  bool get _focused => widget.focused || _descendantFocused;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final dividerBase = widget.variant == CatchFieldSectionNextVariant.contained
        ? CatchFieldNextTokens.rowHorizontalPadding
        : 0.0;
    final dividerInset =
        widget.dividerInset ??
        dividerBase +
            (widget.children.any(
                  (child) => child is CatchFieldNext && child.hasLeading,
                )
                ? CatchFieldNextTokens.textLaneInset
                : 0);
    final rows = CatchFieldSectionNextScope(
      variant: widget.variant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final indexed in widget.children.indexed) ...[
            if (indexed.$1 > 0 && widget.lines)
              CatchDivider.fieldRow(indent: dividerInset, color: t.line),
            indexed.$2,
          ],
        ],
      ),
    );
    final header = _buildHeader(context);
    final footer = widget.footer == null
        ? null
        : Padding(
            padding: const EdgeInsets.only(
              top: CatchFieldNextTokens.sectionFooterGap,
            ),
            child: DefaultTextStyle.merge(
              style: CatchTextStyles.supporting(context, color: t.ink3),
              child: widget.footer!,
            ),
          );
    final section = switch (widget.variant) {
      CatchFieldSectionNextVariant.contained => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AnimatedContainer(
            duration: _motionDuration(context),
            curve: CatchFieldNextTokens.curve,
            decoration: BoxDecoration(
              color: t.surface,
              borderRadius: BorderRadius.circular(
                CatchFieldNextTokens.sectionRadius,
              ),
              border: Border.all(
                color: widget.hasError
                    ? t.danger
                    : _focused
                    ? t.ink
                    : t.line2,
                width: CatchFieldNextTokens.sectionStroke,
              ),
              boxShadow: _focused && !widget.hasError
                  ? CatchFieldNextTokens.activeLift(
                      Theme.of(context).brightness,
                    )
                  : const <BoxShadow>[],
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: CatchFieldNextTokens.sectionContentVerticalPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (header != null) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: CatchFieldNextTokens.rowHorizontalPadding,
                      ),
                      child: header,
                    ),
                    const SizedBox(
                      height: CatchFieldNextTokens.sectionHeaderGap,
                    ),
                  ],
                  rows,
                ],
              ),
            ),
          ),
          ?footer,
        ],
      ),
      CatchFieldSectionNextVariant.divided => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ?header,
          if (header != null)
            const SizedBox(height: CatchFieldNextTokens.sectionHeaderGap),
          if (widget.lines)
            CatchDivider.section(
              color: widget.hasError
                  ? t.danger
                  : _focused
                  ? t.ink
                  : null,
            ),
          rows,
          ?footer,
        ],
      ),
    };
    return Focus(
      onFocusChange: (focused) {
        if (_descendantFocused == focused) return;
        setState(() => _descendantFocused = focused);
      },
      child: section,
    );
  }

  Duration _motionDuration(BuildContext context) {
    final reduced = MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return reduced ? Duration.zero : CatchFieldNextTokens.standard;
  }

  Widget? _buildHeader(BuildContext context) {
    final title = widget.title;
    final hasTitle = title?.trim().isNotEmpty ?? false;
    if (!hasTitle && widget.count == null && widget.trailing == null) {
      return null;
    }
    final t = CatchTokens.of(context);
    final color = widget.hasError
        ? t.danger
        : _focused
        ? t.ink
        : t.ink2;
    return Row(
      children: [
        if (hasTitle)
          Expanded(
            child: Text(
              title!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.kicker(context, color: color),
            ),
          )
        else
          const Spacer(),
        if (widget.count != null) ...[
          const SizedBox(width: CatchFieldNextTokens.sectionHeaderGap),
          Text(
            '${widget.count}',
            style: CatchTextStyles.monoLabel(context, color: color),
          ),
        ],
        if (widget.trailing != null) ...[
          const SizedBox(width: CatchFieldNextTokens.sectionHeaderGap),
          widget.trailing!,
        ],
      ],
    );
  }
}
