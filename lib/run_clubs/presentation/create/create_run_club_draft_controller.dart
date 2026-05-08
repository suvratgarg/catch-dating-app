import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/run_clubs/data/run_club_draft_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club_draft.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_run_club_draft_controller.g.dart';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns local create-run-club draft persistence. The screen owns text
/// controllers and restoration because those are UI mechanics.
@riverpod
class CreateRunClubDraftController extends _$CreateRunClubDraftController {
  static final saveDraftMutation = Mutation<RunClubDraft?>();
  static final deleteDraftMutation = Mutation<void>();

  @override
  void build() {}

  Future<RunClubDraft?> loadDraft() {
    final uid = requireSignedInUid(ref, action: 'load run club draft');
    return ref.read(runClubDraftRepositoryProvider).loadDraft(userId: uid);
  }

  Future<RunClubDraft?> saveDraft(RunClubDraft draft) async {
    if (draft.isEmpty) return null;

    final uid = requireSignedInUid(ref, action: 'save run club draft');
    await ref
        .read(runClubDraftRepositoryProvider)
        .saveDraft(userId: uid, draft: draft);
    return draft;
  }

  Future<void> deleteDraft() {
    final uid = requireSignedInUid(ref, action: 'delete run club draft');
    return ref.read(runClubDraftRepositoryProvider).deleteDraft(userId: uid);
  }
}
