import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_feed_controller.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_view_model.dart';
import 'package:catch_dating_app/hosts/today/presentation/widgets/host_today_body.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_tokens/catch_tokens.dart';
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
      HostTodayRouteStatus.authRequired => CatchRootScreenScaffold.standard(
        header: HostTodayHeader(now: _clockNow),
        slivers: [
          CatchSliverErrorState(
            title: context.l10n.hostsHostAuthRequiredScreenTitleSignInRequired,
            message:
                context.l10n.hostsHostAuthRequiredScreenMessageSignInToManage,
            retryLabel:
                context.l10n.hostsHostAuthRequiredScreenVisiblecopySignIn,
            onRetry: () => context.go(Routes.authScreen.path),
          ),
        ],
      ),
      HostTodayRouteStatus.loading => CatchRootScreenScaffold.standard(
        header: HostTodayHeader(now: _clockNow),
        slivers: const [
          CatchSliverStateViewport(
            child: HostRouteLoadingBody(padding: EdgeInsets.zero),
          ),
        ],
      ),
      HostTodayRouteStatus.error => CatchRootScreenScaffold.standard(
        header: HostTodayHeader(now: _clockNow),
        slivers: [
          CatchSliverErrorState.fromError(
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
        ],
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
      ),
    };
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

    return HostTodayBody(
      organizer: organizer,
      state: todayState,
      now: clockNow,
      onRetry: () =>
          ref.read(hostTodayFeedControllerProvider(request).notifier).retry(),
      onOpenEvent: (event) => onOpenEvent(organizer, event),
      onOpenAttention: (item) => onOpenAttention(organizer, item),
      onViewEvents: onViewEvents,
      onStartRehearsal: () => onStartRehearsal(organizer),
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
    return CatchRootScreenScaffold.standard(
      header: const HostTodayHeader(),
      slivers: [
        CatchSliverEmptyState(
          icon: CatchIcons.groupsOutlined,
          title: context.l10n.hostsHostEventsScaffoldTitleCreateYourFirstClub,
          message: context.l10n.hostsHostEventsScaffoldBodyCreateAClubTo,
          action: CatchButton(
            label: context.l10n.hostsHostEventsScaffoldLabelCreateClub,
            icon: Icon(CatchIcons.addRounded, size: CatchIcon.md),
            size: CatchButtonSize.sm,
            onPressed: onCreateOrganizer,
          ),
        ),
      ],
    );
  }
}
