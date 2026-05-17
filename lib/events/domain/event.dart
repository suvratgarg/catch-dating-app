import 'dart:math' as math;

import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/domain/event_eligibility.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:intl/intl.dart';

part 'event.freezed.dart';
part 'event.g.dart';

enum PaceLevel implements Labelled {
  easy('Easy'),
  moderate('Moderate'),
  fast('Fast'),
  competitive('Competitive');

  const PaceLevel(this.label);
  @override
  final String label;
}

enum EventLifecycleStatus { active, cancelled }

/// The current booking status of a specific event from one user's perspective.
enum EventSignUpStatus {
  /// Event is upcoming, not full, and the user hasn't signed up.
  eligible,

  /// The user has already signed up.
  signedUp,

  /// The event is full and the user is not on the waitlist.
  full,

  /// The event is full and the user is on the waitlist.
  waitlisted,

  /// The user attended this event.
  attended,

  /// The event has started (or ended) and the user did not sign up.
  past,

  /// The user does not meet the event's eligibility constraints (age or gender cap).
  ineligible,
}

@freezed
abstract class Event with _$Event {
  const Event._();

  const factory Event({
    @JsonKey(includeToJson: false) required String id,
    required String clubId,
    @TimestampConverter() required DateTime startTime,
    @TimestampConverter() required DateTime endTime,
    required String meetingPoint,
    double? startingPointLat,
    double? startingPointLng,
    String? locationDetails,
    @JsonKey(includeIfNull: false) String? photoUrl,
    required double distanceKm,
    required PaceLevel pace,
    required int capacityLimit,
    required String description,
    required int priceInPaise,
    @JsonKey(includeIfNull: false) int? bookedCount,
    @JsonKey(includeIfNull: false) int? checkedInCount,
    @JsonKey(includeIfNull: false) int? waitlistedCount,
    @Default(EventLifecycleStatus.active) EventLifecycleStatus status,
    @NullableTimestampConverter() DateTime? cancelledAt,
    String? cancellationReason,
    @Default(EventConstraints()) EventConstraints constraints,
    @JsonKey(includeIfNull: false) EventPolicyBundle? eventPolicy,
    // Denormalized gender counts maintained atomically by Cloud Functions.
    // Keys are Gender enum names: 'man', 'woman', 'nonBinary', 'other'.
    @Default({}) Map<String, int> genderCounts,
    // Denormalized event-policy cohort counts maintained by Cloud Functions.
    // Keys are EventCohortIds values.
    @Default({}) Map<String, int> cohortCounts,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  double get distanceMiles => distanceKm * 0.621371;
  int get signedUpCount => bookedCount ?? 0;
  int get attendedCount => checkedInCount ?? 0;
  int get waitlistCount => waitlistedCount ?? 0;
  int get spotsRemaining => math.max(0, capacityLimit - signedUpCount);
  bool get isFull => signedUpCount >= capacityLimit;
  bool get isFree => priceInPaise == 0;
  bool get isCancelled => status == EventLifecycleStatus.cancelled;
  bool get isUpcoming => isUpcomingAt(DateTime.now());
  bool isUpcomingAt(DateTime now) => !isCancelled && startTime.isAfter(now);
  bool get hasRequirements => constraints.hasRequirements;
  bool get hasExactStartingPoint =>
      startingPointLat != null && startingPointLng != null;
  EventPolicyBundle get effectiveEventPolicy =>
      eventPolicy ??
      EventPolicyBundle.legacyEvent(
        capacityLimit: capacityLimit,
        priceInPaise: priceInPaise,
        maxMen: constraints.maxMen,
        maxWomen: constraints.maxWomen,
      );

  Map<String, int> get effectiveCohortCounts {
    if (cohortCounts.isNotEmpty) return cohortCounts;
    final nonBinaryOrOther =
        (genderCounts[Gender.nonBinary.name] ?? 0) +
        (genderCounts[Gender.other.name] ?? 0);
    return {
      if ((genderCounts[Gender.man.name] ?? 0) > 0)
        EventCohortIds.menInterestedInWomen: genderCounts[Gender.man.name]!,
      if ((genderCounts[Gender.woman.name] ?? 0) > 0)
        EventCohortIds.womenInterestedInMen: genderCounts[Gender.woman.name]!,
      if (nonBinaryOrOther > 0)
        EventCohortIds.nonBinaryOrOther: nonBinaryOrOther,
    };
  }

  int priceInPaiseFor(UserProfile user) {
    final policy = effectiveEventPolicy;
    final attendee = EventAttendeeProfile.fromUserProfile(user);
    final cohort = policy.cohortResolver.resolve(attendee);
    return policy.pricingPolicy
        .quoteFor(
          cohort: cohort,
          roster: EventRosterSnapshot(
            bookedCountsByCohort: effectiveCohortCounts,
          ),
        )
        .finalAmount
        .inPaise;
  }

  /// Returns fresh-viewer eligibility of [user] for this event.
  ///
  /// User-specific roster state lives in `eventParticipations`, so callers that
  /// know the viewer's participation edge should prefer a view-model seam that
  /// combines the event and participation before rendering action state.
  EventEligibility eligibilityFor(UserProfile user, {DateTime? now}) {
    final referenceNow = now ?? DateTime.now();
    if (!isUpcomingAt(referenceNow)) return const EventPast();
    if (user.age < constraints.minAge) return AgeTooYoung(constraints.minAge);
    if (user.age > constraints.maxAge) return AgeTooOld(constraints.maxAge);

    final policy = effectiveEventPolicy;
    if (signedUpCount >= policy.capacityLimit) return const EventFull();

    final decision = const EventPolicyEngine().decideAdmission(
      policy: policy,
      request: EventAdmissionRequest(
        attendee: EventAttendeeProfile.fromUserProfile(user),
      ),
      roster: EventRosterSnapshot(bookedCountsByCohort: effectiveCohortCounts),
    );

    if (decision.isBookable) return const Eligible();
    if (decision.isWaitlisted) return const EventFull();
    if (decision.reason == EventAdmissionDecisionReason.cohortCapReached ||
        decision.reason ==
            EventAdmissionDecisionReason.balancedRatioLimitReached) {
      return const GenderCapacityReached();
    }
    if (decision.reason == EventAdmissionDecisionReason.capacityFull) {
      return const EventFull();
    }
    return const GenderCapacityReached();
  }

  /// Returns the fresh-viewer booking status for [user].
  ///
  /// Signed-up, waitlisted, and attended statuses require a `EventParticipation`
  /// edge and are intentionally resolved outside this model.
  EventSignUpStatus statusFor(UserProfile user, {DateTime? now}) {
    return switch (eligibilityFor(user, now: now)) {
      EventPast() => EventSignUpStatus.past,
      EventFull() => EventSignUpStatus.full,
      Eligible() => EventSignUpStatus.eligible,
      _ => EventSignUpStatus.ineligible,
    };
  }

  String get title {
    final weekday = DateFormat('EEEE').format(startTime);
    final hour = startTime.hour;
    final period = hour < 12
        ? 'Morning'
        : hour < 17
        ? 'Afternoon'
        : 'Evening';
    return '$weekday $period Event';
  }
}
