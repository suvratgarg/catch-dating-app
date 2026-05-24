import 'package:catch_dating_app/reviews/domain/review.dart';

// Re-export generated callable request classes for reviews.
export 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show DeleteEventReviewCallableRequest;

// Hand-written DTOs below carry domain → DTO adapter factories that the
// generator cannot derive from JSON Schema. They are still validated against
// the corresponding schemas by test/core/callable_dto_contracts_test.dart.

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
