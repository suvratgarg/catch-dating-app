import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/event_success/data/event_success_repository.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/presentation/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/presentation/event_detail_screen.dart';
import 'package:catch_dating_app/events/presentation/event_detail_view_model.dart';
import 'package:catch_dating_app/events/presentation/widgets/booking_conflict_sheet.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_body.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_cta.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_overview_section.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_detail_social_section.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_hype_avatar_stack.dart';
import 'package:catch_dating_app/payments/data/payment_repository.dart';
import 'package:catch_dating_app/payments/domain/payment_confirmation_data.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

const _viewerUid = 'widgetbook-event-viewer';
const _clubId = 'widgetbook-event-club';
final _now = DateTime(2026, 6, 22, 9);

final _club = Club(
  id: _clubId,
  name: 'Sunday Sea Face Crew',
  description:
      'A city running crew for easy starts, steady conversation, and a cafe finish.',
  location: 'mumbai',
  area: 'Bandra',
  hostUserId: 'host-mira',
  hostName: 'Mira Shah',
  hostAvatarUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=160&q=80',
  ownerUserId: 'host-mira',
  hostProfiles: const [
    ClubHostProfile(
      uid: 'host-mira',
      displayName: 'Mira Shah',
      role: ClubHostRole.owner,
    ),
  ],
  createdAt: DateTime(2025, 10, 4),
  memberCount: 412,
  rating: 4.9,
  reviewCount: 73,
);

final _event = _eventDetailEvent();
final _pastEvent = _eventDetailEvent(
  id: 'widgetbook-event-detail-past',
  startTime: _now.subtract(const Duration(hours: 18)),
);
final _emptyEvent = _eventDetailEvent(
  id: 'widgetbook-event-detail-empty',
  bookedCount: 0,
  waitlistedCount: 0,
);

final _viewer = UserProfile(
  uid: _viewerUid,
  name: 'Neha Kapoor',
  firstName: 'Neha',
  lastName: 'Kapoor',
  displayName: 'Neha',
  dateOfBirth: DateTime(1996, 4, 12),
  gender: Gender.woman,
  phoneNumber: '+919876543210',
  profileComplete: true,
  city: 'Mumbai',
  interestedInGenders: const [Gender.man],
);

final _signedUp = EventParticipation(
  id: '${_event.id}_$_viewerUid',
  eventId: _event.id,
  clubId: _clubId,
  uid: _viewerUid,
  status: EventParticipationStatus.signedUp,
  createdAt: _now.subtract(const Duration(days: 3)),
  updatedAt: _now.subtract(const Duration(days: 3)),
  signedUpAt: _now.subtract(const Duration(days: 3)),
  genderAtSignup: Gender.woman,
);

final _attended = EventParticipation(
  id: '${_pastEvent.id}_$_viewerUid',
  eventId: _pastEvent.id,
  clubId: _clubId,
  uid: _viewerUid,
  status: EventParticipationStatus.attended,
  createdAt: _now.subtract(const Duration(days: 4)),
  updatedAt: _now.subtract(const Duration(hours: 12)),
  signedUpAt: _now.subtract(const Duration(days: 4)),
  attendedAt: _now.subtract(const Duration(hours: 12)),
  genderAtSignup: Gender.woman,
);

final _hostViewer = _viewer.copyWith(
  uid: 'host-mira',
  name: 'Mira Shah',
  displayName: 'Mira Shah',
  firstName: 'Mira',
  lastName: 'Shah',
);

final _reviews = [
  Review(
    id: 'widgetbook-event-review-1',
    clubId: _clubId,
    eventId: _pastEvent.id,
    reviewerUserId: _viewerUid,
    reviewerName: 'Neha',
    rating: 5,
    comment: 'Easy pace, clear host cues, and a genuinely good post-run table.',
    createdAt: _now.subtract(const Duration(hours: 10)),
  ),
  Review(
    id: 'widgetbook-event-review-2',
    clubId: _clubId,
    eventId: _pastEvent.id,
    reviewerUserId: 'runner-dev',
    reviewerName: 'Dev',
    rating: 5,
    comment: 'The group stayed together without feeling over-managed.',
    createdAt: _now.subtract(const Duration(hours: 8)),
  ),
  Review(
    id: 'widgetbook-event-review-3',
    clubId: _clubId,
    eventId: _pastEvent.id,
    reviewerUserId: 'runner-ana',
    reviewerName: 'Ana',
    rating: 4,
    comment: 'Great route and thoughtful regroup points.',
    createdAt: _now.subtract(const Duration(hours: 7)),
  ),
  Review(
    id: 'widgetbook-event-review-4',
    clubId: _clubId,
    eventId: _pastEvent.id,
    reviewerUserId: 'runner-lee',
    reviewerName: 'Lee',
    rating: 5,
    comment: 'The host made first-timers feel expected.',
    createdAt: _now.subtract(const Duration(hours: 6)),
  ),
];

@widgetbook.UseCase(
  name: 'Screen states',
  type: EventDetailScreen,
  path: '[Event Detail]/Screen states',
)
Widget eventDetailScreenStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailScreen',
    catalogId: 'screen.event.detail',
    children: [
      _StateCard(
        label: 'loading',
        child: _RouteFrame(
          value: const AsyncLoading<EventDetailViewModel?>(),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'not found',
        child: _RouteFrame(
          value: const AsyncData<EventDetailViewModel?>(null),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'fatal error',
        child: _RouteFrame(
          value: AsyncError<EventDetailViewModel?>(
            StateError('Widgetbook event detail load failed'),
            StackTrace.empty,
          ),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'member default',
        child: _RouteFrame(
          value: AsyncData(_eventVm(_event, participation: _signedUp)),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'guest',
        child: _RouteFrame(
          value: AsyncData(
            _eventVm(_event, isAuthenticated: false, isSaved: false),
          ),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'host app',
        child: _RouteFrame(
          value: AsyncData(
            _eventVm(_event, userProfile: _hostViewer, isHost: true),
          ),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'offline error',
        child: _RouteFrame(
          value: AsyncError<EventDetailViewModel?>(
            StateError('No network connection for Event Detail'),
            StackTrace.empty,
          ),
          child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
        ),
      ),
      _StateCard(
        label: 'ticket presentation',
        child: _RouteFrame(
          value: AsyncData(_eventVm(_event, participation: _signedUp)),
          child: EventDetailScreen(
            clubId: _clubId,
            eventId: _event.id,
            presentationMode: EventDetailPresentationMode.ticket,
          ),
        ),
      ),
      _StateCard(
        label: 'spotlight dark presentation',
        child: _RouteFrame(
          value: AsyncData(_eventVm(_event, participation: _signedUp)),
          child: EventDetailScreen(
            clubId: _clubId,
            eventId: _event.id,
            presentationMode: EventDetailPresentationMode.spotlightDark,
          ),
        ),
      ),
      _StateCard(
        label: 'text scale 2',
        child: MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: _RouteFrame(
            value: AsyncData(_eventVm(_event, participation: _signedUp)),
            child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
          ),
        ),
      ),
      _StateCard(
        label: 'reduced motion',
        child: TickerMode(
          enabled: false,
          child: _RouteFrame(
            value: AsyncData(_eventVm(_event, participation: _signedUp)),
            child: EventDetailScreen(clubId: _clubId, eventId: _event.id),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Overview states',
  type: EventDetailOverviewSection,
  path: '[Event Detail]/Sections',
)
Widget eventDetailOverviewSectionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailOverviewSection',
    catalogId: 'section.event.plan',
    children: [
      _StateCard(
        label: 'standard run plan',
        child: EventDetailOverviewSection(event: _event, onLocationTap: _noop),
      ),
      _StateCard(
        label: 'fallback plan / no photos',
        child: EventDetailOverviewSection(
          event: _event.copyWith(description: '', eventPhotos: const []),
        ),
      ),
      _StateCard(
        label: 'approval and paid policy',
        child: EventDetailOverviewSection(
          event: _eventDetailEvent(
            id: 'widgetbook-event-detail-approval',
            activityKind: ActivityKind.dinner,
            priceInPaise: 140000,
            bookedCount: 10,
            eventPolicy: EventPolicyBundle.requestToJoinEvent(
              capacityLimit: 12,
              basePriceInPaise: 140000,
            ),
          ),
          onLocationTap: _noop,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Social states',
  type: EventDetailSocialSection,
  path: '[Event Detail]/Sections',
)
Widget eventDetailSocialSectionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailSocialSection',
    catalogId: 'section.event.who_is_going',
    children: [
      _StateCard(
        label: 'guest locked',
        child: _EventScope(
          event: _event,
          roster: _roster(),
          child: EventDetailSocialSection(
            event: _event,
            clubId: _clubId,
            reviews: const [],
            userProfile: null,
            isAuthenticated: false,
            isHost: false,
            participation: null,
            now: _now,
          ),
        ),
      ),
      _StateCard(
        label: 'member visible',
        child: _EventScope(
          event: _event,
          roster: _roster(),
          child: EventDetailSocialSection(
            event: _event,
            clubId: _clubId,
            reviews: const [],
            userProfile: _viewer,
            isAuthenticated: true,
            isHost: false,
            participation: _signedUp,
            now: _now,
          ),
        ),
      ),
      _StateCard(
        label: 'empty roster',
        child: _EventScope(
          event: _emptyEvent,
          roster: EventParticipationRoster.empty(),
          child: EventDetailSocialSection(
            event: _emptyEvent,
            clubId: _clubId,
            reviews: const [],
            userProfile: _viewer,
            isAuthenticated: true,
            isHost: false,
            participation: null,
            now: _now,
          ),
        ),
      ),
      _StateCard(
        label: 'long avatar feed',
        child: _EventScope(
          event: _pastEvent,
          roster: _roster(event: _pastEvent, count: 9),
          avatarItems: _avatarItems,
          child: EventDetailSocialSection(
            event: _pastEvent,
            clubId: _clubId,
            reviews: _reviews,
            userProfile: _viewer,
            isAuthenticated: true,
            isHost: false,
            participation: _attended,
            now: _now,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Review states',
  type: EventReviewsSection,
  path: '[Event Detail]/Sections',
)
Widget eventDetailReviewsSectionStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventReviewsSection',
    catalogId: 'section.event.reviews',
    children: [
      _StateCard(
        label: 'hidden guest',
        child: const _HiddenSectionState(
          message: 'Reviews are not composed for signed-out Event Detail.',
        ),
      ),
      _StateCard(
        label: 'member before event',
        child: EventReviewsSection(
          clubId: _clubId,
          eventId: _event.id,
          reviews: const [],
          currentUid: _viewerUid,
          userProfile: _viewer,
        ),
      ),
      _StateCard(
        label: 'attended can review',
        child: EventReviewsSection(
          clubId: _clubId,
          eventId: _pastEvent.id,
          reviews: _reviews,
          currentUid: _viewerUid,
          userProfile: _viewer,
          hasAttended: true,
        ),
      ),
      _StateCard(
        label: 'host response actions',
        child: EventReviewsSection(
          clubId: _clubId,
          eventId: _pastEvent.id,
          reviews: _reviews,
          currentUid: 'host-mira',
          userProfile: _viewer.copyWith(uid: 'host-mira', name: 'Mira Shah'),
          isHost: true,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'BookingDock states',
  type: EventBookingDock,
  path: '[Event Detail]/Sections',
)
Widget eventDetailBookingDockStates(BuildContext context) {
  final t = CatchTokens.of(context);
  return _CatalogScreen(
    title: 'EventBookingDock',
    catalogId: 'section.event.booking_dock',
    children: [
      _StateCard(
        label: 'guest',
        child: const _DockFrame(
          child: EventBookingDock(
            label: 'Sign in to book this event',
            onPressed: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'bookable with price',
        child: _DockFrame(
          child: EventBookingDock(
            label: 'Book event',
            onPressed: _noop,
            leadingContent: const PriceLeading(
              price: '₹1,400',
              note: '2 spots left',
              warn: true,
            ),
            buttonAccentColor: t.primary,
            catchLine: 'Matching opens for everyone who goes',
            catchLineAccent: t.primary,
          ),
        ),
      ),
      _StateCard(
        label: 'pending',
        child: _DockFrame(
          child: EventBookingDock(
            label: 'Join event - 3 spots left',
            onPressed: null,
            isLoading: true,
            buttonAccentColor: t.primary,
          ),
        ),
      ),
      _StateCard(
        label: 'failed mutation',
        child: _DockFrame(
          child: EventBookingDock(
            label: 'Join event - 3 spots left',
            onPressed: _noop,
            errorMessage: 'Unable to book this event right now.',
            buttonAccentColor: t.primary,
          ),
        ),
      ),
      _StateCard(
        label: 'booked',
        child: const _DockFrame(
          child: EventBookingDock(
            label: 'Cancel booking',
            onPressed: _noop,
            leadingContent: BookedLeading(),
          ),
        ),
      ),
      _StateCard(
        label: 'waitlist',
        child: const _DockFrame(
          child: EventBookingDock(label: 'Join waitlist', onPressed: _noop),
        ),
      ),
      _StateCard(
        label: 'waitlist offer',
        child: _DockFrame(
          child: EventBookingDock(
            label: 'Accept spot',
            onPressed: _noop,
            leadingContent: WaitlistOfferLeading(
              expiresAt: _now.add(const Duration(hours: 5)),
              isDeclining: false,
              onDecline: _noop,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'full / cancelled / past / attended',
        child: const Column(
          children: [
            _DockFrame(
              child: EventBookingDock(
                label: 'Spots for your gender are full',
                onPressed: null,
              ),
            ),
            gapH12,
            _DockFrame(
              child: EventBookingDock(
                label: 'This event has ended',
                onPressed: null,
              ),
            ),
            gapH12,
            _DockFrame(
              child: EventBookingDock(
                label: 'You attended this event',
                onPressed: null,
                leadingContent: AttendedLeading(),
              ),
            ),
          ],
        ),
      ),
      _StateCard(
        label: 'host hidden',
        child: const _HiddenSectionState(
          message: 'No booking dock is composed in host app context.',
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Booking conflict sheet states',
  type: BookingConflictSheet,
  path: '[Event Detail]/Sheets',
)
Widget eventDetailBookingConflictSheetStates(BuildContext context) {
  return _CatalogScreen(
    title: 'BookingConflictSheet',
    catalogId: 'sheet.event.booking_conflict',
    children: [
      _StateCard(
        label: 'default conflict',
        child: const _SheetFrame(
          child: BookingConflictSheet(
            existing: BookingConflictEvent(
              title: 'Sunday Sea Face Crew',
              when: 'Wed, Jun 24 · 6:30 AM-8:15 AM',
              activityKind: ActivityKind.socialRun,
            ),
            incoming: BookingConflictEvent(
              title: 'Kala Ghoda Coffee Walk',
              when: 'Wed, Jun 24 · 6:45 AM-8:00 AM',
              activityKind: ActivityKind.walking,
            ),
            onReplaceExisting: _noop,
            onKeepBoth: _noop,
            onKeepExisting: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'replacement decision',
        child: const _SheetFrame(
          child: BookingConflictSheet(
            existing: BookingConflictEvent(
              title: 'Neighborhood Easy Run',
              when: 'Fri, Jun 26 · 7:00 PM-8:30 PM',
              activityKind: ActivityKind.socialRun,
            ),
            incoming: BookingConflictEvent(
              title: 'Founder-hosted Singles Dinner',
              when: 'Fri, Jun 26 · 7:15 PM-9:30 PM',
              activityKind: ActivityKind.dinner,
            ),
            onReplaceExisting: _noop,
            onKeepBoth: _noop,
            onKeepExisting: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'long event names',
        child: const _SheetFrame(
          child: BookingConflictSheet(
            existing: BookingConflictEvent(
              title:
                  'South Mumbai Golden Hour Social Run with Coffee and First-timer Intros',
              when: 'Sat, Jun 27 · 6:00 AM-8:45 AM · Carter Road to Bandstand',
              activityKind: ActivityKind.socialRun,
            ),
            incoming: BookingConflictEvent(
              title:
                  'Bandra Pub Quiz Mixer for People Who Always Say One More Round',
              when: 'Sat, Jun 27 · 6:15 AM-9:00 AM · Pali Hill Studio',
              activityKind: ActivityKind.pubQuiz,
            ),
            onReplaceExisting: _noop,
            onKeepBoth: _noop,
            onKeepExisting: _noop,
          ),
        ),
      ),
      _StateCard(
        label: 'fallback activity visuals',
        child: const _SheetFrame(
          child: BookingConflictSheet(
            existing: BookingConflictEvent(
              title: 'Saved event without activity metadata',
              when: 'Sun, Jun 28 · 5:00 PM-6:30 PM',
            ),
            incoming: BookingConflictEvent(
              title: 'Pickleball Doubles Mixer',
              when: 'Sun, Jun 28 · 5:15 PM-7:00 PM',
              activityKind: ActivityKind.pickleball,
            ),
            onReplaceExisting: _noop,
            onKeepBoth: _noop,
            onKeepExisting: _noop,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Prompt states',
  type: EventDetailBody,
  path: '[Event Detail]/Sections',
)
Widget eventDetailPromptBodyStates(BuildContext context) {
  return _CatalogScreen(
    title: 'EventDetailBody prompts',
    catalogId: 'section.event.companion_invite',
    children: [
      _StateCard(
        label: 'hidden',
        child: _DeviceFrame(
          child: _EventScope(
            event: _event,
            plan: null,
            child: EventDetailBody(
              event: _event,
              userProfile: _viewer,
              clubId: _clubId,
              reviews: const [],
              isAuthenticated: true,
              isHost: false,
              isSaved: false,
              participation: null,
              now: _now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'companion available',
        child: _DeviceFrame(
          child: _EventScope(
            event: _event,
            plan: EventSuccessPlan.defaultForEvent(_event, now: _now),
            child: EventDetailBody(
              event: _event,
              userProfile: _viewer,
              clubId: _clubId,
              reviews: _reviews,
              isAuthenticated: true,
              isHost: false,
              isSaved: true,
              participation: _signedUp,
              now: _now,
            ),
          ),
        ),
      ),
      _StateCard(
        label: 'invite loop available',
        child: _DeviceFrame(
          child: _EventScope(
            event: _event,
            plan: null,
            child: EventDetailBody(
              event: _event,
              userProfile: _viewer,
              clubId: _clubId,
              reviews: _reviews,
              isAuthenticated: true,
              isHost: false,
              isSaved: true,
              participation: _signedUp,
              now: _now,
              presentationMode: EventDetailPresentationMode.ticket,
            ),
          ),
        ),
      ),
    ],
  );
}

class _EventScope extends StatelessWidget {
  const _EventScope({
    required this.event,
    required this.child,
    this.roster,
    this.avatarItems,
    this.plan,
  });

  final Event event;
  final Widget child;
  final EventParticipationRoster? roster;
  final List<CatchPersonAvatarItem>? avatarItems;
  final EventSuccessPlan? plan;

  @override
  Widget build(BuildContext context) {
    final avatarQuery = EventHypeAvatarQuery(
      eventId: event.id,
      viewerInterestedInGenders: _viewer.interestedInGenders,
      limit: 7,
    );
    final avatars = avatarItems;
    return ProviderScope(
      overrides: [
        fetchClubProvider(_clubId).overrideWith((ref) => _club),
        watchEventParticipationRosterProvider(
          event.id,
        ).overrideWith((ref) => Stream.value(roster ?? _roster(event: event))),
        if (avatars != null)
          eventHypeAvatarsProvider(
            avatarQuery,
          ).overrideWith((ref) async => avatars),
        watchEventSuccessPlanProvider(
          event.id,
        ).overrideWith((ref) => Stream.value(plan)),
        paymentRepositoryProvider.overrideWithValue(_FakePaymentRepository()),
      ],
      child: child,
    );
  }
}

class _RouteFrame extends StatelessWidget {
  const _RouteFrame({required this.value, required this.child});

  final AsyncValue<EventDetailViewModel?> value;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final avatarQuery = EventHypeAvatarQuery(
      eventId: _event.id,
      viewerInterestedInGenders: _viewer.interestedInGenders,
      limit: 7,
    );

    return _DeviceFrame(
      child: ProviderScope(
        overrides: [
          eventDetailViewModelProvider(_event.id).overrideWithValue(value),
          fetchClubProvider(_clubId).overrideWith((ref) => _club),
          watchEventParticipationRosterProvider(
            _event.id,
          ).overrideWith((ref) => Stream.value(_roster())),
          eventHypeAvatarsProvider(
            avatarQuery,
          ).overrideWith((ref) async => _avatarItems),
          watchEventSuccessPlanProvider(
            _event.id,
          ).overrideWith((ref) => Stream.value(null)),
          paymentRepositoryProvider.overrideWithValue(
            const _FakePaymentRepository(),
          ),
        ],
        child: child,
      ),
    );
  }
}

class _FakePaymentRepository implements PaymentRepository {
  const _FakePaymentRepository();

  @override
  bool get supportsPaidBookings => true;

  @override
  bool supportsPaidBookingsForCurrency(String currencyCode) => true;

  @override
  Future<void> bookFreeEvent({
    required String eventId,
    String? inviteCode,
    String? inviteLinkId,
  }) async {}

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
    return PaymentConfirmationData(
      paymentId: 'widgetbook-payment',
      orderId: 'widgetbook-order',
      amountInPaise: 0,
      currency: currencyCode,
      eventId: eventId,
    );
  }

  @override
  void dispose() {}
}

EventDetailViewModel _eventVm(
  Event event, {
  UserProfile? userProfile,
  bool isAuthenticated = true,
  bool isHost = false,
  bool isSaved = true,
  EventParticipation? participation,
}) {
  return EventDetailViewModel(
    event: event,
    userProfile: userProfile ?? (isAuthenticated ? _viewer : null),
    reviews: _reviews,
    isAuthenticated: isAuthenticated,
    isHost: isHost,
    isSaved: isSaved,
    participation: participation,
  );
}

class _CatalogScreen extends StatelessWidget {
  const _CatalogScreen({
    required this.title,
    required this.catalogId,
    required this.children,
  });

  final String title;
  final String catalogId;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: CatchInsets.content,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: CatchTextStyles.titleL(context)),
              gapH4,
              Text(
                catalogId,
                style: CatchTextStyles.monoLabel(context, color: t.ink2),
              ),
              gapH24,
              for (final child in children) ...[child, gapH20],
            ],
          ),
        ),
      ),
    );
  }
}

class _StateCard extends StatelessWidget {
  const _StateCard({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        border: Border.all(color: t.line),
        borderRadius: BorderRadius.circular(CatchRadius.lg),
      ),
      child: Padding(
        padding: CatchInsets.content,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: CatchTextStyles.sectionTitle(context)),
            gapH12,
            child,
          ],
        ),
      ),
    );
  }
}

class _DeviceFrame extends StatelessWidget {
  const _DeviceFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.surface,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(height: 720, child: child),
          ),
        ),
      ),
    );
  }
}

class _DockFrame extends StatelessWidget {
  const _DockFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 390),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: t.surface,
          border: Border.all(color: t.line),
          borderRadius: BorderRadius.circular(CatchRadius.lg),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(CatchRadius.lg),
          child: child,
        ),
      ),
    );
  }
}

class _SheetFrame extends StatelessWidget {
  const _SheetFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 390),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: t.bg,
            border: Border.all(color: t.line),
            borderRadius: BorderRadius.circular(CatchRadius.lg),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(CatchRadius.lg),
            child: SizedBox(
              height: 560,
              child: Align(alignment: Alignment.bottomCenter, child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _HiddenSectionState extends StatelessWidget {
  const _HiddenSectionState({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return CatchEmptyState(
      title: 'Hidden',
      message: message,
      layout: CatchEmptyStateLayout.inline,
      surface: true,
    );
  }
}

Event _eventDetailEvent({
  String id = 'widgetbook-event-detail',
  ActivityKind activityKind = ActivityKind.socialRun,
  EventPolicyBundle? eventPolicy,
  int capacityLimit = 12,
  int bookedCount = 9,
  int waitlistedCount = 3,
  int priceInPaise = 0,
  DateTime? startTime,
}) {
  final start = startTime ?? DateTime(2026, 6, 24, 6, 30);
  return Event(
    id: id,
    clubId: _clubId,
    startTime: start,
    endTime: start.add(const Duration(hours: 1, minutes: 45)),
    meetingPoint: 'Carter Road Jetty',
    meetingLocation: EventMeetingLocation.legacy(
      name: 'Carter Road Jetty',
      latitude: 19.0676,
      longitude: 72.8227,
      notes: 'Bandra West',
    ),
    eventPhotos: [
      _photo('seaface', 0),
      _photo('coffee', 1),
      _photo('finish', 2),
    ],
    eventFormat: EventFormatSnapshot.fromActivityKind(activityKind),
    distanceKm: activityKind == ActivityKind.socialRun ? 5 : 0,
    pace: PaceLevel.easy,
    capacityLimit: capacityLimit,
    description:
        'An easy social pace along the seafront as the light goes gold, with coffee after for anyone who lingers.',
    priceInPaise: priceInPaise,
    bookedCount: bookedCount,
    waitlistedCount: waitlistedCount,
    eventPolicy:
        eventPolicy ??
        EventPolicyBundle.openEvent(
          capacityLimit: capacityLimit,
          basePriceInPaise: priceInPaise,
        ),
  );
}

EventParticipationRoster _roster({Event? event, int count = 7}) {
  final id = event?.id ?? _event.id;
  return EventParticipationRoster(
    bookedIds: List.generate(count, (index) => '$id-booked-$index'),
    checkedInIds: const [],
    waitlistedIds: const [],
  );
}

UploadedPhoto _photo(String id, int position) {
  return UploadedPhoto.fromUpload(
    url: 'https://example.invalid/widgetbook-event-$id.jpg',
    storagePath: 'widgetbook/events/$id.jpg',
    position: position,
    now: _now.add(Duration(minutes: position)),
  );
}

const _avatarItems = [
  CatchPersonAvatarItem(name: 'Rahul Anand'),
  CatchPersonAvatarItem(name: 'Arjun Iyer'),
  CatchPersonAvatarItem(name: 'Kabir Mehta'),
  CatchPersonAvatarItem(name: 'Dev Shah'),
  CatchPersonAvatarItem(name: 'Aarav Rao'),
  CatchPersonAvatarItem(name: 'Nikhil Menon'),
  CatchPersonAvatarItem(name: 'Ishaan Kapoor'),
];

void _noop() {}
