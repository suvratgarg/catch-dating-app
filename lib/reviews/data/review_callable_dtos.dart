import 'package:catch_dating_app/reviews/domain/review.dart';

final class CreateEventReviewCallableRequest {
  const CreateEventReviewCallableRequest({
    required this.clubId,
    required this.eventId,
    required this.rating,
    required this.comment,
  });

  factory CreateEventReviewCallableRequest.fromReview(
    Review review, {
    required String eventId,
  }) => CreateEventReviewCallableRequest(
    clubId: review.clubId,
    eventId: eventId,
    rating: review.rating,
    comment: review.comment,
  );

  final String clubId;
  final String eventId;
  final int rating;
  final String comment;

  Map<String, Object?> toJson() => {
    'clubId': clubId,
    'eventId': eventId,
    'rating': rating,
    'comment': comment,
  };
}

final class UpdateEventReviewCallableRequest {
  const UpdateEventReviewCallableRequest({
    required this.reviewId,
    required this.rating,
    required this.comment,
  });

  factory UpdateEventReviewCallableRequest.fromReview(Review review) =>
      UpdateEventReviewCallableRequest(
        reviewId: review.id,
        rating: review.rating,
        comment: review.comment,
      );

  final String reviewId;
  final int rating;
  final String comment;

  Map<String, Object?> toJson() => {
    'reviewId': reviewId,
    'rating': rating,
    'comment': comment,
  };
}

final class ReviewIdCallableRequest {
  const ReviewIdCallableRequest(this.reviewId);

  final String reviewId;

  Map<String, Object?> toJson() => {'reviewId': reviewId};
}
