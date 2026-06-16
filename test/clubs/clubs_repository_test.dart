import 'dart:async';

import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clubs_test_helpers.dart';

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
  group('ClubsRepository', () {
    late FakeFirebaseFirestore firestore;
    late TestFirebaseFunctions functions;
    late ClubsRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      functions = TestFirebaseFunctions();
      repository = ClubsRepository(firestore, functions);
    });

    test('generateId uses an auto-generated document reference', () async {
      final generatedId = repository.generateId();

      expect(generatedId, isNotEmpty);
      final generatedDoc = await firestore
          .collection('clubs')
          .doc(generatedId)
          .get();
      expect(generatedDoc.exists, isFalse);
    });

    test(
      'converter round-trips Firestore data and injects the document id',
      () async {
        final club = buildClub(id: 'club-88');

        await _seedClub(firestore, club);

        final decoded = await repository.fetchClub(club.id);
        final encoded = (await firestore.collection('clubs').doc(club.id).get())
            .data()!;
        expect(decoded?.id, 'club-88');
        expect(decoded?.name, 'Stride Social');
        expect(encoded.containsKey('id'), isFalse);
        expect(encoded['name'], 'Stride Social');
      },
    );

    test('converter accepts unclaimed organizer host fields', () async {
      final club = buildClub(
        id: 'unclaimed-club',
        name: 'Open Organizer',
        hostUserId: null,
        hostName: null,
      );

      await _seedClub(firestore, club);

      final decoded = await repository.fetchClub(club.id);
      expect(decoded?.hostUserId, isNull);
      expect(decoded?.hostName, isNull);
      expect(decoded?.displayHostName, 'Open Organizer');
      expect(decoded?.displayHostProfiles, isEmpty);
    });

    test('watchClub emits the decoded club when the document exists', () async {
      final club = buildClub();
      await _seedClub(firestore, club);

      await expectLater(repository.watchClub('club-1'), emits(club));
    });

    test('watchClub emits null when the document is missing', () async {
      await expectLater(repository.watchClub('club-missing'), emits(null));
    });

    test('fetchClub returns the decoded club when found', () async {
      final club = buildClub();
      await _seedClub(firestore, club);

      expect(await repository.fetchClub('club-1'), club);
    });

    test('fetchClub returns null when the document is missing', () async {
      expect(await repository.fetchClub('club-missing'), isNull);
    });

    test(
      'watchClubsByLocation filters by city and orders by createdAt',
      () async {
        final older = buildClub(id: 'older', createdAt: DateTime(2025));
        final newer = buildClub(id: 'newer', createdAt: DateTime(2025, 1, 2));
        await _seedClub(firestore, older);
        await _seedClub(firestore, newer);
        await _seedClub(
          firestore,
          buildClub(id: 'delhi-club', location: 'delhi'),
        );

        await expectLater(
          repository.watchClubsByLocation('mumbai'),
          emits([newer, older]),
        );
      },
    );

    test('watchClubsByLocation caps the discovery stream', () async {
      for (var i = 0; i < ClubsRepository.discoveryLimit + 5; i++) {
        await _seedClub(
          firestore,
          buildClub(
            id: 'club-$i',
            createdAt: DateTime(2025).add(Duration(days: i)),
          ),
        );
      }

      await expectLater(
        repository.watchClubsByLocation('mumbai'),
        emits(
          allOf(
            hasLength(ClubsRepository.discoveryLimit),
            predicate<List<Club>>((clubs) => clubs.first.id == 'club-34'),
          ),
        ),
      );
    });

    test('watchClubsByLocationSortedByRating orders by rating', () async {
      final lowerRated = buildClub(
        id: 'club-low',
        location: 'delhi',
        rating: 3.8,
      );
      final topClub = buildClub(id: 'club-top', location: 'delhi', rating: 4.9);
      await _seedClub(firestore, lowerRated);
      await _seedClub(firestore, topClub);

      await expectLater(
        repository.watchClubsByLocationSortedByRating('delhi'),
        emits([topClub, lowerRated]),
      );
    });

    test('watchClubsHostedBy filters by host user id', () async {
      final hosted = buildClub(id: 'hosted');
      final coHosted = buildClub(
        id: 'co-hosted',
        hostUserId: 'host-2',
        hostUserIds: const ['host-2', 'host-1'],
      );
      final other = buildClub(id: 'other', hostUserId: 'host-2');
      await _seedClub(firestore, hosted);
      await _seedClub(firestore, coHosted);
      await _seedClub(firestore, other);

      await expectLater(
        repository.watchClubsHostedBy('host-1'),
        emits(unorderedEquals([hosted, coHosted])),
      );
    });

    test('watchClubsOwnedBy filters out co-hosted clubs', () async {
      final owned = buildClub(
        id: 'owned',
        ownerUserId: 'host-1',
        hostUserIds: const ['host-1'],
      );
      final coHosted = buildClub(
        id: 'co-hosted',
        hostUserId: 'host-2',
        ownerUserId: 'host-2',
        hostUserIds: const ['host-2', 'host-1'],
      );
      await _seedClub(firestore, owned);
      await _seedClub(firestore, coHosted);

      await expectLater(repository.watchClubsOwnedBy('host-1'), emits([owned]));
    });

    test('createClub delegates creation to the callable', () async {
      final callable =
          functions.httpsCallable('createClub') as TestHttpsCallable;
      callable.resultData = {'clubId': 'club-42'};

      final createdId = await repository.createClub(
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
        },
      ]);
    });

    test('createClub passes contact fields through to the callable', () async {
      final callable =
          functions.httpsCallable('createClub') as TestHttpsCallable;
      callable.resultData = {'clubId': 'club-42'};

      await repository.createClub(
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
    });

    test('updateClub delegates field patches to the callable', () async {
      await repository.updateClub(
        clubId: 'club-1',
        patch: UpdateClubPatch(name: 'New Name', area: 'New Area'),
      );

      final callable =
          functions.httpsCallable('updateClub') as TestHttpsCallable;
      expect(callable.calls, [
        {
          'clubId': 'club-1',
          'fields': {'name': 'New Name', 'area': 'New Area'},
        },
      ]);
    });

    test(
      'updateClub delegates nullable media fields to the callable',
      () async {
        await repository.updateClub(
          clubId: 'club-1',
          patch: UpdateClubPatch(imageUrl: 'https://example.com/updated.jpg'),
        );

        final callable =
            functions.httpsCallable('updateClub') as TestHttpsCallable;
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

      expect(functions.callables['joinClub']?.calls, [
        {'clubId': 'club-1'},
      ]);
      expect(functions.callables.containsKey('leaveClub'), isFalse);
    });

    test('leaveClub delegates membership to the callable', () async {
      await repository.leaveClub('club-1');

      expect(functions.callables['leaveClub']?.calls, [
        {'clubId': 'club-1'},
      ]);
      expect(functions.callables.containsKey('joinClub'), isFalse);
    });

    test('clubsRepositoryProvider builds from firebaseFirestoreProvider', () {
      final container = ProviderContainer(
        overrides: [
          firebaseFirestoreProvider.overrideWithValue(firestore),
          firebaseFunctionsProvider.overrideWithValue(functions),
        ],
      );
      addTearDown(container.dispose);

      expect(container.read(clubsRepositoryProvider), isA<ClubsRepository>());
    });

    test('repository provider wrappers delegate to the repository', () async {
      final fakeRepository = FakeClubsRepository();
      final club = buildClub();
      final topClub = buildClub(id: 'club-top', rating: 4.9);
      fakeRepository.clubsById[club.id] = club;
      fakeRepository.clubsById[topClub.id] = topClub;
      fakeRepository.clubsByLocation['mumbai'] = [club, topClub];

      final container = ProviderContainer(
        overrides: [
          clubsRepositoryProvider.overrideWith((ref) => fakeRepository),
        ],
      );
      addTearDown(container.dispose);

      final clubSubscription = container.listen(
        watchClubProvider(club.id),
        (_, _) {},
        fireImmediately: true,
      );
      final locationSubscription = container.listen(
        watchClubsByLocationProvider('mumbai'),
        (_, _) {},
        fireImmediately: true,
      );
      final ratingSubscription = container.listen(
        watchClubsByLocationSortedByRatingProvider('mumbai'),
        (_, _) {},
        fireImmediately: true,
      );
      final hostedSubscription = container.listen(
        watchClubsHostedByProvider('host-1'),
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
      expect(await container.read(fetchClubProvider(club.id).future), club);
    });

    testWidgets(
      'watchClubsByLocationProvider keeps realtime streams alive while idle',
      (tester) async {
        final club = buildClub();
        final clubsController = StreamController<List<Club>>();
        addTearDown(clubsController.close);

        final container = ProviderContainer(
          overrides: [
            clubsRepositoryProvider.overrideWith(
              (ref) => _IdleClubsRepository(
                clubsByLocationStream: clubsController.stream,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final provider = watchClubsByLocationProvider('mumbai');
        final subscription = container.listen(provider, (_, _) {});
        addTearDown(subscription.close);

        clubsController.add([club]);
        await container.pump();
        expect(subscription.read().value, [club]);

        await tester.pump(_pastLegacyStreamTimeout);
        await container.pump();

        expect(subscription.read(), isA<AsyncData<List<Club>>>());
        expect(subscription.read().value, [club]);
      },
    );
  });
}

Future<void> _seedClub(FakeFirebaseFirestore firestore, Club club) {
  return firestore.collection('clubs').doc(club.id).set(club.toJson());
}

class _IdleClubsRepository extends Fake implements ClubsRepository {
  _IdleClubsRepository({required this.clubsByLocationStream});

  final Stream<List<Club>> clubsByLocationStream;

  @override
  Stream<List<Club>> watchClubsByLocation(String location) =>
      clubsByLocationStream;
}

const _pastLegacyStreamTimeout = Duration(seconds: 11);
