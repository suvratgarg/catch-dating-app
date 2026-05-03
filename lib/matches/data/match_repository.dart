import 'dart:async';

import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'match_repository.g.dart';

class MatchRepository {
  const MatchRepository(this._db);

  static const _collectionPath = 'matches';

  final FirebaseFirestore _db;

  CollectionReference<Match> get _matchesRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<Match>(
        idField: 'id',
        fromJson: Match.fromJson,
        toJson: (match) => match.toJson(),
      );

  DocumentReference<Match> _matchRef(String id) => _matchesRef.doc(id);

  // ── Read ──────────────────────────────────────────────────────────────────

  /// Streams all active matches where the given user is a participant.
  ///
  /// This intentionally uses two equality queries instead of the denormalized
  /// `participantIds` array. Firestore rules can prove `user1Id == uid` and
  /// `user2Id == uid` list queries directly, while the array query is not
  /// accepted by the rules engine for this rule shape.
  Stream<List<Match>> watchMatchesForUser({required String uid}) {
    late final StreamSubscription<List<Match>> user1Subscription;
    late final StreamSubscription<List<Match>> user2Subscription;
    List<Match>? user1Matches;
    List<Match>? user2Matches;

    return Stream.multi((controller) {
      void emitIfReady() {
        final first = user1Matches;
        final second = user2Matches;
        if (first == null || second == null) return;

        final byId = <String, Match>{};
        for (final match in [...first, ...second]) {
          byId[match.id] = match;
        }

        final matches = byId.values.toList()
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        controller.add(matches);
      }

      user1Subscription =
          _watchActiveMatchesByParticipantField(
            field: 'user1Id',
            uid: uid,
          ).listen((matches) {
            user1Matches = matches;
            emitIfReady();
          }, onError: controller.addError);
      user2Subscription =
          _watchActiveMatchesByParticipantField(
            field: 'user2Id',
            uid: uid,
          ).listen((matches) {
            user2Matches = matches;
            emitIfReady();
          }, onError: controller.addError);

      controller.onCancel = () async {
        await user1Subscription.cancel();
        await user2Subscription.cancel();
      };
    });
  }

  Stream<List<Match>> _watchActiveMatchesByParticipantField({
    required String field,
    required String uid,
  }) => _matchesRef
      .where(field, isEqualTo: uid)
      .where('status', isEqualTo: 'active')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.data()).toList());

  Stream<Match?> watchMatch({required String matchId}) => _matchRef(
    matchId,
  ).snapshots().map((doc) => doc.exists ? doc.data() : null);

  // ── Write ─────────────────────────────────────────────────────────────────

  /// Resets the unread count for [uid] in the given match to zero.
  /// Called when the user opens a chat, both on entry and exit.
  ///
  /// Only swallows [FirebaseException] with code `not-found` — the match
  /// document may not exist yet if a Cloud Function hasn't created it.
  /// All other errors (permission-denied, network, etc.) propagate.
  Future<void> resetUnread({required String matchId, required String uid}) =>
      _matchRef(matchId).update({'unreadCounts.$uid': 0}).catchError(
        (Object _) {},
        test: (Object error) =>
            error is FirebaseException && error.code == 'not-found',
      );
}

@riverpod
MatchRepository matchRepository(Ref ref) =>
    MatchRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<Match>> matchesForUser(Ref ref, String uid) =>
    ref.watch(matchRepositoryProvider).watchMatchesForUser(uid: uid).timeout(
      const Duration(seconds: 10),
    );

@riverpod
Stream<Match?> matchStream(Ref ref, String matchId) =>
    ref.watch(matchRepositoryProvider).watchMatch(matchId: matchId);

@riverpod
int totalUnreadCount(Ref ref, String uid) {
  final matches = ref.watch(matchesForUserProvider(uid)).asData?.value ?? [];
  return matches
      .where((match) => !match.isBlocked)
      .fold(0, (total, m) => total + (m.unreadCounts[uid] ?? 0));
}
