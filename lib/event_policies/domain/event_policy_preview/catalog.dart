// copy:allow-file(Developer-only event policy preview fixtures)
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_preview/attendees.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_preview/probes.dart';

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
        ),
        waitlistPolicy: EventWaitlistPolicy.rankedOffer(),
      ),
      pricingPolicy: EventPricingPolicy.fixed(MoneyAmount.inPaise(40000)),
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
    title: 'Followers-only organizer event',
    description:
        'An organizer follower event where non-followers are blocked before capacity and pricing become actionable.',
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
        label: 'Organizer follower',
        attendee: EventPolicyPreviewAttendees.straightWoman,
        isClubMember: true,
      ),
    ],
    cancellationProbes: freeCancellationProbes,
  );
}
