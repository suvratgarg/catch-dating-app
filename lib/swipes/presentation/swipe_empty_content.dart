import 'package:catch_dating_app/core/theme/catch_icons.dart';
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

final defaultSwipeEmptyContent = SwipeEmptyContent(
  title: 'No more attendees',
  message: 'Join more events to meet new people',
  icon: CatchIcons.directionsRunRounded,
);

SwipeEmptyContent buildSwipeEmptyContent({
  required Event? event,
  required UserProfile? currentUser,
  required EventParticipation? currentUserParticipation,
}) {
  if (event == null) {
    return SwipeEmptyContent(
      title: 'Catch unavailable',
      message: 'This event could not be found.',
      icon: CatchIcons.searchOffRounded,
    );
  }

  if (currentUser == null) {
    return SwipeEmptyContent(
      title: 'Sign in required',
      message: 'Sign in again to catch fellow attendees.',
      icon: CatchIcons.lockOutlineRounded,
    );
  }

  if (currentUserParticipation?.status != EventParticipationStatus.attended) {
    return SwipeEmptyContent(
      title: 'Catch unavailable',
      message: 'You can only catch attendees from events you attended.',
      icon: CatchIcons.verifiedUserOutlined,
    );
  }

  if (event.isUpcoming) {
    return SwipeEmptyContent(
      title: 'Event in progress',
      message: 'Catches unlock for 24 hours after the event finishes.',
      icon: CatchIcons.scheduleRounded,
    );
  }

  if (!hasOpenSwipeWindow(event)) {
    return SwipeEmptyContent(
      title: 'Catch window closed',
      message: 'This event is past the 24-hour catch window.',
      icon: CatchIcons.hourglassDisabledRounded,
    );
  }

  return defaultSwipeEmptyContent;
}
