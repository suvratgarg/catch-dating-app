import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_state.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

ReviewsHistoryState buildReviewsHistoryState({
  required AppLocalizations l10n,
  required String? uid,
  required AsyncValue<UserProfile?> user,
  AsyncValue<List<Review>>? reviews,
  AsyncValue<List<Event>>? events,
}) {
  if (uid == null) {
    return ReviewsHistoryEmpty(
      title: l10n.reviewsReviewsHistoryViewModelTitleSignInToSee,
      message: l10n.reviewsReviewsHistoryViewModelMessageYourPastEventReviews,
    );
  }

  if (user case AsyncError()) {
    return ReviewsHistoryError(
      title: l10n.reviewsReviewsHistoryViewModelTitleReviewsUnavailable,
      message: l10n.reviewsReviewsHistoryViewModelMessageCouldNotLoadYour,
      retryTarget: ReviewsHistoryRetryTarget.profile,
    );
  }

  final profile = user.asData?.value;
  if (profile == null || reviews == null) {
    return const ReviewsHistoryLoading();
  }

  return reviews.when<ReviewsHistoryState>(
    loading: () => const ReviewsHistoryLoading(),
    error: (_, _) => ReviewsHistoryError(
      title: l10n.reviewsReviewsHistoryViewModelTitleReviewsUnavailable,
      message: l10n.reviewsReviewsHistoryViewModelMessageCouldNotLoadYourb38403,
      retryTarget: ReviewsHistoryRetryTarget.reviews,
    ),
    data: (reviews) {
      if (reviews.isEmpty) {
        return ReviewsHistoryEmpty(
          title: l10n.reviewsReviewsHistoryViewModelTitleNoReviewsYet,
          message: l10n.reviewsReviewsHistoryViewModelMessageAfterYouReviewA,
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
