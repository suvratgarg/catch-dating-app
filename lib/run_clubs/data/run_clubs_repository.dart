import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/indian_city.dart';
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

  // -- Read ---------------------------------------------------------------

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

  // -- Write --------------------------------------------------------------

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
  }) async {
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
  }

  Future<void> updateRunClub({required RunClub runClub}) =>
      _runClubRef(runClub.id).set(runClub);

  Future<void> deleteRunClub(String id) => _runClubRef(id).delete();

  Future<void> updateImageUrl(String id, String imageUrl) =>
      _runClubRef(id).update({'imageUrl': imageUrl});

  // -- Members ------------------------------------------------------------

  Future<void> joinClub(String clubId, String userId) =>
      _db.runTransaction((transaction) async {
        final clubRef = _runClubRef(clubId);
        final userRef = _userRef(userId);
        final clubSnapshot = await transaction.get(clubRef);
        final runClub = clubSnapshot.data();

        if (!clubSnapshot.exists || runClub == null) {
          throw StateError('Run club \$clubId not found.');
        }

        transaction.set(clubRef, runClub.addMember(userId));
        transaction.set(userRef, {
          'joinedRunClubIds': FieldValue.arrayUnion([clubId]),
        }, SetOptions(merge: true));
      });

  Future<void> leaveClub(String clubId, String userId) =>
      _db.runTransaction((transaction) async {
        final clubRef = _runClubRef(clubId);
        final userRef = _userRef(userId);
        final clubSnapshot = await transaction.get(clubRef);
        final runClub = clubSnapshot.data();

        if (!clubSnapshot.exists || runClub == null) {
          throw StateError('Run club \$clubId not found.');
        }

        transaction.set(clubRef, runClub.removeMember(userId));
        transaction.set(userRef, {
          'joinedRunClubIds': FieldValue.arrayRemove([clubId]),
        }, SetOptions(merge: true));
      });
}

@Riverpod(keepAlive: true)
RunClubsRepository runClubsRepository(Ref ref) =>
    RunClubsRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<RunClub?> watchRunClub(Ref ref, String id) =>
    ref.watch(runClubsRepositoryProvider).watchRunClub(id);

@riverpod
Stream<List<RunClub>> watchRunClubsByLocation(Ref ref, IndianCity location) =>
    ref.watch(runClubsRepositoryProvider).watchRunClubsByLocation(location);

@riverpod
Stream<List<RunClub>> watchRunClubsByLocationSortedByRating(
  Ref ref,
  IndianCity location,
) => ref
    .watch(runClubsRepositoryProvider)
    .watchRunClubsByLocationSortedByRating(location);

@riverpod
Future<RunClub?> fetchRunClub(Ref ref, String id) =>
    ref.watch(runClubsRepositoryProvider).fetchRunClub(id);
