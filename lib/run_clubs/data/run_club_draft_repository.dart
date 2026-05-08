import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_draft.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'run_club_draft_repository.g.dart';

class RunClubDraftRepository {
  static const _maxStaleDays = 7;

  SharedPreferences? _prefsInstance;

  Future<SharedPreferences> get _prefs async {
    _prefsInstance ??= await SharedPreferences.getInstance();
    return _prefsInstance!;
  }

  String _key(String userId) => 'run_club_draft_$userId';

  Future<RunClubDraft?> loadDraft({required String userId}) async {
    final prefs = await _prefs;
    final jsonString = prefs.getString(_key(userId));
    if (jsonString == null) return null;

    try {
      final draft = RunClubDraft.fromJsonString(jsonString);
      if (draft == null) return null;
      final staleThreshold = DateTime.now().subtract(
        const Duration(days: _maxStaleDays),
      );
      if (draft.savedAt.isBefore(staleThreshold)) {
        await deleteDraft(userId: userId);
        return null;
      }
      return draft;
    } catch (error, stack) {
      debugPrint('[ERROR] RunClubDraftRepository.loadDraft: $error\n$stack');
      return null;
    }
  }

  Future<void> saveDraft({
    required String userId,
    required RunClubDraft draft,
  }) async {
    final prefs = await _prefs;
    await prefs.setString(_key(userId), RunClubDraft.toJsonString(draft));
  }

  Future<void> deleteDraft({required String userId}) async {
    final prefs = await _prefs;
    await prefs.remove(_key(userId));
  }
}

@riverpod
RunClubDraftRepository runClubDraftRepository(Ref ref) =>
    RunClubDraftRepository();

@riverpod
Future<RunClubDraft?> runClubDraft(Ref ref) async {
  final uid = requireSignedInUid(ref, action: 'load run club draft');
  return ref.read(runClubDraftRepositoryProvider).loadDraft(userId: uid);
}
