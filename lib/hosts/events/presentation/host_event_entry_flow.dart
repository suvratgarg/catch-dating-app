import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_prefill.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/draft_picker_sheet.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

Future<void> runHostEventEntryFlow({
  required BuildContext context,
  required WidgetRef ref,
  required Club club,
  required HostEventEntryState state,
  required HostEventEntryIntent intent,
  required DateTime createdAt,
}) async {
  switch (intent) {
    case HostEventEntryIntent.resumeDraft:
      final draft = await _pickDraft(context: context, ref: ref, state: state);
      if (draft == null || !context.mounted) return;
      await _openCreateEvent(
        context: context,
        ref: ref,
        club: club,
        initialDraft: draft,
      );
    case HostEventEntryIntent.repeatLastEvent:
      final source = state.repeatSource;
      if (source == null) return;
      await _openRepeatEvent(
        context: context,
        ref: ref,
        club: club,
        event: source,
        createdAt: createdAt,
      );
    case HostEventEntryIntent.createWithCatchBookings:
      await _openCreateEvent(context: context, ref: ref, club: club);
    case HostEventEntryIntent.createFromGuestList:
      await _openExternalEvent(context: context, ref: ref, club: club);
  }
}

Future<EventDraft?> _pickDraft({
  required BuildContext context,
  required WidgetRef ref,
  required HostEventEntryState state,
}) async {
  if (!state.hasMultipleDrafts) return state.mostRecentDraft;
  return showDraftPickerSheet(
    context: context,
    drafts: state.drafts,
    showStartFreshAction: false,
    onDeleteDraft: (draft) async {
      await CreateEventDraftController.deleteDraftMutation.run(ref, (tx) {
        return tx
            .get(createEventDraftControllerProvider.notifier)
            .deleteDraft(clubId: draft.clubId, draftId: draft.id);
      });
      ref.invalidate(clubEventDraftsProvider(clubId: draft.clubId));
    },
  );
}

Future<void> _openCreateEvent({
  required BuildContext context,
  required WidgetRef ref,
  required Club club,
  EventDraft? initialDraft,
}) async {
  await context.pushNamed(
    Routes.hostCreateEventScreen.name,
    pathParameters: {'clubId': club.id},
    extra: HostCreateEventRouteArguments(
      initialClub: club,
      initialDraft: initialDraft,
      externalBookingMode: initialDraft?.externalBookingMode ?? false,
      promptForDrafts: false,
    ),
  );
  ref.invalidate(clubEventDraftsProvider(clubId: club.id));
}

Future<void> _openExternalEvent({
  required BuildContext context,
  required WidgetRef ref,
  required Club club,
}) async {
  await context.pushNamed(
    Routes.hostCreateEventScreen.name,
    pathParameters: {'clubId': club.id},
    extra: HostCreateEventRouteArguments(
      initialClub: club,
      externalBookingMode: true,
      promptForDrafts: false,
    ),
  );
  ref.invalidate(clubEventDraftsProvider(clubId: club.id));
}

Future<void> _openRepeatEvent({
  required BuildContext context,
  required WidgetRef ref,
  required Club club,
  required Event event,
  required DateTime createdAt,
}) async {
  final prefill = CreateEventPrefill.repeat(event: event, createdAt: createdAt);
  await context.pushNamed(
    Routes.hostCreateEventScreen.name,
    pathParameters: {'clubId': club.id},
    extra: HostCreateEventRouteArguments(
      initialClub: club,
      initialPrefill: prefill,
      promptForDrafts: false,
    ),
  );
  ref.invalidate(clubEventDraftsProvider(clubId: club.id));
}
