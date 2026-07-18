import 'package:catch_dating_app/core/business_rules.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_form_keys.dart';
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
          CatchSection.fieldRows(
            first: true,
            children: [
              FormField<String>(
                validator: (_) => dateController.text.isEmpty
                    ? context.l10n.hostsWhenStepVisiblecopyPleaseSelectADate
                    : null,
                builder: (field) => CatchField.nav(
                  key: CreateEventFormKeys.datePicker,
                  title: context.l10n.hostsWhenStepLabelDate,
                  body: dateController.text.isEmpty
                      ? context.l10n.hostsWhenStepPlaceholderSelectADate
                      : dateController.text,
                  icon: CatchIcons.calendarTodayOutlined,
                  error: field.errorText,
                  onTap: onPickDate,
                ),
              ),
              FormField<String>(
                validator: (_) => startTimeController.text.isEmpty
                    ? context.l10n.hostsWhenStepVisiblecopyRequired
                    : null,
                builder: (field) => CatchField.nav(
                  key: CreateEventFormKeys.timePicker,
                  title: context.l10n.hostsWhenStepLabelStartTime,
                  body: startTimeController.text.isEmpty
                      ? context.l10n.hostsWhenStepPlaceholderSelectStartTime
                      : startTimeController.text,
                  icon: CatchIcons.scheduleOutlined,
                  error: field.errorText ?? scheduleErrorText,
                  onTap: onPickTime,
                ),
              ),
              CatchField.stepper(
                title: context.l10n.hostsWhenStepLabelDuration,
                body: formatDuration(durationMinutes),
                value: durationMinutes,
                min: CatchBusinessRules.eventMinDurationMinutes,
                max: CatchBusinessRules.eventMaxDurationMinutes,
                step: CatchBusinessRules.eventDurationStepMinutes,
                formatter: (value) => formatDuration(value.round()),
                decreaseSemanticLabel:
                    context.l10n.hostsWhenStepVisiblecopyDecreaseDuration,
                increaseSemanticLabel:
                    context.l10n.hostsWhenStepVisiblecopyIncreaseDuration,
                onChanged: (value) {
                  if (value < durationMinutes) {
                    onDecreaseDuration?.call();
                  } else if (value > durationMinutes) {
                    onIncreaseDuration?.call();
                  }
                },
                icon: CatchIcons.timerOutlined,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
