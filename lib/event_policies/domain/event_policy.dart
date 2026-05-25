import 'dart:math' as math;

import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

/// IN DEVELOPMENT: parallel event policy engine.
///
/// This domain layer owns the production policy snapshot shape while the
/// migration from legacy EventConstraints/priceInPaise/capacityLimit is in
/// progress. Keep backward-compatible fallbacks until older event documents are
/// migrated.
const eventPolicyEngineDevelopmentStatus =
    'production_migration_policy_snapshot_v1';

enum EventAdmissionFormat {
  open,
  inviteOnly,
  manualApproval,
  fixedCohortCaps,
  balancedRatio,
  membersOnly,
}

enum EventWaitlistMode {
  disabled,
  rankedOffer,
  broadcastFirstComeFirstServed,
  manualReview,
}

enum EventOutOfRatioCohortPolicy {
  admitWithinGeneralCapacity,
  waitlist,
  manualReview,
  reject,
}

enum EventPrivateAccessMode { none, inviteCode }

enum EventAdmissionDecisionType {
  admitted,
  waitlisted,
  manualReviewRequired,
  inviteRequired,
  membershipRequired,
  soldOut,
  cohortUnavailable,
}

enum EventAdmissionDecisionReason {
  capacityAvailable,
  capacityFull,
  inviteRequired,
  membershipRequired,
  manualApprovalRequired,
  cohortCapReached,
  balancedRatioLimitReached,
  outOfRatioCohortRequiresReview,
  outOfRatioCohortWaitlisted,
  outOfRatioCohortRejected,
}

class EventCohortIds {
  const EventCohortIds._();

  static const menInterestedInWomen = 'menInterestedInWomen';
  static const womenInterestedInMen = 'womenInterestedInMen';
  static const queerOrOpen = 'queerOrOpen';
  static const nonBinaryOrOther = 'nonBinaryOrOther';
}

class EventCohort {
  const EventCohort({required this.id, required this.label});

  static const menInterestedInWomen = EventCohort(
    id: EventCohortIds.menInterestedInWomen,
    label: 'Men interested in women',
  );
  static const womenInterestedInMen = EventCohort(
    id: EventCohortIds.womenInterestedInMen,
    label: 'Women interested in men',
  );
  static const queerOrOpen = EventCohort(
    id: EventCohortIds.queerOrOpen,
    label: 'Queer or open',
  );
  static const nonBinaryOrOther = EventCohort(
    id: EventCohortIds.nonBinaryOrOther,
    label: 'Non-binary or other',
  );

  final String id;
  final String label;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventCohort && other.id == id && other.label == label;

  @override
  int get hashCode => Object.hash(id, label);

  @override
  String toString() => 'EventCohort(id: $id, label: $label)';
}

class EventAttendeeProfile {
  const EventAttendeeProfile({
    required this.uid,
    required this.gender,
    required this.interestedInGenders,
  });

  factory EventAttendeeProfile.fromUserProfile(UserProfile profile) =>
      EventAttendeeProfile(
        uid: profile.uid,
        gender: profile.gender,
        interestedInGenders: profile.interestedInGenders.toSet(),
      );

  final String uid;
  final Gender gender;
  final Set<Gender> interestedInGenders;
}

class EventCohortResolver {
  const EventCohortResolver();

  EventCohort resolve(EventAttendeeProfile attendee) {
    return switch (attendee.gender) {
      Gender.man when _isOnlyInterestedIn(attendee, Gender.woman) =>
        EventCohort.menInterestedInWomen,
      Gender.woman when _isOnlyInterestedIn(attendee, Gender.man) =>
        EventCohort.womenInterestedInMen,
      Gender.nonBinary || Gender.other => EventCohort.nonBinaryOrOther,
      _ => EventCohort.queerOrOpen,
    };
  }

  bool _isOnlyInterestedIn(EventAttendeeProfile attendee, Gender gender) {
    return attendee.interestedInGenders.length == 1 &&
        attendee.interestedInGenders.contains(gender);
  }
}

class EventRosterSnapshot {
  const EventRosterSnapshot({
    this.bookedCountsByCohort = const {},
    this.waitlistedCountsByCohort = const {},
    this.offeredCountsByCohort = const {},
  });

  final Map<String, int> bookedCountsByCohort;
  final Map<String, int> waitlistedCountsByCohort;
  final Map<String, int> offeredCountsByCohort;

  int bookedCountFor(String cohortId) => bookedCountsByCohort[cohortId] ?? 0;

  int waitlistedCountFor(String cohortId) =>
      waitlistedCountsByCohort[cohortId] ?? 0;

  int offeredCountFor(String cohortId) => offeredCountsByCohort[cohortId] ?? 0;

  int interestCountFor(String cohortId) =>
      bookedCountFor(cohortId) +
      waitlistedCountFor(cohortId) +
      offeredCountFor(cohortId);

  int get totalBooked => _sum(bookedCountsByCohort);
  int get totalWaitlisted => _sum(waitlistedCountsByCohort);
  int get totalOffered => _sum(offeredCountsByCohort);

  static int _sum(Map<String, int> values) =>
      values.values.fold(0, (total, value) => total + math.max(0, value));
}

class EventWaitlistPolicy {
  const EventWaitlistPolicy({
    this.mode = EventWaitlistMode.disabled,
    this.offerWindow = const Duration(minutes: 20),
  });

  const EventWaitlistPolicy.disabled()
    : mode = EventWaitlistMode.disabled,
      offerWindow = Duration.zero;

  const EventWaitlistPolicy.rankedOffer({
    this.offerWindow = const Duration(minutes: 20),
  }) : mode = EventWaitlistMode.rankedOffer;

  final EventWaitlistMode mode;
  final Duration offerWindow;

  bool get isEnabled => mode != EventWaitlistMode.disabled;

  factory EventWaitlistPolicy.fromJson(Map<String, dynamic> json) {
    return EventWaitlistPolicy(
      mode: _enumFromName(
        EventWaitlistMode.values,
        json['mode'],
        EventWaitlistMode.disabled,
      ),
      offerWindow: Duration(
        minutes: _intValue(json['offerWindowMinutes'], fallback: 20),
      ),
    );
  }

  Map<String, Object?> toJson() => {
    'mode': mode.name,
    'offerWindowMinutes': offerWindow.inMinutes,
  };
}

class EventPrivateAccessPolicy {
  const EventPrivateAccessPolicy({
    this.mode = EventPrivateAccessMode.none,
    this.inviteCodeHint,
    this.privateLinkEnabled = false,
  });

  const EventPrivateAccessPolicy.none()
    : mode = EventPrivateAccessMode.none,
      inviteCodeHint = null,
      privateLinkEnabled = false;

  const EventPrivateAccessPolicy.inviteCode({
    this.inviteCodeHint,
    this.privateLinkEnabled = true,
  }) : mode = EventPrivateAccessMode.inviteCode;

  final EventPrivateAccessMode mode;
  final String? inviteCodeHint;
  final bool privateLinkEnabled;

  bool get requiresInviteCode => mode == EventPrivateAccessMode.inviteCode;

  factory EventPrivateAccessPolicy.fromJson(Map<String, dynamic> json) {
    return EventPrivateAccessPolicy(
      mode: _enumFromName(
        EventPrivateAccessMode.values,
        json['mode'],
        EventPrivateAccessMode.none,
      ),
      inviteCodeHint: _stringValue(json['inviteCodeHint']),
      privateLinkEnabled: _boolValue(json['privateLinkEnabled']),
    );
  }

  Map<String, Object?> toJson() => {
    'mode': mode.name,
    'inviteCodeHint': inviteCodeHint,
    'privateLinkEnabled': privateLinkEnabled,
  };
}

class BalancedRatioPolicy {
  const BalancedRatioPolicy({
    required this.leftCohortId,
    required this.rightCohortId,
    this.maxSkew = 1,
    this.openingBufferPerCohort = 1,
    this.outOfRatioCohortPolicy = EventOutOfRatioCohortPolicy.manualReview,
  });

  final String leftCohortId;
  final String rightCohortId;
  final int maxSkew;
  final int openingBufferPerCohort;
  final EventOutOfRatioCohortPolicy outOfRatioCohortPolicy;

  bool appliesTo(String cohortId) =>
      cohortId == leftCohortId || cohortId == rightCohortId;

  String? counterpartFor(String cohortId) {
    if (cohortId == leftCohortId) return rightCohortId;
    if (cohortId == rightCohortId) return leftCohortId;
    return null;
  }

  bool allowsAdmission({
    required String cohortId,
    required EventRosterSnapshot roster,
  }) {
    final counterpartId = counterpartFor(cohortId);
    if (counterpartId == null) return false;

    final currentCount = roster.bookedCountFor(cohortId);
    final counterpartCount = roster.bookedCountFor(counterpartId);
    final nextCount = currentCount + 1;

    if (counterpartCount == 0 && currentCount < openingBufferPerCohort) {
      return true;
    }

    return nextCount <= counterpartCount + maxSkew;
  }

  factory BalancedRatioPolicy.fromJson(Map<String, dynamic> json) {
    return BalancedRatioPolicy(
      leftCohortId:
          _stringValue(json['leftCohortId']) ??
          EventCohortIds.menInterestedInWomen,
      rightCohortId:
          _stringValue(json['rightCohortId']) ??
          EventCohortIds.womenInterestedInMen,
      maxSkew: _intValue(json['maxSkew'], fallback: 1),
      openingBufferPerCohort: _intValue(
        json['openingBufferPerCohort'],
        fallback: 1,
      ),
      outOfRatioCohortPolicy: _enumFromName(
        EventOutOfRatioCohortPolicy.values,
        json['outOfRatioCohortPolicy'],
        EventOutOfRatioCohortPolicy.manualReview,
      ),
    );
  }

  Map<String, Object?> toJson() => {
    'leftCohortId': leftCohortId,
    'rightCohortId': rightCohortId,
    'maxSkew': maxSkew,
    'openingBufferPerCohort': openingBufferPerCohort,
    'outOfRatioCohortPolicy': outOfRatioCohortPolicy.name,
  };
}

class EventAdmissionPolicy {
  const EventAdmissionPolicy({
    required this.format,
    required this.capacityLimit,
    this.waitlistPolicy = const EventWaitlistPolicy.disabled(),
    this.inviteRequired = false,
    this.membershipRequired = false,
    this.manualApprovalRequired = false,
    this.privateAccessPolicy = const EventPrivateAccessPolicy.none(),
    this.cohortCapacityLimits = const {},
    this.balancedRatioPolicy,
  });

  const EventAdmissionPolicy.open({
    required int capacityLimit,
    EventWaitlistPolicy waitlistPolicy = const EventWaitlistPolicy.disabled(),
  }) : this(
         format: EventAdmissionFormat.open,
         capacityLimit: capacityLimit,
         waitlistPolicy: waitlistPolicy,
       );

  const EventAdmissionPolicy.inviteOnly({
    required int capacityLimit,
    EventWaitlistPolicy waitlistPolicy = const EventWaitlistPolicy.disabled(),
    EventPrivateAccessPolicy privateAccessPolicy =
        const EventPrivateAccessPolicy.inviteCode(),
  }) : this(
         format: EventAdmissionFormat.inviteOnly,
         capacityLimit: capacityLimit,
         inviteRequired: true,
         waitlistPolicy: waitlistPolicy,
         privateAccessPolicy: privateAccessPolicy,
       );

  const EventAdmissionPolicy.manualApproval({
    required int capacityLimit,
    EventWaitlistPolicy waitlistPolicy = const EventWaitlistPolicy.disabled(),
  }) : this(
         format: EventAdmissionFormat.manualApproval,
         capacityLimit: capacityLimit,
         manualApprovalRequired: true,
         waitlistPolicy: waitlistPolicy,
       );

  const EventAdmissionPolicy.membersOnly({
    required int capacityLimit,
    EventWaitlistPolicy waitlistPolicy = const EventWaitlistPolicy.disabled(),
  }) : this(
         format: EventAdmissionFormat.membersOnly,
         capacityLimit: capacityLimit,
         membershipRequired: true,
         waitlistPolicy: waitlistPolicy,
       );

  const EventAdmissionPolicy.fixedCohortCaps({
    required int capacityLimit,
    required Map<String, int> cohortCapacityLimits,
    EventWaitlistPolicy waitlistPolicy = const EventWaitlistPolicy.disabled(),
  }) : this(
         format: EventAdmissionFormat.fixedCohortCaps,
         capacityLimit: capacityLimit,
         cohortCapacityLimits: cohortCapacityLimits,
         waitlistPolicy: waitlistPolicy,
       );

  const EventAdmissionPolicy.balancedRatio({
    required int capacityLimit,
    required BalancedRatioPolicy balancedRatioPolicy,
    EventWaitlistPolicy waitlistPolicy = const EventWaitlistPolicy.disabled(),
  }) : this(
         format: EventAdmissionFormat.balancedRatio,
         capacityLimit: capacityLimit,
         balancedRatioPolicy: balancedRatioPolicy,
         waitlistPolicy: waitlistPolicy,
       );

  final EventAdmissionFormat format;
  final int capacityLimit;
  final EventWaitlistPolicy waitlistPolicy;
  final bool inviteRequired;
  final bool membershipRequired;
  final bool manualApprovalRequired;
  final EventPrivateAccessPolicy privateAccessPolicy;
  final Map<String, int> cohortCapacityLimits;
  final BalancedRatioPolicy? balancedRatioPolicy;

  factory EventAdmissionPolicy.fromJson(Map<String, dynamic> json) {
    return EventAdmissionPolicy(
      format: _enumFromName(
        EventAdmissionFormat.values,
        json['format'],
        EventAdmissionFormat.open,
      ),
      capacityLimit: _intValue(json['capacityLimit'], fallback: 1),
      waitlistPolicy: _mapValue(json['waitlistPolicy']) == null
          ? const EventWaitlistPolicy.disabled()
          : EventWaitlistPolicy.fromJson(_mapValue(json['waitlistPolicy'])!),
      inviteRequired: _boolValue(json['inviteRequired']),
      membershipRequired: _boolValue(json['membershipRequired']),
      manualApprovalRequired: _boolValue(json['manualApprovalRequired']),
      privateAccessPolicy: _mapValue(json['privateAccessPolicy']) == null
          ? const EventPrivateAccessPolicy.none()
          : EventPrivateAccessPolicy.fromJson(
              _mapValue(json['privateAccessPolicy'])!,
            ),
      cohortCapacityLimits: _intMap(json['cohortCapacityLimits']),
      balancedRatioPolicy: _mapValue(json['balancedRatioPolicy']) == null
          ? null
          : BalancedRatioPolicy.fromJson(
              _mapValue(json['balancedRatioPolicy'])!,
            ),
    );
  }

  Map<String, Object?> toJson() => {
    'format': format.name,
    'capacityLimit': capacityLimit,
    'waitlistPolicy': waitlistPolicy.toJson(),
    'inviteRequired': inviteRequired,
    'membershipRequired': membershipRequired,
    'manualApprovalRequired': manualApprovalRequired,
    'privateAccessPolicy': privateAccessPolicy.toJson(),
    'cohortCapacityLimits': cohortCapacityLimits,
    'balancedRatioPolicy': balancedRatioPolicy?.toJson(),
  };
}

class MoneyAmount {
  const MoneyAmount.inPaise(this.inPaise);

  final int inPaise;

  MoneyAmount plus(MoneyAmount other) =>
      MoneyAmount.inPaise(math.max(0, inPaise + other.inPaise));

  MoneyAmount percent(int percent) {
    return MoneyAmount.inPaise((inPaise * percent / 100).round());
  }

  MoneyAmount clamp({MoneyAmount? max}) {
    final maxValue = max?.inPaise;
    return MoneyAmount.inPaise(
      maxValue == null ? math.max(0, inPaise) : inPaise.clamp(0, maxValue),
    );
  }

  bool get isFree => inPaise == 0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoneyAmount && other.inPaise == inPaise;

  @override
  int get hashCode => inPaise.hashCode;

  @override
  String toString() => 'MoneyAmount.inPaise($inPaise)';
}

class EventDemandPricingRule {
  const EventDemandPricingRule({
    required this.pricedCohortId,
    required this.balancingCohortId,
    required this.stepAdjustment,
    required this.maxAdjustment,
    this.freeSkew = 1,
    this.demandStep = 1,
  });

  final String pricedCohortId;
  final String balancingCohortId;
  final MoneyAmount stepAdjustment;
  final MoneyAmount maxAdjustment;
  final int freeSkew;
  final int demandStep;

  MoneyAmount adjustmentFor({
    required String cohortId,
    required EventRosterSnapshot roster,
    bool includeRequestedAttendee = true,
  }) {
    if (cohortId != pricedCohortId) return const MoneyAmount.inPaise(0);

    final pricedDemand =
        roster.interestCountFor(pricedCohortId) +
        (includeRequestedAttendee ? 1 : 0);
    final balancingDemand = roster.interestCountFor(balancingCohortId);
    final excessDemand = pricedDemand - balancingDemand - freeSkew;
    if (excessDemand <= 0) return const MoneyAmount.inPaise(0);

    final steps = (excessDemand / math.max(1, demandStep)).ceil();
    return MoneyAmount.inPaise(
      math.min(maxAdjustment.inPaise, stepAdjustment.inPaise * steps),
    );
  }

  factory EventDemandPricingRule.fromJson(Map<String, dynamic> json) {
    return EventDemandPricingRule(
      pricedCohortId:
          _stringValue(json['pricedCohortId']) ??
          EventCohortIds.menInterestedInWomen,
      balancingCohortId:
          _stringValue(json['balancingCohortId']) ??
          EventCohortIds.womenInterestedInMen,
      stepAdjustment: MoneyAmount.inPaise(
        _intValue(json['stepAdjustmentInPaise'], fallback: 0),
      ),
      maxAdjustment: MoneyAmount.inPaise(
        _intValue(json['maxAdjustmentInPaise'], fallback: 0),
      ),
      freeSkew: _intValue(json['freeSkew'], fallback: 1),
      demandStep: _intValue(json['demandStep'], fallback: 1),
    );
  }

  Map<String, Object?> toJson() => {
    'pricedCohortId': pricedCohortId,
    'balancingCohortId': balancingCohortId,
    'stepAdjustmentInPaise': stepAdjustment.inPaise,
    'maxAdjustmentInPaise': maxAdjustment.inPaise,
    'freeSkew': freeSkew,
    'demandStep': demandStep,
  };
}

class EventPricingPolicy {
  const EventPricingPolicy({
    required this.basePrice,
    this.cohortAdjustments = const {},
    this.demandPricingRules = const [],
  });

  const EventPricingPolicy.fixed(MoneyAmount basePrice)
    : this(basePrice: basePrice);

  final MoneyAmount basePrice;
  final Map<String, MoneyAmount> cohortAdjustments;
  final List<EventDemandPricingRule> demandPricingRules;

  EventPriceQuote quoteFor({
    required EventCohort cohort,
    required EventRosterSnapshot roster,
  }) {
    final cohortAdjustment =
        cohortAdjustments[cohort.id] ?? const MoneyAmount.inPaise(0);
    final demandAdjustment = demandPricingRules.fold(
      const MoneyAmount.inPaise(0),
      (total, rule) =>
          total.plus(rule.adjustmentFor(cohortId: cohort.id, roster: roster)),
    );
    final finalAmount = basePrice.plus(cohortAdjustment).plus(demandAdjustment);

    return EventPriceQuote(
      basePrice: basePrice,
      cohort: cohort,
      cohortAdjustment: cohortAdjustment,
      demandAdjustment: demandAdjustment,
      finalAmount: finalAmount,
    );
  }

  bool get hasDemandPricing => demandPricingRules.isNotEmpty;

  factory EventPricingPolicy.fromJson(Map<String, dynamic> json) {
    return EventPricingPolicy(
      basePrice: MoneyAmount.inPaise(
        _intValue(json['basePriceInPaise'], fallback: 0),
      ),
      cohortAdjustments: _intMap(
        json['cohortAdjustmentsInPaise'],
      ).map((key, value) => MapEntry(key, MoneyAmount.inPaise(value))),
      demandPricingRules: _listValue(json['demandPricingRules'])
          .map(_mapValue)
          .whereType<Map<String, dynamic>>()
          .map(EventDemandPricingRule.fromJson)
          .toList(growable: false),
    );
  }

  Map<String, Object?> toJson() => {
    'basePriceInPaise': basePrice.inPaise,
    'cohortAdjustmentsInPaise': cohortAdjustments.map(
      (key, value) => MapEntry(key, value.inPaise),
    ),
    'demandPricingRules': demandPricingRules
        .map((rule) => rule.toJson())
        .toList(growable: false),
  };
}

class EventPriceQuote {
  const EventPriceQuote({
    required this.basePrice,
    required this.cohort,
    required this.cohortAdjustment,
    required this.demandAdjustment,
    required this.finalAmount,
  });

  final MoneyAmount basePrice;
  final EventCohort cohort;
  final MoneyAmount cohortAdjustment;
  final MoneyAmount demandAdjustment;
  final MoneyAmount finalAmount;

  bool get isFree => finalAmount.isFree;
}

enum EventCancellationPolicyId { flexible, standard, strict }

enum EventCancellationActor { attendee, host, platform }

enum EventCancellationRemedy {
  fullRefund,
  platformCredit,
  noRefund,
  waitlistRelease,
  platformMakesAttendeeComplete,
}

enum EventHostPayoutTiming { afterEventCompletion }

class EventCancellationPolicy {
  const EventCancellationPolicy({
    required this.id,
    required this.title,
    required this.attendeeSummary,
    required this.hostCancellationSummary,
    required this.fullRefundUntilBeforeStart,
    required this.creditUntilBeforeStart,
    required this.lateCreditPercent,
  });

  const EventCancellationPolicy.flexible()
    : this(
        id: EventCancellationPolicyId.flexible,
        title: 'Flexible',
        attendeeSummary:
            'Full refund until 6 hours before start; platform credit until 1 hour before start.',
        hostCancellationSummary:
            'If the host cancels, attendees are fully refunded and the host is not paid.',
        fullRefundUntilBeforeStart: const Duration(hours: 6),
        creditUntilBeforeStart: const Duration(hours: 1),
        lateCreditPercent: 100,
      );

  const EventCancellationPolicy.standard()
    : this(
        id: EventCancellationPolicyId.standard,
        title: 'Standard',
        attendeeSummary:
            'Full refund until 24 hours before start; 50% platform credit until 6 hours before start.',
        hostCancellationSummary:
            'If the host cancels, attendees are fully refunded and the host is not paid.',
        fullRefundUntilBeforeStart: const Duration(hours: 24),
        creditUntilBeforeStart: const Duration(hours: 6),
        lateCreditPercent: 50,
      );

  const EventCancellationPolicy.strict()
    : this(
        id: EventCancellationPolicyId.strict,
        title: 'Strict',
        attendeeSummary:
            'Full refund until 72 hours before start; 50% platform credit until 24 hours before start.',
        hostCancellationSummary:
            'If the host cancels, attendees are fully refunded and the host is not paid.',
        fullRefundUntilBeforeStart: const Duration(hours: 72),
        creditUntilBeforeStart: const Duration(hours: 24),
        lateCreditPercent: 50,
      );

  final EventCancellationPolicyId id;
  final String title;
  final String attendeeSummary;
  final String hostCancellationSummary;
  final Duration fullRefundUntilBeforeStart;
  final Duration creditUntilBeforeStart;
  final int lateCreditPercent;

  factory EventCancellationPolicy.fromJson(Map<String, dynamic> json) {
    final id = _enumFromName(
      EventCancellationPolicyId.values,
      json['policyId'] ?? json['id'],
      EventCancellationPolicyId.standard,
    );
    return switch (id) {
      EventCancellationPolicyId.flexible =>
        const EventCancellationPolicy.flexible(),
      EventCancellationPolicyId.standard =>
        const EventCancellationPolicy.standard(),
      EventCancellationPolicyId.strict =>
        const EventCancellationPolicy.strict(),
    };
  }

  Map<String, Object?> toJson() => {'policyId': id.name};

  EventCancellationQuote quoteFor(EventCancellationRequest request) {
    if (request.isWaitlisted) {
      return EventCancellationQuote(
        policyId: id,
        actor: request.actor,
        remedy: EventCancellationRemedy.waitlistRelease,
        refundAmount: const MoneyAmount.inPaise(0),
        creditAmount: const MoneyAmount.inPaise(0),
        userLabel: 'Free waitlist removal',
        explanation: 'Waitlisted attendees have not paid and can leave freely.',
      );
    }

    if (request.actor == EventCancellationActor.host ||
        request.actor == EventCancellationActor.platform) {
      return EventCancellationQuote(
        policyId: id,
        actor: request.actor,
        remedy: EventCancellationRemedy.platformMakesAttendeeComplete,
        refundAmount: request.paidAmount,
        creditAmount: const MoneyAmount.inPaise(0),
        userLabel: 'Made complete',
        explanation:
            'Host or platform cancellation overrides host policy; the attendee gets a full refund before any host payout.',
      );
    }

    if (request.paidAmount.isFree) {
      return EventCancellationQuote(
        policyId: id,
        actor: request.actor,
        remedy: EventCancellationRemedy.fullRefund,
        refundAmount: request.paidAmount,
        creditAmount: const MoneyAmount.inPaise(0),
        userLabel: 'Free cancellation',
        explanation: 'No payment was collected for this event.',
      );
    }

    if (request.beforeStart >= fullRefundUntilBeforeStart) {
      return EventCancellationQuote(
        policyId: id,
        actor: request.actor,
        remedy: EventCancellationRemedy.fullRefund,
        refundAmount: request.paidAmount,
        creditAmount: const MoneyAmount.inPaise(0),
        userLabel: 'Full refund',
        explanation:
            'The attendee cancelled before the full-refund cutoff for this policy.',
      );
    }

    if (request.beforeStart >= creditUntilBeforeStart &&
        lateCreditPercent > 0) {
      final credit = request.paidAmount.percent(lateCreditPercent);
      return EventCancellationQuote(
        policyId: id,
        actor: request.actor,
        remedy: EventCancellationRemedy.platformCredit,
        refundAmount: const MoneyAmount.inPaise(0),
        creditAmount: credit,
        userLabel: '$lateCreditPercent% credit',
        explanation:
            'The cash refund window has closed, but this policy still returns platform credit.',
      );
    }

    return EventCancellationQuote(
      policyId: id,
      actor: request.actor,
      remedy: EventCancellationRemedy.noRefund,
      refundAmount: const MoneyAmount.inPaise(0),
      creditAmount: const MoneyAmount.inPaise(0),
      userLabel: 'No refund',
      explanation:
          'The attendee cancelled after the final cancellation window for this policy.',
    );
  }
}

class EventCancellationRequest {
  const EventCancellationRequest({
    required this.actor,
    required this.paidAmount,
    required this.beforeStart,
    this.isWaitlisted = false,
  });

  final EventCancellationActor actor;
  final MoneyAmount paidAmount;
  final Duration beforeStart;
  final bool isWaitlisted;
}

class EventCancellationQuote {
  const EventCancellationQuote({
    required this.policyId,
    required this.actor,
    required this.remedy,
    required this.refundAmount,
    required this.creditAmount,
    required this.userLabel,
    required this.explanation,
  });

  final EventCancellationPolicyId policyId;
  final EventCancellationActor actor;
  final EventCancellationRemedy remedy;
  final MoneyAmount refundAmount;
  final MoneyAmount creditAmount;
  final String userLabel;
  final String explanation;
}

class EventSettlementPolicy {
  const EventSettlementPolicy.afterEventCompletion()
    : hostPayoutTiming = EventHostPayoutTiming.afterEventCompletion;

  final EventHostPayoutTiming hostPayoutTiming;

  factory EventSettlementPolicy.fromJson(Map<String, dynamic> json) {
    final timing = _enumFromName(
      EventHostPayoutTiming.values,
      json['hostPayoutTiming'],
      EventHostPayoutTiming.afterEventCompletion,
    );
    return switch (timing) {
      EventHostPayoutTiming.afterEventCompletion =>
        const EventSettlementPolicy.afterEventCompletion(),
    };
  }

  Map<String, Object?> toJson() => {'hostPayoutTiming': hostPayoutTiming.name};

  String get title {
    return switch (hostPayoutTiming) {
      EventHostPayoutTiming.afterEventCompletion => 'After event completion',
    };
  }

  String get summary {
    return switch (hostPayoutTiming) {
      EventHostPayoutTiming.afterEventCompletion =>
        'Platform holds attendee payments until the event is completed, so host cancellations can be refunded without clawbacks.',
    };
  }
}

class EventPolicyBundle {
  const EventPolicyBundle({
    required this.admissionPolicy,
    required this.pricingPolicy,
    this.cancellationPolicy = const EventCancellationPolicy.standard(),
    this.settlementPolicy = const EventSettlementPolicy.afterEventCompletion(),
    this.cohortResolver = const EventCohortResolver(),
  });

  final EventAdmissionPolicy admissionPolicy;
  final EventPricingPolicy pricingPolicy;
  final EventCancellationPolicy cancellationPolicy;
  final EventSettlementPolicy settlementPolicy;
  final EventCohortResolver cohortResolver;

  static const version = 1;

  factory EventPolicyBundle.openEvent({
    required int capacityLimit,
    required int basePriceInPaise,
    EventCancellationPolicy cancellationPolicy =
        const EventCancellationPolicy.standard(),
  }) {
    return EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.open(
        capacityLimit: capacityLimit,
        waitlistPolicy: const EventWaitlistPolicy.rankedOffer(),
      ),
      pricingPolicy: EventPricingPolicy.fixed(
        MoneyAmount.inPaise(basePriceInPaise),
      ),
      cancellationPolicy: cancellationPolicy,
    );
  }

  factory EventPolicyBundle.inviteOnlyEvent({
    required int capacityLimit,
    required int basePriceInPaise,
    String? inviteCodeHint,
    EventCancellationPolicy cancellationPolicy =
        const EventCancellationPolicy.standard(),
  }) {
    return EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.inviteOnly(
        capacityLimit: capacityLimit,
        waitlistPolicy: const EventWaitlistPolicy.disabled(),
        privateAccessPolicy: EventPrivateAccessPolicy.inviteCode(
          inviteCodeHint: inviteCodeHint,
        ),
      ),
      pricingPolicy: EventPricingPolicy.fixed(
        MoneyAmount.inPaise(basePriceInPaise),
      ),
      cancellationPolicy: cancellationPolicy,
    );
  }

  factory EventPolicyBundle.requestToJoinEvent({
    required int capacityLimit,
    required int basePriceInPaise,
    EventCancellationPolicy cancellationPolicy =
        const EventCancellationPolicy.standard(),
  }) {
    return EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.manualApproval(
        capacityLimit: capacityLimit,
        waitlistPolicy: const EventWaitlistPolicy(
          mode: EventWaitlistMode.manualReview,
          offerWindow: Duration.zero,
        ),
      ),
      pricingPolicy: EventPricingPolicy.fixed(
        MoneyAmount.inPaise(basePriceInPaise),
      ),
      cancellationPolicy: cancellationPolicy,
    );
  }

  factory EventPolicyBundle.fixedCohortCapsEvent({
    required int capacityLimit,
    required int basePriceInPaise,
    int? maxMenInterestedInWomen,
    int? maxWomenInterestedInMen,
    EventCancellationPolicy cancellationPolicy =
        const EventCancellationPolicy.standard(),
  }) {
    return EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.fixedCohortCaps(
        capacityLimit: capacityLimit,
        cohortCapacityLimits: {
          EventCohortIds.menInterestedInWomen: ?maxMenInterestedInWomen,
          EventCohortIds.womenInterestedInMen: ?maxWomenInterestedInMen,
        },
        waitlistPolicy: const EventWaitlistPolicy.rankedOffer(),
      ),
      pricingPolicy: EventPricingPolicy.fixed(
        MoneyAmount.inPaise(basePriceInPaise),
      ),
      cancellationPolicy: cancellationPolicy,
    );
  }

  factory EventPolicyBundle.balancedSinglesEvent({
    required int capacityLimit,
    required int basePriceInPaise,
    int maxSkew = 1,
    EventDemandPricingRule? demandPricingRule,
    EventCancellationPolicy cancellationPolicy =
        const EventCancellationPolicy.standard(),
  }) {
    return EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.balancedRatio(
        capacityLimit: capacityLimit,
        waitlistPolicy: const EventWaitlistPolicy.rankedOffer(),
        balancedRatioPolicy: BalancedRatioPolicy(
          leftCohortId: EventCohortIds.menInterestedInWomen,
          rightCohortId: EventCohortIds.womenInterestedInMen,
          maxSkew: maxSkew,
          outOfRatioCohortPolicy:
              EventOutOfRatioCohortPolicy.admitWithinGeneralCapacity,
        ),
      ),
      pricingPolicy: EventPricingPolicy.fixed(
        MoneyAmount.inPaise(basePriceInPaise),
      ).copyWithDemandRule(demandPricingRule),
      cancellationPolicy: cancellationPolicy,
    );
  }

  factory EventPolicyBundle.demandPricedBalancedSinglesEvent({
    required int capacityLimit,
    required int basePriceInPaise,
    required int stepAdjustmentInPaise,
    required int maxAdjustmentInPaise,
    int maxSkew = 1,
    EventCancellationPolicy cancellationPolicy =
        const EventCancellationPolicy.standard(),
  }) {
    return EventPolicyBundle.balancedSinglesEvent(
      capacityLimit: capacityLimit,
      basePriceInPaise: basePriceInPaise,
      maxSkew: maxSkew,
      demandPricingRule: EventDemandPricingRule(
        pricedCohortId: EventCohortIds.menInterestedInWomen,
        balancingCohortId: EventCohortIds.womenInterestedInMen,
        stepAdjustment: MoneyAmount.inPaise(stepAdjustmentInPaise),
        maxAdjustment: MoneyAmount.inPaise(maxAdjustmentInPaise),
      ),
      cancellationPolicy: cancellationPolicy,
    );
  }

  factory EventPolicyBundle.legacyEvent({
    required int capacityLimit,
    required int priceInPaise,
    int? maxMen,
    int? maxWomen,
  }) {
    if (maxMen != null || maxWomen != null) {
      return EventPolicyBundle.fixedCohortCapsEvent(
        capacityLimit: capacityLimit,
        basePriceInPaise: priceInPaise,
        maxMenInterestedInWomen: maxMen,
        maxWomenInterestedInMen: maxWomen,
      );
    }
    return EventPolicyBundle.openEvent(
      capacityLimit: capacityLimit,
      basePriceInPaise: priceInPaise,
    );
  }

  factory EventPolicyBundle.fromJson(Map<String, dynamic> json) {
    return EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.fromJson(
        _mapValue(json['admission']) ?? const {},
      ),
      pricingPolicy: EventPricingPolicy.fromJson(
        _mapValue(json['pricing']) ?? const {},
      ),
      cancellationPolicy: EventCancellationPolicy.fromJson(
        _mapValue(json['cancellation']) ?? const {},
      ),
      settlementPolicy: EventSettlementPolicy.fromJson(
        _mapValue(json['settlement']) ?? const {},
      ),
    );
  }

  int get capacityLimit => admissionPolicy.capacityLimit;
  int get basePriceInPaise => pricingPolicy.basePrice.inPaise;

  bool get usesBalancedRatio =>
      admissionPolicy.format == EventAdmissionFormat.balancedRatio;

  bool get usesFixedCohortCaps =>
      admissionPolicy.format == EventAdmissionFormat.fixedCohortCaps;

  bool get usesInviteOnly =>
      admissionPolicy.format == EventAdmissionFormat.inviteOnly ||
      admissionPolicy.inviteRequired;

  bool get usesDemandPricing => pricingPolicy.hasDemandPricing;

  Map<String, Object?> toJson() => {
    'version': version,
    'admission': admissionPolicy.toJson(),
    'pricing': pricingPolicy.toJson(),
    'cancellation': cancellationPolicy.toJson(),
    'settlement': settlementPolicy.toJson(),
  };
}

extension _EventPricingPolicyX on EventPricingPolicy {
  EventPricingPolicy copyWithDemandRule(EventDemandPricingRule? rule) {
    if (rule == null) return this;
    return EventPricingPolicy(
      basePrice: basePrice,
      cohortAdjustments: cohortAdjustments,
      demandPricingRules: [rule],
    );
  }
}

class EventAdmissionRequest {
  const EventAdmissionRequest({
    required this.attendee,
    this.hasValidInvite = false,
    this.isClubMember = false,
  });

  final EventAttendeeProfile attendee;
  final bool hasValidInvite;
  final bool isClubMember;
}

class EventAdmissionDecision {
  const EventAdmissionDecision({
    required this.type,
    required this.reason,
    required this.cohort,
    required this.priceQuote,
    required this.waitlistMode,
  });

  final EventAdmissionDecisionType type;
  final EventAdmissionDecisionReason reason;
  final EventCohort cohort;
  final EventPriceQuote priceQuote;
  final EventWaitlistMode waitlistMode;

  bool get isBookable => type == EventAdmissionDecisionType.admitted;
  bool get isWaitlisted => type == EventAdmissionDecisionType.waitlisted;
}

class EventPolicyEngine {
  const EventPolicyEngine();

  EventAdmissionDecision decideAdmission({
    required EventPolicyBundle policy,
    required EventAdmissionRequest request,
    required EventRosterSnapshot roster,
  }) {
    final cohort = policy.cohortResolver.resolve(request.attendee);
    final priceQuote = policy.pricingPolicy.quoteFor(
      cohort: cohort,
      roster: roster,
    );
    final admissionPolicy = policy.admissionPolicy;

    EventAdmissionDecision decision({
      required EventAdmissionDecisionType type,
      required EventAdmissionDecisionReason reason,
    }) {
      return EventAdmissionDecision(
        type: type,
        reason: reason,
        cohort: cohort,
        priceQuote: priceQuote,
        waitlistMode: admissionPolicy.waitlistPolicy.mode,
      );
    }

    if (admissionPolicy.inviteRequired && !request.hasValidInvite) {
      return decision(
        type: EventAdmissionDecisionType.inviteRequired,
        reason: EventAdmissionDecisionReason.inviteRequired,
      );
    }

    if (admissionPolicy.membershipRequired && !request.isClubMember) {
      return decision(
        type: EventAdmissionDecisionType.membershipRequired,
        reason: EventAdmissionDecisionReason.membershipRequired,
      );
    }

    if (roster.totalBooked >= admissionPolicy.capacityLimit) {
      return _capacityBlockedDecision(decision, admissionPolicy);
    }

    final cohortLimit = admissionPolicy.cohortCapacityLimits[cohort.id];
    if (cohortLimit != null &&
        roster.bookedCountFor(cohort.id) >= cohortLimit) {
      return _cohortBlockedDecision(
        decision,
        admissionPolicy,
        EventAdmissionDecisionReason.cohortCapReached,
      );
    }

    final balancedRatioPolicy = admissionPolicy.balancedRatioPolicy;
    if (balancedRatioPolicy != null) {
      if (!balancedRatioPolicy.appliesTo(cohort.id)) {
        return switch (balancedRatioPolicy.outOfRatioCohortPolicy) {
          EventOutOfRatioCohortPolicy.admitWithinGeneralCapacity =>
            _maybeManualReview(decision, admissionPolicy),
          EventOutOfRatioCohortPolicy.waitlist => _cohortBlockedDecision(
            decision,
            admissionPolicy,
            EventAdmissionDecisionReason.outOfRatioCohortWaitlisted,
          ),
          EventOutOfRatioCohortPolicy.manualReview => decision(
            type: EventAdmissionDecisionType.manualReviewRequired,
            reason: EventAdmissionDecisionReason.outOfRatioCohortRequiresReview,
          ),
          EventOutOfRatioCohortPolicy.reject => decision(
            type: EventAdmissionDecisionType.cohortUnavailable,
            reason: EventAdmissionDecisionReason.outOfRatioCohortRejected,
          ),
        };
      }

      if (!balancedRatioPolicy.allowsAdmission(
        cohortId: cohort.id,
        roster: roster,
      )) {
        return _cohortBlockedDecision(
          decision,
          admissionPolicy,
          EventAdmissionDecisionReason.balancedRatioLimitReached,
        );
      }
    }

    return _maybeManualReview(decision, admissionPolicy);
  }

  EventAdmissionDecision _maybeManualReview(
    EventAdmissionDecision Function({
      required EventAdmissionDecisionType type,
      required EventAdmissionDecisionReason reason,
    })
    decision,
    EventAdmissionPolicy admissionPolicy,
  ) {
    if (admissionPolicy.manualApprovalRequired) {
      return decision(
        type: EventAdmissionDecisionType.manualReviewRequired,
        reason: EventAdmissionDecisionReason.manualApprovalRequired,
      );
    }
    return decision(
      type: EventAdmissionDecisionType.admitted,
      reason: EventAdmissionDecisionReason.capacityAvailable,
    );
  }

  EventAdmissionDecision _capacityBlockedDecision(
    EventAdmissionDecision Function({
      required EventAdmissionDecisionType type,
      required EventAdmissionDecisionReason reason,
    })
    decision,
    EventAdmissionPolicy admissionPolicy,
  ) {
    if (admissionPolicy.waitlistPolicy.isEnabled) {
      return decision(
        type: EventAdmissionDecisionType.waitlisted,
        reason: EventAdmissionDecisionReason.capacityFull,
      );
    }
    return decision(
      type: EventAdmissionDecisionType.soldOut,
      reason: EventAdmissionDecisionReason.capacityFull,
    );
  }

  EventAdmissionDecision _cohortBlockedDecision(
    EventAdmissionDecision Function({
      required EventAdmissionDecisionType type,
      required EventAdmissionDecisionReason reason,
    })
    decision,
    EventAdmissionPolicy admissionPolicy,
    EventAdmissionDecisionReason reason,
  ) {
    if (admissionPolicy.waitlistPolicy.isEnabled) {
      return decision(
        type: EventAdmissionDecisionType.waitlisted,
        reason: reason,
      );
    }
    return decision(
      type: EventAdmissionDecisionType.cohortUnavailable,
      reason: reason,
    );
  }
}

T _enumFromName<T extends Enum>(List<T> values, Object? value, T fallback) {
  if (value is! String) return fallback;
  return values.firstWhere(
    (entry) => entry.name == value,
    orElse: () => fallback,
  );
}

Map<String, dynamic>? _mapValue(Object? value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) {
    return value.map((key, value) => MapEntry(key.toString(), value));
  }
  return null;
}

List<Object?> _listValue(Object? value) {
  if (value is List<Object?>) return value;
  if (value is List) return value.cast<Object?>();
  return const [];
}

Map<String, int> _intMap(Object? value) {
  final map = _mapValue(value);
  if (map == null) return const {};
  return {
    for (final entry in map.entries)
      if (entry.value is num) entry.key: (entry.value as num).round(),
  };
}

int _intValue(Object? value, {required int fallback}) {
  if (value is int) return value;
  if (value is num) return value.round();
  return fallback;
}

String? _stringValue(Object? value) => value is String ? value : null;

bool _boolValue(Object? value) => value is bool && value;
