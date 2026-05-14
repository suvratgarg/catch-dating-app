import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchMotion, CatchRadius, CatchSpacing, CatchTokens;
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_edit_controller.dart';
import 'package:catch_dating_app/user_profile/presentation/widgets/profile_info_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

typedef ProfileInlineSaveCallback = VoidCallback;

Future<void> _saveField({
  required WidgetRef ref,
  required Map<String, dynamic> fields,
}) {
  return ProfileEditController.saveFieldsMutation.run(
    ref,
    (tx) async =>
        tx.get(profileEditControllerProvider.notifier).saveFields(fields),
  );
}

String _enumName(Object value) => value is Enum ? value.name : value.toString();

mixin _InlineSaveState<T extends ConsumerStatefulWidget> on ConsumerState<T> {
  bool _isSaving = false;
  Object? _saveError;

  bool get isSaving => _isSaving;

  Future<bool> saveFields(Map<String, dynamic> fields) async {
    if (_isSaving) return false;
    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await _saveField(ref: ref, fields: fields);
      if (!mounted) return false;
      setState(() => _isSaving = false);
      return true;
    } catch (error) {
      if (!mounted) return false;
      setState(() {
        _isSaving = false;
        _saveError = error;
      });
      return false;
    }
  }

  Widget? buildSaveError() {
    final error = _saveError;
    if (error == null) return null;
    return ErrorBanner(
      message: appErrorMessage(error, context: AppErrorContext.profile),
    );
  }
}

class _InlineEditorPanel extends StatelessWidget {
  const _InlineEditorPanel({
    required this.isSaving,
    required this.onCancel,
    required this.onSubmit,
    this.saveError,
    this.children = const [],
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;
  final Widget? saveError;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final hasEditorContent = children.isNotEmpty || saveError != null;
    return _InlineEditorPadding(
      compact: !hasEditorContent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (saveError != null) ...[saveError!, gapH12],
          ...children,
          if (children.isNotEmpty) gapH12,
          _InlineEditorActions(
            isSaving: isSaving,
            onCancel: onCancel,
            onSubmit: onSubmit,
          ),
        ],
      ),
    );
  }
}

class ProfileInlineEditableText extends StatelessWidget {
  const ProfileInlineEditableText({
    super.key,
    required this.label,
    required this.controller,
    required this.focusNode,
    required this.enabled,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.textInputAction,
    this.maxLines = 1,
    this.minLines,
    this.autofillHints,
    this.onSubmitted,
  });

  static const double _minimumUnderlineWidth = 28;

  final String label;
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final TextInputAction? textInputAction;
  final int maxLines;
  final int? minLines;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final direction = Directionality.of(context);
    final textScaler = MediaQuery.textScalerOf(context);
    final valueStyle = CatchTextStyles.bodyL(context, color: t.ink);
    final lineCount = minLines ?? maxLines;
    final lineHeight =
        textScaler.scale(valueStyle.fontSize ?? 18) *
        (valueStyle.height ?? 1.2);
    final editableHeight = (lineHeight * lineCount) + Sizes.p3;

    return LayoutBuilder(
      builder: (context, constraints) {
        return AnimatedBuilder(
          animation: controller,
          builder: (context, _) {
            final textWidth = _measureTextWidth(
              text: controller.text,
              style: valueStyle,
              direction: direction,
              textScaler: textScaler,
            );
            final underlineWidth = textWidth
                .clamp(_minimumUnderlineWidth, constraints.maxWidth)
                .toDouble();

            return SizedBox(
              width: double.infinity,
              height: editableHeight,
              child: Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Semantics(
                    textField: true,
                    label: label,
                    child: EditableText(
                      controller: controller,
                      focusNode: focusNode,
                      readOnly: !enabled,
                      autofocus: true,
                      maxLines: maxLines,
                      minLines: minLines,
                      keyboardType: keyboardType,
                      textCapitalization: textCapitalization,
                      textInputAction:
                          textInputAction ??
                          (maxLines == 1
                              ? TextInputAction.done
                              : TextInputAction.newline),
                      autofillHints: autofillHints,
                      onSubmitted: onSubmitted,
                      style: valueStyle,
                      cursorColor: t.primary,
                      backgroundCursorColor: t.primary,
                      selectionColor: t.primary.withValues(alpha: 0.22),
                      cursorWidth: 2,
                      cursorRadius: const Radius.circular(CatchRadius.pill),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    bottom: 0,
                    child: AnimatedContainer(
                      width: underlineWidth,
                      height: 1.5,
                      duration: CatchMotion.fast,
                      curve: CatchMotion.standardCurve,
                      decoration: BoxDecoration(
                        color: t.primary.withValues(
                          alpha: enabled ? 0.9 : 0.35,
                        ),
                        borderRadius: BorderRadius.circular(CatchRadius.pill),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  double _measureTextWidth({
    required String text,
    required TextStyle style,
    required TextDirection direction,
    required TextScaler textScaler,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: direction,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    return painter.width;
  }
}

class ProfileInlineTextEntryEditor extends ConsumerStatefulWidget {
  const ProfileInlineTextEntryEditor({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.currentValue,
    required this.fieldName,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    this.currentFieldValue,
    this.isAddAffordance = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
    this.validator,
    this.toFieldValue,
  });

  final IconData icon;
  final String label;
  final String value;
  final String currentValue;
  final Object? currentFieldValue;
  final String fieldName;
  final bool isExpanded;
  final bool isAddAffordance;
  final int maxLines;
  final int? minLines;
  final VoidCallback onTap;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlineTextEntryEditor> createState() =>
      _ProfileInlineTextEntryEditorState();
}

class _ProfileInlineTextEntryEditorState
    extends ConsumerState<ProfileInlineTextEntryEditor>
    with _InlineSaveState<ProfileInlineTextEntryEditor> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _validationError;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
    _focusNode = FocusNode();
    _controller.addListener(_clearValidationError);
  }

  @override
  void didUpdateWidget(covariant ProfileInlineTextEntryEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isExpanded) return;
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValue != widget.currentValue) {
      _controller.text = widget.currentValue;
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_clearValidationError);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _clearValidationError() {
    if (_validationError == null) return;
    setState(() => _validationError = null);
  }

  Future<void> _submit() async {
    if (isSaving) return;
    final validationError = widget.validator?.call(_controller.text);
    if (validationError != null) {
      setState(() => _validationError = validationError);
      return;
    }

    final rawValue = _controller.text.trim();
    final Object? fieldValue = widget.toFieldValue != null
        ? widget.toFieldValue!(rawValue)
        : rawValue;
    final currentFieldValue = widget.currentFieldValue;
    final comparableCurrentValue = currentFieldValue ?? widget.currentValue;
    final isUnchanged =
        fieldValue == comparableCurrentValue ||
        (fieldValue == null && widget.currentValue.trim().isEmpty) ||
        (fieldValue == '' && currentFieldValue == null);
    if (isUnchanged) {
      widget.onCancel();
      return;
    }

    final saved = await saveFields({widget.fieldName: fieldValue});
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileInlineDisclosure(
      isExpanded: widget.isExpanded,
      header: ProfileInfoTile(
        icon: widget.icon,
        label: widget.label,
        value: widget.value,
        onTap: isSaving ? null : widget.onTap,
        isExpanded: widget.isExpanded,
        isAddAffordance: widget.isAddAffordance,
        valueEditor: widget.isExpanded
            ? ProfileInlineEditableText(
                label: widget.label,
                controller: _controller,
                focusNode: _focusNode,
                enabled: !isSaving,
                keyboardType: widget.keyboardType,
                textCapitalization: widget.textCapitalization,
                maxLines: widget.maxLines,
                minLines: widget.minLines,
                autofillHints: widget.autofillHints,
                onSubmitted: (_) => _submit(),
              )
            : null,
      ),
      body: _InlineEditorPanel(
        saveError: _validationError == null
            ? buildSaveError()
            : ErrorBanner(message: _validationError!),
        isSaving: isSaving,
        onCancel: widget.onCancel,
        onSubmit: _submit,
        children: const [],
      ),
    );
  }
}

class ProfileInlineHeightEditor extends ConsumerStatefulWidget {
  const ProfileInlineHeightEditor({
    super.key,
    required this.currentValue,
    required this.onSaved,
    required this.onCancel,
  });

  final int? currentValue;
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlineHeightEditor> createState() =>
      _ProfileInlineHeightEditorState();
}

class _ProfileInlineHeightEditorState
    extends ConsumerState<ProfileInlineHeightEditor>
    with _InlineSaveState<ProfileInlineHeightEditor> {
  late int _heightCm = normalizeHeightCm(widget.currentValue);

  Future<void> _submit() async {
    if (isSaving) return;
    if (_heightCm == widget.currentValue) {
      widget.onCancel();
      return;
    }
    final saved = await saveFields({'height': _heightCm});
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return _InlineEditorPanel(
      saveError: buildSaveError(),
      isSaving: isSaving,
      onCancel: widget.onCancel,
      onSubmit: _submit,
      children: [
        CatchNumberStepper(
          value: _heightCm,
          min: minimumHeightCm,
          max: maximumHeightCm,
          enabled: !isSaving,
          decreaseTooltip: 'Decrease height',
          increaseTooltip: 'Increase height',
          formatValue: (value) => '${value.round()} cm',
          onChanged: (value) => setState(() => _heightCm = value.round()),
        ),
      ],
    );
  }
}

class ProfileInlineSingleChoiceEntryEditor<T extends Labelled>
    extends ConsumerStatefulWidget {
  const ProfileInlineSingleChoiceEntryEditor({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.values,
    required this.currentValue,
    required this.fieldName,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    this.isAddAffordance = false,
    this.allowEmptySelection = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<T> values;
  final T? currentValue;
  final String fieldName;
  final bool isExpanded;
  final bool isAddAffordance;
  final bool allowEmptySelection;
  final VoidCallback onTap;
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlineSingleChoiceEntryEditor<T>> createState() =>
      _ProfileInlineSingleChoiceEntryEditorState<T>();
}

class _ProfileInlineSingleChoiceEntryEditorState<T extends Labelled>
    extends ConsumerState<ProfileInlineSingleChoiceEntryEditor<T>>
    with _InlineSaveState<ProfileInlineSingleChoiceEntryEditor<T>> {
  late T? _selected = widget.currentValue;

  @override
  void didUpdateWidget(
    covariant ProfileInlineSingleChoiceEntryEditor<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isExpanded) return;
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValue != widget.currentValue) {
      _selected = widget.currentValue;
    }
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (_selected == widget.currentValue) {
      widget.onCancel();
      return;
    }
    final saved = await saveFields({
      widget.fieldName: _selected == null ? null : _enumName(_selected!),
    });
    if (saved && mounted) {
      widget.onSaved();
    }
  }

  void _toggleSelectedValue(T value) {
    if (isSaving) return;
    setState(() {
      if (_selected == value && widget.allowEmptySelection) {
        _selected = null;
      } else {
        _selected = value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableValues = widget.values
        .where((value) => value != _selected)
        .toList(growable: false);

    return ProfileInlineDisclosure(
      isExpanded: widget.isExpanded,
      header: ProfileInfoTile(
        icon: widget.icon,
        label: widget.label,
        value: widget.value,
        onTap: isSaving ? null : widget.onTap,
        isExpanded: widget.isExpanded,
        isAddAffordance: widget.isAddAffordance,
        valueEditor: widget.isExpanded
            ? _ProfileSingleChipValueEditor<T>(
                emptyValue: widget.label,
                selected: _selected,
                enabled: !isSaving,
                allowEmptySelection: widget.allowEmptySelection,
                onSelectedTap: _toggleSelectedValue,
              )
            : null,
      ),
      body: _InlineEditorPanel(
        saveError: buildSaveError(),
        isSaving: isSaving,
        onCancel: widget.onCancel,
        onSubmit: _submit,
        children: [
          if (availableValues.isNotEmpty)
            _ProfileChipOptions<T>(
              values: availableValues,
              enabled: !isSaving,
              selected: const {},
              onTap: _toggleSelectedValue,
            ),
        ],
      ),
    );
  }
}

class ProfileInlineMultiChoiceEntryEditor<T extends Labelled>
    extends ConsumerStatefulWidget {
  const ProfileInlineMultiChoiceEntryEditor({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    required this.values,
    required this.currentValues,
    required this.fieldName,
    required this.isExpanded,
    required this.onTap,
    required this.onSaved,
    required this.onCancel,
    this.isAddAffordance = false,
    this.isOptional = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final List<T> values;
  final List<T> currentValues;
  final String fieldName;
  final bool isExpanded;
  final bool isAddAffordance;
  final bool isOptional;
  final VoidCallback onTap;
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlineMultiChoiceEntryEditor<T>> createState() =>
      _ProfileInlineMultiChoiceEntryEditorState<T>();
}

class _ProfileInlineMultiChoiceEntryEditorState<T extends Labelled>
    extends ConsumerState<ProfileInlineMultiChoiceEntryEditor<T>>
    with _InlineSaveState<ProfileInlineMultiChoiceEntryEditor<T>> {
  late Set<T> _selected = widget.currentValues.toSet();

  @override
  void didUpdateWidget(
    covariant ProfileInlineMultiChoiceEntryEditor<T> oldWidget,
  ) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isExpanded) return;
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValues != widget.currentValues) {
      _selected = widget.currentValues.toSet();
    }
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (_selected.length == widget.currentValues.length &&
        _selected.containsAll(widget.currentValues)) {
      widget.onCancel();
      return;
    }
    final saved = await saveFields({
      widget.fieldName: _selected.map(_enumName).toList(),
    });
    if (saved && mounted) widget.onSaved();
  }

  void _toggleSelectedValue(T value) {
    if (isSaving) return;
    setState(() {
      if (_selected.contains(value)) {
        if (widget.isOptional || _selected.length > 1) {
          _selected = {..._selected}..remove(value);
        }
      } else {
        _selected = {..._selected, value};
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableValues = widget.values
        .where((value) => !_selected.contains(value))
        .toList(growable: false);

    return ProfileInlineDisclosure(
      isExpanded: widget.isExpanded,
      header: ProfileInfoTile(
        icon: widget.icon,
        label: widget.label,
        value: widget.value,
        onTap: isSaving ? null : widget.onTap,
        isExpanded: widget.isExpanded,
        isAddAffordance: widget.isAddAffordance,
        valueEditor: widget.isExpanded
            ? _ProfileMultiChipValueEditor<T>(
                emptyValue: widget.label,
                selected: _selected,
                enabled: !isSaving,
                onSelectedTap: _toggleSelectedValue,
              )
            : null,
      ),
      body: _InlineEditorPanel(
        saveError: buildSaveError(),
        isSaving: isSaving,
        onCancel: widget.onCancel,
        onSubmit: _submit,
        children: [
          if (availableValues.isNotEmpty)
            _ProfileChipOptions<T>(
              values: availableValues,
              enabled: !isSaving,
              selected: const {},
              onTap: _toggleSelectedValue,
            ),
        ],
      ),
    );
  }
}

class _ProfileSingleChipValueEditor<T extends Labelled>
    extends StatelessWidget {
  const _ProfileSingleChipValueEditor({
    required this.emptyValue,
    required this.selected,
    required this.enabled,
    required this.allowEmptySelection,
    required this.onSelectedTap,
  });

  final String emptyValue;
  final T? selected;
  final bool enabled;
  final bool allowEmptySelection;
  final ValueChanged<T> onSelectedTap;

  @override
  Widget build(BuildContext context) {
    final selected = this.selected;
    if (selected == null) {
      return _ProfileChipPlaceholder(value: emptyValue, isAddAffordance: true);
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: CatchChip(
        label: selected.label,
        active: true,
        enabled: enabled,
        onTap: allowEmptySelection ? () => onSelectedTap(selected) : null,
      ),
    );
  }
}

class _ProfileMultiChipValueEditor<T extends Labelled> extends StatelessWidget {
  const _ProfileMultiChipValueEditor({
    required this.emptyValue,
    required this.selected,
    required this.enabled,
    required this.onSelectedTap,
  });

  final String emptyValue;
  final Set<T> selected;
  final bool enabled;
  final ValueChanged<T> onSelectedTap;

  @override
  Widget build(BuildContext context) {
    if (selected.isEmpty) {
      return _ProfileChipPlaceholder(value: emptyValue, isAddAffordance: true);
    }

    return Wrap(
      spacing: CatchSpacing.s2,
      runSpacing: CatchSpacing.s2,
      children: [
        for (final value in selected)
          CatchChip(
            label: value.label,
            active: true,
            icon: const Icon(Icons.check_rounded),
            enabled: enabled,
            onTap: () => onSelectedTap(value),
          ),
      ],
    );
  }
}

class _ProfileChipPlaceholder extends StatelessWidget {
  const _ProfileChipPlaceholder({
    required this.value,
    required this.isAddAffordance,
  });

  final String value;
  final bool isAddAffordance;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Text(
      isAddAffordance ? '+ $value' : value,
      style: CatchTextStyles.bodyL(
        context,
        color: isAddAffordance ? t.ink3 : null,
      ),
    );
  }
}

class _ProfileChipOptions<T extends Labelled> extends StatelessWidget {
  const _ProfileChipOptions({
    required this.values,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  final List<T> values;
  final Set<T> selected;
  final bool enabled;
  final ValueChanged<T> onTap;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: CatchSpacing.s3,
      runSpacing: CatchSpacing.s3,
      children: [
        for (final value in values)
          CatchChip(
            label: value.label,
            active: selected.contains(value),
            enabled: enabled,
            onTap: () => onTap(value),
          ),
      ],
    );
  }
}

class ProfileInlineRangeEditor extends ConsumerStatefulWidget {
  const ProfileInlineRangeEditor({
    super.key,
    required this.title,
    required this.currentMin,
    required this.currentMax,
    required this.sliderMin,
    required this.sliderMax,
    required this.divisions,
    required this.labelText,
    required this.minFieldName,
    required this.maxFieldName,
    required this.onSaved,
    required this.onCancel,
    this.saveEndValue,
    this.savedCurrentMax,
  });

  final String title;
  final int currentMin;
  final int currentMax;
  final double sliderMin;
  final double sliderMax;
  final int divisions;
  final String Function(double) labelText;
  final int Function(int)? saveEndValue;
  final int? savedCurrentMax;
  final String minFieldName;
  final String maxFieldName;
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlineRangeEditor> createState() =>
      _ProfileInlineRangeEditorState();
}

class _ProfileInlineRangeEditorState
    extends ConsumerState<ProfileInlineRangeEditor>
    with _InlineSaveState<ProfileInlineRangeEditor> {
  late RangeValues _range = RangeValues(
    widget.currentMin.toDouble(),
    widget.currentMax.toDouble(),
  );

  Future<void> _submit() async {
    if (isSaving) return;
    final newMin = _range.start.round();
    final newMax =
        widget.saveEndValue?.call(_range.end.round()) ?? _range.end.round();
    if (newMin == widget.currentMin &&
        newMax == (widget.savedCurrentMax ?? widget.currentMax)) {
      widget.onCancel();
      return;
    }
    final saved = await saveFields({
      widget.minFieldName: newMin,
      widget.maxFieldName: newMax,
    });
    if (saved && mounted) widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    return _InlineEditorPanel(
      saveError: buildSaveError(),
      isSaving: isSaving,
      onCancel: widget.onCancel,
      onSubmit: _submit,
      children: [
        CatchRangeSlider(
          min: widget.sliderMin,
          max: widget.sliderMax,
          divisions: widget.divisions,
          values: _range,
          minLabel: widget.labelText(widget.sliderMin),
          maxLabel: widget.labelText(widget.sliderMax),
          labels: RangeLabels(
            widget.labelText(_range.start),
            widget.labelText(_range.end),
          ),
          onChanged: isSaving
              ? null
              : (values) => setState(() => _range = values),
        ),
      ],
    );
  }
}

class _InlineEditorActions extends StatelessWidget {
  const _InlineEditorActions({
    required this.isSaving,
    required this.onCancel,
    required this.onSubmit,
  });

  final bool isSaving;
  final VoidCallback onCancel;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        CatchTextButton(
          label: 'Cancel',
          onPressed: isSaving ? null : onCancel,
          tone: CatchTextButtonTone.neutral,
        ),
        gapW12,
        CatchButton(
          label: 'Done',
          onPressed: isSaving ? null : onSubmit,
          isLoading: isSaving,
          size: CatchButtonSize.sm,
        ),
      ],
    );
  }
}

class _InlineEditorPadding extends StatelessWidget {
  const _InlineEditorPadding({required this.child, required this.compact});

  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: compact ? 0 : CatchSpacing.s2,
        left: CatchSpacing.s10,
        right: CatchSpacing.s2,
        bottom: compact ? CatchSpacing.s3 : CatchSpacing.s5,
      ),
      child: child,
    );
  }
}
