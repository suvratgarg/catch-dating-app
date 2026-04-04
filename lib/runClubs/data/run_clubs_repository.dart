import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/runClubs/domain/run_club.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // FieldValue
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_clubs_repository.g.dart';

class RunClubsRepository {
  RunClubsRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<RunClub> _getCollectionReference() =>
      _db.collection('runClubs').withConverter<RunClub>(
        fromFirestore: (doc, _) => RunClub.fromJson({...doc.data()!, 'id': doc.id}),
        toFirestore: (club, _) => club.toJson(),
      );

  DocumentReference<RunClub> _getDocumentReference([String? id]) =>
      _getCollectionReference().doc(id);

  // ── Read ──────────────────────────────────────────────────────────────────

  Stream<RunClub?> watchRunClub(String id) => _getDocumentReference(id)
      .snapshots()
      .map((doc) => doc.exists ? doc.data() : null);

  Future<RunClub?> getRunClub(String id) async {
    final doc = await _getDocumentReference(id).get();
    return doc.exists ? doc.data() : null;
  }

  Stream<List<RunClub>> watchRunClubsByLocation(IndianCity location) =>
      _getCollectionReference()
          .where('location', isEqualTo: location.name)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  Stream<List<RunClub>> watchRunClubsByLocationSortedByRating(
          IndianCity location) =>
      _getCollectionReference()
          .where('location', isEqualTo: location.name)
          .orderBy('rating', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<String> createRunClub({
    required String name,
    required String description,
    required IndianCity location,
    required String hostUserId,
  }) async {
    final ref = _getDocumentReference();
    await ref.set(RunClub(
      id: ref.id,
      name: name,
      description: description,
      location: location,
      hostUserId: hostUserId,
      createdAt: DateTime.now(),
    ));
    return ref.id;
  }

  Future<void> updateRunClub({required RunClub runClub}) =>
      _getDocumentReference(runClub.id).set(runClub);

  Future<void> deleteRunClub(String id) =>
      _getDocumentReference(id).delete();

  Future<void> updateImageUrl(String id, String imageUrl) =>
      _getDocumentReference(id).update({'imageUrl': imageUrl});

  // ── Members ───────────────────────────────────────────────────────────────

  Future<void> joinClub(String clubId, String userId) =>
      _getDocumentReference(clubId).update({
        'memberUserIds': FieldValue.arrayUnion([userId]),
      });

  Future<void> leaveClub(String clubId, String userId) =>
      _getDocumentReference(clubId).update({
        'memberUserIds': FieldValue.arrayRemove([userId]),
      });
}

@riverpod
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
        Ref ref, IndianCity location) =>
    ref
        .watch(runClubsRepositoryProvider)
        .watchRunClubsByLocationSortedByRating(location);

@riverpod
Future<RunClub?> fetchRunClub(Ref ref, String id) =>
    ref.watch(runClubsRepositoryProvider).getRunClub(id);
