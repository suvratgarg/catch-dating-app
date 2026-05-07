import 'dart:async';

import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/firestore_converters.dart';
import 'package:catch_dating_app/core/firestore_error_util.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_repository.g.dart';

class RunRepository {
  const RunRepository(this._db, this._functions);

  static const _collectionPath = 'runs';

  final FirebaseFirestore _db;
  final FirebaseFunctions _functions;

  CollectionReference<Run> get _runsRef => _db
      .collection(_collectionPath)
      .withDocumentIdConverter<Run>(
        idField: 'id',
        fromJson: Run.fromJson,
        toJson: (run) => run.toJson(),
      );

  CollectionReference<RunParticipation> get _participationsRef => _db
      .collection('runParticipations')
      .withDocumentIdConverter<RunParticipation>(
        idField: 'id',
        fromJson: RunParticipation.fromJson,
        toJson: (participation) => participation.toJson(),
      );

  DocumentReference<Run> _runRef(String id) => _runsRef.doc(id);

  // ── Read ──────────────────────────────────────────────────────────────────

  Future<Run?> fetchRun(String id) async {
    final doc = await _runRef(id).get();
    return doc.exists ? doc.data() : null;
  }

  Stream<Run?> watchRun(String id) =>
      _runRef(id).snapshots().map((doc) => doc.exists ? doc.data() : null);

  Stream<List<Run>> watchRunsForClub({required String runClubId}) => _runsRef
      .where('runClubId', isEqualTo: runClubId)
      .orderBy('startTime')
      .snapshots()
      .map((snap) => snap.docs.map((d) => d.data()).toList());

  Stream<List<Run>> watchAttendedRuns({required String uid}) =>
      _watchRunsForParticipationStatuses(
        uid: uid,
        statuses: const {RunParticipationStatus.attended},
        descending: true,
      );

  /// Streams upcoming runs the user has signed up for (paid / reserved a spot).
  Stream<List<Run>> watchSignedUpRuns({required String uid}) =>
      _watchRunsForParticipationStatuses(
        uid: uid,
        statuses: const {RunParticipationStatus.signedUp},
      );

  Stream<List<Run>> _watchRunsForParticipationStatuses({
    required String uid,
    required Set<RunParticipationStatus> statuses,
    bool descending = false,
  }) {
    if (statuses.isEmpty) return Stream.value(const []);

    StreamSubscription<QuerySnapshot<RunParticipation>>? participationSub;
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
      final runs =
          [
            for (final id in runIds)
              if (byId[id] != null) byId[id]!,
          ]..sort(
            (a, b) => descending
                ? b.startTime.compareTo(a.startTime)
                : a.startTime.compareTo(b.startTime),
          );
      controller.add(runs);
    }

    controller = StreamController<List<Run>>(
      onListen: () {
        Query<RunParticipation> query = _participationsRef.where(
          'uid',
          isEqualTo: uid,
        );
        final statusNames = statuses.map((status) => status.name).toList();
        query = statusNames.length == 1
            ? query.where('status', isEqualTo: statusNames.single)
            : query.where('status', whereIn: statusNames);

        participationSub = query.snapshots().listen((snap) {
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
        await participationSub?.cancel();
        if (!controller.isClosed) {
          await controller.close();
        }
      },
    );

    return controller.stream;
  }

  /// Generates a new unique Firestore document ID for a run without writing it.
  String generateId() => _runsRef.doc().id;

  /// Fetches upcoming runs from the given club IDs (max 10 clubs, limit 10 runs).
  Future<List<Run>> fetchUpcomingRunsForClubs(List<String> runClubIds) async {
    if (runClubIds.isEmpty) return [];
    final now = Timestamp.now();
    final snap = await _runsRef
        .where('runClubId', whereIn: runClubIds.take(10).toList())
        .where('startTime', isGreaterThan: now)
        .orderBy('startTime')
        .limit(10)
        .get();
    return snap.docs.map((d) => d.data()).toList();
  }

  // ── Write ─────────────────────────────────────────────────────────────────

  Future<void> createRun({required Run run}) => withFirestoreErrorContext(
    () => _functions.httpsCallable('createRun').call(_runCreatePayload(run)),
    collection: _collectionPath,
    action: 'create run',
  );

  Future<void> updateRunDetails({required Run run}) =>
      withFirestoreErrorContext(
        () => _functions.httpsCallable('updateRun').call({
          'runId': run.id,
          'fields': _runUpdatePayload(run),
        }),
        collection: _collectionPath,
        action: 'update run',
      );

  /// Cancels the current user's sign-up via the [cancelRunSignUp] Cloud
  /// Function, which atomically updates their participation edge and aggregate
  /// booking projections.
  Future<void> cancelSignUpViaFunction({required String runId}) =>
      withFirestoreErrorContext(
        () =>
            _functions.httpsCallable('cancelRunSignUp').call({'runId': runId}),
        collection: _collectionPath,
        action: 'cancel sign-up',
      );

  Future<void> joinWaitlistViaFunction({required String runId}) =>
      withFirestoreErrorContext(
        () =>
            _functions.httpsCallable('joinRunWaitlist').call({'runId': runId}),
        collection: _collectionPath,
        action: 'join waitlist',
      );

  Future<void> leaveWaitlist({required String runId, required String userId}) =>
      withFirestoreErrorContext(
        () =>
            _functions.httpsCallable('leaveRunWaitlist').call({'runId': runId}),
        collection: _collectionPath,
        action: 'leave waitlist',
      );

  /// Toggles attendance for a single user via the [markRunAttendance] Cloud
  /// Function. Only callable by the run club's host.
  /// Returns `true` if the user is now marked attended, `false` if removed.
  Future<bool> markAttendance({
    required String runId,
    required String userId,
  }) => withFirestoreErrorContext(
    () async {
      final result = await _functions.httpsCallable('markRunAttendance').call({
        'runId': runId,
        'userId': userId,
      });
      return (result.data as Map<String, dynamic>)['attended'] as bool;
    },
    collection: _collectionPath,
    action: 'mark attendance',
  );

  /// Self-check-in for a signed-up participant via the
  /// [selfCheckInAttendance] Cloud Function.
  ///
  /// Requires GPS coordinates so the server can verify the user is within
  /// 200 m of the run's meeting point. Pass `null` for runs without
  /// coordinates (the server skips the proximity check).
  Future<void> selfCheckInAttendance({
    required String runId,
    required double? latitude,
    required double? longitude,
  }) => withFirestoreErrorContext(
    () => _functions.httpsCallable('selfCheckInAttendance').call({
      'runId': runId,
      'latitude': ?latitude,
      'longitude': ?longitude,
    }),
    collection: _collectionPath,
    action: 'self check-in',
  );
}

Iterable<List<T>> _chunks<T>(List<T> values, int size) sync* {
  for (var start = 0; start < values.length; start += size) {
    final end = start + size > values.length ? values.length : start + size;
    yield values.sublist(start, end);
  }
}

Map<String, Object?> _runCreatePayload(Run run) => {
  'runId': run.id,
  'runClubId': run.runClubId,
  ..._runMutableDetailsPayload(run),
  'capacityLimit': run.capacityLimit,
  'priceInPaise': run.priceInPaise,
  'constraints': _constraintsPayload(run.constraints),
};

Map<String, Object?> _runUpdatePayload(Run run) =>
    _runMutableDetailsPayload(run);

Map<String, Object?> _runMutableDetailsPayload(Run run) => {
  'startTimeMillis': run.startTime.millisecondsSinceEpoch,
  'endTimeMillis': run.endTime.millisecondsSinceEpoch,
  'meetingPoint': run.meetingPoint,
  'startingPointLat': run.startingPointLat,
  'startingPointLng': run.startingPointLng,
  'locationDetails': run.locationDetails,
  'distanceKm': run.distanceKm,
  'pace': run.pace.name,
  'description': run.description,
};

Map<String, Object?> _constraintsPayload(RunConstraints constraints) => {
  'minAge': constraints.minAge,
  'maxAge': constraints.maxAge,
  'maxMen': constraints.maxMen,
  'maxWomen': constraints.maxWomen,
};

@riverpod
RunRepository runRepository(Ref ref) => RunRepository(
  ref.watch(firebaseFirestoreProvider),
  ref.watch(firebaseFunctionsProvider),
);

@riverpod
Stream<Run?> watchRun(Ref ref, String runId) =>
    ref.watch(runRepositoryProvider).watchRun(runId);

@riverpod
Stream<List<Run>> watchRunsForClub(Ref ref, String runClubId) =>
    ref.watch(runRepositoryProvider).watchRunsForClub(runClubId: runClubId);

@riverpod
Stream<List<Run>> watchAttendedRuns(Ref ref, String uid) =>
    ref.watch(runRepositoryProvider).watchAttendedRuns(uid: uid);

@riverpod
Stream<List<Run>> watchSignedUpRuns(Ref ref, String uid) =>
    ref.watch(runRepositoryProvider).watchSignedUpRuns(uid: uid);

class RecommendedRunsQuery {
  RecommendedRunsQuery._(Iterable<String> followedClubIds)
    : followedClubIds = List.unmodifiable(
        (followedClubIds.toSet().toList()..sort()),
      );

  factory RecommendedRunsQuery.fromClubIds(Iterable<String> followedClubIds) =>
      RecommendedRunsQuery._(followedClubIds);

  static const _equality = ListEquality<String>();

  final List<String> followedClubIds;

  @override
  bool operator ==(Object other) {
    return other is RecommendedRunsQuery &&
        _equality.equals(other.followedClubIds, followedClubIds);
  }

  @override
  int get hashCode => _equality.hash(followedClubIds);
}

/// Returns upcoming runs from clubs the user follows.
@riverpod
Future<List<Run>> recommendedRuns(Ref ref, RecommendedRunsQuery query) => ref
    .watch(runRepositoryProvider)
    .fetchUpcomingRunsForClubs(query.followedClubIds);
