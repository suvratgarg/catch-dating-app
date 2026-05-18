import 'dart:async';

import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<String> eventIds = const ['event-1'],
  DateTime? createdAt,
  DateTime? lastMessageAt,
  String? lastMessagePreview,
  String? lastMessageSenderId,
  MatchStatus status = MatchStatus.active,
  Map<String, int> unreadCounts = const {},
}) {
  return Match(
    id: id,
    user1Id: user1Id,
    user2Id: user2Id,
    eventIds: eventIds,
    createdAt: createdAt ?? DateTime(2025, 1, 1, 7),
    lastMessageAt: lastMessageAt,
    lastMessagePreview: lastMessagePreview,
    lastMessageSenderId: lastMessageSenderId,
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

    test(
      'watchMatchesForUser emits an empty list when both queries are empty',
      () async {
        await expectLater(
          repository.watchMatchesForUser(uid: 'runner-1'),
          emits(isEmpty),
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

  test(
    'totalUnreadCount counts unread conversations, not unread messages',
    () async {
      final fakeRepository = _FakeMatchRepository();
      fakeRepository.matchesByUser['runner-1'] = [
        _buildMatch(
          id: 'match-1',
          lastMessagePreview: 'Incoming one',
          lastMessageSenderId: 'runner-2',
          unreadCounts: const {'runner-1': 2},
        ),
        _buildMatch(
          id: 'match-2',
          user2Id: 'runner-3',
          lastMessagePreview: 'Incoming two',
          lastMessageSenderId: 'runner-3',
          unreadCounts: const {'runner-1': 3},
        ),
        _buildMatch(
          id: 'own-message',
          lastMessagePreview: 'Sent by me',
          lastMessageSenderId: 'runner-1',
          unreadCounts: const {'runner-1': 5},
        ),
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

      expect(container.read(totalUnreadCountProvider('runner-1')), 2);
    },
  );

  test('Match reads legacy eventId documents into eventIds', () {
    final match = Match.fromJson({
      'id': 'legacy-match',
      'user1Id': 'runner-1',
      'user2Id': 'runner-2',
      'eventId': 'legacy-event',
      'createdAt': Timestamp.fromDate(DateTime(2025, 1, 1, 7)),
    });

    expect(match.eventIds, const ['legacy-event']);
    expect(match.latestEventId, 'legacy-event');
  });

  test('collapseMatchesByOtherUser keeps one latest thread per person', () {
    final collapsed = collapseMatchesByOtherUser([
      _buildMatch(
        id: 'older',
        eventIds: const ['event-1'],
        createdAt: DateTime(2025, 1, 1, 7),
        lastMessageAt: DateTime(2025, 1, 1, 8),
        lastMessagePreview: 'Older message',
        lastMessageSenderId: 'runner-2',
        unreadCounts: const {'runner-1': 1},
      ),
      _buildMatch(
        id: 'newer',
        eventIds: const ['event-2'],
        createdAt: DateTime(2025, 1, 2, 7),
        lastMessageAt: DateTime(2025, 1, 2, 8),
        lastMessagePreview: 'Newer message',
        lastMessageSenderId: 'runner-2',
        unreadCounts: const {'runner-1': 2},
      ),
    ], 'runner-1');

    expect(collapsed, hasLength(1));
    expect(collapsed.single.id, 'newer');
    expect(collapsed.single.lastMessagePreview, 'Newer message');
    expect(collapsed.single.unreadCounts['runner-1'], 1);
    expect(collapsed.single.eventIds, const ['event-1', 'event-2']);
    expect(collapsed.single.latestEventId, 'event-2');
  });

  test(
    'collapseMatchesByOtherUser ignores stale unread values on own sent messages',
    () {
      final collapsed = collapseMatchesByOtherUser([
        _buildMatch(
          id: 'self-sent',
          createdAt: DateTime(2025, 1, 2, 7),
          lastMessageAt: DateTime(2025, 1, 2, 8),
          lastMessagePreview: 'Sent by me',
          lastMessageSenderId: 'runner-1',
          unreadCounts: const {'runner-1': 3},
        ),
      ], 'runner-1');

      expect(collapsed, hasLength(1));
      expect(collapsed.single.unreadCounts['runner-1'], 0);
      expect(collapsed.single.unreadConversationCountFor('runner-1'), 0);
    },
  );

  test(
    'matchStreamProvider auto-disposes route listeners when unwatched',
    () async {
      final match = _buildMatch();
      final cancelCompleter = Completer<void>();
      final matchController = StreamController<Match?>(
        onCancel: () {
          if (!cancelCompleter.isCompleted) cancelCompleter.complete();
        },
      );
      addTearDown(() async {
        if (!cancelCompleter.isCompleted) await matchController.close();
      });

      final container = ProviderContainer(
        overrides: [
          matchRepositoryProvider.overrideWithValue(
            _LifecycleMatchRepository(matchStream: matchController.stream),
          ),
        ],
      );
      addTearDown(container.dispose);

      final provider = matchStreamProvider(match.id);
      final subscription = container.listen(provider, (_, _) {});

      matchController.add(match);
      await container.pump();
      expect(subscription.read().value, match);

      subscription.close();
      await container.pump();

      await expectLater(cancelCompleter.future, completes);
    },
  );
}

class _LifecycleMatchRepository extends Fake implements MatchRepository {
  _LifecycleMatchRepository({this.matchStream});

  final Stream<Match?>? matchStream;

  @override
  Stream<Match?> watchMatch({required String matchId}) => matchStream!;
}

Future<void> _seedMatch(FakeFirebaseFirestore firestore, Match match) {
  return firestore.collection('matches').doc(match.id).set(match.toJson());
}
