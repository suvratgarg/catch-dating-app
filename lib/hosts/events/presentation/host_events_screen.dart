import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_events_state.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_events_view_model.dart';
import 'package:catch_dating_app/hosts/events/presentation/widgets/host_events_list.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_prefill.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/draft_picker_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_operational_roster_panel.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostEventsScreen extends ConsumerWidget {
  const HostEventsScreen({super.key, this.initialOrganizerId, this.now});

  final String? initialOrganizerId;
  final DateTime? now;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidState = catchAsyncStateFromAsyncValue(ref.watch(uidProvider));
    final uid = uidState.value;
    final organizersState = uid == null
        ? null
        : catchAsyncStateFromAsyncValue(
            ref.watch(hostOperableClubsProvider(uid)),
          );
    final routeState = buildHostEventsRouteState(
      uid: uidState,
      organizers: organizersState,
    );

    return switch (routeState.status) {
      HostEventsRouteStatus.authRequired => CatchErrorScaffold(
        title: context.l10n.hostsHostAuthRequiredScreenTitleSignInRequired,
        message: context.l10n.hostsHostAuthRequiredScreenMessageSignInToManage,
        retryLabel: context.l10n.hostsHostAuthRequiredScreenVisiblecopySignIn,
        onRetry: () => context.go(Routes.authScreen.path),
      ),
      HostEventsRouteStatus.loading => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchScreenTopBar(
          context: context,
          title: context.l10n.hostsHostOperationsHomeScreenTitleHostEvents,
          divider: scrolledUnder,
        ),
        body: const SafeArea(child: HostRouteLoadingBody()),
      ),
      HostEventsRouteStatus.error => CatchErrorScaffold.fromError(
        routeState.error!,
        context: routeState.errorContext,
        onRetry: () {
          final currentUid = routeState.uid;
          if (routeState.errorContext == AppErrorContext.auth ||
              currentUid == null) {
            ref.invalidate(uidProvider);
            return;
          }
          ref.invalidate(hostOperableClubsProvider(currentUid));
        },
      ),
      HostEventsRouteStatus.empty ||
      HostEventsRouteStatus.loaded => HostEventsRouteScaffold(
        organizers: routeState.organizers,
        currentUid: routeState.uid!,
        initialOrganizerId: initialOrganizerId,
        now: now,
      ),
    };
  }
}

class HostEventsRouteScaffold extends ConsumerStatefulWidget {
  const HostEventsRouteScaffold({
    super.key,
    required this.organizers,
    required this.currentUid,
    this.initialOrganizerId,
    this.now,
  });

  final List<Club> organizers;
  final String currentUid;
  final String? initialOrganizerId;
  final DateTime? now;

  @override
  ConsumerState<HostEventsRouteScaffold> createState() =>
      _HostEventsRouteScaffoldState();
}

class _HostEventsRouteScaffoldState
    extends ConsumerState<HostEventsRouteScaffold> {
  late DateTime _clockNow;
  late DateTime _timelineBoundary;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _resetClock();
  }

  @override
  void didUpdateWidget(HostEventsRouteScaffold oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.now != widget.now) _resetClock();
  }

  @override
  void dispose() {
    _clockTimer?.cancel();
    super.dispose();
  }

  void _resetClock() {
    _clockTimer?.cancel();
    _clockNow = widget.now ?? DateTime.now();
    _timelineBoundary = _clockNow;
    if (widget.now != null) return;
    _scheduleClockTick();
  }

  void _scheduleClockTick() {
    final current = DateTime.now();
    final nextMinute = DateTime(
      current.year,
      current.month,
      current.day,
      current.hour,
      current.minute + 1,
    );
    _clockTimer = Timer(nextMinute.difference(current) + CatchMotion.fast, () {
      if (!mounted) return;
      setState(() => _clockNow = DateTime.now());
      _scheduleClockTick();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final selectedOrganizerId = ref.watch(
      hostOrganizerSelectionProvider(widget.currentUid),
    );
    final selectedClub = resolveSelectedHostOrganizer(
      widget.organizers,
      selectedOrganizerId: selectedOrganizerId,
      preferredOrganizerId: selectedOrganizerId == null
          ? widget.initialOrganizerId
          : null,
    );

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: selectedClub == null
            ? CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: CatchScreenHeaderTitle.block(
                      title: context.l10n.hostsHostEventsListTextEvents,
                    ),
                  ),
                  CatchSliverEmptyState(
                    icon: CatchIcons.groupsOutlined,
                    title: context
                        .l10n
                        .hostsHostEventsScaffoldTitleCreateYourFirstClub,
                    message:
                        context.l10n.hostsHostEventsScaffoldBodyCreateAClubTo,
                    action: CatchButton(
                      label:
                          context.l10n.hostsHostEventsScaffoldLabelCreateClub,
                      icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                      size: CatchButtonSize.sm,
                      onPressed: () =>
                          context.pushNamed(Routes.hostCreateClubScreen.name),
                    ),
                  ),
                  const CatchSliverTerminalPadding(),
                ],
              )
            : HostEventsClubCard(
                club: selectedClub,
                onEventEntrySelected: _handleEventEntrySelected,
                onManageEvent: _openEvent,
                now: _clockNow,
                sessionBoundary: _timelineBoundary,
              ),
      ),
    );
  }

  Future<void> _handleEventEntrySelected(
    Club club,
    HostEventEntryState state,
    HostEventEntryIntent intent,
  ) async {
    switch (intent) {
      case HostEventEntryIntent.resumeDraft:
        final draft = await _pickDraft(state);
        if (draft == null || !mounted) return;
        await _openCreateEvent(club, initialDraft: draft);
      case HostEventEntryIntent.repeatLastEvent:
        final source = state.repeatSource;
        if (source == null) return;
        await _openRepeatEvent(club, source);
      case HostEventEntryIntent.createWithCatchBookings:
        await _openCreateEvent(club);
      case HostEventEntryIntent.createFromGuestList:
        await _openExternalEvent(club);
    }
  }

  Future<EventDraft?> _pickDraft(HostEventEntryState state) async {
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

  Future<void> _openCreateEvent(Club club, {EventDraft? initialDraft}) async {
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

  Future<void> _openExternalEvent(Club club) async {
    HostRosterTable? table;
    try {
      table = await ref
          .read(createEventControllerProvider.notifier)
          .pickRosterFile();
    } on HostRosterImportException catch (error) {
      if (mounted) {
        showCatchSnackBar(
          context,
          hostRosterImportIssueCopy(context, error.issue),
        );
      }
      return;
    } on Object catch (error) {
      if (mounted) showCatchErrorSnackBar(context, error);
      return;
    }
    if (table == null || !mounted) return;
    final rosterPlan = await showHostRosterMapping(context, table);
    if (rosterPlan == null || !mounted) return;
    await context.pushNamed(
      Routes.hostCreateEventScreen.name,
      pathParameters: {'clubId': club.id},
      extra: HostCreateEventRouteArguments(
        initialClub: club,
        externalBookingMode: true,
        initialRosterImportPlan: rosterPlan,
        promptForDrafts: false,
      ),
    );
    ref.invalidate(clubEventDraftsProvider(clubId: club.id));
  }

  Future<void> _openRepeatEvent(Club club, Event event) async {
    final prefill = CreateEventPrefill.repeat(
      event: event,
      createdAt: _clockNow,
    );
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

  void _openEvent(Club club, Event event) {
    final isLive =
        !event.startTime.isAfter(_clockNow) && event.endTime.isAfter(_clockNow);
    final section = isLive
        ? 'live'
        : event.endTime.isAfter(_clockNow)
        ? 'setup'
        : 'report';
    context.pushNamed(
      Routes.hostAppEventManageScreen.name,
      pathParameters: {'clubId': club.id, 'eventId': event.id},
      queryParameters: {'section': section},
      extra: event,
    );
  }
}
