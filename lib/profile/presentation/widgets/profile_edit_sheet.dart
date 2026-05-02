import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/chip_field.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> _saveField({
  required WidgetRef ref,
  required UserProfile Function(UserProfile) edit,
}) async {
  final current = ref.read(userProfileStreamProvider).asData?.value;
  if (current == null) return;
  await ref.read(userProfileRepositoryProvider).setUserProfile(
    userProfile: edit(current),
  );
}

// ── Text fields ────────────────────────────────────────────────────────────────

Future<void> showTextEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required String currentValue,
  required UserProfile Function(UserProfile, String) applyEdit,
}) async {
  final controller = TextEditingController(text: currentValue);
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return Padding(
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
              maxLines: title == 'Bio' ? 4 : 1,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onSubmitted: (_) {
                Navigator.of(ctx).pop(true);
              },
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
  controller.dispose();

  if (confirmed == true) {
    final newValue = controller.text.trim();
    if (newValue != currentValue) {
      await _saveField(ref: ref, edit: (u) => applyEdit(u, newValue));
    }
  }
}

// ── Integer fields ─────────────────────────────────────────────────────────────

Future<void> showIntEditSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required int? currentValue,
  required UserProfile Function(UserProfile, int?) applyEdit,
}) async {
  final controller = TextEditingController(
    text: currentValue?.toString() ?? '',
  );
  final confirmed = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return Padding(
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
              onSubmitted: (_) {
                Navigator.of(ctx).pop(true);
              },
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
  controller.dispose();

  if (confirmed == true) {
    final text = controller.text.trim();
    final newValue = text.isEmpty ? null : int.tryParse(text);
    if (newValue != currentValue) {
      await _saveField(ref: ref, edit: (u) => applyEdit(u, newValue));
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
  required UserProfile Function(UserProfile, T) applyEdit,
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
    await _saveField(ref: ref, edit: (u) => applyEdit(u, result!));
  }
}

// ── Multi-enum fields ──────────────────────────────────────────────────────────

Future<void> showMultiEnumSheet<T extends Labelled>({
  required BuildContext context,
  required WidgetRef ref,
  required String title,
  required List<T> values,
  required List<T> currentValues,
  required UserProfile Function(UserProfile, List<T>) applyEdit,
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
    await _saveField(ref: ref, edit: (u) => applyEdit(u, result));
  }
}

// ── Age range ──────────────────────────────────────────────────────────────────

Future<void> showAgeRangeSheet({
  required BuildContext context,
  required WidgetRef ref,
  required int currentMin,
  required int currentMax,
}) async {
  final minController = TextEditingController(text: currentMin.toString());
  final maxController = TextEditingController(text: currentMax.toString());

  final result = await showModalBottomSheet<({int min, int max})>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return Padding(
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
            Row(
              children: [
                Expanded(
                  child: CatchTextField(
                    label: 'Min age',
                    controller: minController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.next,
                  ),
                ),
                gapW12,
                Expanded(
                  child: CatchTextField(
                    label: 'Max age',
                    controller: maxController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      Navigator.of(ctx).pop((
                        min: int.tryParse(minController.text) ?? currentMin,
                        max: int.tryParse(maxController.text) ?? currentMax,
                      ));
                    },
                  ),
                ),
              ],
            ),
            gapH16,
            CatchButton(
              label: 'Done',
              onPressed: () => Navigator.of(ctx).pop((
                min: int.tryParse(minController.text) ?? currentMin,
                max: int.tryParse(maxController.text) ?? currentMax,
              )),
              fullWidth: true,
            ),
          ],
        ),
      );
    },
  );

  minController.dispose();
  maxController.dispose();

  if (result != null && (result.min != currentMin || result.max != currentMax)) {
    await _saveField(
      ref: ref,
      edit: (u) => u.copyWith(
        minAgePreference: result.min,
        maxAgePreference: result.max,
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
      edit: (u) => u.copyWith(dateOfBirth: picked),
    );
  }
}
