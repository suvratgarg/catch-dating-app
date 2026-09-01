import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
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
import 'package:catch_dating_app/core/widgets/catch_mutation_error_listener.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart'
    show EventAdmissionFormat;
import 'package:catch_dating_app/event_success/event_success.dart'
    show
        EventSuccessHostFixtureActions,
        EventSuccessHostSection,
        EventSuccessHostTab,
        EventSuccessOperationalRosterSummary;
import 'package:catch_dating_app/events/data/event_attendee_repository.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_attendee.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_invite_link.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/events/domain/event_private_access.dart';
import 'package:catch_dating_app/events/domain/route_event_plan.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_booking_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_attendance_panel.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_live_location_control.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_reviews_panel.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_roster_drawer.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_event_staff_section.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_operational_roster_panel.dart';
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

EventSuccessOperationalRosterSummary _operationalRosterSummary(
  List<EventAttendee>? attendees,
) {
  if (attendees == null) {
    return const EventSuccessOperationalRosterSummary(
      checkedInCount: 0,
      expectedCount: null,
    );
  }
  final expected = attendees.where(
    (attendee) =>
        attendee.status == EventAttendeeStatus.registered ||
        attendee.status == EventAttendeeStatus.checkedIn,
  );
  return EventSuccessOperationalRosterSummary(
    checkedInCount: expected.where((attendee) => attendee.isCheckedIn).length,
    expectedCount: expected.length,
  );
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
    this.referenceNow,
  });

  final Club club;
  final Event event;
  final VoidCallback onBackToSuccess;
  final HostEventManageSection initialSection;
  final ValueChanged<HostEventManageSection>? onSectionChanged;
  final EventSuccessHostFixtureActions? eventSuccessFixtureActions;
  final String initialParticipantSearchQuery;

  /// A deterministic clock used by captures and lifecycle-focused tests.
  /// Production callers leave this null and use the device clock.
  final DateTime? referenceNow;

  @override
  ConsumerState<HostEventManageScreen> createState() =>
      _HostEventManageScreenState();
}

class _HostEventManageScreenState extends ConsumerState<HostEventManageScreen> {
  late bool _rosterOpen =
      widget.initialSection == HostEventManageSection.guests;

  @override
  void didUpdateWidget(covariant HostEventManageScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialSection != widget.initialSection) {
      _rosterOpen = widget.initialSection == HostEventManageSection.guests;
    }
  }

  @override
  Widget build(BuildContext context) {
    final club = widget.club;
    final event = widget.event;
    final now = widget.referenceNow ?? DateTime.now();
    final screenState = HostEventManageScreenState.resolve(
      event: event,
      requestedSection: widget.initialSection,
      now: now,
    );
    final onBackToSuccess = widget.onBackToSuccess;
    final rosterAsync = ref.watch(
      watchEventParticipationRosterProvider(event.id),
    );
    final roster = catchAsyncStateFromAsyncValue(rosterAsync).value;
    final bookedCount = hostManageBookedCount(event, roster);
    final operationalAttendees =
        screenState.phase == HostEventWorkspacePhase.runtime
        ? catchAsyncStateFromAsyncValue(
            ref.watch(watchEventAttendeesProvider(event.id)),
          ).value
        : null;
    final operationalRosterSummary = _operationalRosterSummary(
      operationalAttendees,
    );
    final cancelMutation = ref.watch(
      HostEventBookingController.hostCancelEventMutation,
    );
    final deleteMutation = ref.watch(
      HostEventBookingController.deleteEventMutation,
    );
    final publicRegistrationMutation = ref.watch(
      HostEventBookingController.publicRegistrationMutation,
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
    final inviteLinksListState = HostInviteLinksListDisplayState.resolve(
      createPending: createInviteLinkMutation.isPending,
      copyPending: copyInviteLinkMutation.isPending,
      disablePending: disableInviteLinkMutation.isPending,
    );
    final inviteLinksMutationError = _firstMutationError([
      createInviteLinkMutation,
      copyInviteLinkMutation,
      disableInviteLinkMutation,
    ]);
    final actionError = _firstMutationError([cancelMutation, deleteMutation]);
    final hostActions = HostEventActionsSection(
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
            onDeleted: onBackToSuccess,
          ),
        );
      },
      onCancelEvent: () => _handleHostEventActionIntent(
        HostEventManageActionIntent.cancelEvent,
        event: event,
        onDeleted: onBackToSuccess,
      ),
      onDeleteEvent: () => _handleHostEventActionIntent(
        HostEventManageActionIntent.deleteEvent,
        event: event,
        onDeleted: onBackToSuccess,
      ),
      onSharePrivateLink: (inviteLink) => _shareHostPrivateLink(
        club: club,
        event: event,
        inviteLink: inviteLink,
      ),
    );
    final eventSuccessSetup = EventSuccessHostSection(
      event: event,
      referenceNow: now,
      showTabs: false,
      fixtureActions: widget.eventSuccessFixtureActions,
    );
    final workspaceChildren = switch (screenState.phase) {
      HostEventWorkspacePhase.preparation => <Widget>[
        if (_showsCapacityNotice(event)) ...[
          const HostFullCapacityBanner(),
          gapH12,
        ],
        HostFullCapacityApron(event: event, roster: roster),
        gapH20,
        HostEventSummaryCard(
          club: club,
          event: event,
          title: context.l10n.hostsHostEventManagePreparationEventDetails,
        ),
        gapH20,
        CatchSection.fieldRows(
          title: context.l10n.hostsHostEventManagePreparationGuestSources,
          children: [
            HostPublicRegistrationCard(
              club: club,
              event: event,
              mutation: publicRegistrationMutation,
              onChanged: (enabled) =>
                  _setPublicRegistration(event: event, enabled: enabled),
            ),
            HostGuestIntakeField(
              eventId: event.id,
              organizerId: event.clubId,
              bookingProvider: event.eventOrigin?.provider,
              suggestedRevenueAmountMinor: event.priceInPaise,
              revenueCurrency: event.currency,
            ),
          ],
        ),
        if (event.effectiveEventPolicy.usesInviteOnly) ...[
          gapH20,
          HostPrivateAccessCard(
            club: club,
            event: event,
            accessAsync: accessAsync!,
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
            onCopyInviteLink: (link) => unawaited(
              _copyNamedInviteLink(
                event: event,
                inviteCode: privateAccessState!.value!.inviteCode,
                link: link,
              ),
            ),
            onDisableInviteLink: (link) =>
                unawaited(_disableNamedInviteLink(event: event, link: link)),
          ),
        ],
        gapH20,
        CatchSection.fieldRows(
          title: context.l10n.hostsHostEventManagePreparationTeamAccess,
          children: [HostEventStaffSection(eventId: event.id)],
        ),
        gapH20,
        CatchSection.fieldRows(
          children: [
            CatchField.action(
              title: context.l10n.hostEventRehearsalEntryTitle,
              body: context.l10n.hostEventRehearsalEntryBody,
              icon: CatchIcons.scienceOutlined,
              emphasis: CatchFieldEmphasis.title,
              onTap: () => context.pushNamed(
                Routes.hostEventRehearsalStartScreen.name,
                pathParameters: {'clubId': club.id},
                queryParameters: {'eventId': event.id},
              ),
            ),
          ],
        ),
        gapH20,
        eventSuccessSetup,
        gapH20,
        hostActions,
      ],
      HostEventWorkspacePhase.runtime => <Widget>[
        if (event.eventFormat.routePlan?.liveTrackingPolicy.enabled ==
            true) ...[
          CatchSection.fieldRows(
            first: true,
            children: [HostEventLiveLocationControl(event: event)],
          ),
          gapH20,
        ],
        EventSuccessHostSection(
          event: event,
          referenceNow: now,
          initialTab: EventSuccessHostTab.live,
          showTabs: false,
          compactLiveControls: true,
          operationalRosterSummary: operationalRosterSummary,
          onOpenGuests: () => _setRosterOpen(true, screenState.phase),
          guestsWorkspaceSemanticLabel: context.l10n
              .hostsHostEventRosterDrawerOpen(count: bookedCount),
          fixtureActions: widget.eventSuccessFixtureActions,
        ),
      ],
      HostEventWorkspacePhase.recap => <Widget>[
        HostEventReviewsPanel(eventId: event.id),
        gapH20,
        EventSuccessHostSection(
          event: event,
          referenceNow: now,
          initialTab: EventSuccessHostTab.report,
          showTabs: false,
          fixtureActions: widget.eventSuccessFixtureActions,
        ),
        gapH20,
        CatchSection.fieldRows(
          first: true,
          children: [
            CatchField.control(
              title: context.l10n.hostsHostEventManageReviewSetupTitle,
              body: context.l10n.hostsHostEventManageReviewSetupBody,
              contractExemption:
                  'Read and management disclosure for an existing event; it '
                  'does not submit a scalar field value.',
              control: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HostEventSummaryCard(club: club, event: event),
                  gapH20,
                  hostActions,
                  gapH20,
                  eventSuccessSetup,
                ],
              ),
            ),
          ],
        ),
      ],
    };
    final rosterMode = switch (screenState.phase) {
      HostEventWorkspacePhase.preparation => HostEventParticipantsMode.setup,
      HostEventWorkspacePhase.runtime => HostEventParticipantsMode.live,
      HostEventWorkspacePhase.recap => HostEventParticipantsMode.report,
    };
    final rosterChildren = <Widget>[
      if (event.isExternalCompanion &&
          event.hasWebRuntime &&
          screenState.phase != HostEventWorkspacePhase.recap) ...[
        CatchSection.fieldRows(
          first: true,
          children: [
            CatchField.control(
              title: context.l10n.hostsHostEventAttendancePanelTitleCheckInQr,
              contractExemption:
                  'Disclosure-only public runtime URL and QR; no editable '
                  'value is submitted or persisted.',
              body: context.l10n.hostsHostEventAttendancePanelBodyCheckInQr,
              icon: CatchIcons.qrCode2Rounded,
              control: HostEventCheckInQrPanel(event: event),
            ),
          ],
        ),
        gapH20,
      ],
      HostOperationalRosterPanel(
        eventId: event.id,
        organizerId: event.clubId,
        allowManualGuest: screenState.phase == HostEventWorkspacePhase.runtime,
        allowAttendanceChanges:
            screenState.phase != HostEventWorkspacePhase.recap,
        allowRuntimeClaimReview:
            screenState.phase == HostEventWorkspacePhase.runtime,
      ),
      if (!event.isExternalCompanion) ...[
        gapH20,
        HostEventParticipantsPanel(
          eventId: event.id,
          mode: rosterMode,
          initialSearchQuery: widget.initialParticipantSearchQuery,
        ),
      ],
    ];
    final workspaceBody = screenState.phase == HostEventWorkspacePhase.runtime
        ? workspaceChildren.single
        : ListView(
            key: Key(
              context.l10n.hostsHostEventManageScreenBodyHostEventManageScroll,
            ),
            padding: CatchInsets.pageBody,
            children: workspaceChildren,
          );
    return CatchMutationErrorListener(
      mutation: HostEventManageController.sharePrivateLinkMutation,
      errorContext: AppErrorContext.event,
      child: CatchRouteScaffold(
        topBarBuilder: (context, scrolledUnder) => CatchTopBar(
          large: false,
          title: screenState.eventTitle,
          subtitle: _hostEventManageLifecycleLabel(
            context,
            event: event,
            phase: screenState.phase,
          ),
          height: MediaQuery.textScalerOf(context).scale(1) >= 1.4
              ? CatchScreenTopBar.heightFor(
                  context: context,
                  hasEyebrow: true,
                  titleMaxLines: 3,
                  titleStyle: CatchTextStyles.titleL(context),
                )
              : CatchLayout.browseHeaderHeight,
          allowContentHeightExpansion: true,
          contentCrossAxisAlignment: CrossAxisAlignment.start,
          titleWidget: _HostManageTopBarTitle(
            eyebrow: _hostEventManageLifecycleLabel(
              context,
              event: event,
              phase: screenState.phase,
            ),
            title: screenState.eventTitle,
          ),
          titleWidgetIncludesSupplementalText: true,
          leading: CatchIconAction(
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            icon: CatchIcons.arrowBackIosNewRounded,
            onPressed: onBackToSuccess,
          ),
          actions: [
            CatchTopBarPrimaryAction(
              label: context.l10n.hostsHostEventRosterDrawerTitle,
              icon: CatchIcons.groupsRounded,
              onPressed: () => _setRosterOpen(true, screenState.phase),
            ),
          ],
          divider: scrolledUnder,
        ),
        body: HostEventRosterDrawer(
          open: _rosterOpen,
          bookedCount: bookedCount,
          showHandle: false,
          onOpenChanged: (open) => _setRosterOpen(open, screenState.phase),
          onMessageGuests: () => _openEventMessages(club, event),
          bodyMaxWidth: screenState.phase == HostEventWorkspacePhase.runtime
              ? CatchLayout.hostEventLiveWorkspaceMaxContentWidth
              : CatchLayout.maxContentWidth,
          body: workspaceBody,
          roster: ListView(
            key: const ValueKey<String>('host_event_roster_drawer.scroll'),
            padding: CatchInsets.pageBody,
            children: rosterChildren,
          ),
        ),
      ),
    );
  }

  void _setRosterOpen(bool open, HostEventWorkspacePhase phase) {
    if (_rosterOpen == open) return;
    setState(() => _rosterOpen = open);
    widget.onSectionChanged?.call(
      open
          ? HostEventManageSection.guests
          : switch (phase) {
              HostEventWorkspacePhase.preparation =>
                HostEventManageSection.setup,
              HostEventWorkspacePhase.runtime => HostEventManageSection.live,
              HostEventWorkspacePhase.recap => HostEventManageSection.report,
            },
    );
  }

  void _openEventMessages(Club club, Event event) {
    context.pushNamed(
      Routes.hostInboxScreen.name,
      queryParameters: {'eventId': event.id},
      extra: club,
    );
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

  Future<void> _setPublicRegistration({
    required Event event,
    required bool enabled,
  }) async {
    try {
      await HostEventBookingController.publicRegistrationMutation.run(
        ref,
        (tx) => tx
            .get(hostEventBookingControllerProvider.notifier)
            .setPublicRegistration(event: event, enabled: enabled),
      );
    } catch (_) {
      // HostPublicRegistrationCard owns the localized mutation error.
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
    required Event event,
    required String inviteCode,
    required EventInviteLink link,
  }) async {
    try {
      final label = await HostEventManageController.copyInviteLinkMutation.run(
        ref,
        (tx) => tx
            .get(hostEventManageActionsProvider)
            .copyInviteLink(event: event, inviteCode: inviteCode, link: link),
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
  final void Function(EventInviteLink link) onCopyInviteLink;
  final void Function(EventInviteLink link) onDisableInviteLink;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchAsyncValueView<EventPrivateAccess?>(
      value: accessAsync,
      onRetry: onRetryPrivateAccess,
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
  return catchAsyncStateFromAsyncValue(value);
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
  final void Function(EventInviteLink link) onCopyInviteLink;
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
  final void Function(EventInviteLink link) onCopyInviteLink;
  final void Function(EventInviteLink link) onDisableInviteLink;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final button = CatchButton(
      label: context.l10n.hostsHostEventManageScreenLabelNewLink,
      onPressed: state.isMutating
          ? null
          : () => unawaited(_createNamedLink(context)),
      variant: CatchButtonVariant.secondary,
      icon: Icon(CatchIcons.addRounded),
      isLoading: state.createPending,
    );
    final heading = Text(
      context.l10n.hostsHostEventManageScreenTextNamedInviteLinks,
      style: CatchTextStyles.labelL(context),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ComponentResponsiveBuilder(
          breakpoint: ComponentBreakpoints.hostInviteLinksHeaderStackBreakpoint,
          compact: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              heading,
              gapH10,
              Align(alignment: Alignment.centerLeft, child: button),
            ],
          ),
          expanded: (context) => Row(
            children: [
              Expanded(child: heading),
              button,
            ],
          ),
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
          onRetry: onRetry,
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
  final void Function(EventInviteLink link) onCopyInviteLink;
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
    final details = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s1,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(rowState.label, style: CatchTextStyles.labelL(context)),
            if (rowState.showDisabledBadge)
              CatchBadge(
                label: context.l10n.hostsHostEventManageScreenLabelDisabled,
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
          message: context.l10n.hostsHostEventManageScreenMessageCopyLink,
          child: CatchIconButton(
            onTap: rowState.actionsDisabled
                ? null
                : () => onCopyInviteLink(link),
            disabled: rowState.actionsDisabled,
            child: Icon(CatchIcons.contentCopyRounded, size: CatchIcon.sm),
          ),
        ),
        if (rowState.showDisableAction) ...[
          gapW8,
          Tooltip(
            message: context.l10n.hostsHostEventManageScreenMessageDisableLink,
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
    return Padding(
      padding: CatchInsets.sectionItemBottomGap,
      child: CatchSurface(
        padding: CatchInsets.contentDense,
        borderColor: t.line,
        child: ComponentResponsiveBuilder(
          breakpoint: ComponentBreakpoints.hostInviteLinkRowStackBreakpoint,
          compact: (context) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              details,
              gapH10,
              Align(alignment: Alignment.centerRight, child: actions),
            ],
          ),
          expanded: (context) => Row(
            children: [
              Expanded(child: details),
              gapW8,
              actions,
            ],
          ),
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
            child: CatchFieldLanes.custom(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CatchField.input(
                    title: context.l10n.hostsHostEventManageScreenTitleLabel,
                    contract: CatchContractConstraints
                        .createEventInviteLinkCallablePayloadLabel,
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
                    contract: CatchContractConstraints
                        .createEventInviteLinkCallablePayloadSource,
                    isOptional: true,
                    controller: sourceController,
                    placeholder: context
                        .l10n
                        .hostsHostEventManageScreenPlaceholderInstagram,
                    onChanged: (_) => setState(() {}),
                  ),
                ],
              ),
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

    return CatchSection.fieldRows(
      first: true,
      children: [
        CatchField.read(
          icon: CatchIcons.groupsRounded,
          title: context.l10n.hostsHostEventManageScreenLabelBooked,
          body: context.l10n.hostsHostEventManageScreenDetailOpenOpen(
            open: open,
          ),
          valueText:
              '${context.l10n.hostsHostEventManageScreenVisiblecopyBooked(booked: booked)}'
              '${context.l10n.hostsHostEventManageScreenVisiblecopyCapacitylimit(capacityLimit: event.capacityLimit)}',
        ),
        CatchField.read(
          icon: CatchIcons.waitlisted,
          title: context.l10n.hostsHostEventManageScreenLabelWaitlist,
          body: waitlisted == 1
              ? context.l10n.hostsHostEventManageScreenDetail1ToReview
              : context.l10n.hostsHostEventManageScreenDetailWaitlistedToReview(
                  waitlisted: waitlisted,
                ),
          valueText: context.l10n
              .hostsHostEventManageScreenVisiblecopyWaitlisted(
                waitlisted: waitlisted,
              ),
        ),
        CatchField.read(
          icon: CatchIcons.paymentsOutlined,
          title: context.l10n.hostsHostEventManageScreenLabelRevenueEst,
          valueText: revenueLabel,
        ),
        CatchField.read(
          icon: CatchIcons.receiptLongOutlined,
          title: context.l10n.hostsHostEventManageScreenLabelRefundPolicy,
          valueText: refundPolicy,
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
      padding: CatchInsets.listBody,
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
    return CatchFieldLanes.single(
      child: CatchField.action(
        title: label,
        body: detail,
        titleMaxLines: 2,
        tone: destructive ? CatchFieldTone.danger : CatchFieldTone.normal,
        onTap: onTap,
      ),
    );
  }
}

class HostPublicRegistrationCard extends StatelessWidget {
  const HostPublicRegistrationCard({
    super.key,
    required this.club,
    required this.event,
    required this.mutation,
    required this.onChanged,
  });

  final Club club;
  final Event event;
  final MutationState<dynamic> mutation;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final organizerPublished =
        club.appVisibility == ClubAppVisibility.discoverable &&
        club.publicPage?.allowsPublicWebRead == true;
    final policy = event.effectiveEventPolicy;
    final supportsStandaloneRegistration =
        policy.basePriceInPaise == 0 &&
        policy.admissionPolicy.format == EventAdmissionFormat.open &&
        !policy.admissionPolicy.inviteRequired &&
        !policy.admissionPolicy.membershipRequired &&
        !policy.admissionPolicy.manualApprovalRequired;
    final enabled = event.publicRegistrationEnabled;
    return CatchFieldLanes.single(
      child: CatchField.control(
        key: const ValueKey<String>('host_event_website_registration_field'),
        title: context.l10n.hostsHostPublicRegistrationTitle,
        body: enabled
            ? context.l10n.hostsHostPublicRegistrationSubtitleEnabled
            : context.l10n.hostsHostPublicRegistrationSubtitleDisabled,
        icon: CatchIcons.languageOutlined,
        contractExemption:
            'Disclosure and mutation surface for server-owned public event '
            'registration; the field itself does not persist a scalar value.',
        control: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: CatchBadge.functional(
                label: enabled
                    ? context.l10n.hostsHostPublicRegistrationStatusOpen
                    : context.l10n.hostsHostPublicRegistrationStatusOff,
                tone: enabled ? CatchBadgeTone.success : CatchBadgeTone.neutral,
              ),
            ),
            gapH8,
            Text(
              !supportsStandaloneRegistration
                  ? context.l10n.hostsHostPublicRegistrationBodyUnsupported
                  : organizerPublished
                  ? context.l10n.hostsHostPublicRegistrationBodyPublished
                  : context.l10n.hostsHostPublicRegistrationBodyNeedsPage,
              style: CatchTextStyles.supporting(
                context,
                color: CatchTokens.of(context).ink2,
              ),
            ),
            gapH12,
            CatchButton(
              label: enabled
                  ? context.l10n.hostsHostPublicRegistrationActionDisable
                  : context.l10n.hostsHostPublicRegistrationActionEnable,
              onPressed:
                  mutation.isPending ||
                      ((!organizerPublished ||
                              !supportsStandaloneRegistration) &&
                          !enabled)
                  ? null
                  : () => onChanged(!enabled),
              isLoading: mutation.isPending,
              variant: enabled
                  ? CatchButtonVariant.secondary
                  : CatchButtonVariant.primary,
              fullWidth: true,
            ),
            if (mutation.hasError) ...[
              gapH8,
              CatchErrorBanner.fromError(
                (mutation as MutationError).error,
                context: AppErrorContext.event,
              ),
            ],
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
    this.title,
  });

  final Club club;
  final Event event;
  final String? title;

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
      title: title,
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
    final iconWidget = Icon(icon, color: t.ink2, size: CatchIcon.md);
    final labelText = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: CatchTextStyles.supporting(context, color: t.ink2),
    );

    return Column(
      children: [
        ComponentResponsiveBuilder(
          breakpoint: ComponentBreakpoints.hostEventSummaryRowStackBreakpoint,
          compact: (context) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              iconWidget,
              gapW10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    labelText,
                    gapH2,
                    Text(
                      value,
                      maxLines: 1,
                      style: CatchTextStyles.labelL(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          expanded: (context) => Row(
            children: [
              iconWidget,
              gapW10,
              Expanded(child: labelText),
              gapW10,
              Expanded(
                flex: 3,
                child: Text(
                  value,
                  maxLines: 1,
                  style: CatchTextStyles.labelL(context),
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
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

String _hostEventManageLifecycleLabel(
  BuildContext context, {
  required Event event,
  required HostEventWorkspacePhase phase,
}) => event.isCancelled
    ? context.l10n.hostsHostEventManageWorkspaceCancelled
    : switch (phase) {
        HostEventWorkspacePhase.preparation =>
          context.l10n.hostsHostEventManageWorkspacePreparation,
        HostEventWorkspacePhase.runtime =>
          context.l10n.hostsHostEventManageWorkspaceRuntime,
        HostEventWorkspacePhase.recap =>
          context.l10n.hostsHostEventManageWorkspaceRecap,
      };

class _HostManageTopBarTitle extends StatelessWidget {
  const _HostManageTopBarTitle({required this.eyebrow, required this.title});

  final String eyebrow;
  final String title;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.4;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          eyebrow,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.kicker(context, color: t.ink3),
        ),
        gapH2,
        Text(
          title,
          maxLines: largeText ? 3 : 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.titleL(context, color: t.ink),
        ),
      ],
    );
  }
}
