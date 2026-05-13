import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/domain/run_participation_roster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_participation_repository.g.dart';

class RunParticipationRepository {
  const RunParticipationRepository(this._db);

  static const _collectionPath = 'runParticipations';
  static const _rosterVisibleStatuses = ['signedUp', 'waitlisted', 'attended'];

  final FirebaseFirestore _db;

  CollectionReference<RunParticipation> get _participationsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<RunParticipation>(
        idField: 'id',
        fromJson: RunParticipation.fromJson,
        toJson: (participation) => participation.toJson(),
      );

  Stream<List<RunParticipation>> watchParticipationsForUser({
    required String uid,
  }) => withBackendErrorStream(
    () => _participationsRef
        .where('uid', isEqualTo: uid)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch user participations',
      resource: _collectionPath,
    ),
  );

  Stream<List<RunParticipation>> watchParticipationsForRun({
    required String runId,
  }) => withBackendErrorStream(
    () => _participationsRef
        .where('runId', isEqualTo: runId)
        .where('status', whereIn: _rosterVisibleStatuses)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => doc.data()).toList()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch run participations',
      resource: _collectionPath,
    ),
  );

  Future<List<RunParticipation>> fetchParticipationsForRun({
    required String runId,
  }) => withBackendErrorContext(
    () async {
      final snap = await _participationsRef
          .where('runId', isEqualTo: runId)
          .where('status', whereIn: _rosterVisibleStatuses)
          .get();
      return snap.docs.map((doc) => doc.data()).toList();
    },
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'fetch run participations',
      resource: _collectionPath,
    ),
  );

  Stream<RunParticipation?> watchParticipation({
    required String runId,
    required String uid,
  }) => withBackendErrorStream(
    () => _participationsRef
        .where('runId', isEqualTo: runId)
        .where('uid', isEqualTo: uid)
        .limit(1)
        .snapshots()
        .map((snap) => snap.docs.isEmpty ? null : snap.docs.first.data()),
    context: const BackendErrorContext(
      service: BackendService.firestore,
      action: 'watch run participation',
      resource: _collectionPath,
    ),
  );
}

@Riverpod(keepAlive: true)
RunParticipationRepository runParticipationRepository(Ref ref) =>
    RunParticipationRepository(ref.watch(firebaseFirestoreProvider));

@riverpod
Stream<List<RunParticipation>> watchRunParticipationsForUser(
  Ref ref,
  String uid,
) => ref
    .watch(runParticipationRepositoryProvider)
    .watchParticipationsForUser(uid: uid);

@riverpod
Stream<List<RunParticipation>> watchRunParticipationsForRun(
  Ref ref,
  String runId,
) => ref
    .watch(runParticipationRepositoryProvider)
    .watchParticipationsForRun(runId: runId);

@riverpod
Stream<RunParticipationRoster> watchRunParticipationRoster(
  Ref ref,
  String runId,
) => ref
    .watch(runParticipationRepositoryProvider)
    .watchParticipationsForRun(runId: runId)
    .map(RunParticipationRoster.fromParticipations);

@riverpod
Stream<RunParticipation?> watchRunParticipation(
  Ref ref,
  String runId,
  String uid,
) => ref
    .watch(runParticipationRepositoryProvider)
    .watchParticipation(runId: runId, uid: uid);
