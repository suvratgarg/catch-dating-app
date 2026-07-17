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

typedef _RowConfigData = ({
  int titleMaxLines,
  int bodyMaxLines,
  bool contentRow,
  String? valueText,
  int valueMaxLines,
  bool? showChevron,
  String? placeholder,
  bool isOptional,
  String? error,
  String? errorText,
  bool valid,
  VoidCallback? onTap,
  bool add,
  bool navigation,
});

typedef _ToggleConfigData = ({
  bool value,
  ValueChanged<bool>? onChanged,
  int titleMaxLines,
  int bodyMaxLines,
  String? helperText,
  String? badgeLabel,
  CatchBadgeTone? badgeTone,
});

typedef _TextEntryConfigData = ({
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
  bool showLabel,
  CatchFieldSize size,
  TextAlign textAlign,
  bool mono,
  Widget? prefixIcon,
  String? prefixText,
  Widget? suffixIcon,
  String? suffixText,
  bool showClearButton,
  bool floatingLabel,
});

typedef _EditConfigData = ({
  _TextEntryConfigData input,
  String? placeholder,
  String? emptyValueText,
  String? inputHint,
  String? leadingUnit,
  String? error,
  String? errorText,
  VoidCallback? onTap,
  bool isOptional,
  String? helperText,
  CatchFieldSupportTone helperTone,
  bool focused,
  bool explicitSave,
  bool? open,
  ValueChanged<bool>? onOpenChanged,
  Widget? supporting,
  Widget? secondaryAction,
  Widget? feedback,
  VoidCallback? onCancel,
  VoidCallback? onSubmit,
  bool isLoading,
});

typedef _ControlConfigData = ({
  Widget control,
  int titleMaxLines,
  int bodyMaxLines,
  bool? open,
  bool initiallyOpen,
  ValueChanged<bool>? onOpenChanged,
  VoidCallback? onCancel,
  VoidCallback? onSubmit,
  bool isLoading,
  bool addable,
  bool isOptional,
  String? helperText,
  String? placeholder,
  String? emptyValueText,
  String? error,
  String? errorText,
});

sealed class _CatchFieldConfig {
  const _CatchFieldConfig();
}

final class _RowConfig extends _CatchFieldConfig {
  const _RowConfig({
    this.titleMaxLines = 1,
    this.bodyMaxLines = 2,
    this.contentRow = false,
    this.valueText,
    this.valueMaxLines = 1,
    this.showChevron,
    this.placeholder,
    this.isOptional = false,
    this.error,
    this.errorText,
    this.valid = false,
    this.onTap,
    this.add = false,
    this.navigation = false,
  });

  final int titleMaxLines;
  final int bodyMaxLines;
  final bool contentRow;
  final String? valueText;
  final int valueMaxLines;
  final bool? showChevron;
  final String? placeholder;
  final bool isOptional;
  final String? error;
  final String? errorText;
  final bool valid;
  final VoidCallback? onTap;
  final bool add;
  final bool navigation;
}

final class _ToggleConfig extends _CatchFieldConfig {
  const _ToggleConfig({
    required this.value,
    required this.onChanged,
    this.titleMaxLines = 1,
    this.bodyMaxLines = 2,
    this.helperText,
    this.badgeLabel,
    this.badgeTone,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final int titleMaxLines;
  final int bodyMaxLines;
  final String? helperText;
  final String? badgeLabel;
  final CatchBadgeTone? badgeTone;
}

final class _TextEntryConfig {
  const _TextEntryConfig({
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
    this.showLabel = true,
    this.size = CatchFieldSize.md,
    this.textAlign = TextAlign.start,
    this.mono = false,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.suffixText,
    this.showClearButton = false,
    this.floatingLabel = true,
  }) : assert(
         controller == null || initialValue == null,
         'CatchField.input cannot include both controller and initialValue.',
       );

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
  final bool showLabel;
  final CatchFieldSize size;
  final TextAlign textAlign;
  final bool mono;
  final Widget? prefixIcon;
  final String? prefixText;
  final Widget? suffixIcon;
  final String? suffixText;
  final bool showClearButton;
  final bool floatingLabel;
}

final class _EditConfig extends _CatchFieldConfig {
  const _EditConfig({
    required this.input,
    this.placeholder,
    this.emptyValueText,
    this.inputHint,
    this.leadingUnit,
    this.error,
    this.errorText,
    this.onTap,
    this.isOptional = false,
    this.helperText,
    this.helperTone = CatchFieldSupportTone.neutral,
    this.focused = false,
    this.explicitSave = false,
    this.open,
    this.onOpenChanged,
    this.supporting,
    this.secondaryAction,
    this.feedback,
    this.onCancel,
    this.onSubmit,
    this.isLoading = false,
  }) : assert(
         inputHint == null || placeholder == null,
         'Use inputHint for editable fields; do not also pass placeholder.',
       ),
       assert(
         (onCancel == null && onSubmit == null) || explicitSave,
         'Commit actions require an explicit-save input.',
       );

  final _TextEntryConfig input;
  final String? placeholder;
  final String? emptyValueText;
  final String? inputHint;
  final String? leadingUnit;
  final String? error;
  final String? errorText;
  final VoidCallback? onTap;
  final bool isOptional;
  final String? helperText;
  final CatchFieldSupportTone helperTone;
  final bool focused;
  final bool explicitSave;
  final bool? open;
  final ValueChanged<bool>? onOpenChanged;
  final Widget? supporting;
  final Widget? secondaryAction;
  final Widget? feedback;
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;
  final bool isLoading;
}

final class _SelectConfig extends _CatchFieldConfig {
  const _SelectConfig({
    required this.values,
    required this.itemLabel,
    this.value,
    this.onChanged,
    this.validator,
    this.placeholder,
    this.prefixIcon,
    this.showLabel = true,
    this.size = CatchFieldSize.md,
    this.helperText,
    this.helperTone = CatchFieldSupportTone.neutral,
  });

  final List<Object?> values;
  final String Function(Object? item) itemLabel;
  final Object? value;
  final ValueChanged<Object?>? onChanged;
  final FormFieldValidator<Object?>? validator;
  final String? placeholder;
  final Widget? prefixIcon;
  final bool showLabel;
  final CatchFieldSize size;
  final String? helperText;
  final CatchFieldSupportTone helperTone;
}

final class _ControlConfig extends _CatchFieldConfig {
  const _ControlConfig({
    required this.control,
    this.titleMaxLines = 1,
    this.bodyMaxLines = 2,
    this.open,
    this.initiallyOpen = false,
    this.onOpenChanged,
    this.onCancel,
    this.onSubmit,
    this.isLoading = false,
    this.addable = false,
    this.isOptional = false,
    this.helperText,
    this.placeholder,
    this.emptyValueText,
    this.error,
    this.errorText,
  });

  final Widget control;
  final int titleMaxLines;
  final int bodyMaxLines;
  final bool? open;
  final bool initiallyOpen;
  final ValueChanged<bool>? onOpenChanged;
  final VoidCallback? onCancel;
  final VoidCallback? onSubmit;
  final bool isLoading;
  final bool addable;
  final bool isOptional;
  final String? helperText;
  final String? placeholder;
  final String? emptyValueText;
  final String? error;
  final String? errorText;
}

_CatchFieldConfig _materializeCatchFieldConfig(Object data) => switch (data) {
  final _CatchFieldConfig config => config,
  final _RowConfigData config => _RowConfig(
    titleMaxLines: config.titleMaxLines,
    bodyMaxLines: config.bodyMaxLines,
    contentRow: config.contentRow,
    valueText: config.valueText,
    valueMaxLines: config.valueMaxLines,
    showChevron: config.showChevron,
    placeholder: config.placeholder,
    isOptional: config.isOptional,
    error: config.error,
    errorText: config.errorText,
    valid: config.valid,
    onTap: config.onTap,
    add: config.add,
    navigation: config.navigation,
  ),
  final _ToggleConfigData config => _ToggleConfig(
    value: config.value,
    onChanged: config.onChanged,
    titleMaxLines: config.titleMaxLines,
    bodyMaxLines: config.bodyMaxLines,
    helperText: config.helperText,
    badgeLabel: config.badgeLabel,
    badgeTone: config.badgeTone,
  ),
  final _EditConfigData config => _EditConfig(
    input: _TextEntryConfig(
      controller: config.input.controller,
      initialValue: config.input.initialValue,
      onChanged: config.input.onChanged,
      onSubmitted: config.input.onSubmitted,
      onBlur: config.input.onBlur,
      onFocusChanged: config.input.onFocusChanged,
      focusNode: config.input.focusNode,
      retainFocusOnSubmitted: config.input.retainFocusOnSubmitted,
      validator: config.input.validator,
      keyboardType: config.input.keyboardType,
      textInputAction: config.input.textInputAction,
      textCapitalization: config.input.textCapitalization,
      inputFormatters: config.input.inputFormatters,
      autofillHints: config.input.autofillHints,
      obscureText: config.input.obscureText,
      maxLines: config.input.maxLines,
      minLines: config.input.minLines,
      maxLength: config.input.maxLength,
      readOnly: config.input.readOnly,
      autofocus: config.input.autofocus,
      showLabel: config.input.showLabel,
      size: config.input.size,
      textAlign: config.input.textAlign,
      mono: config.input.mono,
      prefixIcon: config.input.prefixIcon,
      prefixText: config.input.prefixText,
      suffixIcon: config.input.suffixIcon,
      suffixText: config.input.suffixText,
      showClearButton: config.input.showClearButton,
      floatingLabel: config.input.floatingLabel,
    ),
    placeholder: config.placeholder,
    emptyValueText: config.emptyValueText,
    inputHint: config.inputHint,
    leadingUnit: config.leadingUnit,
    error: config.error,
    errorText: config.errorText,
    onTap: config.onTap,
    isOptional: config.isOptional,
    helperText: config.helperText,
    helperTone: config.helperTone,
    focused: config.focused,
    explicitSave: config.explicitSave,
    open: config.open,
    onOpenChanged: config.onOpenChanged,
    supporting: config.supporting,
    secondaryAction: config.secondaryAction,
    feedback: config.feedback,
    onCancel: config.onCancel,
    onSubmit: config.onSubmit,
    isLoading: config.isLoading,
  ),
  final _ControlConfigData config => _ControlConfig(
    control: config.control,
    titleMaxLines: config.titleMaxLines,
    bodyMaxLines: config.bodyMaxLines,
    open: config.open,
    initiallyOpen: config.initiallyOpen,
    onOpenChanged: config.onOpenChanged,
    onCancel: config.onCancel,
    onSubmit: config.onSubmit,
    isLoading: config.isLoading,
    addable: config.addable,
    isOptional: config.isOptional,
    helperText: config.helperText,
    placeholder: config.placeholder,
    emptyValueText: config.emptyValueText,
    error: config.error,
    errorText: config.errorText,
  ),
  _ => throw StateError('Unknown CatchField configuration: $data'),
};

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
class CatchField extends StatefulWidget {
  const CatchField._fromConfig(
    _CatchFieldConfig config, {
    super.key,
    required this.title,
    this.enabled = true,
  }) : _configData = config,
       body = null,
       action = null,
       emphasis = CatchFieldEmphasis.body,
       tone = CatchFieldTone.normal,
       variant = CatchFieldVariant.row,
       icon = null,
       iconColor = null,
       leading = null,
       divider = false,
       status = CatchFieldStatus.idle;

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
  }) : _configData = (
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         contentRow: false,
         valueText: valueText,
         valueMaxLines: valueMaxLines,
         showChevron: null,
         placeholder: placeholder,
         isOptional: false,
         error: null,
         errorText: null,
         valid: valid,
         onTap: null,
         add: false,
         navigation: false,
       ),
       assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       title = title,
       body = body,
       action = action,
       emphasis = emphasis,
       tone = tone,
       variant = CatchFieldVariant.row,
       icon = icon,
       iconColor = iconColor,
       leading = leading,
       status = status,
       divider = divider,
       enabled = true,
       super(key: key);

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
  }) : _configData = (
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         contentRow: true,
         valueText: valueText,
         valueMaxLines: valueMaxLines,
         showChevron: showChevron,
         isOptional: isOptional,
         valid: valid,
         onTap: onTap,
         add: false,
         navigation: onTap != null,
         placeholder: null,
         error: null,
         errorText: null,
       ),
       assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       title = title,
       body = body,
       action = action,
       emphasis = emphasis,
       tone = tone,
       variant = CatchFieldVariant.row,
       icon = icon,
       iconColor = iconColor,
       leading = leading,
       status = status,
       divider = divider,
       enabled = true,
       super(key: key);

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
  }) : _configData = (
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         valueText: valueText,
         valueMaxLines: valueMaxLines,
         showChevron: showChevron,
         placeholder: placeholder,
         isOptional: false,
         error: error,
         errorText: errorText,
         valid: valid,
         onTap: onTap,
         add: false,
         contentRow: false,
         navigation: true,
       ),
       assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       title = title,
       body = body,
       action = action,
       emphasis = emphasis,
       tone = tone,
       variant = CatchFieldVariant.row,
       icon = icon,
       iconColor = iconColor,
       leading = leading,
       status = status,
       divider = divider,
       enabled = true,
       super(key: key);

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
  }) : _configData = (
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         valueText: valueText,
         valueMaxLines: valueMaxLines,
         showChevron: null,
         placeholder: placeholder,
         isOptional: false,
         error: error,
         errorText: errorText,
         valid: valid,
         onTap: onTap,
         add: false,
         contentRow: false,
         navigation: false,
       ),
       assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       title = title,
       body = body,
       action = action,
       emphasis = emphasis,
       tone = tone,
       variant = CatchFieldVariant.row,
       icon = icon,
       iconColor = iconColor,
       leading = leading,
       status = status,
       divider = divider,
       enabled = true,
       super(key: key);

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
  }) : _configData = (
         value: value,
         onChanged: onChanged,
         titleMaxLines: titleMaxLines,
         bodyMaxLines: bodyMaxLines,
         helperText: helperText,
         badgeLabel: badgeLabel,
         badgeTone: badgeTone,
       ),
       title = title,
       body = body,
       action = null,
       emphasis = emphasis,
       tone = tone,
       variant = CatchFieldVariant.row,
       icon = icon,
       iconColor = iconColor,
       leading = null,
       status = status,
       divider = divider,
       enabled = true,
       super(key: key);

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
  }) : _configData = (
         input: (
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
           showLabel: showLabel,
           size: size,
           textAlign: textAlign,
           mono: mono,
           prefixIcon: prefixIcon,
           prefixText: prefixText,
           suffixIcon: suffixIcon,
           suffixText: suffixText,
           showClearButton: showClearButton,
           floatingLabel: floatingLabel,
         ),
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
         focused: focused,
         explicitSave: false,
         open: null,
         onOpenChanged: null,
         supporting: null,
         secondaryAction: null,
         feedback: null,
         onCancel: null,
         onSubmit: null,
         isLoading: false,
       ),
       assert(
         inputHint == null || placeholder == null,
         'Use inputHint for editable fields; do not also pass placeholder.',
       ),
       assert(
         controller == null || initialValue == null,
         'CatchField.input cannot include both controller and initialValue.',
       ),
       title = title,
       body = null,
       action = action,
       emphasis = CatchFieldEmphasis.body,
       tone = CatchFieldTone.normal,
       variant = variant,
       icon = icon,
       iconColor = iconColor,
       leading = null,
       divider = divider,
       enabled = enabled,
       status = status,
       super(key: key);

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
  }) : _configData = (
         control: control,
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
       ),
       title = title,
       body = body,
       action = null,
       emphasis = emphasis,
       tone = tone,
       variant = CatchFieldVariant.row,
       icon = icon,
       iconColor = iconColor,
       leading = null,
       divider = divider,
       status = status,
       enabled = enabled,
       super(key: key);

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
  }) : _configData = (
         input: (
           controller: controller,
           initialValue: null,
           onChanged: onChanged,
           onSubmitted: onSubmitted,
           onBlur: onBlur,
           onFocusChanged: onFocusChanged,
           focusNode: focusNode,
           retainFocusOnSubmitted: false,
           validator: null,
           keyboardType: keyboardType,
           textInputAction: textInputAction,
           textCapitalization: textCapitalization,
           inputFormatters: inputFormatters,
           autofillHints: autofillHints,
           obscureText: false,
           maxLines: maxLines,
           minLines: minLines,
           maxLength: maxLength,
           readOnly: false,
           autofocus: false,
           showLabel: true,
           size: CatchFieldSize.md,
           textAlign: TextAlign.start,
           mono: false,
           prefixIcon: null,
           prefixText: null,
           suffixIcon: null,
           suffixText: null,
           showClearButton: false,
           floatingLabel: false,
         ),
         placeholder: placeholder,
         emptyValueText: emptyValueText,
         inputHint: inputHint,
         leadingUnit: null,
         error: error,
         errorText: null,
         onTap: null,
         isOptional: false,
         helperText: null,
         helperTone: CatchFieldSupportTone.neutral,
         focused: false,
         explicitSave: true,
         open: open,
         onOpenChanged: onOpenChanged,
         supporting: supporting,
         secondaryAction: secondaryAction,
         feedback: feedback,
         onCancel: onCancel,
         onSubmit: onSubmit,
         isLoading: isLoading,
       ),
       title = title,
       body = null,
       action = null,
       emphasis = CatchFieldEmphasis.body,
       tone = tone,
       variant = CatchFieldVariant.row,
       icon = icon,
       iconColor = iconColor,
       leading = null,
       enabled = enabled,
       divider = divider,
       status = status,
       super(key: key);

  const CatchField.add({
    Key? key,
    required String title,
    VoidCallback? onTap,
    IconData? icon,
    CatchFieldTone tone = CatchFieldTone.primary,
  }) : _configData = (
         titleMaxLines: 1,
         bodyMaxLines: 2,
         contentRow: false,
         valueText: null,
         valueMaxLines: 1,
         showChevron: null,
         placeholder: null,
         isOptional: false,
         error: null,
         errorText: null,
         valid: false,
         onTap: onTap,
         add: true,
         navigation: true,
       ),
       title = title,
       body = null,
       action = null,
       emphasis = CatchFieldEmphasis.body,
       tone = tone,
       variant = CatchFieldVariant.row,
       icon = icon,
       iconColor = null,
       leading = null,
       divider = false,
       enabled = true,
       status = CatchFieldStatus.idle,
       super(key: key);

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
    return CatchField._fromConfig(
      _SelectConfig(
        values: List<Object?>.unmodifiable(values),
        itemLabel: (item) => itemLabel(item as T),
        value: value,
        onChanged: onChanged == null ? null : (item) => onChanged(item as T?),
        validator: validator == null ? null : (item) => validator(item as T?),
        placeholder: hintText,
        prefixIcon: prefixIcon,
        showLabel: showLabel,
        size: size,
        helperText: helperText,
        helperTone: helperTone,
      ),
      key: key,
      title: title,
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

  final Object _configData;
  _CatchFieldConfig get _config => _materializeCatchFieldConfig(_configData);
  final CatchFieldEmphasis emphasis;
  final CatchFieldTone tone;
  final CatchFieldVariant variant;
  final IconData? icon;
  final Color? iconColor;

  /// Caller-owned leading content used instead of [icon].
  final Widget? leading;
  final bool divider;
  final bool enabled;
  final CatchFieldStatus status;

  _RowConfigData? get _rowConfig => switch (_configData) {
    final _RowConfigData config => config,
    _ => null,
  };
  _ToggleConfigData? get _toggleConfig => switch (_configData) {
    final _ToggleConfigData config => config,
    _ => null,
  };
  _EditConfigData? get _editConfig => switch (_configData) {
    final _EditConfigData config => config,
    _ => null,
  };
  _SelectConfig? get _selectConfig => switch (_configData) {
    final _SelectConfig config => config,
    _ => null,
  };
  _ControlConfigData? get _controlConfig => switch (_configData) {
    final _ControlConfigData config => config,
    _ => null,
  };

  /// End-aligned text for compact read and navigation rows.
  String? get valueText => _rowConfig?.valueText;
  int get valueMaxLines => _rowConfig?.valueMaxLines ?? 1;
  int get titleMaxLines => switch (_configData) {
    final _RowConfigData config => config.titleMaxLines,
    final _ToggleConfigData config => config.titleMaxLines,
    final _ControlConfigData config => config.titleMaxLines,
    _ => 1,
  };
  int get bodyMaxLines => switch (_configData) {
    final _RowConfigData config => config.bodyMaxLines,
    final _ToggleConfigData config => config.bodyMaxLines,
    final _ControlConfigData config => config.bodyMaxLines,
    _ => 2,
  };
  bool get _contentRow => _rowConfig?.contentRow ?? false;
  String? get leadingUnit => _editConfig?.leadingUnit;
  bool? get showChevron => _rowConfig?.showChevron;

  String? get placeholder => switch (_configData) {
    final _RowConfigData config => config.placeholder,
    final _EditConfigData config => config.placeholder,
    final _SelectConfig config => config.placeholder,
    final _ControlConfigData config => config.placeholder,
    _ => null,
  };
  String? get emptyValueText => switch (_configData) {
    final _EditConfigData config => config.emptyValueText,
    final _ControlConfigData config => config.emptyValueText,
    _ => null,
  };
  String? get inputHint => _editConfig?.inputHint;
  bool get toggled => _toggleConfig?.value ?? false;
  ValueChanged<bool>? get onToggle => _toggleConfig?.onChanged;

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
  String? get error => switch (_configData) {
    final _RowConfigData config => config.error,
    final _EditConfigData config => config.error,
    final _ControlConfigData config => config.error,
    _ => null,
  };
  String? get errorText => switch (_configData) {
    final _RowConfigData config => config.errorText,
    final _EditConfigData config => config.errorText,
    final _ControlConfigData config => config.errorText,
    _ => null,
  };
  bool get valid => _rowConfig?.valid ?? false;
  VoidCallback? get onTap => _rowConfig?.onTap ?? _editConfig?.onTap;

  _TextEntryConfigData? get _inputConfig => _editConfig?.input;
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
  bool get isOptional => switch (_configData) {
    final _RowConfigData config => config.isOptional,
    final _EditConfigData config => config.isOptional,
    final _ControlConfigData config => config.isOptional,
    _ => false,
  };
  bool get showLabel => switch (_configData) {
    final _EditConfigData config => config.input.showLabel,
    final _SelectConfig config => config.showLabel,
    _ => true,
  };
  String? get helperText => switch (_configData) {
    final _ToggleConfigData config => config.helperText,
    final _EditConfigData config => config.helperText,
    final _SelectConfig config => config.helperText,
    final _ControlConfigData config => config.helperText,
    _ => null,
  };
  CatchFieldSupportTone get helperTone => switch (_configData) {
    final _EditConfigData config => config.helperTone,
    final _SelectConfig config => config.helperTone,
    _ => CatchFieldSupportTone.neutral,
  };
  String? get badgeLabel => _toggleConfig?.badgeLabel;
  CatchBadgeTone? get badgeTone => _toggleConfig?.badgeTone;
  CatchFieldSize get size => switch (_configData) {
    final _EditConfigData config => config.input.size,
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
  ValueChanged<Object?>? get _onSelectChanged => _selectConfig?.onChanged;
  FormFieldValidator<Object?>? get _selectValidator => _selectConfig?.validator;

  VoidCallback? get _onCancel =>
      _controlConfig?.onCancel ?? _editConfig?.onCancel;
  VoidCallback? get _onSubmit =>
      _controlConfig?.onSubmit ?? _editConfig?.onSubmit;
  bool get _closeLocallyOnSubmit => true;
  bool get _isLoading =>
      _controlConfig?.isLoading ?? _editConfig?.isLoading ?? false;

  @override
  State<CatchField> createState() => _CatchFieldState();
}
