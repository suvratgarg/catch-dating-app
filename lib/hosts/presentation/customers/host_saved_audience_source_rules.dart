part of 'host_customers_screen.dart';

enum HostAudienceSourceRuleKind {
  applicationStatus,
  formAnswer,
  attendedEvent,
  spend,
}

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
    if (kind == HostAudienceSourceRuleKind.spend) {
      final rule = predicate as HostSavedAudienceSpend;
      return CatchFieldLanes.divided(
        children: [
          CatchField.read(
            title: context.l10n.hostAudienceSpend,
            body: context.l10n.hostAudienceSpendHelp,
          ),
          CatchField.select<HostSavedAudienceAttendanceOperator>(
            title: context.l10n.hostSavedAudienceAttendanceComparison,
            contract: CatchContractConstraints
                .upsertOrganizerSavedAudienceCallablePayloadDefinitionPredicatesItemsOperator,
            contractValue: (value) => value.name,
            values: HostSavedAudienceAttendanceOperator.values,
            itemLabel: (value) =>
                value == HostSavedAudienceAttendanceOperator.atLeast
                ? context.l10n.hostSavedAudienceAtLeast
                : context.l10n.hostSavedAudienceAtMost,
            value: rule.operator,
            enabled: enabled,
            onChanged: (value) {
              if (value != null) onChanged(rule.copyWith(operator: value));
            },
          ),
          CatchField.select<String>(
            key: const ValueKey('host-audience-spend-currency'),
            title: context.l10n.hostAudienceSpendCurrency,
            contract: CatchContractConstraints
                .upsertOrganizerSavedAudienceCallablePayloadDefinitionPredicatesItemsCurrency,
            values: {
              ...supportedCurrencyDefinitions.map((c) => c.code),
              rule.currency,
            }.toList(),
            itemLabel: (value) => value,
            value: rule.currency,
            enabled: enabled,
            onChanged: (value) {
              if (value != null && value != rule.currency) {
                onChanged(rule.copyWith(currency: value, amountMinor: 0));
              }
            },
          ),
          CatchField.input(
            key: ValueKey('host-audience-spend-amount-${rule.currency}'),
            title: context.l10n.hostAudienceSpendAmount,
            contractExemption:
                'The field edits major currency units. Exact integer parsing validates the stored amountMinor range before saving.',
            initialValue: minorCurrencyAmountInputText(
              rule.amountMinor,
              currencyCode: rule.currency,
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            enabled: enabled,
            validator: (text) {
              final amount = parseMajorCurrencyAmountToMinorUnits(
                text ?? '',
                currencyCode: rule.currency,
              );
              return amount == null || amount < 0 || amount > 10000000000
                  ? context.l10n.hostAudienceSpendAmountInvalid
                  : null;
            },
            onChanged: (text) {
              final amount = parseMajorCurrencyAmountToMinorUnits(
                text,
                currencyCode: rule.currency,
              );
              if (amount != null && amount >= 0 && amount <= 10000000000) {
                onChanged(rule.copyWith(amountMinor: amount));
              }
            },
          ),
          CatchField.input(
            key: const ValueKey('host-audience-spend-days'),
            title: context.l10n.hostAudienceSpendDays,
            helperText: context.l10n.hostAudienceSpendDaysHelp,
            contractExemption:
                'Blank means lifetime (null); an entered value must be an integer from 1 to 3650, matching withinDays.',
            initialValue: rule.withinDays?.toString() ?? '',
            keyboardType: TextInputType.number,
            enabled: enabled,
            validator: (text) {
              if ((text ?? '').trim().isEmpty) return null;
              final days = int.tryParse(text!.trim());
              return days == null || days < 1 || days > 3650
                  ? context.l10n.hostAudienceSpendDaysInvalid
                  : null;
            },
            onChanged: (text) {
              final days = int.tryParse(text.trim());
              if (text.trim().isEmpty) {
                onChanged(rule.copyWith(lifetime: true));
              } else if (days != null && days >= 1 && days <= 3650) {
                onChanged(rule.copyWith(withinDays: days));
              }
            },
          ),
        ],
      );
    }
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
