import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_prefill.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_wizard_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_route_loading_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_route_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catch_dating_app/l10n/l10n.dart';

export 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_route_loading_screen.dart';

class HostCreateEventRouteArguments {
  const HostCreateEventRouteArguments({
    required this.initialClub,
    this.initialPrefill,
  });

  final Club initialClub;
  final CreateEventPrefill? initialPrefill;
}

class HostCreateEventRouteScreen extends ConsumerWidget {
  const HostCreateEventRouteScreen({
    super.key,
    required this.clubId,
    this.initialClub,
    this.initialPrefill,
  });

  final String clubId;
  final Club? initialClub;
  final CreateEventPrefill? initialPrefill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final initialClub = this.initialClub;
    final initialPrefill = this.initialPrefill;
    if (initialClub != null && initialClub.id != clubId) {
      return CatchErrorScaffold(
        title:
            context.l10n.hostsHostCreateEventScreenTitleEventSetupUnavailable,
        message:
            context.l10n.hostsHostCreateEventScreenMessageThatOrganizerDoesNot,
      );
    }
    if (initialPrefill != null && initialPrefill.values.clubId != clubId) {
      return CatchErrorScaffold(
        title: context.l10n.hostsHostCreateEventScreenTitleRepeatUnavailable,
        message:
            context.l10n.hostsHostCreateEventScreenMessageThatEventBelongsTo,
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
      initialPrefill: initialPrefill,
    );
  }
}

class HostCreateEventRouteStateView extends ConsumerWidget {
  const HostCreateEventRouteStateView({
    super.key,
    required this.clubId,
    required this.state,
    this.initialPrefill,
  });

  final String clubId;
  final HostCreateEventRouteState state;
  final CreateEventPrefill? initialPrefill;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return switch (state.status) {
      HostCreateEventRouteStatus.loading =>
        const HostCreateEventRouteLoadingScreen(),
      HostCreateEventRouteStatus.error => CatchErrorScaffold.fromError(
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
      HostCreateEventRouteStatus.notFound => CatchErrorScaffold(
        title: context.l10n.hostsHostCreateEventScreenTitleClubNotFound,
        message: context.l10n.hostsHostCreateEventScreenMessageThisClubIsNo,
      ),
      HostCreateEventRouteStatus.forbidden => CatchErrorScaffold(
        title: context.l10n.hostsHostCreateEventScreenTitleHostAccessRequired,
        message: context.l10n.hostsHostCreateEventScreenMessageOnlyThisClubS,
      ),
      HostCreateEventRouteStatus.ready => CreateEventScreen(
        club: state.club!,
        initialPrefill: initialPrefill,
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
