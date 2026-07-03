import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_state.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

ReviewsHistoryState buildReviewsHistoryState({
  required String? uid,
  required AsyncValue<UserProfile?> user,
  AsyncValue<List<Review>>? reviews,
  AsyncValue<List<Event>>? events,
}) {
  if (uid == null) {
    return const ReviewsHistoryEmpty(
      title: 'Sign in to see reviews',
      message: 'Your past event reviews will appear here.',
    );
  }

  if (user case AsyncError()) {
    return const ReviewsHistoryError(
      title: 'Reviews unavailable',
      message: 'Could not load your profile.',
      retryTarget: ReviewsHistoryRetryTarget.profile,
    );
  }

  final profile = user.asData?.value;
  if (profile == null || reviews == null) {
    return const ReviewsHistoryLoading();
  }

  return reviews.when<ReviewsHistoryState>(
    loading: () => const ReviewsHistoryLoading(),
    error: (_, _) => const ReviewsHistoryError(
      title: 'Reviews unavailable',
      message: 'Could not load your reviews.',
      retryTarget: ReviewsHistoryRetryTarget.reviews,
    ),
    data: (reviews) {
      if (reviews.isEmpty) {
        return const ReviewsHistoryEmpty(
          title: 'No reviews yet',
          message: 'After you review a completed event, it will appear here.',
        );
      }

      final eventsById = <String, Event>{
        for (final event in events?.asData?.value ?? const <Event>[])
          event.id: event,
      };
      final rows = [
        for (final review in reviews)
          ReviewsHistoryRow(
            review: review,
            contextLabel: reviewHistoryContextLabel(
              review: review,
              event: review.eventId == null ? null : eventsById[review.eventId],
            ),
            editEventId: review.eventId,
          ),
      ];

      return ReviewsHistoryContent(user: profile, rows: rows);
    },
  );
}
