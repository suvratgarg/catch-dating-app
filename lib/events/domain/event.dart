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
import 'package:catch_dating_app/l10n/generated/structured_domain_copy.g.dart';
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
    required EventMeetingLocation meetingLocation,
    required double startingPointLat,
    required double startingPointLng,
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

  factory Event.fromJson(Map<String, dynamic> json) =>
      _$EventFromJson(_normalizedEventJson(json));

  static Map<String, dynamic> _normalizedEventJson(Map<String, dynamic> json) {
    final normalized = Map<String, dynamic>.from(json);
    final location = _eventMeetingLocationFromJson(json);
    normalized
      ..['meetingLocation'] = location.toJson()
      ..['startingPointLat'] = location.latitude
      ..['startingPointLng'] = location.longitude;
    return normalized;
  }

  double get distanceMiles => distanceKm * 0.621371;
  ActivityKind get activityKind => eventFormat.activityKind;
  int get signedUpCount => bookedCount ?? 0;
  int get attendedCount => checkedInCount ?? 0;
  int get waitlistCount => waitlistedCount ?? 0;
  int get spotsRemaining => math.max(0, capacityLimit - signedUpCount);
  bool get isFull => signedUpCount >= capacityLimit;
  bool get isFree => priceInPaise == 0;
  bool get isCancelled => status == EventLifecycleStatus.cancelled;
  bool isUpcomingAt(DateTime now) => !isCancelled && startTime.isAfter(now);
  bool get hasRequirements => constraints.hasRequirements;
  String? get primaryPhotoUrl {
    if (eventPhotos.isNotEmpty) return eventPhotos.first.url;
    return photoUrl;
  }

  EventMeetingLocation get effectiveMeetingLocation => meetingLocation;
  String get locationName => meetingLocation.name;
  String? get locationNotes => meetingLocation.notes ?? locationDetails;
  double get effectiveStartingPointLat => meetingLocation.latitude;
  double get effectiveStartingPointLng => meetingLocation.longitude;
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
    required DateTime now,
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
    required DateTime now,
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
        ? StructuredDomainCopy.eventTitleMorning
        : hour < 17
        ? StructuredDomainCopy.eventTitleAfternoon
        : StructuredDomainCopy.eventTitleEvening;
    // copy:allow-inline(Composes governed period copy with dynamic event data)
    return '$weekday $period ${eventFormat.eventTitleLabel}';
  }
}

EventMeetingLocation _eventMeetingLocationFromJson(Map<String, dynamic> json) {
  final structured = json['meetingLocation'];
  if (structured is Map) {
    final mapped = structured.map(
      (key, value) => MapEntry(key.toString(), value),
    );
    try {
      final location = EventMeetingLocation.fromJson(mapped).normalized();
      if (_isValidExactEventLocation(location)) return location;
    } on Object {
      // Released documents may still carry only the legacy scalar mirrors.
      // Fall through to the deterministic compatibility promotion below.
    }
  }

  final legacy = EventMeetingLocation.legacy(
    name: json['meetingPoint'] is String ? json['meetingPoint'] as String : '',
    latitude: _eventCoordinate(json['startingPointLat']),
    longitude: _eventCoordinate(json['startingPointLng']),
    notes: json['locationDetails'] is String
        ? json['locationDetails'] as String
        : null,
  );
  if (legacy != null && _isValidExactEventLocation(legacy)) return legacy;
  throw const FormatException(
    'Published events require a named meeting location with exact coordinates.',
  );
}

double? _eventCoordinate(Object? value) =>
    value is num ? value.toDouble() : null;

bool _isValidExactEventLocation(EventMeetingLocation location) {
  final latitude = location.latitude;
  final longitude = location.longitude;
  return location.name.trim().isNotEmpty &&
      latitude.isFinite &&
      longitude.isFinite &&
      latitude >= -90 &&
      latitude <= 90 &&
      longitude >= -180 &&
      longitude <= 180;
}
