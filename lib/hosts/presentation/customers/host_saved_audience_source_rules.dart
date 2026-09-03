part of 'host_customers_screen.dart';

enum HostAudienceSourceRuleKind { applicationStatus, formAnswer, attendedEvent }

class HostAudienceSourceRuleFields extends StatelessWidget {
  const HostAudienceSourceRuleFields({
    super.key,
    required this.kind,
    required this.predicate,
    required this.options,
    required this.enabled,
    required this.onChanged,
  });

  final HostAudienceSourceRuleKind kind;
  final HostSavedAudiencePredicate? predicate;
  final HostSavedAudienceFilterOptions options;
  final bool enabled;
  final ValueChanged<HostSavedAudiencePredicate> onChanged;

  @override
  Widget build(BuildContext context) {
    if (kind == HostAudienceSourceRuleKind.attendedEvent) {
      final rule = predicate is HostSavedAudienceAttendedEvent
          ? predicate as HostSavedAudienceAttendedEvent
          : null;
      return CatchField.select<HostAudienceSourceOption>(
        title: context.l10n.hostAudienceRuleNamedEvent,
        contract: CatchContractConstraints
            .upsertOrganizerSavedAudienceCallablePayloadDefinitionPredicatesItemsEventId,
        contractValue: (value) => value.id,
        values: options.events,
        itemLabel: (value) => value.title,
        value: options.events.where((e) => e.id == rule?.eventId).firstOrNull,
        enabled: enabled && options.events.isNotEmpty,
        hintText: context.l10n.hostAudienceChooseEvent,
        onChanged: (value) {
          if (value != null) {
            onChanged(HostSavedAudienceAttendedEvent(value.id));
          }
        },
      );
    }
    if (kind == HostAudienceSourceRuleKind.applicationStatus) {
      final rule = predicate is HostSavedAudienceApplicationStatusRule
          ? predicate as HostSavedAudienceApplicationStatusRule
          : null;
      return Column(
        children: [
          CatchField.select<HostAudienceSourceOption>(
            title: context.l10n.hostAudienceChooseForm,
            contract: CatchContractConstraints
                .upsertOrganizerSavedAudienceCallablePayloadDefinitionPredicatesItemsFormId,
            contractValue: (value) => value.id,
            values: options.forms,
            itemLabel: (value) => value.title,
            value: options.forms.where((f) => f.id == rule?.formId).firstOrNull,
            enabled: enabled && options.forms.isNotEmpty,
            hintText: context.l10n.hostAudienceChooseForm,
            onChanged: (value) {
              if (value != null) {
                onChanged(
                  HostSavedAudienceApplicationStatusRule(
                    formId: value.id,
                    reviewStatus:
                        rule?.reviewStatus ??
                        HostSavedAudienceApplicationStatus.submitted,
                  ),
                );
              }
            },
          ),
          CatchField.select<HostSavedAudienceApplicationStatus>(
            title: context.l10n.hostApplicationsReviewStatusFilter,
            contract: CatchContractConstraints
                .upsertOrganizerSavedAudienceCallablePayloadDefinitionPredicatesItemsReviewStatus,
            contractValue: (value) => value.name,
            values: HostSavedAudienceApplicationStatus.values,
            itemLabel: (value) =>
                _audienceApplicationStatusLabel(context, value),
            value:
                rule?.reviewStatus ??
                HostSavedAudienceApplicationStatus.submitted,
            enabled: enabled && rule != null,
            onChanged: (value) {
              if (value != null && rule != null) {
                onChanged(
                  HostSavedAudienceApplicationStatusRule(
                    formId: rule.formId,
                    reviewStatus: value,
                  ),
                );
              }
            },
          ),
        ],
      );
    }
    final rule = predicate is HostSavedAudienceFormAnswer
        ? predicate as HostSavedAudienceFormAnswer
        : null;
    final question = options.questions
        .where(
          (q) =>
              q.versionId == rule?.versionId &&
              q.questionId == rule?.questionId &&
              q.formId == rule?.formId,
        )
        .firstOrNull;
    return Column(
      children: [
        CatchField.select<HostAudienceQuestionOption>(
          key: const ValueKey('host-saved-audience-source-question'),
          title: context.l10n.hostAudienceChooseQuestion,
          helperText: context.l10n.hostAudienceFilterableQuestionsHelp,
          contract: CatchContractConstraints
              .upsertOrganizerSavedAudienceCallablePayloadDefinitionPredicatesItemsQuestionId,
          contractValue: (value) => value.questionId,
          values: options.questions,
          value: question,
          itemLabel: (value) =>
              '${value.formTitle} · v${value.version} · ${value.label}',
          enabled: enabled && options.questions.isNotEmpty,
          hintText: context.l10n.hostAudienceChooseQuestion,
          onChanged: (value) {
            final answer = value?.options.firstOrNull;
            if (value != null && answer != null) {
              onChanged(
                HostSavedAudienceFormAnswer(
                  formId: value.formId,
                  versionId: value.versionId,
                  questionId: value.questionId,
                  value: answer.value,
                ),
              );
            }
          },
        ),
        if (question != null)
          CatchField.select<HostAudienceAnswerOption>(
            key: const ValueKey('host-saved-audience-source-answer'),
            title: context.l10n.hostAudienceChooseAnswer,
            contractExemption:
                'Values come from the scoped immutable form version; '
                'the callable validates the selected string or boolean again.',
            values: question.options,
            itemLabel: (value) => _audienceAnswerLabel(context, value),
            value: question.options
                .where((o) => o.value == rule?.value)
                .firstOrNull,
            enabled: enabled,
            onChanged: (value) {
              if (value != null) {
                onChanged(
                  HostSavedAudienceFormAnswer(
                    formId: question.formId,
                    versionId: question.versionId,
                    questionId: question.questionId,
                    value: value.value,
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}

String _audienceAnswerLabel(
  BuildContext context,
  HostAudienceAnswerOption option,
) => switch (option.value) {
  true => context.l10n.hostApplicationAnswerYes,
  false => context.l10n.hostApplicationAnswerNo,
  _ => option.label,
};

String _audienceApplicationStatusLabel(
  BuildContext context,
  HostSavedAudienceApplicationStatus status,
) => switch (status) {
  HostSavedAudienceApplicationStatus.submitted =>
    context.l10n.hostApplicationsStatusSubmitted,
  HostSavedAudienceApplicationStatus.inReview =>
    context.l10n.hostApplicationsStatusInReview,
  HostSavedAudienceApplicationStatus.approved =>
    context.l10n.hostApplicationsStatusApproved,
  HostSavedAudienceApplicationStatus.waitlisted =>
    context.l10n.hostApplicationsStatusWaitlisted,
  HostSavedAudienceApplicationStatus.declined =>
    context.l10n.hostApplicationsStatusDeclined,
};
