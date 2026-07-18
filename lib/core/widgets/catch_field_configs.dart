// Per-mode config fields intentionally implement the public facade getters,
// while explicit forwarding keeps every const constructor's ownership clear.
// ignore_for_file: annotate_overrides, prefer_initializing_formals, use_super_parameters

part of 'catch_field.dart';

sealed class _CatchFieldConfig extends CatchField {
  const _CatchFieldConfig({
    Key? key,
    required String? title,
    String? body,
    Widget? action,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    CatchFieldVariant variant = CatchFieldVariant.row,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    double? leadingExtent,
    bool divider = false,
    bool enabled = true,
    CatchFieldStatus status = CatchFieldStatus.idle,
  }) : super._shared(
         key: key,
         title: title,
         body: body,
         action: action,
         emphasis: emphasis,
         tone: tone,
         variant: variant,
         icon: icon,
         iconColor: iconColor,
         leading: leading,
         leadingExtent: leadingExtent,
         divider: divider,
         enabled: enabled,
         status: status,
       );
}

final class _RowConfig extends _CatchFieldConfig {
  const _RowConfig.read({
    Key? key,
    String? title,
    String? body,
    Widget? action,
    this.titleMaxLines = 1,
    this.bodyMaxLines = 2,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    double? leadingExtent,
    this.valueText,
    this.valueMaxLines = 1,
    this.placeholder,
    this.valid = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    bool divider = false,
  }) : contentRow = false,
       showChevron = null,
       isOptional = false,
       error = null,
       errorText = null,
       onTap = null,
       add = false,
       navigation = false,
       assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       assert(
         leadingExtent == null || (leading != null && leadingExtent > 0),
         'CatchField.leadingExtent requires non-null leading content.',
       ),
       super(
         key: key,
         title: title,
         body: body,
         action: action,
         emphasis: emphasis,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         leading: leading,
         leadingExtent: leadingExtent,
         status: status,
         divider: divider,
       );

  const _RowConfig.content({
    Key? key,
    required String title,
    required String body,
    Widget? action,
    this.onTap,
    this.titleMaxLines = 2,
    this.bodyMaxLines = 3,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    double? leadingExtent,
    this.valueText,
    this.valueMaxLines = 1,
    this.showChevron,
    this.isOptional = false,
    this.valid = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    bool divider = false,
  }) : contentRow = true,
       placeholder = null,
       error = null,
       errorText = null,
       add = false,
       navigation = onTap != null,
       assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       assert(
         leadingExtent == null || (leading != null && leadingExtent > 0),
         'CatchField.leadingExtent requires non-null leading content.',
       ),
       super(
         key: key,
         title: title,
         body: body,
         action: action,
         emphasis: emphasis,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         leading: leading,
         leadingExtent: leadingExtent,
         status: status,
         divider: divider,
       );

  const _RowConfig.nav({
    Key? key,
    String? title,
    String? body,
    Widget? action,
    this.onTap,
    this.titleMaxLines = 1,
    this.bodyMaxLines = 2,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    double? leadingExtent,
    this.valueText,
    this.valueMaxLines = 1,
    this.showChevron,
    this.placeholder,
    this.error,
    this.errorText,
    this.valid = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    bool divider = false,
  }) : contentRow = false,
       isOptional = false,
       add = false,
       navigation = true,
       assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       assert(
         leadingExtent == null || (leading != null && leadingExtent > 0),
         'CatchField.leadingExtent requires non-null leading content.',
       ),
       super(
         key: key,
         title: title,
         body: body,
         action: action,
         emphasis: emphasis,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         leading: leading,
         leadingExtent: leadingExtent,
         status: status,
         divider: divider,
       );

  const _RowConfig.action({
    Key? key,
    String? title,
    String? body,
    Widget? action,
    required this.onTap,
    this.titleMaxLines = 1,
    this.bodyMaxLines = 2,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    Widget? leading,
    double? leadingExtent,
    this.valueText,
    this.valueMaxLines = 1,
    this.placeholder,
    this.error,
    this.errorText,
    this.valid = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    bool divider = false,
  }) : contentRow = false,
       showChevron = null,
       isOptional = false,
       add = false,
       navigation = false,
       assert(
         leading == null || icon == null,
         'Use either CatchField.leading or CatchField.icon, not both.',
       ),
       assert(
         leadingExtent == null || (leading != null && leadingExtent > 0),
         'CatchField.leadingExtent requires non-null leading content.',
       ),
       super(
         key: key,
         title: title,
         body: body,
         action: action,
         emphasis: emphasis,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         leading: leading,
         leadingExtent: leadingExtent,
         status: status,
         divider: divider,
       );

  const _RowConfig.add({
    Key? key,
    required String title,
    this.onTap,
    IconData? icon,
    CatchFieldTone tone = CatchFieldTone.primary,
  }) : titleMaxLines = 1,
       bodyMaxLines = 2,
       contentRow = false,
       valueText = null,
       valueMaxLines = 1,
       showChevron = null,
       placeholder = null,
       isOptional = false,
       error = null,
       errorText = null,
       valid = false,
       add = true,
       navigation = true,
       super(key: key, title: title, tone: tone, icon: icon);

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
  const _ToggleConfig.toggle({
    Key? key,
    String? title,
    String? body,
    required this.value,
    required ValueChanged<bool>? onChanged,
    this.titleMaxLines = 1,
    this.bodyMaxLines = 2,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    this.helperText,
    this.badgeLabel,
    this.badgeTone,
    CatchFieldStatus status = CatchFieldStatus.idle,
    bool divider = false,
  }) : onToggleChanged = onChanged,
       super(
         key: key,
         title: title,
         body: body,
         emphasis: emphasis,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         status: status,
         divider: divider,
       );

  final bool value;
  final ValueChanged<bool>? onToggleChanged;
  final int titleMaxLines;
  final int bodyMaxLines;
  final String? helperText;
  final String? badgeLabel;
  final CatchBadgeTone? badgeTone;
}

final class _EditConfig extends _CatchFieldConfig {
  const _EditConfig.input({
    Key? key,
    required String title,
    this.placeholder,
    this.emptyValueText,
    this.inputHint,
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
    bool enabled = true,
    this.isOptional = false,
    this.showLabel = true,
    this.helperText,
    this.helperTone = CatchFieldSupportTone.neutral,
    this.size = CatchFieldSize.md,
    this.textAlign = TextAlign.start,
    this.focused = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    this.mono = false,
    this.prefixIcon,
    this.prefixText,
    this.suffixIcon,
    this.suffixText,
    this.showClearButton = false,
    this.floatingLabel = true,
    CatchFieldVariant variant = CatchFieldVariant.row,
    IconData? icon,
    Color? iconColor,
    this.leadingUnit,
    Widget? action,
    this.error,
    this.errorText,
    bool divider = false,
    this.onTap,
  }) : explicitSave = false,
       open = null,
       onOpenChanged = null,
       supporting = null,
       secondaryAction = null,
       feedback = null,
       onCancel = null,
       onSubmit = null,
       isLoading = false,
       assert(
         inputHint == null || placeholder == null,
         'Use inputHint for editable fields; do not also pass placeholder.',
       ),
       assert(
         controller == null || initialValue == null,
         'CatchField.input cannot include both controller and initialValue.',
       ),
       super(
         key: key,
         title: title,
         action: action,
         variant: variant,
         icon: icon,
         iconColor: iconColor,
         divider: divider,
         enabled: enabled,
         status: status,
       );

  const _EditConfig.inputActions({
    Key? key,
    required String title,
    required this.controller,
    required bool open,
    required ValueChanged<bool> onOpenChanged,
    required VoidCallback onCancel,
    required VoidCallback onSubmit,
    this.placeholder,
    this.emptyValueText,
    this.inputHint,
    this.supporting,
    this.secondaryAction,
    this.feedback,
    this.isLoading = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    this.keyboardType,
    this.textInputAction,
    this.textCapitalization = TextCapitalization.sentences,
    this.inputFormatters,
    this.autofillHints,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    bool enabled = true,
    IconData? icon,
    Color? iconColor,
    CatchFieldTone tone = CatchFieldTone.normal,
    this.error,
    bool divider = false,
    this.onChanged,
    this.onSubmitted,
    this.onBlur,
    this.onFocusChanged,
    this.focusNode,
  }) : initialValue = null,
       retainFocusOnSubmitted = false,
       validator = null,
       obscureText = false,
       readOnly = false,
       autofocus = false,
       isOptional = false,
       showLabel = true,
       helperText = null,
       helperTone = CatchFieldSupportTone.neutral,
       size = CatchFieldSize.md,
       textAlign = TextAlign.start,
       focused = false,
       mono = false,
       prefixIcon = null,
       prefixText = null,
       suffixIcon = null,
       suffixText = null,
       showClearButton = false,
       floatingLabel = false,
       leadingUnit = null,
       errorText = null,
       onTap = null,
       explicitSave = true,
       open = open,
       onOpenChanged = onOpenChanged,
       onCancel = onCancel,
       onSubmit = onSubmit,
       super(
         key: key,
         title: title,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         enabled: enabled,
         divider: divider,
         status: status,
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
  const _SelectConfig.select({
    Key? key,
    required String title,
    required this.values,
    required this.itemLabel,
    required this.value,
    required this.onSelectChanged,
    required this.selectValidator,
    required this.placeholder,
    required this.prefixIcon,
    required this.showLabel,
    required this.size,
    required this.helperText,
    required this.helperTone,
    required bool enabled,
  }) : super(key: key, title: title, enabled: enabled);

  final List<Object?> values;
  final String Function(Object? item) itemLabel;
  final Object? value;
  final ValueChanged<Object?>? onSelectChanged;
  final FormFieldValidator<Object?>? selectValidator;
  final String? placeholder;
  final Widget? prefixIcon;
  final bool showLabel;
  final CatchFieldSize size;
  final String? helperText;
  final CatchFieldSupportTone helperTone;
}

final class _ControlConfig extends _CatchFieldConfig {
  const _ControlConfig.control({
    Key? key,
    required String title,
    String? body,
    required this.control,
    this.open,
    this.initiallyOpen = false,
    this.onOpenChanged,
    this.onCancel,
    this.onSubmit,
    this.isLoading = false,
    CatchFieldStatus status = CatchFieldStatus.idle,
    bool enabled = true,
    this.addable = false,
    this.isOptional = false,
    this.helperText,
    this.titleMaxLines = 1,
    this.bodyMaxLines = 2,
    CatchFieldEmphasis emphasis = CatchFieldEmphasis.body,
    CatchFieldTone tone = CatchFieldTone.normal,
    IconData? icon,
    Color? iconColor,
    this.placeholder,
    this.emptyValueText,
    this.error,
    this.errorText,
    bool divider = false,
  }) : super(
         key: key,
         title: title,
         body: body,
         emphasis: emphasis,
         tone: tone,
         icon: icon,
         iconColor: iconColor,
         divider: divider,
         enabled: enabled,
         status: status,
       );

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
