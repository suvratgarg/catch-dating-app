import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/firestore_error_util.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reviews_repository.g.dart';

class ReviewsRepository {
  const ReviewsRepository(this._db, this._functions);

  static const _collectionPath = 'reviews';
  static const _reviewIdSeparator = '~';

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  CollectionReference<Review> get _reviewsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<Review>(
        idField: 'id',
        fromJson: Review.fromJson,
        toJson: (review) => review.toJson(),
      );

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<List<Review>> watchReviewsForClub(String runClubId) => _reviewsRef
      .where('runClubId', isEqualTo: runClubId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()).toList());

  Stream<List<Review>> watchReviewsForRun(String runId) => _reviewsRef
      .where('runId', isEqualTo: runId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()).toList());

  Stream<List<Review>> watchReviewsByUser(String reviewerUserId) => _reviewsRef
      .where('reviewerUserId', isEqualTo: reviewerUserId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((s) => s.docs.map((d) => d.data()).toList());

  /// Watches the review this user wrote for a specific run (null if none).
  Stream<Review?> watchUserReviewForRun({
    required String runId,
    required String reviewerUserId,
  }) => _reviewRefForRunUser(
    runId: runId,
    reviewerUserId: reviewerUserId,
  ).snapshots().map((s) => s.exists ? s.data() : null);

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> addReview(Review review) {
    final runId = review.runId;
    if (runId == null || runId.isEmpty) {
      throw ArgumentError.value(
        runId,
        'review.runId',
        'Run reviews require a runId.',
      );
    }

    return withFirestoreErrorContext(
      () => _functions.httpsCallable('createRunReview').call({
        'runClubId': review.runClubId,
        'runId': runId,
        'rating': review.rating,
        'comment': review.comment,
      }),
      collection: _collectionPath,
      action: 'add review',
    );
  }

  Future<void> updateReview(Review review) => withFirestoreErrorContext(
    () => _functions.httpsCallable('updateRunReview').call({
      'reviewId': review.id,
      'rating': review.rating,
      'comment': review.comment,
    }),
    collection: _collectionPath,
    action: 'update review',
  );

  Future<void> deleteReview(String reviewId) => withFirestoreErrorContext(
    () => _functions.httpsCallable('deleteRunReview').call({
      'reviewId': reviewId,
    }),
    collection: _collectionPath,
    action: 'delete review',
  );

  DocumentReference<Review> _reviewRefForRunUser({
    required String runId,
    required String reviewerUserId,
  }) => _reviewsRef.doc(
    reviewIdForRunUser(runId: runId, reviewerUserId: reviewerUserId),
  );

  static String reviewIdForRunUser({
    required String runId,
    required String reviewerUserId,
  }) {
    if (runId.isEmpty) {
      throw ArgumentError.value(runId, 'runId', 'Run id cannot be empty.');
    }
    if (reviewerUserId.isEmpty) {
      throw ArgumentError.value(
        reviewerUserId,
        'reviewerUserId',
        'Reviewer user id cannot be empty.',
      );
    }
    if (runId.contains('/') || reviewerUserId.contains('/')) {
      throw ArgumentError.value(
        '$runId:$reviewerUserId',
        'runId/reviewerUserId',
        'Review id parts cannot contain path separators.',
      );
    }

    return '$runId$_reviewIdSeparator$reviewerUserId';
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

@riverpod
ReviewsRepository reviewsRepository(Ref ref) => ReviewsRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(firebaseFunctionsProvider),
);

@riverpod
Stream<List<Review>> watchReviewsForClub(Ref ref, String runClubId) =>
    ref.watch(reviewsRepositoryProvider).watchReviewsForClub(runClubId);

@riverpod
Stream<List<Review>> watchReviewsForRun(Ref ref, String runId) =>
    ref.watch(reviewsRepositoryProvider).watchReviewsForRun(runId);

@riverpod
Stream<List<Review>> watchReviewsByUser(Ref ref, String reviewerUserId) =>
    ref.watch(reviewsRepositoryProvider).watchReviewsByUser(reviewerUserId);

@riverpod
Stream<Review?> watchUserReviewForRun(
  Ref ref, {
  required String runId,
  required String reviewerUserId,
}) => ref
    .watch(reviewsRepositoryProvider)
    .watchUserReviewForRun(runId: runId, reviewerUserId: reviewerUserId);
