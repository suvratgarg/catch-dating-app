import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/runs/domain/run_draft.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'run_draft_repository.g.dart';

class RunDraftRepository {
  static const _maxDrafts = 5;
  static const _maxStaleDays = 7;

  Future<SharedPreferences> get _prefs => SharedPreferences.getInstance();

  String _key(String runClubId, String userId) =>
      'run_drafts_${runClubId}_$userId';

  Future<List<RunDraft>> loadDrafts({
    required String runClubId,
    required String userId,
  }) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_key(runClubId, userId));
    if (jsonString == null) return [];

    try {
      final allDrafts = RunDraft.listFromJson(jsonString);
      final staleThreshold =
          DateTime.now().subtract(const Duration(days: _maxStaleDays));
      final fresh = allDrafts
          .where((d) => d.savedAt.isAfter(staleThreshold))
          .toList();
      if (fresh.length != allDrafts.length) {
        await _writeDrafts(
          runClubId: runClubId,
          userId: userId,
          drafts: fresh,
          prefs: prefs,
        );
      }
      fresh.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return fresh;
    } catch (error, stack) {
      debugPrint('[ERROR] RunDraftRepository.loadDrafts: $error\n$stack');
      return [];
    }
  }

  Future<void> saveDraft({
    required String userId,
    required RunDraft draft,
  }) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_key(draft.runClubId, userId));
    final drafts = jsonString != null
        ? RunDraft.listFromJson(jsonString)
        : <RunDraft>[];

    final existingIndex = drafts.indexWhere((d) => d.id == draft.id);
    if (existingIndex != -1) {
      drafts[existingIndex] = draft;
    } else {
      drafts.add(draft);
      while (drafts.length > _maxDrafts) {
        drafts.remove(
          drafts.reduce((a, b) => a.savedAt.isBefore(b.savedAt) ? a : b),
        );
      }
    }

    await prefs.setString(
      _key(draft.runClubId, userId),
      RunDraft.listToJson(drafts),
    );
  }

  Future<void> deleteDraft({
    required String runClubId,
    required String userId,
    required String draftId,
  }) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_key(runClubId, userId));
    if (jsonString == null) return;

    final drafts = RunDraft.listFromJson(jsonString);
    drafts.removeWhere((d) => d.id == draftId);
    await _writeDrafts(
      runClubId: runClubId,
      userId: userId,
      drafts: drafts,
      prefs: prefs,
    );
  }

  Future<void> deleteAllDrafts({
    required String runClubId,
    required String userId,
  }) async {
    final prefs = await _prefs;
    await prefs.remove(_key(runClubId, userId));
  }

  Future<void> _writeDrafts({
    required String runClubId,
    required String userId,
    required List<RunDraft> drafts,
    required SharedPreferences prefs,
  }) async {
    if (drafts.isEmpty) {
      await prefs.remove(_key(runClubId, userId));
    } else {
      await prefs.setString(
        _key(runClubId, userId),
        RunDraft.listToJson(drafts),
      );
    }
  }
}

@riverpod
RunDraftRepository runDraftRepository(Ref ref) => RunDraftRepository();

@riverpod
Future<List<RunDraft>> clubRunDrafts(
  Ref ref, {
  required String runClubId,
}) async {
  final uid = requireSignedInUid(ref, action: 'load drafts');
  return ref.read(runDraftRepositoryProvider).loadDrafts(
        runClubId: runClubId,
        userId: uid,
      );
}
