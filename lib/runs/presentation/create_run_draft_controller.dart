import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/runs/data/run_draft_repository.dart';
import 'package:catch_dating_app/runs/domain/run_draft.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_run_draft_controller.g.dart';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns create-run draft persistence. The create-run screen still owns form
/// field controllers and draft restoration because those are UI mechanics.
@riverpod
class CreateRunDraftController extends _$CreateRunDraftController {
  static final saveDraftMutation = Mutation<RunDraft?>();
  static final deleteDraftMutation = Mutation<void>();

  @override
  void build() {}

  Future<List<RunDraft>> loadDrafts({required String runClubId}) {
    final uid = requireSignedInUid(ref, action: 'load drafts');
    return ref
        .read(runDraftRepositoryProvider)
        .loadDrafts(runClubId: runClubId, userId: uid);
  }

  Future<RunDraft?> saveDraft(RunDraft draft) async {
    if (draft.isEmpty) return null;

    final uid = requireSignedInUid(ref, action: 'save draft');
    await ref
        .read(runDraftRepositoryProvider)
        .saveDraft(userId: uid, draft: draft);
    return draft;
  }

  Future<void> deleteDraft({
    required String runClubId,
    required String draftId,
  }) {
    final uid = requireSignedInUid(ref, action: 'delete draft');
    return ref
        .read(runDraftRepositoryProvider)
        .deleteDraft(runClubId: runClubId, userId: uid, draftId: draftId);
  }
}
