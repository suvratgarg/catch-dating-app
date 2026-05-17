import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy_preview.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const harness = EventPolicyPreviewHarness();

  test('catalog covers the first host-facing configuration set', () {
    expect(eventPolicyPreviewDevelopmentStatus, contains('in_development'));
    expect(
      EventPolicyPreviewCatalog.defaultScenarios.map((scenario) => scenario.id),
      containsAll(<String>[
        'invite_only_private_event',
        'capacity_only_open_event',
        'fixed_cohort_caps_event',
        'balanced_ratio_event',
        'demand_priced_balanced_event',
        'manual_approval_event',
        'members_only_event',
      ]),
    );
  });

  test('invite-only preview shows the invite gate and paid admission', () {
    final result = harness.preview(
      EventPolicyPreviewCatalog.inviteOnlyPrivateEvent,
    );

    final blocked = result.rowFor('guest_without_invite');
    final admitted = result.rowFor('guest_with_invite');

    expect(blocked.decisionType, EventAdmissionDecisionType.inviteRequired);
    expect(blocked.decisionReason, EventAdmissionDecisionReason.inviteRequired);
    expect(blocked.requiresManualAction, isTrue);
    expect(admitted.decisionType, EventAdmissionDecisionType.admitted);
    expect(admitted.finalPriceInPaise, 50000);
  });

  test('capacity-only preview ignores cohort skew while capacity remains', () {
    final result = harness.preview(
      EventPolicyPreviewCatalog.capacityOnlyOpenEvent,
    );

    expect(result.rowFor('additional_man').decisionType, admitted);
    expect(result.rowFor('additional_woman').decisionType, admitted);
    expect(result.rowFor('non_binary_guest').decisionType, admitted);
    expect(result.rowFor('additional_man').finalPriceInPaise, 30000);
  });

  test('fixed cap preview blocks only the capped cohort', () {
    final result = harness.preview(
      EventPolicyPreviewCatalog.fixedCohortCapsEvent,
    );

    final capped = result.rowFor('man_after_men_cap');
    final woman = result.rowFor('woman_before_women_cap');
    final queerOpen = result.rowFor('queer_open_guest');

    expect(capped.decisionType, EventAdmissionDecisionType.waitlisted);
    expect(
      capped.decisionReason,
      EventAdmissionDecisionReason.cohortCapReached,
    );
    expect(woman.decisionType, admitted);
    expect(queerOpen.decisionType, admitted);
  });

  test(
    'balanced ratio preview keeps ratio cohorts separate from review cohorts',
    () {
      final result = harness.preview(
        EventPolicyPreviewCatalog.balancedRatioEvent,
      );

      final man = result.rowFor('man_when_men_ahead');
      final woman = result.rowFor('woman_when_men_ahead');
      final nonBinary = result.rowFor('non_binary_ratio_policy');

      expect(man.decisionType, EventAdmissionDecisionType.waitlisted);
      expect(
        man.decisionReason,
        EventAdmissionDecisionReason.balancedRatioLimitReached,
      );
      expect(woman.decisionType, admitted);
      expect(
        nonBinary.decisionType,
        EventAdmissionDecisionType.manualReviewRequired,
      );
      expect(
        nonBinary.decisionReason,
        EventAdmissionDecisionReason.outOfRatioCohortRequiresReview,
      );
    },
  );

  test('demand-priced preview exposes admission and price quote together', () {
    final result = harness.preview(
      EventPolicyPreviewCatalog.demandPricedBalancedEvent,
    );

    final man = result.rowFor('man_in_high_demand_cohort');
    final woman = result.rowFor('woman_in_balancing_cohort');

    expect(man.decisionType, EventAdmissionDecisionType.waitlisted);
    expect(man.demandAdjustmentInPaise, 60000);
    expect(man.finalPriceInPaise, 100000);
    expect(woman.decisionType, admitted);
    expect(woman.cohortAdjustmentInPaise, -10000);
    expect(woman.finalPriceInPaise, 30000);
  });

  test('cancellation previews show bounded host and attendee outcomes', () {
    final result = harness.preview(
      EventPolicyPreviewCatalog.demandPricedBalancedEvent,
    );

    final credit = result.cancellationRowFor('surge_attendee_36h_before');
    final noRefund = result.cancellationRowFor('surge_attendee_6h_before');
    final hostCancelled = result.cancellationRowFor('host_cancels_surge_event');

    expect(credit.policyId, EventCancellationPolicyId.strict);
    expect(credit.remedy, EventCancellationRemedy.platformCredit);
    expect(credit.creditAmountInPaise, 50000);
    expect(noRefund.remedy, EventCancellationRemedy.noRefund);
    expect(
      hostCancelled.remedy,
      EventCancellationRemedy.platformMakesAttendeeComplete,
    );
    expect(hostCancelled.refundAmountInPaise, 100000);
    expect(hostCancelled.userLabel, 'Made complete');
  });

  test('manual and membership previews model non-bookable review states', () {
    final manual = harness.preview(
      EventPolicyPreviewCatalog.manualApprovalEvent,
    );
    final membersOnly = harness.preview(
      EventPolicyPreviewCatalog.membersOnlyEvent,
    );

    expect(
      manual.rowFor('approval_candidate').decisionType,
      EventAdmissionDecisionType.manualReviewRequired,
    );
    expect(
      membersOnly.rowFor('non_member').decisionType,
      EventAdmissionDecisionType.membershipRequired,
    );
    expect(membersOnly.rowFor('club_member').decisionType, admitted);
    expect(membersOnly.rowFor('club_member').finalPriceInPaise, 0);
  });

  test('debug map gives stable product-review output', () {
    final result = harness.preview(
      EventPolicyPreviewCatalog.demandPricedBalancedEvent,
    );

    expect(result.toDebugMap(), {
      'scenarioId': 'demand_priced_balanced_event',
      'scenarioTitle': 'Demand-priced balanced event',
      'rows': [
        {
          'probeId': 'man_in_high_demand_cohort',
          'probeLabel': 'Man in high-demand cohort',
          'cohortId': EventCohortIds.menInterestedInWomen,
          'cohortLabel': 'Men interested in women',
          'decisionType': 'waitlisted',
          'decisionReason': 'balancedRatioLimitReached',
          'waitlistMode': 'rankedOffer',
          'basePriceInPaise': 40000,
          'cohortAdjustmentInPaise': 0,
          'demandAdjustmentInPaise': 60000,
          'finalPriceInPaise': 100000,
          'isBookable': false,
          'isWaitlisted': true,
          'requiresManualAction': false,
        },
        {
          'probeId': 'woman_in_balancing_cohort',
          'probeLabel': 'Woman in balancing cohort',
          'cohortId': EventCohortIds.womenInterestedInMen,
          'cohortLabel': 'Women interested in men',
          'decisionType': 'admitted',
          'decisionReason': 'capacityAvailable',
          'waitlistMode': 'rankedOffer',
          'basePriceInPaise': 40000,
          'cohortAdjustmentInPaise': -10000,
          'demandAdjustmentInPaise': 0,
          'finalPriceInPaise': 30000,
          'isBookable': true,
          'isWaitlisted': false,
          'requiresManualAction': false,
        },
      ],
      'cancellationRows': [
        {
          'probeId': 'surge_attendee_36h_before',
          'probeLabel': 'Demand-priced attendee cancels 36h before',
          'policyId': 'strict',
          'policyTitle': 'Strict',
          'actor': 'attendee',
          'beforeStartHours': 36,
          'isWaitlisted': false,
          'remedy': 'platformCredit',
          'refundAmountInPaise': 0,
          'creditAmountInPaise': 50000,
          'userLabel': '50% credit',
          'explanation':
              'The cash refund window has closed, but this policy still returns platform credit.',
        },
        {
          'probeId': 'surge_attendee_6h_before',
          'probeLabel': 'Demand-priced attendee cancels 6h before',
          'policyId': 'strict',
          'policyTitle': 'Strict',
          'actor': 'attendee',
          'beforeStartHours': 6,
          'isWaitlisted': false,
          'remedy': 'noRefund',
          'refundAmountInPaise': 0,
          'creditAmountInPaise': 0,
          'userLabel': 'No refund',
          'explanation':
              'The attendee cancelled after the final cancellation window for this policy.',
        },
        {
          'probeId': 'host_cancels_surge_event',
          'probeLabel': 'Host cancels demand-priced event',
          'policyId': 'strict',
          'policyTitle': 'Strict',
          'actor': 'host',
          'beforeStartHours': 6,
          'isWaitlisted': false,
          'remedy': 'platformMakesAttendeeComplete',
          'refundAmountInPaise': 100000,
          'creditAmountInPaise': 0,
          'userLabel': 'Made complete',
          'explanation':
              'Host or platform cancellation overrides host policy; the attendee gets a full refund before any host payout.',
        },
      ],
    });
  });
}

const admitted = EventAdmissionDecisionType.admitted;

extension on EventPolicyPreviewResult {
  EventPolicyPreviewRow rowFor(String probeId) {
    return rows.singleWhere((row) => row.probeId == probeId);
  }

  EventPolicyCancellationPreviewRow cancellationRowFor(String probeId) {
    return cancellationRows.singleWhere((row) => row.probeId == probeId);
  }
}
