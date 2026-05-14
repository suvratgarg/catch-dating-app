import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/review_keys.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_screen.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';
import '../test_pump_helpers.dart';

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
    await pumpFeatureUi(tester);

    await tester.tap(find.byKey(ReviewKeys.ratingStar(4)));
    await tester.enterText(find.byType(TextField), '  Friendly crew.  ');
    await tester.tap(find.byKey(ReviewKeys.submitReviewButton));
    await pumpFeatureUi(tester);

    expect(repository.addedReview?.runClubId, 'club-1');
    expect(repository.addedReview?.runId, 'run-1');
    expect(repository.addedReview?.reviewerUserId, 'runner-1');
    expect(repository.addedReview?.reviewerName, 'Asha');
    expect(repository.addedReview?.rating, 4);
    expect(repository.addedReview?.comment, 'Friendly crew.');
  });

  testWidgets('empty reviews state is centered across the section width', (
    tester,
  ) async {
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

    final sectionCenter = tester.getCenter(find.byType(RunReviewsSection)).dx;
    final iconCenter = tester
        .getCenter(find.byIcon(Icons.rate_review_outlined))
        .dx;
    final titleCenter = tester.getCenter(find.text('No reviews yet')).dx;

    expect(iconCenter, closeTo(sectionCenter, 1));
    expect(titleCenter, closeTo(sectionCenter, 1));
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
    await pumpFeatureUi(tester);

    expect(find.text('Edit review'), findsOneWidget);
    expect(find.byKey(ReviewKeys.deleteReviewButton), findsOneWidget);

    await tester.tap(find.byKey(ReviewKeys.deleteReviewButton));
    await pumpFeatureUi(tester);

    expect(find.text('Delete review?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await pumpFeatureUi(tester);

    expect(repository.deletedReviewId, 'review-1');
  });

  testWidgets('review history lists own reviews and opens edit sheet', (
    tester,
  ) async {
    final user = buildUser(uid: 'runner-1', name: 'Asha');
    final run = buildRun(id: 'run-1', runClubId: 'club-1');
    final review = buildReview(
      id: 'run-1~runner-1',
      runClubId: 'club-1',
      runId: run.id,
      reviewerUserId: user.uid,
      reviewerName: user.name,
      comment: 'Great route.',
    );
    final repository = _FakeReviewsRepository(reviewsByUser: [review]);
    final container = ProviderContainer(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value(user.uid)),
        watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
        reviewsRepositoryProvider.overrideWith((ref) => repository),
        watchRunProvider(run.id).overrideWith((ref) => Stream.value(run)),
      ],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          theme: AppTheme.light,
          home: const ReviewsHistoryScreen(),
        ),
      ),
    );
    await pumpFeatureUi(tester);

    expect(find.text('Review history'), findsOneWidget);
    expect(find.text('Great route.'), findsOneWidget);

    await tester.tap(find.byKey(ReviewKeys.editReviewButton(review.id)));
    await pumpFeatureUi(tester);

    expect(find.text('Edit review'), findsOneWidget);
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
            child: RunReviewsSection(
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
  _FakeReviewsRepository({this.reviewsByUser = const []});

  final List<Review> reviewsByUser;
  Review? addedReview;
  String? deletedReviewId;

  @override
  Stream<List<Review>> watchReviewsByUser(String reviewerUserId) =>
      Stream.value(reviewsByUser);

  @override
  Future<void> addReview(Review review) async {
    addedReview = review;
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    deletedReviewId = reviewId;
  }
}
