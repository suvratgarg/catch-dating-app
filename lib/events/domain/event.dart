import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/domain/event_eligibility.dart';
import 'package:catch_dating_app/events/domain/event_meeting_location.dart';
import 'package:catch_dating_app/events/domain/event_service.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

// Re-export so existing `import '.../event.dart'` call sites keep working
// without churning every import. Prefer importing the dedicated file in new
// code.
export 'package:catch_dating_app/events/domain/event_meeting_location.dart';

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
    @JsonKey(includeIfNull: false) EventMeetingLocation? meetingLocation,
    double? startingPointLat,
    double? startingPointLng,
    String? locationDetails,
    @JsonKey(includeIfNull: false) String? photoUrl,
    @Default([]) List<UploadedPhoto> eventPhotos,
    @Default(EventFormatSnapshot.socialRun()) EventFormatSnapshot eventFormat,
    required double distanceKm,
    required PaceLevel pace,
    required int capacityLimit,
    required String description,
    required int priceInPaise,
    @Default(defaultCurrencyCode) String currency,
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
    // Denormalized waitlist demand by event-policy cohort. Used for dynamic
    // pricing quotes without reading the whole waitlist on every client view.
    @Default({}) Map<String, int> waitlistedCohortCounts,
  }) = _Event;

  factory Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

  double get distanceMiles => distanceKm * 0.621371;
  ActivityKind get activityKind => eventFormat.activityKind;
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
      effectiveStartingPointLat != null && effectiveStartingPointLng != null;
  String? get primaryPhotoUrl {
    if (eventPhotos.isNotEmpty) return eventPhotos.first.url;
    return photoUrl;
  }

  EventMeetingLocation? get effectiveMeetingLocation =>
      meetingLocation ??
      EventMeetingLocation.legacy(
        name: meetingPoint,
        latitude: startingPointLat,
        longitude: startingPointLng,
        notes: locationDetails,
      );
  String get locationName => effectiveMeetingLocation?.name ?? meetingPoint;
  String? get locationNotes =>
      effectiveMeetingLocation?.notes ?? locationDetails;
  double? get effectiveStartingPointLat =>
      effectiveMeetingLocation?.latitude ?? startingPointLat;
  double? get effectiveStartingPointLng =>
      effectiveMeetingLocation?.longitude ?? startingPointLng;
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

  Map<String, int> get effectiveWaitlistedCohortCounts =>
      waitlistedCohortCounts;

  int priceInPaiseFor(UserProfile user) {
    final policy = effectiveEventPolicy;
    final attendee = EventAttendeeProfile.fromUserProfile(user);
    final cohort = policy.cohortResolver.resolve(attendee);
    return policy.pricingPolicy
        .quoteFor(
          cohort: cohort,
          roster: EventRosterSnapshot(
            bookedCountsByCohort: effectiveCohortCounts,
            waitlistedCountsByCohort: effectiveWaitlistedCohortCounts,
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
  @Deprecated('Use EventService.eligibilityFor instead')
  EventEligibility eligibilityFor(
    UserProfile user, {
    DateTime? now,
    bool hasValidInvite = false,
  }) {
    return EventService.eligibilityFor(
      this,
      user,
      now: now,
      hasValidInvite: hasValidInvite,
    );
  }

  /// Returns the fresh-viewer booking status for [user].
  ///
  /// Signed-up, waitlisted, and attended statuses require a `EventParticipation`
  /// edge and are intentionally resolved outside this model.
  EventSignUpStatus statusFor(
    UserProfile user, {
    DateTime? now,
    bool hasValidInvite = false,
  }) {
    return switch (EventService.eligibilityFor(
      this,
      user,
      now: now,
      hasValidInvite: hasValidInvite,
    )) {
      EventPast() => EventSignUpStatus.past,
      EventFull() => EventSignUpStatus.full,
      Eligible() => EventSignUpStatus.eligible,
      _ => EventSignUpStatus.ineligible,
    };
  }

  String get title {
    final weekday = AppTimeFormatters.longWeekday(startTime);
    final hour = startTime.hour;
    final period = hour < 12
        ? 'Morning'
        : hour < 17
        ? 'Afternoon'
        : 'Evening';
    return '$weekday $period ${eventFormat.eventTitleLabel}';
  }
}
