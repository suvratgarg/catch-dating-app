import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/events/presentation/create_event_form_keys.dart';
import 'package:catch_dating_app/events/presentation/widgets/field_label.dart';
import 'package:catch_dating_app/events/presentation/widgets/picker_tile.dart';
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
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          16,
          CatchSpacing.s5,
          24,
        ),
        children: [
          const FieldLabel('Date'),
          const SizedBox(height: 8),
          PickerTile(
            key: CreateEventFormKeys.datePicker,
            icon: Icons.calendar_today_outlined,
            value: dateController.text.isEmpty ? null : dateController.text,
            placeholder: 'Select a date',
            onTap: onPickDate,
          ),
          FormField<String>(
            validator: (_) =>
                dateController.text.isEmpty ? 'Please select a date' : null,
            builder: (field) => field.hasError
                ? Padding(
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(fontSize: 12, color: t.primary),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 20),
          const FieldLabel('Start time'),
          const SizedBox(height: 8),
          PickerTile(
            key: CreateEventFormKeys.timePicker,
            icon: Icons.schedule_outlined,
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
                    padding: const EdgeInsets.only(top: 4, left: 4),
                    child: Text(
                      field.errorText!,
                      style: TextStyle(fontSize: 12, color: t.primary),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          if (scheduleErrorText != null)
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 4),
              child: Text(
                scheduleErrorText!,
                style: TextStyle(fontSize: 12, color: t.primary),
              ),
            ),
          const SizedBox(height: 20),
          const FieldLabel('Duration'),
          const SizedBox(height: 8),
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
