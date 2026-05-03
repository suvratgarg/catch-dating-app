import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/chip_field.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Serializes profile saves so rapid edits don't race.
Future<void> _pendingSave = Future.value();

/// Persists [fields] to the current user's Firestore document via
/// [UserProfileRepository.updateUserProfile], which uses [DocumentReference.update]
/// to touch only the supplied keys. This avoids the Timestamp → DateTime →
/// Timestamp round-trip on [dateOfBirth] that a full-document [set] would cause.
Future<void> _saveField({
  required WidgetRef ref,
  required Map<String, dynamic> fields,
}) {
  _pendingSave = _pendingSave.then((_) async {
    final uid = ref.read(uidProvider).asData?.value;
    if (uid == null) return;
    await ref.read(userProfileRepositoryProvider).updateUserProfile(
      uid: uid,
      fields: fields,
    );
  }).catchError((Object error, StackTrace stack) {
    debugPrint('_saveField failed: $error\n$stack');
    // Reset the chain so subsequent saves are not blocked.
    _pendingSave = Future.value();
  });
  return _pendingSave;
}

String _enumName(Object value) =>
    value is Enum ? value.name : value.toString();

// ── Text fields ────────────────────────────────────────────────────────────────

Future<void> showTextEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required String currentValue,
  required String fieldName,
  FormFieldValidator<String>? validator,
}) async {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController(text: currentValue);
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Sizes.p16,
            Sizes.p12,
            Sizes.p16,
            MediaQuery.of(ctx).viewInsets.bottom + Sizes.p16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              gapH16,
              CatchTextField(
                label: title,
                controller: controller,
                autofocus: true,
                maxLines: fieldName == 'bio' ? 4 : 1,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                validator: validator,
                onSubmitted: (_) {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(ctx).pop(true);
                  }
                },
              ),
              gapH16,
              CatchButton(
                label: 'Done',
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(ctx).pop(true);
                  }
                },
                fullWidth: true,
              ),
            ],
          ),
        ),
      );
    },
  );
  controller.dispose();

  if (confirmed == true) {
    final newValue = controller.text.trim();
    if (newValue != currentValue) {
      await _saveField(ref: ref, fields: {fieldName: newValue});
    }
  }
}

// ── Integer fields ─────────────────────────────────────────────────────────────

Future<void> showIntEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required int? currentValue,
  required String fieldName,
  FormFieldValidator<String>? validator,
}) async {
  final formKey = GlobalKey<FormState>();
  final controller = TextEditingController(
    text: currentValue?.toString() ?? '',
  );
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return Form(
        key: formKey,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            Sizes.p16,
            Sizes.p12,
            Sizes.p16,
            MediaQuery.of(ctx).viewInsets.bottom + Sizes.p16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Theme.of(ctx).dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              gapH16,
              CatchTextField(
                label: title,
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                suffixText: title == 'Height' ? 'cm' : null,
                textInputAction: TextInputAction.done,
                validator: validator,
                onSubmitted: (_) {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(ctx).pop(true);
                  }
                },
              ),
              gapH16,
              CatchButton(
                label: 'Done',
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    Navigator.of(ctx).pop(true);
                  }
                },
                fullWidth: true,
              ),
            ],
          ),
        ),
      );
    },
  );
  controller.dispose();

  if (confirmed == true) {
    final text = controller.text.trim();
    final newValue = text.isEmpty ? null : int.tryParse(text);
    if (newValue != currentValue) {
      await _saveField(ref: ref, fields: {fieldName: newValue});
    }
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
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              Sizes.p16,
              Sizes.p12,
              Sizes.p16,
              Sizes.p32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                gapH16,
                ChipField<T>(
                  label: title,
                  values: values,
                  selected: {selected},
                  multiSelect: false,
                  onChanged: (next) {
                    setSheetState(() => selected = next.first);
                    Navigator.of(ctx).pop(next.first);
                  },
                ),
              ],
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
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              Sizes.p16,
              Sizes.p12,
              Sizes.p16,
              Sizes.p32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                gapH16,
                ChipField<T>(
                  label: title,
                  values: values,
                  selected: selected,
                  multiSelect: true,
                  onChanged: (next) => setSheetState(() => selected = next),
                ),
                gapH16,
                CatchButton(
                  label: 'Done',
                  onPressed: () => Navigator.of(ctx).pop(selected.toList()),
                  fullWidth: true,
                ),
              ],
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
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              Sizes.p16,
              Sizes.p12,
              Sizes.p16,
              Sizes.p32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                gapH16,
                Text(title, style: CatchTextStyles.titleL(context)),
                gapH4,
                Text(
                  displayText(range),
                  style: CatchTextStyles.bodyS(
                    context,
                    color: CatchTokens.of(context).ink3,
                  ),
                ),
                RangeSlider(
                  min: sliderMin,
                  max: sliderMax,
                  divisions: divisions,
                  values: range,
                  labels: RangeLabels(
                    labelText(range.start),
                    labelText(range.end),
                  ),
                  onChanged: (values) =>
                      setSheetState(() => range = values),
                ),
                gapH16,
                CatchButton(
                  label: 'Done',
                  onPressed: () => Navigator.of(ctx).pop(true),
                  fullWidth: true,
                ),
              ],
            ),
          );
        },
      );
    },
  );

  if (confirmed == true) {
    final newMin = range.start.round();
    final newMax = range.end.round();
    if (newMin != currentMin || newMax != currentMax) {
      await _saveField(ref: ref, fields: {
        minFieldName: newMin,
        maxFieldName: newMax,
      });
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
  return _showRangeEditSheet(
    context: context,
    ref: ref,
    title: 'Age range',
    currentMin: currentMin,
    currentMax: currentMax,
    sliderMin: 18,
    sliderMax: 99,
    divisions: 81,
    displayText: (r) => '${r.start.round()} – ${r.end.round()}',
    labelText: (v) => '${v.round()}',
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
    await _saveField(ref: ref, fields: {
      'dateOfBirth': Timestamp.fromDate(picked),
    });
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
          return Padding(
            padding: const EdgeInsets.fromLTRB(
              Sizes.p16,
              Sizes.p12,
              Sizes.p16,
              Sizes.p32,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(ctx).dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                gapH16,
                Row(
                  children: [
                    Icon(icon, color: t.ink2),
                    gapW16,
                    Expanded(
                      child: Text(
                        title,
                        style: CatchTextStyles.titleL(context),
                      ),
                    ),
                    Switch(
                      value: value,
                      onChanged: (v) => setSheetState(() => value = v),
                    ),
                  ],
                ),
                gapH16,
                CatchButton(
                  label: 'Done',
                  onPressed: () => Navigator.of(ctx).pop(value),
                  fullWidth: true,
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
