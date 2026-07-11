import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_prefill.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';

void main() {
  test('repeat prefill copies safe form values and requires a new date', () {
    final createdAt = DateTime(2026, 7, 10, 12);
    final event = buildEvent(
      id: 'trivia-42',
      clubId: 'club-7',
      startTime: DateTime(2026, 7, 3, 20, 15),
      endTime: DateTime(2026, 7, 3, 22),
      eventFormat: EventFormatSnapshot.custom(
        label: 'Trivia',
        interactionModel: EventInteractionModel.teamRotations,
      ),
      distanceKm: 0,
      pace: PaceLevel.moderate,
      capacityLimit: 30,
      description: 'A hosted team trivia night.',
      priceInPaise: 125000,
      meetingLocation: const EventMeetingLocation(
        name: 'The Daily Bar',
        address: 'Bandra West, Mumbai',
        placeId: 'place-7',
        latitude: 19.06,
        longitude: 72.83,
        notes: 'Ask for the upstairs room.',
      ),
      constraints: const EventConstraints(minAge: 23, maxAge: 39),
      eventPolicy: EventPolicyBundle.inviteOnlyEvent(
        capacityLimit: 30,
        basePriceInPaise: 125000,
        inviteCodeHint: 'TR...42',
        cancellationPolicy: const EventCancellationPolicy.strict(),
      ),
    );

    final prefill = CreateEventPrefill.repeat(
      event: event,
      createdAt: createdAt,
    );
    final values = prefill.values;

    expect(prefill.sourceEventId, event.id);
    expect(values.clubId, event.clubId);
    expect(values.savedAt, createdAt);
    expect(values.activityKind, ActivityKind.openActivity.name);
    expect(values.customActivityLabel, 'Trivia');
    expect(values.interactionModel, EventInteractionModel.teamRotations.name);
    expect(values.description, event.description);
    expect(values.meetingPoint, 'The Daily Bar');
    expect(values.meetingLocationAddress, 'Bandra West, Mumbai');
    expect(values.selectedDateMillis, isNull);
    expect(values.selectedStartHour, 20);
    expect(values.selectedStartMinute, 15);
    expect(values.durationMinutes, 105);
    expect(values.admissionPreset, 'inviteOnly');
    expect(values.inviteCode, isNull);
    expect(values.cancellationPolicy, EventCancellationPolicyId.strict.name);
    expect(values.eventSuccessDefaults.enabled, isFalse);
  });

  test('members-only source is not exposed as repeatable', () {
    final event = buildEvent(
      eventPolicy: const EventPolicyBundle(
        admissionPolicy: EventAdmissionPolicy.membersOnly(capacityLimit: 20),
        pricingPolicy: EventPricingPolicy.fixed(MoneyAmount.inPaise(0)),
      ),
    );

    expect(CreateEventPrefill.canRepeat(event), isFalse);
  });

  test('lossy custom pricing policy is not exposed as repeatable', () {
    final event = buildEvent(
      eventPolicy: const EventPolicyBundle(
        admissionPolicy: EventAdmissionPolicy.balancedRatio(
          capacityLimit: 20,
          waitlistPolicy: EventWaitlistPolicy.rankedOffer(),
          balancedRatioPolicy: BalancedRatioPolicy(
            leftCohortId: EventCohortIds.menInterestedInWomen,
            rightCohortId: EventCohortIds.womenInterestedInMen,
            outOfRatioCohortPolicy:
                EventOutOfRatioCohortPolicy.admitWithinGeneralCapacity,
          ),
        ),
        pricingPolicy: EventPricingPolicy(
          basePrice: MoneyAmount.inPaise(10000),
          demandPricingRules: [
            EventDemandPricingRule(
              pricedCohortId: EventCohortIds.menInterestedInWomen,
              balancingCohortId: EventCohortIds.womenInterestedInMen,
              stepAdjustment: MoneyAmount.inPaise(1000),
              maxAdjustment: MoneyAmount.inPaise(5000),
              freeSkew: 2,
            ),
          ],
        ),
      ),
    );

    expect(CreateEventPrefill.canRepeat(event), isFalse);
    expect(
      () => CreateEventPrefill.repeat(event: event, createdAt: DateTime(2026)),
      throwsStateError,
    );
  });
}
