import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_sliver_error_state.dart';
import 'package:catch_dating_app/event_rehearsal/presentation/widgets/event_rehearsal_start_sheet.dart';
import 'package:catch_dating_app/events/data/event_draft_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_draft.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_flow.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_sheet.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_events_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:catch_dating_app/hosts/today/personalization/domain/host_today_preference.dart';
import 'package:catch_dating_app/hosts/today/personalization/presentation/host_today_personalized_layout.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_feed_controller.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_view_model.dart';
import 'package:catch_dating_app/hosts/today/presentation/widgets/host_today_body.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
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

    return CatchRootScreenScaffold.sections(
      scrollKey: const ValueKey<String>('host-today-scroll-view'),
      title: HostTodayHeader(now: _clockNow),
      children: [
        switch (routeState.status) {
          HostTodayRouteStatus.authRequired => CatchSliverErrorState(
            title: context.l10n.hostsHostAuthRequiredScreenTitleSignInRequired,
            message:
                context.l10n.hostsHostAuthRequiredScreenMessageSignInToManage,
            retryLabel:
                context.l10n.hostsHostAuthRequiredScreenVisiblecopySignIn,
            onRetry: () => context.go(Routes.authScreen.path),
          ),
          HostTodayRouteStatus.loading =>
            const CatchStateViewport.sliverLoading(),
          HostTodayRouteStatus.error => CatchLocalizedSliverErrorState(
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
            onOpenEvent: _openEvent,
            onOpenAttention: _openAttention,
            onViewEvents: () => context.goNamed(Routes.hostEventsScreen.name),
            onStartRehearsal: _startRehearsal,
            onStartEventRehearsal: _showRehearsalStart,
          ),
        },
      ],
    );
  }

  Future<void> _showRehearsalStart(Club organizer, Event event) async {
    final choice = await showCatchBottomSheet<EventRehearsalStartChoice>(
      context: context,
      builder: (_) => EventRehearsalStartSheet(event: event),
    );
    if (!mounted || choice == null) return;
    _startRehearsal(
      organizer,
      sourceEventId: choice == EventRehearsalStartChoice.upcomingEvent
          ? event.id
          : null,
    );
  }

  void _startRehearsal(Club organizer, {String? sourceEventId}) {
    context.pushNamed(
      Routes.hostEventRehearsalStartScreen.name,
      pathParameters: {'clubId': organizer.id},
      queryParameters: {
        'eventId': ?sourceEventId,
        if (sourceEventId == null) 'source': 'custom',
      },
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
        if (destination.section == 'automations') {
          context.pushNamed(
            formId == null
                ? Routes.hostAudienceAutomationsScreen.name
                : Routes.hostFormAutomationsScreen.name,
            pathParameters: {'formId': ?formId},
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
    required this.onOpenEvent,
    required this.onOpenAttention,
    required this.onViewEvents,
    required this.onStartRehearsal,
    this.onStartEventRehearsal,
    this.initialOrganizerId,
  });

  final HostTodayRouteState routeState;
  final String? initialOrganizerId;
  final DateTime clockNow;
  final DateTime sessionBoundary;
  final void Function(Club organizer, Event event) onOpenEvent;
  final void Function(Club organizer, HostAttentionItem item) onOpenAttention;
  final VoidCallback onViewEvents;
  final ValueChanged<Club> onStartRehearsal;
  final void Function(Club organizer, Event event)? onStartEventRehearsal;

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
    final draftsAsync = ref.watch(
      clubEventDraftsProvider(clubId: organizer.id),
    );
    final drafts = switch (draftsAsync) {
      AsyncData<List<EventDraft>>(:final value) => value,
      _ => const <EventDraft>[],
    };
    final repeatSource = HostEventsWorkspaceState.fromEvents(
      events: feedState.value?.pastEvents ?? const <Event>[],
      now: clockNow,
    ).repeatSource;
    final entryState = HostEventEntryState.resolve(
      organizerId: organizer.id,
      drafts: drafts,
      repeatSource: repeatSource,
    );
    final todayState = buildHostTodayState(
      feedState,
      now: clockNow,
      l10n: context.l10n,
    );

    return HostTodayPersonalizedLayout(
      scope: HostTodayPreferenceScope(
        accountId: uid,
        organizerId: organizer.id,
      ),
      today: todayState,
      now: clockNow,
      onCreateEvent: () => _showEventEntry(
        context: context,
        ref: ref,
        organizer: organizer,
        state: entryState,
        request: request,
      ),
      operationalSurface: HostTodayBody(
        organizer: organizer,
        state: todayState,
        now: clockNow,
        onRetry: () =>
            ref.read(hostTodayFeedControllerProvider(request).notifier).retry(),
        onOpenEvent: (event) => onOpenEvent(organizer, event),
        onOpenAttention: (item) => onOpenAttention(organizer, item),
        onCreateEvent: () => _showEventEntry(
          context: context,
          ref: ref,
          organizer: organizer,
          state: entryState,
          request: request,
        ),
        onViewEvents: onViewEvents,
        onStartRehearsal: () => onStartRehearsal(organizer),
        onStartEventRehearsal: onStartEventRehearsal == null
            ? null
            : (event) => onStartEventRehearsal!(organizer, event),
      ),
    );
  }

  Future<void> _showEventEntry({
    required BuildContext context,
    required WidgetRef ref,
    required Club organizer,
    required HostEventEntryState state,
    required HostTodayFeedRequest request,
  }) async {
    final intent = await showHostEventEntrySheet(
      context: context,
      state: state,
    );
    if (intent == null || !context.mounted) return;
    await runHostEventEntryFlow(
      context: context,
      ref: ref,
      club: organizer,
      state: state,
      intent: intent,
      createdAt: clockNow,
    );
    if (!context.mounted) return;
    ref.invalidate(hostTodayFeedControllerProvider(request));
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
    return CatchSliverEmptyState(
      icon: CatchIcons.groupsOutlined,
      title: context.l10n.hostsHostEventsScaffoldTitleCreateYourFirstClub,
      message: context.l10n.hostsHostEventsScaffoldBodyCreateAClubTo,
      actions: [
        CatchButton(
          label: context.l10n.hostsHostEventsScaffoldLabelCreateClub,
          leading: Icon(CatchIcons.addRounded, size: CatchIcon.md),
          size: CatchButtonSize.sm,
          onPressed: onCreateOrganizer,
        ),
      ],
    );
  }
}
