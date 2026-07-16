// copy:allow-file(Developer-only deterministic design fixture data)
import 'dart:async';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_draft.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/events/domain/event_invite_link.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/hosts/data/host_analytics_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_profile.dart';
import 'package:catch_dating_app/labs/design_fixtures/utility_surface_fixtures.dart';
import 'package:catch_dating_app/payments/domain/host_payment_account.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

/// Shared deterministic fixtures for host operations design review.
///
/// Keep these values free of Widgetbook widgets so the same host shell data can
/// back route captures once the capture pass reaches host operations.
final class HostOperationsFixtures {
  const HostOperationsFixtures._();

  static const hostUid = 'design-host-owner';
  static const coHostUid = 'design-host-cohost';
  static const guestUid = 'design-host-guest';
  static const secondGuestUid = 'design-host-guest-2';
  static const waitlistUid = 'design-host-waitlist';
  static final now = DateTime(2026, 6, 22, 10);

  static final hostProfile = HostProfile(
    uid: hostUid,
    displayName: 'Mira Shah',
    roleTitle: 'Founder, Sea Face Social',
    bio: 'Builds small-format social events with useful cues and clear hosts.',
    status: HostProfileStatus.active,
    verified: true,
    linkedClubIds: [primaryClub.id, dinnerClub.id],
    createdAt: now.subtract(const Duration(days: 400)),
    updatedAt: now.subtract(const Duration(days: 2)),
  );

  static final hostProfileMissingDisplayName = HostProfile(
    uid: hostUid,
    displayName: '',
    roleTitle: 'Founder, Sea Face Social',
    bio: 'Builds small-format social events with useful cues and clear hosts.',
    status: HostProfileStatus.active,
    verified: true,
    linkedClubIds: [primaryClub.id, dinnerClub.id],
    createdAt: now.subtract(const Duration(days: 400)),
    updatedAt: now.subtract(const Duration(days: 2)),
  );

  static const pendingPaymentAccount = HostPaymentAccount(
    userId: hostUid,
    country: 'IN',
    defaultCurrency: 'INR',
    stripeAccountId: 'acct_design_pending',
    chargesEnabled: false,
    payoutsEnabled: false,
    detailsSubmitted: true,
    onboardingStatus: HostPaymentOnboardingStatus.pending,
    requirementsPendingVerification: ['individual.verification.document'],
  );

  static const readyPaymentAccount = HostPaymentAccount(
    userId: hostUid,
    country: 'IN',
    defaultCurrency: 'INR',
    stripeAccountId: 'acct_design_ready',
    chargesEnabled: true,
    payoutsEnabled: true,
    detailsSubmitted: true,
    onboardingStatus: HostPaymentOnboardingStatus.complete,
  );

  static const restrictedPaymentAccount = HostPaymentAccount(
    userId: hostUid,
    country: 'IN',
    defaultCurrency: 'INR',
    stripeAccountId: 'acct_design_restricted',
    chargesEnabled: false,
    payoutsEnabled: false,
    detailsSubmitted: true,
    onboardingStatus: HostPaymentOnboardingStatus.restricted,
    disabledReason: 'Stripe needs director verification before payouts resume.',
    requirementsCurrentlyDue: ['company.directors_provided'],
  );

  static final owner = UtilitySurfaceFixtures.viewer.copyWith(
    uid: hostUid,
    name: 'Mira Shah',
    firstName: 'Mira',
    lastName: 'Shah',
    displayName: 'Mira',
    city: 'Mumbai',
    gender: Gender.woman,
  );

  static final primaryClub = Club(
    id: 'design-host-sea-face',
    name: 'Sea Face Social',
    description:
        'Coastal social runs, coffee tables, and low-pressure ways to meet people after work.',
    location: 'Mumbai',
    area: 'Bandra West',
    hostUserId: hostUid,
    hostName: 'Mira Shah',
    ownerUserId: hostUid,
    hostUserIds: const [hostUid, coHostUid],
    hostProfiles: const [
      ClubHostProfile(
        uid: hostUid,
        displayName: 'Mira Shah',
        role: ClubHostRole.owner,
      ),
      ClubHostProfile(uid: coHostUid, displayName: 'Rishi Mehta'),
    ],
    createdAt: DateTime(2025, 9, 12),
    imageUrl:
        'https://images.unsplash.com/photo-1502904550040-7534597429ae?w=1200&q=80',
    tags: const ['social run', 'coffee after', 'new members'],
    memberCount: 428,
    rating: 4.9,
    reviewCount: 73,
    nextEventAt: DateTime(2030, 6, 24, 18, 30),
    nextEventLabel: 'Wed 6:30 PM',
    instagramHandle: '@seafacesocial',
    phoneNumber: '+91 98765 43210',
    email: 'hello@seafacesocial.example',
    hostDefaults: const ClubHostDefaults(
      supportedActivityKinds: [
        ActivityKind.socialRun,
        ActivityKind.walking,
        ActivityKind.dinner,
      ],
    ),
  );

  static final dinnerClub = Club(
    id: 'design-host-table-club',
    name: 'Long Table Club',
    description:
        'Dinner tables for people who want a slower social room and strong hosting.',
    location: 'Mumbai',
    area: 'Kala Ghoda',
    hostUserId: hostUid,
    hostName: 'Mira Shah',
    ownerUserId: hostUid,
    hostUserIds: const [hostUid],
    hostProfiles: const [
      ClubHostProfile(
        uid: hostUid,
        displayName: 'Mira Shah',
        role: ClubHostRole.owner,
      ),
    ],
    createdAt: DateTime(2025, 11, 3),
    tags: const ['dinner', 'conversation', 'members only'],
    memberCount: 96,
    rating: 4.7,
    reviewCount: 21,
    nextEventAt: DateTime(2030, 6, 29, 20),
    nextEventLabel: 'Mon 8:00 PM',
    hostDefaults: const ClubHostDefaults(
      primaryActivityKind: ActivityKind.dinner,
      supportedActivityKinds: [ActivityKind.dinner],
    ),
  );

  static final coHostedClub = primaryClub.copyWith(
    id: 'design-host-cohost-club',
    name: 'Tempo Social Club',
    ownerUserId: 'design-host-other-owner',
    hostUserId: 'design-host-other-owner',
    hostName: 'Aarav',
    hostUserIds: const ['design-host-other-owner', hostUid],
    hostProfiles: const [
      ClubHostProfile(
        uid: 'design-host-other-owner',
        displayName: 'Aarav Sinha',
        role: ClubHostRole.owner,
      ),
      ClubHostProfile(uid: hostUid, displayName: 'Mira Shah'),
    ],
    memberCount: 188,
    rating: 4.6,
    reviewCount: 19,
  );

  static final clubs = [primaryClub, dinnerClub, coHostedClub];

  static final upcomingEvent = event(
    id: 'design-host-event-upcoming',
    club: primaryClub,
    start: DateTime(2030, 6, 24, 18, 30),
    bookedCount: 10,
    waitlistedCount: 2,
  );

  static final privateEvent = event(
    id: 'design-host-event-private',
    club: primaryClub,
    start: DateTime(2030, 6, 27, 19),
    bookedCount: 11,
    waitlistedCount: 5,
    eventPolicy: EventPolicyBundle.inviteOnlyEvent(
      capacityLimit: 12,
      basePriceInPaise: 0,
      inviteCodeHint: 'SEAFACE',
    ),
  );

  static final unusedEvent = event(
    id: 'design-host-event-unused',
    club: primaryClub,
    start: DateTime(2030, 7, 5, 18, 30),
    bookedCount: 0,
    description: 'An unused host draft that can still be removed safely.',
  );

  static final fullEvent = event(
    id: 'design-host-event-full',
    club: dinnerClub,
    start: DateTime(2030, 6, 29, 20),
    bookedCount: 18,
    checkedInCount: 8,
    waitlistedCount: 6,
    capacityLimit: 18,
    activityKind: ActivityKind.dinner,
    meetingPoint: 'Kala Ghoda table 4',
    description: 'A guided dinner table with host-led introductions.',
  );

  static final cancelledEvent = upcomingEvent.copyWith(
    id: 'design-host-event-cancelled',
    status: EventLifecycleStatus.cancelled,
    cancelledAt: now.subtract(const Duration(hours: 3)),
    cancellationReason: 'Monsoon weather alert.',
  );

  static final eventsByClub = <String, List<Event>>{
    primaryClub.id: [upcomingEvent, privateEvent],
    dinnerClub.id: [fullEvent],
    coHostedClub.id: [],
  };

  static final privateAccess = EventPrivateAccess(
    id: 'design-host-private-access',
    eventId: privateEvent.id,
    clubId: primaryClub.id,
    inviteCode: 'SEAFACE',
    createdAt: now.subtract(const Duration(days: 2)),
  );

  static final inviteLinks = <EventInviteLink>[
    EventInviteLink(
      id: 'design-host-link-instagram',
      eventId: privateEvent.id,
      clubId: primaryClub.id,
      hostUid: hostUid,
      label: 'Instagram bio',
      source: 'instagram',
      openCount: 142,
      requestCount: 28,
      confirmedCount: 11,
      paidCount: 0,
      checkedInCount: 0,
      catcherCount: 3,
      matchCount: 2,
      chatStartedCount: 2,
      disabledAt: null,
      createdAt: now.subtract(const Duration(days: 2)),
      updatedAt: now.subtract(const Duration(hours: 4)),
    ),
    EventInviteLink(
      id: 'design-host-link-alumni',
      eventId: privateEvent.id,
      clubId: primaryClub.id,
      hostUid: hostUid,
      label: 'Alumni WhatsApp',
      source: 'whatsapp',
      openCount: 64,
      requestCount: 18,
      confirmedCount: 7,
      paidCount: 0,
      checkedInCount: 0,
      catcherCount: 1,
      matchCount: 1,
      chatStartedCount: 1,
      disabledAt: now.subtract(const Duration(hours: 1)),
      createdAt: now.subtract(const Duration(days: 1)),
      updatedAt: now.subtract(const Duration(hours: 1)),
    ),
  ];

  static final participations = <EventParticipation>[
    participation(
      uid: guestUid,
      event: privateEvent,
      status: EventParticipationStatus.attended,
      gender: Gender.man,
      createdOffset: const Duration(days: 3),
    ),
    participation(
      uid: secondGuestUid,
      event: privateEvent,
      status: EventParticipationStatus.signedUp,
      gender: Gender.woman,
      createdOffset: const Duration(days: 2),
    ),
    participation(
      uid: waitlistUid,
      event: privateEvent,
      status: EventParticipationStatus.waitlisted,
      gender: Gender.man,
      createdOffset: const Duration(days: 1),
    ),
  ];

  static final roster = EventParticipationRoster.fromParticipations(
    participations,
  );

  static final attendanceViewModel = (
    event: privateEvent,
    attendeeIds: roster.bookedIds,
    attendedIds: Set<String>.unmodifiable(roster.checkedInIds),
    waitlistedIds: roster.waitlistedIds,
    profileIds: <String>[...roster.bookedIds, ...roster.waitlistedIds],
    participationsByUid: Map<String, EventParticipation>.unmodifiable({
      for (final participation in participations)
        participation.uid: participation,
    }),
  );

  static final eventDraft = EventDraft(
    id: 'design-host-event-draft',
    clubId: primaryClub.id,
    savedAt: now.subtract(const Duration(hours: 2)),
    distance: '5',
    capacity: '12',
    price: '0',
    description: 'A relaxed after-work loop with clear host cues.',
    meetingPoint: 'Carter Road Jetty',
    locationDetails: 'Meet by the sea-facing steps.',
    meetingLocationAddress: 'Carter Road, Bandra West',
    startingPointLat: 19.0676,
    startingPointLng: 72.8227,
    selectedDateMillis: DateTime(2030, 6, 24).millisecondsSinceEpoch,
    selectedStartHour: 18,
    selectedStartMinute: 30,
  );

  static final clubDraft = ClubDraft(
    savedAt: now.subtract(const Duration(hours: 3)),
    name: 'Sea Face Evenings',
    area: 'Bandra West',
    description:
        'Low-pressure hosted formats for runners, walkers, and coffee-first social plans.',
    location: 'Mumbai',
    instagramHandle: '@seafaceevenings',
    phoneNumber: '+91 98765 43210',
    email: 'hello@seaface.example',
    hostDefaults: const ClubHostDefaults(
      supportedActivityKinds: [
        ActivityKind.socialRun,
        ActivityKind.walking,
        ActivityKind.dinner,
      ],
    ),
  );

  static final analyticsReport = HostAnalyticsReport(
    generatedAt: now,
    summaryCards: const [
      HostAnalyticsMetricCard(
        id: 'bookings',
        label: 'Bookings',
        value: 126,
        unit: HostAnalyticsMetricUnit.count,
        status: HostAnalyticsMetricStatus.ready,
        caption: '+18% vs prior period',
      ),
      HostAnalyticsMetricCard(
        id: 'check_in_rate',
        label: 'Check-in rate',
        value: 84,
        unit: HostAnalyticsMetricUnit.percent,
        status: HostAnalyticsMetricStatus.ready,
        caption: 'Strong arrival reliability',
      ),
      HostAnalyticsMetricCard(
        id: 'gross_revenue',
        label: 'Revenue',
        value: 148000,
        unit: HostAnalyticsMetricUnit.moneyMinor,
        status: HostAnalyticsMetricStatus.partial,
        caption: 'Free events excluded',
      ),
    ],
    trend: [
      HostAnalyticsTrendPoint(
        periodStart: now.subtract(const Duration(days: 21)),
        periodEnd: now.subtract(const Duration(days: 14)),
        metrics: const {'bookings': 28, 'checkIns': 22},
      ),
      HostAnalyticsTrendPoint(
        periodStart: now.subtract(const Duration(days: 14)),
        periodEnd: now.subtract(const Duration(days: 7)),
        metrics: const {'bookings': 41, 'checkIns': 34},
      ),
      HostAnalyticsTrendPoint(
        periodStart: now.subtract(const Duration(days: 7)),
        periodEnd: now,
        metrics: const {'bookings': 57, 'checkIns': 48},
      ),
    ],
    topEvents: [
      HostAnalyticsEventRow(
        eventId: privateEvent.id,
        clubId: privateEvent.clubId,
        title: 'Private Sundowner 5K',
        startTime: privateEvent.startTime,
        status: 'upcoming',
        bookedCount: 11,
        checkedInCount: 0,
        waitlistedCount: 5,
        fillRate: 92,
        checkInRate: 0,
        grossRevenueMinor: 0,
        currency: 'INR',
        checkoutStartedCount: 0,
        checkoutDropoffCount: 0,
        paymentCompletedCount: 0,
        paymentFailedCount: 0,
        paymentRefundedCount: 0,
        reviewCount: 0,
        averageRating: 0,
        demandCount: 31,
        inviteOpenCount: 206,
        mutualMatchCount: 3,
        chatStartedCount: 3,
        repeatAttendeeCount: 4,
      ),
      HostAnalyticsEventRow(
        eventId: fullEvent.id,
        clubId: fullEvent.clubId,
        title: 'Long Table Dinner',
        startTime: fullEvent.startTime,
        status: 'full',
        bookedCount: 18,
        checkedInCount: 8,
        waitlistedCount: 6,
        fillRate: 100,
        checkInRate: 44,
        grossRevenueMinor: 148000,
        currency: 'INR',
        checkoutStartedCount: 22,
        checkoutDropoffCount: 4,
        paymentCompletedCount: 18,
        paymentFailedCount: 1,
        paymentRefundedCount: 0,
        reviewCount: 6,
        averageRating: 4.8,
        demandCount: 34,
        inviteOpenCount: 88,
        mutualMatchCount: 5,
        chatStartedCount: 4,
        repeatAttendeeCount: 7,
      ),
    ],
    reviewSummary: const HostAnalyticsReviewSummary(
      newReviews: 6,
      publishedReviews: 28,
      verifiedReviews: 24,
      publicReviews: 22,
      ownerResponseCount: 5,
      averageRating: 4.8,
    ),
    discoverySummary: const HostAnalyticsDiscoverySummary(
      listingViews: 842,
      searchAppearances: 318,
      eventViews: 466,
      organizerSaves: 71,
      eventSaves: 53,
      contactClicks: 18,
      claimClicks: 0,
      outboundClicks: 42,
    ),
    dataQuality: const [
      HostAnalyticsDataQuality(
        id: 'reviews',
        state: HostAnalyticsDataQualityState.ok,
        detail: 'Reviews and discovery metrics are fresh.',
      ),
      HostAnalyticsDataQuality(
        id: 'payments',
        state: HostAnalyticsDataQualityState.partial,
        detail: 'Free events have no payment conversion denominator.',
      ),
    ],
  );

  static Event event({
    required String id,
    required Club club,
    required DateTime start,
    required int bookedCount,
    int checkedInCount = 0,
    int waitlistedCount = 0,
    int capacityLimit = 12,
    ActivityKind activityKind = ActivityKind.socialRun,
    String meetingPoint = 'Carter Road Jetty',
    String description = 'A relaxed social event with host-led cues.',
    EventPolicyBundle? eventPolicy,
  }) {
    return Event(
      id: id,
      clubId: club.id,
      startTime: start,
      endTime: start.add(const Duration(hours: 1, minutes: 30)),
      meetingPoint: meetingPoint,
      meetingLocation: EventMeetingLocation(
        name: meetingPoint,
        latitude: 19.0676,
        longitude: 72.8227,
        notes: club.area,
      ),
      startingPointLat: 19.0676,
      startingPointLng: 72.8227,
      eventFormat: EventFormatSnapshot.fromActivityKind(activityKind),
      distanceKm: activityKind == ActivityKind.dinner ? 0 : 5,
      pace: PaceLevel.easy,
      capacityLimit: capacityLimit,
      description: description,
      priceInPaise: activityKind == ActivityKind.dinner ? 95000 : 0,
      bookedCount: bookedCount,
      checkedInCount: checkedInCount,
      waitlistedCount: waitlistedCount,
      eventPolicy:
          eventPolicy ??
          EventPolicyBundle.openEvent(
            capacityLimit: capacityLimit,
            basePriceInPaise: activityKind == ActivityKind.dinner ? 95000 : 0,
          ),
    );
  }

  static EventParticipation participation({
    required String uid,
    required Event event,
    required EventParticipationStatus status,
    required Gender gender,
    required Duration createdOffset,
  }) {
    final createdAt = now.subtract(createdOffset);
    return EventParticipation(
      id: eventParticipationId(eventId: event.id, uid: uid),
      eventId: event.id,
      clubId: event.clubId,
      uid: uid,
      status: status,
      genderAtSignup: gender,
      createdAt: createdAt,
      updatedAt: createdAt,
      signedUpAt:
          status == EventParticipationStatus.signedUp ||
              status == EventParticipationStatus.attended
          ? createdAt
          : null,
      attendedAt: status == EventParticipationStatus.attended
          ? createdAt.add(const Duration(hours: 1))
          : null,
      waitlistedAt: status == EventParticipationStatus.waitlisted
          ? createdAt
          : null,
    );
  }

  static Stream<T> loadingStream<T>() => Stream<T>.empty();

  static Stream<T> errorStream<T>(String message) =>
      Stream<T>.error(StateError(message), StackTrace.empty);
}

final class HostFixtureAnalyticsRepository implements HostAnalyticsRepository {
  const HostFixtureAnalyticsRepository({this.report, this.error});

  final HostAnalyticsReport? report;
  final Object? error;

  @override
  Future<HostAnalyticsReport> getHostAnalytics(HostAnalyticsQuery query) async {
    final error = this.error;
    if (error != null) throw error;
    return report ?? HostOperationsFixtures.analyticsReport;
  }
}

final class HostFixtureEventDraftRepository implements EventDraftRepository {
  const HostFixtureEventDraftRepository({this.drafts = const []});

  final List<EventDraft> drafts;

  @override
  Future<List<EventDraft>> loadDrafts({
    required String clubId,
    required String userId,
  }) async {
    return drafts.where((draft) => draft.clubId == clubId).toList();
  }

  @override
  Future<void> saveDraft({
    required String userId,
    required EventDraft draft,
  }) async {}

  @override
  Future<void> deleteDraft({
    required String clubId,
    required String userId,
    required String draftId,
  }) async {}

  @override
  Future<void> deleteAllDrafts({
    required String clubId,
    required String userId,
  }) async {}
}
