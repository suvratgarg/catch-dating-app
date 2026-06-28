import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_control_shell.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:flutter/material.dart';

class WhenStep extends StatelessWidget {
  const WhenStep({
    super.key,
    required this.formKey,
    this.autovalidateMode = AutovalidateMode.disabled,
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
  final AutovalidateMode autovalidateMode;
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
      autovalidateMode: autovalidateMode,
      child: ListView(
        padding: CatchInsets.formStepBody,
        children: [
          const CatchFormFieldLabel(label: 'Date', large: true),
          gapH8,
          _buildPickerTile(
            key: CreateEventFormKeys.datePicker,
            context: context,
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
          const CatchFormFieldLabel(label: 'Start time', large: true),
          gapH8,
          _buildPickerTile(
            key: CreateEventFormKeys.timePicker,
            context: context,
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
          const CatchFormFieldLabel(label: 'Duration', large: true),
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

  Widget _buildPickerTile({
    required Key key,
    required BuildContext context,
    required IconData icon,
    required String? value,
    required String placeholder,
    required VoidCallback onTap,
  }) {
    final t = CatchTokens.of(context);
    return CatchControlShell(
      key: key,
      onTap: onTap,
      tone: CatchControlTone.raised,
      padding: CatchControlMetrics.contentPadding(CatchControlSize.md),
      semanticButton: true,
      child: Row(
        children: [
          Icon(icon, size: CatchIcon.control, color: t.ink2),
          gapW12,
          Expanded(
            child: Text(
              value ?? placeholder,
              style: value != null
                  ? CatchTextStyles.bodyLead(context)
                  : CatchTextStyles.bodyLead(context, color: t.ink3),
            ),
          ),
          Icon(
            CatchIcons.chevronRightRounded,
            size: CatchIcon.md,
            color: t.ink3,
          ),
        ],
      ),
    );
  }
}
