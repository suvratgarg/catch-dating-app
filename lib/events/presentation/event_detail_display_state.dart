import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/foundation.dart';

enum EventDetailCompanionStatus { hidden, loading, available, error }

@immutable
class EventDetailCompanionState {
  const EventDetailCompanionState._({required this.status, this.error});

  const EventDetailCompanionState.hidden()
    : this._(status: EventDetailCompanionStatus.hidden);

  const EventDetailCompanionState.loading()
    : this._(status: EventDetailCompanionStatus.loading);

  const EventDetailCompanionState.available()
    : this._(status: EventDetailCompanionStatus.available);

  const EventDetailCompanionState.error(Object error)
    : this._(status: EventDetailCompanionStatus.error, error: error);

  final EventDetailCompanionStatus status;
  final Object? error;
}

/// One value/label data pair in an Event Detail host stat strip.
///
/// [value] and [label] are pre-formatted; the host card renders [label]
/// uppercased mono.
@immutable
class EventDetailHostStat {
  const EventDetailHostStat({required this.value, required this.label});

  final String value;
  final String label;
}

enum EventDetailHostStatus { hidden, loading, content, error }

@immutable
class EventDetailHostState {
  const EventDetailHostState._({
    required this.status,
    this.error,
    this.clubId,
    this.hostUid,
    this.hostName,
    this.photoUrl,
    this.meta,
    this.verified = false,
    this.stats = const <EventDetailHostStat>[],
    this.canMessage = false,
  });

  const EventDetailHostState.hidden()
    : this._(status: EventDetailHostStatus.hidden);

  const EventDetailHostState.loading()
    : this._(status: EventDetailHostStatus.loading);

  const EventDetailHostState.error(Object error)
    : this._(status: EventDetailHostStatus.error, error: error);

  const EventDetailHostState.content({
    required String clubId,
    required String hostName,
    String? hostUid,
    String? photoUrl,
    String? meta,
    bool verified = false,
    List<EventDetailHostStat> stats = const <EventDetailHostStat>[],
    bool canMessage = false,
  }) : this._(
         status: EventDetailHostStatus.content,
         clubId: clubId,
         hostUid: hostUid,
         hostName: hostName,
         photoUrl: photoUrl,
         meta: meta,
         verified: verified,
         stats: stats,
         canMessage: canMessage,
       );

  final EventDetailHostStatus status;
  final Object? error;
  final String? clubId;
  final String? hostUid;
  final String? hostName;
  final String? photoUrl;
  final String? meta;
  final bool verified;
  final List<EventDetailHostStat> stats;
  final bool canMessage;
}

@immutable
class EventDetailSectionVisibilityState {
  const EventDetailSectionVisibilityState({
    required this.showConsumerActions,
    required this.renderSocialAsHost,
    required this.showInviteLoop,
    required this.showBottomNavigation,
  });

  final bool showConsumerActions;
  final bool renderSocialAsHost;
  final bool showInviteLoop;
  final bool showBottomNavigation;
}

EventDetailSectionVisibilityState eventDetailSectionVisibilityStateFrom({
  required Event event,
  required EventParticipation? participation,
  required bool isHostApp,
  required bool isHost,
  required DateTime now,
}) {
  final showConsumerActions = !isHostApp && !isHost;
  return EventDetailSectionVisibilityState(
    showConsumerActions: showConsumerActions,
    renderSocialAsHost: isHostApp || isHost,
    showInviteLoop: eventDetailCanShowInviteLoop(
      event: event,
      participation: participation,
      showConsumerActions: showConsumerActions,
      now: now,
    ),
    showBottomNavigation: !isHostApp,
  );
}

bool eventDetailCanShowInviteLoop({
  required Event event,
  required EventParticipation? participation,
  required bool showConsumerActions,
  required DateTime now,
}) {
  if (!showConsumerActions ||
      event.isCancelled ||
      !event.startTime.isAfter(now)) {
    return false;
  }
  return participation?.status == EventParticipationStatus.signedUp;
}

@immutable
class EventDetailSocialState {
  const EventDetailSocialState({
    required this.showMemberContext,
    required this.renderAsHost,
    required this.hasReviewAccess,
  });

  final bool showMemberContext;
  final bool renderAsHost;
  final bool hasReviewAccess;
}

EventDetailSocialState eventDetailSocialStateFrom({
  required Event event,
  required UserProfile? userProfile,
  required bool isAuthenticated,
  required bool renderAsHost,
  required EventParticipation? participation,
  required DateTime now,
}) {
  final reviewAccessStarted = !event.endTime.isAfter(now);
  return EventDetailSocialState(
    showMemberContext: isAuthenticated && userProfile != null,
    renderAsHost: renderAsHost,
    hasReviewAccess:
        participation?.status == EventParticipationStatus.attended &&
        reviewAccessStarted,
  );
}
