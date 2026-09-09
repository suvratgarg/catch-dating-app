part of 'catch_field.dart';

mixin _CatchFieldProperties {
  Record get _config;
  CatchContractFieldConstraints? get contract;
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
  String? get inlineMetadata => _rowConfig?.inlineMetadata;
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
  String? get toggleContractExemption => _toggleConfig?.contractExemption;

  /// Control revealed by a navigation-mode disclosure field.
  bool get initiallyOpen => _controlConfig?.initiallyOpen ?? false;

  /// Caller-owned disclosure state; null keeps expansion local.
  bool? get open => _controlConfig?.open ?? _editConfig?.open;
  ValueChanged<bool>? get onOpenChanged =>
      _controlConfig?.onOpenChanged ?? _editConfig?.onOpenChanged;
  bool get _explicitSaveInput => _editConfig?.explicitSave ?? false;

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
  List<TextInputFormatter>? get inputFormatters => _inputConfig != null
      ? _inputConfig!.inputFormatters
      : CatchContractFieldPolicy.effectiveInputFormatters(contract, null);
  Iterable<String>? get autofillHints => _inputConfig?.autofillHints;
  bool get obscureText => _inputConfig?.obscureText ?? false;
  int? get maxLines => _inputConfig == null ? 1 : _inputConfig!.maxLines;
  int? get minLines => _inputConfig?.minLines;
  int? get maxLength => _inputConfig != null
      ? _inputConfig!.maxLength
      : CatchContractFieldPolicy.effectiveMaxLength(contract, null);
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
  CatchFieldSupportRowTone get helperTone => switch (_config) {
    final _EditConfig config => config.helperTone,
    final _SelectConfig config => config.helperTone,
    _ => CatchFieldSupportRowTone.neutral,
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
  String? get prefixText => _inputConfig?.prefixText;
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
}
