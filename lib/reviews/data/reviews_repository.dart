import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/reviews/domain/review_document_id.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reviews_repository.g.dart';

class ReviewsRepository {
  const ReviewsRepository(this._db);

  static const _collectionPath = 'reviews';

  final FirebaseFirestore _db;

  CollectionReference<Review> get _reviewsRef => _db
      .collection(_collectionPath)
      .withConverter<Review>(
        fromFirestore: (doc, _) =>
            Review.fromJson({...doc.data()!, 'id': doc.id}),
        toFirestore: (review, _) => review.toJson(),
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

  /// Watches the single review this user wrote for a club (null if none).
  Stream<Review?> watchUserReviewForClub({
    required String runClubId,
    required String reviewerUserId,
  }) {
    final docId = reviewDocumentId(
      runClubId: runClubId,
      reviewerUserId: reviewerUserId,
    );
    return _reviewsRef
        .doc(docId)
        .snapshots()
        .map((snap) => snap.exists ? snap.data() : null);
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> addReview(Review review) {
    final ref = _reviewsRef.doc(
      reviewDocumentId(
        runClubId: review.runClubId,
        reviewerUserId: review.reviewerUserId,
      ),
    );
    return ref.set(review.copyWith(id: ref.id));
  }

  Future<void> updateReview(Review review) =>
      _reviewsRef.doc(review.id).update({
        'rating': review.rating,
        'comment': review.comment,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteReview(String reviewId) =>
      _reviewsRef.doc(reviewId).delete();
}

// ── Providers ─────────────────────────────────────────────────────────────────

@Riverpod(keepAlive: true)
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
Stream<Review?> watchUserReviewForClub(
  Ref ref, {
  required String runClubId,
  required String reviewerUserId,
}) => ref
    .watch(reviewsRepositoryProvider)
    .watchUserReviewForClub(
      runClubId: runClubId,
      reviewerUserId: reviewerUserId,
    );
