import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
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
  title: 'No more runners',
  message: 'Join more runs to meet new people',
  icon: Icons.directions_run_rounded,
);

SwipeEmptyContent buildSwipeEmptyContent({
  required Run? run,
  required AppUser? currentUser,
}) {
  if (run == null) {
    return const SwipeEmptyContent(
      title: 'Catch unavailable',
      message: 'This run could not be found.',
      icon: Icons.search_off_rounded,
    );
  }

  if (currentUser == null) {
    return const SwipeEmptyContent(
      title: 'Sign in required',
      message: 'Sign in again to swipe on fellow runners.',
      icon: Icons.lock_outline_rounded,
    );
  }

  if (!run.hasAttended(currentUser.uid)) {
    return const SwipeEmptyContent(
      title: 'Catch unavailable',
      message: 'You can only swipe on runners from events you attended.',
      icon: Icons.verified_user_outlined,
    );
  }

  if (run.isUpcoming) {
    return const SwipeEmptyContent(
      title: 'Run in progress',
      message: 'Swiping unlocks for 24 hours after the run finishes.',
      icon: Icons.schedule_rounded,
    );
  }

  if (!hasOpenSwipeWindow(run)) {
    return const SwipeEmptyContent(
      title: 'Swipe window closed',
      message: 'This run is past the 24-hour catch window.',
      icon: Icons.hourglass_disabled_rounded,
    );
  }

  return defaultSwipeEmptyContent;
}
