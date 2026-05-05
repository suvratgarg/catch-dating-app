import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/chip_field.dart';
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
}) async {
  final newValue = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) => _TextEditSheet(
      title: title,
      currentValue: currentValue,
      maxLines: fieldName == 'bio' ? 4 : 1,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      autofillHints: autofillHints,
      validator: validator,
    ),
  );

  if (newValue != null && newValue != currentValue) {
    await _saveField(
      ref: ref,
      fields: {fieldName: toFieldValue?.call(newValue) ?? newValue},
    );
  }
}

class _TextEditSheet extends StatefulWidget {
  const _TextEditSheet({
    required this.title,
    required this.currentValue,
    required this.maxLines,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.autofillHints,
    this.validator,
  });

  final String title;
  final String currentValue;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final Iterable<String>? autofillHints;
  final FormFieldValidator<String>? validator;

  @override
  State<_TextEditSheet> createState() => _TextEditSheetState();
}

class _TextEditSheetState extends State<_TextEditSheet> {
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

  void _submit() {
    if (_formKey.currentState!.validate()) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: CatchBottomSheetScaffold(
        keyboardSafe: true,
        action: CatchButton(label: 'Done', onPressed: _submit, fullWidth: true),
        child: CatchTextField(
          label: widget.title,
          controller: _controller,
          autofocus: true,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          textCapitalization: widget.textCapitalization,
          textInputAction: TextInputAction.done,
          autofillHints: widget.autofillHints,
          validator: widget.validator,
          onSubmitted: (_) => _submit(),
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
  final result = await showModalBottomSheet<int>(
    context: context,
    useSafeArea: true,
    builder: (ctx) => _HeightEditSheet(initialValue: initialValue),
  );

  if (result != null && result != currentValue) {
    await _saveField(ref: ref, fields: {'height': result});
  }
}

class _HeightEditSheet extends StatefulWidget {
  const _HeightEditSheet({required this.initialValue});

  @override
  State<_HeightEditSheet> createState() => _HeightEditSheetState();

  final int initialValue;
}

class _HeightEditSheetState extends State<_HeightEditSheet> {
  late int _heightCm;

  @override
  void initState() {
    super.initState();
    _heightCm = widget.initialValue;
  }

  VoidCallback? get _decrease =>
      _heightCm > minimumHeightCm ? () => setState(() => _heightCm--) : null;

  VoidCallback? get _increase =>
      _heightCm < maximumHeightCm ? () => setState(() => _heightCm++) : null;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchBottomSheetScaffold(
      title: 'Height',
      subtitle: '$minimumHeightCm-$maximumHeightCm cm',
      action: CatchButton(
        label: 'Done',
        onPressed: () => Navigator.of(context).pop(_heightCm),
        fullWidth: true,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.raised,
          borderRadius: BorderRadius.circular(CatchRadius.md),
          border: Border.all(color: t.line),
        ),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Decrease height',
              icon: Icon(Icons.remove_rounded, color: t.ink),
              onPressed: _decrease,
              visualDensity: VisualDensity.compact,
            ),
            Expanded(
              child: Center(
                child: Text(
                  '$_heightCm cm',
                  style: CatchTextStyles.mono(context),
                ),
              ),
            ),
            IconButton(
              tooltip: 'Increase height',
              icon: Icon(Icons.add_rounded, color: t.ink),
              onPressed: _increase,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
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
  required T currentValue,
  required String fieldName,
}) async {
  final result = await showModalBottomSheet<T>(
    context: context,
    useSafeArea: true,
    builder: (ctx) {
      // Track the selection locally so user sees immediate feedback.
      T selected = currentValue;
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return CatchBottomSheetScaffold(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s4,
              CatchSpacing.s3,
              CatchSpacing.s4,
              CatchSpacing.s8,
            ),
            child: ChipField<T>(
              label: title,
              values: values,
              selected: {selected},
              multiSelect: false,
              onChanged: (next) {
                setSheetState(() => selected = next.first);
                Navigator.of(ctx).pop(next.first);
              },
            ),
          );
        },
      );
    },
  );

  if (result != null && result != currentValue) {
    await _saveField(ref: ref, fields: {fieldName: _enumName(result)});
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
  final result = await showModalBottomSheet<List<T>>(
    context: context,
    useSafeArea: true,
    builder: (ctx) {
      Set<T> selected = currentValues.toSet();
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
              onPressed: () => Navigator.of(ctx).pop(selected.toList()),
              fullWidth: true,
            ),
            child: ChipField<T>(
              label: title,
              values: values,
              selected: selected,
              multiSelect: true,
              onChanged: (next) => setSheetState(() => selected = next),
            ),
          );
        },
      );
    },
  );

  if (result != null) {
    await _saveField(
      ref: ref,
      fields: {fieldName: result.map(_enumName).toList()},
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
  RangeValues range = RangeValues(currentMin.toDouble(), currentMax.toDouble());

  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    useSafeArea: true,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (ctx, setSheetState) {
          return CatchBottomSheetScaffold(
            title: title,
            subtitle: displayText(range),
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s4,
              CatchSpacing.s3,
              CatchSpacing.s4,
              CatchSpacing.s8,
            ),
            action: CatchButton(
              label: 'Done',
              onPressed: () => Navigator.of(ctx).pop(true),
              fullWidth: true,
            ),
            child: RangeSlider(
              min: sliderMin,
              max: sliderMax,
              divisions: divisions,
              values: range,
              labels: RangeLabels(labelText(range.start), labelText(range.end)),
              onChanged: (values) => setSheetState(() => range = values),
            ),
          );
        },
      );
    },
  );

  if (confirmed == true) {
    final newMin = range.start.round();
    final newMax = saveEndValue?.call(range.end.round()) ?? range.end.round();
    if (newMin != currentMin || newMax != (savedCurrentMax ?? currentMax)) {
      await _saveField(
        ref: ref,
        fields: {minFieldName: newMin, maxFieldName: newMax},
      );
    }
  }
}

// ── Age range ──────────────────────────────────────────────────────────────────

Future<void> showAgeRangeSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int currentMin,
  required int currentMax,
}) {
  final normalizedRange = normalizeAgePreferenceRange(
    minAgePreference: currentMin,
    maxAgePreference: currentMax,
  );

  return _showRangeEditSheet(
    context: context,
    ref: ref,
    title: 'Age range',
    currentMin: normalizedRange.minAge,
    currentMax: normalizedRange.maxAge
        .clamp(minimumProfileAge, preferredMatchAgeOpenEndedDisplayAge)
        .toInt(),
    sliderMin: minimumProfileAge.toDouble(),
    sliderMax: preferredMatchAgeOpenEndedDisplayAge.toDouble(),
    divisions: preferredMatchAgeOpenEndedDisplayAge - minimumProfileAge,
    displayText: (r) =>
        '${r.start.round()} – ${formatPreferredMatchAge(r.end.round())}',
    labelText: (v) => formatPreferredMatchAge(v.round()),
    saveEndValue: preferredMatchAgeStorageValue,
    savedCurrentMax: normalizedRange.maxAge,
    minFieldName: 'minAgePreference',
    maxFieldName: 'maxAgePreference',
  );
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
