import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

class TestFirebaseFunctions extends Fake implements FirebaseFunctions {
  final callables = <String, TestHttpsCallable>{};

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return callables.putIfAbsent(name, () => TestHttpsCallable(name));
  }
}

class TestHttpsCallable extends Fake implements HttpsCallable {
  TestHttpsCallable(this.name);

  final String name;
  final calls = <Object?>[];

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    calls.add(parameters);
    return TestHttpsCallableResult<T>(null as T);
  }
}

class TestHttpsCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  TestHttpsCallableResult(this.dataValue);

  final T dataValue;

  @override
  T get data => dataValue;
}

void main() {
  group('ReviewsRepository', () {
    late FakeFirebaseFirestore firestore;
    late TestFirebaseFunctions functions;
    late ReviewsRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      functions = TestFirebaseFunctions();
      repository = ReviewsRepository(firestore, functions);
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

    test('addReview delegates deterministic run reviews to callable', () async {
      final review = _review(runId: 'run-1', reviewerUserId: 'runner-1');

      await repository.addReview(review);

      final callable = functions.httpsCallable('createRunReview')
          as TestHttpsCallable;
      expect(callable.calls, [
        {
          'runClubId': 'club-1',
          'runId': 'run-1',
          'rating': 5,
          'comment': 'Great run.',
        },
      ]);
    });

    test('updateReview and deleteReview delegate to callables', () async {
      await repository.updateReview(
        _review(runId: 'run-1').copyWith(id: 'run-1~runner-1', rating: 4),
      );
      await repository.deleteReview('run-1~runner-1');

      final updateCallable = functions.httpsCallable('updateRunReview')
          as TestHttpsCallable;
      final deleteCallable = functions.httpsCallable('deleteRunReview')
          as TestHttpsCallable;
      expect(updateCallable.calls, [
        {
          'reviewId': 'run-1~runner-1',
          'rating': 4,
          'comment': 'Great run.',
        },
      ]);
      expect(deleteCallable.calls, [
        {'reviewId': 'run-1~runner-1'},
      ]);
    });

    test('watchUserReviewForRun emits the deterministic review doc', () async {
      await firestore.collection('reviews').doc('run-1~runner-1').set({
        'runClubId': 'club-1',
        'runId': 'run-1',
        'reviewerUserId': 'runner-1',
        'reviewerName': 'Runner One',
        'rating': 5,
        'comment': 'Great run.',
        'createdAt': DateTime.utc(2026, 5),
      });

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
    });

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
