import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_form_field_label.dart';
import 'package:catch_dating_app/core/widgets/catch_number_stepper.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_picker_tile.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
    return Form(
      key: formKey,
      autovalidateMode: autovalidateMode,
      child: ListView(
        padding: CatchInsets.formStepBody,
        children: [
          CatchFormFieldLabel(
            label: context.l10n.hostsWhenStepLabelDate,
            large: true,
          ),
          gapH8,
          HostPickerTile(
            key: CreateEventFormKeys.datePicker,
            icon: CatchIcons.calendarTodayOutlined,
            value: dateController.text.isEmpty ? null : dateController.text,
            placeholder: context.l10n.hostsWhenStepPlaceholderSelectADate,
            onTap: onPickDate,
          ),
          FormField<String>(
            validator: (_) => dateController.text.isEmpty
                ? context.l10n.hostsWhenStepVisiblecopyPleaseSelectADate
                : null,
            builder: (field) => field.hasError
                ? WhenStepFieldError(text: field.errorText!)
                : const SizedBox.shrink(),
          ),
          gapH20,
          CatchFormFieldLabel(
            label: context.l10n.hostsWhenStepLabelStartTime,
            large: true,
          ),
          gapH8,
          HostPickerTile(
            key: CreateEventFormKeys.timePicker,
            icon: CatchIcons.scheduleOutlined,
            value: startTimeController.text.isEmpty
                ? null
                : startTimeController.text,
            placeholder: context.l10n.hostsWhenStepPlaceholderSelectStartTime,
            onTap: onPickTime,
          ),
          FormField<String>(
            validator: (_) => startTimeController.text.isEmpty
                ? context.l10n.hostsWhenStepVisiblecopyRequired
                : null,
            builder: (field) => field.hasError
                ? WhenStepFieldError(text: field.errorText!)
                : const SizedBox.shrink(),
          ),
          if (scheduleErrorText != null)
            WhenStepFieldError(text: scheduleErrorText!),
          gapH20,
          CatchFormFieldLabel(
            label: context.l10n.hostsWhenStepLabelDuration,
            large: true,
          ),
          gapH8,
          CatchNumberStepper(
            value: durationMinutes,
            onDecrease: onDecreaseDuration,
            onIncrease: onIncreaseDuration,
            decreaseTooltip:
                context.l10n.hostsWhenStepVisiblecopyDecreaseDuration,
            increaseTooltip:
                context.l10n.hostsWhenStepVisiblecopyIncreaseDuration,
            formatValue: (value) => formatDuration(value.round()),
          ),
        ],
      ),
    );
  }
}

class WhenStepFieldError extends StatelessWidget {
  const WhenStepFieldError({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: CatchInsets.formFieldError,
      child: Text(
        text,
        style: CatchTextStyles.supporting(context, color: t.primary),
      ),
    );
  }
}
