import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ReviewsRepository', () {
    late FakeFirebaseFirestore firestore;
    late ReviewsRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = ReviewsRepository(firestore);
    });

    test('reviewIdForRunUser is deterministic and path-safe', () {
      expect(
        ReviewsRepository.reviewIdForRunUser(
          runId: 'run-1',
          reviewerUserId: 'runner-1',
        ),
        'run-1~runner-1',
      );

      expect(
        () => ReviewsRepository.reviewIdForRunUser(
          runId: '',
          reviewerUserId: 'runner-1',
        ),
        throwsArgumentError,
      );
      expect(
        () => ReviewsRepository.reviewIdForRunUser(
          runId: 'run-1',
          reviewerUserId: 'runner/1',
        ),
        throwsArgumentError,
      );
    });

    test(
      'addReview writes one deterministic review document per run user',
      () async {
        final review = _review(runId: 'run-1', reviewerUserId: 'runner-1');

        await repository.addReview(review);

        final stored = await firestore
            .collection('reviews')
            .doc('run-1~runner-1')
            .get();
        expect(stored.exists, isTrue);
        expect(stored.data(), isNot(contains('id')));
        expect(stored.data()?['runId'], 'run-1');
        expect(stored.data()?['reviewerUserId'], 'runner-1');

        await expectLater(
          repository.watchUserReviewForRun(
            runId: 'run-1',
            reviewerUserId: 'runner-1',
          ),
          emits(
            isA<Review>()
                .having((r) => r.id, 'id', 'run-1~runner-1')
                .having((r) => r.runId, 'runId', 'run-1')
                .having((r) => r.reviewerUserId, 'reviewerUserId', 'runner-1'),
          ),
        );
      },
    );

    test(
      'watchUserReviewForRun emits null when the deterministic doc is absent',
      () async {
        await expectLater(
          repository.watchUserReviewForRun(
            runId: 'run-missing',
            reviewerUserId: 'runner-1',
          ),
          emits(isNull),
        );
      },
    );

    test('addReview rejects reviews without a runId', () async {
      expect(
        () => repository.addReview(_review(runId: null)),
        throwsArgumentError,
      );
    });
  });
}

Review _review({
  String runClubId = 'club-1',
  String? runId = 'run-1',
  String reviewerUserId = 'runner-1',
}) {
  return Review(
    id: '',
    runClubId: runClubId,
    runId: runId,
    reviewerUserId: reviewerUserId,
    reviewerName: 'Runner One',
    rating: 5,
    comment: 'Great run.',
    createdAt: DateTime.utc(2026, 5),
  );
}
