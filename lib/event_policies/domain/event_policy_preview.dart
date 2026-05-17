import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

/// IN DEVELOPMENT: deterministic preview fixtures for the parallel event policy
/// engine.
///
/// This file is intentionally not wired into production booking. It exists so
/// host-facing event configurations can be tested against representative demand
/// snapshots before the live run schema is migrated.
const eventPolicyPreviewDevelopmentStatus =
    'in_development_parallel_policy_preview';

class EventPolicyPreviewScenario {
  const EventPolicyPreviewScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.policy,
    required this.roster,
    required this.probes,
    this.cancellationProbes = const [],
  });

  final String id;
  final String title;
  final String description;
  final EventPolicyBundle policy;
  final EventRosterSnapshot roster;
  final List<EventPolicyPreviewProbe> probes;
  final List<EventPolicyCancellationPreviewProbe> cancellationProbes;
}

class EventPolicyPreviewProbe {
  const EventPolicyPreviewProbe({
    required this.id,
    required this.label,
    required this.attendee,
    this.hasValidInvite = false,
    this.isClubMember = false,
  });

  final String id;
  final String label;
  final EventAttendeeProfile attendee;
  final bool hasValidInvite;
  final bool isClubMember;

  EventAdmissionRequest toAdmissionRequest() {
    return EventAdmissionRequest(
      attendee: attendee,
      hasValidInvite: hasValidInvite,
      isClubMember: isClubMember,
    );
  }
}

class EventPolicyCancellationPreviewProbe {
  const EventPolicyCancellationPreviewProbe({
    required this.id,
    required this.label,
    required this.actor,
    required this.beforeStart,
    required this.paidAmount,
    this.isWaitlisted = false,
  });

  final String id;
  final String label;
  final EventCancellationActor actor;
  final Duration beforeStart;
  final MoneyAmount paidAmount;
  final bool isWaitlisted;

  EventCancellationRequest toCancellationRequest() {
    return EventCancellationRequest(
      actor: actor,
      paidAmount: paidAmount,
      beforeStart: beforeStart,
      isWaitlisted: isWaitlisted,
    );
  }
}

class EventPolicyPreviewResult {
  const EventPolicyPreviewResult({
    required this.scenarioId,
    required this.scenarioTitle,
    required this.rows,
    required this.cancellationRows,
  });

  final String scenarioId;
  final String scenarioTitle;
  final List<EventPolicyPreviewRow> rows;
  final List<EventPolicyCancellationPreviewRow> cancellationRows;

  Map<String, Object?> toDebugMap() {
    return {
      'scenarioId': scenarioId,
      'scenarioTitle': scenarioTitle,
      'rows': rows.map((row) => row.toDebugMap()).toList(),
      'cancellationRows': cancellationRows
          .map((row) => row.toDebugMap())
          .toList(),
    };
  }
}

class EventPolicyPreviewRow {
  const EventPolicyPreviewRow({
    required this.probeId,
    required this.probeLabel,
    required this.cohortId,
    required this.cohortLabel,
    required this.decisionType,
    required this.decisionReason,
    required this.waitlistMode,
    required this.basePriceInPaise,
    required this.cohortAdjustmentInPaise,
    required this.demandAdjustmentInPaise,
    required this.finalPriceInPaise,
  });

  final String probeId;
  final String probeLabel;
  final String cohortId;
  final String cohortLabel;
  final EventAdmissionDecisionType decisionType;
  final EventAdmissionDecisionReason decisionReason;
  final EventWaitlistMode waitlistMode;
  final int basePriceInPaise;
  final int cohortAdjustmentInPaise;
  final int demandAdjustmentInPaise;
  final int finalPriceInPaise;

  bool get isBookable => decisionType == EventAdmissionDecisionType.admitted;

  bool get requiresManualAction =>
      decisionType == EventAdmissionDecisionType.manualReviewRequired ||
      decisionType == EventAdmissionDecisionType.inviteRequired ||
      decisionType == EventAdmissionDecisionType.membershipRequired;

  bool get isWaitlisted =>
      decisionType == EventAdmissionDecisionType.waitlisted;

  Map<String, Object?> toDebugMap() {
    return {
      'probeId': probeId,
      'probeLabel': probeLabel,
      'cohortId': cohortId,
      'cohortLabel': cohortLabel,
      'decisionType': decisionType.name,
      'decisionReason': decisionReason.name,
      'waitlistMode': waitlistMode.name,
      'basePriceInPaise': basePriceInPaise,
      'cohortAdjustmentInPaise': cohortAdjustmentInPaise,
      'demandAdjustmentInPaise': demandAdjustmentInPaise,
      'finalPriceInPaise': finalPriceInPaise,
      'isBookable': isBookable,
      'isWaitlisted': isWaitlisted,
      'requiresManualAction': requiresManualAction,
    };
  }
}

class EventPolicyCancellationPreviewRow {
  const EventPolicyCancellationPreviewRow({
    required this.probeId,
    required this.probeLabel,
    required this.policyId,
    required this.policyTitle,
    required this.actor,
    required this.beforeStartHours,
    required this.isWaitlisted,
    required this.remedy,
    required this.refundAmountInPaise,
    required this.creditAmountInPaise,
    required this.userLabel,
    required this.explanation,
  });

  final String probeId;
  final String probeLabel;
  final EventCancellationPolicyId policyId;
  final String policyTitle;
  final EventCancellationActor actor;
  final int beforeStartHours;
  final bool isWaitlisted;
  final EventCancellationRemedy remedy;
  final int refundAmountInPaise;
  final int creditAmountInPaise;
  final String userLabel;
  final String explanation;

  Map<String, Object?> toDebugMap() {
    return {
      'probeId': probeId,
      'probeLabel': probeLabel,
      'policyId': policyId.name,
      'policyTitle': policyTitle,
      'actor': actor.name,
      'beforeStartHours': beforeStartHours,
      'isWaitlisted': isWaitlisted,
      'remedy': remedy.name,
      'refundAmountInPaise': refundAmountInPaise,
      'creditAmountInPaise': creditAmountInPaise,
      'userLabel': userLabel,
      'explanation': explanation,
    };
  }
}

class EventPolicyPreviewHarness {
  const EventPolicyPreviewHarness({this.engine = const EventPolicyEngine()});

  final EventPolicyEngine engine;

  EventPolicyPreviewResult preview(EventPolicyPreviewScenario scenario) {
    final rows = scenario.probes
        .map((probe) {
          final decision = engine.decideAdmission(
            policy: scenario.policy,
            request: probe.toAdmissionRequest(),
            roster: scenario.roster,
          );
          final price = decision.priceQuote;

          return EventPolicyPreviewRow(
            probeId: probe.id,
            probeLabel: probe.label,
            cohortId: decision.cohort.id,
            cohortLabel: decision.cohort.label,
            decisionType: decision.type,
            decisionReason: decision.reason,
            waitlistMode: decision.waitlistMode,
            basePriceInPaise: price.basePrice.inPaise,
            cohortAdjustmentInPaise: price.cohortAdjustment.inPaise,
            demandAdjustmentInPaise: price.demandAdjustment.inPaise,
            finalPriceInPaise: price.finalAmount.inPaise,
          );
        })
        .toList(growable: false);
    final cancellationRows = scenario.cancellationProbes
        .map((probe) {
          final quote = scenario.policy.cancellationPolicy.quoteFor(
            probe.toCancellationRequest(),
          );

          return EventPolicyCancellationPreviewRow(
            probeId: probe.id,
            probeLabel: probe.label,
            policyId: quote.policyId,
            policyTitle: scenario.policy.cancellationPolicy.title,
            actor: quote.actor,
            beforeStartHours: probe.beforeStart.inHours,
            isWaitlisted: probe.isWaitlisted,
            remedy: quote.remedy,
            refundAmountInPaise: quote.refundAmount.inPaise,
            creditAmountInPaise: quote.creditAmount.inPaise,
            userLabel: quote.userLabel,
            explanation: quote.explanation,
          );
        })
        .toList(growable: false);

    return EventPolicyPreviewResult(
      scenarioId: scenario.id,
      scenarioTitle: scenario.title,
      rows: rows,
      cancellationRows: cancellationRows,
    );
  }

  List<EventPolicyPreviewResult> previewAll(
    List<EventPolicyPreviewScenario> scenarios,
  ) {
    return scenarios.map(preview).toList(growable: false);
  }
}

class EventPolicyPreviewCatalog {
  const EventPolicyPreviewCatalog._();

  static const inviteOnlyCancellationProbes =
      <EventPolicyCancellationPreviewProbe>[
        EventPolicyCancellationPreviewProbe(
          id: 'attendee_12h_before_private',
          label: 'Attendee cancels 12h before',
          actor: EventCancellationActor.attendee,
          beforeStart: Duration(hours: 12),
          paidAmount: MoneyAmount.inPaise(50000),
        ),
        EventPolicyCancellationPreviewProbe(
          id: 'host_cancels_private',
          label: 'Host cancels event',
          actor: EventCancellationActor.host,
          beforeStart: Duration(hours: 2),
          paidAmount: MoneyAmount.inPaise(50000),
        ),
      ];

  static const standardCancellationProbes =
      <EventPolicyCancellationPreviewProbe>[
        EventPolicyCancellationPreviewProbe(
          id: 'attendee_30h_before',
          label: 'Attendee cancels 30h before',
          actor: EventCancellationActor.attendee,
          beforeStart: Duration(hours: 30),
          paidAmount: MoneyAmount.inPaise(40000),
        ),
        EventPolicyCancellationPreviewProbe(
          id: 'attendee_8h_before',
          label: 'Attendee cancels 8h before',
          actor: EventCancellationActor.attendee,
          beforeStart: Duration(hours: 8),
          paidAmount: MoneyAmount.inPaise(40000),
        ),
        EventPolicyCancellationPreviewProbe(
          id: 'host_cancels_standard',
          label: 'Host cancels event',
          actor: EventCancellationActor.host,
          beforeStart: Duration(hours: 1),
          paidAmount: MoneyAmount.inPaise(40000),
        ),
      ];

  static const freeCancellationProbes = <EventPolicyCancellationPreviewProbe>[
    EventPolicyCancellationPreviewProbe(
      id: 'free_attendee_1h_before',
      label: 'Attendee cancels free event',
      actor: EventCancellationActor.attendee,
      beforeStart: Duration(hours: 1),
      paidAmount: MoneyAmount.inPaise(0),
    ),
    EventPolicyCancellationPreviewProbe(
      id: 'waitlisted_attendee_leaves',
      label: 'Waitlisted attendee leaves',
      actor: EventCancellationActor.attendee,
      beforeStart: Duration(hours: 1),
      paidAmount: MoneyAmount.inPaise(0),
      isWaitlisted: true,
    ),
  ];

  static const strictDemandCancellationProbes =
      <EventPolicyCancellationPreviewProbe>[
        EventPolicyCancellationPreviewProbe(
          id: 'surge_attendee_36h_before',
          label: 'Demand-priced attendee cancels 36h before',
          actor: EventCancellationActor.attendee,
          beforeStart: Duration(hours: 36),
          paidAmount: MoneyAmount.inPaise(100000),
        ),
        EventPolicyCancellationPreviewProbe(
          id: 'surge_attendee_6h_before',
          label: 'Demand-priced attendee cancels 6h before',
          actor: EventCancellationActor.attendee,
          beforeStart: Duration(hours: 6),
          paidAmount: MoneyAmount.inPaise(100000),
        ),
        EventPolicyCancellationPreviewProbe(
          id: 'host_cancels_surge_event',
          label: 'Host cancels demand-priced event',
          actor: EventCancellationActor.host,
          beforeStart: Duration(hours: 6),
          paidAmount: MoneyAmount.inPaise(100000),
        ),
      ];

  static const defaultScenarios = <EventPolicyPreviewScenario>[
    inviteOnlyPrivateEvent,
    capacityOnlyOpenEvent,
    fixedCohortCapsEvent,
    balancedRatioEvent,
    demandPricedBalancedEvent,
    manualApprovalEvent,
    membersOnlyEvent,
  ];

  static const inviteOnlyPrivateEvent = EventPolicyPreviewScenario(
    id: 'invite_only_private_event',
    title: 'Invite-only private event',
    description:
        'A private paid event where guests need an invite code/link and there is no waitlist.',
    policy: EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.inviteOnly(capacityLimit: 12),
      pricingPolicy: EventPricingPolicy.fixed(MoneyAmount.inPaise(50000)),
      cancellationPolicy: EventCancellationPolicy.flexible(),
    ),
    roster: EventRosterSnapshot(
      bookedCountsByCohort: {
        EventCohortIds.menInterestedInWomen: 6,
        EventCohortIds.womenInterestedInMen: 5,
      },
    ),
    probes: [
      EventPolicyPreviewProbe(
        id: 'guest_without_invite',
        label: 'Guest without invite',
        attendee: EventPolicyPreviewAttendees.straightMan,
      ),
      EventPolicyPreviewProbe(
        id: 'guest_with_invite',
        label: 'Guest with invite',
        attendee: EventPolicyPreviewAttendees.straightWoman,
        hasValidInvite: true,
      ),
    ],
    cancellationProbes: inviteOnlyCancellationProbes,
  );

  static const capacityOnlyOpenEvent = EventPolicyPreviewScenario(
    id: 'capacity_only_open_event',
    title: 'Capacity-only open event',
    description:
        'An open event where the host only cares about total attendance, not gender or cohort mix.',
    policy: EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.open(
        capacityLimit: 12,
        waitlistPolicy: EventWaitlistPolicy.rankedOffer(),
      ),
      pricingPolicy: EventPricingPolicy.fixed(MoneyAmount.inPaise(30000)),
      cancellationPolicy: EventCancellationPolicy.flexible(),
    ),
    roster: EventRosterSnapshot(
      bookedCountsByCohort: {
        EventCohortIds.menInterestedInWomen: 8,
        EventCohortIds.womenInterestedInMen: 3,
      },
    ),
    probes: [
      EventPolicyPreviewProbe(
        id: 'additional_man',
        label: 'Additional man',
        attendee: EventPolicyPreviewAttendees.straightMan,
      ),
      EventPolicyPreviewProbe(
        id: 'additional_woman',
        label: 'Additional woman',
        attendee: EventPolicyPreviewAttendees.straightWoman,
      ),
      EventPolicyPreviewProbe(
        id: 'non_binary_guest',
        label: 'Non-binary guest',
        attendee: EventPolicyPreviewAttendees.nonBinaryInterestedInWomen,
      ),
    ],
    cancellationProbes: freeCancellationProbes,
  );

  static const fixedCohortCapsEvent = EventPolicyPreviewScenario(
    id: 'fixed_cohort_caps_event',
    title: 'Fixed cohort caps',
    description:
        'A capped event where one cohort can fill independently of the total capacity.',
    policy: EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.fixedCohortCaps(
        capacityLimit: 30,
        cohortCapacityLimits: {
          EventCohortIds.menInterestedInWomen: 10,
          EventCohortIds.womenInterestedInMen: 10,
        },
        waitlistPolicy: EventWaitlistPolicy.rankedOffer(),
      ),
      pricingPolicy: EventPricingPolicy.fixed(MoneyAmount.inPaise(40000)),
      cancellationPolicy: EventCancellationPolicy.standard(),
    ),
    roster: EventRosterSnapshot(
      bookedCountsByCohort: {
        EventCohortIds.menInterestedInWomen: 10,
        EventCohortIds.womenInterestedInMen: 4,
      },
    ),
    probes: [
      EventPolicyPreviewProbe(
        id: 'man_after_men_cap',
        label: 'Man after men cap',
        attendee: EventPolicyPreviewAttendees.straightMan,
      ),
      EventPolicyPreviewProbe(
        id: 'woman_before_women_cap',
        label: 'Woman before women cap',
        attendee: EventPolicyPreviewAttendees.straightWoman,
      ),
      EventPolicyPreviewProbe(
        id: 'queer_open_guest',
        label: 'Queer/open guest',
        attendee: EventPolicyPreviewAttendees.queerOpenMan,
      ),
    ],
    cancellationProbes: standardCancellationProbes,
  );

  static const balancedRatioEvent = EventPolicyPreviewScenario(
    id: 'balanced_ratio_event',
    title: 'Balanced ratio event',
    description:
        'A ranked-waitlist event that keeps straight men and straight women within one slot of each other.',
    policy: EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.balancedRatio(
        capacityLimit: 100,
        balancedRatioPolicy: BalancedRatioPolicy(
          leftCohortId: EventCohortIds.menInterestedInWomen,
          rightCohortId: EventCohortIds.womenInterestedInMen,
          maxSkew: 1,
          outOfRatioCohortPolicy: EventOutOfRatioCohortPolicy.manualReview,
        ),
        waitlistPolicy: EventWaitlistPolicy.rankedOffer(),
      ),
      pricingPolicy: EventPricingPolicy.fixed(MoneyAmount.inPaise(40000)),
      cancellationPolicy: EventCancellationPolicy.standard(),
    ),
    roster: EventRosterSnapshot(
      bookedCountsByCohort: {
        EventCohortIds.menInterestedInWomen: 11,
        EventCohortIds.womenInterestedInMen: 10,
      },
    ),
    probes: [
      EventPolicyPreviewProbe(
        id: 'man_when_men_ahead',
        label: 'Man when men are ahead',
        attendee: EventPolicyPreviewAttendees.straightMan,
      ),
      EventPolicyPreviewProbe(
        id: 'woman_when_men_ahead',
        label: 'Woman when men are ahead',
        attendee: EventPolicyPreviewAttendees.straightWoman,
      ),
      EventPolicyPreviewProbe(
        id: 'non_binary_ratio_policy',
        label: 'Non-binary guest',
        attendee: EventPolicyPreviewAttendees.nonBinaryInterestedInWomen,
      ),
    ],
    cancellationProbes: standardCancellationProbes,
  );

  static const demandPricedBalancedEvent = EventPolicyPreviewScenario(
    id: 'demand_priced_balanced_event',
    title: 'Demand-priced balanced event',
    description:
        'A high-demand event where overrepresented cohort demand can raise price quotes before payment.',
    policy: EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.balancedRatio(
        capacityLimit: 100,
        balancedRatioPolicy: BalancedRatioPolicy(
          leftCohortId: EventCohortIds.menInterestedInWomen,
          rightCohortId: EventCohortIds.womenInterestedInMen,
          maxSkew: 1,
          outOfRatioCohortPolicy: EventOutOfRatioCohortPolicy.manualReview,
        ),
        waitlistPolicy: EventWaitlistPolicy.rankedOffer(),
      ),
      pricingPolicy: EventPricingPolicy(
        basePrice: MoneyAmount.inPaise(40000),
        cohortAdjustments: {
          EventCohortIds.womenInterestedInMen: MoneyAmount.inPaise(-10000),
        },
        demandPricingRules: [
          EventDemandPricingRule(
            pricedCohortId: EventCohortIds.menInterestedInWomen,
            balancingCohortId: EventCohortIds.womenInterestedInMen,
            freeSkew: 1,
            demandStep: 5,
            stepAdjustment: MoneyAmount.inPaise(20000),
            maxAdjustment: MoneyAmount.inPaise(60000),
          ),
        ],
      ),
      cancellationPolicy: EventCancellationPolicy.strict(),
    ),
    roster: EventRosterSnapshot(
      bookedCountsByCohort: {
        EventCohortIds.menInterestedInWomen: 20,
        EventCohortIds.womenInterestedInMen: 10,
      },
      waitlistedCountsByCohort: {EventCohortIds.menInterestedInWomen: 4},
    ),
    probes: [
      EventPolicyPreviewProbe(
        id: 'man_in_high_demand_cohort',
        label: 'Man in high-demand cohort',
        attendee: EventPolicyPreviewAttendees.straightMan,
      ),
      EventPolicyPreviewProbe(
        id: 'woman_in_balancing_cohort',
        label: 'Woman in balancing cohort',
        attendee: EventPolicyPreviewAttendees.straightWoman,
      ),
    ],
    cancellationProbes: strictDemandCancellationProbes,
  );

  static const manualApprovalEvent = EventPolicyPreviewScenario(
    id: 'manual_approval_event',
    title: 'Manual approval event',
    description:
        'A curated event where capacity checks pass first and then the host reviews applicants.',
    policy: EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.manualApproval(capacityLimit: 16),
      pricingPolicy: EventPricingPolicy.fixed(MoneyAmount.inPaise(60000)),
      cancellationPolicy: EventCancellationPolicy.standard(),
    ),
    roster: EventRosterSnapshot(
      bookedCountsByCohort: {
        EventCohortIds.menInterestedInWomen: 5,
        EventCohortIds.womenInterestedInMen: 5,
      },
    ),
    probes: [
      EventPolicyPreviewProbe(
        id: 'approval_candidate',
        label: 'Approval candidate',
        attendee: EventPolicyPreviewAttendees.straightWoman,
      ),
      EventPolicyPreviewProbe(
        id: 'queer_open_candidate',
        label: 'Queer/open candidate',
        attendee: EventPolicyPreviewAttendees.queerOpenWoman,
      ),
    ],
    cancellationProbes: standardCancellationProbes,
  );

  static const membersOnlyEvent = EventPolicyPreviewScenario(
    id: 'members_only_event',
    title: 'Members-only club event',
    description:
        'A club member event where non-members are blocked before capacity and pricing become actionable.',
    policy: EventPolicyBundle(
      admissionPolicy: EventAdmissionPolicy.membersOnly(
        capacityLimit: 20,
        waitlistPolicy: EventWaitlistPolicy.rankedOffer(),
      ),
      pricingPolicy: EventPricingPolicy.fixed(MoneyAmount.inPaise(0)),
      cancellationPolicy: EventCancellationPolicy.flexible(),
    ),
    roster: EventRosterSnapshot(
      bookedCountsByCohort: {
        EventCohortIds.menInterestedInWomen: 6,
        EventCohortIds.womenInterestedInMen: 6,
      },
    ),
    probes: [
      EventPolicyPreviewProbe(
        id: 'non_member',
        label: 'Non-member',
        attendee: EventPolicyPreviewAttendees.straightMan,
      ),
      EventPolicyPreviewProbe(
        id: 'club_member',
        label: 'Club member',
        attendee: EventPolicyPreviewAttendees.straightWoman,
        isClubMember: true,
      ),
    ],
    cancellationProbes: freeCancellationProbes,
  );
}

class EventPolicyPreviewAttendees {
  const EventPolicyPreviewAttendees._();

  static const straightMan = EventAttendeeProfile(
    uid: 'preview_straight_man',
    gender: Gender.man,
    interestedInGenders: {Gender.woman},
  );

  static const straightWoman = EventAttendeeProfile(
    uid: 'preview_straight_woman',
    gender: Gender.woman,
    interestedInGenders: {Gender.man},
  );

  static const queerOpenMan = EventAttendeeProfile(
    uid: 'preview_queer_open_man',
    gender: Gender.man,
    interestedInGenders: {Gender.man, Gender.woman},
  );

  static const queerOpenWoman = EventAttendeeProfile(
    uid: 'preview_queer_open_woman',
    gender: Gender.woman,
    interestedInGenders: {Gender.man, Gender.woman},
  );

  static const nonBinaryInterestedInWomen = EventAttendeeProfile(
    uid: 'preview_non_binary_interested_in_women',
    gender: Gender.nonBinary,
    interestedInGenders: {Gender.woman},
  );
}
