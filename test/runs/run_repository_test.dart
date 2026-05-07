import 'dart:async';

import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'runs_test_helpers.dart';

class TestFirebaseFunctions extends Fake implements FirebaseFunctions {
  final callables = <String, TestHttpsCallable>{};

  @override
  HttpsCallable httpsCallable(String name, {HttpsCallableOptions? options}) {
    return callables.putIfAbsent(name, () => TestHttpsCallable(name));
  }
}

class TestHttpsCallable extends Fake implements HttpsCallable {
  TestHttpsCallable(this.name);

  final String name;
  final calls = <Object?>[];
  Object? resultData;

  @override
  Future<HttpsCallableResult<T>> call<T>([dynamic parameters]) async {
    calls.add(parameters);
    return TestHttpsCallableResult<T>(resultData as T);
  }
}

class TestHttpsCallableResult<T> extends Fake
    implements HttpsCallableResult<T> {
  TestHttpsCallableResult(this.dataValue);

  final T dataValue;

  @override
  T get data => dataValue;
}

void main() {
  group('RunRepository', () {
    late FakeFirebaseFirestore firestore;
    late TestFirebaseFunctions functions;
    late RunRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      functions = TestFirebaseFunctions();
      repository = RunRepository(firestore, functions);
    });

    test('generateId uses an auto-generated document reference', () async {
      final generatedId = repository.generateId();

      expect(generatedId, isNotEmpty);
      final generatedDoc = await firestore
          .collection('runs')
          .doc(generatedId)
          .get();
      expect(generatedDoc.exists, isFalse);
    });

    test(
      'converter round-trips Firestore data and injects the document id',
      () async {
        final rawRun = buildRun(
          id: 'run-88',
          constraints: const RunConstraints(minAge: 21, maxWomen: 6),
        );

        await _seedRun(firestore, rawRun);

        final decoded = await repository.fetchRun(rawRun.id);
        final encoded =
            (await firestore.collection('runs').doc(rawRun.id).get()).data()!;

        expect(decoded?.id, 'run-88');
        expect(decoded?.meetingPoint, 'Carter Road');
        expect(encoded.containsKey('id'), isFalse);
        expect(encoded['runClubId'], 'club-1');
        expect(encoded['constraints'], {
          'minAge': 21,
          'maxAge': 99,
          'maxMen': null,
          'maxWomen': 6,
        });
        expect(decoded?.constraints, rawRun.constraints);
      },
    );

    test('fetchRun returns the decoded run when found', () async {
      final run = buildRun(id: 'run-1');
      await _seedRun(firestore, run);

      expect(await repository.fetchRun('run-1'), run);
    });

    test('fetchRun returns null when the document is missing', () async {
      expect(await repository.fetchRun('run-missing'), isNull);
    });

    test('watchRun emits the decoded run when the document exists', () async {
      final run = buildRun(id: 'run-1');
      await _seedRun(firestore, run);

      await expectLater(repository.watchRun('run-1'), emits(run));
    });

    test('watchRun emits null when the document is missing', () async {
      await expectLater(repository.watchRun('run-missing'), emits(null));
    });

    test(
      'watchRunsForClub filters by club id and orders by start time',
      () async {
        final later = buildRun(
          id: 'later',
          runClubId: 'club-2',
          startTime: DateTime.now().add(const Duration(hours: 5)),
        );
        final earlier = buildRun(
          id: 'earlier',
          runClubId: 'club-2',
          startTime: DateTime.now().add(const Duration(hours: 2)),
        );
        await _seedRun(firestore, later);
        await _seedRun(firestore, earlier);
        await _seedRun(
          firestore,
          buildRun(id: 'other-club', runClubId: 'club-3'),
        );

        await expectLater(
          repository.watchRunsForClub(runClubId: 'club-2'),
          emits([earlier, later]),
        );
      },
    );

    test(
      'watchAttendedRuns filters by attendee id and sorts descending',
      () async {
        final older = buildRun(
          id: 'older',
          startTime: DateTime.now().subtract(const Duration(days: 2)),
        );
        final newer = buildRun(
          id: 'newer',
          startTime: DateTime.now().subtract(const Duration(days: 1)),
        );
        await _seedRun(firestore, older);
        await _seedRun(firestore, newer);
        await _seedRun(firestore, buildRun(id: 'not-attended'));
        await _seedParticipation(
          firestore,
          run: older,
          uid: 'runner-1',
          status: RunParticipationStatus.attended,
        );
        await _seedParticipation(
          firestore,
          run: newer,
          uid: 'runner-1',
          status: RunParticipationStatus.attended,
        );
        await _seedParticipation(
          firestore,
          run: buildRun(id: 'not-attended'),
          uid: 'runner-1',
          status: RunParticipationStatus.signedUp,
        );

        await expectLater(
          repository.watchAttendedRuns(uid: 'runner-1'),
          emits([newer, older]),
        );
      },
    );

    test(
      'watchSignedUpRuns filters by signup id and sorts ascending',
      () async {
        final later = buildRun(
          id: 'later',
          startTime: DateTime.now().add(const Duration(hours: 5)),
        );
        final earlier = buildRun(
          id: 'earlier',
          startTime: DateTime.now().add(const Duration(hours: 2)),
        );
        await _seedRun(firestore, later);
        await _seedRun(firestore, earlier);
        await _seedRun(firestore, buildRun(id: 'not-signed-up'));
        await _seedParticipation(
          firestore,
          run: later,
          uid: 'runner-1',
          status: RunParticipationStatus.signedUp,
        );
        await _seedParticipation(
          firestore,
          run: earlier,
          uid: 'runner-1',
          status: RunParticipationStatus.signedUp,
        );
        await _seedParticipation(
          firestore,
          run: buildRun(id: 'not-signed-up'),
          uid: 'runner-1',
          status: RunParticipationStatus.waitlisted,
        );

        await expectLater(
          repository.watchSignedUpRuns(uid: 'runner-1'),
          emits([earlier, later]),
        );
      },
    );

    test(
      'fetchUpcomingRunsForClubs returns empty without querying for no clubs',
      () async {
        await _seedRun(firestore, buildRun(id: 'run-1', runClubId: 'club-1'));

        expect(await repository.fetchUpcomingRunsForClubs(const []), isEmpty);
      },
    );

    test(
      'fetchUpcomingRunsForClubs filters upcoming runs and limits results',
      () async {
        final run = buildRun(id: 'run-1', runClubId: 'club-3');
        await _seedRun(firestore, run);
        await _seedRun(
          firestore,
          buildRun(
            id: 'past',
            runClubId: 'club-3',
            startTime: DateTime.now().subtract(const Duration(hours: 2)),
          ),
        );
        await _seedRun(
          firestore,
          buildRun(id: 'other-club', runClubId: 'club-11'),
        );

        final results = await repository.fetchUpcomingRunsForClubs(const [
          'club-1',
          'club-2',
          'club-3',
        ]);

        expect(results, [run]);
      },
    );

    test('createRun calls the server-owned createRun Cloud Function', () async {
      final run = buildRun(
        id: 'run-42',
        constraints: const RunConstraints(minAge: 21, maxAge: 35),
      );

      await repository.createRun(run: run);

      expect(functions.callables['createRun']!.calls, [
        {
          'runId': 'run-42',
          'runClubId': run.runClubId,
          'startTimeMillis': run.startTime.millisecondsSinceEpoch,
          'endTimeMillis': run.endTime.millisecondsSinceEpoch,
          'meetingPoint': run.meetingPoint,
          'startingPointLat': run.startingPointLat,
          'startingPointLng': run.startingPointLng,
          'locationDetails': run.locationDetails,
          'distanceKm': run.distanceKm,
          'pace': run.pace.name,
          'description': run.description,
          'capacityLimit': run.capacityLimit,
          'priceInPaise': run.priceInPaise,
          'constraints': {
            'minAge': 21,
            'maxAge': 35,
            'maxMen': null,
            'maxWomen': null,
          },
        },
      ]);
    });

    test(
      'updateRunDetails calls the server-owned updateRun Cloud Function',
      () async {
        final run = buildRun(id: 'run-42');

        await repository.updateRunDetails(run: run);

        expect(functions.callables['updateRun']!.calls, [
          {
            'runId': 'run-42',
            'fields': {
              'startTimeMillis': run.startTime.millisecondsSinceEpoch,
              'endTimeMillis': run.endTime.millisecondsSinceEpoch,
              'meetingPoint': run.meetingPoint,
              'startingPointLat': run.startingPointLat,
              'startingPointLng': run.startingPointLng,
              'locationDetails': run.locationDetails,
              'distanceKm': run.distanceKm,
              'pace': run.pace.name,
              'description': run.description,
            },
          },
        ]);
      },
    );

    test('joinWaitlistViaFunction calls the matching Cloud Function', () async {
      await repository.joinWaitlistViaFunction(runId: 'run-1');

      expect(functions.callables['joinRunWaitlist']!.calls, [
        {'runId': 'run-1'},
      ]);
    });

    test('leaveWaitlist calls the matching Cloud Function', () async {
      await repository.leaveWaitlist(runId: 'run-1', userId: 'runner-1');

      expect(functions.callables['leaveRunWaitlist']!.calls, [
        {'runId': 'run-1'},
      ]);
    });

    test('cancelSignUpViaFunction calls the matching Cloud Function', () async {
      await repository.cancelSignUpViaFunction(runId: 'run-9');

      expect(functions.callables['cancelRunSignUp']!.calls, [
        {'runId': 'run-9'},
      ]);
    });

    test('markAttendance calls the matching Cloud Function', () async {
      (functions.httpsCallable('markRunAttendance') as TestHttpsCallable)
          .resultData = {
        'attended': true,
      };
      final result = await repository.markAttendance(
        runId: 'run-9',
        userId: 'user-1',
      );

      expect(result, true);
      expect(functions.callables['markRunAttendance']!.calls, [
        {'runId': 'run-9', 'userId': 'user-1'},
      ]);
    });
  });

  group('RunRepository providers', () {
    late FakeFirebaseFirestore firestore;
    late TestFirebaseFunctions functions;
    late ProviderContainer container;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      functions = TestFirebaseFunctions();
      container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(firestore),
          firebaseFunctionsProvider.overrideWithValue(functions),
        ],
      );
    });

    tearDown(() => container.dispose());

    test(
      'runRepositoryProvider builds a repository from Firebase providers',
      () {
        expect(container.read(runRepositoryProvider), isA<RunRepository>());
      },
    );

    test('watchRunProvider delegates to the repository', () async {
      final run = buildRun(id: 'run-1');
      await _seedRun(firestore, run);

      final provider = watchRunProvider(run.id);
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final value = await container.read(provider.future);

      expect(value, run);
    });

    test(
      'watchRunProvider auto-disposes detail listeners when unwatched',
      () async {
        final run = buildRun(id: 'run-1');
        final cancelCompleter = Completer<void>();
        final runController = StreamController<Run?>(
          onCancel: () {
            if (!cancelCompleter.isCompleted) cancelCompleter.complete();
          },
        );
        addTearDown(() async {
          if (!cancelCompleter.isCompleted) await runController.close();
        });

        final container = ProviderContainer(
          overrides: [
            runRepositoryProvider.overrideWith(
              (ref) => _LifecycleRunRepository(runStream: runController.stream),
            ),
          ],
        );
        addTearDown(container.dispose);

        final provider = watchRunProvider(run.id);
        final subscription = container.listen(provider, (_, _) {});

        runController.add(run);
        await container.pump();
        expect(subscription.read().value, run);

        subscription.close();
        await container.pump();

        await expectLater(cancelCompleter.future, completes);
      },
    );

    test('watchRunsForClubProvider delegates to the repository', () async {
      final run = buildRun(id: 'run-1', runClubId: 'club-1');
      await _seedRun(firestore, run);

      final provider = watchRunsForClubProvider('club-1');
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final value = await container.read(provider.future);

      expect(value, [run]);
    });

    test('watchAttendedRunsProvider delegates to the repository', () async {
      final run = buildRun(id: 'run-1');
      await _seedRun(firestore, run);
      await _seedParticipation(
        firestore,
        run: run,
        uid: 'runner-1',
        status: RunParticipationStatus.attended,
      );

      final provider = watchAttendedRunsProvider('runner-1');
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final value = await container.read(provider.future);

      expect(value, [run]);
    });

    test('watchSignedUpRunsProvider delegates to the repository', () async {
      final run = buildRun(id: 'run-1');
      await _seedRun(firestore, run);
      await _seedParticipation(
        firestore,
        run: run,
        uid: 'runner-1',
        status: RunParticipationStatus.signedUp,
      );

      final provider = watchSignedUpRunsProvider('runner-1');
      final subscription = container.listen(provider, (_, _) {});
      addTearDown(subscription.close);

      final value = await container.read(provider.future);

      expect(value, [run]);
    });

    testWidgets(
      'watchSignedUpRunsProvider keeps realtime streams alive while idle',
      (tester) async {
        final run = buildRun(id: 'run-1', bookedCount: 1);
        final signedUpRunsController = StreamController<List<Run>>();
        addTearDown(signedUpRunsController.close);

        final container = ProviderContainer(
          overrides: [
            runRepositoryProvider.overrideWith(
              (ref) => _IdleRunRepository(
                signedUpRunsStream: signedUpRunsController.stream,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final provider = watchSignedUpRunsProvider('runner-1');
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);

        signedUpRunsController.add([run]);
        await container.pump();
        expect(subscription.read().value, [run]);

        await tester.pump(_pastLegacyStreamTimeout);
        await container.pump();

        expect(subscription.read(), isA<AsyncData<List<Run>>>());
        expect(subscription.read().value, [run]);
      },
    );

    test('recommendedRunsProvider delegates to the repository', () async {
      final run = buildRun(id: 'run-1', runClubId: 'club-1');
      await _seedRun(firestore, run);

      final results = await container.read(
        recommendedRunsProvider(
          RecommendedRunsQuery.fromClubIds(const ['club-1']),
        ).future,
      );

      expect(results, [run]);
    });
  });
}

Future<void> _seedRun(FakeFirebaseFirestore firestore, Run run) {
  return firestore.collection('runs').doc(run.id).set(run.toJson());
}

Future<void> _seedParticipation(
  FakeFirebaseFirestore firestore, {
  required Run run,
  required String uid,
  required RunParticipationStatus status,
}) {
  final now = DateTime(2026, 1, 1);
  final participation = RunParticipation(
    id: runParticipationId(runId: run.id, uid: uid),
    runId: run.id,
    runClubId: run.runClubId,
    uid: uid,
    status: status,
    createdAt: now,
    updatedAt: now,
  );
  return firestore
      .collection('runParticipations')
      .doc(participation.id)
      .set(participation.toJson());
}

class _IdleRunRepository extends Fake implements RunRepository {
  _IdleRunRepository({required this.signedUpRunsStream});

  final Stream<List<Run>> signedUpRunsStream;

  @override
  Stream<List<Run>> watchSignedUpRuns({required String uid}) =>
      signedUpRunsStream;
}

class _LifecycleRunRepository extends Fake implements RunRepository {
  _LifecycleRunRepository({required this.runStream});

  final Stream<Run?> runStream;

  @override
  Stream<Run?> watchRun(String id) => runStream;
}

const _pastLegacyStreamTimeout = Duration(seconds: 11);
