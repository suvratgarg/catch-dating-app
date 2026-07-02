import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/attendance_sheet_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_action_keys.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/catch_roster_board.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

enum HostEventParticipantsMode { setup, live, report }

class HostEventAttendancePanel extends StatelessWidget {
  const HostEventAttendancePanel({
    super.key,
    required this.eventId,
    this.scrollable = false,
    this.showSummaryHeader = true,
    this.initialSearchQuery = '',
  });

  final String eventId;
  final bool scrollable;
  final bool showSummaryHeader;
  final String initialSearchQuery;

  @override
  Widget build(BuildContext context) {
    return HostEventParticipantsPanel(
      eventId: eventId,
      mode: HostEventParticipantsMode.live,
      scrollable: scrollable,
      showSummaryHeader: showSummaryHeader,
      initialSearchQuery: initialSearchQuery,
    );
  }
}

class HostEventParticipantsPanel extends ConsumerWidget {
  const HostEventParticipantsPanel({
    super.key,
    required this.eventId,
    required this.mode,
    this.scrollable = false,
    this.showSummaryHeader = true,
    this.initialSearchQuery = '',
  });

  final String eventId;
  final HostEventParticipantsMode mode;
  final bool scrollable;
  final bool showSummaryHeader;
  final String initialSearchQuery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(
      attendanceSheetViewModelProvider(eventId),
    );

    return CatchAsyncValueView<AttendanceSheetViewModel?>(
      value: attendanceAsync,
      loadingBuilder: (_) => const HostRosterSkeleton(),
      errorBuilder: (_, error, _) => Padding(
        padding: CatchInsets.content,
        child: CatchInlineErrorState.fromError(
          error,
          context: AppErrorContext.event,
          onRetry: () {
            ref.invalidate(watchEventProvider(eventId));
            ref.invalidate(watchEventParticipationsForEventProvider(eventId));
            ref.invalidate(attendanceSheetViewModelProvider(eventId));
          },
        ),
      ),
      builder: (context, viewModel) {
        if (viewModel == null) {
          return Padding(
            padding: CatchInsets.contentVerticalRelaxed,
            child: CatchEmptyState(
              icon: CatchIcons.eventBusyOutlined,
              title: 'Event not found',
              message: 'This event is no longer available.',
            ),
          );
        }
        final markAttendanceMutation = ref.watch(
          EventBookingController.markAttendanceMutation,
        );
        final approveMutation = ref.watch(
          EventBookingController.approveJoinRequestMutation,
        );
        final declineMutation = ref.watch(
          EventBookingController.declineJoinRequestMutation,
        );
        final offerMutation = ref.watch(
          EventBookingController.createWaitlistOfferMutation,
        );
        final opsExportMutation = ref.watch(
          HostEventManageController.shareOpsReportMutation,
        );
        final revenueExportMutation = ref.watch(
          HostEventManageController.shareRevenueReportMutation,
        );
        final mutationState = HostParticipantsMutationDisplayState.resolve(
          markAttendancePending: markAttendanceMutation.isPending,
          approveJoinRequestPending: approveMutation.isPending,
          declineJoinRequestPending: declineMutation.isPending,
          createWaitlistOfferPending: offerMutation.isPending,
          opsReportPending: opsExportMutation.isPending,
          revenueReportPending: revenueExportMutation.isPending,
          markAttendanceError: _mutationError(markAttendanceMutation),
          approveJoinRequestError: _mutationError(approveMutation),
          declineJoinRequestError: _mutationError(declineMutation),
          createWaitlistOfferError: _mutationError(offerMutation),
          opsReportError: _mutationError(opsExportMutation),
          revenueReportError: _mutationError(revenueExportMutation),
        );

        final profileIds = viewModel.profileIds;
        final profilesAsync = profileIds.isEmpty
            ? null
            : ref.watch(attendeeProfilesProvider(profileIds));
        final profileLookupState = HostParticipantProfilesLookupState.resolve(
          profileIds: profileIds,
          profilesAsync: profilesAsync,
        );

        return HostEventParticipantsList(
          viewModel: viewModel,
          mode: mode,
          scrollable: scrollable,
          showSummaryHeader: showSummaryHeader,
          initialSearchQuery: initialSearchQuery,
          profileLookupState: profileLookupState,
          mutationState: mutationState,
          actions: HostParticipantLifecycleActions(
            openProfile: (uid) => _openPublicProfile(context, uid),
            approveJoinRequest: (uid) =>
                _approveJoinRequest(ref, viewModel, uid),
            declineJoinRequest: (uid) =>
                _declineJoinRequest(ref, viewModel, uid),
            toggleAttendance: (uid) => _toggleAttendance(ref, viewModel, uid),
            createWaitlistOffers: (userIds) =>
                _createWaitlistOffers(ref, viewModel, userIds),
            shareOpsReport: () =>
                _shareOpsReport(context, ref, viewModel, profileLookupState),
            shareRevenueReport: () => _shareRevenueReport(
              context,
              ref,
              viewModel,
              profileLookupState,
            ),
          ),
          onRetryProfiles: () => ref.invalidate(
            attendeeProfilesProvider(profileLookupState.profileIds),
          ),
        );
      },
    );
  }
}

void _toggleAttendance(
  WidgetRef ref,
  AttendanceSheetViewModel viewModel,
  String uid,
) {
  final mutation = ref.read(EventBookingController.markAttendanceMutation);
  if (mutation.isPending) return;
  EventBookingController.markAttendanceMutation.run(
    ref,
    (tx) async => tx
        .get(eventBookingControllerProvider.notifier)
        .markAttendance(eventId: viewModel.event.id, userId: uid),
  );
}

void _approveJoinRequest(
  WidgetRef ref,
  AttendanceSheetViewModel viewModel,
  String uid,
) {
  final mutation = ref.read(EventBookingController.approveJoinRequestMutation);
  if (mutation.isPending) return;
  EventBookingController.approveJoinRequestMutation.run(
    ref,
    (tx) async => tx
        .get(eventBookingControllerProvider.notifier)
        .approveJoinRequest(eventId: viewModel.event.id, userId: uid),
  );
}

void _declineJoinRequest(
  WidgetRef ref,
  AttendanceSheetViewModel viewModel,
  String uid,
) {
  final mutation = ref.read(EventBookingController.declineJoinRequestMutation);
  if (mutation.isPending) return;
  EventBookingController.declineJoinRequestMutation.run(
    ref,
    (tx) async => tx
        .get(eventBookingControllerProvider.notifier)
        .declineJoinRequest(eventId: viewModel.event.id, userId: uid),
  );
}

void _createWaitlistOffers(
  WidgetRef ref,
  AttendanceSheetViewModel viewModel,
  List<String> userIds,
) {
  if (userIds.isEmpty) return;
  final mutation = ref.read(EventBookingController.createWaitlistOfferMutation);
  if (mutation.isPending) return;
  EventBookingController.createWaitlistOfferMutation.run(
    ref,
    (tx) async => tx
        .get(eventBookingControllerProvider.notifier)
        .createWaitlistOffers(eventId: viewModel.event.id, userIds: userIds),
  );
}

Future<void> _shareRevenueReport(
  BuildContext context,
  WidgetRef ref,
  AttendanceSheetViewModel viewModel,
  HostParticipantProfilesLookupState profileLookupState,
) async {
  final origin = _shareOrigin(context);
  try {
    await HostEventManageController.shareRevenueReportMutation.run(
      ref,
      (tx) => tx
          .get(hostEventManageActionsProvider)
          .shareRevenueReport(
            viewModel: viewModel,
            profiles: profileLookupState.profiles,
            origin: origin,
          ),
    );
    if (!context.mounted) return;
    showCatchSnackBar(context, 'Revenue CSV ready.');
  } catch (error, stackTrace) {
    ref
        .read(errorLoggerProvider)
        .logError(error, stackTrace, reason: '_shareRevenueReport failed');
  }
}

Future<void> _shareOpsReport(
  BuildContext context,
  WidgetRef ref,
  AttendanceSheetViewModel viewModel,
  HostParticipantProfilesLookupState profileLookupState,
) async {
  final origin = _shareOrigin(context);
  try {
    await HostEventManageController.shareOpsReportMutation.run(
      ref,
      (tx) => tx
          .get(hostEventManageActionsProvider)
          .shareOpsReport(
            viewModel: viewModel,
            profiles: profileLookupState.profiles,
            origin: origin,
          ),
    );
    if (!context.mounted) return;
    showCatchSnackBar(context, 'Ops CSV ready.');
  } catch (error, stackTrace) {
    ref
        .read(errorLoggerProvider)
        .logError(error, stackTrace, reason: '_shareOpsReport failed');
  }
}

Rect? _shareOrigin(BuildContext context) {
  final box = context.findRenderObject() as RenderBox?;
  return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
}

void _openPublicProfile(BuildContext context, String uid) {
  final router = GoRouter.maybeOf(context);
  if (router == null) return;
  router.pushNamed(
    Routes.publicProfileScreen.name,
    pathParameters: {'uid': uid},
  );
}

class HostEventParticipantsList extends StatefulWidget {
  const HostEventParticipantsList({
    super.key,
    required this.viewModel,
    required this.mode,
    required this.scrollable,
    required this.showSummaryHeader,
    required this.initialSearchQuery,
    required this.profileLookupState,
    required this.mutationState,
    required this.actions,
    required this.onRetryProfiles,
  });

  final AttendanceSheetViewModel viewModel;
  final HostEventParticipantsMode mode;
  final bool scrollable;
  final bool showSummaryHeader;
  final String initialSearchQuery;
  final HostParticipantProfilesLookupState profileLookupState;
  final HostParticipantsMutationDisplayState mutationState;
  final HostParticipantLifecycleActions actions;
  final VoidCallback onRetryProfiles;

  @override
  State<HostEventParticipantsList> createState() =>
      _HostEventParticipantsListState();
}

class _HostEventParticipantsListState extends State<HostEventParticipantsList> {
  late var _searchQuery = widget.initialSearchQuery;
  var _selectedFilter = HostRosterFilter.all;

  @override
  void didUpdateWidget(covariant HostEventParticipantsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _selectedFilter = HostRosterFilter.all;
    }
    if (oldWidget.initialSearchQuery != widget.initialSearchQuery) {
      _searchQuery = widget.initialSearchQuery;
    }
  }

  @override
  Widget build(BuildContext context) {
    final mutationState = widget.mutationState;
    final usesRequestApproval = widget
        .viewModel
        .event
        .effectiveEventPolicy
        .admissionPolicy
        .manualApprovalRequired;
    final profileLookupState = widget.profileLookupState;
    Widget buildBoard() {
      return HostParticipationLifecycleBoard(
        viewModel: widget.viewModel,
        mode: widget.mode,
        profiles: profileLookupState.profiles,
        scrollable: widget.scrollable,
        showHeader: widget.showSummaryHeader,
        usesRequestApproval: usesRequestApproval,
        mutationState: mutationState,
        actions: widget.actions,
        searchQuery: _searchQuery,
        selectedFilter: _selectedFilter,
        onSearchChanged: (value) => setState(() => _searchQuery = value),
        onFilterChanged: (value) => setState(() => _selectedFilter = value),
      );
    }

    final rows = switch (profileLookupState.status) {
      HostParticipantProfilesLookupStatus.ready => buildBoard(),
      HostParticipantProfilesLookupStatus.loading => const HostRosterSkeleton(),
      HostParticipantProfilesLookupStatus.error => Padding(
        padding: CatchInsets.content,
        child: CatchInlineErrorState.fromError(
          profileLookupState.error!,
          context: AppErrorContext.event,
          onRetry: widget.onRetryProfiles,
        ),
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (mutationState.participantActionError != null)
          CatchErrorBanner.fromError(
            mutationState.participantActionError!,
            context: AppErrorContext.event,
          ),
        if (widget.scrollable) Expanded(child: rows) else rows,
      ],
    );
  }
}

class HostParticipationLifecycleBoard extends StatelessWidget {
  const HostParticipationLifecycleBoard({
    super.key,
    required this.viewModel,
    required this.mode,
    required this.profiles,
    required this.scrollable,
    required this.showHeader,
    required this.usesRequestApproval,
    required this.mutationState,
    required this.actions,
    required this.searchQuery,
    required this.selectedFilter,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  final AttendanceSheetViewModel viewModel;
  final HostEventParticipantsMode mode;
  final Map<String, (String, String?)> profiles;
  final bool scrollable;
  final bool showHeader;
  final bool usesRequestApproval;
  final HostParticipantsMutationDisplayState mutationState;
  final HostParticipantLifecycleActions actions;
  final String searchQuery;
  final HostRosterFilter selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<HostRosterFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final children = switch (mode) {
      HostEventParticipantsMode.setup => _setupChildren(context),
      HostEventParticipantsMode.live => _liveChildren(context),
      HostEventParticipantsMode.report => _reportChildren(context),
    };

    return ListView(
      shrinkWrap: !scrollable,
      primary: scrollable ? null : false,
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: scrollable ? CatchSpacing.s6 : 0),
      children: children,
    );
  }

  List<Widget> _setupChildren(BuildContext context) {
    final rosterState = HostRosterDisplayState.setup(
      usesRequestApproval: usesRequestApproval,
      attendeeIds: viewModel.attendeeIds,
      waitlistedIds: viewModel.waitlistedIds,
      totalCount: viewModel.totalCount,
      capacityLimit: viewModel.event.capacityLimit,
      waitlistCount: viewModel.waitlistCount,
      participationsByUid: viewModel.participationsByUid,
      profiles: profiles,
      searchQuery: searchQuery,
      selectedFilter: selectedFilter,
    );

    return [
      if (showHeader) ...[
        HostRosterFilterHeader(
          title: 'Participation',
          subtitle: usesRequestApproval
              ? 'Review profiles and approve requests before launch.'
              : 'Review booking status before launch.',
          filters: rosterState.filters,
          selectedFilter: rosterState.activeFilter,
          onFilterChanged: onFilterChanged,
        ),
        gapH12,
      ],
      if (rosterState.showBulkOfferAction) ...[
        HostWaitlistBulkOfferAction(
          count: rosterState.bulkOfferCount,
          candidateCount: rosterState.offerableWaitlistIds.length,
          isPending: mutationState.waitlistOfferPending,
          onOffer: () => actions.createWaitlistOffers(rosterState.bulkOfferIds),
        ),
        gapH12,
      ],
      HostRosterSearchBar(
        value: searchQuery,
        label: 'Search people',
        onChanged: onSearchChanged,
      ),
      gapH14,
      CatchRosterTable(
        columns: const ['Guest', 'Signal', 'Host action'],
        showEmpty: rosterState.rowIds.isEmpty,
        emptyTitle: rosterState.emptyTitle,
        emptyMessage: rosterState.emptyMessage,
        rows: [
          for (final uid in rosterState.rowIds)
            _setupRow(
              uid,
              usesRequestApproval: usesRequestApproval,
              requestActionPending: mutationState.requestActionPending,
              offerActionPending: mutationState.waitlistOfferPending,
            ),
        ],
      ),
    ];
  }

  List<Widget> _liveChildren(BuildContext context) {
    final rosterState = HostRosterDisplayState.live(
      usesRequestApproval: usesRequestApproval,
      attendeeIds: viewModel.attendeeIds,
      attendedIds: viewModel.attendedIds,
      waitlistedIds: viewModel.waitlistedIds,
      totalCount: viewModel.totalCount,
      capacityLimit: viewModel.event.capacityLimit,
      participationsByUid: viewModel.participationsByUid,
      profiles: profiles,
      searchQuery: searchQuery,
      selectedFilter: selectedFilter,
    );

    return [
      HostRosterFilterHeader(
        title: showHeader ? 'Check-in board' : null,
        subtitle: showHeader
            ? 'Use the status tiles to focus the roster as people arrive.'
            : null,
        filters: rosterState.filters,
        selectedFilter: rosterState.activeFilter,
        onFilterChanged: onFilterChanged,
      ),
      gapH12,
      if (rosterState.showBulkOfferAction) ...[
        HostWaitlistBulkOfferAction(
          count: rosterState.bulkOfferCount,
          candidateCount: rosterState.offerableWaitlistIds.length,
          isPending: mutationState.waitlistOfferPending,
          onOffer: () => actions.createWaitlistOffers(rosterState.bulkOfferIds),
        ),
        gapH12,
      ],
      HostRosterSearchBar(
        value: searchQuery,
        label: 'Search roster',
        onChanged: onSearchChanged,
      ),
      gapH14,
      CatchRosterTable(
        columns: const ['Guest', 'Status', 'Host action'],
        showEmpty: rosterState.rowIds.isEmpty,
        emptyTitle: rosterState.emptyTitle,
        emptyMessage: rosterState.emptyMessage,
        rows: [
          for (final uid in rosterState.rowIds)
            _liveRow(
              uid,
              usesRequestApproval: usesRequestApproval,
              attendanceActionPending: mutationState.attendanceActionPending,
              offerActionPending: mutationState.waitlistOfferPending,
            ),
        ],
      ),
    ];
  }

  List<Widget> _reportChildren(BuildContext context) {
    final t = CatchTokens.of(context);
    final reportSummary = HostReportSummaryDisplayState.resolve(
      totalCount: viewModel.totalCount,
      checkedInCount: viewModel.checkedInCount,
      waitlistCount: viewModel.waitlistCount,
      priceInPaise: viewModel.event.priceInPaise,
      currencyCode: viewModel.event.currency,
    );
    final rosterState = HostRosterDisplayState.report(
      attendeeIds: viewModel.attendeeIds,
      attendedIds: viewModel.attendedIds,
      waitlistedIds: viewModel.waitlistedIds,
      totalCount: viewModel.totalCount,
      waitlistCount: viewModel.waitlistCount,
      profiles: profiles,
      searchQuery: searchQuery,
      selectedFilter: selectedFilter,
    );

    return [
      if (showHeader) ...[
        HostRosterFilterHeader(
          title: 'Event report',
          subtitle: 'Attendance, payout, and export-ready roster history.',
          filters: rosterState.filters,
          selectedFilter: rosterState.activeFilter,
          onFilterChanged: onFilterChanged,
        ),
        gapH12,
      ],
      HostRosterSearchBar(
        value: searchQuery,
        label: 'Search roster',
        onChanged: onSearchChanged,
      ),
      gapH14,
      CatchRosterTable(
        columns: const ['Name', 'Attendance', 'Payment'],
        showEmpty: rosterState.rowIds.isEmpty,
        emptyTitle: rosterState.emptyTitle,
        emptyMessage: rosterState.emptyMessage,
        rows: [for (final uid in rosterState.rowIds) _reportRow(uid)],
      ),
      gapH12,
      CatchSurface(
        padding: CatchInsets.compactControlContent,
        borderColor: t.line,
        radius: CatchRadius.md,
        backgroundColor: t.raised,
        child: Text(
          reportSummary.summary,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
      ),
      gapH12,
      if (mutationState.reportExportError != null) ...[
        CatchErrorBanner.fromError(
          mutationState.reportExportError!,
          context: AppErrorContext.event,
        ),
        gapH12,
      ],
      Row(
        children: [
          Expanded(
            child: HostExportReportButton(
              label: 'Ops CSV',
              isExporting: mutationState.opsReportExportPending,
              onExport: actions.shareOpsReport,
            ),
          ),
          gapW10,
          Expanded(
            child: HostExportReportButton(
              label: 'Revenue CSV',
              primary: true,
              isExporting: mutationState.revenueReportExportPending,
              onExport: actions.shareRevenueReport,
            ),
          ),
        ],
      ),
    ];
  }

  CatchRosterRow _setupRow(
    String uid, {
    required bool usesRequestApproval,
    required bool requestActionPending,
    required bool offerActionPending,
  }) {
    final participation = viewModel.participationFor(uid);
    final rowState = HostSetupRosterRowDisplayState.resolve(
      participation: participation,
      usesRequestApproval: usesRequestApproval,
    );
    final CatchRosterAction action;
    if (rowState.showRequestActions) {
      action = CatchRosterDecideAction(
        onProfile: () => actions.openProfile(uid),
        onApprove: requestActionPending
            ? null
            : () => actions.approveJoinRequest(uid),
        onDecline: requestActionPending
            ? null
            : () => actions.declineJoinRequest(uid),
      );
    } else if (rowState.showWaitlistOfferAction) {
      action = _waitlistOfferAction(
        uid,
        participation,
        offerActionPending: offerActionPending,
      );
    } else {
      action = _profileAction(uid);
    }
    return CatchRosterRow(
      person: _nameFor(uid),
      imageUrl: _photoFor(uid),
      meta: rowState.meta,
      signal: rowState.signal,
      tone: rowState.tone,
      action: action,
    );
  }

  CatchRosterRow _liveRow(
    String uid, {
    required bool usesRequestApproval,
    required bool attendanceActionPending,
    required bool offerActionPending,
  }) {
    final participation = viewModel.participationFor(uid);
    final attended = viewModel.attendedIds.contains(uid);
    final rowState = HostLiveRosterRowDisplayState.resolve(
      participation: participation,
      attended: attended,
      usesRequestApproval: usesRequestApproval,
    );
    final CatchRosterAction action;
    if (rowState.showAttendanceToggle) {
      action = CatchRosterButtonAction(
        buttonKey: HostEventActionKeys.attendeeCheckInButton(uid),
        label: rowState.attendanceButtonLabel,
        primary: rowState.attendanceButtonPrimary,
        onPressed: attendanceActionPending
            ? null
            : () => actions.toggleAttendance(uid),
        disabled: attendanceActionPending,
      );
    } else if (rowState.showWaitlistOfferAction) {
      action = _waitlistOfferAction(
        uid,
        participation,
        offerActionPending: offerActionPending,
      );
    } else {
      action = _profileAction(uid);
    }
    return CatchRosterRow(
      person: _nameFor(uid),
      imageUrl: _photoFor(uid),
      meta: rowState.meta,
      signal: rowState.signal,
      tone: rowState.tone,
      action: action,
    );
  }

  CatchRosterRow _reportRow(String uid) {
    final participation = viewModel.participationFor(uid);
    final attended = viewModel.attendedIds.contains(uid);
    final rowState = HostReportRosterRowDisplayState.resolve(
      participation: participation,
      attended: attended,
      priceInPaise: viewModel.event.priceInPaise,
      currencyCode: viewModel.event.currency,
    );
    return CatchRosterRow(
      person: _nameFor(uid),
      imageUrl: _photoFor(uid),
      meta: rowState.meta,
      signal: rowState.signal,
      tone: rowState.tone,
      action: CatchRosterTextAction(rowState.payment),
    );
  }

  /// Shared waitlist action — a settled offer reads as an outcome [CatchBadge],
  /// otherwise an "Offer" button (disabled while a send is in flight).
  CatchRosterAction _waitlistOfferAction(
    String uid,
    EventParticipation? participation, {
    required bool offerActionPending,
  }) {
    final offerStatus = participation?.waitlistOfferStatus;
    if (offerStatus == EventWaitlistOfferStatus.active ||
        offerStatus == EventWaitlistOfferStatus.accepted) {
      final accepted = offerStatus == EventWaitlistOfferStatus.accepted;
      return CatchRosterBadgeAction(
        label: accepted ? 'Accepted' : 'Offered',
        tone: accepted ? CatchBadgeTone.success : CatchBadgeTone.brand,
      );
    }
    return CatchRosterButtonAction(
      label: 'Offer',
      onPressed: offerActionPending
          ? null
          : () => actions.createWaitlistOffer(uid),
      disabled: offerActionPending,
    );
  }

  CatchRosterAction _profileAction(String uid) {
    return CatchRosterButtonAction(
      label: 'Profile',
      onPressed: () => actions.openProfile(uid),
    );
  }

  String _nameFor(String uid) => profiles[uid]?.$1 ?? 'Runner';

  String? _photoFor(String uid) => profiles[uid]?.$2;
}

Object? _mutationError(MutationState<dynamic> mutation) {
  if (!mutation.hasError) return null;
  return (mutation as MutationError).error;
}

class HostRosterSearchBar extends StatelessWidget {
  const HostRosterSearchBar({
    super.key,
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final String value;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return CatchSection.contained(
      padding: const EdgeInsets.symmetric(horizontal: CatchSpacing.s3),
      child: CatchField.input(
        key: ValueKey('hostRosterSearch-$label'),
        title: label,
        showLabel: false,
        initialValue: value,
        placeholder: label,
        size: CatchFieldSize.compact,
        textInputAction: TextInputAction.search,
        prefixIcon: Icon(CatchIcons.searchRounded),
        showClearButton: true,
        onChanged: onChanged,
      ),
    );
  }
}

class HostRosterFilterHeader extends StatelessWidget {
  const HostRosterFilterHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final String? title;
  final String? subtitle;
  final List<HostRosterFilterSpec> filters;
  final HostRosterFilter selectedFilter;
  final ValueChanged<HostRosterFilter> onFilterChanged;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Text(title!, style: CatchTextStyles.sectionTitle(context)),
          if (subtitle != null) ...[
            gapH4,
            Text(
              subtitle!,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
          gapH12,
        ],
        CatchRosterTiles(
          items: [
            for (final spec in filters)
              CatchRosterTile(
                id: spec.filter.name,
                value: '${spec.value}',
                label: spec.label,
                tone: spec.tone,
              ),
          ],
          selected: selectedFilter.name,
          onSelect: (id) => onFilterChanged(HostRosterFilter.values.byName(id)),
        ),
      ],
    );
  }
}

class HostWaitlistBulkOfferAction extends StatelessWidget {
  const HostWaitlistBulkOfferAction({
    super.key,
    required this.count,
    required this.candidateCount,
    required this.isPending,
    required this.onOffer,
  });

  final int count;
  final int candidateCount;
  final bool isPending;
  final VoidCallback onOffer;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final remainingAfterSend = candidateCount - count;
    final detail = remainingAfterSend > 0
        ? '$remainingAfterSend still waiting after this offer'
        : 'Next $count ${_personNoun(count)} on the waitlist';
    return CatchSurface(
      padding: CatchInsets.compactControlContent,
      borderColor: t.warning.withValues(alpha: CatchOpacity.warningFill),
      radius: CatchRadius.md,
      backgroundColor: t.warning.withValues(alpha: CatchOpacity.warningFill),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final summary = Row(
            children: [
              Icon(
                CatchIcons.groupAddOutlined,
                color: t.warning,
                size: CatchIcon.md,
              ),
              gapW10,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Waitlist movement',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.labelL(context, color: t.ink),
                    ),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: CatchTextStyles.supporting(context, color: t.ink2),
                    ),
                  ],
                ),
              ),
            ],
          );
          final button = CatchButton(
            label: 'Offer next $count',
            size: CatchButtonSize.sm,
            variant: CatchButtonVariant.secondary,
            icon: Icon(CatchIcons.sendRounded),
            isLoading: isPending,
            onPressed: isPending ? null : onOffer,
          );
          if (constraints.maxWidth < 340) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                summary,
                gapH10,
                Align(alignment: Alignment.centerLeft, child: button),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: summary),
              gapW10,
              button,
            ],
          );
        },
      ),
    );
  }
}

String _personNoun(int count) => count == 1 ? 'person' : 'people';

class HostExportReportButton extends StatelessWidget {
  const HostExportReportButton({
    super.key,
    required this.label,
    required this.onExport,
    required this.isExporting,
    this.primary = false,
  });

  final String label;
  final Future<void> Function() onExport;
  final bool isExporting;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    return CatchButton(
      label: label,
      onPressed: isExporting ? null : () => onExport(),
      isLoading: isExporting,
      variant: primary
          ? CatchButtonVariant.primary
          : CatchButtonVariant.secondary,
      icon: Icon(
        CatchIcons.platformShare(platform: Theme.of(context).platform),
      ),
      fullWidth: true,
    );
  }
}
