import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_configuration.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_draft.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_late_join_copy.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Optional timing and delivery limits preserve the rest of the configuration.
class EventAssistanceRuntimeLimits extends StatelessWidget {
  const EventAssistanceRuntimeLimits({
    super.key,
    required this.draft,
    required this.eventEnd,
    required this.enabled,
    required this.onChanged,
    required this.onChooseTime,
  });
  final AssistanceRuntimeDraft draft;
  final int eventEnd;
  final bool enabled;
  final ValueChanged<AssistanceRuntimeDraft> onChanged;
  final ValueChanged<bool> onChooseTime;
  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final policy = draft.deliveryPolicy;
    final states = <WidgetState>{if (!enabled) WidgetState.disabled};
    void change({int? total, int? perRoute, int? gap}) => onChanged(
      draft.withDelivery(
        AssistanceDeliveryPolicy(
          maxAttempts: total ?? policy.maxAttempts,
          maxAttemptsPerRoute: perRoute ?? policy.maxAttemptsPerRoute,
          minimumRetrySeconds: gap ?? policy.minimumRetrySeconds,
        ),
      ),
    );
    return CatchSection.fieldRows(
      children: [
        CatchField.action(
          copy: catchFieldCopy(l),
          title: l.eventAssistanceRuntimeUntil,
          body: lateJoinTimeLabel(context, draft.expiresAt),
          onTap: enabled ? () => onChooseTime(false) : null,
        ),
        if (draft.expiresAt != eventEnd)
          CatchField.action(
            copy: catchFieldCopy(l),
            title: l.eventAssistanceRuntimeUseEventEnd,
            onTap: enabled ? () => onChanged(draft.withExpiry(eventEnd)) : null,
          ),
        CatchField.action(
          copy: catchFieldCopy(l),
          title: l.eventAssistanceRuntimeDeadline,
          body: draft.responseDeadline == null
              ? l.eventAssistanceRuntimeSetDeadline
              : lateJoinTimeLabel(context, draft.responseDeadline!),
          onTap: enabled ? () => onChooseTime(true) : null,
        ),
        if (draft.responseDeadline != null)
          CatchField.action(
            copy: catchFieldCopy(l),
            title: l.eventAssistanceRuntimeNoDeadline,
            onTap: enabled ? () => onChanged(draft.withDeadline(null)) : null,
          ),
        CatchField.content(
          copy: catchFieldCopy(l),
          title: l.eventAssistanceLateJoinUnanswered,
          body: l.eventAssistanceRuntimeDeadlineBody,
        ),
        CatchField.stepper(
          copy: catchFieldCopy(l),
          key: const ValueKey('runtime.attempts'),
          title: l.eventAssistanceRuntimeAttempts,
          body: l.eventAssistanceRuntimeAttemptsBody,
          contract: CatchContractConstraints
              .setEventAssistanceRuntimeConfigCallablePayloadCommandConfigurationOptionsDeliveryPolicyMaxAttempts,
          value: policy.maxAttempts,
          min: 1,
          max: 6,
          states: states,
          decreaseSemanticLabel: l.eventAssistanceLateJoinDecrease,
          increaseSemanticLabel: l.eventAssistanceLateJoinIncrease,
          onChanged: enabled ? (v) => change(total: v.toInt()) : null,
        ),
        CatchField.stepper(
          copy: catchFieldCopy(l),
          key: const ValueKey('runtime.perChannel'),
          title: l.eventAssistanceRuntimePerChannel,
          contract: CatchContractConstraints
              .setEventAssistanceRuntimeConfigCallablePayloadCommandConfigurationOptionsDeliveryPolicyMaxAttemptsPerRoute,
          value: policy.maxAttemptsPerRoute,
          min: 1,
          max: 3,
          states: states,
          decreaseSemanticLabel: l.eventAssistanceLateJoinDecrease,
          increaseSemanticLabel: l.eventAssistanceLateJoinIncrease,
          onChanged: enabled ? (v) => change(perRoute: v.toInt()) : null,
        ),
        CatchField.stepper(
          copy: catchFieldCopy(l),
          key: const ValueKey('runtime.retryGap'),
          title: l.eventAssistanceRuntimeGap,
          body: l.eventAssistanceRuntimeGapBody,
          contract: CatchContractConstraints
              .setEventAssistanceRuntimeConfigCallablePayloadCommandConfigurationOptionsDeliveryPolicyMinimumRetrySeconds,
          value: policy.minimumRetrySeconds,
          min: 1,
          max: 3600,
          states: states,
          decreaseSemanticLabel: l.eventAssistanceLateJoinDecrease,
          increaseSemanticLabel: l.eventAssistanceLateJoinIncrease,
          onChanged: enabled ? (v) => change(gap: v.toInt()) : null,
        ),
      ],
    );
  }
}

Future<int?> chooseRuntimeTime(
  BuildContext context, {
  required int serverTime,
  required int eventEnd,
  required int initial,
}) async {
  if (eventEnd <= serverTime) return null;
  final first = DateTime.fromMillisecondsSinceEpoch(serverTime);
  final last = DateTime.fromMillisecondsSinceEpoch(eventEnd);
  var chosen = DateTime.fromMillisecondsSinceEpoch(
    initial.clamp(serverTime, eventEnd),
  );
  if (!DateUtils.isSameDay(first, last)) {
    final date = await showCatchDatePicker(
      context: context,
      initialDate: chosen,
      firstDate: first,
      lastDate: last,
      copy: catchDatePickerCopy(context.l10n),
    );
    if (!context.mounted || date == null) return null;
    chosen = DateTime(
      date.year,
      date.month,
      date.day,
      chosen.hour,
      chosen.minute,
    );
  }
  final time = await showCatchTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(chosen),
    copy: catchTimePickerCopy(context.l10n),
  );
  if (!context.mounted || time == null) return null;
  return DateTime(
    chosen.year,
    chosen.month,
    chosen.day,
    time.hour,
    time.minute,
  ).millisecondsSinceEpoch;
}
