import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'firestore_repository_test_helpers.dart';

class _FakeMatchRepository extends Fake implements MatchRepository {
  final matchesByUser = <String, List<Match>>{};
  final matchesById = <String, Match?>{};

  @override
  Stream<List<Match>> watchMatchesForUser({required String uid}) =>
      Stream.value(matchesByUser[uid] ?? const []);

  @override
  Stream<Match?> watchMatch({required String matchId}) =>
      Stream.value(matchesById[matchId]);
}

Match _buildMatch({
  String id = 'match-1',
  String user1Id = 'runner-1',
  String user2Id = 'runner-2',
  Map<String, int> unreadCounts = const {},
}) {
  return Match(
    id: id,
    user1Id: user1Id,
    user2Id: user2Id,
    runId: 'run-1',
    createdAt: DateTime(2025, 1, 1, 7),
    unreadCounts: unreadCounts,
  );
}

void main() {
  group('MatchRepository', () {
    late TestTypedCollection<Match> typedMatchesCollection;
    late TestRawCollection<Match> rawMatchesCollection;
    late MatchRepository repository;

    setUp(() {
      typedMatchesCollection = TestTypedCollection<Match>(
        pathPrefix: 'matches',
      );
      rawMatchesCollection = TestRawCollection<Match>(
        pathPrefix: 'matches',
        convertedCollection: typedMatchesCollection,
      );
      repository = MatchRepository(
        TestFirebaseFirestore(
          collectionsByPath: {
            'matches': rawMatchesCollection,
          },
        ),
      );
    });

    test('watchMatchesForUser filters by participant and orders newest first', () async {
      final match = _buildMatch();
      final query = TestTypedQuery<Match>(
        snapshotStream: Stream.value(
          TestTypedQuerySnapshot<Match>([
            TestTypedQueryDocumentSnapshot<Match>(
              referenceValue:
                  typedMatchesCollection.doc(match.id),
              dataValue: match,
            ),
          ]),
        ),
      );
      typedMatchesCollection.nextWhereResult = query;

      await expectLater(
        repository.watchMatchesForUser(uid: 'runner-1'),
        emits([match]),
      );

      expect(typedMatchesCollection.lastWhereField, 'participantIds');
      expect(typedMatchesCollection.lastArrayContains, 'runner-1');
      expect(query.lastOrderByField, 'createdAt');
      expect(query.lastOrderByDescending, isTrue);
    });

    test('watchMatch emits the match when the document exists', () async {
      final match = _buildMatch();
      final matchDoc =
          typedMatchesCollection.doc(match.id) as TestTypedDocumentReference<Match>;
      matchDoc.snapshotStream = Stream.value(
        TestTypedDocumentSnapshot<Match>(
          referenceValue: matchDoc,
          existsValue: true,
          dataValue: match,
        ),
      );

      await expectLater(repository.watchMatch(matchId: match.id), emits(match));
    });

    test('watchMatch emits null when the document is missing', () async {
      final matchDoc =
          typedMatchesCollection.doc('missing-match')
              as TestTypedDocumentReference<Match>;
      matchDoc.snapshotStream = Stream.value(
        TestTypedDocumentSnapshot<Match>(
          referenceValue: matchDoc,
          existsValue: false,
          dataValue: null,
        ),
      );

      await expectLater(
        repository.watchMatch(matchId: 'missing-match'),
        emits(isNull),
      );
    });

    test('resetUnread updates the unread count field for the user', () async {
      final matchDoc =
          typedMatchesCollection.doc('match-1') as TestTypedDocumentReference<Match>;

      await repository.resetUnread(matchId: 'match-1', uid: 'runner-1');

      expect(matchDoc.updateCalls, [
        {'unreadCounts.runner-1': 0},
      ]);
    });

    test('resetUnread swallows update failures', () async {
      final matchDoc =
          typedMatchesCollection.doc('match-1') as TestTypedDocumentReference<Match>;
      matchDoc.updateError = StateError('missing match');

      await repository.resetUnread(matchId: 'match-1', uid: 'runner-1');

      expect(matchDoc.updateCalls, isEmpty);
    });
  });

  test('matchStreamProvider streams the selected match', () async {
    final fakeRepository = _FakeMatchRepository();
    final match = _buildMatch();
    fakeRepository.matchesById[match.id] = match;
    final container = ProviderContainer(
      overrides: [
        matchRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen<AsyncValue<Match?>>(
      matchStreamProvider(match.id),
      (_, _) {},
    );
    addTearDown(subscription.close);

    final value = await container.read(matchStreamProvider(match.id).future);

    expect(value, match);
  });

  test('totalUnreadCount sums unread counts across matches', () async {
    final fakeRepository = _FakeMatchRepository();
    fakeRepository.matchesByUser['runner-1'] = [
      _buildMatch(id: 'match-1', unreadCounts: const {'runner-1': 2}),
      _buildMatch(id: 'match-2', unreadCounts: const {'runner-1': 3}),
    ];
    final container = ProviderContainer(
      overrides: [
        matchRepositoryProvider.overrideWithValue(fakeRepository),
      ],
    );
    addTearDown(container.dispose);
    final subscription = container.listen<AsyncValue<List<Match>>>(
      matchesForUserProvider('runner-1'),
      (_, _) {},
    );
    addTearDown(subscription.close);

    await container.read(matchesForUserProvider('runner-1').future);

    expect(container.read(totalUnreadCountProvider('runner-1')), 5);
  });
}
