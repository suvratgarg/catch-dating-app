import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
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

  /// Fetches upcoming runs from the given club IDs (max 10 clubs, limit 10 runs).
  Future<List<Run>> fetchUpcomingRunsForClubs(List<String> runClubIds) async {
    if (runClubIds.isEmpty) return [];
    final now = Timestamp.now();
    final snap = await _getCollectionReference()
        .where('runClubId', whereIn: runClubIds.take(10).toList())
        .where('startTime', isGreaterThan: now)
        .orderBy('startTime')
        .limit(10)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> createRun({required Run run}) =>
      _getDocumentReference(run.id).set(run);

  Future<void> signUpForRun({
    required String runId,
    required String userId,
  }) => _getDocumentReference(runId).update({
        'signedUpUserIds': FieldValue.arrayUnion([userId]),
      });

  /// Cancels the current user's sign-up via the [cancelRunSignUp] Cloud
  /// Function, which atomically removes them from [signedUpUserIds] and
  /// decrements their gender count.
  Future<void> cancelSignUpViaFunction({required String runId}) =>
      FirebaseFunctions.instance
          .httpsCallable('cancelRunSignUp')
          .call({'runId': runId});

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

  /// Marks all signed-up users as attended via the [markRunAttendance] Cloud
  /// Function. Only callable by the run club's host.
  Future<void> markAttendance({required String runId}) =>
      FirebaseFunctions.instance
          .httpsCallable('markRunAttendance')
          .call({'runId': runId});
}

@riverpod
RunRepository runRepository(Ref ref) =>
    RunRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<Run?> watchRun(Ref ref, String runId) =>
    ref.watch(runRepositoryProvider).watchRun(runId);

@riverpod
Stream<List<Run>> runsForClub(Ref ref, String runClubId) =>
    ref.watch(runRepositoryProvider).watchRunsForClub(runClubId: runClubId);

@riverpod
Stream<List<Run>> attendedRuns(Ref ref, String uid) =>
    ref.watch(runRepositoryProvider).watchAttendedRuns(uid: uid);

@riverpod
Stream<List<Run>> signedUpRuns(Ref ref, String uid) =>
    ref.watch(runRepositoryProvider).watchSignedUpRuns(uid: uid);

/// Returns upcoming runs from clubs the user follows (based on [followedClubIds]).
@riverpod
Future<List<Run>> recommendedRuns(Ref ref, List<String> followedClubIds) =>
    ref.watch(runRepositoryProvider).fetchUpcomingRunsForClubs(followedClubIds);
