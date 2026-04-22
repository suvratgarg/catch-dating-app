import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'swipe_repository.g.dart';

class SwipeRepository {
  const SwipeRepository(this._db);

  static const _collectionPath = 'swipes';

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _outgoingSwipesRef(String uid) =>
      _db.collection(_collectionPath).doc(uid).collection('outgoing');

  Future<void> recordSwipe({required Swipe swipe}) =>
      _outgoingSwipesRef(swipe.swiperId).doc(swipe.targetId).set({
        'swiperId': swipe.swiperId,
        'targetId': swipe.targetId,
        'runId': swipe.runId,
        'direction': swipe.direction.name,
        'createdAt': FieldValue.serverTimestamp(),
      });

  /// Returns the set of user IDs this user has already swiped on.
  Future<Set<String>> fetchSwipedUserIds({required String uid}) async {
    final snap = await _outgoingSwipesRef(uid).get();
    return snap.docs.map((d) => d.id).toSet();
  }
}

@Riverpod(keepAlive: true)
SwipeRepository swipeRepository(Ref ref) =>
    SwipeRepository(ref.watch(firebaseFirestoreProvider));
