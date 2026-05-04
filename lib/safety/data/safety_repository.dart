import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_error_util.dart';
import 'package:catch_dating_app/safety/domain/blocked_user.dart';
export 'package:catch_dating_app/safety/domain/blocked_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'safety_repository.g.dart';

class SafetyRepository {
  const SafetyRepository(this._db, this._functions, this._auth);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<List<BlockedUser>> watchBlockedUsers({required String uid}) => _db
      .collection('blocks')
      .where('blockerUserId', isEqualTo: uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snap) => snap.docs
            .map((doc) => BlockedUser.fromFirestore(doc.data()))
            .toList(),
      );

  Future<Set<String>> fetchBlockedUserIds({required String uid}) async {
    final outgoing = await _db
        .collection('blocks')
        .where('blockerUserId', isEqualTo: uid)
        .get();
    final incoming = await _db
        .collection('blocks')
        .where('blockedUserId', isEqualTo: uid)
        .get();

    return {
      ...outgoing.docs.map((doc) => doc.data()['blockedUserId'] as String),
      ...incoming.docs.map((doc) => doc.data()['blockerUserId'] as String),
    };
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> blockUser({
    required String targetUserId,
    String source = 'profile',
  }) => withFirestoreErrorContext(
    () => _functions.httpsCallable('blockUser').call({
      'targetUserId': targetUserId,
      'source': source,
    }),
    collection: 'blocks',
    action: 'block user',
  );

  Future<void> unblockUser({required String targetUserId}) =>
      withFirestoreErrorContext(
        () => _functions
            .httpsCallable('unblockUser')
            .call({'targetUserId': targetUserId}),
        collection: 'blocks',
        action: 'unblock user',
      );

  Future<void> reportUser({
    required String targetUserId,
    String source = 'profile',
    String? reasonCode,
    String? contextId,
    String? notes,
  }) => withFirestoreErrorContext(
    () => _functions.httpsCallable('reportUser').call({
      'targetUserId': targetUserId,
      'source': source,
      'reasonCode': ?reasonCode,
      'contextId': ?contextId,
      'notes': ?notes,
    }),
    collection: 'reports',
    action: 'report user',
  );

  Future<void> requestAccountDeletion() => withFirestoreErrorContext(
    () async {
      await _functions.httpsCallable('requestAccountDeletion').call<void>();
      await _auth.signOut();
    },
    collection: 'users',
    action: 'request account deletion',
  );
}

@riverpod
SafetyRepository safetyRepository(Ref ref) => SafetyRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(firebaseFunctionsProvider),
  ref.watch(firebaseAuthProvider),
);

@riverpod
Stream<List<BlockedUser>> watchBlockedUsers(Ref ref) {
  final uid = ref.watch(uidProvider).asData?.value;
  if (uid == null) return const Stream.empty();
  return ref.watch(safetyRepositoryProvider).watchBlockedUsers(uid: uid);
}
