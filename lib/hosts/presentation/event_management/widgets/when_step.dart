import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/field_label.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/picker_tile.dart';
import 'package:flutter/material.dart';

class WhenStep extends StatelessWidget {
  const WhenStep({
    super.key,
    required this.formKey,
    required this.dateController,
    required this.startTimeController,
    required this.durationMinutes,
    required this.onPickDate,
    required this.onPickTime,
    required this.onDecreaseDuration,
    required this.onIncreaseDuration,
    required this.formatDuration,
    this.scheduleErrorText,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController dateController;
  final TextEditingController startTimeController;
  final int durationMinutes;
  final VoidCallback onPickDate;
  final VoidCallback onPickTime;
  final VoidCallback? onDecreaseDuration;
  final VoidCallback? onIncreaseDuration;
  final String Function(int) formatDuration;
  final String? scheduleErrorText;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Form(
      key: formKey,
      child: ListView(
        padding: CatchInsets.formStepBody,
        children: [
          const FieldLabel('Date'),
          gapH8,
          PickerTile(
            key: CreateEventFormKeys.datePicker,
            icon: CatchIcons.calendarTodayOutlined,
            value: dateController.text.isEmpty ? null : dateController.text,
            placeholder: 'Select a date',
            onTap: onPickDate,
          ),
          FormField<String>(
            validator: (_) =>
                dateController.text.isEmpty ? 'Please select a date' : null,
            builder: (field) => field.hasError
                ? Padding(
                    padding: const EdgeInsets.only(
                      top: CatchSpacing.s1,
                      left: CatchSpacing.s1,
                    ),
                    child: Text(
                      field.errorText!,
                      style: CatchTextStyles.supporting(
                        context,
                        color: t.primary,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          gapH20,
          const FieldLabel('Start time'),
          gapH8,
          PickerTile(
            key: CreateEventFormKeys.timePicker,
            icon: CatchIcons.scheduleOutlined,
            value: startTimeController.text.isEmpty
                ? null
                : startTimeController.text,
            placeholder: 'Select start time',
            onTap: onPickTime,
          ),
          FormField<String>(
            validator: (_) =>
                startTimeController.text.isEmpty ? 'Required' : null,
            builder: (field) => field.hasError
                ? Padding(
                    padding: const EdgeInsets.only(
                      top: CatchSpacing.s1,
                      left: CatchSpacing.s1,
                    ),
                    child: Text(
                      field.errorText!,
                      style: CatchTextStyles.supporting(
                        context,
                        color: t.primary,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (scheduleErrorText != null)
            Padding(
              padding: const EdgeInsets.only(
                top: CatchSpacing.s1,
                left: CatchSpacing.s1,
              ),
              child: Text(
                scheduleErrorText!,
                style: CatchTextStyles.supporting(context, color: t.primary),
              ),
            ),
          gapH20,
          const FieldLabel('Duration'),
          gapH8,
          CatchNumberStepper(
            value: durationMinutes,
            onDecrease: onDecreaseDuration,
            onIncrease: onIncreaseDuration,
            decreaseTooltip: 'Decrease duration',
            increaseTooltip: 'Increase duration',
            formatValue: (value) => formatDuration(value.round()),
          ),
        ],
      ),
    );
  }
}
