import 'dart:async';

import 'package:catch_dating_app/clubs/data/club_callable_dtos.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'clubs_repository.g.dart';

class ClubsRepository {
  const ClubsRepository(this._db, this._functions);

  static const _collectionPath = 'clubs';
  static const discoveryLimit = 30;

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  CollectionReference<Club> get _clubsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<Club>(
        idField: 'id',
        fromJson: Club.fromJson,
        toJson: (club) => club.toJson(),
      );

  DocumentReference<Club> _clubRef([String? id]) => _clubsRef.doc(id);

  // ── Read ───────────────────────────────────────────────────────────────────

  Stream<Club?> watchClub(String id) => withBackendErrorStream(
    () => _clubRef(id).snapshots().map((doc) => doc.exists ? doc.data() : null),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch club',
      resource: _collectionPath,
    ),
  );

  Future<Club?> fetchClub(String id) => withBackendErrorContext(
    () async {
      final doc = await _clubRef(id).get();
      return doc.exists ? doc.data() : null;
    },
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'fetch club',
      resource: _collectionPath,
    ),
  );

  Stream<List<Club>> watchClubsByLocation(String location) =>
      withBackendErrorStream(
        () => _clubsRef
            .where('location', isEqualTo: location)
            .orderBy('createdAt', descending: true)
            .limit(discoveryLimit)
            .snapshots()
            .map((snap) => snap.docs.map((d) => d.data()).toList()),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch clubs by location',
          resource: _collectionPath,
        ),
      );

  Stream<List<Club>> watchClubsByLocationSortedByRating(String location) =>
      withBackendErrorStream(
        () => _clubsRef
            .where('location', isEqualTo: location)
            .orderBy('rating', descending: true)
            .limit(discoveryLimit)
            .snapshots()
            .map((snap) => snap.docs.map((d) => d.data()).toList()),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch clubs by rating',
          resource: _collectionPath,
        ),
      );

  Stream<List<Club>> watchClubsHostedBy(String uid) => withBackendErrorStream(
    () => _clubsRef
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

  String generateId() => _clubRef().id;

  Future<String> createClub({
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
      final result = await _functions
          .httpsCallable('createClub')
          .call<Object?>(
            CreateClubCallableRequest(
              clubId: clubId,
              name: name,
              description: description,
              location: location,
              area: area,
              imageUrl: imageUrl,
              instagramHandle: instagramHandle,
              phoneNumber: phoneNumber,
              email: email,
            ).toJson(),
          );
      return CreateClubCallableResponse.fromCallableData(result.data).clubId;
    },
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'create club',
      resource: _collectionPath,
    ),
  );

  /// Updates only the fields present in [fields] via the `updateClub`
  /// callable.
  Future<void> updateClub({
    required String clubId,
    required Map<String, dynamic> fields,
  }) => withBackendErrorContext(
    () => _functions
        .httpsCallable('updateClub')
        .call(
          UpdateClubCallableRequest(clubId: clubId, fields: fields).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'update club',
      resource: _collectionPath,
    ),
  );

  // ── Members ────────────────────────────────────────────────────────────────

  /// Adds the signed-in user to [clubId] via the `joinClub` callable.
  ///
  /// Membership touches both `clubs/{clubId}` and `users/{uid}`, so the
  /// server owns this mutation and Firestore rules can keep membership fields
  /// read-only to direct client writes.
  Future<void> joinClub(String clubId) => withBackendErrorContext(
    () => _functions
        .httpsCallable('joinClub')
        .call(ClubIdCallableRequest(clubId).toJson()),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'join club',
      resource: _collectionPath,
    ),
  );

  /// Removes the signed-in user from [clubId] via the `leaveClub` callable.
  Future<void> leaveClub(String clubId) => withBackendErrorContext(
    () => _functions
        .httpsCallable('leaveClub')
        .call(ClubIdCallableRequest(clubId).toJson()),
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
    () => _functions
        .httpsCallable('setClubNotificationPreference')
        .call(
          SetClubNotificationPreferenceCallableRequest(
            clubId: clubId,
            enabled: enabled,
          ).toJson(),
        ),
    context: const BackendErrorContext(
      service: BackendService.functions,
      action: 'update club notifications',
      resource: _collectionPath,
    ),
  );
}

@Riverpod(keepAlive: true)
ClubsRepository clubsRepository(Ref ref) => ClubsRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(firebaseFunctionsProvider),
);

@riverpod
Stream<Club?> watchClub(Ref ref, String id) {
  final repository = ref.watch(clubsRepositoryProvider);
  return repository.watchClub(id);
}

@riverpod
Stream<List<Club>> watchClubsByLocation(Ref ref, String location) {
  final repository = ref.watch(clubsRepositoryProvider);
  return repository.watchClubsByLocation(location);
}

@riverpod
Stream<List<Club>> watchClubsByLocationSortedByRating(
  Ref ref,
  String location,
) {
  final repository = ref.watch(clubsRepositoryProvider);
  return repository.watchClubsByLocationSortedByRating(location);
}

@riverpod
Stream<List<Club>> watchClubsHostedBy(Ref ref, String uid) {
  final repository = ref.watch(clubsRepositoryProvider);
  return repository.watchClubsHostedBy(uid);
}

@riverpod
Future<Club?> fetchClub(Ref ref, String id) =>
    ref.watch(clubsRepositoryProvider).fetchClub(id);
