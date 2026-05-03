import 'package:catch_dating_app/runs/data/run_draft_repository.dart';
import 'package:catch_dating_app/runs/domain/run_draft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RunDraftRepository', () {
    late RunDraftRepository repo;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repo = RunDraftRepository();
    });

    RunDraft buildDraft({
      String id = 'draft-1',
      String runClubId = 'club-1',
      DateTime? savedAt,
      String? distance,
      String? meetingPoint,
    }) {
      return RunDraft(
        id: id,
        runClubId: runClubId,
        savedAt: savedAt ?? DateTime(2026, 5, 1),
        distance: distance,
        meetingPoint: meetingPoint,
      );
    }

    group('loadDrafts', () {
      test('returns empty list when no drafts exist', () async {
        final drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-1',
        );
        expect(drafts, isEmpty);
      });

      test('stale drafts are filtered out and removed', () async {
        final oldDraft = RunDraft(
          id: 'old-1',
          runClubId: 'club-1',
          savedAt: DateTime.now().subtract(const Duration(days: 10)),
          distance: '5',
        );
        await repo.saveDraft(userId: 'user-1', draft: oldDraft);

        final drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-1',
        );
        expect(drafts, isEmpty);
      });

      test('corrupted JSON returns empty list', () async {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('run_drafts_club-1_user-1', '{invalid');

        final drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-1',
        );
        expect(drafts, isEmpty);
      });
    });

    group('saveDraft / loadDrafts', () {
      test('save then load returns the same draft', () async {
        final draft = buildDraft(distance: '5');
        await repo.saveDraft(userId: 'user-1', draft: draft);

        final drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-1',
        );
        expect(drafts.length, 1);
        expect(drafts.first.id, 'draft-1');
        expect(drafts.first.distance, '5');
      });

      test('save with same ID updates instead of duplicating', () async {
        final draft1 = buildDraft(id: 'draft-1', distance: '5');
        await repo.saveDraft(userId: 'user-1', draft: draft1);

        final draft2 = buildDraft(
          id: 'draft-1',
          distance: '10',
          meetingPoint: 'Park',
        );
        await repo.saveDraft(userId: 'user-1', draft: draft2);

        final drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-1',
        );
        expect(drafts.length, 1);
        expect(drafts.first.distance, '10');
        expect(drafts.first.meetingPoint, 'Park');
      });

      test('sorted by savedAt descending (newest first)', () async {
        final old = buildDraft(
          id: 'old',
          savedAt: DateTime(2026, 5, 1),
          distance: '5',
        );
        final newer = buildDraft(
          id: 'new',
          savedAt: DateTime(2026, 5, 3),
          distance: '10',
        );
        await repo.saveDraft(userId: 'user-1', draft: old);
        await repo.saveDraft(userId: 'user-1', draft: newer);

        final drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-1',
        );
        expect(drafts.length, 2);
        expect(drafts[0].id, 'new');
        expect(drafts[1].id, 'old');
      });

      test('evicts oldest when exceeding max 5 drafts', () async {
        for (var i = 0; i < 7; i++) {
          await repo.saveDraft(
            userId: 'user-1',
            draft: buildDraft(
              id: 'draft-$i',
              savedAt: DateTime(2026, 5, i + 1),
              distance: '$i',
            ),
          );
        }

        final drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-1',
        );
        expect(drafts.length, 5);
        // Oldest (May 1) should be evicted
        final ids = drafts.map((d) => d.id).toList();
        expect(ids, contains('draft-6'));
        expect(ids, contains('draft-5'));
        expect(ids, isNot(contains('draft-0')));
      });
    });

    group('deleteDraft', () {
      test('removes the specified draft, leaves others', () async {
        await repo.saveDraft(userId: 'user-1', draft: buildDraft(id: 'd-1'));
        await repo.saveDraft(userId: 'user-1', draft: buildDraft(id: 'd-2'));

        await repo.deleteDraft(
          runClubId: 'club-1',
          userId: 'user-1',
          draftId: 'd-1',
        );

        final drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-1',
        );
        expect(drafts.length, 1);
        expect(drafts.first.id, 'd-2');
      });

      test('does nothing when draft not found', () async {
        await repo.saveDraft(userId: 'user-1', draft: buildDraft(id: 'd-1'));
        await repo.deleteDraft(
          runClubId: 'club-1',
          userId: 'user-1',
          draftId: 'nonexistent',
        );

        final drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-1',
        );
        expect(drafts.length, 1);
      });
    });

    group('deleteAllDrafts', () {
      test('clears all drafts for the club/user', () async {
        await repo.saveDraft(userId: 'user-1', draft: buildDraft(id: 'd-1'));
        await repo.saveDraft(userId: 'user-1', draft: buildDraft(id: 'd-2'));

        await repo.deleteAllDrafts(runClubId: 'club-1', userId: 'user-1');

        final drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-1',
        );
        expect(drafts, isEmpty);
      });
    });

    group('isolation', () {
      test('different clubIds produce isolated lists', () async {
        await repo.saveDraft(
          userId: 'user-1',
          draft: buildDraft(id: 'd-1', runClubId: 'club-1'),
        );
        await repo.saveDraft(
          userId: 'user-1',
          draft: buildDraft(id: 'd-2', runClubId: 'club-2'),
        );

        final club1Drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-1',
        );
        final club2Drafts = await repo.loadDrafts(
          runClubId: 'club-2',
          userId: 'user-1',
        );
        expect(club1Drafts.length, 1);
        expect(club2Drafts.length, 1);
        expect(club1Drafts.first.id, 'd-1');
        expect(club2Drafts.first.id, 'd-2');
      });

      test('different userIds produce isolated lists', () async {
        await repo.saveDraft(
          userId: 'user-1',
          draft: buildDraft(id: 'd-1'),
        );
        await repo.saveDraft(
          userId: 'user-2',
          draft: buildDraft(id: 'd-2'),
        );

        final user1Drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-1',
        );
        final user2Drafts = await repo.loadDrafts(
          runClubId: 'club-1',
          userId: 'user-2',
        );
        expect(user1Drafts.length, 1);
        expect(user2Drafts.length, 1);
        expect(user1Drafts.first.id, 'd-1');
        expect(user2Drafts.first.id, 'd-2');
      });
    });
  });
}
