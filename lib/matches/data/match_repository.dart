import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'match_repository.g.dart';

class MatchRepository {
  MatchRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Match> _getCollectionReference() =>
      _db.collection('matches').withConverter<Match>(
        fromFirestore: (doc, _) =>
            Match.fromJson({...doc.data()!, 'id': doc.id}),
        toFirestore: (match, _) => match.toJson(),
      );

  DocumentReference<Match> _getDocumentReference(String id) =>
      _getCollectionReference().doc(id);

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Streams all matches where the given user is a participant.
  /// Relies on the Cloud Function writing a `participantIds` array field.
  Stream<List<Match>> watchMatchesForUser({required String uid}) =>
      _getCollectionReference()
          .where('participantIds', arrayContains: uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Resets the unread count for [uid] in the given match to zero.
  /// Called when the user opens a chat, both on entry and exit.
  Future<void> resetUnread({
    required String matchId,
    required String uid,
  }) =>
      _getDocumentReference(matchId)
          .update({'unreadCounts.$uid': 0})
          // Silently ignore errors (e.g., match document not yet created)
          .catchError((_) {});
}

@riverpod
MatchRepository matchRepository(Ref ref) =>
    MatchRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<Match>> matchesForUser(Ref ref, String uid) =>
    ref.watch(matchRepositoryProvider).watchMatchesForUser(uid: uid);

@riverpod
int totalUnreadCount(Ref ref, String uid) {
  final matches =
      ref.watch(matchesForUserProvider(uid)).asData?.value ?? [];
  return matches.fold(
    0,
    (total, m) => total + (m.unreadCounts[uid] ?? 0),
  );
}
