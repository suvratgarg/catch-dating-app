import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
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

  CollectionReference<Run> get _runsRef => _db
      .collection('runs')
      .withDocumentIdConverter<Run>(
        idField: 'id',
        fromJson: Run.fromJson,
        toJson: (run) => run.toJson(),
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

  Stream<List<Run>> watchSavedRunDetailsForUser({required String uid}) {
    StreamSubscription<QuerySnapshot<SavedRun>>? savedRunSub;
    var runSubs = <StreamSubscription<QuerySnapshot<Run>>>[];
    var generation = 0;
    var closed = false;

    late final StreamController<List<Run>> controller;

    void cancelRunSubscriptions() {
      for (final sub in runSubs) {
        unawaited(sub.cancel());
      }
      runSubs = [];
    }

    void emitSortedRuns({
      required List<String> runIds,
      required Map<int, List<Run>> runsByChunk,
      required int chunkCount,
    }) {
      if (runsByChunk.length < chunkCount || controller.isClosed) return;

      final byId = <String, Run>{};
      for (final runs in runsByChunk.values) {
        for (final run in runs) {
          byId[run.id] = run;
        }
      }

      final runs = [
        for (final id in runIds)
          if (byId[id] != null) byId[id]!,
      ]..sort((a, b) => a.startTime.compareTo(b.startTime));
      controller.add(runs);
    }

    controller = StreamController<List<Run>>(
      onListen: () {
        savedRunSub = _savedRunsRef
            .where('uid', isEqualTo: uid)
            .snapshots()
            .listen((snap) {
              generation += 1;
              final localGeneration = generation;
              cancelRunSubscriptions();

              final runIds = snap.docs
                  .map((doc) => doc.data().runId)
                  .toSet()
                  .toList();
              if (runIds.isEmpty) {
                if (!controller.isClosed) controller.add(const []);
                return;
              }

              final chunks = _chunks(runIds, 10).toList(growable: false);
              final runsByChunk = <int, List<Run>>{};

              for (var i = 0; i < chunks.length; i += 1) {
                final chunk = chunks[i];
                final sub = _runsRef
                    .where(FieldPath.documentId, whereIn: chunk)
                    .snapshots()
                    .listen((runSnap) {
                      if (closed || localGeneration != generation) return;
                      runsByChunk[i] = runSnap.docs
                          .map((doc) => doc.data())
                          .toList();
                      emitSortedRuns(
                        runIds: runIds,
                        runsByChunk: runsByChunk,
                        chunkCount: chunks.length,
                      );
                    }, onError: controller.addError);
                runSubs.add(sub);
              }
            }, onError: controller.addError);
      },
      onCancel: () async {
        closed = true;
        cancelRunSubscriptions();
        await savedRunSub?.cancel();
        if (!controller.isClosed) {
          await controller.close();
        }
      },
    );

    return withBackendErrorStream(
      () => controller.stream,
      context: const BackendErrorContext(
        service: BackendService.firestore,
        action: 'watch saved run details',
        resource: 'runs',
      ),
    );
  }

  Stream<SavedRun?> watchSavedRun({
    required String uid,
    required String runId,
  }) => withBackendErrorStream(
    () => _savedRunsRef
        .where('uid', isEqualTo: uid)
        .where('runId', isEqualTo: runId)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : snap.docs.first.data()),
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

@riverpod
Stream<List<Run>> watchSavedRunDetailsForUser(Ref ref, String uid) =>
    ref.watch(savedRunRepositoryProvider).watchSavedRunDetailsForUser(uid: uid);

Iterable<List<T>> _chunks<T>(List<T> values, int size) sync* {
  for (var start = 0; start < values.length; start += size) {
    final end = start + size > values.length ? values.length : start + size;
    yield values.sublist(start, end);
  }
}
