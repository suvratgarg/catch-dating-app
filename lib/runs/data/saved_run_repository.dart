import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/runs/domain/saved_run.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'saved_run_repository.g.dart';

class SavedRunRepository {
  const SavedRunRepository(this._db);

  static const _collectionPath = 'savedRuns';

  final FirebaseFirestore _db;

  CollectionReference<SavedRun> get _savedRunsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<SavedRun>(
        idField: 'id',
        fromJson: SavedRun.fromJson,
        toJson: (savedRun) => savedRun.toJson(),
      );

  DocumentReference<Map<String, dynamic>> _rawSavedRunRef({
    required String uid,
    required String runId,
  }) => _db.collection(_collectionPath).doc(savedRunId(uid: uid, runId: runId));

  Stream<List<SavedRun>> watchSavedRunsForUser({required String uid}) =>
      withBackendErrorStream(
        () => _savedRunsRef
            .where('uid', isEqualTo: uid)
            .snapshots()
            .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'watch saved runs',
          resource: _collectionPath,
        ),
      );

  Stream<SavedRun?> watchSavedRun({
    required String uid,
    required String runId,
  }) => withBackendErrorStream(
    () => _savedRunsRef
        .doc(savedRunId(uid: uid, runId: runId))
        .snapshots()
        .map((snap) => snap.data()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch saved run',
      resource: _collectionPath,
    ),
  );

  Future<void> saveRun({required String uid, required String runId}) =>
      withBackendErrorContext(
        () => _rawSavedRunRef(uid: uid, runId: runId).set({
          'uid': uid,
          'runId': runId,
          'savedAt': FieldValue.serverTimestamp(),
        }),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'save run',
          resource: _collectionPath,
        ),
      );

  Future<void> unsaveRun({required String uid, required String runId}) =>
      withBackendErrorContext(
        () => _rawSavedRunRef(uid: uid, runId: runId).delete(),
        context: const BackendErrorContext(
          service: BackendService.firestore,
          action: 'unsave run',
          resource: _collectionPath,
        ),
      );
}

@Riverpod(keepAlive: true)
SavedRunRepository savedRunRepository(Ref ref) =>
    SavedRunRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<SavedRun>> watchSavedRunsForUser(Ref ref, String uid) =>
    ref.watch(savedRunRepositoryProvider).watchSavedRunsForUser(uid: uid);

@riverpod
Stream<SavedRun?> watchSavedRun(Ref ref, String uid, String runId) =>
    ref.watch(savedRunRepositoryProvider).watchSavedRun(uid: uid, runId: runId);
