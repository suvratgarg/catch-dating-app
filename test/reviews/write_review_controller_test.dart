import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/write_review_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  test('submit creates a trimmed run review', () async {
    final repository = _FakeReviewsRepository();
    final container = _reviewsContainer(repository);
    addTearDown(container.dispose);

    await container
        .read(writeReviewControllerProvider.notifier)
        .submit(
          runClubId: 'club-1',
          runId: 'run-1',
          reviewerUserId: 'runner-1',
          reviewerName: 'Runner One',
          rating: 4,
          comment: '  Great hosts.  ',
        );

    expect(repository.addedReview?.runClubId, 'club-1');
    expect(repository.addedReview?.runId, 'run-1');
    expect(repository.addedReview?.rating, 4);
    expect(repository.addedReview?.comment, 'Great hosts.');
  });

  test('submit updates an existing review', () async {
    final repository = _FakeReviewsRepository();
    final container = _reviewsContainer(repository);
    addTearDown(container.dispose);
    final existing = buildReview(id: 'review-1', comment: 'Old');

    await container
        .read(writeReviewControllerProvider.notifier)
        .submit(
          runClubId: existing.runClubId,
          runId: existing.runId!,
          reviewerUserId: existing.reviewerUserId,
          reviewerName: existing.reviewerName,
          rating: 5,
          comment: '  Updated  ',
          existingReview: existing,
        );

    expect(repository.updatedReview?.id, 'review-1');
    expect(repository.updatedReview?.rating, 5);
    expect(repository.updatedReview?.comment, 'Updated');
  });

  test('submit rejects invalid ratings', () async {
    final container = _reviewsContainer(_FakeReviewsRepository());
    addTearDown(container.dispose);

    await expectLater(
      container
          .read(writeReviewControllerProvider.notifier)
          .submit(
            runClubId: 'club-1',
            runId: 'run-1',
            reviewerUserId: 'runner-1',
            reviewerName: 'Runner One',
            rating: 0,
            comment: '',
          ),
      throwsArgumentError,
    );
  });

  test('delete delegates to repository', () async {
    final repository = _FakeReviewsRepository();
    final container = _reviewsContainer(repository);
    addTearDown(container.dispose);

    await container
        .read(writeReviewControllerProvider.notifier)
        .delete('review-1');

    expect(repository.deletedReviewId, 'review-1');
  });
}

ProviderContainer _reviewsContainer(_FakeReviewsRepository repository) {
  final container = ProviderContainer(
    overrides: [reviewsRepositoryProvider.overrideWith((ref) => repository)],
  );
  WriteReviewController.submitMutation.reset(container);
  WriteReviewController.deleteMutation.reset(container);
  return container;
}

class _FakeReviewsRepository extends Fake implements ReviewsRepository {
  Review? addedReview;
  Review? updatedReview;
  String? deletedReviewId;

  @override
  Future<void> addReview(Review review) async {
    addedReview = review;
  }

  @override
  Future<void> updateReview(Review review) async {
    updatedReview = review;
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    deletedReviewId = reviewId;
  }
}
