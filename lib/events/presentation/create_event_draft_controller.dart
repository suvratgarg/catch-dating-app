import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_event_draft_controller.g.dart';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns create-event draft persistence. The create-event screen still owns form
/// field controllers and draft restoration because those are UI mechanics.
@riverpod
class CreateEventDraftController extends _$CreateEventDraftController {
  static final saveDraftMutation = Mutation<EventDraft?>();
  static final deleteDraftMutation = Mutation<void>();

  @override
  void build() {}

  Future<List<EventDraft>> loadDrafts({required String clubId}) {
    final uid = requireSignedInUid(ref, action: 'load drafts');
    return ref
        .read(eventDraftRepositoryProvider)
        .loadDrafts(clubId: clubId, userId: uid);
  }

  Future<EventDraft?> saveDraft(EventDraft draft) async {
    if (draft.isEmpty) return null;

    final uid = requireSignedInUid(ref, action: 'save draft');
    await ref
        .read(eventDraftRepositoryProvider)
        .saveDraft(userId: uid, draft: draft);
    return draft;
  }

  Future<void> deleteDraft({required String clubId, required String draftId}) {
    final uid = requireSignedInUid(ref, action: 'delete draft');
    return ref
        .read(eventDraftRepositoryProvider)
        .deleteDraft(clubId: clubId, userId: uid, draftId: draftId);
  }
}
