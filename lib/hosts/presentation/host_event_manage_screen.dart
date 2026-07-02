import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_segmented_control.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_success/presentation/event_success_host_screen.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_invite_link.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_attendance_panel.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

export 'package:catch_dating_app/hosts/presentation/host_event_manage_screen_state.dart'
    show HostEventManageSection;

typedef _HostEventManageRouteData = ({String? uid, Club? club, Event? event});

class HostEventManageRouteScreen extends ConsumerWidget {
  const HostEventManageRouteScreen({
    super.key,
    required this.clubId,
    required this.eventId,
    this.initialEvent,
    this.initialSection = HostEventManageSection.setup,
    this.initialParticipantSearchQuery = '',
  });

  final String clubId;
  final String eventId;
  final Event? initialEvent;
  final HostEventManageSection initialSection;
  final String initialParticipantSearchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uidAsync = ref.watch(uidProvider);
    final clubAsync = ref.watch(fetchClubProvider(clubId));
    final eventAsync = ref.watch(watchEventProvider(eventId));
    final routeDataAsync = _hostEventManageRouteData(
      uidAsync: uidAsync,
      clubAsync: clubAsync,
      eventAsync: eventAsync,
      initialEvent: initialEvent,
    );

    return CatchAsyncValueView<_HostEventManageRouteData>(
      value: routeDataAsync,
      loadingBuilder: (_) => Scaffold(
        backgroundColor: CatchTokens.of(context).bg,
        appBar: const CatchTopBar(title: 'Manage event', border: true),
        body: const SafeArea(child: HostRouteLoadingBody(showTabRail: true)),
      ),
      errorBuilder: (_, error, _) => CatchErrorScaffold.fromError(
        error,
        context: AppErrorContext.event,
        onRetry: () {
          ref.invalidate(fetchClubProvider(clubId));
          ref.invalidate(watchEventProvider(eventId));
        },
      ),
      builder: (context, routeData) {
        final uid = routeData.uid;
        final club = routeData.club;
        final event = routeData.event;
        if (club == null || event == null) {
          return const CatchErrorScaffold(
            title: 'Event not found',
            message: 'This hosted event is no longer available.',
          );
        }

        if (uid == null || !club.isHostedBy(uid)) {
          return CatchErrorScaffold(
            title: 'Action unavailable',
            message: 'You can manage only events that you host.',
            icon: CatchIcons.blockRounded,
          );
        }

        return HostEventManageScreen(
          club: club,
          event: event,
          onBackToSuccess: () => Navigator.of(context).maybePop(),
          initialSection: initialSection,
          initialParticipantSearchQuery: initialParticipantSearchQuery,
        );
      },
    );
  }
}

AsyncValue<_HostEventManageRouteData> _hostEventManageRouteData({
  required AsyncValue<String?> uidAsync,
  required AsyncValue<Club?> clubAsync,
  required AsyncValue<Event?> eventAsync,
  required Event? initialEvent,
}) {
  final event = eventAsync.asData?.value ?? initialEvent;
  final loading =
      uidAsync.isLoading ||
      clubAsync.isLoading ||
      (eventAsync.isLoading && event == null);
  if (loading) return const AsyncLoading<_HostEventManageRouteData>();

  final error = uidAsync.error ?? clubAsync.error ?? eventAsync.error;
  if (error != null) {
    final stackTrace =
        uidAsync.stackTrace ??
        clubAsync.stackTrace ??
        eventAsync.stackTrace ??
        StackTrace.current;
    return AsyncError<_HostEventManageRouteData>(error, stackTrace);
  }

  return AsyncData<_HostEventManageRouteData>((
    uid: uidAsync.asData?.value,
    club: clubAsync.asData?.value,
    event: event,
  ));
}

class HostEventManageScreen extends ConsumerStatefulWidget {
  const HostEventManageScreen({
    super.key,
    required this.club,
    required this.event,
    required this.onBackToSuccess,
    this.initialSection = HostEventManageSection.setup,
    this.onSectionChanged,
    this.eventSuccessFixtureActions,
    this.initialParticipantSearchQuery = '',
  });

  final Club club;
  final Event event;
  final VoidCallback onBackToSuccess;
  final HostEventManageSection initialSection;
  final ValueChanged<HostEventManageSection>? onSectionChanged;
  final EventSuccessHostFixtureActions? eventSuccessFixtureActions;
  final String initialParticipantSearchQuery;

  @override
  ConsumerState<HostEventManageScreen> createState() =>
      _HostEventManageScreenState();
}

class _HostEventManageScreenState extends ConsumerState<HostEventManageScreen> {
  late HostEventManageSection _selectedSection = widget.initialSection;

  @override
  void didUpdateWidget(covariant HostEventManageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection) {
      _selectedSection = widget.initialSection;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final club = widget.club;
    final event = widget.event;
    final onBackToSuccess = widget.onBackToSuccess;
    final rosterAsync = ref.watch(
      watchEventParticipationRosterProvider(event.id),
    );
    final roster = rosterAsync.asData?.value;
    final cancelMutation = ref.watch(
      EventBookingController.hostCancelEventMutation,
    );
    final deleteMutation = ref.watch(
      EventBookingController.deleteEventMutation,
    );
    final isInviteOnly = event.effectiveEventPolicy.usesInviteOnly;
    final accessAsync = isInviteOnly
        ? ref.watch(watchEventPrivateAccessProvider(event.id))
        : null;
    final inviteLinksAsync = isInviteOnly
        ? ref.watch(watchEventInviteLinksProvider(event.id))
        : null;
    final shareMutation = ref.watch(
      HostEventManageController.sharePrivateLinkMutation,
    );
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final screenState = HostEventManageScreenState.resolve(
      club: club,
      event: event,
      selectedSection: _selectedSection,
      textScale: textScale,
    );
    final actionState = HostEventActionDisplayState.resolve(
      event: event,
      roster: roster,
      cancelEventPending: cancelMutation.isPending,
      deleteEventPending: deleteMutation.isPending,
    );
    final privateLinkActionState = isInviteOnly
        ? HostPrivateLinkActionState.resolve(
            club: club,
            event: event,
            accessAsync: accessAsync,
            inviteLinksAsync: inviteLinksAsync,
            sharePending: shareMutation.isPending,
          )
        : null;
    const sectionPickerHeight = 62.0;

    return Scaffold(
      backgroundColor: t.bg,
      appBar: CatchTopBar(
        showBackButton: true,
        onBack: onBackToSuccess,
        border: true,
        height: CatchLayout.topBarLargeHeight + CatchSpacing.s4,
        titleWidget: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!screenState.collapseHeaderCopy) ...[
              Text(
                club.name.toUpperCase(),
                style: CatchTextStyles.kicker(context, color: t.ink3),
              ),
              gapH2,
            ],
            Text(
              screenState.eventTitle,
              style: CatchTextStyles.titleL(context, color: t.ink),
              semanticsLabel: screenState.collapsedTitleSemanticsLabel,
              maxLines: screenState.collapseHeaderCopy ? 1 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (!screenState.collapseHeaderCopy) ...[
              gapH8,
              HostManageMetaRow(event: event),
            ],
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(sectionPickerHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              CatchSpacing.s0,
              CatchSpacing.s5,
              CatchSpacing.s2,
            ),
            child: HostManageSectionPicker(
              selectedSection: screenState.selectedSection,
              onChanged: (section) {
                setState(
                  () => _selectedSection = screenState
                      .selectSection(section)
                      .selectedSection,
                );
                widget.onSectionChanged?.call(section);
              },
            ),
          ),
        ),
      ),
      body: ListView(
        key: const Key('host_event_manage_scroll_view'),
        padding: CatchInsets.pageBodyUnderHeader,
        children: [
          ..._selectedSectionChildren(
            section: screenState.selectedSection,
            club: club,
            event: event,
            roster: roster,
            privateAccessAsync: accessAsync,
            inviteLinksAsync: inviteLinksAsync,
            shareMutation: shareMutation,
            onDeleted: onBackToSuccess,
            actionState: actionState,
            actionError: _firstMutationError([cancelMutation, deleteMutation]),
            privateLinkActionState: privateLinkActionState,
          ),
        ],
      ),
    );
  }

  List<Widget> _selectedSectionChildren({
    required HostEventManageSection section,
    required Club club,
    required Event event,
    required EventParticipationRoster? roster,
    required AsyncValue<EventPrivateAccess?>? privateAccessAsync,
    required AsyncValue<List<EventInviteLink>>? inviteLinksAsync,
    required MutationState<dynamic> shareMutation,
    required VoidCallback onDeleted,
    required HostEventActionDisplayState actionState,
    required Object? actionError,
    required HostPrivateLinkActionState? privateLinkActionState,
  }) {
    return switch (section) {
      HostEventManageSection.setup => [
        if (_showsCapacityNotice(event)) ...[
          const HostFullCapacityBanner(),
          gapH12,
        ],
        HostFullCapacityApron(event: event, roster: roster),
        gapH20,
        HostEventActionsSection(
          club: club,
          event: event,
          actionState: actionState,
          actionError: actionError,
          privateLinkActionState: privateLinkActionState,
          onEditEvent: () {
            unawaited(
              _handleHostEventActionIntent(
                HostEventManageActionIntent.editEvent,
                event: event,
                onDeleted: onDeleted,
              ),
            );
          },
          onCancelEvent: () => _handleHostEventActionIntent(
            HostEventManageActionIntent.cancelEvent,
            event: event,
            onDeleted: onDeleted,
          ),
          onDeleteEvent: () => _handleHostEventActionIntent(
            HostEventManageActionIntent.deleteEvent,
            event: event,
            onDeleted: onDeleted,
          ),
          onSharePrivateLink: (inviteLink) => _shareHostPrivateLink(
            context: context,
            ref: ref,
            club: club,
            event: event,
            inviteLink: inviteLink,
          ),
        ),
        if (event.effectiveEventPolicy.usesInviteOnly) ...[
          gapH20,
          HostPrivateAccessCard(
            club: club,
            event: event,
            accessAsync: privateAccessAsync!,
            inviteLinksAsync: inviteLinksAsync!,
            shareMutation: shareMutation,
            onRetryPrivateAccess: () =>
                ref.invalidate(watchEventPrivateAccessProvider(event.id)),
            onRetryInviteLinks: () =>
                ref.invalidate(watchEventInviteLinksProvider(event.id)),
            onSharePrivateLink: (inviteLink) => _shareHostPrivateLink(
              context: context,
              ref: ref,
              club: club,
              event: event,
              inviteLink: inviteLink,
            ),
          ),
        ],
        gapH20,
        HostEventSummaryCard(club: club, event: event),
        gapH20,
        EventSuccessHostSection(
          event: event,
          showTabs: false,
          fixtureActions: widget.eventSuccessFixtureActions,
        ),
      ],
      HostEventManageSection.guests => [
        HostEventParticipantsPanel(
          eventId: event.id,
          mode: HostEventParticipantsMode.setup,
          initialSearchQuery: widget.initialParticipantSearchQuery,
        ),
      ],
      HostEventManageSection.live => [
        EventSuccessHostSection(
          event: event,
          initialTab: EventSuccessHostTab.live,
          showTabs: false,
          compactLiveControls: true,
          fixtureActions: widget.eventSuccessFixtureActions,
        ),
      ],
      HostEventManageSection.report => [
        HostEventParticipantsPanel(
          eventId: event.id,
          mode: HostEventParticipantsMode.report,
          initialSearchQuery: widget.initialParticipantSearchQuery,
        ),
        gapH20,
        EventSuccessHostSection(
          event: event,
          initialTab: EventSuccessHostTab.report,
          showTabs: false,
          fixtureActions: widget.eventSuccessFixtureActions,
        ),
      ],
    };
  }

  Future<void> _handleHostEventActionIntent(
    HostEventManageActionIntent intent, {
    required Event event,
    required VoidCallback onDeleted,
  }) {
    final effect = HostEventManageActionEffect.resolve(
      intent: intent,
      event: event,
    );
    switch (effect.destination) {
      case HostEventManageActionDestination.editEventRoute:
        _openEditEvent(effect);
        return Future<void>.value();
      case HostEventManageActionDestination.cancelConfirmation:
        return _confirmCancelEvent(effect.event);
      case HostEventManageActionDestination.deleteConfirmation:
        return _confirmDeleteEvent(effect.event, onDeleted);
    }
  }

  void _openEditEvent(HostEventManageActionEffect effect) {
    context.pushNamed(
      Routes.hostAppEditEventScreen.name,
      pathParameters: effect.pathParameters,
      extra: effect.event,
    );
  }

  Future<void> _confirmCancelEvent(Event event) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Cancel this event?',
      message:
          'Cancelling removes it from schedules but keeps attendee, payment, and history records. Attendees are notified and refunded per your cancellation policy.',
      actions: const [
        CatchDialogAction(label: 'Keep event', value: false, isDefault: true),
        CatchDialogAction(
          label: 'Cancel event',
          value: true,
          isDestructive: true,
        ),
      ],
    );
    if (confirmed != true || !mounted) return;

    unawaited(
      EventBookingController.hostCancelEventMutation.run(ref, (tx) async {
        await tx
            .get(hostEventManageActionsProvider)
            .cancelHostedEvent(event: event);
        if (!mounted) return;
        showCatchSnackBar(context, 'Event cancelled.');
      }),
    );
  }

  Future<void> _confirmDeleteEvent(Event event, VoidCallback onDeleted) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Delete unused event?',
      message:
          'Only events with no bookings, waitlist, attendance, payments, or reviews can be deleted. This permanently removes the event.',
      actions: const [
        CatchDialogAction(label: 'Keep event', value: false, isDefault: true),
        CatchDialogAction(
          label: 'Delete unused event',
          value: true,
          isDestructive: true,
        ),
      ],
    );
    if (confirmed != true || !mounted) return;

    unawaited(
      EventBookingController.deleteEventMutation.run(ref, (tx) async {
        await tx
            .get(hostEventManageActionsProvider)
            .deleteUnusedEvent(event: event);
        if (!mounted) return;
        showCatchSnackBar(context, 'Event deleted.');
        onDeleted();
      }),
    );
  }
}

bool _showsCapacityNotice(Event event) {
  if (event.isFull) return true;
  return event.effectiveWaitlistedCohortCounts.values.any((count) => count > 0);
}

Object? _firstMutationError(Iterable<Object> mutations) {
  for (final mutation in mutations) {
    if (mutation is MutationError) return mutation.error;
  }
  return null;
}

class HostManageMetaRow extends StatelessWidget {
  const HostManageMetaRow({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: HostManageMetaItem(
            icon: CatchIcons.calendarTodayOutlined,
            label:
                '${event.shortDateLabel} · ${EventFormatters.time(event.startTime)}',
            color: t.ink2,
          ),
        ),
        gapW12,
        Expanded(
          flex: 4,
          child: HostManageMetaItem(
            icon: CatchIcons.pinOutlined,
            label: event.locationName,
            color: t.ink2,
          ),
        ),
        gapW12,
        Expanded(
          flex: 3,
          child: HostManageMetaItem(
            icon: CatchIcons.groupsOutlined,
            label: event.spotsLabel,
            color: t.ink2,
          ),
        ),
      ],
    );
  }
}

class HostManageMetaItem extends StatelessWidget {
  const HostManageMetaItem({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: CatchIcon.badge, color: color),
        gapW4,
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.supporting(context, color: color),
          ),
        ),
      ],
    );
  }
}

class HostManageSectionPicker extends StatelessWidget {
  const HostManageSectionPicker({
    super.key,
    required this.selectedSection,
    required this.onChanged,
  });

  final HostEventManageSection selectedSection;
  final ValueChanged<HostEventManageSection> onChanged;

  @override
  Widget build(BuildContext context) {
    return CatchSegmentedControl<HostEventManageSection>(
      expanded: true,
      style: CatchSegmentedControlStyle.surface,
      segments: [
        for (final section in HostEventManageSection.values)
          CatchSegment(value: section, label: section.label.toUpperCase()),
      ],
      selected: selectedSection,
      onChanged: onChanged,
    );
  }
}

class HostPrivateAccessCard extends StatelessWidget {
  const HostPrivateAccessCard({
    super.key,
    required this.club,
    required this.event,
    required this.accessAsync,
    required this.inviteLinksAsync,
    required this.shareMutation,
    required this.onRetryPrivateAccess,
    required this.onRetryInviteLinks,
    required this.onSharePrivateLink,
  });

  final Club club;
  final Event event;
  final AsyncValue<EventPrivateAccess?> accessAsync;
  final AsyncValue<List<EventInviteLink>> inviteLinksAsync;
  final MutationState<dynamic> shareMutation;
  final VoidCallback onRetryPrivateAccess;
  final VoidCallback onRetryInviteLinks;
  final ValueChanged<String> onSharePrivateLink;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchAsyncValueView<EventPrivateAccess?>(
      value: accessAsync,
      loadingBuilder: (_) => HostPrivateAccessShell(
        child: Row(
          children: [
            const HostInlineSkeletonIcon(),
            gapW12,
            Expanded(
              child: Text(
                'Loading invite access...',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ),
          ],
        ),
      ),
      errorBuilder: (_, error, _) => CatchInlineErrorState.fromError(
        error,
        context: AppErrorContext.event,
        compact: true,
        onRetry: onRetryPrivateAccess,
      ),
      builder: (context, access) {
        final privateAccessState = HostPrivateAccessDisplayState.resolve(
          club: club,
          event: event,
          access: access,
          inviteLinksAsync: inviteLinksAsync,
          sharePending: shareMutation.isPending,
        );
        return HostPrivateAccessBody(
          event: event,
          state: privateAccessState,
          inviteLinksAsync: inviteLinksAsync,
          shareMutation: shareMutation,
          onRetryInviteLinks: onRetryInviteLinks,
          onSharePrivateLink: onSharePrivateLink,
        );
      },
    );
  }
}

class HostPrivateAccessShell extends StatelessWidget {
  const HostPrivateAccessShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: CatchInsets.content,
      borderColor: t.line,
      child: child,
    );
  }
}

class HostPrivateAccessBody extends StatelessWidget {
  const HostPrivateAccessBody({
    super.key,
    required this.event,
    required this.state,
    required this.inviteLinksAsync,
    required this.shareMutation,
    required this.onRetryInviteLinks,
    required this.onSharePrivateLink,
  });

  final Event event;
  final HostPrivateAccessDisplayState state;
  final AsyncValue<List<EventInviteLink>> inviteLinksAsync;
  final MutationState<dynamic> shareMutation;
  final VoidCallback onRetryInviteLinks;
  final ValueChanged<String> onSharePrivateLink;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final privateAccessState = state;
    final linkAction = privateAccessState.linkAction;

    return HostPrivateAccessShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(CatchIcons.keyOutlined, color: t.primary),
              gapW10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Private access',
                      style: CatchTextStyles.sectionTitle(context),
                    ),
                    gapH4,
                    Text(
                      privateAccessState.description,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
              const CatchBadge(label: 'Invite', tone: CatchBadgeTone.brand),
            ],
          ),
          if (privateAccessState.hasInviteCode) ...[
            gapH14,
            HostEventSummaryRow(
              icon: CatchIcons.passwordRounded,
              label: 'Code',
              value: linkAction.inviteCode!,
            ),
            if (linkAction.inviteLink != null)
              HostEventSummaryRow(
                icon: CatchIcons.linkRounded,
                label: 'Link',
                value: linkAction.inviteLink!,
                showDivider: false,
              ),
            if (shareMutation.hasError) ...[
              gapH12,
              CatchMutationErrorBanner(
                mutation: shareMutation,
                errorContext: AppErrorContext.event,
              ),
            ],
            gapH14,
            CatchButton(
              label: 'Share private link',
              onPressed: !linkAction.canShare
                  ? null
                  : () => onSharePrivateLink(linkAction.inviteLink!),
              variant: CatchButtonVariant.secondary,
              icon: Icon(
                CatchIcons.platformShare(platform: Theme.of(context).platform),
              ),
              isLoading: shareMutation.isPending,
              fullWidth: true,
            ),
            gapH18,
            HostInviteLinksList(
              event: event,
              inviteCode: linkAction.inviteCode!,
              linksAsync: inviteLinksAsync,
              onRetry: onRetryInviteLinks,
            ),
          ],
        ],
      ),
    );
  }
}

void _shareHostPrivateLink({
  required BuildContext context,
  required WidgetRef ref,
  required Club club,
  required Event event,
  required String inviteLink,
}) {
  final box = context.findRenderObject() as RenderBox?;
  final origin = box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  unawaited(
    HostEventManageController.sharePrivateLinkMutation
        .run(
          ref,
          (tx) => tx
              .get(hostEventManageActionsProvider)
              .sharePrivateLink(
                club: club,
                event: event,
                inviteLink: inviteLink,
                origin: origin,
              ),
        )
        .then<void>(
          (_) {},
          onError: (Object error, StackTrace stackTrace) {
            ref
                .read(errorLoggerProvider)
                .logError(
                  error,
                  stackTrace,
                  reason: '_shareHostPrivateLink failed',
                );
          },
        ),
  );
}

class HostInviteLinksList extends ConsumerWidget {
  const HostInviteLinksList({
    super.key,
    required this.event,
    required this.inviteCode,
    required this.linksAsync,
    required this.onRetry,
  });

  final Event event;
  final String inviteCode;
  final AsyncValue<List<EventInviteLink>> linksAsync;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final createMutation = ref.watch(
      HostEventManageController.createInviteLinkMutation,
    );
    final copyMutation = ref.watch(
      HostEventManageController.copyInviteLinkMutation,
    );
    final disableMutation = ref.watch(
      HostEventManageController.disableInviteLinkMutation,
    );
    final listState = HostInviteLinksListDisplayState.resolve(
      createPending: createMutation.isPending,
      copyPending: copyMutation.isPending,
      disablePending: disableMutation.isPending,
    );
    final mutationError = [
      createMutation,
      copyMutation,
      disableMutation,
    ].firstWhere((mutation) => mutation.hasError, orElse: () => createMutation);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final button = CatchButton(
              label: 'New link',
              onPressed: listState.isMutating
                  ? null
                  : () => unawaited(_createNamedLink(context, ref)),
              variant: CatchButtonVariant.secondary,
              icon: Icon(CatchIcons.addRounded),
              isLoading: listState.createPending,
            );
            if (constraints.maxWidth < 360) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Named invite links',
                    style: CatchTextStyles.labelL(context),
                  ),
                  gapH10,
                  Align(alignment: Alignment.centerLeft, child: button),
                ],
              );
            }
            return Row(
              children: [
                Expanded(
                  child: Text(
                    'Named invite links',
                    style: CatchTextStyles.labelL(context),
                  ),
                ),
                button,
              ],
            );
          },
        ),
        gapH6,
        Text(
          'Track which channels create demand, bookings, arrivals, catches, and chats.',
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
        if (mutationError.hasError) ...[
          gapH12,
          CatchMutationErrorBanner(
            mutation: mutationError,
            errorContext: AppErrorContext.event,
          ),
        ],
        gapH12,
        CatchAsyncValueView<List<EventInviteLink>>(
          value: linksAsync,
          loadingBuilder: (_) => Text(
            'Loading invite links...',
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          errorBuilder: (_, error, _) => CatchInlineErrorState.fromError(
            error,
            context: AppErrorContext.event,
            compact: true,
            onRetry: onRetry,
          ),
          builder: (context, links) => links.isEmpty
              ? Text(
                  listState.emptyCopy,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                )
              : Column(
                  children: [
                    for (final link in links)
                      HostInviteLinkRow(
                        event: event,
                        inviteCode: inviteCode,
                        link: link,
                        actionsDisabled: listState.isMutating,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _createNamedLink(BuildContext context, WidgetRef ref) async {
    final draft = await _showInviteLinkDialog(context);
    if (draft == null) return;
    if (!context.mounted) return;
    try {
      final label = await HostEventManageController.createInviteLinkMutation
          .run(
            ref,
            (tx) => tx
                .get(hostEventManageActionsProvider)
                .createInviteLink(
                  event: event,
                  inviteCode: inviteCode,
                  draft: draft,
                ),
          );
      if (!context.mounted) return;
      showCatchSnackBar(context, '$label copied.');
    } catch (error, stackTrace) {
      ref
          .read(errorLoggerProvider)
          .logError(
            error,
            stackTrace,
            reason: 'HostInviteLinksList._createNamedLink failed',
          );
    }
  }
}

class HostInviteLinkRow extends ConsumerWidget {
  const HostInviteLinkRow({
    super.key,
    required this.event,
    required this.inviteCode,
    required this.link,
    required this.actionsDisabled,
  });

  final Event event;
  final String inviteCode;
  final EventInviteLink link;
  final bool actionsDisabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final rowState = HostInviteLinkRowDisplayState.resolve(
      event: event,
      inviteCode: inviteCode,
      link: link,
      actionsDisabled: actionsDisabled,
    );
    return Padding(
      padding: const EdgeInsets.only(bottom: CatchSpacing.s3),
      child: CatchSurface(
        padding: CatchInsets.contentDense,
        borderColor: t.line,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final details = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s1,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      rowState.label,
                      style: CatchTextStyles.labelL(context),
                    ),
                    if (rowState.showDisabledBadge)
                      const CatchBadge(label: 'Disabled'),
                  ],
                ),
                if (rowState.source != null) ...[
                  gapH2,
                  Text(
                    rowState.source!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                ],
                gapH8,
                Text(
                  rowState.stats,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            );
            final actions = Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Tooltip(
                  message: 'Copy link',
                  child: CatchIconButton(
                    onTap: rowState.actionsDisabled
                        ? null
                        : () => unawaited(
                            _copyInviteLink(context, ref, rowState.url),
                          ),
                    disabled: rowState.actionsDisabled,
                    child: Icon(
                      CatchIcons.contentCopyRounded,
                      size: CatchIcon.sm,
                    ),
                  ),
                ),
                if (rowState.showDisableAction) ...[
                  gapW8,
                  Tooltip(
                    message: 'Disable link',
                    child: CatchIconButton(
                      onTap: rowState.actionsDisabled
                          ? null
                          : () => unawaited(_disableInviteLink(context, ref)),
                      disabled: rowState.actionsDisabled,
                      child: Icon(
                        CatchIcons.hourglassDisabledRounded,
                        size: CatchIcon.sm,
                      ),
                    ),
                  ),
                ],
              ],
            );
            if (constraints.maxWidth < 340) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  details,
                  gapH10,
                  Align(alignment: Alignment.centerRight, child: actions),
                ],
              );
            }
            return Row(
              children: [
                Expanded(child: details),
                gapW8,
                actions,
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _copyInviteLink(
    BuildContext context,
    WidgetRef ref,
    String url,
  ) async {
    try {
      final label = await HostEventManageController.copyInviteLinkMutation.run(
        ref,
        (tx) => tx
            .get(hostEventManageActionsProvider)
            .copyInviteLink(label: link.label, url: url),
      );
      if (!context.mounted) return;
      showCatchSnackBar(context, '$label copied.');
    } catch (error, stackTrace) {
      ref
          .read(errorLoggerProvider)
          .logError(
            error,
            stackTrace,
            reason: 'HostInviteLinkRow._copyInviteLink failed',
          );
    }
  }

  Future<void> _disableInviteLink(BuildContext context, WidgetRef ref) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: 'Disable invite link?',
      message:
          'This stops new attribution for ${link.label}, but keeps its history in reporting.',
      actions: const [
        CatchDialogAction(label: 'Keep active', value: false),
        CatchDialogAction(label: 'Disable', value: true, isDestructive: true),
      ],
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    try {
      final label = await HostEventManageController.disableInviteLinkMutation
          .run(
            ref,
            (tx) => tx
                .get(hostEventManageActionsProvider)
                .disableInviteLink(event: event, link: link),
          );
      if (!context.mounted) return;
      showCatchSnackBar(context, '$label disabled.');
    } catch (error, stackTrace) {
      ref
          .read(errorLoggerProvider)
          .logError(
            error,
            stackTrace,
            reason: 'HostInviteLinkRow._disableInviteLink failed',
          );
    }
  }
}

Future<HostInviteLinkDraft?> _showInviteLinkDialog(BuildContext context) async {
  final labelController = TextEditingController();
  final sourceController = TextEditingController();
  try {
    return showDialog<HostInviteLinkDraft>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          final label = labelController.text.trim();
          final source = sourceController.text.trim();
          return CatchFormDialog(
            title: 'New invite link',
            actions: [
              CatchTextButton(
                label: 'Cancel',
                onPressed: () => Navigator.of(context).pop(),
              ),
              CatchTextButton(
                label: 'Create',
                onPressed: label.isEmpty
                    ? null
                    : () => Navigator.of(context).pop(
                        HostInviteLinkDraft(
                          label: label,
                          source: source.isEmpty ? null : source,
                        ),
                      ),
              ),
            ],
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchField.input(
                  title: 'Label',
                  controller: labelController,
                  placeholder: 'Instagram bio',
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                ),
                gapH12,
                CatchField.input(
                  title: 'Source',
                  isOptional: true,
                  controller: sourceController,
                  placeholder: 'instagram',
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ),
          );
        },
      ),
    );
  } finally {
    labelController.dispose();
    sourceController.dispose();
  }
}

class HostFullCapacityApron extends StatelessWidget {
  const HostFullCapacityApron({
    super.key,
    required this.event,
    required this.roster,
  });

  final Event event;
  final EventParticipationRoster? roster;

  @override
  Widget build(BuildContext context) {
    final booked = hostManageBookedCount(event, roster);
    final waitlisted = hostManageWaitlistedCount(event, roster);
    final open = (event.capacityLimit - booked).clamp(0, event.capacityLimit);
    final revenueEstimate = booked * event.priceInPaise;
    final revenueLabel = event.isFree
        ? 'Free'
        : EventFormatters.priceInPaise(
            revenueEstimate,
            currencyCode: event.currency,
          );
    final refundPolicy = event.effectiveEventPolicy.cancellationPolicy.title;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: HostCapacityTile(
                value: '$booked',
                suffix: '/${event.capacityLimit}',
                label: 'Booked',
                detail: '$open open',
              ),
            ),
            gapW10,
            Expanded(
              child: HostCapacityTile(
                value: '$waitlisted',
                label: 'Waitlist',
                detail: waitlisted == 1
                    ? '1 to review'
                    : '$waitlisted to review',
              ),
            ),
          ],
        ),
        gapH10,
        Row(
          children: [
            Expanded(
              child: HostCapacityTile(
                value: revenueLabel,
                label: 'Revenue est',
              ),
            ),
            gapW10,
            Expanded(
              child: HostCapacityTile(
                value: refundPolicy,
                label: 'Refund policy',
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class HostFullCapacityBanner extends StatelessWidget {
  const HostFullCapacityBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s4,
        vertical: CatchSpacing.s3,
      ),
      backgroundColor: t.ink,
      radius: CatchRadius.md,
      borderWidth: 0,
      child: Row(
        children: [
          Icon(CatchIcons.lockRounded, color: t.surface, size: CatchIcon.md),
          gapW10,
          Expanded(
            child: Text(
              'FULL - CAPACITY REACHED',
              style: CatchTextStyles.monoLabel(context, color: t.surface),
            ),
          ),
          Text(
            'WAITLIST OPEN',
            style: CatchTextStyles.badge(context, color: t.ink3),
          ),
        ],
      ),
    );
  }
}

class HostCapacityTile extends StatelessWidget {
  const HostCapacityTile({
    super.key,
    required this.value,
    required this.label,
    this.suffix,
    this.detail,
  });

  final String value;
  final String? suffix;
  final String label;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      padding: const EdgeInsets.all(CatchSpacing.s4),
      borderColor: t.line,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: value,
              style: CatchTextStyles.titleL(context, color: t.ink),
              children: [
                if (suffix != null)
                  TextSpan(
                    text: suffix,
                    style: CatchTextStyles.supporting(context, color: t.ink3),
                  ),
              ],
            ),
          ),
          gapH4,
          Text(
            label.toUpperCase(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.monoLabel(context, color: t.ink2),
          ),
          if (detail != null) ...[
            gapH4,
            Text(
              detail!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.supporting(context, color: t.ink3),
            ),
          ],
        ],
      ),
    );
  }
}

class HostEventActionsSection extends StatelessWidget {
  const HostEventActionsSection({
    super.key,
    required this.club,
    required this.event,
    required this.actionState,
    required this.actionError,
    required this.privateLinkActionState,
    required this.onEditEvent,
    required this.onCancelEvent,
    required this.onDeleteEvent,
    required this.onSharePrivateLink,
  });

  final Club club;
  final Event event;
  final HostEventActionDisplayState actionState;
  final Object? actionError;
  final HostPrivateLinkActionState? privateLinkActionState;
  final VoidCallback onEditEvent;
  final Future<void> Function() onCancelEvent;
  final Future<void> Function() onDeleteEvent;
  final ValueChanged<String> onSharePrivateLink;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final privateLinkState = privateLinkActionState;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HOST ACTIONS',
          style: CatchTextStyles.monoLabel(context, color: t.ink2),
        ),
        gapH10,
        Divider(color: t.line, height: 1),
        if (actionError != null) ...[
          gapH12,
          CatchErrorBanner.fromError(
            actionError!,
            context: AppErrorContext.event,
          ),
          gapH8,
        ],
        if (actionState.showEditAction)
          HostActionRow(
            label: 'Edit event details',
            detail: 'Schedule · location',
            onTap: actionState.isMutating ? null : onEditEvent,
          ),
        if (privateLinkState != null)
          HostActionRow(
            label: 'Share private link',
            detail: privateLinkState.shareDetail,
            onTap: !privateLinkState.canShare
                ? null
                : () => onSharePrivateLink(privateLinkState.inviteLink!),
            showDivider: false,
          ),
        gapH18,
        Text(
          'DANGER ZONE',
          style: CatchTextStyles.monoLabel(context, color: t.ink2),
        ),
        gapH10,
        if (actionState.showCancelledState)
          const HostActionRow(
            label: 'Event cancelled',
            detail: 'Records are retained',
            destructive: true,
            showDivider: false,
          )
        else ...[
          if (actionState.showCancelAction)
            HostActionRow(
              label: 'Cancel event',
              detail: actionState.cancelDetail,
              destructive: true,
              onTap: actionState.isMutating
                  ? null
                  : () => unawaited(onCancelEvent()),
              showDivider: actionState.showDeleteAction,
            ),
          if (actionState.showDeleteAction)
            HostActionRow(
              label: 'Delete unused event',
              detail: actionState.deleteDetail,
              destructive: true,
              onTap: actionState.isMutating
                  ? null
                  : () => unawaited(onDeleteEvent()),
              showDivider: false,
            ),
        ],
      ],
    );
  }
}

class HostActionRow extends StatelessWidget {
  const HostActionRow({
    super.key,
    required this.label,
    required this.detail,
    this.onTap,
    this.destructive = false,
    this.showDivider = true,
  });

  final String label;
  final String detail;
  final VoidCallback? onTap;
  final bool destructive;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final labelColor = destructive ? t.danger : t.ink;
    final detailColor = onTap == null ? t.ink3 : t.ink;

    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s8,
                CatchSpacing.s4,
                CatchSpacing.s4,
                CatchSpacing.s4,
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final labelText = Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.labelL(
                      context,
                      color: onTap == null ? t.ink3 : labelColor,
                    ),
                  );
                  final detailText = Text(
                    detail,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.supporting(
                      context,
                      color: detailColor,
                    ),
                  );
                  if (constraints.maxWidth < 330) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [labelText, gapH4, detailText],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(flex: 5, child: labelText),
                      gapW8,
                      Expanded(flex: 6, child: detailText),
                    ],
                  );
                },
              ),
            ),
            if (showDivider)
              Divider(color: t.line, height: 1, indent: CatchSpacing.s8),
          ],
        ),
      ),
    );
  }
}

class HostEventSummaryCard extends StatelessWidget {
  const HostEventSummaryCard({
    super.key,
    required this.club,
    required this.event,
  });

  final Club club;
  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final price = event.isFree
        ? 'Free'
        : EventFormatters.priceInPaise(
            event.priceInPaise,
            currencyCode: event.currency,
          );

    return CatchSurface(
      padding: CatchInsets.listBody,
      borderColor: t.line,
      child: Column(
        children: [
          HostEventSummaryRow(
            icon: CatchIcons.groupsRounded,
            label: 'Club',
            value: club.name,
          ),
          HostEventSummaryRow(
            icon: CatchIcons.locationOnOutlined,
            label: 'Meet',
            value: event.locationName,
          ),
          HostEventSummaryRow(
            icon: CatchIcons.routeRounded,
            label: 'Event',
            value: event.activitySummaryLabel,
          ),
          HostEventSummaryRow(
            icon: CatchIcons.paymentsOutlined,
            label: 'Price',
            value: price,
            showDivider: false,
          ),
        ],
      ),
    );
  }
}

class HostEventSummaryRow extends StatelessWidget {
  const HostEventSummaryRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.showDivider = true,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final iconWidget = Icon(icon, color: t.ink2, size: CatchIcon.md);
            final labelText = Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            );
            final valueText = Text(
              value,
              maxLines: 1,
              style: CatchTextStyles.labelL(context),
              textAlign: constraints.maxWidth < 340
                  ? TextAlign.left
                  : TextAlign.right,
              overflow: TextOverflow.ellipsis,
            );
            if (constraints.maxWidth < 340) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  iconWidget,
                  gapW10,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [labelText, gapH2, valueText],
                    ),
                  ),
                ],
              );
            }
            return Row(
              children: [
                iconWidget,
                gapW10,
                Expanded(child: labelText),
                gapW10,
                Expanded(flex: 3, child: valueText),
              ],
            );
          },
        ),
        if (showDivider) ...[gapH12, Divider(color: t.line, height: 1), gapH12],
      ],
    );
  }
}
