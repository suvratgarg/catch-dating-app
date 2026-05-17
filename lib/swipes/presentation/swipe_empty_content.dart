import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

class SwipeEmptyContent {
  const SwipeEmptyContent({
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;
}

const defaultSwipeEmptyContent = SwipeEmptyContent(
  title: 'No more attendees',
  message: 'Join more events to meet new people',
  icon: Icons.directions_run_rounded,
);

SwipeEmptyContent buildSwipeEmptyContent({
  required Event? event,
  required UserProfile? currentUser,
  required EventParticipation? currentUserParticipation,
}) {
  if (event == null) {
    return const SwipeEmptyContent(
      title: 'Catch unavailable',
      message: 'This event could not be found.',
      icon: Icons.search_off_rounded,
    );
  }

  if (currentUser == null) {
    return const SwipeEmptyContent(
      title: 'Sign in required',
      message: 'Sign in again to swipe on fellow attendees.',
      icon: Icons.lock_outline_rounded,
    );
  }

  if (currentUserParticipation?.status != EventParticipationStatus.attended) {
    return const SwipeEmptyContent(
      title: 'Catch unavailable',
      message: 'You can only swipe on attendees from events you attended.',
      icon: Icons.verified_user_outlined,
    );
  }

  if (event.isUpcoming) {
    return const SwipeEmptyContent(
      title: 'Event in progress',
      message: 'Swiping unlocks for 24 hours after the event finishes.',
      icon: Icons.schedule_rounded,
    );
  }

  if (!hasOpenSwipeWindow(event)) {
    return const SwipeEmptyContent(
      title: 'Swipe window closed',
      message: 'This event is past the 24-hour catch window.',
      icon: Icons.hourglass_disabled_rounded,
    );
  }

  return defaultSwipeEmptyContent;
}
