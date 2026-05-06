import 'dart:async';

import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/domain/run_participation_roster.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_participation_repository.g.dart';

class RunParticipationRepository {
  const RunParticipationRepository(this._db);

  static const _collectionPath = 'runParticipations';

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
  }) => _participationsRef
      .where('uid', isEqualTo: uid)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  Stream<List<RunParticipation>> watchParticipationsForRun({
    required String runId,
  }) => _participationsRef
      .where('runId', isEqualTo: runId)
      .snapshots()
      .map((snap) => snap.docs.map((doc) => doc.data()).toList());

  Future<List<RunParticipation>> fetchParticipationsForRun({
    required String runId,
  }) async {
    final snap = await _participationsRef
        .where('runId', isEqualTo: runId)
        .get();
    return snap.docs.map((doc) => doc.data()).toList();
  }

  Stream<RunParticipation?> watchParticipation({
    required String runId,
    required String uid,
  }) => _participationsRef
      .doc(runParticipationId(runId: runId, uid: uid))
      .snapshots()
      .map((doc) => doc.exists ? doc.data() : null);
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
