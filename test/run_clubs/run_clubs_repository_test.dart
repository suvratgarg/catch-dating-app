import 'dart:async';

import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'run_clubs_test_helpers.dart';

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
  group('RunClubsRepository', () {
    late FakeFirebaseFirestore firestore;
    late TestFirebaseFunctions functions;
    late RunClubsRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      functions = TestFirebaseFunctions();
      repository = RunClubsRepository(firestore, functions);
    });

    test('generateId uses an auto-generated document reference', () async {
      final generatedId = repository.generateId();

      expect(generatedId, isNotEmpty);
      final generatedDoc = await firestore
          .collection('runClubs')
          .doc(generatedId)
          .get();
      expect(generatedDoc.exists, isFalse);
    });

    test(
      'converter round-trips Firestore data and injects the document id',
      () async {
        final club = buildRunClub(id: 'club-88');

        await _seedRunClub(firestore, club);

        final decoded = await repository.fetchRunClub(club.id);
        final encoded =
            (await firestore.collection('runClubs').doc(club.id).get()).data()!;
        expect(decoded?.id, 'club-88');
        expect(decoded?.name, 'Stride Social');
        expect(encoded.containsKey('id'), isFalse);
        expect(encoded['name'], 'Stride Social');
      },
    );

    test(
      'watchRunClub emits the decoded club when the document exists',
      () async {
        final club = buildRunClub(id: 'club-1');
        await _seedRunClub(firestore, club);

        await expectLater(repository.watchRunClub('club-1'), emits(club));
      },
    );

    test('watchRunClub emits null when the document is missing', () async {
      await expectLater(repository.watchRunClub('club-missing'), emits(null));
    });

    test('fetchRunClub returns the decoded club when found', () async {
      final club = buildRunClub(id: 'club-1');
      await _seedRunClub(firestore, club);

      expect(await repository.fetchRunClub('club-1'), club);
    });

    test('fetchRunClub returns null when the document is missing', () async {
      expect(await repository.fetchRunClub('club-missing'), isNull);
    });

    test(
      'watchRunClubsByLocation filters by city and orders by createdAt',
      () async {
        final older = buildRunClub(
          id: 'older',
          location: 'mumbai',
          createdAt: DateTime(2025, 1, 1),
        );
        final newer = buildRunClub(
          id: 'newer',
          location: 'mumbai',
          createdAt: DateTime(2025, 1, 2),
        );
        await _seedRunClub(firestore, older);
        await _seedRunClub(firestore, newer);
        await _seedRunClub(
          firestore,
          buildRunClub(id: 'delhi-club', location: 'delhi'),
        );

        await expectLater(
          repository.watchRunClubsByLocation('mumbai'),
          emits([newer, older]),
        );
      },
    );

    test('watchRunClubsByLocationSortedByRating orders by rating', () async {
      final lowerRated = buildRunClub(
        id: 'club-low',
        location: 'delhi',
        rating: 3.8,
      );
      final topClub = buildRunClub(
        id: 'club-top',
        location: 'delhi',
        rating: 4.9,
      );
      await _seedRunClub(firestore, lowerRated);
      await _seedRunClub(firestore, topClub);

      await expectLater(
        repository.watchRunClubsByLocationSortedByRating('delhi'),
        emits([topClub, lowerRated]),
      );
    });

    test('watchRunClubsHostedBy filters by host user id', () async {
      final hosted = buildRunClub(id: 'hosted', hostUserId: 'host-1');
      final other = buildRunClub(id: 'other', hostUserId: 'host-2');
      await _seedRunClub(firestore, hosted);
      await _seedRunClub(firestore, other);

      await expectLater(
        repository.watchRunClubsHostedBy('host-1'),
        emits([hosted]),
      );
    });

    test('createRunClub delegates creation to the callable', () async {
      final callable =
          functions.httpsCallable('createRunClub') as TestHttpsCallable;
      callable.resultData = {'clubId': 'club-42'};

      final createdId = await repository.createRunClub(
        clubId: 'club-42',
        name: 'Sunset Striders',
        description: 'Easy city loops',
        location: 'mumbai',
        area: 'Bandra',
        imageUrl: 'https://example.com/cover.jpg',
      );

      expect(createdId, 'club-42');
      expect(callable.calls, [
        {
          'clubId': 'club-42',
          'name': 'Sunset Striders',
          'description': 'Easy city loops',
          'location': 'mumbai',
          'area': 'Bandra',
          'imageUrl': 'https://example.com/cover.jpg',
          'instagramHandle': null,
          'phoneNumber': null,
          'email': null,
        },
      ]);
    });

    test(
      'createRunClub passes contact fields through to the callable',
      () async {
        final callable =
            functions.httpsCallable('createRunClub') as TestHttpsCallable;
        callable.resultData = {'clubId': 'club-42'};

        await repository.createRunClub(
          clubId: 'club-42',
          name: 'Contact Club',
          description: 'A club with contact info.',
          location: 'mumbai',
          area: 'Bandra',
          instagramHandle: '@contactclub',
          phoneNumber: '+91 99999 99999',
          email: 'hello@contactclub.com',
        );

        expect(
          callable.calls.single,
          containsPair('instagramHandle', '@contactclub'),
        );
        expect(
          callable.calls.single,
          containsPair('phoneNumber', '+91 99999 99999'),
        );
        expect(
          callable.calls.single,
          containsPair('email', 'hello@contactclub.com'),
        );
      },
    );

    test('updateRunClub delegates field patches to the callable', () async {
      await repository.updateRunClub(
        clubId: 'club-1',
        fields: {'name': 'New Name', 'area': 'New Area'},
      );

      final callable =
          functions.httpsCallable('updateRunClub') as TestHttpsCallable;
      expect(callable.calls, [
        {
          'clubId': 'club-1',
          'fields': {'name': 'New Name', 'area': 'New Area'},
        },
      ]);
    });

    test(
      'updateRunClub delegates nullable media fields to the callable',
      () async {
        await repository.updateRunClub(
          clubId: 'club-1',
          fields: {'imageUrl': 'https://example.com/updated.jpg'},
        );

        final callable =
            functions.httpsCallable('updateRunClub') as TestHttpsCallable;
        expect(callable.calls, [
          {
            'clubId': 'club-1',
            'fields': {'imageUrl': 'https://example.com/updated.jpg'},
          },
        ]);
      },
    );

    test('joinClub delegates membership to the callable', () async {
      await repository.joinClub('club-1');

      expect(functions.callables['joinRunClub']?.calls, [
        {'clubId': 'club-1'},
      ]);
      expect(functions.callables.containsKey('leaveRunClub'), isFalse);
    });

    test('leaveClub delegates membership to the callable', () async {
      await repository.leaveClub('club-1');

      expect(functions.callables['leaveRunClub']?.calls, [
        {'clubId': 'club-1'},
      ]);
      expect(functions.callables.containsKey('joinRunClub'), isFalse);
    });

    test(
      'runClubsRepositoryProvider builds from firebaseFirestoreProvider',
      () {
        final container = ProviderContainer(
          overrides: [
            firebaseFirestoreProvider.overrideWithValue(firestore),
            firebaseFunctionsProvider.overrideWithValue(functions),
          ],
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
      final club = buildRunClub(id: 'club-1', location: 'mumbai');
      final topClub = buildRunClub(
        id: 'club-top',
        location: 'mumbai',
        rating: 4.9,
      );
      fakeRepository.clubsById[club.id] = club;
      fakeRepository.clubsById[topClub.id] = topClub;
      fakeRepository.clubsByLocation['mumbai'] = [club, topClub];

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
        watchRunClubsByLocationProvider('mumbai'),
        (_, _) {},
        fireImmediately: true,
      );
      final ratingSubscription = container.listen(
        watchRunClubsByLocationSortedByRatingProvider('mumbai'),
        (_, _) {},
        fireImmediately: true,
      );
      final hostedSubscription = container.listen(
        watchRunClubsHostedByProvider(club.hostUserId),
        (_, _) {},
        fireImmediately: true,
      );
      addTearDown(clubSubscription.close);
      addTearDown(locationSubscription.close);
      addTearDown(ratingSubscription.close);
      addTearDown(hostedSubscription.close);
      await container.pump();

      expect(clubSubscription.read().value, club);
      expect(locationSubscription.read().value, [club, topClub]);
      expect(ratingSubscription.read().value?.first.id, 'club-top');
      expect(hostedSubscription.read().value, [club, topClub]);
      expect(await container.read(fetchRunClubProvider(club.id).future), club);
    });

    testWidgets(
      'watchRunClubsByLocationProvider keeps realtime streams alive while idle',
      (tester) async {
        final club = buildRunClub(id: 'club-1', location: 'mumbai');
        final clubsController = StreamController<List<RunClub>>();
        addTearDown(clubsController.close);

        final container = ProviderContainer(
          overrides: [
            runClubsRepositoryProvider.overrideWith(
              (ref) => _IdleRunClubsRepository(
                clubsByLocationStream: clubsController.stream,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final provider = watchRunClubsByLocationProvider('mumbai');
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);

        clubsController.add([club]);
        await container.pump();
        expect(subscription.read().value, [club]);

        await tester.pump(_pastLegacyStreamTimeout);
        await container.pump();

        expect(subscription.read(), isA<AsyncData<List<RunClub>>>());
        expect(subscription.read().value, [club]);
      },
    );
  });
}

Future<void> _seedRunClub(FakeFirebaseFirestore firestore, RunClub club) {
  return firestore.collection('runClubs').doc(club.id).set(club.toJson());
}

class _IdleRunClubsRepository extends Fake implements RunClubsRepository {
  _IdleRunClubsRepository({required this.clubsByLocationStream});

  final Stream<List<RunClub>> clubsByLocationStream;

  @override
  Stream<List<RunClub>> watchRunClubsByLocation(String location) =>
      clubsByLocationStream;
}

const _pastLegacyStreamTimeout = Duration(seconds: 11);
