import 'package:catch_dating_app/core/firestore_error_message.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart'
    show CatchSpacing;
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/chip_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_edit_controller.dart';
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
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
      child: ErrorBanner(message: firestoreErrorMessage(error)),
    );
  }
}

class ProfileInlineTextEditor extends ConsumerStatefulWidget {
  const ProfileInlineTextEditor({
    super.key,
    required this.label,
    required this.currentValue,
    required this.fieldName,
    required this.onSaved,
    required this.onCancel,
    this.currentFieldValue,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
    this.validator,
    this.toFieldValue,
  });

  final String label;
  final String currentValue;
  final Object? currentFieldValue;
  final String fieldName;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlineTextEditor> createState() =>
      _ProfileInlineTextEditorState();
}

class _ProfileInlineTextEditorState
    extends ConsumerState<ProfileInlineTextEditor>
    with _InlineSaveState<ProfileInlineTextEditor> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (!_formKey.currentState!.validate()) return;

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
    return _InlineEditorPadding(
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ?buildSaveError(),
            CatchTextField(
              label: widget.label,
              controller: _controller,
              enabled: !isSaving,
              autofocus: true,
              maxLines: widget.maxLines,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              textInputAction: widget.maxLines == 1
                  ? TextInputAction.done
                  : TextInputAction.newline,
              autofillHints: widget.autofillHints,
              validator: widget.validator,
              onSubmitted: (_) => _submit(),
            ),
            gapH12,
            _InlineEditorActions(
              isSaving: isSaving,
              onCancel: widget.onCancel,
              onSubmit: _submit,
            ),
          ],
        ),
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
    return _InlineEditorPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?buildSaveError(),
          Text(
            '$minimumHeightCm-$maximumHeightCm cm',
            style: CatchTextStyles.bodyS(context),
          ),
          gapH8,
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
          gapH12,
          _InlineEditorActions(
            isSaving: isSaving,
            onCancel: widget.onCancel,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

class ProfileInlineSingleChoiceEditor<T extends Labelled>
    extends ConsumerStatefulWidget {
  const ProfileInlineSingleChoiceEditor({
    super.key,
    required this.label,
    required this.values,
    required this.currentValue,
    required this.fieldName,
    required this.onSaved,
    required this.onCancel,
  });

  final String label;
  final List<T> values;
  final T? currentValue;
  final String fieldName;
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlineSingleChoiceEditor<T>> createState() =>
      _ProfileInlineSingleChoiceEditorState<T>();
}

class _ProfileInlineSingleChoiceEditorState<T extends Labelled>
    extends ConsumerState<ProfileInlineSingleChoiceEditor<T>>
    with _InlineSaveState<ProfileInlineSingleChoiceEditor<T>> {
  late T? _selected = widget.currentValue;

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

  @override
  Widget build(BuildContext context) {
    return _InlineEditorPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?buildSaveError(),
          ChipField<T>(
            key: ValueKey(
              'inline-single-${widget.fieldName}-${_selected?.label ?? 'empty'}',
            ),
            label: widget.label,
            values: widget.values,
            selected: _selected == null ? <T>{} : {_selected as T},
            multiSelect: false,
            isOptional: true,
            showLabel: false,
            allowEmptySingleSelection: true,
            enabled: !isSaving,
            onChanged: (next) =>
                setState(() => _selected = next.isEmpty ? null : next.first),
          ),
          gapH12,
          _InlineEditorActions(
            isSaving: isSaving,
            onCancel: widget.onCancel,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}

class ProfileInlineMultiChoiceEditor<T extends Labelled>
    extends ConsumerStatefulWidget {
  const ProfileInlineMultiChoiceEditor({
    super.key,
    required this.label,
    required this.values,
    required this.currentValues,
    required this.fieldName,
    required this.onSaved,
    required this.onCancel,
  });

  final String label;
  final List<T> values;
  final List<T> currentValues;
  final String fieldName;
  final ProfileInlineSaveCallback onSaved;
  final VoidCallback onCancel;

  @override
  ConsumerState<ProfileInlineMultiChoiceEditor<T>> createState() =>
      _ProfileInlineMultiChoiceEditorState<T>();
}

class _ProfileInlineMultiChoiceEditorState<T extends Labelled>
    extends ConsumerState<ProfileInlineMultiChoiceEditor<T>>
    with _InlineSaveState<ProfileInlineMultiChoiceEditor<T>> {
  late Set<T> _selected = widget.currentValues.toSet();

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

  @override
  Widget build(BuildContext context) {
    return _InlineEditorPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?buildSaveError(),
          ChipField<T>(
            label: widget.label,
            values: widget.values,
            selected: _selected,
            multiSelect: true,
            showLabel: false,
            enabled: !isSaving,
            onChanged: (next) => setState(() => _selected = next),
          ),
          gapH12,
          _InlineEditorActions(
            isSaving: isSaving,
            onCancel: widget.onCancel,
            onSubmit: _submit,
          ),
        ],
      ),
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
    required this.displayText,
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
  final String Function(RangeValues) displayText;
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
    return _InlineEditorPadding(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?buildSaveError(),
          Text(
            widget.displayText(_range),
            style: CatchTextStyles.bodyM(context),
          ),
          gapH8,
          CatchRangeSlider(
            min: widget.sliderMin,
            max: widget.sliderMax,
            divisions: widget.divisions,
            values: _range,
            labels: RangeLabels(
              widget.labelText(_range.start),
              widget.labelText(_range.end),
            ),
            onChanged: isSaving
                ? null
                : (values) => setState(() => _range = values),
          ),
          gapH12,
          _InlineEditorActions(
            isSaving: isSaving,
            onCancel: widget.onCancel,
            onSubmit: _submit,
          ),
        ],
      ),
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
      children: [
        CatchTextButton(
          label: 'Cancel',
          onPressed: isSaving ? null : onCancel,
          tone: CatchTextButtonTone.neutral,
        ),
        const Spacer(),
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
  const _InlineEditorPadding({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: CatchSpacing.s10,
        right: CatchSpacing.s1,
        bottom: CatchSpacing.s4,
      ),
      child: child,
    );
  }
}
