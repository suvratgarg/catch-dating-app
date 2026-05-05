import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/review_keys.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  testWidgets('empty attended run section can submit a review', (tester) async {
    final repository = _FakeReviewsRepository();
    final user = buildUser(uid: 'runner-1', name: 'Asha');
    final container = _reviewsContainer(repository);
    addTearDown(container.dispose);

    await _pumpReviewsSection(
      tester,
      container: container,
      user: user,
      reviews: const [],
    );

    expect(find.text('No reviews yet'), findsOneWidget);

    await tester.tap(find.byKey(ReviewKeys.writeReviewButton));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(ReviewKeys.ratingStar(4)));
    await tester.enterText(find.byType(TextField), '  Friendly crew.  ');
    await tester.tap(find.byKey(ReviewKeys.submitReviewButton));
    await tester.pumpAndSettle();

    expect(repository.addedReview?.runClubId, 'club-1');
    expect(repository.addedReview?.runId, 'run-1');
    expect(repository.addedReview?.reviewerUserId, 'runner-1');
    expect(repository.addedReview?.reviewerName, 'Asha');
    expect(repository.addedReview?.rating, 4);
    expect(repository.addedReview?.comment, 'Friendly crew.');
  });

  testWidgets('own review can be edited and deleted from the sheet', (
    tester,
  ) async {
    final repository = _FakeReviewsRepository();
    final user = buildUser(uid: 'runner-1', name: 'Asha');
    final review = buildReview(
      id: 'review-1',
      runClubId: 'club-1',
      runId: 'run-1',
      reviewerUserId: user.uid,
      reviewerName: user.name,
      comment: 'Good run.',
    );
    final container = _reviewsContainer(repository);
    addTearDown(container.dispose);

    await _pumpReviewsSection(
      tester,
      container: container,
      user: user,
      reviews: [review],
    );

    await tester.tap(find.byKey(ReviewKeys.editReviewButton('review-1')));
    await tester.pumpAndSettle();

    expect(find.text('Edit review'), findsOneWidget);
    expect(find.byKey(ReviewKeys.deleteReviewButton), findsOneWidget);

    await tester.tap(find.byKey(ReviewKeys.deleteReviewButton));
    await tester.pumpAndSettle();

    expect(find.text('Delete review?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();

    expect(repository.deletedReviewId, 'review-1');
  });
}

ProviderContainer _reviewsContainer(_FakeReviewsRepository repository) {
  return ProviderContainer(
    overrides: [reviewsRepositoryProvider.overrideWith((ref) => repository)],
  );
}

Future<void> _pumpReviewsSection(
  WidgetTester tester, {
  required ProviderContainer container,
  required UserProfile user,
  required List<Review> reviews,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: ReviewsSection(
              runClubId: 'club-1',
              runId: 'run-1',
              reviews: reviews,
              currentUid: user.uid,
              userProfile: user,
              hasAttended: true,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

class _FakeReviewsRepository extends Fake implements ReviewsRepository {
  Review? addedReview;
  String? deletedReviewId;

  @override
  Future<void> addReview(Review review) async {
    addedReview = review;
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    deletedReviewId = reviewId;
  }
}
