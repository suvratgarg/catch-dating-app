import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_repository.g.dart';

class SwipeRepository {
  SwipeRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _getOutgoingCollection(
          String uid) =>
      _db.collection('swipes').doc(uid).collection('outgoing');

  Future<void> recordSwipe({required Swipe swipe}) =>
      _getOutgoingCollection(swipe.swiperId).doc(swipe.targetId).set({
        'swiperId': swipe.swiperId,
        'targetId': swipe.targetId,
        'runId': swipe.runId,
        'direction': swipe.direction.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

  /// Returns the set of user IDs this user has already swiped on.
  Future<Set<String>> fetchSwipedUserIds({required String uid}) async {
    final snap = await _getOutgoingCollection(uid).get();
    return snap.docs.map((d) => d.id).toSet();
  }
}

@riverpod
SwipeRepository swipeRepository(Ref ref) =>
    SwipeRepository(ref.watch(firebaseFirestoreProvider));
