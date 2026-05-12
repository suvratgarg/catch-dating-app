import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_clubs_repository.g.dart';

class RunClubsRepository {
  const RunClubsRepository(this._db, this._functions);

  static const _collectionPath = 'runClubs';

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  CollectionReference<RunClub> get _runClubsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<RunClub>(
        idField: 'id',
        fromJson: RunClub.fromJson,
        toJson: (club) => club.toJson(),
      );

  DocumentReference<RunClub> _runClubRef([String? id]) => _runClubsRef.doc(id);

  // ── Read ───────────────────────────────────────────────────────────────────

  Stream<RunClub?> watchRunClub(String id) => withBackendErrorStream(
    () => _runClubRef(
      id,
    ).snapshots().map((doc) => doc.exists ? doc.data() : null),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch club',
      resource: _collectionPath,
    ),
  );

  Future<RunClub?> fetchRunClub(String id) => withBackendErrorContext(
    () async {
      final doc = await _runClubRef(id).get();
      return doc.exists ? doc.data() : null;
    },
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'fetch club',
      resource: _collectionPath,
    ),
  );

  Stream<List<RunClub>> watchRunClubsByLocation(String location) =>
      withBackendErrorStream(
        () => _runClubsRef
            .where('location', isEqualTo: location)
            .orderBy('createdAt', descending: true)
            .snapshots()
            .map((snap) => snap.docs.map((d) => d.data()).toList()),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch clubs by location',
          resource: _collectionPath,
        ),
      );

  Stream<List<RunClub>> watchRunClubsByLocationSortedByRating(
    String location,
  ) => withBackendErrorStream(
    () => _runClubsRef
        .where('location', isEqualTo: location)
        .orderBy('rating', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch clubs by rating',
      resource: _collectionPath,
    ),
  );

  Stream<List<RunClub>> watchRunClubsHostedBy(String uid) =>
      withBackendErrorStream(
        () => _runClubsRef
            .where('hostUserId', isEqualTo: uid)
            .snapshots()
            .map((snap) => snap.docs.map((d) => d.data()).toList()),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch hosted clubs',
          resource: _collectionPath,
        ),
      );

  // ── Write ──────────────────────────────────────────────────────────────────

  String generateId() => _runClubRef().id;

  Future<String> createRunClub({
    String? clubId,
    required String name,
    required String description,
    required String location,
    required String area,
    String? imageUrl,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
  }) => withBackendErrorContext(
    () async {
      final data = <String, dynamic>{
        'name': name,
        'description': description,
        'location': location,
        'area': area,
        'imageUrl': imageUrl,
        'instagramHandle': instagramHandle,
        'phoneNumber': phoneNumber,
        'email': email,
      };
      if (clubId != null) {
        data['clubId'] = clubId;
      }
      final result = await _functions
          .httpsCallable('createRunClub')
          .call<Map<String, dynamic>>(data);
      return result.data['clubId'] as String;
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'create club',
      resource: _collectionPath,
    ),
  );

  /// Updates only the fields present in [fields] via the `updateRunClub`
  /// callable.
  Future<void> updateRunClub({
    required String clubId,
    required Map<String, dynamic> fields,
  }) => withBackendErrorContext(
    () => _functions.httpsCallable('updateRunClub').call({
      'clubId': clubId,
      'fields': fields,
    }),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'update club',
      resource: _collectionPath,
    ),
  );

  // ── Members ────────────────────────────────────────────────────────────────

  /// Adds the signed-in user to [clubId] via the `joinRunClub` callable.
  ///
  /// Membership touches both `runClubs/{clubId}` and `users/{uid}`, so the
  /// server owns this mutation and Firestore rules can keep membership fields
  /// read-only to direct client writes.
  Future<void> joinClub(String clubId) => withBackendErrorContext(
    () => _functions.httpsCallable('joinRunClub').call({'clubId': clubId}),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'join club',
      resource: _collectionPath,
    ),
  );

  /// Removes the signed-in user from [clubId] via the `leaveRunClub` callable.
  Future<void> leaveClub(String clubId) => withBackendErrorContext(
    () => _functions.httpsCallable('leaveRunClub').call({'clubId': clubId}),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'leave club',
      resource: _collectionPath,
    ),
  );

  /// Updates the signed-in user's per-club push notification opt-in.
  Future<void> setClubPushNotifications({
    required String clubId,
    required bool enabled,
  }) => withBackendErrorContext(
    () => _functions.httpsCallable('setRunClubNotificationPreference').call({
      'clubId': clubId,
      'enabled': enabled,
    }),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'update club notifications',
      resource: _collectionPath,
    ),
  );
}

@Riverpod(keepAlive: true)
RunClubsRepository runClubsRepository(Ref ref) => RunClubsRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(firebaseFunctionsProvider),
);

@riverpod
Stream<RunClub?> watchRunClub(Ref ref, String id) {
  final repository = ref.watch(runClubsRepositoryProvider);
  return repository.watchRunClub(id);
}

@riverpod
Stream<List<RunClub>> watchRunClubsByLocation(Ref ref, String location) {
  final repository = ref.watch(runClubsRepositoryProvider);
  return repository.watchRunClubsByLocation(location);
}

@riverpod
Stream<List<RunClub>> watchRunClubsByLocationSortedByRating(
  Ref ref,
  String location,
) {
  final repository = ref.watch(runClubsRepositoryProvider);
  return repository.watchRunClubsByLocationSortedByRating(location);
}

@riverpod
Stream<List<RunClub>> watchRunClubsHostedBy(Ref ref, String uid) {
  final repository = ref.watch(runClubsRepositoryProvider);
  return repository.watchRunClubsHostedBy(uid);
}

@riverpod
Future<RunClub?> fetchRunClub(Ref ref, String id) =>
    ref.watch(runClubsRepositoryProvider).fetchRunClub(id);
