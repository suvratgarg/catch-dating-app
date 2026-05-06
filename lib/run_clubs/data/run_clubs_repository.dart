import 'dart:async';

import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/firestore_error_util.dart';
import 'package:catch_dating_app/core/indian_city.dart';
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

  Stream<RunClub?> watchRunClub(String id) =>
      _runClubRef(id).snapshots().map((doc) => doc.exists ? doc.data() : null);

  Future<RunClub?> fetchRunClub(String id) async {
    final doc = await _runClubRef(id).get();
    return doc.exists ? doc.data() : null;
  }

  Stream<List<RunClub>> watchRunClubsByLocation(IndianCity location) =>
      _runClubsRef
          .where('location', isEqualTo: location.name)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  Stream<List<RunClub>> watchRunClubsByLocationSortedByRating(
    IndianCity location,
  ) => _runClubsRef
      .where('location', isEqualTo: location.name)
      .orderBy('rating', descending: true)
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.data()).toList());

  Stream<List<RunClub>> watchRunClubsHostedBy(String uid) => _runClubsRef
      .where('hostUserId', isEqualTo: uid)
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.data()).toList());

  // ── Write ──────────────────────────────────────────────────────────────────

  String generateId() => _runClubRef().id;

  Future<String> createRunClub({
    String? clubId,
    required String name,
    required String description,
    required IndianCity location,
    required String area,
    String? imageUrl,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
  }) => withFirestoreErrorContext(
    () async {
      final data = <String, dynamic>{
        'name': name,
        'description': description,
        'location': location.name,
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
    collection: _collectionPath,
    action: 'create club',
  );

  /// Updates only the fields present in [fields] on the club document.
  ///
  /// Uses [DocumentReference.update] so only the supplied keys are touched —
  /// other fields (notably `createdAt`) are never deserialized, avoiding the
  /// Timestamp → DateTime → Timestamp round-trip that would lose nanosecond
  /// precision and trip the Firestore rules `isValidRunClubHostUpdate` diff
  /// check.
  Future<void> updateRunClub({
    required String clubId,
    required Map<String, dynamic> fields,
  }) => withFirestoreErrorContext(
    () => _runClubRef(clubId).update(fields),
    collection: _collectionPath,
    action: 'update club',
  );

  // ── Members ────────────────────────────────────────────────────────────────

  /// Adds the signed-in user to [clubId] via the `joinRunClub` callable.
  ///
  /// Membership touches both `runClubs/{clubId}` and `users/{uid}`, so the
  /// server owns this mutation and Firestore rules can keep membership fields
  /// read-only to direct client writes.
  Future<void> joinClub(String clubId) => withFirestoreErrorContext(
    () => _functions.httpsCallable('joinRunClub').call({'clubId': clubId}),
    collection: _collectionPath,
    action: 'join',
  );

  /// Removes the signed-in user from [clubId] via the `leaveRunClub` callable.
  Future<void> leaveClub(String clubId) => withFirestoreErrorContext(
    () => _functions.httpsCallable('leaveRunClub').call({'clubId': clubId}),
    collection: _collectionPath,
    action: 'leave',
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
Stream<List<RunClub>> watchRunClubsByLocation(Ref ref, IndianCity location) {
  final repository = ref.watch(runClubsRepositoryProvider);
  return repository.watchRunClubsByLocation(location);
}

@riverpod
Stream<List<RunClub>> watchRunClubsByLocationSortedByRating(
  Ref ref,
  IndianCity location,
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
