part of 'host_customers_screen.dart';

enum _AudienceRuleKind {
  computedSegment('computedSegment'),
  manualTag('manualTag'),
  attendanceCount('attendanceCount'),
  lastSeenWithinDays('lastSeenWithinDays'),
  campaignReachable('reachableForIntent'),
  spend('spend'),
  applicationStatus('applicationStatus'),
  formAnswer('formAnswer'),
  attendedEvent('attendedEvent');

  const _AudienceRuleKind(this.wireValue);
  final String wireValue;
}

class _AudienceRuleDraft {
  const _AudienceRuleDraft({
    required this.kind,
    required this.segment,
    required this.manualTagId,
    required this.operator,
    required this.amount,
    this.sourcePredicate,
  });

  factory _AudienceRuleDraft.defaults() => const _AudienceRuleDraft(
    kind: _AudienceRuleKind.computedSegment,
    segment: HostAudienceSegment.regular,
    manualTagId: null,
    operator: HostSavedAudienceAttendanceOperator.atLeast,
    amount: 1,
  );

  factory _AudienceRuleDraft.fromPredicate(
    HostSavedAudiencePredicate predicate,
  ) => switch (predicate) {
    HostSavedAudienceStaticMembers() => throw StateError(
      'Static members do not use the rule editor.',
    ),
    HostSavedAudienceSpend() => _AudienceRuleDraft.defaults().copyWith(
      kind: _AudienceRuleKind.spend,
      sourcePredicate: predicate,
    ),
    HostSavedAudienceApplicationStatusRule() =>
      _AudienceRuleDraft.defaults().copyWith(
        kind: _AudienceRuleKind.applicationStatus,
        sourcePredicate: predicate,
      ),
    HostSavedAudienceFormAnswer() => _AudienceRuleDraft.defaults().copyWith(
      kind: _AudienceRuleKind.formAnswer,
      sourcePredicate: predicate,
    ),
    HostSavedAudienceAttendedEvent() => _AudienceRuleDraft.defaults().copyWith(
      kind: _AudienceRuleKind.attendedEvent,
      sourcePredicate: predicate,
    ),
    HostSavedAudienceComputedSegment(:final segment) => _AudienceRuleDraft(
      kind: _AudienceRuleKind.computedSegment,
      segment: segment,
      manualTagId: null,
      operator: HostSavedAudienceAttendanceOperator.atLeast,
      amount: 1,
    ),
    HostSavedAudienceManualTag(:final manualTagId) => _AudienceRuleDraft(
      kind: _AudienceRuleKind.manualTag,
      segment: HostAudienceSegment.regular,
      manualTagId: manualTagId,
      operator: HostSavedAudienceAttendanceOperator.atLeast,
      amount: 1,
    ),
    HostSavedAudienceAttendanceCount(:final operator, :final eventCount) =>
      _AudienceRuleDraft(
        kind: _AudienceRuleKind.attendanceCount,
        segment: HostAudienceSegment.regular,
        manualTagId: null,
        operator: operator,
        amount: eventCount,
      ),
    HostSavedAudienceLastSeenWithinDays(:final days) => _AudienceRuleDraft(
      kind: _AudienceRuleKind.lastSeenWithinDays,
      segment: HostAudienceSegment.regular,
      manualTagId: null,
      operator: HostSavedAudienceAttendanceOperator.atLeast,
      amount: days,
    ),
    HostSavedAudienceCampaignReachable() => const _AudienceRuleDraft(
      kind: _AudienceRuleKind.campaignReachable,
      segment: HostAudienceSegment.regular,
      manualTagId: null,
      operator: HostSavedAudienceAttendanceOperator.atLeast,
      amount: 1,
    ),
  };

  final _AudienceRuleKind kind;
  final HostAudienceSegment segment;
  final String? manualTagId;
  final HostSavedAudienceAttendanceOperator operator;
  final int amount;
  final HostSavedAudiencePredicate? sourcePredicate;

  _AudienceRuleDraft withKind(
    _AudienceRuleKind next,
    List<HostCustomerManualTag> manualTags,
  ) => copyWith(
    kind: next,
    sourcePredicate:
        next == _AudienceRuleKind.spend &&
            sourcePredicate is! HostSavedAudienceSpend
        ? const HostSavedAudienceSpend(
            operator: HostSavedAudienceAttendanceOperator.atLeast,
            currency: 'INR',
            amountMinor: 100000,
          )
        : sourcePredicate,
    manualTagId: next == _AudienceRuleKind.manualTag
        ? manualTagId ?? manualTags.firstOrNull?.tagId
        : manualTagId,
    amount: next == _AudienceRuleKind.lastSeenWithinDays
        ? amount.clamp(1, 3650)
        : amount,
  );

  _AudienceRuleDraft copyWith({
    _AudienceRuleKind? kind,
    HostAudienceSegment? segment,
    String? manualTagId,
    HostSavedAudienceAttendanceOperator? operator,
    int? amount,
    HostSavedAudiencePredicate? sourcePredicate,
  }) => _AudienceRuleDraft(
    kind: kind ?? this.kind,
    segment: segment ?? this.segment,
    manualTagId: manualTagId ?? this.manualTagId,
    operator: operator ?? this.operator,
    amount: amount ?? this.amount,
    sourcePredicate: sourcePredicate ?? this.sourcePredicate,
  );

  HostSavedAudiencePredicate? toPredicate() => switch (kind) {
    _AudienceRuleKind.spend =>
      sourcePredicate is HostSavedAudienceSpend ? sourcePredicate : null,
    _AudienceRuleKind.applicationStatus =>
      sourcePredicate is HostSavedAudienceApplicationStatusRule
          ? sourcePredicate
          : null,
    _AudienceRuleKind.formAnswer =>
      sourcePredicate is HostSavedAudienceFormAnswer ? sourcePredicate : null,
    _AudienceRuleKind.attendedEvent =>
      sourcePredicate is HostSavedAudienceAttendedEvent
          ? sourcePredicate
          : null,
    _AudienceRuleKind.computedSegment => HostSavedAudienceComputedSegment(
      segment,
    ),
    _AudienceRuleKind.manualTag =>
      manualTagId == null ? null : HostSavedAudienceManualTag(manualTagId!),
    _AudienceRuleKind.attendanceCount => HostSavedAudienceAttendanceCount(
      operator: operator,
      eventCount: amount,
    ),
    _AudienceRuleKind.lastSeenWithinDays => HostSavedAudienceLastSeenWithinDays(
      amount,
    ),
    _AudienceRuleKind.campaignReachable =>
      const HostSavedAudienceCampaignReachable(),
  };
}

String _audienceRuleKindLabel(BuildContext context, _AudienceRuleKind kind) =>
    switch (kind) {
      _AudienceRuleKind.spend => context.l10n.hostAudienceSpend,
      _AudienceRuleKind.applicationStatus =>
        context.l10n.hostAudienceRuleApplication,
      _AudienceRuleKind.formAnswer => context.l10n.hostAudienceRuleFormAnswer,
      _AudienceRuleKind.attendedEvent =>
        context.l10n.hostAudienceRuleNamedEvent,
      _AudienceRuleKind.computedSegment =>
        context.l10n.hostSavedAudienceRuleSegment,
      _AudienceRuleKind.manualTag => context.l10n.hostSavedAudienceRuleTag,
      _AudienceRuleKind.attendanceCount =>
        context.l10n.hostSavedAudienceRuleAttendance,
      _AudienceRuleKind.lastSeenWithinDays =>
        context.l10n.hostSavedAudienceRuleLastSeen,
      _AudienceRuleKind.campaignReachable =>
        context.l10n.hostSavedAudienceRuleManagedReach,
    };
