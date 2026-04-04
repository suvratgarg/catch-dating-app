import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_repository.g.dart';

class RunRepository {
  RunRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Run> _getCollectionReference() =>
      _db.collection('runs').withConverter<Run>(
        fromFirestore: (doc, _) =>
            Run.fromJson({...doc.data()!, 'id': doc.id}),
        toFirestore: (run, _) => run.toJson(),
      );

  DocumentReference<Run> _getDocumentReference(String id) =>
      _getCollectionReference().doc(id);

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<Run?> fetchRun(String id) async {
    final doc = await _getDocumentReference(id).get();
    return doc.exists ? doc.data() : null;
  }

  Stream<Run?> watchRun(String id) => _getDocumentReference(id)
      .snapshots()
      .map((doc) => doc.exists ? doc.data() : null);

  Stream<List<Run>> watchRunsForClub({required String runClubId}) =>
      _getCollectionReference()
          .where('runClubId', isEqualTo: runClubId)
          .orderBy('startTime')
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  Stream<List<Run>> watchAttendedRuns({required String uid}) =>
      _getCollectionReference()
          .where('attendedUserIds', arrayContains: uid)
          .orderBy('startTime', descending: true)
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  /// Streams upcoming runs the user has signed up for (paid / reserved a spot).
  Stream<List<Run>> watchSignedUpRuns({required String uid}) =>
      _getCollectionReference()
          .where('signedUpUserIds', arrayContains: uid)
          .orderBy('startTime')
          .snapshots()
          .map((snap) => snap.docs.map((d) => d.data()).toList());

  /// Generates a new unique Firestore document ID for a run without writing it.
  String generateId() => _getCollectionReference().doc().id;

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> createRun({required Run run}) =>
      _getDocumentReference(run.id).set(run);

  Future<void> signUpForRun({
    required String runId,
    required String userId,
  }) => _getDocumentReference(runId).update({
        'signedUpUserIds': FieldValue.arrayUnion([userId]),
      });

  Future<void> cancelSignUp({
    required String runId,
    required String userId,
    required Gender gender,
  }) => _getDocumentReference(runId).update({
        'signedUpUserIds': FieldValue.arrayRemove([userId]),
        'genderCounts.${gender.name}': FieldValue.increment(-1),
      });

  Future<void> joinWaitlist({
    required String runId,
    required String userId,
  }) => _getDocumentReference(runId).update({
        'waitlistUserIds': FieldValue.arrayUnion([userId]),
      });

  Future<void> leaveWaitlist({
    required String runId,
    required String userId,
  }) => _getDocumentReference(runId).update({
        'waitlistUserIds': FieldValue.arrayRemove([userId]),
      });
}

@riverpod
RunRepository runRepository(Ref ref) =>
    RunRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<Run>> runsForClub(Ref ref, String runClubId) =>
    ref.watch(runRepositoryProvider).watchRunsForClub(runClubId: runClubId);

@riverpod
Stream<List<Run>> attendedRuns(Ref ref, String uid) =>
    ref.watch(runRepositoryProvider).watchAttendedRuns(uid: uid);

@riverpod
Stream<List<Run>> signedUpRuns(Ref ref, String uid) =>
    ref.watch(runRepositoryProvider).watchSignedUpRuns(uid: uid);
