import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/events/data/event_callable_responses.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_constraints.dart';
import 'package:catch_dating_app/events/domain/event_invite_link.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/events/domain/saved_event.dart'
    as saved_domain;
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Event buildEvent({
  String id = 'event-1',
  String clubId = 'club-1',
  DateTime? startTime,
  DateTime? endTime,
  String meetingPoint = 'Carter Road',
  EventMeetingLocation? meetingLocation,
  double startingPointLat = 19.0608,
  double startingPointLng = 72.8365,
  String? locationDetails,
  String? photoUrl,
  EventFormatSnapshot eventFormat = const EventFormatSnapshot.socialRun(),
  double distanceKm = 5,
  PaceLevel pace = PaceLevel.easy,
  int capacityLimit = 20,
  String description = 'Easy paced seaside event.',
  int priceInPaise = 0,
  String currency = defaultCurrencyCode,
  int? bookedCount,
  int? checkedInCount,
  int? waitlistedCount,
  EventLifecycleStatus status = EventLifecycleStatus.active,
  EventConstraints constraints = const EventConstraints(),
  EventPolicyBundle? eventPolicy,
  Map<String, int> genderCounts = const {},
  Map<String, int> cohortCounts = const {},
  Map<String, int> waitlistedCohortCounts = const {},
}) {
  final start = startTime ?? DateTime.now().add(const Duration(hours: 2));
  final resolvedLocation =
      meetingLocation?.normalized() ??
      EventMeetingLocation(
        name: meetingPoint,
        latitude: startingPointLat,
        longitude: startingPointLng,
        notes: locationDetails,
      );
  return Event(
    id: id,
    clubId: clubId,
    startTime: start,
    endTime: endTime ?? start.add(const Duration(hours: 1)),
    meetingPoint: resolvedLocation.name,
    meetingLocation: resolvedLocation,
    startingPointLat: resolvedLocation.latitude,
    startingPointLng: resolvedLocation.longitude,
    locationDetails: resolvedLocation.notes,
    photoUrl: photoUrl,
    eventFormat: eventFormat,
    distanceKm: distanceKm,
    pace: pace,
    capacityLimit: capacityLimit,
    description: description,
    priceInPaise: priceInPaise,
    currency: currency,
    bookedCount: bookedCount,
    checkedInCount: checkedInCount,
    waitlistedCount: waitlistedCount,
    status: status,
    constraints: constraints,
    eventPolicy: eventPolicy,
    genderCounts: genderCounts,
    cohortCounts: cohortCounts,
    waitlistedCohortCounts: waitlistedCohortCounts,
  );
}

EventParticipation buildEventParticipation({
  required Event event,
  required String uid,
  EventParticipationStatus status = EventParticipationStatus.signedUp,
  DateTime? createdAt,
  Gender? genderAtSignup,
  String? cohortAtSignup,
  EventJoinRequestStatus? hostApprovalStatus,
  EventWaitlistOfferStatus? waitlistOfferStatus,
  DateTime? waitlistOfferedAt,
  DateTime? waitlistOfferExpiresAt,
  DateTime? waitlistOfferAcceptedAt,
  String? waitlistOfferId,
  String? paymentId,
  String? inviteLinkId,
  String? inviteSource,
  DateTime? inviteCapturedAt,
}) {
  final timestamp = createdAt ?? DateTime(2026, 5, 6, 7);
  return EventParticipation(
    id: eventParticipationId(eventId: event.id, uid: uid),
    eventId: event.id,
    clubId: event.clubId,
    uid: uid,
    status: status,
    createdAt: timestamp,
    updatedAt: timestamp,
    signedUpAt:
        status == EventParticipationStatus.signedUp ||
            status == EventParticipationStatus.attended
        ? timestamp
        : null,
    attendedAt: status == EventParticipationStatus.attended ? timestamp : null,
    waitlistedAt: status == EventParticipationStatus.waitlisted
        ? timestamp
        : null,
    cancelledAt: status == EventParticipationStatus.cancelled
        ? timestamp
        : null,
    deletedAt: status == EventParticipationStatus.deleted ? timestamp : null,
    genderAtSignup: genderAtSignup,
    cohortAtSignup: cohortAtSignup,
    paymentId: paymentId,
    hostApprovalStatus: hostApprovalStatus,
    waitlistOfferStatus: waitlistOfferStatus,
    waitlistOfferedAt: waitlistOfferedAt,
    waitlistOfferExpiresAt: waitlistOfferExpiresAt,
    waitlistOfferAcceptedAt: waitlistOfferAcceptedAt,
    waitlistOfferId: waitlistOfferId,
    inviteLinkId: inviteLinkId,
    inviteSource: inviteSource,
    inviteCapturedAt: inviteCapturedAt,
  );
}

UserProfile buildUser({
  String uid = 'runner-1',
  String name = 'Runner',
  String? firstName,
  String? lastName,
  String displayName = '',
  String email = 'runner@example.com',
  String bio = 'Here for the event.',
  List<ProfilePromptAnswer>? profilePrompts,
  Gender gender = Gender.man,
  List<Gender> interestedInGenders = const [Gender.woman],
  DateTime? dateOfBirth,
  String phoneNumber = '+910000000000',
  List<String> photoUrls = const [],
  int runPreferencesVersion = currentRunPreferencesVersion,
}) {
  final nameParts = name.trim().split(RegExp(r'\s+'));
  return UserProfile(
    uid: uid,
    email: email,
    name: name,
    firstName: firstName ?? nameParts.first,
    lastName:
        lastName ?? (nameParts.length > 1 ? nameParts.skip(1).join(' ') : ''),
    displayName: displayName,
    dateOfBirth: dateOfBirth ?? DateTime(1995, 6, 15),
    profilePrompts:
        profilePrompts ??
        normalizeProfilePromptAnswers(const [], legacyBio: bio),
    gender: gender,
    phoneNumber: phoneNumber,
    profileComplete: true,
    interestedInGenders: interestedInGenders,
    profilePhotos: _profilePhotosFromUrls(uid: uid, photoUrls: photoUrls),
    activityPreferences: _activityPreferences(version: runPreferencesVersion),
  );
}

Review buildReview({
  String id = 'review-1',
  String clubId = 'club-1',
  String? eventId = 'event-1',
  String reviewerUserId = 'runner-1',
  String reviewerName = 'Runner 1',
  int rating = 5,
  String comment = 'Loved it.',
  ReviewOwnerResponse? ownerResponse,
  DateTime? createdAt,
}) {
  return Review(
    id: id,
    clubId: clubId,
    eventId: eventId,
    reviewerUserId: reviewerUserId,
    reviewerName: reviewerName,
    rating: rating,
    comment: comment,
    ownerResponse: ownerResponse,
    createdAt: createdAt ?? DateTime(2025, 1, 2),
  );
}

Club buildClub({
  String id = 'club-1',
  String name = 'Stride Social',
  String description = 'Morning runners who like easy city loops.',
  String location = 'mumbai',
  String area = 'Bandra',
  String hostUserId = 'host-1',
  String hostName = 'Host',
  DateTime? createdAt,
}) {
  return Club(
    id: id,
    name: name,
    description: description,
    location: location,
    area: area,
    hostUserId: hostUserId,
    hostName: hostName,
    createdAt: createdAt ?? DateTime(2025),
    memberCount: 1,
  );
}

PublicProfile buildPublicProfile({
  String uid = 'runner-1',
  String name = 'Runner',
  int age = 30,
  String bio = 'Always up for a sunrise event.',
  List<ProfilePromptAnswer>? profilePrompts,
  Gender gender = Gender.man,
  List<String> photoUrls = const [],
  int runPreferencesVersion = currentRunPreferencesVersion,
}) {
  return PublicProfile(
    uid: uid,
    name: name,
    age: age,
    profilePrompts:
        profilePrompts ??
        normalizeProfilePromptAnswers(const [], legacyBio: bio),
    gender: gender,
    profilePhotos: _profilePhotosFromUrls(uid: uid, photoUrls: photoUrls),
    activityPreferences: _activityPreferences(version: runPreferencesVersion),
  );
}

ActivityPreferences _activityPreferences({required int version}) {
  return ActivityPreferences(running: RunningPreferences(version: version));
}

List<ProfilePhoto> _profilePhotosFromUrls({
  required String uid,
  required List<String> photoUrls,
}) {
  return [
    for (final indexed in photoUrls.indexed)
      ProfilePhoto.uploaded(
        position: indexed.$1,
        url: indexed.$2,
        storagePath: 'test-profiles/$uid/${indexed.$1}.jpg',
        now: DateTime(2026),
      ),
  ];
}

Future<void> pumpEventsTestApp(
  WidgetTester tester,
  Widget child, {
  Iterable overrides = const [],
  String? signedInUid = 'runner-1',
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (signedInUid != null)
          uidProvider.overrideWith((ref) => Stream.value(signedInUid)),
        ...overrides,
      ],
      child: _EventTestProviderPrimer(
        primeUid: signedInUid != null,
        child: MaterialApp(theme: AppTheme.light, home: child),
      ),
    ),
  );
  await tester.pump();
}

class _EventTestProviderPrimer extends ConsumerWidget {
  const _EventTestProviderPrimer({required this.primeUid, required this.child});

  final bool primeUid;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (primeUid) {
      ref.watch(uidProvider);
    }
    return child;
  }
}

class FakeEventRepository extends Fake implements EventRepository {
  String generatedId = 'generated-event-id';
  Event? createdEvent;
  Object? createError;
  Object? cancelError;
  Object? hostCancelError;
  Object? deleteEventError;
  Object? updateEventError;
  Object? joinWaitlistError;
  Object? leaveWaitlistError;
  Object? recordInviteOpenError;
  Object? createWaitlistOfferError;
  Object? acceptWaitlistOfferError;
  Object? declineWaitlistOfferError;
  Object? decideJoinRequestError;
  Object? markAttendanceError;
  Object? selfCheckInError;
  String? cancelledEventId;
  String? hostCancelledEventId;
  String? hostCancelReason;
  String? deletedEventId;
  Event? updatedEvent;
  bool? updatedEventIncludePolicy;
  String? updatedEventInviteCode;
  String? joinedWaitlistEventId;
  String? joinedWaitlistInviteCode;
  String? joinedWaitlistInviteLinkId;
  String? createdInviteLinkEventId;
  String? createdInviteLinkLabel;
  String? createdInviteLinkSource;
  String? disabledInviteLinkEventId;
  String? disabledInviteLinkId;
  String? recordedInviteOpenEventId;
  String? recordedInviteOpenLinkId;
  String? createdWaitlistOfferEventId;
  List<String>? createdWaitlistOfferUserIds;
  int? createdWaitlistOfferExpiresInMinutes;
  String? acceptedWaitlistOfferEventId;
  String? declinedWaitlistOfferEventId;
  WaitlistOfferAcceptanceCallableResponse acceptWaitlistOfferResponse =
      const WaitlistOfferAcceptanceCallableResponse(
        accepted: true,
        requiresPayment: false,
        booked: true,
      );
  String? decidedJoinRequestEventId;
  String? decidedJoinRequestUserId;
  String? decidedJoinRequestDecision;
  String? createdEventInviteCode;
  String? leftWaitlistEventId;
  String? markedAttendanceEventId;
  String? markedAttendanceUserId;
  String? selfCheckedInEventId;
  Event? fetchedEvent;
  EventSuccessDefaults? createdEventSuccessDefaults;
  final Map<String, Event?> watchedEvents = {};
  final Map<String, List<Event>> clubEvents = {};
  final Map<String, List<Event>> attendedEvents = {};
  final Map<String, List<Event>> signedUpEvents = {};
  final Map<String, EventPrivateAccess?> privateAccessByEventId = {};
  final Map<String, List<EventInviteLink>> inviteLinksByEventId = {};
  List<String>? recommendedClubIds;
  List<Event> recommendedEvents = const [];

  @override
  String generateId() => generatedId;

  @override
  Future<void> createEvent({
    required Event event,
    String? inviteCode,
    EventSuccessDefaults? eventSuccessDefaults,
  }) async {
    if (createError != null) {
      throw createError!;
    }
    createdEvent = event;
    createdEventInviteCode = inviteCode;
    createdEventSuccessDefaults = eventSuccessDefaults;
  }

  @override
  Future<Event?> fetchEvent(String id) async => fetchedEvent;

  @override
  Stream<Event?> watchEvent(String id) => Stream.value(watchedEvents[id]);

  @override
  Stream<EventPrivateAccess?> watchPrivateAccess(String eventId) =>
      Stream.value(privateAccessByEventId[eventId]);

  @override
  Stream<List<EventInviteLink>> watchInviteLinks(String eventId) =>
      Stream.value(inviteLinksByEventId[eventId] ?? const []);

  @override
  Stream<List<Event>> watchEventsForClub({required String clubId}) =>
      Stream.value(clubEvents[clubId] ?? const []);

  @override
  Stream<List<Event>> watchAttendedEvents({required String uid}) =>
      Stream.value(attendedEvents[uid] ?? const []);

  @override
  Stream<List<Event>> watchSignedUpEvents({required String uid}) =>
      Stream.value(signedUpEvents[uid] ?? const []);

  @override
  Future<List<Event>> fetchUpcomingEventsForClubs(List<String> clubIds) async {
    recommendedClubIds = clubIds;
    return recommendedEvents;
  }

  @override
  Future<void> cancelSignUpViaFunction({required String eventId}) async {
    if (cancelError != null) {
      throw cancelError!;
    }
    cancelledEventId = eventId;
  }

  @override
  Future<void> cancelEvent({required String eventId, String? reason}) async {
    if (hostCancelError != null) {
      throw hostCancelError!;
    }
    hostCancelledEventId = eventId;
    hostCancelReason = reason;
  }

  @override
  Future<void> deleteEvent({required String eventId}) async {
    if (deleteEventError != null) {
      throw deleteEventError!;
    }
    deletedEventId = eventId;
  }

  @override
  Future<void> updateEventDetails({
    required Event event,
    bool includePolicy = false,
    String? inviteCode,
  }) async {
    if (updateEventError != null) {
      throw updateEventError!;
    }
    updatedEvent = event;
    updatedEventIncludePolicy = includePolicy;
    updatedEventInviteCode = inviteCode;
  }

  @override
  Future<void> joinWaitlistViaFunction({
    required String eventId,
    String? inviteCode,
    String? inviteLinkId,
  }) async {
    if (joinWaitlistError != null) {
      throw joinWaitlistError!;
    }
    joinedWaitlistEventId = eventId;
    joinedWaitlistInviteCode = inviteCode;
    joinedWaitlistInviteLinkId = inviteLinkId;
  }

  @override
  Future<CreateEventInviteLinkCallableResponse> createInviteLink({
    required String eventId,
    required String label,
    String? source,
  }) async {
    createdInviteLinkEventId = eventId;
    createdInviteLinkLabel = label;
    createdInviteLinkSource = source;
    return CreateEventInviteLinkCallableResponse(
      inviteLinkId: 'invite-link-1',
      eventId: eventId,
      label: label,
      source: source,
    );
  }

  @override
  Future<void> disableInviteLink({
    required String eventId,
    required String inviteLinkId,
  }) async {
    disabledInviteLinkEventId = eventId;
    disabledInviteLinkId = inviteLinkId;
  }

  @override
  Future<RecordEventInviteLinkOpenCallableResponse> recordInviteLinkOpen({
    required String eventId,
    required String inviteLinkId,
  }) async {
    if (recordInviteOpenError != null) {
      throw recordInviteOpenError!;
    }
    recordedInviteOpenEventId = eventId;
    recordedInviteOpenLinkId = inviteLinkId;
    return RecordEventInviteLinkOpenCallableResponse(
      accepted: true,
      disabled: false,
      eventId: eventId,
      inviteLinkId: inviteLinkId,
    );
  }

  @override
  Future<void> leaveWaitlist({required String eventId}) async {
    if (leaveWaitlistError != null) {
      throw leaveWaitlistError!;
    }
    leftWaitlistEventId = eventId;
  }

  @override
  Future<CreateWaitlistOffersCallableResponse> createWaitlistOffers({
    required String eventId,
    required List<String> userIds,
    int? expiresInMinutes,
  }) async {
    if (createWaitlistOfferError != null) {
      throw createWaitlistOfferError!;
    }
    createdWaitlistOfferEventId = eventId;
    createdWaitlistOfferUserIds = userIds;
    createdWaitlistOfferExpiresInMinutes = expiresInMinutes;
    return const CreateWaitlistOffersCallableResponse(
      createdCount: 1,
      skippedCount: 0,
    );
  }

  @override
  Future<WaitlistOfferAcceptanceCallableResponse> acceptWaitlistOffer({
    required String eventId,
  }) async {
    if (acceptWaitlistOfferError != null) {
      throw acceptWaitlistOfferError!;
    }
    acceptedWaitlistOfferEventId = eventId;
    return acceptWaitlistOfferResponse;
  }

  @override
  Future<void> declineWaitlistOffer({required String eventId}) async {
    if (declineWaitlistOfferError != null) {
      throw declineWaitlistOfferError!;
    }
    declinedWaitlistOfferEventId = eventId;
  }

  @override
  Future<void> decideJoinRequest({
    required String eventId,
    required String userId,
    required String decision,
  }) async {
    if (decideJoinRequestError != null) {
      throw decideJoinRequestError!;
    }
    decidedJoinRequestEventId = eventId;
    decidedJoinRequestUserId = userId;
    decidedJoinRequestDecision = decision;
  }

  @override
  Future<bool> markAttendance({
    required String eventId,
    required String userId,
  }) async {
    if (markAttendanceError != null) {
      throw markAttendanceError!;
    }
    markedAttendanceEventId = eventId;
    markedAttendanceUserId = userId;
    return true;
  }

  @override
  Future<void> selfCheckInAttendance({
    required String eventId,
    required double? latitude,
    required double? longitude,
  }) async {
    if (selfCheckInError != null) {
      throw selfCheckInError!;
    }
    selfCheckedInEventId = eventId;
  }
}

class FakeEventParticipationRepository extends Fake
    implements EventParticipationRepository {
  final Map<String, List<EventParticipation>> eventParticipations = {};
  final Map<String, List<EventParticipation>> userParticipations = {};
  String? lastFetchedEventId;

  @override
  Future<List<EventParticipation>> fetchParticipationsForEvent({
    required String eventId,
  }) async {
    lastFetchedEventId = eventId;
    return eventParticipations[eventId] ?? const [];
  }

  @override
  Future<List<EventParticipation>> fetchHostReportParticipationsForEvent({
    required String eventId,
  }) async {
    lastFetchedEventId = eventId;
    return eventParticipations[eventId] ?? const [];
  }

  @override
  Stream<List<EventParticipation>> watchParticipationsForEvent({
    required String eventId,
  }) => Stream.value(eventParticipations[eventId] ?? const []);

  @override
  Stream<List<EventParticipation>> watchParticipationsForUser({
    required String uid,
  }) => Stream.value(userParticipations[uid] ?? const []);
}

class FakePaymentRepository extends Fake implements PaymentRepository {
  FakePaymentRepository({this.supportsPaid = true});

  final bool supportsPaid;
  Object? bookFreeEventError;
  Object? processPaymentError;
  bool bookFreeEventCalled = false;
  String? bookedFreeEventId;
  bool processPaymentCalled = false;
  ProcessPaymentCall? lastProcessPaymentCall;
  PaymentConfirmationData? processPaymentResult;

  @override
  bool get supportsPaidBookings => supportsPaid;

  @override
  bool supportsPaidBookingsForCurrency(String currencyCode) =>
      currencyCode.trim().toUpperCase() == 'INR' ? supportsPaid : true;

  String? bookedFreeEventInviteCode;
  String? bookedFreeEventInviteLinkId;

  @override
  Future<void> bookFreeEvent({
    required String eventId,
    String? inviteCode,
    String? inviteLinkId,
  }) async {
    if (bookFreeEventError != null) {
      throw bookFreeEventError!;
    }
    bookFreeEventCalled = true;
    bookedFreeEventId = eventId;
    bookedFreeEventInviteCode = inviteCode;
    bookedFreeEventInviteLinkId = inviteLinkId;
  }

  @override
  Future<PaymentConfirmationData> processPayment({
    required String eventId,
    required String currencyCode,
    required String description,
    required String userName,
    required String userEmail,
    required String userContact,
    String? inviteCode,
    String? inviteLinkId,
  }) async {
    if (!supportsPaid) {
      throw const PaidBookingUnsupportedException();
    }
    if (processPaymentError != null) {
      throw processPaymentError!;
    }
    processPaymentCalled = true;
    lastProcessPaymentCall = ProcessPaymentCall(
      eventId: eventId,
      currencyCode: currencyCode,
      description: description,
      userName: userName,
      userEmail: userEmail,
      userContact: userContact,
      inviteCode: inviteCode,
      inviteLinkId: inviteLinkId,
    );
    return processPaymentResult ??
        PaymentConfirmationData(
          paymentId: 'pay_test',
          orderId: 'order_test',
          amountInPaise: 0,
          currency: currencyCode,
          eventId: eventId,
        );
  }

  @override
  void dispose() {}
}

class ProcessPaymentCall {
  const ProcessPaymentCall({
    required this.eventId,
    required this.currencyCode,
    required this.description,
    required this.userName,
    required this.userEmail,
    required this.userContact,
    this.inviteCode,
    this.inviteLinkId,
  });

  final String eventId;
  final String currencyCode;
  final String description;
  final String userName;
  final String userEmail;
  final String userContact;
  final String? inviteCode;
  final String? inviteLinkId;
}

class FakePublicProfileRepository extends Fake
    implements PublicProfileRepository {
  List<String>? lastRequestedUids;
  final List<List<String>> fetchPublicProfilesCalls = [];
  List<PublicProfile> profiles = const [];

  @override
  Future<List<PublicProfile>> fetchPublicProfiles(List<String> uids) async {
    lastRequestedUids = uids;
    fetchPublicProfilesCalls.add(List.unmodifiable(uids));
    return profiles;
  }
}

class FakeSavedEventRepository extends Fake implements SavedEventRepository {
  String? savedUid;
  String? savedEventId;
  String? unsavedUid;
  String? unsavedEventId;
  bool throwOnSave = false;
  final Map<String, List<Event>> savedEventDetails = {};
  final Map<String, List<saved_domain.SavedEvent>> savedEvents = {};

  @override
  Future<void> saveEvent({required String uid, required String eventId}) async {
    if (throwOnSave) throw StateError('save failed');
    savedUid = uid;
    savedEventId = eventId;
  }

  @override
  Future<void> unsaveEvent({
    required String uid,
    required String eventId,
  }) async {
    unsavedUid = uid;
    unsavedEventId = eventId;
  }

  @override
  Stream<List<Event>> watchSavedEventDetailsForUser({required String uid}) =>
      Stream.value(savedEventDetails[uid] ?? const []);

  @override
  Stream<List<saved_domain.SavedEvent>> watchSavedEventsForUser({
    required String uid,
  }) {
    final savedEdges = savedEvents[uid];
    if (savedEdges != null) return Stream.value(savedEdges);
    final details = savedEventDetails[uid] ?? const <Event>[];
    return Stream.value([
      for (final event in details)
        saved_domain.SavedEvent(
          id: saved_domain.savedEventId(uid: uid, eventId: event.id),
          uid: uid,
          eventId: event.id,
          savedAt: DateTime(2026),
        ),
    ]);
  }

  @override
  Stream<saved_domain.SavedEvent?> watchSavedEvent({
    required String uid,
    required String eventId,
  }) {
    final edges = savedEvents[uid] ?? const <saved_domain.SavedEvent>[];
    for (final savedEvent in edges) {
      if (savedEvent.eventId == eventId) return Stream.value(savedEvent);
    }
    return Stream.value(null);
  }
}
