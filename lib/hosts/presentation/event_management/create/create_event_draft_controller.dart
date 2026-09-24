import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/private_event_update_journal.dart';
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

  Future<PrivateEventCreateReceipt> createPrivateEvent({
    required String organizerId,
    required String requestId,
    required PrivateEventBasics basics,
  }) => PrivateEventSetupRepository(ref.read(firebaseFunctionsProvider)).create(
    organizerId: organizerId,
    requestId: requestId,
    basics: basics,
  );

  Future<PrivateEventCreateReceipt> updatePrivateEventBasics(
    PrivateEventBasicsUpdateRequest request,
  ) => PrivateEventSetupRepository(ref.read(firebaseFunctionsProvider))
      .update(request);

  Future<PrivateEventBasicSummary> getPrivateEventSetup({
    required String organizerId,
    required String eventId,
  }) => PrivateEventSetupRepository(ref.read(firebaseFunctionsProvider)).get(
    organizerId: organizerId,
    eventId: eventId,
  );

  Future<PrivateEventBasicsUpdateRequest?> loadPendingBasicsUpdate({
    required String organizerId,
    required String eventId,
  }) => const PrivateEventUpdateJournal().load(
    userId: requireSignedInUid(ref, action: 'load pending basics update'),
    organizerId: organizerId,
    eventId: eventId,
  );

  Future<void> savePendingBasicsUpdate(
    PrivateEventBasicsUpdateRequest request,
  ) => const PrivateEventUpdateJournal().save(
    userId: requireSignedInUid(ref, action: 'save pending basics update'),
    request: request,
  );

  Future<void> clearPendingBasicsUpdate(
    PrivateEventBasicsUpdateRequest request,
  ) => const PrivateEventUpdateJournal().clear(
    userId: requireSignedInUid(ref, action: 'clear pending basics update'),
    request: request,
  );
}
