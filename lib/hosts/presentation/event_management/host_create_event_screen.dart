import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_prefill.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_wizard_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_route_loading_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_route_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_route_loading_screen.dart';

class HostCreateEventRouteArguments {
  const HostCreateEventRouteArguments({
    required this.initialClub,
    this.initialDraft,
    this.initialPrefill,
    this.externalBookingMode = false,
    this.initialRosterImportPlan,
    this.promptForDrafts = true,
  }) : assert(
         initialDraft == null || initialPrefill == null,
         'A create route cannot restore a draft and apply a repeat prefill.',
       );

  final Club initialClub;
  final EventDraft? initialDraft;
  final CreateEventPrefill? initialPrefill;
  final bool externalBookingMode;
  final HostRosterImportPlan? initialRosterImportPlan;
  final bool promptForDrafts;
}

class HostCreateEventRouteScreen extends ConsumerWidget {
  const HostCreateEventRouteScreen({
    super.key,
    required this.clubId,
    this.initialClub,
    this.initialDraft,
    this.initialPrefill,
    this.externalBookingMode = false,
    this.initialRosterImportPlan,
    this.promptForDrafts = true,
  }) : assert(
         initialDraft == null || initialPrefill == null,
         'A create route cannot restore a draft and apply a repeat prefill.',
       );

  final String clubId;
  final Club? initialClub;
  final EventDraft? initialDraft;
  final CreateEventPrefill? initialPrefill;
  final bool externalBookingMode;
  final HostRosterImportPlan? initialRosterImportPlan;
  final bool promptForDrafts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialClub = this.initialClub;
    final initialDraft = this.initialDraft;
    final initialPrefill = this.initialPrefill;
    if (initialClub != null && initialClub.id != clubId) {
      return CatchScreenScaffold.stepFlow(
        body: CatchErrorBody(
          title:
              context.l10n.hostsHostCreateEventScreenTitleEventSetupUnavailable,
          message: context
              .l10n
              .hostsHostCreateEventScreenMessageThatOrganizerDoesNot,
          secondaryAction: const CatchErrorBackAction(),
        ),
      );
    }
    if (initialPrefill != null && initialPrefill.values.clubId != clubId) {
      return CatchScreenScaffold.stepFlow(
        body: CatchErrorBody(
          title: context.l10n.hostsHostCreateEventScreenTitleRepeatUnavailable,
          message:
              context.l10n.hostsHostCreateEventScreenMessageThatEventBelongsTo,
          secondaryAction: const CatchErrorBackAction(),
        ),
      );
    }
    if (initialDraft != null && initialDraft.clubId != clubId) {
      return CatchScreenScaffold.stepFlow(
        body: CatchErrorBody(
          title:
              context.l10n.hostsHostCreateEventScreenTitleEventSetupUnavailable,
          message: context
              .l10n
              .hostsHostCreateEventScreenMessageThatOrganizerDoesNot,
          secondaryAction: const CatchErrorBackAction(),
        ),
      );
    }
    final routeState = HostCreateEventRouteState.resolve(
      initialClub: initialClub,
      fetchedClub: initialClub == null
          ? _catchAsyncState(ref.watch(fetchClubProvider(clubId)))
          : null,
      uid: _catchAsyncState(ref.watch(uidProvider)),
    );
    return HostCreateEventRouteStateView(
      clubId: clubId,
      state: routeState,
      initialDraft: initialDraft,
      initialPrefill: initialPrefill,
      initialRosterImportPlan: initialRosterImportPlan,
      externalBookingMode:
          initialDraft?.externalBookingMode ?? externalBookingMode,
      promptForDrafts: promptForDrafts,
    );
  }
}

class HostCreateEventRouteStateView extends ConsumerWidget {
  const HostCreateEventRouteStateView({
    super.key,
    required this.clubId,
    required this.state,
    this.initialDraft,
    this.initialPrefill,
    this.externalBookingMode = false,
    this.initialRosterImportPlan,
    this.promptForDrafts = true,
  });

  final String clubId;
  final HostCreateEventRouteState state;
  final EventDraft? initialDraft;
  final CreateEventPrefill? initialPrefill;
  final bool externalBookingMode;
  final HostRosterImportPlan? initialRosterImportPlan;
  final bool promptForDrafts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state.status) {
      HostCreateEventRouteStatus.loading =>
        const HostCreateEventRouteLoadingScreen(),
      HostCreateEventRouteStatus.error => CatchScreenScaffold.stepFlow(
        body: CatchErrorState.fromError(
          state.error!,
          context: AppErrorContext.club,
          onRetry: () {
            switch (state.retryIntent) {
              case HostCreateEventRouteRetryIntent.reloadClub:
                ref.invalidate(fetchClubProvider(clubId));
              case null:
                break;
            }
          },
        ),
      ),
      HostCreateEventRouteStatus.notFound => CatchScreenScaffold.stepFlow(
        body: CatchErrorBody(
          title: context.l10n.hostsHostCreateEventScreenTitleClubNotFound,
          message: context.l10n.hostsHostCreateEventScreenMessageThisClubIsNo,
          secondaryAction: const CatchErrorBackAction(),
        ),
      ),
      HostCreateEventRouteStatus.forbidden => CatchScreenScaffold.stepFlow(
        body: CatchErrorBody(
          title: context.l10n.hostsHostCreateEventScreenTitleHostAccessRequired,
          message: context.l10n.hostsHostCreateEventScreenMessageOnlyThisClubS,
          secondaryAction: const CatchErrorBackAction(),
        ),
      ),
      HostCreateEventRouteStatus.ready => CreateEventScreen(
        club: state.club!,
        initialDraft: initialDraft,
        initialPrefill: initialPrefill,
        externalBookingMode: externalBookingMode,
        initialRosterImportPlan: initialRosterImportPlan,
        promptForDraftsOnStart: promptForDrafts,
        initialStep: initialPrefill == null
            ? CreateEventWizardStep.eventDetails.index
            : CreateEventWizardStep.schedule.index,
      ),
    };
  }
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return catchAsyncStateFromAsyncValue(value);
}
