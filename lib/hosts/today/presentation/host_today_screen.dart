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
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_draft_controller.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/create/create_event_prefill.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/host_create_event_screen.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/widgets/draft_picker_sheet.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_operational_roster_panel.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_feed_controller.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_view_model.dart';
import 'package:catch_dating_app/hosts/today/presentation/widgets/host_today_body.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostTodayScreen extends ConsumerStatefulWidget {
  const HostTodayScreen({super.key, this.initialOrganizerId, this.now});

  final String? initialOrganizerId;
  final DateTime? now;

  @override
  ConsumerState<HostTodayScreen> createState() => _HostTodayScreenState();
}

class _HostTodayScreenState extends ConsumerState<HostTodayScreen> {
  late DateTime _clockNow;
  late DateTime _sessionBoundary;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _resetClock();
  }

  @override
  void didUpdateWidget(HostTodayScreen oldWidget) {
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
    _sessionBoundary = _clockNow;
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
    final uidState = catchAsyncStateFromAsyncValue(ref.watch(uidProvider));
    final uid = uidState.value;
    final organizersState = uid == null
        ? null
        : catchAsyncStateFromAsyncValue(
            ref.watch(hostOperableClubsProvider(uid)),
          );
    final routeState = buildHostTodayRouteState(
      uid: uidState,
      organizers: organizersState,
    );

    return switch (routeState.status) {
      HostTodayRouteStatus.authRequired => CatchErrorScaffold(
        title: context.l10n.hostsHostAuthRequiredScreenTitleSignInRequired,
        message: context.l10n.hostsHostAuthRequiredScreenMessageSignInToManage,
        retryLabel: context.l10n.hostsHostAuthRequiredScreenVisiblecopySignIn,
        onRetry: () => context.go(Routes.authScreen.path),
      ),
      HostTodayRouteStatus.loading => CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          title: context.l10n.hostNavigationToday,
          divider: scrolledUnder,
        ),
        body: const SafeArea(child: HostRouteLoadingBody()),
      ),
      HostTodayRouteStatus.error => CatchErrorScaffold.fromError(
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
      HostTodayRouteStatus.empty => HostTodayOrganizerEmptyState(
        onCreateOrganizer: () =>
            context.pushNamed(Routes.hostCreateClubScreen.name),
      ),
      HostTodayRouteStatus.loaded => HostTodayLoadedRoute(
        routeState: routeState,
        initialOrganizerId: widget.initialOrganizerId,
        clockNow: _clockNow,
        sessionBoundary: _sessionBoundary,
        onEventEntrySelected: _handleEventEntrySelected,
        onOpenEvent: _openEvent,
        onOpenAttention: _openAttention,
        onViewEvents: () => context.goNamed(Routes.hostEventsScreen.name),
        onStartRehearsal: _startRehearsal,
      ),
    };
  }

  Future<void> _handleEventEntrySelected(
    Club organizer,
    HostEventEntryState state,
    HostEventEntryIntent intent,
  ) async {
    switch (intent) {
      case HostEventEntryIntent.resumeDraft:
        final draft = await _pickDraft(state);
        if (draft == null || !mounted) return;
        await _openCreateEvent(organizer, initialDraft: draft);
      case HostEventEntryIntent.repeatLastEvent:
        final source = state.repeatSource;
        if (source == null) return;
        await _openRepeatEvent(organizer, source);
      case HostEventEntryIntent.createWithCatchBookings:
        await _openCreateEvent(organizer);
      case HostEventEntryIntent.createFromGuestList:
        await _openExternalEvent(organizer);
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

  Future<void> _openCreateEvent(
    Club organizer, {
    EventDraft? initialDraft,
  }) async {
    await context.pushNamed(
      Routes.hostCreateEventScreen.name,
      pathParameters: {'clubId': organizer.id},
      extra: HostCreateEventRouteArguments(
        initialClub: organizer,
        initialDraft: initialDraft,
        externalBookingMode: initialDraft?.externalBookingMode ?? false,
        promptForDrafts: false,
      ),
    );
    ref.invalidate(clubEventDraftsProvider(clubId: organizer.id));
  }

  Future<void> _openExternalEvent(Club organizer) async {
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
      pathParameters: {'clubId': organizer.id},
      extra: HostCreateEventRouteArguments(
        initialClub: organizer,
        externalBookingMode: true,
        initialRosterImportPlan: rosterPlan,
        promptForDrafts: false,
      ),
    );
    ref.invalidate(clubEventDraftsProvider(clubId: organizer.id));
  }

  Future<void> _openRepeatEvent(Club organizer, Event event) async {
    final prefill = CreateEventPrefill.repeat(
      event: event,
      createdAt: _clockNow,
    );
    await context.pushNamed(
      Routes.hostCreateEventScreen.name,
      pathParameters: {'clubId': organizer.id},
      extra: HostCreateEventRouteArguments(
        initialClub: organizer,
        initialPrefill: prefill,
        promptForDrafts: false,
      ),
    );
    ref.invalidate(clubEventDraftsProvider(clubId: organizer.id));
  }

  void _startRehearsal(Club organizer) {
    context.pushNamed(
      Routes.hostEventRehearsalStartScreen.name,
      pathParameters: {'clubId': organizer.id},
    );
  }

  void _openEvent(Club organizer, Event event) {
    final isLive =
        !event.startTime.isAfter(_clockNow) && event.endTime.isAfter(_clockNow);
    context.pushNamed(
      Routes.hostAppEventManageScreen.name,
      pathParameters: {'clubId': organizer.id, 'eventId': event.id},
      queryParameters: {
        'section': isLive
            ? 'live'
            : event.endTime.isAfter(_clockNow)
            ? 'setup'
            : 'report',
      },
      extra: event,
    );
  }

  void _openAttention(Club organizer, HostAttentionItem item) {
    final destination = item.destination;
    switch (destination.route) {
      case HostAttentionDestinationRoute.hostEventManage:
        final eventId = destination.eventId ?? item.eventId;
        if (eventId == null) return;
        context.pushNamed(
          Routes.hostAppEventManageScreen.name,
          pathParameters: {'clubId': organizer.id, 'eventId': eventId},
          queryParameters: {'section': destination.section ?? 'setup'},
        );
        return;
      case HostAttentionDestinationRoute.hostApplications:
        final applicationId = destination.applicationId;
        context.pushNamed(
          applicationId == null
              ? Routes.hostApplicationsScreen.name
              : Routes.hostApplicationDetailScreen.name,
          pathParameters: {'applicationId': ?applicationId},
          queryParameters: {'organizerId': organizer.id},
        );
        return;
      case HostAttentionDestinationRoute.hostOrganizerPayments:
        context.pushNamed(
          Routes.hostClubPaymentsScreen.name,
          queryParameters: {'clubId': organizer.id},
        );
        return;
      case HostAttentionDestinationRoute.hostAudienceForms:
        final formId = destination.formId;
        if (formId != null && destination.section == 'automations') {
          context.pushNamed(
            Routes.hostFormAutomationsScreen.name,
            pathParameters: {'formId': formId},
            queryParameters: {'organizerId': organizer.id},
          );
          return;
        }
        context.goNamed(
          Routes.hostAudienceScreen.name,
          queryParameters: {
            'organizerId': organizer.id,
            'view': destination.section == 'responses' ? 'responses' : 'forms',
            'formId': ?formId,
          },
        );
        return;
      case HostAttentionDestinationRoute.hostInbox:
        context.goNamed(
          Routes.hostInboxScreen.name,
          queryParameters: {'threadId': ?destination.threadId},
          extra: organizer,
        );
        return;
      case HostAttentionDestinationRoute.hostDressRehearsal:
        _startRehearsal(organizer);
        return;
      case HostAttentionDestinationRoute.hostEvents:
        context.goNamed(Routes.hostEventsScreen.name);
        return;
    }
  }
}

class HostTodayLoadedRoute extends ConsumerWidget {
  const HostTodayLoadedRoute({
    super.key,
    required this.routeState,
    required this.clockNow,
    required this.sessionBoundary,
    required this.onEventEntrySelected,
    required this.onOpenEvent,
    required this.onOpenAttention,
    required this.onViewEvents,
    required this.onStartRehearsal,
    this.initialOrganizerId,
  });

  final HostTodayRouteState routeState;
  final String? initialOrganizerId;
  final DateTime clockNow;
  final DateTime sessionBoundary;
  final HostEventEntryCallback onEventEntrySelected;
  final void Function(Club organizer, Event event) onOpenEvent;
  final void Function(Club organizer, HostAttentionItem item) onOpenAttention;
  final VoidCallback onViewEvents;
  final ValueChanged<Club> onStartRehearsal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = routeState.uid!;
    final selectedOrganizerId = ref.watch(hostOrganizerSelectionProvider(uid));
    final organizer = resolveSelectedHostOrganizer(
      routeState.organizers,
      selectedOrganizerId: selectedOrganizerId,
      preferredOrganizerId: selectedOrganizerId == null
          ? initialOrganizerId
          : null,
    )!;
    final request = HostTodayFeedRequest(
      organizerId: organizer.id,
      accountId: uid,
      sessionBoundary: sessionBoundary,
    );
    final feedState = catchAsyncStateFromAsyncValue(
      ref.watch(hostTodayFeedControllerProvider(request)),
    );
    final todayState = buildHostTodayState(
      feedState,
      now: clockNow,
      l10n: context.l10n,
    );
    final draftsState = catchAsyncStateFromAsyncValue(
      ref.watch(clubEventDraftsProvider(clubId: organizer.id)),
    );
    final repeatSource = feedState.value?.pastEvents
        .where(CreateEventPrefill.canRepeat)
        .firstOrNull;
    final entryState = HostEventEntryState.resolve(
      organizerId: organizer.id,
      drafts: draftsState.value ?? const <EventDraft>[],
      repeatSource: repeatSource,
    );

    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      body: SafeArea(
        bottom: false,
        child: HostTodayBody(
          organizer: organizer,
          state: todayState,
          entryState: entryState,
          now: clockNow,
          onRetry: () => ref
              .read(hostTodayFeedControllerProvider(request).notifier)
              .retry(),
          onEventEntrySelected: onEventEntrySelected,
          onOpenEvent: (event) => onOpenEvent(organizer, event),
          onOpenAttention: (item) => onOpenAttention(organizer, item),
          onViewEvents: onViewEvents,
          onStartRehearsal: () => onStartRehearsal(organizer),
        ),
      ),
    );
  }
}

class HostTodayOrganizerEmptyState extends StatelessWidget {
  const HostTodayOrganizerEmptyState({
    super.key,
    required this.onCreateOrganizer,
  });

  final VoidCallback onCreateOrganizer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CatchTokens.of(context).bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(child: HostTodayHeader()),
            CatchSliverEmptyState(
              icon: CatchIcons.groupsOutlined,
              title:
                  context.l10n.hostsHostEventsScaffoldTitleCreateYourFirstClub,
              message: context.l10n.hostsHostEventsScaffoldBodyCreateAClubTo,
              action: CatchButton(
                label: context.l10n.hostsHostEventsScaffoldLabelCreateClub,
                icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
                size: CatchButtonSize.sm,
                onPressed: onCreateOrganizer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
