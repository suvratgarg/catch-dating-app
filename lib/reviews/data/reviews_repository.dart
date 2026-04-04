import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'reviews_repository.g.dart';

class ReviewsRepository {
  ReviewsRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Review> get _reviewsRef =>
      _db.collection('reviews').withConverter<Review>(
        fromFirestore: (doc, _) => Review.fromJson({...doc.data()!, 'id': doc.id}),
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

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> addReview(Review review) async {
    final reviewRef = _reviewsRef.doc();
    final clubRef = _db.collection('runClubs').doc(review.runClubId);

    await _db.runTransaction((tx) async {
      final clubSnap = await tx.get(clubRef);
      final currentRating =
          (clubSnap.data()?['rating'] as num?)?.toDouble() ?? 0.0;
      final reviewCount =
          (clubSnap.data()?['reviewCount'] as int?) ?? 0;

      final newCount = reviewCount + 1;
      final newRating =
          (currentRating * reviewCount + review.rating) / newCount;

      tx.set(reviewRef, review.copyWith(id: reviewRef.id));
      tx.update(clubRef, {
        'rating': newRating,
        'reviewCount': newCount,
      });
    });
  }

  Future<void> updateReview(Review review) async {
    final reviewRef = _reviewsRef.doc(review.id);
    final clubRef = _db.collection('runClubs').doc(review.runClubId);

    await _db.runTransaction((tx) async {
      final oldSnap = await tx.get(reviewRef);
      final oldRating = oldSnap.data()?.rating ?? review.rating;

      final clubSnap = await tx.get(clubRef);
      final currentRating =
          (clubSnap.data()?['rating'] as num?)?.toDouble() ?? 0.0;
      final reviewCount =
          (clubSnap.data()?['reviewCount'] as int?) ?? 1;

      final newRating = reviewCount <= 1
          ? review.rating.toDouble()
          : (currentRating * reviewCount - oldRating + review.rating) /
              reviewCount;

      tx.update(reviewRef, {
        'rating': review.rating,
        'comment': review.comment,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
      tx.update(clubRef, {'rating': newRating});
    });
  }
}

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
