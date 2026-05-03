import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/firestore_error_util.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reviews_repository.g.dart';

class ReviewsRepository {
  const ReviewsRepository(this._db);

  static const _collectionPath = 'reviews';

  final FirebaseFirestore _db;

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
  }) => _reviewsRef
      .where('runId', isEqualTo: runId)
      .where('reviewerUserId', isEqualTo: reviewerUserId)
      .limit(1)
      .snapshots()
      .map((s) => s.docs.isNotEmpty ? s.docs.first.data() : null);

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> addReview(Review review) => withFirestoreErrorContext(
    () {
      final ref = _reviewsRef.doc(); // auto-generated ID
      return ref.set(review.copyWith(id: ref.id));
    },
    collection: _collectionPath,
    action: 'add review',
  );

  Future<void> updateReview(Review review) => withFirestoreErrorContext(
    () => _reviewsRef.doc(review.id).update({
      'rating': review.rating,
      'comment': review.comment,
      'updatedAt': FieldValue.serverTimestamp(),
    }),
    collection: _collectionPath,
    action: 'update review',
  );

  Future<void> deleteReview(String reviewId) => withFirestoreErrorContext(
    () => _reviewsRef.doc(reviewId).delete(),
    collection: _collectionPath,
    action: 'delete review',
  );
}

// ── Providers ─────────────────────────────────────────────────────────────────

@riverpod
ReviewsRepository reviewsRepository(Ref ref) =>
    ReviewsRepository(ref.watch(firebaseFirestoreProvider));

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
    .watchUserReviewForRun(
      runId: runId,
      reviewerUserId: reviewerUserId,
    );
