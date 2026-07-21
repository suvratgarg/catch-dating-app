import 'dart:async';

import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_action_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_metric_strip.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_check_in_qr_payload.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/events.dart'
    show attendeeProfilesProvider;
import 'package:catch_dating_app/events/shared/attendance_sheet_view_model.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_action_keys.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_booking_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/catch_roster_board.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

class HostEventParticipantsPanel extends ConsumerStatefulWidget {
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
  ConsumerState<HostEventParticipantsPanel> createState() =>
      _HostEventParticipantsPanelState();
}

class _HostEventParticipantsPanelState
    extends ConsumerState<HostEventParticipantsPanel> {
  List<String> _stableProfileIds = const [];

  List<String> _profileIdsFor(List<String> nextProfileIds) {
    if (!listEquals(_stableProfileIds, nextProfileIds)) {
      _stableProfileIds = List.unmodifiable(nextProfileIds);
    }
    return _stableProfileIds;
  }

  @override
  Widget build(BuildContext context) {
    final eventId = widget.eventId;
    final attendanceAsync = ref.watch(
      attendanceSheetViewModelProvider(eventId),
    );

    return CatchAsyncValueView<AttendanceSheetViewModel?>(
      value: attendanceAsync,
      onRetry: () {
        ref.invalidate(watchEventProvider(eventId));
        ref.invalidate(watchEventParticipationsForEventProvider(eventId));
        ref.invalidate(attendanceSheetViewModelProvider(eventId));
      },
      loadingBuilder: (_) => const CatchSkeletonRows(
        count: 4,
        titleWidth: CatchLayout.skeletonTextSectionWidth,
      ),
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
              title:
                  context.l10n.hostsHostEventAttendancePanelTitleEventNotFound,
              message: context
                  .l10n
                  .hostsHostEventAttendancePanelMessageThisEventIsNo,
            ),
          );
        }
        final participantIds = viewModel.profileIds;
        final bulkOfferMutation = ref.watch(
          HostEventBookingController.createWaitlistOfferMutation(
            HostEventBookingController.bulkWaitlistOfferMutationKey(
              eventId: viewModel.event.id,
            ),
          ),
        );
        final opsExportMutation = ref.watch(
          HostEventManageController.shareOpsReportMutation,
        );
        final revenueExportMutation = ref.watch(
          HostEventManageController.shareRevenueReportMutation,
        );
        final bulkOfferError = bulkOfferMutation.hasError
            ? (bulkOfferMutation as MutationError).error
            : null;
        final opsReportError = opsExportMutation.hasError
            ? (opsExportMutation as MutationError).error
            : null;
        final revenueReportError = revenueExportMutation.hasError
            ? (revenueExportMutation as MutationError).error
            : null;
        final mutationState = HostParticipantsMutationDisplayState.resolve(
          markAttendancePendingIds: _pendingMutationIds(
            participantIds,
            (uid) => HostEventBookingController.markAttendanceMutation(
              HostEventBookingController.markAttendanceMutationKey(
                eventId: viewModel.event.id,
                userId: uid,
              ),
            ),
          ),
          approveJoinRequestPendingIds: _pendingMutationIds(
            participantIds,
            (uid) => HostEventBookingController.approveJoinRequestMutation(
              HostEventBookingController.approveJoinRequestMutationKey(
                eventId: viewModel.event.id,
                userId: uid,
              ),
            ),
          ),
          declineJoinRequestPendingIds: _pendingMutationIds(
            participantIds,
            (uid) => HostEventBookingController.declineJoinRequestMutation(
              HostEventBookingController.declineJoinRequestMutationKey(
                eventId: viewModel.event.id,
                userId: uid,
              ),
            ),
          ),
          createWaitlistOfferPendingIds: _pendingMutationIds(
            participantIds,
            (uid) => HostEventBookingController.createWaitlistOfferMutation(
              HostEventBookingController.waitlistOfferMutationKey(
                eventId: viewModel.event.id,
                userId: uid,
              ),
            ),
          ),
          bulkWaitlistOfferPending: bulkOfferMutation.isPending,
          opsReportPending: opsExportMutation.isPending,
          revenueReportPending: revenueExportMutation.isPending,
          markAttendanceError: _firstMutationErrorForIds(
            participantIds,
            (uid) => HostEventBookingController.markAttendanceMutation(
              HostEventBookingController.markAttendanceMutationKey(
                eventId: viewModel.event.id,
                userId: uid,
              ),
            ),
          ),
          approveJoinRequestError: _firstMutationErrorForIds(
            participantIds,
            (uid) => HostEventBookingController.approveJoinRequestMutation(
              HostEventBookingController.approveJoinRequestMutationKey(
                eventId: viewModel.event.id,
                userId: uid,
              ),
            ),
          ),
          declineJoinRequestError: _firstMutationErrorForIds(
            participantIds,
            (uid) => HostEventBookingController.declineJoinRequestMutation(
              HostEventBookingController.declineJoinRequestMutationKey(
                eventId: viewModel.event.id,
                userId: uid,
              ),
            ),
          ),
          createWaitlistOfferError:
              bulkOfferError ??
              _firstMutationErrorForIds(
                participantIds,
                (uid) => HostEventBookingController.createWaitlistOfferMutation(
                  HostEventBookingController.waitlistOfferMutationKey(
                    eventId: viewModel.event.id,
                    userId: uid,
                  ),
                ),
              ),
          opsReportError: opsReportError,
          revenueReportError: revenueReportError,
        );

        final profileIds = _profileIdsFor(viewModel.profileIds);
        final profilesAsync = profileIds.isEmpty
            ? null
            : ref.watch(attendeeProfilesProvider(profileIds));
        final profileLookupState = HostParticipantProfilesLookupState.resolve(
          profileIds: profileIds,
          profilesState: profilesAsync == null
              ? null
              : _catchAsyncState(profilesAsync),
        );

        return HostEventParticipantsList(
          viewModel: viewModel,
          mode: widget.mode,
          scrollable: widget.scrollable,
          showSummaryHeader: widget.showSummaryHeader,
          initialSearchQuery: widget.initialSearchQuery,
          profileLookupState: profileLookupState,
          mutationState: mutationState,
          actions: HostParticipantLifecycleActions(
            openProfile: (uid) => _openPublicProfile(context, uid),
            approveJoinRequest: (uid) => _approveJoinRequest(viewModel, uid),
            declineJoinRequest: (uid) => _declineJoinRequest(viewModel, uid),
            toggleAttendance: (uid) => _toggleAttendance(viewModel, uid),
            createWaitlistOffers: (userIds) =>
                _createWaitlistOffers(viewModel, userIds),
            shareOpsReport: () =>
                _shareOpsReport(viewModel, profileLookupState),
            shareRevenueReport: () =>
                _shareRevenueReport(viewModel, profileLookupState),
          ),
          onRetryProfiles: () => ref.invalidate(
            attendeeProfilesProvider(profileLookupState.profileIds),
          ),
        );
      },
    );
  }

  void _toggleAttendance(AttendanceSheetViewModel viewModel, String uid) {
    final mutation = HostEventBookingController.markAttendanceMutation(
      HostEventBookingController.markAttendanceMutationKey(
        eventId: viewModel.event.id,
        userId: uid,
      ),
    );
    if (ref.read(mutation).isPending) return;
    mutation.run(
      ref,
      (tx) async => tx
          .get(hostEventBookingControllerProvider.notifier)
          .markAttendance(eventId: viewModel.event.id, userId: uid),
    );
  }

  void _approveJoinRequest(AttendanceSheetViewModel viewModel, String uid) {
    final mutation = HostEventBookingController.approveJoinRequestMutation(
      HostEventBookingController.approveJoinRequestMutationKey(
        eventId: viewModel.event.id,
        userId: uid,
      ),
    );
    if (ref.read(mutation).isPending) return;
    mutation.run(
      ref,
      (tx) async => tx
          .get(hostEventBookingControllerProvider.notifier)
          .approveJoinRequest(eventId: viewModel.event.id, userId: uid),
    );
  }

  void _declineJoinRequest(AttendanceSheetViewModel viewModel, String uid) {
    final mutation = HostEventBookingController.declineJoinRequestMutation(
      HostEventBookingController.declineJoinRequestMutationKey(
        eventId: viewModel.event.id,
        userId: uid,
      ),
    );
    if (ref.read(mutation).isPending) return;
    mutation.run(
      ref,
      (tx) async => tx
          .get(hostEventBookingControllerProvider.notifier)
          .declineJoinRequest(eventId: viewModel.event.id, userId: uid),
    );
  }

  void _createWaitlistOffers(
    AttendanceSheetViewModel viewModel,
    List<String> userIds,
  ) {
    if (userIds.isEmpty) return;
    final mutation = HostEventBookingController.createWaitlistOfferMutation(
      _waitlistOfferMutationKey(viewModel.event.id, userIds),
    );
    if (ref.read(mutation).isPending) return;
    mutation.run(
      ref,
      (tx) async => tx
          .get(hostEventBookingControllerProvider.notifier)
          .createWaitlistOffers(eventId: viewModel.event.id, userIds: userIds),
    );
  }

  Future<void> _shareRevenueReport(
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
      if (!mounted) return;
      showCatchSnackBar(
        context,
        context.l10n.hostsHostEventAttendancePanelVisiblecopyRevenueCsvReady,
      );
    } catch (error, stackTrace) {
      ref
          .read(errorLoggerProvider)
          .logError(
            error,
            stackTrace,
            reason: context
                .l10n
                .hostsHostEventAttendancePanelVisiblecopySharerevenuereportFailed,
          );
    }
  }

  Future<void> _shareOpsReport(
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
      if (!mounted) return;
      showCatchSnackBar(
        context,
        context.l10n.hostsHostEventAttendancePanelVisiblecopyOpsCsvReady,
      );
    } catch (error, stackTrace) {
      ref
          .read(errorLoggerProvider)
          .logError(
            error,
            stackTrace,
            reason: context
                .l10n
                .hostsHostEventAttendancePanelVisiblecopyShareopsreportFailed,
          );
    }
  }

  Set<String> _pendingMutationIds(
    Iterable<String> ids,
    Mutation<void> Function(String uid) mutationFor,
  ) {
    return {
      for (final uid in ids)
        if (ref.watch(mutationFor(uid)).isPending) uid,
    };
  }

  Object? _firstMutationErrorForIds(
    Iterable<String> ids,
    Mutation<void> Function(String uid) mutationFor,
  ) {
    for (final uid in ids) {
      final error = _mutationError(ref.watch(mutationFor(uid)));
      if (error != null) return error;
    }
    return null;
  }
}

CatchAsyncState<T> _catchAsyncState<T>(AsyncValue<T> value) {
  return catchAsyncStateFromAsyncValue(value);
}

Object _waitlistOfferMutationKey(String eventId, List<String> userIds) {
  return userIds.length == 1
      ? HostEventBookingController.waitlistOfferMutationKey(
          eventId: eventId,
          userId: userIds.single,
        )
      : HostEventBookingController.bulkWaitlistOfferMutationKey(
          eventId: eventId,
        );
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
      HostParticipantProfilesLookupStatus.loading => const CatchSkeletonRows(
        count: 4,
        titleWidth: CatchLayout.skeletonTextSectionWidth,
      ),
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
    late final Widget section;
    switch (mode) {
      case HostEventParticipantsMode.setup:
        final rosterState = HostRosterDisplayState.setup(
          l10n: context.l10n,
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
        section = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) ...[
              HostRosterFilterHeader(
                title: context
                    .l10n
                    .hostsHostEventAttendancePanelTitleParticipation,
                subtitle: usesRequestApproval
                    ? context
                          .l10n
                          .hostsHostEventAttendancePanelSubtitleReviewProfilesAndApprove
                    : context
                          .l10n
                          .hostsHostEventAttendancePanelSubtitleReviewBookingStatusBefore,
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
                onOffer: () =>
                    actions.createWaitlistOffers(rosterState.bulkOfferIds),
              ),
              gapH12,
            ],
            HostRosterSearchBar(
              value: searchQuery,
              label:
                  context.l10n.hostsHostEventAttendancePanelLabelSearchPeople,
              onChanged: onSearchChanged,
            ),
            gapH14,
            CatchRosterTable(
              columns: [
                context.l10n.hostsHostEventAttendancePanelVisiblecopyGuest,
                context.l10n.hostsHostEventAttendancePanelVisiblecopySignal,
                context.l10n.hostsHostEventAttendancePanelVisiblecopyHostAction,
              ],
              showEmpty: rosterState.rowIds.isEmpty,
              emptyTitle: rosterState.emptyTitle,
              emptyMessage: rosterState.emptyMessage,
              rows: [
                for (final uid in rosterState.rowIds)
                  _setupRow(
                    context,
                    uid,
                    usesRequestApproval: usesRequestApproval,
                    requestActionPending: mutationState.isRequestActionPending(
                      uid,
                    ),
                    offerActionPending: mutationState.isWaitlistOfferPending(
                      uid,
                    ),
                  ),
              ],
            ),
          ],
        );
      case HostEventParticipantsMode.live:
        final rosterState = HostRosterDisplayState.live(
          l10n: context.l10n,
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
        section = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CatchSection.fieldRows(
              first: true,
              children: [
                CatchField.control(
                  title:
                      context.l10n.hostsHostEventAttendancePanelTitleCheckInQr,
                  body: context.l10n.hostsHostEventAttendancePanelBodyCheckInQr,
                  icon: CatchIcons.qrCode2Rounded,
                  control: HostEventCheckInQrPanel(event: viewModel.event),
                ),
              ],
            ),
            gapH12,
            HostRosterFilterHeader(
              title: showHeader
                  ? context.l10n.hostsHostEventAttendancePanelTitleCheckInBoard
                  : null,
              subtitle: showHeader
                  ? context
                        .l10n
                        .hostsHostEventAttendancePanelSubtitleUseTheStatusTiles
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
                onOffer: () =>
                    actions.createWaitlistOffers(rosterState.bulkOfferIds),
              ),
              gapH12,
            ],
            HostRosterSearchBar(
              value: searchQuery,
              label:
                  context.l10n.hostsHostEventAttendancePanelLabelSearchRoster,
              onChanged: onSearchChanged,
            ),
            gapH14,
            CatchRosterTable(
              columns: [
                context.l10n.hostsHostEventAttendancePanelVisiblecopyGuest,
                context.l10n.hostsHostEventAttendancePanelVisiblecopyStatus,
                context.l10n.hostsHostEventAttendancePanelVisiblecopyHostAction,
              ],
              showEmpty: rosterState.rowIds.isEmpty,
              emptyTitle: rosterState.emptyTitle,
              emptyMessage: rosterState.emptyMessage,
              rows: [
                for (final uid in rosterState.rowIds)
                  _liveRow(
                    context,
                    uid,
                    usesRequestApproval: usesRequestApproval,
                    attendanceActionPending: mutationState
                        .isAttendanceActionPending(uid),
                    offerActionPending: mutationState.isWaitlistOfferPending(
                      uid,
                    ),
                  ),
              ],
            ),
          ],
        );
      case HostEventParticipantsMode.report:
        final reportSummary = HostReportSummaryDisplayState.resolve(
          totalCount: viewModel.totalCount,
          checkedInCount: viewModel.checkedInCount,
          waitlistCount: viewModel.waitlistCount,
          priceInPaise: viewModel.event.priceInPaise,
          currencyCode: viewModel.event.currency,
        );
        final rosterState = HostRosterDisplayState.report(
          l10n: context.l10n,
          attendeeIds: viewModel.attendeeIds,
          attendedIds: viewModel.attendedIds,
          waitlistedIds: viewModel.waitlistedIds,
          totalCount: viewModel.totalCount,
          waitlistCount: viewModel.waitlistCount,
          profiles: profiles,
          searchQuery: searchQuery,
          selectedFilter: selectedFilter,
        );
        final hasParticipants =
            viewModel.totalCount > 0 || viewModel.waitlistCount > 0;
        section = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (showHeader) ...[
              HostRosterFilterHeader(
                title:
                    context.l10n.hostsHostEventAttendancePanelTitleEventReport,
                subtitle: context
                    .l10n
                    .hostsHostEventAttendancePanelSubtitleAttendancePayoutAndExport,
                filters: rosterState.filters,
                selectedFilter: rosterState.activeFilter,
                onFilterChanged: onFilterChanged,
                trailing: hasParticipants
                    ? CatchActionMenu<_HostReportExportAction>(
                        tooltip: context
                            .l10n
                            .hostsHostEventAttendancePanelLabelExport,
                        icon: CatchIcons.iosShareRounded,
                        items: [
                          CatchActionMenuItem(
                            value: _HostReportExportAction.ops,
                            label: context
                                .l10n
                                .hostsHostEventAttendancePanelLabelOpsCsv,
                            icon: CatchIcons.tableRowsOutlined,
                            enabled:
                                !mutationState.opsReportExportPending &&
                                !mutationState.revenueReportExportPending,
                          ),
                          CatchActionMenuItem(
                            value: _HostReportExportAction.revenue,
                            label: context
                                .l10n
                                .hostsHostEventAttendancePanelLabelRevenueCsv,
                            icon: CatchIcons.paymentsOutlined,
                            enabled:
                                !mutationState.opsReportExportPending &&
                                !mutationState.revenueReportExportPending,
                          ),
                        ],
                        onSelected: (action) {
                          switch (action) {
                            case _HostReportExportAction.ops:
                              unawaited(actions.shareOpsReport());
                            case _HostReportExportAction.revenue:
                              unawaited(actions.shareRevenueReport());
                          }
                        },
                      )
                    : null,
              ),
              gapH12,
            ],
            if (!hasParticipants)
              CatchEmptyState(
                icon: CatchIcons.groupsOutlined,
                title: rosterState.emptyTitle,
                message: rosterState.emptyMessage,
                layout: CatchEmptyStateLayout.inline,
                surface: true,
                padding: CatchInsets.content,
              )
            else ...[
              HostRosterSearchBar(
                value: searchQuery,
                label:
                    context.l10n.hostsHostEventAttendancePanelLabelSearchRoster,
                onChanged: onSearchChanged,
              ),
              gapH14,
              CatchRosterTable(
                columns: [
                  context.l10n.hostsHostEventAttendancePanelVisiblecopyName,
                  context
                      .l10n
                      .hostsHostEventAttendancePanelVisiblecopyAttendance,
                  context.l10n.hostsHostEventAttendancePanelVisiblecopyPayment,
                ],
                showEmpty: rosterState.rowIds.isEmpty,
                emptyTitle: rosterState.emptyTitle,
                emptyMessage: rosterState.emptyMessage,
                rows: [
                  for (final uid in rosterState.rowIds)
                    _reportRow(context, uid),
                ],
              ),
              gapH12,
              CatchField.content(
                title:
                    context.l10n.hostsHostEventAttendancePanelTitleEventReport,
                body: reportSummary.summary(context.l10n),
                icon: CatchIcons.receiptLongOutlined,
              ),
              if (mutationState.reportExportError != null) ...[
                gapH12,
                CatchErrorBanner.fromError(
                  mutationState.reportExportError!,
                  context: AppErrorContext.event,
                ),
              ],
            ],
          ],
        );
    }

    return ListView(
      shrinkWrap: !scrollable,
      primary: scrollable ? null : false,
      physics: scrollable
          ? const AlwaysScrollableScrollPhysics()
          : const NeverScrollableScrollPhysics(),
      padding: scrollable ? CatchInsets.scrollEnd : EdgeInsets.zero,
      children: [section],
    );
  }

  CatchRosterRow _setupRow(
    BuildContext context,
    String uid, {
    required bool usesRequestApproval,
    required bool requestActionPending,
    required bool offerActionPending,
  }) {
    final participation = viewModel.participationFor(uid);
    final rowState = HostSetupRosterRowDisplayState.resolve(
      l10n: context.l10n,
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
        context,
        uid,
        participation,
        offerActionPending: offerActionPending,
      );
    } else {
      action = _profileAction(context, uid);
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
    BuildContext context,
    String uid, {
    required bool usesRequestApproval,
    required bool attendanceActionPending,
    required bool offerActionPending,
  }) {
    final participation = viewModel.participationFor(uid);
    final attended = viewModel.attendedIds.contains(uid);
    final rowState = HostLiveRosterRowDisplayState.resolve(
      l10n: context.l10n,
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
        context,
        uid,
        participation,
        offerActionPending: offerActionPending,
      );
    } else {
      action = _profileAction(context, uid);
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

  CatchRosterRow _reportRow(BuildContext context, String uid) {
    final participation = viewModel.participationFor(uid);
    final attended = viewModel.attendedIds.contains(uid);
    final rowState = HostReportRosterRowDisplayState.resolve(
      l10n: context.l10n,
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

  String _nameFor(String uid) => profiles[uid]?.$1 ?? 'Runner';

  String? _photoFor(String uid) => profiles[uid]?.$2;

  /// Shared waitlist action — a settled offer reads as an outcome [CatchBadge],
  /// otherwise an "Offer" button (disabled while a send is in flight).
  CatchRosterAction _waitlistOfferAction(
    BuildContext context,
    String uid,
    EventParticipation? participation, {
    required bool offerActionPending,
  }) {
    final offerStatus = participation?.waitlistOfferStatus;
    if (offerStatus == EventWaitlistOfferStatus.active ||
        offerStatus == EventWaitlistOfferStatus.accepted) {
      final accepted = offerStatus == EventWaitlistOfferStatus.accepted;
      return CatchRosterBadgeAction(
        label: accepted
            ? context.l10n.hostsHostEventAttendancePanelLabelAccepted
            : context.l10n.hostsHostEventAttendancePanelLabelOffered,
        tone: accepted ? CatchBadgeTone.success : CatchBadgeTone.brand,
      );
    }
    return CatchRosterButtonAction(
      label: context.l10n.hostsHostEventAttendancePanelLabelOffer,
      onPressed: offerActionPending
          ? null
          : () => actions.createWaitlistOffer(uid),
      disabled: offerActionPending,
    );
  }

  CatchRosterAction _profileAction(BuildContext context, String uid) {
    return CatchRosterButtonAction(
      label: context.l10n.hostsHostEventAttendancePanelLabelProfile,
      onPressed: () => actions.openProfile(uid),
    );
  }
}

enum _HostReportExportAction { ops, revenue }

Object? _mutationError(MutationState<dynamic> mutation) {
  if (!mutation.hasError) return null;
  return (mutation as MutationError).error;
}

class HostEventCheckInQrPanel extends StatelessWidget {
  const HostEventCheckInQrPanel({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final payload = EventCheckInQrPayload(eventId: event.id).encode();
    return Align(
      alignment: Alignment.centerLeft,
      child: CatchSurface(
        radius: CatchRadius.sm,
        backgroundColor: CatchTokens.editorialWhite,
        borderWidth: 0,
        padding: CatchInsets.iconChipContent,
        child: QrImageView(
          data: payload,
          size: 168,
          padding: EdgeInsets.zero,
          backgroundColor: CatchTokens.editorialWhite,
        ),
      ),
    );
  }
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
    return CatchSearchField(
      key: ValueKey('hostRosterSearch-$label'),
      value: value,
      placeholder: label,
      semanticLabel: label,
      textInputAction: TextInputAction.search,
      onChanged: onChanged,
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
    this.trailing,
  });

  final String? title;
  final String? subtitle;
  final List<HostRosterFilterSpec> filters;
  final HostRosterFilter selectedFilter;
  final ValueChanged<HostRosterFilter> onFilterChanged;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final canFilter = filters.any((spec) => spec.value > 0);
    return CatchSection.plain(
      title: title,
      subtitle: subtitle,
      trailing: trailing,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchMetricStrip(
            items: [
              for (final spec in filters)
                CatchMetricStripItem(
                  value: context.l10n
                      .hostsHostEventAttendancePanelVisiblecopyValue(
                        value: spec.value,
                      ),
                  label: spec.label,
                ),
            ],
          ),
          if (canFilter) ...[
            gapH12,
            CatchOptionGroup<HostRosterFilter>(
              options: [
                for (final spec in filters)
                  CatchOption(value: spec.filter, label: spec.label),
              ],
              selected: selectedFilter,
              onChanged: onFilterChanged,
              variant: CatchOptionGroupVariant.mono,
              scrollable: true,
            ),
          ],
        ],
      ),
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
        ? context.l10n
              .hostsHostEventAttendancePanelVisiblecopyRemainingaftersendStillWaitingAfter(
                remainingAfterSend: remainingAfterSend,
              )
        : context.l10n
              .hostsHostEventAttendancePanelVisiblecopyNextCountPersonnounOn(
                count: count,
                personNoun: _personNoun(count),
              );
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
                      context
                          .l10n
                          .hostsHostEventAttendancePanelTextWaitlistMovement,
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
            label: context.l10n
                .hostsHostEventAttendancePanelLabelOfferNextCount(count: count),
            size: CatchButtonSize.sm,
            variant: CatchButtonVariant.secondary,
            icon: Icon(CatchIcons.sendRounded),
            isLoading: isPending,
            onPressed: isPending ? null : onOffer,
          );
          if (constraints.maxWidth <
              ComponentBreakpoints.hostWaitlistBulkOfferStackBreakpoint) {
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
