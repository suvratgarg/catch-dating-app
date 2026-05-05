import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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
  DateTime? createdAt,
  MatchStatus status = MatchStatus.active,
  Map<String, int> unreadCounts = const {},
}) {
  return Match(
    id: id,
    user1Id: user1Id,
    user2Id: user2Id,
    runId: 'run-1',
    createdAt: createdAt ?? DateTime(2025, 1, 1, 7),
    status: status,
    unreadCounts: unreadCounts,
  );
}

void main() {
  group('MatchRepository', () {
    late FakeFirebaseFirestore firestore;
    late MatchRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = MatchRepository(firestore);
    });

    test(
      'watchMatchesForUser merges active matches from both user fields',
      () async {
        final olderMatch = _buildMatch(id: 'older', user1Id: 'runner-1');
        final newerMatch = _buildMatch(
          id: 'newer',
          user1Id: 'runner-2',
          user2Id: 'runner-1',
          createdAt: DateTime(2025, 1, 2, 7),
        );
        final blockedMatch = _buildMatch(
          id: 'blocked',
          user1Id: 'runner-1',
          status: MatchStatus.blocked,
          createdAt: DateTime(2025, 1, 3, 7),
        );
        await _seedMatch(firestore, olderMatch);
        await _seedMatch(firestore, newerMatch);
        await _seedMatch(firestore, blockedMatch);

        await expectLater(
          repository.watchMatchesForUser(uid: 'runner-1'),
          emits([newerMatch, olderMatch]),
        );
      },
    );

    test('watchMatch emits the match when the document exists', () async {
      final match = _buildMatch();
      await _seedMatch(firestore, match);

      await expectLater(repository.watchMatch(matchId: match.id), emits(match));
    });

    test('watchMatch emits null when the document is missing', () async {
      await expectLater(
        repository.watchMatch(matchId: 'missing-match'),
        emits(isNull),
      );
    });

    test('resetUnread updates the unread count field for the user', () async {
      final match = _buildMatch(unreadCounts: const {'runner-1': 4});
      await _seedMatch(firestore, match);

      await repository.resetUnread(matchId: 'match-1', uid: 'runner-1');

      final updated = await repository.watchMatch(matchId: 'match-1').first;
      expect(updated?.unreadCounts['runner-1'], 0);
    });

    test('resetUnread swallows missing match updates', () async {
      await repository.resetUnread(matchId: 'match-1', uid: 'runner-1');

      final snapshot = await firestore
          .collection('matches')
          .doc('match-1')
          .get();
      expect(snapshot.exists, isFalse);
    });
  });

  test('matchStreamProvider streams the selected match', () async {
    final fakeRepository = _FakeMatchRepository();
    final match = _buildMatch();
    fakeRepository.matchesById[match.id] = match;
    final container = ProviderContainer(
      overrides: [matchRepositoryProvider.overrideWithValue(fakeRepository)],
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
      overrides: [matchRepositoryProvider.overrideWithValue(fakeRepository)],
    );
    addTearDown(container.dispose);
    final subscription = container.listen<AsyncValue<List<Match>>>(
      watchMatchesForUserProvider('runner-1'),
      (_, _) {},
    );
    addTearDown(subscription.close);

    await container.read(watchMatchesForUserProvider('runner-1').future);

    expect(container.read(totalUnreadCountProvider('runner-1')), 5);
  });
}

Future<void> _seedMatch(FakeFirebaseFirestore firestore, Match match) {
  return firestore.collection('matches').doc(match.id).set(match.toJson());
}
