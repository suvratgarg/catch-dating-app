import 'dart:async';

import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/firestore_error_util.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // FieldValue
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_clubs_repository.g.dart';

class RunClubsRepository {
  const RunClubsRepository(this._db);

  static const _collectionPath = 'runClubs';
  static const _usersCollectionPath = 'users';

  final FirebaseFirestore _db;

  CollectionReference<RunClub> get _runClubsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<RunClub>(
        idField: 'id',
        fromJson: RunClub.fromJson,
        toJson: (club) => club.toJson(),
      );

  DocumentReference<RunClub> _runClubRef([String? id]) => _runClubsRef.doc(id);

  DocumentReference<Map<String, dynamic>> _userRef(String uid) =>
      _db.collection(_usersCollectionPath).doc(uid);

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

  // ── Write ──────────────────────────────────────────────────────────────────

  String generateId() => _runClubRef().id;

  Future<String> createRunClub({
    String? clubId,
    required String name,
    required String description,
    required IndianCity location,
    required String area,
    required String hostUserId,
    required String hostName,
    String? hostAvatarUrl,
    String? imageUrl,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
  }) => withFirestoreErrorContext(
    () async {
      final ref = _runClubRef(clubId);
      final batch = _db.batch();

      batch.set(
        ref,
        RunClub(
          id: ref.id,
          name: name,
          description: description,
          location: location,
          area: area,
          hostUserId: hostUserId,
          hostName: hostName,
          hostAvatarUrl: hostAvatarUrl,
          createdAt: DateTime.now(),
          imageUrl: imageUrl,
          memberUserIds: [hostUserId],
          memberCount: 1,
          instagramHandle: instagramHandle,
          phoneNumber: phoneNumber,
          email: email,
        ),
      );
      batch.set(_userRef(hostUserId), {
        'joinedRunClubIds': FieldValue.arrayUnion([ref.id]),
      }, SetOptions(merge: true));

      await batch.commit();
      return ref.id;
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

  Future<void> deleteRunClub(String id) => withFirestoreErrorContext(
    () => _runClubRef(id).delete(),
    collection: _collectionPath,
    action: 'delete club',
  );

  // ── Members ────────────────────────────────────────────────────────────────

  /// Adds [userId] to [clubId]'s member list.
  ///
  /// Uses [FieldValue] operations inside a transaction so only
  /// `memberUserIds` and `memberCount` are touched — other fields
  /// (notably `createdAt`) are never deserialized, avoiding a
  /// Timestamp → DateTime → Timestamp round-trip that would lose
  /// nanosecond precision and trip the Firestore rules diff check.
  Future<void> joinClub(String clubId, String userId) =>
      withFirestoreErrorContext(
        () => _db.runTransaction((transaction) async {
          final clubRef = _runClubRef(clubId);
          final userRef = _userRef(userId);
          final clubSnapshot = await transaction.get(clubRef);

          if (!clubSnapshot.exists) {
            throw DocumentNotFoundException('runClubs/$clubId');
          }

          transaction.update(clubRef, {
            'memberUserIds': FieldValue.arrayUnion([userId]),
            'memberCount': FieldValue.increment(1),
          });
          transaction.set(userRef, {
            'joinedRunClubIds': FieldValue.arrayUnion([clubId]),
          }, SetOptions(merge: true));
        }),
        collection: _collectionPath,
        action: 'join',
      );

  Future<void> leaveClub(String clubId, String userId) =>
      withFirestoreErrorContext(
        () => _db.runTransaction((transaction) async {
          final clubRef = _runClubRef(clubId);
          final userRef = _userRef(userId);
          final clubSnapshot = await transaction.get(clubRef);

          if (!clubSnapshot.exists) {
            throw DocumentNotFoundException('runClubs/$clubId');
          }

          transaction.update(clubRef, {
            'memberUserIds': FieldValue.arrayRemove([userId]),
            'memberCount': FieldValue.increment(-1),
          });
          transaction.set(userRef, {
            'joinedRunClubIds': FieldValue.arrayRemove([clubId]),
          }, SetOptions(merge: true));
        }),
        collection: _collectionPath,
        action: 'leave',
      );
}

@riverpod
RunClubsRepository runClubsRepository(Ref ref) =>
    RunClubsRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<RunClub?> watchRunClub(Ref ref, String id) =>
    ref.watch(runClubsRepositoryProvider).watchRunClub(id).timeout(
      const Duration(seconds: 10),
    );

@riverpod
Stream<List<RunClub>> watchRunClubsByLocation(Ref ref, IndianCity location) =>
    ref.watch(runClubsRepositoryProvider).watchRunClubsByLocation(location).timeout(
      const Duration(seconds: 10),
    );

@riverpod
Stream<List<RunClub>> watchRunClubsByLocationSortedByRating(
  Ref ref,
  IndianCity location,
) => ref
    .watch(runClubsRepositoryProvider)
    .watchRunClubsByLocationSortedByRating(location)
    .timeout(const Duration(seconds: 10));

@riverpod
Future<RunClub?> fetchRunClub(Ref ref, String id) =>
    ref.watch(runClubsRepositoryProvider).fetchRunClub(id);
