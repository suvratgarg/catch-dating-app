import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'write_review_controller.g.dart';

@riverpod
class WriteReviewController extends _$WriteReviewController {
  static final submitMutation = Mutation<void>();
  static final deleteMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> submit({
    required String runClubId,
    String? runId,
    required String reviewerUserId,
    required String reviewerName,
    required int rating,
    required String comment,
    Review? existingReview,
  }) async {
    final repo = ref.read(reviewsRepositoryProvider);
    if (existingReview != null) {
      await repo.updateReview(
        existingReview.copyWith(rating: rating, comment: comment),
      );
    } else {
      await repo.addReview(
        Review(
          id: '',
          runClubId: runClubId,
          runId: runId,
          reviewerUserId: reviewerUserId,
          reviewerName: reviewerName,
          rating: rating,
          comment: comment,
          createdAt: DateTime.now(),
        ),
      );
    }
  }

  Future<void> delete(String reviewId) async {
    await ref.read(reviewsRepositoryProvider).deleteReview(reviewId);
  }
}
