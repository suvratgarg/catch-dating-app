import 'package:catch_dating_app/core/firestore_error_message.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/core/widgets/catch_range_slider.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/chip_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/user_profile/domain/profile_validation.dart';
import 'package:catch_dating_app/user_profile/presentation/profile_edit_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

mixin _ProfileEditSaveState<T extends StatefulWidget> on State<T> {
  bool _isSaving = false;
  Object? _saveError;

  bool get isSaving => _isSaving;

  Future<void> saveAndPop(WidgetRef ref, Map<String, dynamic> fields) async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await _saveField(ref: ref, fields: fields);
      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = error;
      });
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

// ── Text fields ────────────────────────────────────────────────────────────────

Future<void> showTextEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required String currentValue,
  required String fieldName,
  TextInputType? keyboardType,
  TextCapitalization textCapitalization = TextCapitalization.sentences,
  Iterable<String>? autofillHints,
  FormFieldValidator<String>? validator,
  Object? Function(String value)? toFieldValue,
  Object? currentFieldValue,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _TextEditSheet(
      ref: ref,
      title: title,
      currentValue: currentValue,
      currentFieldValue: currentFieldValue ?? currentValue,
      fieldName: fieldName,
      maxLines: fieldName == 'bio' ? 4 : 1,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      validator: validator,
      toFieldValue: toFieldValue,
    ),
  );
}

class _TextEditSheet extends StatefulWidget {
  const _TextEditSheet({
    required this.ref,
    required this.title,
    required this.currentValue,
    required this.currentFieldValue,
    required this.fieldName,
    required this.maxLines,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
    this.validator,
    this.toFieldValue,
  });

  final WidgetRef ref;
  final String title;
  final String currentValue;
  final Object? currentFieldValue;
  final String fieldName;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;
  final Object? Function(String value)? toFieldValue;

  @override
  State<_TextEditSheet> createState() => _TextEditSheetState();
}

class _TextEditSheetState extends State<_TextEditSheet>
    with _ProfileEditSaveState<_TextEditSheet> {
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
    if (_formKey.currentState!.validate()) {
      final rawValue = _controller.text.trim();
      final fieldValue = widget.toFieldValue != null
          ? widget.toFieldValue!(rawValue)
          : rawValue;
      final isUnchanged =
          fieldValue == widget.currentFieldValue ||
          (fieldValue == null && widget.currentValue.trim().isEmpty) ||
          (fieldValue == '' && widget.currentFieldValue == null);
      if (isUnchanged) {
        Navigator.of(context).pop();
        return;
      }
      await saveAndPop(widget.ref, {widget.fieldName: fieldValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CatchBottomSheetScaffold(
        keyboardSafe: true,
        action: CatchButton(
          label: 'Done',
          onPressed: isSaving ? null : () => _submit(),
          isLoading: isSaving,
          fullWidth: true,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ?buildSaveError(),
            CatchTextField(
              label: widget.title,
              controller: _controller,
              enabled: !isSaving,
              autofocus: true,
              maxLines: widget.maxLines,
              keyboardType: widget.keyboardType,
              textCapitalization: widget.textCapitalization,
              textInputAction: TextInputAction.done,
              autofillHints: widget.autofillHints,
              validator: widget.validator,
              onSubmitted: (_) {
                _submit();
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Height field ───────────────────────────────────────────────────────────────

Future<void> showHeightEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int? currentValue,
}) async {
  final initialValue = normalizeHeightCm(currentValue);
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (ctx) => _HeightEditSheet(
      ref: ref,
      initialValue: initialValue,
      currentValue: currentValue,
    ),
  );
}

class _HeightEditSheet extends StatefulWidget {
  const _HeightEditSheet({
    required this.ref,
    required this.initialValue,
    required this.currentValue,
  });

  @override
  State<_HeightEditSheet> createState() => _HeightEditSheetState();

  final WidgetRef ref;
  final int initialValue;
  final int? currentValue;
}

class _HeightEditSheetState extends State<_HeightEditSheet>
    with _ProfileEditSaveState<_HeightEditSheet> {
  late int _heightCm;

  @override
  void initState() {
    super.initState();
    _heightCm = widget.initialValue;
  }

  Future<void> _submit() async {
    if (isSaving) return;
    if (_heightCm == widget.currentValue) {
      Navigator.of(context).pop();
      return;
    }
    await saveAndPop(widget.ref, {'height': _heightCm});
  }

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      title: 'Height',
      subtitle: '$minimumHeightCm-$maximumHeightCm cm',
      action: CatchButton(
        label: 'Done',
        onPressed: isSaving ? null : () => _submit(),
        isLoading: isSaving,
        fullWidth: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?buildSaveError(),
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
      ),
    );
  }
}

// ── Single-enum fields ─────────────────────────────────────────────────────────

Future<void> showSingleEnumSheet<T extends Labelled>({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required List<T> values,
  required T? currentValue,
  required String fieldName,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (ctx) => _SingleEnumEditSheet<T>(
      ref: ref,
      title: title,
      values: values,
      currentValue: currentValue,
      fieldName: fieldName,
    ),
  );
}

class _SingleEnumEditSheet<T extends Labelled> extends StatefulWidget {
  const _SingleEnumEditSheet({
    required this.ref,
    required this.title,
    required this.values,
    required this.currentValue,
    required this.fieldName,
  });

  final WidgetRef ref;
  final String title;
  final List<T> values;
  final T? currentValue;
  final String fieldName;

  @override
  State<_SingleEnumEditSheet<T>> createState() =>
      _SingleEnumEditSheetState<T>();
}

class _SingleEnumEditSheetState<T extends Labelled>
    extends State<_SingleEnumEditSheet<T>>
    with _ProfileEditSaveState<_SingleEnumEditSheet<T>> {
  T? _pendingSelection;

  @override
  void didUpdateWidget(covariant _SingleEnumEditSheet<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldName != widget.fieldName ||
        oldWidget.currentValue != widget.currentValue) {
      _pendingSelection = null;
    }
  }

  Future<void> _select(Set<T> next) async {
    if (isSaving) return;
    final selected = next.isEmpty ? null : next.first;
    if (selected == null) return;
    if (selected == widget.currentValue) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _pendingSelection = selected);
    await saveAndPop(widget.ref, {widget.fieldName: _enumName(selected)});
    if (mounted && !isSaving) {
      setState(() => _pendingSelection = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = isSaving
        ? _pendingSelection ?? widget.currentValue
        : widget.currentValue;
    return CatchBottomSheetScaffold(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s3,
        CatchSpacing.s4,
        CatchSpacing.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?buildSaveError(),
          ChipField<T>(
            key: ValueKey(
              'single-enum-${widget.fieldName}-${selected?.label ?? 'empty'}',
            ),
            label: widget.title,
            values: widget.values,
            selected: selected == null ? <T>{} : {selected},
            multiSelect: false,
            enabled: !isSaving,
            onChanged: (next) => _select(next),
          ),
          if (isSaving) ...[
            gapH16,
            _SavingInlineStatus(message: 'Saving ${widget.title}...'),
          ],
        ],
      ),
    );
  }
}

class _SavingInlineStatus extends StatelessWidget {
  const _SavingInlineStatus({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: CatchLoadingIndicator(strokeWidth: 2, color: t.primary),
        ),
        const SizedBox(width: CatchSpacing.s2),
        Text(message, style: CatchTextStyles.bodyS(context, color: t.ink2)),
      ],
    );
  }
}

// ── Multi-enum fields ──────────────────────────────────────────────────────────

Future<void> showMultiEnumSheet<T extends Labelled>({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required List<T> values,
  required List<T> currentValues,
  required String fieldName,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (ctx) => _MultiEnumEditSheet<T>(
      ref: ref,
      title: title,
      values: values,
      currentValues: currentValues,
      fieldName: fieldName,
    ),
  );
}

class _MultiEnumEditSheet<T extends Labelled> extends StatefulWidget {
  const _MultiEnumEditSheet({
    required this.ref,
    required this.title,
    required this.values,
    required this.currentValues,
    required this.fieldName,
  });

  final WidgetRef ref;
  final String title;
  final List<T> values;
  final List<T> currentValues;
  final String fieldName;

  @override
  State<_MultiEnumEditSheet<T>> createState() => _MultiEnumEditSheetState<T>();
}

class _MultiEnumEditSheetState<T extends Labelled>
    extends State<_MultiEnumEditSheet<T>>
    with _ProfileEditSaveState<_MultiEnumEditSheet<T>> {
  late Set<T> _selected = widget.currentValues.toSet();

  Future<void> _submit() async {
    if (isSaving) return;
    if (_selected.length == widget.currentValues.length &&
        _selected.containsAll(widget.currentValues)) {
      Navigator.of(context).pop();
      return;
    }
    await saveAndPop(widget.ref, {
      widget.fieldName: _selected.map(_enumName).toList(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s3,
        CatchSpacing.s4,
        CatchSpacing.s8,
      ),
      action: CatchButton(
        label: 'Done',
        onPressed: isSaving ? null : () => _submit(),
        isLoading: isSaving,
        fullWidth: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?buildSaveError(),
          ChipField<T>(
            label: widget.title,
            values: widget.values,
            selected: _selected,
            multiSelect: true,
            enabled: !isSaving,
            onChanged: (next) => setState(() => _selected = next),
          ),
        ],
      ),
    );
  }
}

// ── Range slider (shared) ───────────────────────────────────────────────────────

Future<void> _showRangeEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required int currentMin,
  required int currentMax,
  required double sliderMin,
  required double sliderMax,
  required int divisions,
  required String Function(RangeValues) displayText,
  required String Function(double) labelText,
  int Function(int)? saveEndValue,
  int? savedCurrentMax,
  required String minFieldName,
  required String maxFieldName,
}) async {
  await showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    builder: (ctx) => _RangeEditSheet(
      ref: ref,
      title: title,
      currentMin: currentMin,
      currentMax: currentMax,
      sliderMin: sliderMin,
      sliderMax: sliderMax,
      divisions: divisions,
      displayText: displayText,
      labelText: labelText,
      saveEndValue: saveEndValue,
      savedCurrentMax: savedCurrentMax,
      minFieldName: minFieldName,
      maxFieldName: maxFieldName,
    ),
  );
}

class _RangeEditSheet extends StatefulWidget {
  const _RangeEditSheet({
    required this.ref,
    required this.title,
    required this.currentMin,
    required this.currentMax,
    required this.sliderMin,
    required this.sliderMax,
    required this.divisions,
    required this.displayText,
    required this.labelText,
    required this.saveEndValue,
    required this.savedCurrentMax,
    required this.minFieldName,
    required this.maxFieldName,
  });

  final WidgetRef ref;
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

  @override
  State<_RangeEditSheet> createState() => _RangeEditSheetState();
}

class _RangeEditSheetState extends State<_RangeEditSheet>
    with _ProfileEditSaveState<_RangeEditSheet> {
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
      Navigator.of(context).pop();
      return;
    }
    await saveAndPop(widget.ref, {
      widget.minFieldName: newMin,
      widget.maxFieldName: newMax,
    });
  }

  @override
  Widget build(BuildContext context) {
    return CatchBottomSheetScaffold(
      title: widget.title,
      subtitle: widget.displayText(_range),
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s4,
        CatchSpacing.s3,
        CatchSpacing.s4,
        CatchSpacing.s8,
      ),
      action: CatchButton(
        label: 'Done',
        onPressed: isSaving ? null : () => _submit(),
        isLoading: isSaving,
        fullWidth: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ?buildSaveError(),
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
        ],
      ),
    );
  }
}

// ── Date of birth ──────────────────────────────────────────────────────────────

Future<void> showDateOfBirthEdit({
  required BuildContext context,
  required WidgetRef ref,
  required DateTime currentDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) async {
  final picked = await showDatePicker(
    context: context,
    initialDate: currentDate,
    firstDate: firstDate,
    lastDate: lastDate,
  );

  if (picked != null && picked != currentDate) {
    await _saveField(
      ref: ref,
      fields: {'dateOfBirth': Timestamp.fromDate(picked)},
    );
  }
}

// ── Pace range ─────────────────────────────────────────────────────────────────

Future<void> showPaceEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int currentMin,
  required int currentMax,
}) {
  return _showRangeEditSheet(
    context: context,
    ref: ref,
    title: 'Pace range',
    currentMin: currentMin,
    currentMax: currentMax,
    sliderMin: 240,
    sliderMax: 540,
    divisions: 20,
    displayText: (r) =>
        '${formatPace(r.start.round())} – ${formatPace(r.end.round())} /km',
    labelText: (v) => formatPace(v.round()),
    minFieldName: 'paceMinSecsPerKm',
    maxFieldName: 'paceMaxSecsPerKm',
  );
}

// ── Boolean switch ─────────────────────────────────────────────────────────────

Future<void> showBooleanEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required IconData icon,
  required bool currentValue,
  required String fieldName,
}) async {
  bool value = currentValue;
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    builder: (ctx) {
      final t = CatchTokens.of(ctx);
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return CatchBottomSheetScaffold(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s4,
              CatchSpacing.s3,
              CatchSpacing.s4,
              CatchSpacing.s8,
            ),
            action: CatchButton(
              label: 'Done',
              onPressed: () => Navigator.of(ctx).pop(value),
              fullWidth: true,
            ),
            child: Row(
              children: [
                Icon(icon, color: t.ink2),
                gapW16,
                Expanded(
                  child: Text(title, style: CatchTextStyles.titleL(context)),
                ),
                Switch(
                  value: value,
                  onChanged: (v) => setSheetState(() => value = v),
                ),
              ],
            ),
          );
        },
      );
    },
  );

  if (confirmed != null && confirmed != currentValue) {
    await _saveField(ref: ref, fields: {fieldName: confirmed});
  }
}
