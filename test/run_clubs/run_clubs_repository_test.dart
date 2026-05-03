// ignore_for_file: must_be_immutable, override_on_non_overriding_member, subtype_of_sealed_class

import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'run_clubs_test_helpers.dart';

class TestFirebaseFirestore extends Fake implements FirebaseFirestore {
  TestFirebaseFirestore({
    required this.runClubsCollection,
    required this.usersCollection,
  });

  final CollectionReference<Map<String, dynamic>> runClubsCollection;
  final CollectionReference<Map<String, dynamic>> usersCollection;
  TestWriteBatch? batchValue;
  TestTransaction? transactionValue;

  @override
  CollectionReference<Map<String, dynamic>> collection(String collectionPath) {
    switch (collectionPath) {
      case 'runClubs':
        return runClubsCollection;
      case 'users':
        return usersCollection;
      default:
        throw UnimplementedError('Unexpected collection path: $collectionPath');
    }
  }

  @override
  WriteBatch batch() => batchValue!;

  @override
  Future<T> runTransaction<T>(
    TransactionHandler<T> transactionHandler, {
    Duration timeout = const Duration(seconds: 30),
    int maxAttempts = 5,
  }) async {
    return transactionHandler(transactionValue!);
  }
}

class TestRunClubsRawCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  TestRunClubsRawCollection(this.convertedCollection);

  final TestRunClubsCollection convertedCollection;
  FromFirestore<RunClub>? lastFromFirestore;
  ToFirestore<RunClub>? lastToFirestore;

  @override
  CollectionReference<R> withConverter<R>({
    required FromFirestore<R> fromFirestore,
    required ToFirestore<R> toFirestore,
  }) {
    if (R != RunClub) {
      throw UnimplementedError(
        'Only RunClub conversion is supported in tests.',
      );
    }
    lastFromFirestore = fromFirestore as FromFirestore<RunClub>;
    lastToFirestore = toFirestore as ToFirestore<RunClub>;
    return convertedCollection as CollectionReference<R>;
  }
}

class TestRunClubsCollection extends Fake
    implements CollectionReference<RunClub> {
  TestRunClubsCollection({required this.autoDoc});

  final TestRunClubDocumentReference autoDoc;
  final docsById = <String, TestRunClubDocumentReference>{};
  TestRunClubsQuery? nextWhereResult;
  Object? lastWhereField;
  Object? lastWhereEqualTo;

  @override
  DocumentReference<RunClub> doc([String? path]) {
    if (path == null) {
      return autoDoc;
    }
    return docsById.putIfAbsent(path, () => TestRunClubDocumentReference(path));
  }

  @override
  Query<RunClub> where(
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
    lastWhereField = field;
    lastWhereEqualTo = isEqualTo;
    return nextWhereResult!;
  }
}

class TestRunClubsQuery extends Fake implements Query<RunClub> {
  TestRunClubsQuery(this.snapshot);

  final QuerySnapshot<RunClub> snapshot;
  Object? lastOrderByField;
  bool? lastOrderByDescending;

  @override
  Query<RunClub> orderBy(Object field, {bool descending = false}) {
    lastOrderByField = field;
    lastOrderByDescending = descending;
    return this;
  }

  @override
  Stream<QuerySnapshot<RunClub>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) => Stream.value(snapshot);
}

class TestRunClubDocumentReference extends Fake
    implements DocumentReference<RunClub> {
  TestRunClubDocumentReference(this.id);

  @override
  final String id;
  RunClub? getResultData;
  bool getResultExists = true;
  Stream<DocumentSnapshot<RunClub>> snapshotStream = const Stream.empty();
  final setCalls = <RunClub>[];
  final updateCalls = <Map<Object, Object?>>[];
  bool deleteCalled = false;

  @override
  String get path => 'runClubs/$id';

  @override
  Future<DocumentSnapshot<RunClub>> get([GetOptions? options]) async =>
      TestRunClubDocumentSnapshot(
        referenceValue: this,
        existsValue: getResultExists,
        dataValue: getResultData,
      );

  @override
  Stream<DocumentSnapshot<RunClub>> snapshots({
    bool includeMetadataChanges = false,
    ListenSource source = ListenSource.defaultSource,
  }) => snapshotStream;

  @override
  Future<void> set(RunClub data, [SetOptions? options]) async {
    setCalls.add(data);
  }

  @override
  Future<void> update(Map<Object, Object?> data) async {
    updateCalls.add(data);
  }

  @override
  Future<void> delete() async {
    deleteCalled = true;
  }
}

class TestMapDocumentReference extends Fake
    implements DocumentReference<Map<String, dynamic>> {
  TestMapDocumentReference(this.id);

  @override
  final String id;

  @override
  String get path => 'users/$id';
}

class TestUsersCollection extends Fake
    implements CollectionReference<Map<String, dynamic>> {
  final docsById = <String, TestMapDocumentReference>{};

  @override
  DocumentReference<Map<String, dynamic>> doc([String? path]) {
    return docsById.putIfAbsent(path!, () => TestMapDocumentReference(path));
  }
}

class TestRunClubDocumentSnapshot extends Fake
    implements DocumentSnapshot<RunClub> {
  TestRunClubDocumentSnapshot({
    required this.referenceValue,
    required this.existsValue,
    required this.dataValue,
  });

  @override
  final DocumentReference<RunClub> referenceValue;
  final bool existsValue;
  final RunClub? dataValue;

  @override
  bool get exists => existsValue;

  @override
  String get id => referenceValue.id;

  @override
  DocumentReference<RunClub> get reference => referenceValue;

  @override
  RunClub? data() => dataValue;
}

class TestRunClubQuerySnapshot extends Fake implements QuerySnapshot<RunClub> {
  TestRunClubQuerySnapshot(this.docsValue);

  final List<QueryDocumentSnapshot<RunClub>> docsValue;

  @override
  List<QueryDocumentSnapshot<RunClub>> get docs => docsValue;

  @override
  List<DocumentChange<RunClub>> get docChanges => const [];

  @override
  int get size => docsValue.length;
}

class TestRunClubQueryDocumentSnapshot extends Fake
    implements QueryDocumentSnapshot<RunClub> {
  TestRunClubQueryDocumentSnapshot({
    required this.referenceValue,
    required this.dataValue,
  });

  @override
  final DocumentReference<RunClub> referenceValue;
  final RunClub dataValue;

  @override
  bool get exists => true;

  @override
  String get id => referenceValue.id;

  @override
  DocumentReference<RunClub> get reference => referenceValue;

  @override
  RunClub data() => dataValue;
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

class RecordedSetCall {
  const RecordedSetCall({
    required this.document,
    required this.data,
    this.options,
  });

  final Object document;
  final Object? data;
  final SetOptions? options;
}

class TestWriteBatch extends Fake implements WriteBatch {
  final setCalls = <RecordedSetCall>[];
  bool commitCalled = false;

  @override
  void set<T>(DocumentReference<T> document, T data, [SetOptions? options]) {
    setCalls.add(
      RecordedSetCall(document: document, data: data, options: options),
    );
  }

  @override
  Future<void> commit() async {
    commitCalled = true;
  }
}

class TestTransaction extends Fake implements Transaction {
  final snapshotByDocument = <Object, Object>{};
  final setCalls = <RecordedSetCall>[];
  final updateCalls = <Map<Object, Object?>>[];

  void registerSnapshot<T>(
    DocumentReference<T> document,
    DocumentSnapshot<T> snapshot,
  ) {
    snapshotByDocument[document] = snapshot;
  }

  @override
  Future<DocumentSnapshot<T>> get<T>(
    DocumentReference<T> documentReference,
  ) async {
    return snapshotByDocument[documentReference]! as DocumentSnapshot<T>;
  }

  @override
  Transaction set<T>(
    DocumentReference<T> documentReference,
    T data, [
    SetOptions? options,
  ]) {
    setCalls.add(
      RecordedSetCall(
        document: documentReference,
        data: data,
        options: options,
      ),
    );
    return this;
  }

  @override
  Transaction update(
    DocumentReference<Object?> documentReference,
    Map<Object, Object?> data,
  ) {
    updateCalls.add(data);
    return this;
  }
}

void main() {
  group('RunClubsRepository', () {
    late TestRunClubDocumentReference autoDoc;
    late TestRunClubsCollection runClubsCollection;
    late TestUsersCollection usersCollection;
    late TestRunClubsRawCollection rawRunClubsCollection;
    late TestFirebaseFirestore firestore;
    late RunClubsRepository repository;

    setUp(() {
      autoDoc = TestRunClubDocumentReference('generated-id');
      runClubsCollection = TestRunClubsCollection(autoDoc: autoDoc);
      usersCollection = TestUsersCollection();
      rawRunClubsCollection = TestRunClubsRawCollection(runClubsCollection);
      firestore = TestFirebaseFirestore(
        runClubsCollection: rawRunClubsCollection,
        usersCollection: usersCollection,
      );
      repository = RunClubsRepository(firestore);
    });

    test('generateId uses an auto-generated document reference', () {
      expect(repository.generateId(), 'generated-id');
    });

    test(
      'converter round-trips Firestore data and injects the document id',
      () {
        repository.generateId();

        final fromFirestore = rawRunClubsCollection.lastFromFirestore!;
        final toFirestore = rawRunClubsCollection.lastToFirestore!;
        final decoded = fromFirestore(
          TestMapDocumentSnapshot(
            idValue: 'club-77',
            dataValue: buildRunClub(id: 'ignored').toJson(),
          ),
          null,
        );
        final encoded = toFirestore(buildRunClub(id: 'club-88'), null);

        expect(decoded.id, 'club-77');
        expect(decoded.name, 'Stride Social');
        expect(encoded.containsKey('id'), isFalse);
        expect(encoded['name'], 'Stride Social');
      },
    );

    test(
      'watchRunClub emits the decoded club when the document exists',
      () async {
        final clubDoc =
            runClubsCollection.doc('club-1') as TestRunClubDocumentReference;
        final club = buildRunClub(id: 'club-1');
        clubDoc.snapshotStream = Stream.value(
          TestRunClubDocumentSnapshot(
            referenceValue: clubDoc,
            existsValue: true,
            dataValue: club,
          ),
        );

        await expectLater(repository.watchRunClub('club-1'), emits(club));
      },
    );

    test('watchRunClub emits null when the document is missing', () async {
      final clubDoc =
          runClubsCollection.doc('club-missing')
              as TestRunClubDocumentReference;
      clubDoc.snapshotStream = Stream.value(
        TestRunClubDocumentSnapshot(
          referenceValue: clubDoc,
          existsValue: false,
          dataValue: null,
        ),
      );

      await expectLater(repository.watchRunClub('club-missing'), emits(null));
    });

    test('fetchRunClub returns the decoded club when found', () async {
      final clubDoc =
          runClubsCollection.doc('club-1') as TestRunClubDocumentReference;
      final club = buildRunClub(id: 'club-1');
      clubDoc.getResultData = club;
      clubDoc.getResultExists = true;

      expect(await repository.fetchRunClub('club-1'), club);
    });

    test('fetchRunClub returns null when the document is missing', () async {
      final clubDoc =
          runClubsCollection.doc('club-missing')
              as TestRunClubDocumentReference;
      clubDoc.getResultData = null;
      clubDoc.getResultExists = false;

      expect(await repository.fetchRunClub('club-missing'), isNull);
    });

    test('watchRunClubsByLocation queries by city and createdAt', () async {
      final club = buildRunClub(id: 'club-1', location: IndianCity.mumbai);
      final query = TestRunClubsQuery(
        TestRunClubQuerySnapshot([
          TestRunClubQueryDocumentSnapshot(
            referenceValue: TestRunClubDocumentReference(club.id),
            dataValue: club,
          ),
        ]),
      );
      runClubsCollection.nextWhereResult = query;

      await expectLater(
        repository.watchRunClubsByLocation(IndianCity.mumbai),
        emits([club]),
      );
      expect(runClubsCollection.lastWhereField, 'location');
      expect(runClubsCollection.lastWhereEqualTo, IndianCity.mumbai.name);
      expect(query.lastOrderByField, 'createdAt');
      expect(query.lastOrderByDescending, isTrue);
    });

    test('watchRunClubsByLocationSortedByRating orders by rating', () async {
      final club = buildRunClub(
        id: 'club-top',
        location: IndianCity.delhi,
        rating: 4.9,
      );
      final query = TestRunClubsQuery(
        TestRunClubQuerySnapshot([
          TestRunClubQueryDocumentSnapshot(
            referenceValue: TestRunClubDocumentReference(club.id),
            dataValue: club,
          ),
        ]),
      );
      runClubsCollection.nextWhereResult = query;

      await expectLater(
        repository.watchRunClubsByLocationSortedByRating(IndianCity.delhi),
        emits([club]),
      );
      expect(query.lastOrderByField, 'rating');
      expect(query.lastOrderByDescending, isTrue);
    });

    test('createRunClub writes the club and follows it for the host', () async {
      final batch = TestWriteBatch();
      firestore.batchValue = batch;
      runClubsCollection.docsById['club-42'] = TestRunClubDocumentReference(
        'club-42',
      );
      final beforeCreate = DateTime.now();

      final createdId = await repository.createRunClub(
        clubId: 'club-42',
        name: 'Sunset Striders',
        description: 'Easy city loops',
        location: IndianCity.mumbai,
        area: 'Bandra',
        hostUserId: 'host-1',
        hostName: 'Priya',
        hostAvatarUrl: 'https://example.com/host.jpg',
        imageUrl: 'https://example.com/cover.jpg',
      );

      expect(createdId, 'club-42');
      expect(batch.setCalls, hasLength(2));

      final createdClub = batch.setCalls.first.data as RunClub;
      expect(createdClub.id, 'club-42');
      expect(createdClub.name, 'Sunset Striders');
      expect(createdClub.hostName, 'Priya');
      expect(createdClub.imageUrl, 'https://example.com/cover.jpg');
      expect(createdClub.memberUserIds, ['host-1']);
      expect(createdClub.memberCount, 1);
      expect(createdClub.createdAt.isBefore(beforeCreate), isFalse);

      final userWrite = batch.setCalls.last;
      expect(
        userWrite.data,
        containsPair('joinedRunClubIds', isA<FieldValue>()),
      );
      expect(userWrite.options?.merge, isTrue);
      expect(batch.commitCalled, isTrue);
    });

    test('createRunClub passes contact fields through to Firestore', () async {
      final batch = TestWriteBatch();
      firestore.batchValue = batch;
      runClubsCollection.docsById['club-42'] = TestRunClubDocumentReference(
        'club-42',
      );

      await repository.createRunClub(
        clubId: 'club-42',
        name: 'Contact Club',
        description: 'A club with contact info.',
        location: IndianCity.mumbai,
        area: 'Bandra',
        hostUserId: 'host-1',
        hostName: 'Priya',
        instagramHandle: '@contactclub',
        phoneNumber: '+91 99999 99999',
        email: 'hello@contactclub.com',
      );

      final createdClub = batch.setCalls.first.data as RunClub;
      expect(createdClub.instagramHandle, '@contactclub');
      expect(createdClub.phoneNumber, '+91 99999 99999');
      expect(createdClub.email, 'hello@contactclub.com');
    });

    test('createRunClub stores null for absent contact fields', () async {
      final batch = TestWriteBatch();
      firestore.batchValue = batch;
      runClubsCollection.docsById['club-42'] = TestRunClubDocumentReference(
        'club-42',
      );

      await repository.createRunClub(
        clubId: 'club-42',
        name: 'No Contact Club',
        description: 'A club without contact info.',
        location: IndianCity.mumbai,
        area: 'Bandra',
        hostUserId: 'host-1',
        hostName: 'Priya',
      );

      final createdClub = batch.setCalls.first.data as RunClub;
      expect(createdClub.instagramHandle, isNull);
      expect(createdClub.phoneNumber, isNull);
      expect(createdClub.email, isNull);
    });

    test('updateRunClub delegates to doc.update with the given fields', () async {
      final clubDoc =
          runClubsCollection.doc('club-1') as TestRunClubDocumentReference;

      await repository.updateRunClub(
        clubId: 'club-1',
        fields: {'name': 'New Name', 'area': 'New Area'},
      );

      expect(clubDoc.updateCalls, [
        {'name': 'New Name', 'area': 'New Area'},
      ]);
    });

    test('deleteRunClub deletes the document', () async {
      final clubDoc =
          runClubsCollection.doc('club-1') as TestRunClubDocumentReference;

      await repository.deleteRunClub('club-1');

      expect(clubDoc.deleteCalled, isTrue);
    });

    test('updateRunClub patches specific fields via update', () async {
      final clubDoc =
          runClubsCollection.doc('club-1') as TestRunClubDocumentReference;

      await repository.updateRunClub(
        clubId: 'club-1',
        fields: {'imageUrl': 'https://example.com/updated.jpg'},
      );

      expect(clubDoc.updateCalls, [
        {'imageUrl': 'https://example.com/updated.jpg'},
      ]);
    });

    test(
      'joinClub adds the member and follows the club transactionally',
      () async {
        final clubDoc =
            runClubsCollection.doc('club-1') as TestRunClubDocumentReference;
        final userDoc = usersCollection.doc('runner-1');
        final transaction = TestTransaction();
        firestore.transactionValue = transaction;
        transaction.registerSnapshot(
          clubDoc,
          TestRunClubDocumentSnapshot(
            referenceValue: clubDoc,
            existsValue: true,
            dataValue: buildRunClub(id: 'club-1', memberCount: 99),
          ),
        );

        await repository.joinClub('club-1', 'runner-1');

        expect(transaction.updateCalls, hasLength(1));
        expect(transaction.setCalls, hasLength(1));

        final clubUpdate = transaction.updateCalls.first;
        expect(
          clubUpdate,
          containsPair('memberUserIds', isA<FieldValue>()),
        );
        expect(
          clubUpdate,
          containsPair('memberCount', isA<FieldValue>()),
        );

        final userWrite = transaction.setCalls.first;
        expect(userWrite.document, same(userDoc));
        expect(
          userWrite.data,
          containsPair('joinedRunClubIds', isA<FieldValue>()),
        );
        expect(userWrite.options?.merge, isTrue);
      },
    );

    test('joinClub throws when the club no longer exists', () async {
      final clubDoc =
          runClubsCollection.doc('missing-club')
              as TestRunClubDocumentReference;
      final transaction = TestTransaction();
      firestore.transactionValue = transaction;
      transaction.registerSnapshot(
        clubDoc,
        TestRunClubDocumentSnapshot(
          referenceValue: clubDoc,
          existsValue: false,
          dataValue: null,
        ),
      );

      expect(
        () => repository.joinClub('missing-club', 'runner-1'),
        throwsA(isA<DocumentNotFoundException>()),
      );
    });

    test(
      'leaveClub removes the member and unfollows the club transactionally',
      () async {
        final clubDoc =
            runClubsCollection.doc('club-1') as TestRunClubDocumentReference;
        final userDoc = usersCollection.doc('runner-1');
        final transaction = TestTransaction();
        firestore.transactionValue = transaction;
        transaction.registerSnapshot(
          clubDoc,
          TestRunClubDocumentSnapshot(
            referenceValue: clubDoc,
            existsValue: true,
            dataValue: buildRunClub(
              id: 'club-1',
              memberUserIds: const ['host-1', 'runner-1'],
              memberCount: 99,
            ),
          ),
        );

        await repository.leaveClub('club-1', 'runner-1');

        expect(transaction.updateCalls, hasLength(1));
        expect(transaction.setCalls, hasLength(1));

        final clubUpdate = transaction.updateCalls.first;
        expect(
          clubUpdate,
          containsPair('memberUserIds', isA<FieldValue>()),
        );
        expect(
          clubUpdate,
          containsPair('memberCount', isA<FieldValue>()),
        );

        final userWrite = transaction.setCalls.first;
        expect(userWrite.document, same(userDoc));
        expect(
          userWrite.data,
          containsPair('joinedRunClubIds', isA<FieldValue>()),
        );
        expect(userWrite.options?.merge, isTrue);
      },
    );

    test('leaveClub throws when the club no longer exists', () async {
      final clubDoc =
          runClubsCollection.doc('missing-club')
              as TestRunClubDocumentReference;
      final transaction = TestTransaction();
      firestore.transactionValue = transaction;
      transaction.registerSnapshot(
        clubDoc,
        TestRunClubDocumentSnapshot(
          referenceValue: clubDoc,
          existsValue: false,
          dataValue: null,
        ),
      );

      expect(
        () => repository.leaveClub('missing-club', 'runner-1'),
        throwsA(isA<DocumentNotFoundException>()),
      );
    });

    test(
      'runClubsRepositoryProvider builds from firebaseFirestoreProvider',
      () {
        final container = ProviderContainer(
          overrides: [firebaseFirestoreProvider.overrideWithValue(firestore)],
        );
        addTearDown(container.dispose);

        expect(
          container.read(runClubsRepositoryProvider),
          isA<RunClubsRepository>(),
        );
      },
    );

    test('repository provider wrappers delegate to the repository', () async {
      final fakeRepository = FakeRunClubsRepository();
      final club = buildRunClub(id: 'club-1', location: IndianCity.mumbai);
      final topClub = buildRunClub(
        id: 'club-top',
        location: IndianCity.mumbai,
        rating: 4.9,
      );
      fakeRepository.clubsById[club.id] = club;
      fakeRepository.clubsByLocation[IndianCity.mumbai] = [club, topClub];

      final container = ProviderContainer(
        overrides: [
          runClubsRepositoryProvider.overrideWith((ref) => fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      final clubSubscription = container.listen(
        watchRunClubProvider(club.id),
        (_, _) {},
        fireImmediately: true,
      );
      final locationSubscription = container.listen(
        watchRunClubsByLocationProvider(IndianCity.mumbai),
        (_, _) {},
        fireImmediately: true,
      );
      final ratingSubscription = container.listen(
        watchRunClubsByLocationSortedByRatingProvider(IndianCity.mumbai),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(clubSubscription.close);
      addTearDown(locationSubscription.close);
      addTearDown(ratingSubscription.close);
      await container.pump();

      expect(clubSubscription.read().value, club);
      expect(locationSubscription.read().value, [club, topClub]);
      expect(ratingSubscription.read().value?.first.id, 'club-top');
      expect(await container.read(fetchRunClubProvider(club.id).future), club);
    });
  });
}
