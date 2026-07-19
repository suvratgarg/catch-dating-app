import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
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
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_success/event_success.dart'
    show
        EventSuccessHostFixtureActions,
        EventSuccessHostSection,
        EventSuccessHostTab;
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_invite_link.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/domain/host_attendance_window.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_booking_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_attendance_panel.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/app_deep_links.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

export 'package:catch_dating_app/hosts/presentation/host_event_manage_screen_state.dart'
    show HostEventManageSection;

part 'host_event_manage_route_screen.dart';

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
      HostEventBookingController.hostCancelEventMutation,
    );
    final deleteMutation = ref.watch(
      HostEventBookingController.deleteEventMutation,
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
    final createInviteLinkMutation = ref.watch(
      HostEventManageController.createInviteLinkMutation,
    );
    final copyInviteLinkMutation = ref.watch(
      HostEventManageController.copyInviteLinkMutation,
    );
    final disableInviteLinkMutation = ref.watch(
      HostEventManageController.disableInviteLinkMutation,
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
      l10n: context.l10n,
      cancelEventPending: cancelMutation.isPending,
      deleteEventPending: deleteMutation.isPending,
    );
    final privateAccessState = _nullableCatchAsyncState(accessAsync);
    final inviteLinksState = _nullableCatchAsyncState(inviteLinksAsync);
    final privateLinkActionState = isInviteOnly
        ? HostPrivateLinkActionState.resolve(
            l10n: context.l10n,
            accessState: privateAccessState,
            inviteLinksState: inviteLinksState,
            inviteLink: _hostEventInviteUrl(
              clubId: club.id,
              eventId: event.id,
              inviteCode: privateAccessState?.value?.inviteCode,
            ),
            sharePending: shareMutation.isPending,
          )
        : null;
    return Scaffold(
      backgroundColor: t.bg,
      appBar: CatchTopBar(
        showBackButton: true,
        onBack: onBackToSuccess,
        border: true,
        height: CatchLayout.hostEventManageTopBarHeight,
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
        bottom: HostManageSectionPicker(
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
      body: ListView(
        key: Key(
          context.l10n.hostsHostEventManageScreenBodyHostEventManageScroll,
        ),
        padding: CatchInsets.pageBody,
        children: [
          ..._selectedSectionChildren(
            section: screenState.selectedSection,
            club: club,
            event: event,
            roster: roster,
            privateAccessAsync: accessAsync,
            inviteLinksAsync: inviteLinksAsync,
            shareMutation: shareMutation,
            inviteLinksListState: HostInviteLinksListDisplayState.resolve(
              createPending: createInviteLinkMutation.isPending,
              copyPending: copyInviteLinkMutation.isPending,
              disablePending: disableInviteLinkMutation.isPending,
            ),
            inviteLinksMutationError: _firstMutationError([
              createInviteLinkMutation,
              copyInviteLinkMutation,
              disableInviteLinkMutation,
            ]),
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
    required HostInviteLinksListDisplayState inviteLinksListState,
    required Object? inviteLinksMutationError,
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
            inviteLinksListState: inviteLinksListState,
            inviteLinksMutationError: inviteLinksMutationError,
            onRetryPrivateAccess: () =>
                ref.invalidate(watchEventPrivateAccessProvider(event.id)),
            onRetryInviteLinks: () =>
                ref.invalidate(watchEventInviteLinksProvider(event.id)),
            onSharePrivateLink: (inviteLink) => _shareHostPrivateLink(
              club: club,
              event: event,
              inviteLink: inviteLink,
            ),
            onCreateInviteLink: (draft) => _createNamedInviteLink(
              event: event,
              inviteCode: privateLinkActionState!.inviteCode!,
              draft: draft,
            ),
            onCopyInviteLink: (link, url) =>
                unawaited(_copyNamedInviteLink(link: link, url: url)),
            onDisableInviteLink: (link) =>
                unawaited(_disableNamedInviteLink(event: event, link: link)),
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
          mode:
              hostEventAttendanceStateFor(event: event, now: DateTime.now()) ==
                  HostEventAttendanceState.open
              ? HostEventParticipantsMode.live
              : HostEventParticipantsMode.setup,
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
      title: context.l10n.hostsHostEventManageScreenTitleCancelThisEvent,
      message:
          context.l10n.hostsHostEventManageScreenMessageCancellingRemovesItFrom,
      actions: [
        CatchDialogAction(
          label: context.l10n.hostsHostEventManageScreenLabelKeepEvent,
          value: false,
          isDefault: true,
        ),
        CatchDialogAction(
          label: context.l10n.hostsHostEventManageScreenLabelCancelEvent,
          value: true,
          isDestructive: true,
        ),
      ],
    );
    if (confirmed != true || !mounted) return;

    unawaited(
      HostEventBookingController.hostCancelEventMutation.run(ref, (tx) async {
        await tx
            .get(hostEventManageActionsProvider)
            .cancelHostedEvent(event: event);
        if (!mounted) return;
        showCatchSnackBar(
          context,
          context.l10n.hostsHostEventManageScreenVisiblecopyEventCancelled,
        );
      }),
    );
  }

  Future<void> _confirmDeleteEvent(Event event, VoidCallback onDeleted) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: context.l10n.hostsHostEventManageScreenTitleDeleteUnusedEvent,
      message: context.l10n.hostsHostEventManageScreenMessageOnlyEventsWithNo,
      actions: [
        CatchDialogAction(
          label: context.l10n.hostsHostEventManageScreenLabelKeepEvent,
          value: false,
          isDefault: true,
        ),
        CatchDialogAction(
          label: context.l10n.hostsHostEventManageScreenLabelDeleteUnusedEvent,
          value: true,
          isDestructive: true,
        ),
      ],
    );
    if (confirmed != true || !mounted) return;

    unawaited(
      HostEventBookingController.deleteEventMutation.run(ref, (tx) async {
        await tx
            .get(hostEventManageActionsProvider)
            .deleteUnusedEvent(event: event);
        if (!mounted) return;
        showCatchSnackBar(
          context,
          context.l10n.hostsHostEventManageScreenVisiblecopyEventDeleted,
        );
        onDeleted();
      }),
    );
  }

  Future<void> _createNamedInviteLink({
    required Event event,
    required String inviteCode,
    required HostInviteLinkDraft draft,
  }) async {
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
      if (!mounted) return;
      showCatchSnackBar(
        context,
        context.l10n.hostsHostEventManageScreenVisiblecopyLabelCopied(
          label: label,
        ),
      );
    } catch (error, stackTrace) {
      ref
          .read(errorLoggerProvider)
          .logError(
            error,
            stackTrace,
            reason: context
                .l10n
                .hostsHostEventManageScreenVisiblecopyHosteventmanagescreenCreatenamedinvitelinkFailed,
          );
    }
  }

  Future<void> _copyNamedInviteLink({
    required EventInviteLink link,
    required String url,
  }) async {
    try {
      final label = await HostEventManageController.copyInviteLinkMutation.run(
        ref,
        (tx) => tx
            .get(hostEventManageActionsProvider)
            .copyInviteLink(label: link.label, url: url),
      );
      if (!mounted) return;
      showCatchSnackBar(
        context,
        context.l10n.hostsHostEventManageScreenVisiblecopyLabelCopied(
          label: label,
        ),
      );
    } catch (error, stackTrace) {
      ref
          .read(errorLoggerProvider)
          .logError(
            error,
            stackTrace,
            reason: context
                .l10n
                .hostsHostEventManageScreenVisiblecopyHosteventmanagescreenCopynamedinvitelinkFailed,
          );
    }
  }

  Future<void> _disableNamedInviteLink({
    required Event event,
    required EventInviteLink link,
  }) async {
    final confirmed = await showCatchAdaptiveDialog<bool>(
      context: context,
      title: context.l10n.hostsHostEventManageScreenTitleDisableInviteLink,
      message: context.l10n
          .hostsHostEventManageScreenMessageThisStopsNewAttribution(
            label: link.label,
          ),
      actions: [
        CatchDialogAction(
          label: context.l10n.hostsHostEventManageScreenLabelKeepActive,
          value: false,
        ),
        CatchDialogAction(
          label: context.l10n.hostsHostEventManageScreenLabelDisable,
          value: true,
          isDestructive: true,
        ),
      ],
    );
    if (confirmed != true) return;
    if (!mounted) return;
    try {
      final label = await HostEventManageController.disableInviteLinkMutation
          .run(
            ref,
            (tx) => tx
                .get(hostEventManageActionsProvider)
                .disableInviteLink(event: event, link: link),
          );
      if (!mounted) return;
      showCatchSnackBar(
        context,
        context.l10n.hostsHostEventManageScreenVisiblecopyLabelDisabled(
          label: label,
        ),
      );
    } catch (error, stackTrace) {
      ref
          .read(errorLoggerProvider)
          .logError(
            error,
            stackTrace,
            reason: context
                .l10n
                .hostsHostEventManageScreenVisiblecopyHosteventmanagescreenDisablenamedinvitelinkFailed,
          );
    }
  }

  void _shareHostPrivateLink({
    required Club club,
    required Event event,
    required String inviteLink,
  }) {
    final box = context.findRenderObject() as RenderBox?;
    final l10n = context.l10n;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
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
                  l10n: l10n,
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
                    reason: l10n
                        .hostsHostEventManageScreenVisiblecopyHosteventmanagescreenSharehostprivatelinkFailed,
                  );
            },
          ),
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
          child: CatchMetaRow(
            icon: CatchIcons.calendarTodayOutlined,
            label: context.l10n
                .hostsHostEventManageScreenLabelShortdatelabelTime(
                  shortDateLabel: event.shortDateLabel,
                  time: EventFormatters.time(event.startTime),
                ),
            color: t.ink2,
          ),
        ),
        gapW12,
        Expanded(
          flex: 4,
          child: CatchMetaRow(
            icon: CatchIcons.pinOutlined,
            label: event.locationName,
            color: t.ink2,
          ),
        ),
        gapW12,
        Expanded(
          flex: 3,
          child: CatchMetaRow(
            icon: CatchIcons.groupsOutlined,
            label: event.spotsLabel,
            color: t.ink2,
          ),
        ),
      ],
    );
  }
}

class HostManageSectionPicker extends StatelessWidget
    implements PreferredSizeWidget {
  const HostManageSectionPicker({
    super.key,
    required this.selectedSection,
    required this.onChanged,
  });

  final HostEventManageSection selectedSection;
  final ValueChanged<HostEventManageSection> onChanged;

  @override
  Size get preferredSize => const Size.fromHeight(CatchLayout.tabRailHeight);

  @override
  Widget build(BuildContext context) {
    return CatchTabRail<HostEventManageSection>(
      options: [
        for (final section in HostEventManageSection.values)
          CatchOption(
            value: section,
            label: section.label(context.l10n).toUpperCase(),
          ),
      ],
      selected: selectedSection,
      onChanged: onChanged,
      variant: CatchOptionGroupVariant.mono,
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
    required this.inviteLinksListState,
    required this.inviteLinksMutationError,
    required this.onRetryPrivateAccess,
    required this.onRetryInviteLinks,
    required this.onSharePrivateLink,
    required this.onCreateInviteLink,
    required this.onCopyInviteLink,
    required this.onDisableInviteLink,
  });

  final Club club;
  final Event event;
  final AsyncValue<EventPrivateAccess?> accessAsync;
  final AsyncValue<List<EventInviteLink>> inviteLinksAsync;
  final MutationState<dynamic> shareMutation;
  final HostInviteLinksListDisplayState inviteLinksListState;
  final Object? inviteLinksMutationError;
  final VoidCallback onRetryPrivateAccess;
  final VoidCallback onRetryInviteLinks;
  final ValueChanged<String> onSharePrivateLink;
  final Future<void> Function(HostInviteLinkDraft draft) onCreateInviteLink;
  final void Function(EventInviteLink link, String url) onCopyInviteLink;
  final void Function(EventInviteLink link) onDisableInviteLink;

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
                context.l10n.hostsHostEventManageScreenTextLoadingInviteAccess,
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
          l10n: context.l10n,
          access: access,
          inviteLinksState: _catchAsyncState(inviteLinksAsync),
          inviteLink: _hostEventInviteUrl(
            clubId: club.id,
            eventId: event.id,
            inviteCode: access?.inviteCode,
          ),
          sharePending: shareMutation.isPending,
        );
        return HostPrivateAccessBody(
          event: event,
          state: privateAccessState,
          inviteLinksAsync: inviteLinksAsync,
          shareMutation: shareMutation,
          inviteLinksListState: inviteLinksListState,
          inviteLinksMutationError: inviteLinksMutationError,
          onRetryInviteLinks: onRetryInviteLinks,
          onSharePrivateLink: onSharePrivateLink,
          onCreateInviteLink: onCreateInviteLink,
          onCopyInviteLink: onCopyInviteLink,
          onDisableInviteLink: onDisableInviteLink,
        );
      },
    );
  }
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return value.when(
    data: CatchAsyncState<T>.data,
    loading: () => const CatchAsyncState.loading(),
    error: (error, stackTrace) => CatchAsyncState<T>.error(error),
  );
}

CatchAsyncState<T>? _nullableCatchAsyncState<T>(AsyncValue<T>? value) {
  return value == null ? null : _catchAsyncState(value);
}

String? _hostEventInviteUrl({
  required String clubId,
  required String eventId,
  required String? inviteCode,
  String? inviteLinkId,
}) {
  final normalizedInviteCode = inviteCode?.trim();
  if (normalizedInviteCode == null || normalizedInviteCode.isEmpty) {
    return null;
  }
  return AppDeepLinks.event(
    clubId: clubId,
    eventId: eventId,
    inviteCode: normalizedInviteCode,
    inviteLinkId: inviteLinkId,
  ).toString();
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
    required this.inviteLinksListState,
    required this.inviteLinksMutationError,
    required this.onRetryInviteLinks,
    required this.onSharePrivateLink,
    required this.onCreateInviteLink,
    required this.onCopyInviteLink,
    required this.onDisableInviteLink,
  });

  final Event event;
  final HostPrivateAccessDisplayState state;
  final AsyncValue<List<EventInviteLink>> inviteLinksAsync;
  final MutationState<dynamic> shareMutation;
  final HostInviteLinksListDisplayState inviteLinksListState;
  final Object? inviteLinksMutationError;
  final VoidCallback onRetryInviteLinks;
  final ValueChanged<String> onSharePrivateLink;
  final Future<void> Function(HostInviteLinkDraft draft) onCreateInviteLink;
  final void Function(EventInviteLink link, String url) onCopyInviteLink;
  final void Function(EventInviteLink link) onDisableInviteLink;

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
                      context.l10n.hostsHostEventManageScreenTextPrivateAccess,
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
              CatchBadge(
                label: context.l10n.hostsHostEventManageScreenLabelInvite,
                tone: CatchBadgeTone.brand,
              ),
            ],
          ),
          if (privateAccessState.hasInviteCode) ...[
            gapH14,
            HostEventSummaryRow(
              icon: CatchIcons.passwordRounded,
              label: context.l10n.hostsHostEventManageScreenLabelCode,
              value: linkAction.inviteCode!,
            ),
            if (linkAction.inviteLink != null)
              HostEventSummaryRow(
                icon: CatchIcons.linkRounded,
                label: context.l10n.hostsHostEventManageScreenLabelLink,
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
              label:
                  context.l10n.hostsHostEventManageScreenLabelSharePrivateLink,
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
              state: inviteLinksListState,
              mutationError: inviteLinksMutationError,
              onRetry: onRetryInviteLinks,
              onCreateInviteLink: onCreateInviteLink,
              onCopyInviteLink: onCopyInviteLink,
              onDisableInviteLink: onDisableInviteLink,
            ),
          ],
        ],
      ),
    );
  }
}

class HostInviteLinksList extends StatelessWidget {
  const HostInviteLinksList({
    super.key,
    required this.event,
    required this.inviteCode,
    required this.linksAsync,
    required this.state,
    required this.mutationError,
    required this.onRetry,
    required this.onCreateInviteLink,
    required this.onCopyInviteLink,
    required this.onDisableInviteLink,
  });

  final Event event;
  final String inviteCode;
  final AsyncValue<List<EventInviteLink>> linksAsync;
  final HostInviteLinksListDisplayState state;
  final Object? mutationError;
  final VoidCallback onRetry;
  final Future<void> Function(HostInviteLinkDraft draft) onCreateInviteLink;
  final void Function(EventInviteLink link, String url) onCopyInviteLink;
  final void Function(EventInviteLink link) onDisableInviteLink;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final button = CatchButton(
              label: context.l10n.hostsHostEventManageScreenLabelNewLink,
              onPressed: state.isMutating
                  ? null
                  : () => unawaited(_createNamedLink(context)),
              variant: CatchButtonVariant.secondary,
              icon: Icon(CatchIcons.addRounded),
              isLoading: state.createPending,
            );
            if (constraints.maxWidth < 360) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.l10n.hostsHostEventManageScreenTextNamedInviteLinks,
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
                    context.l10n.hostsHostEventManageScreenTextNamedInviteLinks,
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
          context.l10n.hostsHostEventManageScreenTextTrackWhichChannelsCreate,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
        if (mutationError != null) ...[
          gapH12,
          CatchErrorBanner.fromError(
            mutationError!,
            context: AppErrorContext.event,
          ),
        ],
        gapH12,
        CatchAsyncValueView<List<EventInviteLink>>(
          value: linksAsync,
          loadingBuilder: (_) => Text(
            context.l10n.hostsHostEventManageScreenTextLoadingInviteLinks,
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
                  state.emptyCopy,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                )
              : Column(
                  children: [
                    for (final link in links)
                      HostInviteLinkRow(
                        event: event,
                        inviteCode: inviteCode,
                        link: link,
                        actionsDisabled: state.isMutating,
                        onCopyInviteLink: onCopyInviteLink,
                        onDisableInviteLink: onDisableInviteLink,
                      ),
                  ],
                ),
        ),
      ],
    );
  }

  Future<void> _createNamedLink(BuildContext context) async {
    final draft = await _showInviteLinkDialog(context);
    if (draft == null) return;
    if (!context.mounted) return;
    await onCreateInviteLink(draft);
  }
}

class HostInviteLinkRow extends StatelessWidget {
  const HostInviteLinkRow({
    super.key,
    required this.event,
    required this.inviteCode,
    required this.link,
    required this.actionsDisabled,
    required this.onCopyInviteLink,
    required this.onDisableInviteLink,
  });

  final Event event;
  final String inviteCode;
  final EventInviteLink link;
  final bool actionsDisabled;
  final void Function(EventInviteLink link, String url) onCopyInviteLink;
  final void Function(EventInviteLink link) onDisableInviteLink;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final rowState = HostInviteLinkRowDisplayState.resolve(
      link: link,
      url: _hostEventInviteUrl(
        clubId: event.clubId,
        eventId: event.id,
        inviteCode: inviteCode,
        inviteLinkId: link.id,
      )!,
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
                      CatchBadge(
                        label: context
                            .l10n
                            .hostsHostEventManageScreenLabelDisabled,
                      ),
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
                  message:
                      context.l10n.hostsHostEventManageScreenMessageCopyLink,
                  child: CatchIconButton(
                    onTap: rowState.actionsDisabled
                        ? null
                        : () => onCopyInviteLink(link, rowState.url),
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
                    message: context
                        .l10n
                        .hostsHostEventManageScreenMessageDisableLink,
                    child: CatchIconButton(
                      onTap: rowState.actionsDisabled
                          ? null
                          : () => onDisableInviteLink(link),
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
            title: context.l10n.hostsHostEventManageScreenTitleNewInviteLink,
            actions: [
              CatchTextButton(
                label: context.l10n.hostsHostEventManageScreenLabelCancel,
                onPressed: () => Navigator.of(context).pop(),
              ),
              CatchTextButton(
                label: context.l10n.hostsHostEventManageScreenLabelCreate,
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
                  title: context.l10n.hostsHostEventManageScreenTitleLabel,
                  controller: labelController,
                  placeholder: context
                      .l10n
                      .hostsHostEventManageScreenPlaceholderInstagramBio,
                  textCapitalization: TextCapitalization.words,
                  onChanged: (_) => setState(() {}),
                ),
                gapH12,
                CatchField.input(
                  title: context.l10n.hostsHostEventManageScreenTitleSource,
                  isOptional: true,
                  controller: sourceController,
                  placeholder: context
                      .l10n
                      .hostsHostEventManageScreenPlaceholderInstagram,
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
        ? context.l10n.hostsHostEventManageScreenVisiblecopyFree
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
                value: context.l10n.hostsHostEventManageScreenVisiblecopyBooked(
                  booked: booked,
                ),
                suffix: context.l10n
                    .hostsHostEventManageScreenVisiblecopyCapacitylimit(
                      capacityLimit: event.capacityLimit,
                    ),
                label: context.l10n.hostsHostEventManageScreenLabelBooked,
                detail: context.l10n.hostsHostEventManageScreenDetailOpenOpen(
                  open: open,
                ),
              ),
            ),
            gapW10,
            Expanded(
              child: HostCapacityTile(
                value: context.l10n
                    .hostsHostEventManageScreenVisiblecopyWaitlisted(
                      waitlisted: waitlisted,
                    ),
                label: context.l10n.hostsHostEventManageScreenLabelWaitlist,
                detail: waitlisted == 1
                    ? context.l10n.hostsHostEventManageScreenDetail1ToReview
                    : context.l10n
                          .hostsHostEventManageScreenDetailWaitlistedToReview(
                            waitlisted: waitlisted,
                          ),
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
                label: context.l10n.hostsHostEventManageScreenLabelRevenueEst,
              ),
            ),
            gapW10,
            Expanded(
              child: HostCapacityTile(
                value: refundPolicy,
                label: context.l10n.hostsHostEventManageScreenLabelRefundPolicy,
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
              context.l10n.hostsHostEventManageScreenTextFullCapacityReached,
              style: CatchTextStyles.monoLabel(context, color: t.surface),
            ),
          ),
          Text(
            context.l10n.hostsHostEventManageScreenTextWaitlistOpen,
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
    final privateLinkState = privateLinkActionState;
    final hostActions = <Widget>[
      if (actionState.showEditAction)
        HostActionRow(
          label: context.l10n.hostsHostEventManageScreenLabelEditEventDetails,
          detail: context.l10n.hostsHostEventManageScreenDetailScheduleLocation,
          onTap: actionState.isMutating ? null : onEditEvent,
        ),
      if (privateLinkState != null)
        HostActionRow(
          label: context.l10n.hostsHostEventManageScreenLabelSharePrivateLink,
          detail: privateLinkState.shareDetail,
          onTap: !privateLinkState.canShare
              ? null
              : () => onSharePrivateLink(privateLinkState.inviteLink!),
        ),
    ];
    final dangerActions = <Widget>[
      if (actionState.showCancelledState)
        HostActionRow(
          label: context.l10n.hostsHostEventManageScreenLabelEventCancelled,
          detail:
              context.l10n.hostsHostEventManageScreenDetailRecordsAreRetained,
          destructive: true,
        )
      else ...[
        if (actionState.showCancelAction)
          HostActionRow(
            label: context.l10n.hostsHostEventManageScreenLabelCancelEvent,
            detail: actionState.cancelDetail,
            destructive: true,
            onTap: actionState.isMutating
                ? null
                : () => unawaited(onCancelEvent()),
          ),
        if (actionState.showDeleteAction)
          HostActionRow(
            label:
                context.l10n.hostsHostEventManageScreenLabelDeleteUnusedEvent,
            detail: actionState.deleteDetail,
            destructive: true,
            onTap: actionState.isMutating
                ? null
                : () => unawaited(onDeleteEvent()),
          ),
      ],
    ];

    return CatchSectionList(
      emptyStateOmitted: true,
      gap: 0,
      children: [
        CatchSection.fieldRows(
          first: true,
          title: context.l10n.hostsHostEventManageScreenTextHostActions,
          children: hostActions,
        ),
        if (actionError != null) ...[
          gapH12,
          CatchErrorBanner.fromError(
            actionError!,
            context: AppErrorContext.event,
          ),
          gapH4,
        ],
        CatchSection.fieldRows(
          title: context.l10n.hostsHostEventManageScreenTextDangerZone,
          children: dangerActions,
        ),
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
  });

  final String label;
  final String detail;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return CatchField.action(
      title: label,
      body: detail,
      titleMaxLines: 2,
      tone: destructive ? CatchFieldTone.danger : CatchFieldTone.normal,
      onTap: onTap,
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
    final price = event.isFree
        ? context.l10n.hostsHostEventManageScreenVisiblecopyFree
        : EventFormatters.priceInPaise(
            event.priceInPaise,
            currencyCode: event.currency,
          );

    return CatchSection.fieldRows(
      first: true,
      children: [
        CatchField.read(
          icon: CatchIcons.groupsRounded,
          title: context.l10n.hostsHostEventManageScreenLabelClub,
          body: club.name,
        ),
        CatchField.read(
          icon: CatchIcons.locationOnOutlined,
          title: context.l10n.hostsHostEventManageScreenLabelMeet,
          body: event.locationName,
        ),
        CatchField.read(
          icon: CatchIcons.routeRounded,
          title: context.l10n.hostsHostEventManageScreenLabelEvent,
          body: event.activitySummaryLabel,
        ),
        CatchField.read(
          icon: CatchIcons.paymentsOutlined,
          title: context.l10n.hostsHostEventManageScreenLabelPrice,
          body: price,
        ),
      ],
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
        if (showDivider) ...[
          gapH12,
          const CatchDivider.fieldRow(indent: 0),
          gapH12,
        ],
      ],
    );
  }
}
