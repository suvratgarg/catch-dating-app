// ignore_for_file: must_be_immutable, override_on_non_overriding_member, subtype_of_sealed_class

import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'runs_test_helpers.dart';

class TestFirebaseFirestore extends Fake implements FirebaseFirestore {
  TestFirebaseFirestore({required this.runsCollection});

  final CollectionReference<Map<String, dynamic>> runsCollection;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    switch (collectionPath) {
      case 'runs':
        return runsCollection;
      default:
        throw UnimplementedError('Unexpected collection path: $collectionPath');
    }
  }
}

class TestRunsRawCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  TestRunsRawCollection(this.convertedCollection);

  final TestRunsCollection convertedCollection;
  FromFirestore<Run>? lastFromFirestore;
  ToFirestore<Run>? lastToFirestore;

  @override
  CollectionReference<R> withConverter<R>({
    required FromFirestore<R> fromFirestore,
    required ToFirestore<R> toFirestore,
  }) {
    if (R != Run) {
      throw UnimplementedError('Only Run conversion is supported in tests.');
    }
    lastFromFirestore = fromFirestore as FromFirestore<Run>;
    lastToFirestore = toFirestore as ToFirestore<Run>;
    return convertedCollection as CollectionReference<R>;
  }
}

class TestRunsCollection extends Fake implements CollectionReference<Run> {
  TestRunsCollection({required this.autoDoc});

  final TestRunDocumentReference autoDoc;
  final docsById = <String, TestRunDocumentReference>{};
  TestRunsQuery? nextWhereResult;
  final whereCalls = <WhereCall>[];

  @override
  DocumentReference<Run> doc([String? path]) {
    if (path == null) {
      return autoDoc;
    }
    return docsById.putIfAbsent(path, () => TestRunDocumentReference(path));
  }

  @override
  Query<Run> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    whereCalls.add(
      WhereCall(
        field: field,
        isEqualTo: isEqualTo,
        isGreaterThan: isGreaterThan,
        arrayContains: arrayContains,
        whereIn: whereIn,
      ),
    );
    return nextWhereResult!;
  }
}

class TestRunsQuery extends Fake implements Query<Run> {
  TestRunsQuery({required this.snapshot, QuerySnapshot<Run>? getSnapshot})
    : getSnapshot = getSnapshot ?? snapshot;

  final QuerySnapshot<Run> snapshot;
  final QuerySnapshot<Run> getSnapshot;
  final whereCalls = <WhereCall>[];
  Object? lastOrderByField;
  bool? lastOrderByDescending;
  int? lastLimit;

  @override
  Query<Run> where(
    Object field, {
    Object? isEqualTo,
    Object? isNotEqualTo,
    Object? isLessThan,
    Object? isLessThanOrEqualTo,
    Object? isGreaterThan,
    Object? isGreaterThanOrEqualTo,
    Object? arrayContains,
    Iterable<Object?>? arrayContainsAny,
    Iterable<Object?>? whereIn,
    Iterable<Object?>? whereNotIn,
    bool? isNull,
  }) {
    whereCalls.add(
      WhereCall(
        field: field,
        isEqualTo: isEqualTo,
        isGreaterThan: isGreaterThan,
        arrayContains: arrayContains,
        whereIn: whereIn,
      ),
    );
    return this;
  }

  @override
  Query<Run> orderBy(Object field, {bool descending = false}) {
    lastOrderByField = field;
    lastOrderByDescending = descending;
    return this;
  }

  @override
  Query<Run> limit(int limit) {
    lastLimit = limit;
    return this;
  }

  @override
  Future<QuerySnapshot<Run>> get([GetOptions? options]) async => getSnapshot;

  @override
  Stream<QuerySnapshot<Run>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) => Stream.value(snapshot);
}

class TestRunDocumentReference extends Fake implements DocumentReference<Run> {
  TestRunDocumentReference(this.id);

  @override
  final String id;
  Run? getResultData;
  bool getResultExists = true;
  Stream<DocumentSnapshot<Run>> snapshotStream = const Stream.empty();
  final setCalls = <Run>[];
  final updateCalls = <Map<Object, Object?>>[];

  @override
  String get path => 'runs/$id';

  @override
  Future<DocumentSnapshot<Run>> get([GetOptions? options]) async =>
      TestRunDocumentSnapshot(
        referenceValue: this,
        existsValue: getResultExists,
        dataValue: getResultData,
      );

  @override
  Stream<DocumentSnapshot<Run>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) => snapshotStream;

  @override
  Future<void> set(Run data, [SetOptions? options]) async {
    setCalls.add(data);
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    updateCalls.add(data);
  }
}

class TestRunDocumentSnapshot extends Fake implements DocumentSnapshot<Run> {
  TestRunDocumentSnapshot({
    required this.referenceValue,
    required this.existsValue,
    required this.dataValue,
  });

  @override
  final DocumentReference<Run> referenceValue;
  final bool existsValue;
  final Run? dataValue;

  @override
  bool get exists => existsValue;

  @override
  String get id => referenceValue.id;

  @override
  DocumentReference<Run> get reference => referenceValue;

  @override
  Run? data() => dataValue;
}

class TestRunQuerySnapshot extends Fake implements QuerySnapshot<Run> {
  TestRunQuerySnapshot(this.docsValue);

  final List<QueryDocumentSnapshot<Run>> docsValue;

  @override
  List<QueryDocumentSnapshot<Run>> get docs => docsValue;

  @override
  List<DocumentChange<Run>> get docChanges => const [];

  @override
  int get size => docsValue.length;
}

class TestRunQueryDocumentSnapshot extends Fake
    implements QueryDocumentSnapshot<Run> {
  TestRunQueryDocumentSnapshot({
    required this.referenceValue,
    required this.dataValue,
  });

  @override
  final DocumentReference<Run> referenceValue;
  final Run dataValue;

  @override
  bool get exists => true;

  @override
  String get id => referenceValue.id;

  @override
  DocumentReference<Run> get reference => referenceValue;

  @override
  Run data() => dataValue;
}

class TestMapDocumentSnapshot extends Fake
    implements DocumentSnapshot<Map<String, dynamic>> {
  TestMapDocumentSnapshot({required this.idValue, required this.dataValue});

  final String idValue;
  final Map<String, dynamic>? dataValue;

  @override
  bool get exists => dataValue != null;

  @override
  String get id => idValue;

  @override
  Map<String, dynamic>? data() => dataValue;
}

class WhereCall {
  const WhereCall({
    required this.field,
    this.isEqualTo,
    this.isGreaterThan,
    this.arrayContains,
    this.whereIn,
  });

  final Object field;
  final Object? isEqualTo;
  final Object? isGreaterThan;
  final Object? arrayContains;
  final Iterable<Object?>? whereIn;
}

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
    late TestRunDocumentReference autoDoc;
    late TestRunsCollection runsCollection;
    late TestRunsRawCollection rawRunsCollection;
    late TestFirebaseFirestore firestore;
    late TestFirebaseFunctions functions;
    late RunRepository repository;

    setUp(() {
      autoDoc = TestRunDocumentReference('generated-run-id');
      runsCollection = TestRunsCollection(autoDoc: autoDoc);
      rawRunsCollection = TestRunsRawCollection(runsCollection);
      firestore = TestFirebaseFirestore(runsCollection: rawRunsCollection);
      functions = TestFirebaseFunctions();
      repository = RunRepository(firestore, functions);
    });

    test('generateId uses an auto-generated document reference', () {
      expect(repository.generateId(), 'generated-run-id');
    });

    test(
      'converter round-trips Firestore data and injects the document id',
      () {
        repository.generateId();

        final fromFirestore = rawRunsCollection.lastFromFirestore!;
        final toFirestore = rawRunsCollection.lastToFirestore!;
        final rawRun = buildRun(id: 'run-88');
        final encoded = {
          ...toFirestore(rawRun, null),
          'constraints': rawRun.constraints.toJson(),
        };
        final decoded = fromFirestore(
          TestMapDocumentSnapshot(idValue: 'run-77', dataValue: encoded),
          null,
        );

        expect(decoded.id, 'run-77');
        expect(decoded.meetingPoint, 'Carter Road');
        expect(encoded.containsKey('id'), isFalse);
        expect(encoded['runClubId'], 'club-1');
      },
    );

    test('fetchRun returns the decoded run when found', () async {
      final runDoc = runsCollection.doc('run-1') as TestRunDocumentReference;
      final run = buildRun(id: 'run-1');
      runDoc.getResultData = run;
      runDoc.getResultExists = true;

      expect(await repository.fetchRun('run-1'), run);
    });

    test('fetchRun returns null when the document is missing', () async {
      final runDoc =
          runsCollection.doc('run-missing') as TestRunDocumentReference;
      runDoc.getResultData = null;
      runDoc.getResultExists = false;

      expect(await repository.fetchRun('run-missing'), isNull);
    });

    test('watchRun emits the decoded run when the document exists', () async {
      final runDoc = runsCollection.doc('run-1') as TestRunDocumentReference;
      final run = buildRun(id: 'run-1');
      runDoc.snapshotStream = Stream.value(
        TestRunDocumentSnapshot(
          referenceValue: runDoc,
          existsValue: true,
          dataValue: run,
        ),
      );

      await expectLater(repository.watchRun('run-1'), emits(run));
    });

    test('watchRun emits null when the document is missing', () async {
      final runDoc =
          runsCollection.doc('run-missing') as TestRunDocumentReference;
      runDoc.snapshotStream = Stream.value(
        TestRunDocumentSnapshot(
          referenceValue: runDoc,
          existsValue: false,
          dataValue: null,
        ),
      );

      await expectLater(repository.watchRun('run-missing'), emits(null));
    });

    test(
      'watchRunsForClub queries by club id and orders by start time',
      () async {
        final run = buildRun(id: 'run-1', runClubId: 'club-2');
        final query = TestRunsQuery(
          snapshot: TestRunQuerySnapshot([
            TestRunQueryDocumentSnapshot(
              referenceValue: TestRunDocumentReference(run.id),
              dataValue: run,
            ),
          ]),
        );
        runsCollection.nextWhereResult = query;

        await expectLater(
          repository.watchRunsForClub(runClubId: 'club-2'),
          emits([run]),
        );
        expect(runsCollection.whereCalls.single.field, 'runClubId');
        expect(runsCollection.whereCalls.single.isEqualTo, 'club-2');
        expect(query.lastOrderByField, 'startTime');
        expect(query.lastOrderByDescending, isFalse);
      },
    );

    test(
      'watchAttendedRuns queries by attendee id and sorts descending',
      () async {
        final run = buildRun(id: 'run-1');
        final query = TestRunsQuery(
          snapshot: TestRunQuerySnapshot([
            TestRunQueryDocumentSnapshot(
              referenceValue: TestRunDocumentReference(run.id),
              dataValue: run,
            ),
          ]),
        );
        runsCollection.nextWhereResult = query;

        await expectLater(
          repository.watchAttendedRuns(uid: 'runner-1'),
          emits([run]),
        );
        expect(runsCollection.whereCalls.single.field, 'attendedUserIds');
        expect(runsCollection.whereCalls.single.arrayContains, 'runner-1');
        expect(query.lastOrderByField, 'startTime');
        expect(query.lastOrderByDescending, isTrue);
      },
    );

    test(
      'watchSignedUpRuns queries by signup id and sorts ascending',
      () async {
        final run = buildRun(id: 'run-1');
        final query = TestRunsQuery(
          snapshot: TestRunQuerySnapshot([
            TestRunQueryDocumentSnapshot(
              referenceValue: TestRunDocumentReference(run.id),
              dataValue: run,
            ),
          ]),
        );
        runsCollection.nextWhereResult = query;

        await expectLater(
          repository.watchSignedUpRuns(uid: 'runner-1'),
          emits([run]),
        );
        expect(runsCollection.whereCalls.single.field, 'signedUpUserIds');
        expect(runsCollection.whereCalls.single.arrayContains, 'runner-1');
        expect(query.lastOrderByField, 'startTime');
        expect(query.lastOrderByDescending, isFalse);
      },
    );

    test(
      'fetchUpcomingRunsForClubs returns empty without querying for no clubs',
      () async {
        expect(await repository.fetchUpcomingRunsForClubs(const []), isEmpty);
        expect(runsCollection.whereCalls, isEmpty);
      },
    );

    test(
      'fetchUpcomingRunsForClubs filters upcoming runs and limits results',
      () async {
        final run = buildRun(id: 'run-1', runClubId: 'club-3');
        final query = TestRunsQuery(
          snapshot: TestRunQuerySnapshot([]),
          getSnapshot: TestRunQuerySnapshot([
            TestRunQueryDocumentSnapshot(
              referenceValue: TestRunDocumentReference(run.id),
              dataValue: run,
            ),
          ]),
        );
        runsCollection.nextWhereResult = query;

        final results = await repository.fetchUpcomingRunsForClubs(const [
          'club-1',
          'club-2',
          'club-3',
        ]);

        expect(results, [run]);
        expect(runsCollection.whereCalls.single.field, 'runClubId');
        expect(runsCollection.whereCalls.single.whereIn, [
          'club-1',
          'club-2',
          'club-3',
        ]);
        expect(query.whereCalls.single.field, 'startTime');
        expect(query.whereCalls.single.isGreaterThan, isA<Timestamp>());
        expect(query.lastOrderByField, 'startTime');
        expect(query.lastLimit, 10);
      },
    );

    test('createRun writes the run to its document id', () async {
      final run = buildRun(id: 'run-42');
      final runDoc = runsCollection.doc(run.id) as TestRunDocumentReference;

      await repository.createRun(run: run);

      expect(runDoc.setCalls, [run]);
    });

    test('signUpForRun updates the signed up user ids', () async {
      final runDoc = runsCollection.doc('run-1') as TestRunDocumentReference;

      await repository.signUpForRun(runId: 'run-1', userId: 'runner-1');

      expect(
        runDoc.updateCalls.single,
        containsPair('signedUpUserIds', isA<FieldValue>()),
      );
    });

    test('joinWaitlist updates the waitlist user ids', () async {
      final runDoc = runsCollection.doc('run-1') as TestRunDocumentReference;

      await repository.joinWaitlist(runId: 'run-1', userId: 'runner-1');

      expect(
        runDoc.updateCalls.single,
        containsPair('waitlistUserIds', isA<FieldValue>()),
      );
    });

    test('leaveWaitlist removes the user from the waitlist', () async {
      final runDoc = runsCollection.doc('run-1') as TestRunDocumentReference;

      await repository.leaveWaitlist(runId: 'run-1', userId: 'runner-1');

      expect(
        runDoc.updateCalls.single,
        containsPair('waitlistUserIds', isA<FieldValue>()),
      );
    });

    test('cancelSignUpViaFunction calls the matching Cloud Function', () async {
      await repository.cancelSignUpViaFunction(runId: 'run-9');

      expect(functions.callables['cancelRunSignUp']!.calls, [
        {'runId': 'run-9'},
      ]);
    });

    test('markAttendance calls the matching Cloud Function', () async {
      await repository.markAttendance(runId: 'run-9');

      expect(functions.callables['markRunAttendance']!.calls, [
        {'runId': 'run-9'},
      ]);
    });
  });

  group('RunRepository providers', () {
    late TestRunDocumentReference autoDoc;
    late TestRunsCollection runsCollection;
    late TestRunsRawCollection rawRunsCollection;
    late TestFirebaseFirestore firestore;
    late TestFirebaseFunctions functions;
    late ProviderContainer container;

    setUp(() {
      autoDoc = TestRunDocumentReference('generated-provider-id');
      runsCollection = TestRunsCollection(autoDoc: autoDoc);
      rawRunsCollection = TestRunsRawCollection(runsCollection);
      firestore = TestFirebaseFirestore(runsCollection: rawRunsCollection);
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
      final runDoc = runsCollection.doc(run.id) as TestRunDocumentReference;
      runDoc.snapshotStream = Stream.value(
        TestRunDocumentSnapshot(
          referenceValue: runDoc,
          existsValue: true,
          dataValue: run,
        ),
      );

      container.listen(
        watchRunProvider(run.id),
        (_, _) {},
        fireImmediately: true,
      );
      await container.pump();

      expect(container.read(watchRunProvider(run.id)).value, run);
    });

    test('runsForClubProvider delegates to the repository', () async {
      final run = buildRun(id: 'run-1', runClubId: 'club-1');
      runsCollection.nextWhereResult = TestRunsQuery(
        snapshot: TestRunQuerySnapshot([
          TestRunQueryDocumentSnapshot(
            referenceValue: TestRunDocumentReference(run.id),
            dataValue: run,
          ),
        ]),
      );

      container.listen(
        runsForClubProvider('club-1'),
        (_, _) {},
        fireImmediately: true,
      );
      await container.pump();

      expect(container.read(runsForClubProvider('club-1')).value, [run]);
    });

    test('attendedRunsProvider delegates to the repository', () async {
      final run = buildRun(id: 'run-1');
      runsCollection.nextWhereResult = TestRunsQuery(
        snapshot: TestRunQuerySnapshot([
          TestRunQueryDocumentSnapshot(
            referenceValue: TestRunDocumentReference(run.id),
            dataValue: run,
          ),
        ]),
      );

      container.listen(
        attendedRunsProvider('runner-1'),
        (_, _) {},
        fireImmediately: true,
      );
      await container.pump();

      expect(container.read(attendedRunsProvider('runner-1')).value, [run]);
    });

    test('signedUpRunsProvider delegates to the repository', () async {
      final run = buildRun(id: 'run-1');
      runsCollection.nextWhereResult = TestRunsQuery(
        snapshot: TestRunQuerySnapshot([
          TestRunQueryDocumentSnapshot(
            referenceValue: TestRunDocumentReference(run.id),
            dataValue: run,
          ),
        ]),
      );

      container.listen(
        signedUpRunsProvider('runner-1'),
        (_, _) {},
        fireImmediately: true,
      );
      await container.pump();

      expect(container.read(signedUpRunsProvider('runner-1')).value, [run]);
    });

    test('recommendedRunsProvider delegates to the repository', () async {
      final run = buildRun(id: 'run-1', runClubId: 'club-1');
      runsCollection.nextWhereResult = TestRunsQuery(
        snapshot: TestRunQuerySnapshot([]),
        getSnapshot: TestRunQuerySnapshot([
          TestRunQueryDocumentSnapshot(
            referenceValue: TestRunDocumentReference(run.id),
            dataValue: run,
          ),
        ]),
      );

      final results = await container.read(
        recommendedRunsProvider(const ['club-1']).future,
      );

      expect(results, [run]);
    });
  });
}
