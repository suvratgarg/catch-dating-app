part of 'host_crm_repository.dart';

enum HostSavedAudienceApplicationStatus {
  submitted,
  inReview,
  approved,
  waitlisted,
  declined,
}

final class HostSavedAudienceApplicationStatusRule
    extends HostSavedAudiencePredicate {
  const HostSavedAudienceApplicationStatusRule({
    required this.formId,
    required this.reviewStatus,
  });
  final String formId;
  final HostSavedAudienceApplicationStatus reviewStatus;
  @override
  Map<String, Object?> toJson() => {
    'kind': 'applicationStatus',
    'formId': formId,
    'reviewStatus': reviewStatus.name,
  };
}

final class HostSavedAudienceFormAnswer extends HostSavedAudiencePredicate {
  const HostSavedAudienceFormAnswer({
    required this.formId,
    required this.versionId,
    required this.questionId,
    required this.value,
  });
  final String formId;
  final String versionId;
  final String questionId;
  final Object value;
  @override
  Map<String, Object?> toJson() => {
    'kind': 'formAnswer',
    'formId': formId,
    'versionId': versionId,
    'questionId': questionId,
    'value': value,
  };
}

final class HostSavedAudienceAttendedEvent extends HostSavedAudiencePredicate {
  const HostSavedAudienceAttendedEvent(this.eventId);
  final String eventId;
  @override
  Map<String, Object?> toJson() => {
    'kind': 'attendedEvent',
    'eventId': eventId,
  };
}

class HostAudienceSourceOption {
  const HostAudienceSourceOption({required this.id, required this.title});
  final String id;
  final String title;
}

class HostAudienceAnswerOption {
  const HostAudienceAnswerOption({required this.label, required this.value});
  final String label;
  final Object value;
}

class HostAudienceQuestionOption {
  const HostAudienceQuestionOption({
    required this.formId,
    required this.versionId,
    required this.version,
    required this.formTitle,
    required this.questionId,
    required this.label,
    required this.options,
  });
  final String formId;
  final String versionId;
  final int version;
  final String formTitle;
  final String questionId;
  final String label;
  final List<HostAudienceAnswerOption> options;
}

class HostSavedAudienceFilterOptions {
  const HostSavedAudienceFilterOptions({
    required this.forms,
    required this.questions,
    required this.events,
    required this.tags,
  });
  const HostSavedAudienceFilterOptions.empty()
    : forms = const [],
      questions = const [],
      events = const [],
      tags = const [];

  factory HostSavedAudienceFilterOptions.fromCallableData(Object? data) {
    final root = _requiredMap(data, 'audience source options');
    final map = _requiredMap(root['filterOptions'], 'audience source options');
    return HostSavedAudienceFilterOptions(
      forms: _mapList(map['forms'], 'audience forms')
          .map(
            (item) => HostAudienceSourceOption(
              id: _requiredString(item, 'formId'),
              title: _requiredString(item, 'title'),
            ),
          )
          .toList(growable: false),
      events: _mapList(map['events'], 'audience events')
          .map(
            (item) => HostAudienceSourceOption(
              id: _requiredString(item, 'eventId'),
              title: _requiredString(item, 'title'),
            ),
          )
          .toList(growable: false),
      tags: _mapList(
        map['tags'],
        'audience tags',
      ).map(HostManualTag.fromMap).toList(growable: false),
      questions: _mapList(map['questions'], 'audience questions')
          .map(
            (item) => HostAudienceQuestionOption(
              formId: _requiredString(item, 'formId'),
              versionId: _requiredString(item, 'versionId'),
              version: _requiredInt(item, 'version'),
              formTitle: _requiredString(item, 'formTitle'),
              questionId: _requiredString(item, 'questionId'),
              label: _requiredString(item, 'label'),
              options: _mapList(item['options'], 'answer options')
                  .map(
                    (option) => HostAudienceAnswerOption(
                      label: _requiredString(option, 'label'),
                      value: _audienceAnswerValue(option['value']),
                    ),
                  )
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
    );
  }

  final List<HostAudienceSourceOption> forms;
  final List<HostAudienceQuestionOption> questions;
  final List<HostAudienceSourceOption> events;
  final List<HostManualTag> tags;
}

Object _audienceAnswerValue(Object? value) => switch (value) {
  String() || bool() => value!,
  _ => throw const FormatException('Expected a choice or boolean answer.'),
};

enum HostSavedAudienceMembershipMode { rules, selectedPeople }

final class HostSavedAudienceStaticMembers extends HostSavedAudiencePredicate {
  const HostSavedAudienceStaticMembers(this.contactIds);
  final List<String> contactIds;
  @override
  Map<String, Object?> toJson() => {
    'kind': 'staticMembers',
    'contactIds': contactIds,
  };
}

final class HostSavedAudienceSpend extends HostSavedAudiencePredicate {
  const HostSavedAudienceSpend({
    required this.operator,
    required this.currency,
    required this.amountMinor,
    this.withinDays,
  });
  final HostSavedAudienceAttendanceOperator operator;
  final String currency;
  final int amountMinor;
  final int? withinDays;

  HostSavedAudienceSpend copyWith({
    HostSavedAudienceAttendanceOperator? operator,
    String? currency,
    int? amountMinor,
    int? withinDays,
    bool lifetime = false,
  }) => HostSavedAudienceSpend(
    operator: operator ?? this.operator,
    currency: currency ?? this.currency,
    amountMinor: amountMinor ?? this.amountMinor,
    withinDays: lifetime ? null : withinDays ?? this.withinDays,
  );

  @override
  Map<String, Object?> toJson() => {
    'kind': 'spend',
    'operator': operator.name,
    'currency': currency,
    'amountMinor': amountMinor,
    'withinDays': withinDays,
  };
}

class HostStaticAudienceMember {
  const HostStaticAudienceMember({
    required this.selectedContactId,
    required this.contactId,
    required this.displayName,
    required this.available,
  });
  factory HostStaticAudienceMember.fromMap(Map<Object?, Object?> map) =>
      HostStaticAudienceMember(
        selectedContactId: _requiredString(map, 'selectedContactId'),
        contactId: _nullableString(map['contactId']),
        displayName: _nullableString(map['displayName']),
        available: _requiredBool(map, 'available'),
      );
  final String selectedContactId;
  final String? contactId;
  final String? displayName;
  final bool available;
}
