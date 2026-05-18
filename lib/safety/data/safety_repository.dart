import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/safety/data/safety_callable_dtos.dart';
import 'package:catch_dating_app/safety/domain/blocked_user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

export 'package:catch_dating_app/safety/domain/blocked_user.dart';

part 'safety_repository.g.dart';

class SafetyRepository {
  const SafetyRepository(this._db, this._functions, this._auth);

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;
  final FirebaseAuth _auth;

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<List<BlockedUser>> watchBlockedUsers({required String uid}) =>
      withBackendErrorStream(
        () => _db
            .collection('blocks')
            .where('blockerUserId', isEqualTo: uid)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map(
              (snap) => snap.docs
                  .map((doc) => BlockedUser.fromFirestore(doc.data()))
                  .toList(),
            ),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch blocked users',
          resource: 'blocks',
        ),
      );

  Future<Set<String>> fetchBlockedUserIds({
    required String uid,
  }) => withBackendErrorContext(
    () async {
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
    },
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'fetch blocked users',
      resource: 'blocks',
    ),
  );

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> blockUser({
    required String targetUserId,
    String source = 'profile',
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('blockUser')
        .call(
          BlockUserCallableRequest(
            targetUserId: targetUserId,
            source: source,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'block user',
      resource: 'blocks',
    ),
  );

  Future<void> unblockUser({required String targetUserId}) =>
      withBackendErrorContext(
        () => _functions
            .httpsCallable('unblockUser')
            .call(
              UnblockUserCallableRequest(targetUserId: targetUserId).toJson(),
            ),
        context: const BackendErrorContext(
          service: BackendService.functions,
          action: 'unblock user',
          resource: 'blocks',
        ),
      );

  Future<void> reportUser({
    required String targetUserId,
    String source = 'profile',
    String? reasonCode,
    String? contextId,
    String? notes,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('reportUser')
        .call(
          ReportUserCallableRequest(
            targetUserId: targetUserId,
            source: source,
            reasonCode: reasonCode,
            contextId: contextId,
            notes: notes,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'report user',
      resource: 'reports',
    ),
  );

  Future<void> requestAccountDeletion() => withBackendErrorContext(
    () async {
      await _functions.httpsCallable('requestAccountDeletion').call<void>();
      await _auth.signOut();
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'request account deletion',
      resource: 'users',
    ),
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
