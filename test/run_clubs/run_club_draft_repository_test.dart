import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/run_clubs/data/run_club_draft_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_draft.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RunClubDraftRepository', () {
    late RunClubDraftRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = RunClubDraftRepository();
    });

    test('returns null when no draft exists', () async {
      expect(await repository.loadDraft(userId: 'host-1'), isNull);
    });

    test('save then load returns the current user draft', () async {
      final draft = RunClubDraft(
        savedAt: DateTime.now(),
        name: 'Sunset Striders',
        area: 'Bandra',
        description: 'Easy social club.',
        location: IndianCity.mumbai,
        instagramHandle: '@sunsetstriders',
      );

      await repository.saveDraft(userId: 'host-1', draft: draft);

      final loaded = await repository.loadDraft(userId: 'host-1');
      expect(loaded, isNotNull);
      expect(loaded!.name, 'Sunset Striders');
      expect(loaded.location, IndianCity.mumbai);
      expect(loaded.instagramHandle, '@sunsetstriders');
    });

    test('different users have isolated drafts', () async {
      await repository.saveDraft(
        userId: 'host-1',
        draft: RunClubDraft(savedAt: DateTime.now(), name: 'One'),
      );
      await repository.saveDraft(
        userId: 'host-2',
        draft: RunClubDraft(savedAt: DateTime.now(), name: 'Two'),
      );

      expect((await repository.loadDraft(userId: 'host-1'))!.name, 'One');
      expect((await repository.loadDraft(userId: 'host-2'))!.name, 'Two');
    });

    test('stale drafts are discarded', () async {
      await repository.saveDraft(
        userId: 'host-1',
        draft: RunClubDraft(
          savedAt: DateTime.now().subtract(const Duration(days: 10)),
          name: 'Old club',
        ),
      );

      expect(await repository.loadDraft(userId: 'host-1'), isNull);
    });

    test('deleteDraft clears the persisted draft', () async {
      await repository.saveDraft(
        userId: 'host-1',
        draft: RunClubDraft(savedAt: DateTime.now(), name: 'Delete me'),
      );

      await repository.deleteDraft(userId: 'host-1');

      expect(await repository.loadDraft(userId: 'host-1'), isNull);
    });
  });
}
