import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/presentation/review_keys.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_history_screen.dart';
import 'package:catch_dating_app/reviews/presentation/reviews_section.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';
import '../test_pump_helpers.dart';

void main() {
  testWidgets('empty attended event section can submit a review', (
    tester,
  ) async {
    final repository = _FakeReviewsRepository();
    final user = buildUser(name: 'Asha');
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

    expect(repository.addedReview?.clubId, 'club-1');
    expect(repository.addedReview?.eventId, 'event-1');
    expect(repository.addedReview?.reviewerUserId, 'runner-1');
    expect(repository.addedReview?.reviewerName, 'Asha');
    expect(repository.addedReview?.rating, 4);
    expect(repository.addedReview?.comment, 'Friendly crew.');
  });

  testWidgets('empty event reviews state uses compact inline layout', (
    tester,
  ) async {
    final repository = _FakeReviewsRepository();
    final user = buildUser(name: 'Asha');
    final container = _reviewsContainer(repository);
    addTearDown(container.dispose);

    await _pumpReviewsSection(
      tester,
      container: container,
      user: user,
      reviews: const [],
    );

    final iconRight = tester
        .getTopRight(find.byIcon(CatchIcons.rateReviewOutlined))
        .dx;
    final titleLeft = tester.getTopLeft(find.text('No reviews yet')).dx;

    expect(titleLeft, greaterThan(iconRight));
    expect(
      find.text('Reviews appear after attendees complete the event.'),
      findsOneWidget,
    );
  });

  testWidgets('own review can be edited and deleted from the sheet', (
    tester,
  ) async {
    final repository = _FakeReviewsRepository();
    final user = buildUser(name: 'Asha');
    final review = buildReview(
      reviewerUserId: user.uid,
      reviewerName: user.name,
      comment: 'Good event.',
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

  testWidgets('review cards display host responses', (tester) async {
    final repository = _FakeReviewsRepository();
    final user = buildUser(name: 'Asha');
    final review = buildReview(
      comment: 'Loved the pacing.',
      ownerResponse: ReviewOwnerResponse(
        hostUserId: 'host-1',
        hostName: 'Afterfly',
        message: 'Thanks for joining us.',
        createdAt: DateTime(2026, 6),
        updatedAt: DateTime(2026, 6),
      ),
    );
    final container = _reviewsContainer(repository);
    addTearDown(container.dispose);

    await _pumpReviewsSection(
      tester,
      container: container,
      user: user,
      reviews: [review],
    );

    expect(find.text('Host response · Afterfly'), findsOneWidget);
    expect(find.text('Thanks for joining us.'), findsOneWidget);
  });

  testWidgets('hosts can respond to event reviews', (tester) async {
    final repository = _FakeReviewsRepository();
    final user = buildUser(uid: 'host-1', name: 'Host');
    final review = buildReview(
      id: 'event-1~runner-1',
      reviewerName: 'Runner',
      comment: 'Loved the route.',
    );
    final container = _reviewsContainer(repository);
    addTearDown(container.dispose);

    await _pumpReviewsSection(
      tester,
      container: container,
      user: user,
      reviews: [review],
      isHost: true,
    );

    expect(find.byKey(ReviewKeys.writeReviewButton), findsNothing);

    await tester.tap(find.byKey(ReviewKeys.respondToReviewButton(review.id)));
    await pumpFeatureUi(tester);

    await tester.enterText(
      find.descendant(
        of: find.byKey(ReviewKeys.ownerResponseField),
        matching: find.byType(TextField),
      ),
      '  Thanks for coming.  ',
    );
    await pumpFeatureUi(tester);
    await tester.tap(find.byKey(ReviewKeys.submitOwnerResponseButton));
    await pumpFeatureUi(tester);

    expect(repository.responseReviewId, 'event-1~runner-1');
    expect(repository.responseMessage, 'Thanks for coming.');
  });

  testWidgets('review history lists own reviews and opens edit sheet', (
    tester,
  ) async {
    final user = buildUser(name: 'Asha');
    final event = buildEvent();
    final review = buildReview(
      id: 'event-1~runner-1',
      eventId: event.id,
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
        watchEventProvider(event.id).overrideWith((ref) => Stream.value(event)),
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
  bool isHost = false,
}) async {
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: EventReviewsSection(
              clubId: 'club-1',
              eventId: 'event-1',
              reviews: reviews,
              currentUid: user.uid,
              userProfile: user,
              isHost: isHost,
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
  String? responseReviewId;
  String? responseMessage;

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

  @override
  Future<void> setReviewResponse({
    required String reviewId,
    required String message,
  }) async {
    responseReviewId = reviewId;
    responseMessage = message;
  }
}
