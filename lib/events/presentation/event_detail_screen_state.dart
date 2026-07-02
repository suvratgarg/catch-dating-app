import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_arrival_action.dart';
import 'package:catch_dating_app/events/domain/event_domain_readiness.dart';
import 'package:catch_dating_app/events/domain/event_eligibility.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_service.dart';
import 'package:catch_dating_app/events/presentation/event_detail_display_state.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_capacity_presenter.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

enum EventDetailBookingDockAction {
  none,
  openRunPreferences,
  book,
  cancelBooking,
  joinWaitlist,
  leaveWaitlist,
  acceptWaitlistOffer,
  declineWaitlistOffer,
}

enum EventDetailBookingDockButtonKey { book, cancelBooking, joinWaitlist }

enum EventDetailBookingDockLeadingKind {
  none,
  price,
  booked,
  waitlistOffer,
  attended,
}

class EventDetailBookingDockState {
  const EventDetailBookingDockState._({
    required this.visible,
    required this.label,
    required this.primaryAction,
    required this.buttonKey,
    required this.leadingKind,
    required this.isLoading,
    required this.useAccent,
    this.price,
    this.priceNote,
    this.priceWarn = false,
    this.waitlistOfferExpiresAt,
    this.secondaryAction = EventDetailBookingDockAction.none,
    this.isSecondaryLoading = false,
    this.catchLine,
    this.error,
  });

  const EventDetailBookingDockState.hidden()
    : this._(
        visible: false,
        label: '',
        primaryAction: EventDetailBookingDockAction.none,
        buttonKey: null,
        leadingKind: EventDetailBookingDockLeadingKind.none,
        isLoading: false,
        useAccent: false,
      );

  const EventDetailBookingDockState({
    required String label,
    required EventDetailBookingDockAction primaryAction,
    EventDetailBookingDockButtonKey? buttonKey,
    EventDetailBookingDockLeadingKind leadingKind =
        EventDetailBookingDockLeadingKind.none,
    bool isLoading = false,
    bool useAccent = false,
    String? price,
    String? priceNote,
    bool priceWarn = false,
    DateTime? waitlistOfferExpiresAt,
    EventDetailBookingDockAction secondaryAction =
        EventDetailBookingDockAction.none,
    bool isSecondaryLoading = false,
    String? catchLine,
    Object? error,
  }) : this._(
         visible: true,
         label: label,
         primaryAction: primaryAction,
         buttonKey: buttonKey,
         leadingKind: leadingKind,
         isLoading: isLoading,
         useAccent: useAccent,
         price: price,
         priceNote: priceNote,
         priceWarn: priceWarn,
         waitlistOfferExpiresAt: waitlistOfferExpiresAt,
         secondaryAction: secondaryAction,
         isSecondaryLoading: isSecondaryLoading,
         catchLine: catchLine,
         error: error,
       );

  final bool visible;
  final String label;
  final EventDetailBookingDockAction primaryAction;
  final EventDetailBookingDockButtonKey? buttonKey;
  final EventDetailBookingDockLeadingKind leadingKind;
  final bool isLoading;
  final bool useAccent;
  final String? price;
  final String? priceNote;
  final bool priceWarn;
  final DateTime? waitlistOfferExpiresAt;
  final EventDetailBookingDockAction secondaryAction;
  final bool isSecondaryLoading;
  final String? catchLine;
  final Object? error;

  bool get isPrimaryActionEnabled =>
      visible &&
      !isLoading &&
      primaryAction != EventDetailBookingDockAction.none;

  bool get isSecondaryActionEnabled =>
      visible &&
      !isSecondaryLoading &&
      secondaryAction != EventDetailBookingDockAction.none;
}

class EventDetailBookingDockMutationState {
  const EventDetailBookingDockMutationState({
    this.bookPending = false,
    this.cancelPending = false,
    this.joinWaitlistPending = false,
    this.leaveWaitlistPending = false,
    this.acceptWaitlistOfferPending = false,
    this.declineWaitlistOfferPending = false,
    this.error,
  });

  final bool bookPending;
  final bool cancelPending;
  final bool joinWaitlistPending;
  final bool leaveWaitlistPending;
  final bool acceptWaitlistOfferPending;
  final bool declineWaitlistOfferPending;
  final Object? error;
}

EventDetailBookingDockState eventDetailBookingDockStateFrom({
  required Event event,
  required UserProfile userProfile,
  required EventParticipation? participation,
  required DateTime now,
  required bool hasInviteCode,
  required bool supportsPaidBookings,
  EventDetailBookingDockMutationState mutationState =
      const EventDetailBookingDockMutationState(),
}) {
  final eligibility = _eventDetailEligibilityForParticipation(
    event: event,
    userProfile: userProfile,
    participation: participation,
    now: now,
    hasInviteCode: hasInviteCode,
  );
  final signUpStatus = _statusForEligibility(eligibility);
  final requiresHostApproval =
      event.effectiveEventPolicy.admissionPolicy.manualApprovalRequired;
  final hasApprovedJoinRequest =
      requiresHostApproval &&
      participation?.status == EventParticipationStatus.waitlisted &&
      participation != null &&
      EventService.participationStatus(participation, now: now).hasHostApproval;
  final hasActiveWaitlistOffer = participation != null
      ? EventService.participationStatus(
          participation,
          now: now,
        ).isWaitlistOfferActive
      : false;
  final canRequestHostApproval =
      requiresHostApproval && eligibility is GenderCapacityReached;
  final quotedPriceInPaise = event.priceInPaiseFor(userProfile);
  final isFreeForViewer = quotedPriceInPaise == 0;
  final needsRunPreferences =
      event.requiresRunPreferences && !userProfile.hasCurrentRunPreferences;

  if (hasActiveWaitlistOffer) {
    final paidUnsupported = !isFreeForViewer && !supportsPaidBookings;
    return EventDetailBookingDockState(
      label: paidUnsupported
          ? 'Paid booking unavailable'
          : isFreeForViewer
          ? 'Accept spot'
          : 'Accept spot and pay',
      primaryAction: paidUnsupported
          ? EventDetailBookingDockAction.none
          : EventDetailBookingDockAction.acceptWaitlistOffer,
      leadingKind: EventDetailBookingDockLeadingKind.waitlistOffer,
      waitlistOfferExpiresAt: participation.waitlistOfferExpiresAt,
      secondaryAction: EventDetailBookingDockAction.declineWaitlistOffer,
      isLoading: mutationState.acceptWaitlistOfferPending,
      isSecondaryLoading: mutationState.declineWaitlistOfferPending,
      useAccent: true,
      error: mutationState.error,
    );
  }

  if (canRequestHostApproval) {
    return EventDetailBookingDockState(
      label: needsRunPreferences ? 'Set run preferences' : 'Request to join',
      primaryAction: needsRunPreferences
          ? EventDetailBookingDockAction.openRunPreferences
          : EventDetailBookingDockAction.joinWaitlist,
      buttonKey: EventDetailBookingDockButtonKey.joinWaitlist,
      isLoading: mutationState.joinWaitlistPending,
      useAccent: true,
      error: mutationState.error,
    );
  }

  return switch (signUpStatus) {
    EventSignUpStatus.eligible => _eligibleBookingDockState(
      event: event,
      quotedPriceInPaise: quotedPriceInPaise,
      isFreeForViewer: isFreeForViewer,
      supportsPaidBookings: supportsPaidBookings,
      needsRunPreferences: needsRunPreferences,
      hasApprovedJoinRequest: hasApprovedJoinRequest,
      mutationState: mutationState,
    ),
    EventSignUpStatus.signedUp => _signedUpBookingDockState(
      event: event,
      participation: participation,
      now: now,
      mutationState: mutationState,
    ),
    EventSignUpStatus.full => EventDetailBookingDockState(
      label: needsRunPreferences
          ? 'Set run preferences'
          : requiresHostApproval
          ? 'Request to join'
          : 'Join waitlist',
      primaryAction: needsRunPreferences
          ? EventDetailBookingDockAction.openRunPreferences
          : EventDetailBookingDockAction.joinWaitlist,
      buttonKey: EventDetailBookingDockButtonKey.joinWaitlist,
      isLoading: mutationState.joinWaitlistPending,
      error: mutationState.error,
    ),
    EventSignUpStatus.waitlisted => EventDetailBookingDockState(
      label: requiresHostApproval ? 'Withdraw request' : 'Leave waitlist',
      primaryAction: EventDetailBookingDockAction.leaveWaitlist,
      isLoading: mutationState.leaveWaitlistPending,
      error: mutationState.error,
    ),
    EventSignUpStatus.attended => EventDetailBookingDockState(
      label: 'You attended this event',
      primaryAction: EventDetailBookingDockAction.none,
      leadingKind: EventDetailBookingDockLeadingKind.attended,
      error: mutationState.error,
    ),
    EventSignUpStatus.past => EventDetailBookingDockState(
      label: 'This event has ended',
      primaryAction: EventDetailBookingDockAction.none,
      error: mutationState.error,
    ),
    EventSignUpStatus.ineligible => EventDetailBookingDockState(
      label: switch (eligibility) {
        AgeTooYoung(:final minAge) => 'Must be $minAge+ to join',
        AgeTooOld(:final maxAge) => 'Must be $maxAge or younger',
        EventInviteRequired() => 'Invite required',
        GenderCapacityReached() =>
          requiresHostApproval
              ? 'Request required'
              : 'Spots for your gender are full',
        _ => 'Not eligible for this event',
      },
      primaryAction: EventDetailBookingDockAction.none,
      error: mutationState.error,
    ),
  };
}

EventDetailBookingDockState _eligibleBookingDockState({
  required Event event,
  required int quotedPriceInPaise,
  required bool isFreeForViewer,
  required bool supportsPaidBookings,
  required bool needsRunPreferences,
  required bool hasApprovedJoinRequest,
  required EventDetailBookingDockMutationState mutationState,
}) {
  final paidUnsupported = !isFreeForViewer && !supportsPaidBookings;
  final presenter = EventCapacityPresenter(event);
  final spotsRemaining = presenter.spotsRemaining;
  final isScarce = spotsRemaining > 0 && spotsRemaining <= 3;

  return EventDetailBookingDockState(
    label: paidUnsupported
        ? 'Paid booking unavailable'
        : needsRunPreferences
        ? 'Set run preferences'
        : hasApprovedJoinRequest
        ? isFreeForViewer
              ? 'Join approved event'
              : 'Complete approved booking'
        : isFreeForViewer
        ? 'Join event — ${presenter.joinCtaAvailabilityLabel}'
        : 'Book event',
    primaryAction: paidUnsupported
        ? EventDetailBookingDockAction.none
        : needsRunPreferences
        ? EventDetailBookingDockAction.openRunPreferences
        : EventDetailBookingDockAction.book,
    buttonKey: EventDetailBookingDockButtonKey.book,
    leadingKind: isFreeForViewer
        ? EventDetailBookingDockLeadingKind.none
        : EventDetailBookingDockLeadingKind.price,
    price: isFreeForViewer
        ? null
        : EventFormatters.priceInPaise(
            quotedPriceInPaise,
            currencyCode: event.currency,
          ),
    priceNote: !isFreeForViewer && isScarce
        ? '$spotsRemaining spots left'
        : null,
    priceWarn: !isFreeForViewer && isScarce,
    isLoading: mutationState.bookPending,
    useAccent: true,
    catchLine: 'Matching opens for everyone who goes',
    error: mutationState.error,
  );
}

EventDetailBookingDockState _signedUpBookingDockState({
  required Event event,
  required EventParticipation? participation,
  required DateTime now,
  required EventDetailBookingDockMutationState mutationState,
}) {
  if (isSelfCheckInOpenForParticipationStatus(
    event: event,
    status: participation?.status,
    now: now,
  )) {
    return const EventDetailBookingDockState.hidden();
  }

  return EventDetailBookingDockState(
    label: 'Cancel booking',
    primaryAction: EventDetailBookingDockAction.cancelBooking,
    buttonKey: EventDetailBookingDockButtonKey.cancelBooking,
    leadingKind: EventDetailBookingDockLeadingKind.booked,
    isLoading: mutationState.cancelPending,
    error: mutationState.error,
  );
}

EventEligibility _eventDetailEligibilityForParticipation({
  required Event event,
  required UserProfile userProfile,
  required EventParticipation? participation,
  required DateTime now,
  required bool hasInviteCode,
}) {
  return switch (participation?.status) {
    EventParticipationStatus.attended =>
      _hasEventStarted(event, now) ? const Attended() : const AlreadySignedUp(),
    EventParticipationStatus.signedUp => const AlreadySignedUp(),
    EventParticipationStatus.waitlisted
        when participation != null &&
            EventService.participationStatus(
              participation,
              now: now,
            ).hasHostApproval =>
      _hasEventStarted(event, now) ? const EventPast() : const Eligible(),
    EventParticipationStatus.waitlisted => const OnWaitlist(),
    EventParticipationStatus.cancelled ||
    EventParticipationStatus.deleted ||
    null => EventService.eligibilityFor(
      event,
      userProfile,
      now: now,
      hasValidInvite: hasInviteCode,
    ),
  };
}

bool _hasEventStarted(Event event, DateTime now) =>
    !event.startTime.isAfter(now);

EventSignUpStatus _statusForEligibility(EventEligibility eligibility) {
  return switch (eligibility) {
    Attended() => EventSignUpStatus.attended,
    AlreadySignedUp() => EventSignUpStatus.signedUp,
    EventPast() => EventSignUpStatus.past,
    OnWaitlist() => EventSignUpStatus.waitlisted,
    EventFull() => EventSignUpStatus.full,
    Eligible() => EventSignUpStatus.eligible,
    _ => EventSignUpStatus.ineligible,
  };
}

EventDetailCompanionState eventDetailCompanionStateFrom<T>({
  required EventParticipation? participation,
  required bool showConsumerActions,
  required CatchAsyncState<T?>? planState,
}) {
  if (!eventDetailCanOpenCompanion(
    participation: participation,
    showConsumerActions: showConsumerActions,
  )) {
    return const EventDetailCompanionState.hidden();
  }

  final resolvedPlan = planState;
  if (resolvedPlan == null) return const EventDetailCompanionState.loading();
  return switch (resolvedPlan.status) {
    CatchAsyncStatus.data =>
      resolvedPlan.value == null
          ? const EventDetailCompanionState.hidden()
          : const EventDetailCompanionState.available(),
    CatchAsyncStatus.loading => const EventDetailCompanionState.loading(),
    CatchAsyncStatus.error => EventDetailCompanionState.error(
      resolvedPlan.error!,
    ),
  };
}

bool eventDetailCanOpenCompanion({
  required EventParticipation? participation,
  required bool showConsumerActions,
}) {
  if (!showConsumerActions) return false;
  return switch (participation?.status) {
    EventParticipationStatus.signedUp ||
    EventParticipationStatus.attended => true,
    EventParticipationStatus.waitlisted ||
    EventParticipationStatus.cancelled ||
    EventParticipationStatus.deleted ||
    null => false,
  };
}

EventDetailHostState eventDetailHostStateFrom({
  required CatchAsyncState<Club?> clubState,
  required String? currentUid,
  required bool canMessageHost,
}) {
  return switch (clubState.status) {
    CatchAsyncStatus.data => () {
      final club = clubState.value;
      if (club == null) return const EventDetailHostState.hidden();
      final hostProfiles = club.displayHostProfiles;
      final hostProfile = hostProfiles.isEmpty ? null : hostProfiles.first;
      final hostUid = hostProfile?.uid ?? club.ownerOrPrimaryHostUserId;
      final canMessage =
          canMessageHost &&
          hostUid != null &&
          currentUid != null &&
          currentUid != hostUid;

      return EventDetailHostState.content(
        clubId: club.id,
        hostUid: hostUid,
        hostName: club.displayHostName,
        photoUrl: hostProfile?.avatarUrl ?? club.logoPhotoUrl,
        meta: _hostMeta(club),
        verified: club.ownerOrPrimaryHostUserId != null,
        stats: _hostStats(club),
        canMessage: canMessage,
      );
    }(),
    CatchAsyncStatus.loading => const EventDetailHostState.loading(),
    CatchAsyncStatus.error => EventDetailHostState.error(clubState.error!),
  };
}

const List<String> _monthAbbrevs = <String>[
  'JAN',
  'FEB',
  'MAR',
  'APR',
  'MAY',
  'JUN',
  'JUL',
  'AUG',
  'SEP',
  'OCT',
  'NOV',
  'DEC',
];

String _hostMeta(Club club) {
  final month = _monthAbbrevs[(club.createdAt.month - 1).clamp(0, 11)];
  final parts = <String>['HOSTING SINCE $month ${club.createdAt.year}'];
  final area = club.area.trim();
  if (area.isNotEmpty) parts.add(area.toUpperCase());
  return parts.join(' · ');
}

List<EventDetailHostStat> _hostStats(Club club) {
  final stats = <EventDetailHostStat>[];
  if (club.memberCount > 0) {
    stats.add(
      EventDetailHostStat(value: '${club.memberCount}', label: 'Members'),
    );
  }
  if (club.reviewCount > 0) {
    stats
      ..add(
        EventDetailHostStat(
          value: club.rating.toStringAsFixed(1),
          label: 'Rating',
        ),
      )
      ..add(
        EventDetailHostStat(value: '${club.reviewCount}', label: 'Reviews'),
      );
  }
  return stats;
}
