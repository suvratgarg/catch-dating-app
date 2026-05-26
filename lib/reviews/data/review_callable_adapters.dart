import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show CreateEventReviewCallableRequest, UpdateEventReviewCallableRequest;
import 'package:catch_dating_app/reviews/domain/review.dart';

CreateEventReviewCallableRequest createEventReviewCallableRequestFromReview(
  Review review, {
  required String eventId,
}) => CreateEventReviewCallableRequest(
  clubId: review.clubId,
  eventId: eventId,
  rating: review.rating,
  comment: review.comment,
);

UpdateEventReviewCallableRequest updateEventReviewCallableRequestFromReview(
  Review review,
) => UpdateEventReviewCallableRequest(
  reviewId: review.id,
  rating: review.rating,
  comment: review.comment,
);
