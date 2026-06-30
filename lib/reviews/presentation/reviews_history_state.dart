import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

sealed class ReviewsHistoryState {
  const ReviewsHistoryState();

  factory ReviewsHistoryState.fromAsync({
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
                event: review.eventId == null
                    ? null
                    : eventsById[review.eventId],
              ),
              editEventId: review.eventId,
            ),
        ];

        return ReviewsHistoryContent(user: profile, rows: rows);
      },
    );
  }

  static List<String> eventIdsFor(Iterable<Review> reviews) {
    final eventIds = <String>{
      for (final review in reviews)
        if (review.eventId != null) review.eventId!,
    };
    return List.unmodifiable(eventIds.toList()..sort());
  }
}

final class ReviewsHistoryLoading extends ReviewsHistoryState {
  const ReviewsHistoryLoading();
}

final class ReviewsHistoryEmpty extends ReviewsHistoryState {
  const ReviewsHistoryEmpty({required this.title, required this.message});

  final String title;
  final String message;
}

enum ReviewsHistoryRetryTarget { profile, reviews }

final class ReviewsHistoryError extends ReviewsHistoryState {
  const ReviewsHistoryError({
    required this.title,
    required this.message,
    required this.retryTarget,
  });

  final String title;
  final String message;
  final ReviewsHistoryRetryTarget retryTarget;
}

final class ReviewsHistoryContent extends ReviewsHistoryState {
  const ReviewsHistoryContent({required this.user, required this.rows});

  final UserProfile user;
  final List<ReviewsHistoryRow> rows;
}

final class ReviewsHistoryRow {
  const ReviewsHistoryRow({
    required this.review,
    required this.contextLabel,
    required this.editEventId,
  });

  final Review review;
  final String contextLabel;
  final String? editEventId;

  bool get canEdit => editEventId != null;
}

String reviewHistoryContextLabel({required Review review, Event? event}) {
  if (event != null) {
    return '${event.longDateLabel} · ${event.timeRangeLabel}';
  }
  if (review.eventId != null) return 'Event review';
  return 'Legacy club review';
}
