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
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/attendance_sheet_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_action_keys.dart';
import 'package:catch_dating_app/hosts/presentation/host_event_manage_controller.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/catch_roster_board.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
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
        return _ParticipantsList(
          viewModel: viewModel,
          mode: mode,
          scrollable: scrollable,
          showSummaryHeader: showSummaryHeader,
          initialSearchQuery: initialSearchQuery,
        );
      },
    );
  }
}

class _ParticipantsList extends ConsumerStatefulWidget {
  const _ParticipantsList({
    required this.viewModel,
    required this.mode,
    required this.scrollable,
    required this.showSummaryHeader,
    required this.initialSearchQuery,
  });

  final AttendanceSheetViewModel viewModel;
  final HostEventParticipantsMode mode;
  final bool scrollable;
  final bool showSummaryHeader;
  final String initialSearchQuery;

  @override
  ConsumerState<_ParticipantsList> createState() => _ParticipantsListState();
}

enum _RosterFilter {
  all,
  booked,
  waitlist,
  slots,
  requests,
  due,
  checkedIn,
  attended,
  noShow,
}

class _RosterFilterSpec {
  const _RosterFilterSpec({
    required this.filter,
    required this.label,
    required this.value,
    required this.tone,
  });

  final _RosterFilter filter;
  final String label;
  final int value;
  final CatchBadgeTone tone;
}

class _ParticipantsListState extends ConsumerState<_ParticipantsList> {
  late var _searchQuery = widget.initialSearchQuery;
  var _selectedFilter = _RosterFilter.all;

  @override
  void didUpdateWidget(covariant _ParticipantsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _selectedFilter = _RosterFilter.all;
    }
    if (oldWidget.initialSearchQuery != widget.initialSearchQuery) {
      _searchQuery = widget.initialSearchQuery;
    }
  }

  @override
  Widget build(BuildContext context) {
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
    final errorMutation =
        [
          markAttendanceMutation,
          approveMutation,
          declineMutation,
          offerMutation,
        ].firstWhere(
          (mutation) => mutation.hasError,
          orElse: () => markAttendanceMutation,
        );
    final usesRequestApproval = widget
        .viewModel
        .event
        .effectiveEventPolicy
        .admissionPolicy
        .manualApprovalRequired;

    final profileIds = widget.viewModel.profileIds;
    final profilesAsync = profileIds.isEmpty
        ? null
        : ref.watch(attendeeProfilesProvider(profileIds));
    Widget buildBoard(Map<String, (String, String?)> profiles) {
      return _ParticipationLifecycleBoard(
        viewModel: widget.viewModel,
        mode: widget.mode,
        profiles: profiles,
        scrollable: widget.scrollable,
        showHeader: widget.showSummaryHeader,
        usesRequestApproval: usesRequestApproval,
        searchQuery: _searchQuery,
        selectedFilter: _selectedFilter,
        onSearchChanged: (value) => setState(() => _searchQuery = value),
        onFilterChanged: (value) => setState(() => _selectedFilter = value),
      );
    }

    final Widget rows = profilesAsync == null
        ? buildBoard(const <String, (String, String?)>{})
        : CatchAsyncValueView<Map<String, (String, String?)>>(
            value: profilesAsync,
            loadingBuilder: (_) => const HostRosterSkeleton(),
            errorBuilder: (_, error, _) => Padding(
              padding: CatchInsets.content,
              child: CatchInlineErrorState.fromError(
                error,
                context: AppErrorContext.event,
                onRetry: () =>
                    ref.invalidate(attendeeProfilesProvider(profileIds)),
              ),
            ),
            builder: (context, profiles) => buildBoard(profiles),
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (errorMutation.hasError)
          CatchErrorBanner(message: mutationErrorMessage(errorMutation)),
        if (widget.scrollable) Expanded(child: rows) else rows,
      ],
    );
  }
}

class _ParticipationLifecycleBoard extends ConsumerWidget {
  const _ParticipationLifecycleBoard({
    required this.viewModel,
    required this.mode,
    required this.profiles,
    required this.scrollable,
    required this.showHeader,
    required this.usesRequestApproval,
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
  final String searchQuery;
  final _RosterFilter selectedFilter;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<_RosterFilter> onFilterChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final children = switch (mode) {
      HostEventParticipantsMode.setup => _setupChildren(context, ref),
      HostEventParticipantsMode.live => _liveChildren(context, ref),
      HostEventParticipantsMode.report => _reportChildren(context, ref),
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

  List<Widget> _setupChildren(BuildContext context, WidgetRef ref) {
    final requestActionPending =
        ref
            .watch(EventBookingController.approveJoinRequestMutation)
            .isPending ||
        ref.watch(EventBookingController.declineJoinRequestMutation).isPending;
    final offerActionPending = ref
        .watch(EventBookingController.createWaitlistOfferMutation)
        .isPending;
    final requestIds = usesRequestApproval
        ? viewModel.waitlistedIds
        : const <String>[];
    final bookedIds = viewModel.attendeeIds;
    final waitlistedIds = usesRequestApproval
        ? const <String>[]
        : viewModel.waitlistedIds;
    final allIds = [...requestIds, ...bookedIds, ...waitlistedIds];
    final remainingSlots =
        (viewModel.event.capacityLimit - viewModel.totalCount)
            .clamp(0, viewModel.event.capacityLimit)
            .toInt();
    final offerableWaitlistIds = _offerableWaitlistIds(waitlistedIds);
    final bulkOfferCount = _bulkOfferCount(
      offerableWaitlistIds,
      remainingSlots,
    );
    final filters = [
      _RosterFilterSpec(
        filter: _RosterFilter.all,
        label: 'All',
        value: allIds.length,
        tone: CatchBadgeTone.solid,
      ),
      _RosterFilterSpec(
        filter: _RosterFilter.booked,
        label: 'Booked',
        value: bookedIds.length,
        tone: CatchBadgeTone.success,
      ),
      _RosterFilterSpec(
        filter: usesRequestApproval
            ? _RosterFilter.requests
            : _RosterFilter.waitlist,
        label: usesRequestApproval ? 'Requests' : 'Waitlist',
        value: viewModel.waitlistCount,
        tone: usesRequestApproval
            ? CatchBadgeTone.brand
            : CatchBadgeTone.warning,
      ),
      _RosterFilterSpec(
        filter: _RosterFilter.slots,
        label: 'Slots',
        value: remainingSlots,
        tone: CatchBadgeTone.neutral,
      ),
    ];
    final activeFilter = _effectiveFilter(selectedFilter, filters);
    final visibleIds = switch (activeFilter) {
      _RosterFilter.booked => bookedIds,
      _RosterFilter.waitlist => waitlistedIds,
      _RosterFilter.requests => requestIds,
      _RosterFilter.slots => const <String>[],
      _ => allIds,
    };
    final rowIds = _matchingIds(visibleIds);
    final hasSearch = searchQuery.trim().isNotEmpty;

    return [
      if (showHeader) ...[
        _RosterFilterHeader(
          title: 'Participation',
          subtitle: usesRequestApproval
              ? 'Review profiles and approve requests before launch.'
              : 'Review booking status before launch.',
          filters: filters,
          selectedFilter: activeFilter,
          onFilterChanged: onFilterChanged,
        ),
        gapH12,
      ],
      if (bulkOfferCount > 0) ...[
        _WaitlistBulkOfferAction(
          count: bulkOfferCount,
          candidateCount: offerableWaitlistIds.length,
          isPending: offerActionPending,
          onOffer: () => _createWaitlistOffers(
            ref,
            offerableWaitlistIds.take(bulkOfferCount).toList(growable: false),
          ),
        ),
        gapH12,
      ],
      _RosterSearchBar(
        value: searchQuery,
        label: 'Search people',
        onChanged: onSearchChanged,
      ),
      gapH14,
      CatchRosterTable(
        columns: const ['Guest', 'Signal', 'Host action'],
        showEmpty: rowIds.isEmpty,
        emptyTitle: hasSearch
            ? 'No matches'
            : activeFilter == _RosterFilter.slots
            ? 'Open slots are not people'
            : mode.emptyTitle,
        emptyMessage: hasSearch
            ? 'No people match this search.'
            : activeFilter == _RosterFilter.slots
            ? 'Slots show capacity left after booked people. New people appear here once they book or request access.'
            : mode.emptyMessage,
        rows: [
          for (final uid in rowIds)
            _setupRow(
              context,
              ref,
              uid,
              usesRequestApproval: usesRequestApproval,
              requestActionPending: requestActionPending,
              offerActionPending: offerActionPending,
            ),
        ],
      ),
    ];
  }

  List<Widget> _liveChildren(BuildContext context, WidgetRef ref) {
    final offerActionPending = ref
        .watch(EventBookingController.createWaitlistOfferMutation)
        .isPending;
    final checkedInBaseIds = viewModel.attendeeIds
        .where(viewModel.attendedIds.contains)
        .toList(growable: false);
    final needsCheckInBaseIds = viewModel.attendeeIds
        .where((uid) => !viewModel.attendedIds.contains(uid))
        .toList(growable: false);
    final waitlistedBaseIds = viewModel.waitlistedIds;
    final remainingSlots =
        (viewModel.event.capacityLimit - viewModel.totalCount)
            .clamp(0, viewModel.event.capacityLimit)
            .toInt();
    final offerableWaitlistIds = _offerableWaitlistIds(waitlistedBaseIds);
    final bulkOfferCount = _bulkOfferCount(
      offerableWaitlistIds,
      remainingSlots,
    );
    final allBaseIds = [
      ...needsCheckInBaseIds,
      ...checkedInBaseIds,
      ...waitlistedBaseIds,
    ];
    final filters = [
      _RosterFilterSpec(
        filter: _RosterFilter.all,
        label: 'All',
        value: allBaseIds.length,
        tone: CatchBadgeTone.solid,
      ),
      _RosterFilterSpec(
        filter: _RosterFilter.due,
        label: 'Due',
        value: needsCheckInBaseIds.length,
        tone: CatchBadgeTone.brand,
      ),
      _RosterFilterSpec(
        filter: _RosterFilter.checkedIn,
        label: 'In',
        value: checkedInBaseIds.length,
        tone: CatchBadgeTone.success,
      ),
      _RosterFilterSpec(
        filter: usesRequestApproval
            ? _RosterFilter.requests
            : _RosterFilter.waitlist,
        label: usesRequestApproval ? 'Requests' : 'Waitlist',
        value: waitlistedBaseIds.length,
        tone: CatchBadgeTone.warning,
      ),
    ];
    final activeFilter = _effectiveFilter(selectedFilter, filters);
    final visibleIds = switch (activeFilter) {
      _RosterFilter.due => needsCheckInBaseIds,
      _RosterFilter.checkedIn => checkedInBaseIds,
      _RosterFilter.waitlist || _RosterFilter.requests => waitlistedBaseIds,
      _ => allBaseIds,
    };
    final rowIds = _matchingIds(visibleIds);
    final hasRoster = viewModel.totalCount > 0;
    final hasSearch = searchQuery.trim().isNotEmpty;

    return [
      _RosterFilterHeader(
        title: showHeader ? 'Check-in board' : null,
        subtitle: showHeader
            ? 'Use the status tiles to focus the roster as people arrive.'
            : null,
        filters: filters,
        selectedFilter: activeFilter,
        onFilterChanged: onFilterChanged,
      ),
      gapH12,
      if (bulkOfferCount > 0) ...[
        _WaitlistBulkOfferAction(
          count: bulkOfferCount,
          candidateCount: offerableWaitlistIds.length,
          isPending: offerActionPending,
          onOffer: () => _createWaitlistOffers(
            ref,
            offerableWaitlistIds.take(bulkOfferCount).toList(growable: false),
          ),
        ),
        gapH12,
      ],
      _RosterSearchBar(
        value: searchQuery,
        label: 'Search roster',
        onChanged: onSearchChanged,
      ),
      gapH14,
      CatchRosterTable(
        columns: const ['Guest', 'Status', 'Host action'],
        showEmpty: rowIds.isEmpty,
        emptyTitle: hasSearch
            ? 'No matches'
            : _liveEmptyTitle(activeFilter, hasRoster),
        emptyMessage: hasSearch
            ? 'No live roster rows match this search.'
            : _liveEmptyMessage(activeFilter, hasRoster),
        rows: [
          for (final uid in rowIds)
            _liveRow(
              context,
              ref,
              uid,
              usesRequestApproval: usesRequestApproval,
              offerActionPending: offerActionPending,
            ),
        ],
      ),
    ];
  }

  List<Widget> _reportChildren(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final opsExportMutation = ref.watch(
      HostEventManageController.shareOpsReportMutation,
    );
    final revenueExportMutation = ref.watch(
      HostEventManageController.shareRevenueReportMutation,
    );
    final exportErrorMutation = [opsExportMutation, revenueExportMutation]
        .firstWhere(
          (mutation) => mutation.hasError,
          orElse: () => opsExportMutation,
        );
    final checkedInCount = viewModel.checkedInCount;
    final noShowCount = viewModel.totalCount - checkedInCount;
    final grossEstimate = viewModel.totalCount * viewModel.event.priceInPaise;
    final attendedBaseIds = viewModel.attendeeIds
        .where(viewModel.attendedIds.contains)
        .toList(growable: false);
    final noShowBaseIds = viewModel.attendeeIds
        .where((uid) => !viewModel.attendedIds.contains(uid))
        .toList(growable: false);
    final waitlistedBaseIds = viewModel.waitlistedIds;
    final allBaseIds = [
      ...attendedBaseIds,
      ...noShowBaseIds,
      ...waitlistedBaseIds,
    ];
    final filters = [
      _RosterFilterSpec(
        filter: _RosterFilter.all,
        label: 'All',
        value: allBaseIds.length,
        tone: CatchBadgeTone.solid,
      ),
      _RosterFilterSpec(
        filter: _RosterFilter.attended,
        label: 'Attended',
        value: checkedInCount,
        tone: CatchBadgeTone.success,
      ),
      _RosterFilterSpec(
        filter: _RosterFilter.noShow,
        label: 'No-show',
        value: noShowCount,
        tone: CatchBadgeTone.neutral,
      ),
      _RosterFilterSpec(
        filter: _RosterFilter.waitlist,
        label: 'Waitlist',
        value: viewModel.waitlistCount,
        tone: CatchBadgeTone.warning,
      ),
    ];
    final activeFilter = _effectiveFilter(selectedFilter, filters);
    final visibleIds = switch (activeFilter) {
      _RosterFilter.attended => attendedBaseIds,
      _RosterFilter.noShow => noShowBaseIds,
      _RosterFilter.waitlist => waitlistedBaseIds,
      _ => allBaseIds,
    };
    final rowIds = _matchingIds(visibleIds);
    final hasSearch = searchQuery.trim().isNotEmpty;

    return [
      if (showHeader) ...[
        _RosterFilterHeader(
          title: 'Event report',
          subtitle: 'Attendance, payout, and export-ready roster history.',
          filters: filters,
          selectedFilter: activeFilter,
          onFilterChanged: onFilterChanged,
        ),
        gapH12,
      ],
      _RosterSearchBar(
        value: searchQuery,
        label: 'Search roster',
        onChanged: onSearchChanged,
      ),
      gapH14,
      CatchRosterTable(
        columns: const ['Name', 'Attendance', 'Payment'],
        showEmpty: rowIds.isEmpty,
        emptyTitle: hasSearch ? 'No matches' : _reportEmptyTitle(activeFilter),
        emptyMessage: hasSearch
            ? 'No report rows match this search.'
            : _reportEmptyMessage(activeFilter),
        rows: [for (final uid in rowIds) _reportRow(uid)],
      ),
      gapH12,
      CatchSurface(
        padding: CatchInsets.compactControlContent,
        borderColor: t.line,
        radius: CatchRadius.md,
        backgroundColor: t.raised,
        child: Text(
          '${EventFormatters.priceInPaise(grossEstimate, currencyCode: viewModel.event.currency)} gross estimate · $checkedInCount attended · $noShowCount no-shows · ${viewModel.waitlistCount} waitlisted.',
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
      ),
      gapH12,
      if (exportErrorMutation.hasError) ...[
        CatchMutationErrorBanner(
          mutation: exportErrorMutation,
          errorContext: AppErrorContext.event,
        ),
        gapH12,
      ],
      Row(
        children: [
          Expanded(
            child: _ExportReportButton(
              label: 'Ops CSV',
              isExporting: opsExportMutation.isPending,
              onExport: () => _shareOpsReport(context, ref),
            ),
          ),
          gapW10,
          Expanded(
            child: _ExportReportButton(
              label: 'Revenue CSV',
              primary: true,
              isExporting: revenueExportMutation.isPending,
              onExport: () => _shareRevenueReport(context, ref),
            ),
          ),
        ],
      ),
    ];
  }

  CatchRosterRow _setupRow(
    BuildContext context,
    WidgetRef ref,
    String uid, {
    required bool usesRequestApproval,
    required bool requestActionPending,
    required bool offerActionPending,
  }) {
    final participation = viewModel.participationFor(uid);
    final signal = _setupSignal(participation, usesRequestApproval);
    final isRequest =
        usesRequestApproval &&
        participation?.status == EventParticipationStatus.waitlisted;
    final CatchRosterAction action;
    if (isRequest) {
      action = CatchRosterDecideAction(
        onProfile: () => _openPublicProfile(context, uid),
        onApprove: requestActionPending
            ? null
            : () => _approveJoinRequest(ref, uid),
        onDecline: requestActionPending
            ? null
            : () => _declineJoinRequest(ref, uid),
      );
    } else if (participation?.status == EventParticipationStatus.waitlisted) {
      action = _waitlistOfferAction(
        ref,
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
      meta: _setupMeta(participation, usesRequestApproval),
      signal: signal.label,
      tone: signal.tone,
      action: action,
    );
  }

  CatchRosterRow _liveRow(
    BuildContext context,
    WidgetRef ref,
    String uid, {
    required bool usesRequestApproval,
    required bool offerActionPending,
  }) {
    final participation = viewModel.participationFor(uid);
    final attended = viewModel.attendedIds.contains(uid);
    final status = participation?.status;
    final signal = _liveSignal(participation, attended, usesRequestApproval);
    final meta = attended
        ? participation?.attendedAt == null
              ? 'Checked in'
              : EventFormatters.time(participation!.attendedAt!)
        : _reportMeta(participation);
    final canToggle =
        status == EventParticipationStatus.signedUp ||
        status == EventParticipationStatus.attended;
    final CatchRosterAction action;
    if (canToggle) {
      action = CatchRosterButtonAction(
        buttonKey: HostEventActionKeys.attendeeCheckInButton(uid),
        label: attended ? 'Undo' : 'Check in',
        primary: !attended,
        onPressed: () => _toggleAttendance(ref, uid),
      );
    } else if (status == EventParticipationStatus.waitlisted &&
        !usesRequestApproval) {
      action = _waitlistOfferAction(
        ref,
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
      meta: meta,
      signal: signal.label,
      tone: signal.tone,
      action: action,
    );
  }

  CatchRosterRow _reportRow(String uid) {
    final participation = viewModel.participationFor(uid);
    final attended = viewModel.attendedIds.contains(uid);
    final status = participation?.status;
    final attendance = _reportAttendance(participation, attended);
    final payment = status == EventParticipationStatus.waitlisted
        ? '-'
        : viewModel.event.priceInPaise == 0
        ? 'Free'
        : EventFormatters.priceInPaise(
            viewModel.event.priceInPaise,
            currencyCode: viewModel.event.currency,
          );
    return CatchRosterRow(
      person: _nameFor(uid),
      imageUrl: _photoFor(uid),
      meta: _reportMeta(participation),
      signal: attendance.label,
      tone: attendance.tone,
      action: CatchRosterTextAction(payment),
    );
  }

  /// Shared waitlist action — a settled offer reads as an outcome [CatchBadge],
  /// otherwise an "Offer" button (disabled while a send is in flight).
  CatchRosterAction _waitlistOfferAction(
    WidgetRef ref,
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
          : () => _createWaitlistOffer(ref, uid),
      disabled: offerActionPending,
    );
  }

  CatchRosterAction _profileAction(BuildContext context, String uid) {
    return CatchRosterButtonAction(
      label: 'Profile',
      onPressed: () => _openPublicProfile(context, uid),
    );
  }

  String _nameFor(String uid) => profiles[uid]?.$1 ?? 'Runner';

  String? _photoFor(String uid) => profiles[uid]?.$2;

  List<String> _offerableWaitlistIds(List<String> ids) {
    return [
      for (final uid in ids)
        if (_canCreateWaitlistOffer(viewModel.participationFor(uid))) uid,
    ];
  }

  List<String> _matchingIds(List<String> ids) {
    final query = searchQuery.trim().toLowerCase();
    if (query.isEmpty) return ids;
    return [
      for (final uid in ids)
        if (_nameFor(uid).toLowerCase().contains(query) ||
            uid.toLowerCase().contains(query))
          uid,
    ];
  }

  void _toggleAttendance(WidgetRef ref, String uid) {
    final mutation = ref.read(EventBookingController.markAttendanceMutation);
    if (mutation.isPending) return;
    EventBookingController.markAttendanceMutation.run(
      ref,
      (tx) async => tx
          .get(eventBookingControllerProvider.notifier)
          .markAttendance(eventId: viewModel.event.id, userId: uid),
    );
  }

  void _approveJoinRequest(WidgetRef ref, String uid) {
    final mutation = ref.read(
      EventBookingController.approveJoinRequestMutation,
    );
    if (mutation.isPending) return;
    EventBookingController.approveJoinRequestMutation.run(
      ref,
      (tx) async => tx
          .get(eventBookingControllerProvider.notifier)
          .approveJoinRequest(eventId: viewModel.event.id, userId: uid),
    );
  }

  void _declineJoinRequest(WidgetRef ref, String uid) {
    final mutation = ref.read(
      EventBookingController.declineJoinRequestMutation,
    );
    if (mutation.isPending) return;
    EventBookingController.declineJoinRequestMutation.run(
      ref,
      (tx) async => tx
          .get(eventBookingControllerProvider.notifier)
          .declineJoinRequest(eventId: viewModel.event.id, userId: uid),
    );
  }

  void _createWaitlistOffer(WidgetRef ref, String uid) {
    _createWaitlistOffers(ref, [uid]);
  }

  void _createWaitlistOffers(WidgetRef ref, List<String> userIds) {
    if (userIds.isEmpty) return;
    final mutation = ref.read(
      EventBookingController.createWaitlistOfferMutation,
    );
    if (mutation.isPending) return;
    EventBookingController.createWaitlistOfferMutation.run(
      ref,
      (tx) async => tx
          .get(eventBookingControllerProvider.notifier)
          .createWaitlistOffers(eventId: viewModel.event.id, userIds: userIds),
    );
  }

  Future<void> _shareRevenueReport(BuildContext context, WidgetRef ref) async {
    final origin = _shareOrigin(context);
    try {
      await HostEventManageController.shareRevenueReportMutation.run(
        ref,
        (tx) => tx
            .get(hostEventManageActionsProvider)
            .shareRevenueReport(
              viewModel: viewModel,
              profiles: profiles,
              origin: origin,
            ),
      );
      if (!context.mounted) return;
      showCatchSnackBar(context, 'Revenue CSV ready.');
    } catch (_) {}
  }

  Future<void> _shareOpsReport(BuildContext context, WidgetRef ref) async {
    final origin = _shareOrigin(context);
    try {
      await HostEventManageController.shareOpsReportMutation.run(
        ref,
        (tx) => tx
            .get(hostEventManageActionsProvider)
            .shareOpsReport(
              viewModel: viewModel,
              profiles: profiles,
              origin: origin,
            ),
      );
      if (!context.mounted) return;
      showCatchSnackBar(context, 'Ops CSV ready.');
    } catch (_) {}
  }

  Rect? _shareOrigin(BuildContext context) {
    final box = context.findRenderObject() as RenderBox?;
    return box == null ? null : box.localToGlobal(Offset.zero) & box.size;
  }
}

_RosterFilter _effectiveFilter(
  _RosterFilter selected,
  List<_RosterFilterSpec> filters,
) {
  for (final filter in filters) {
    if (filter.filter == selected) return selected;
  }
  return _RosterFilter.all;
}

String _liveEmptyTitle(_RosterFilter filter, bool hasRoster) {
  return switch (filter) {
    _RosterFilter.due when hasRoster => 'Everyone visible is checked in',
    _RosterFilter.checkedIn => 'No checked-in people yet',
    _RosterFilter.waitlist || _RosterFilter.requests => 'No waitlisted people',
    _ => 'Roster is empty',
  };
}

String _liveEmptyMessage(_RosterFilter filter, bool hasRoster) {
  return switch (filter) {
    _RosterFilter.due when hasRoster =>
      'Switch to In to review arrivals or All to see the full roster.',
    _RosterFilter.checkedIn =>
      'Checked-in people will appear here during the event.',
    _RosterFilter.waitlist ||
    _RosterFilter.requests => 'Waitlisted people will appear here for context.',
    _ => 'Signed-up participants will appear here when they book.',
  };
}

String _reportEmptyTitle(_RosterFilter filter) {
  return switch (filter) {
    _RosterFilter.attended => 'No attended people yet',
    _RosterFilter.noShow => 'No no-shows yet',
    _RosterFilter.waitlist => 'No waitlisted people',
    _ => 'No participants yet',
  };
}

String _reportEmptyMessage(_RosterFilter filter) {
  return switch (filter) {
    _RosterFilter.attended =>
      'Checked-in people will appear here after the event.',
    _RosterFilter.noShow =>
      'Booked people who did not check in will appear here.',
    _RosterFilter.waitlist =>
      'Waitlist history will appear here when people queue for this event.',
    _ =>
      'Attendance and waitlist history will appear here once people sign up.',
  };
}

class _RosterSearchBar extends StatelessWidget {
  const _RosterSearchBar({
    required this.value,
    required this.label,
    required this.onChanged,
  });

  final String value;
  final String label;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return CatchTextField(
      key: ValueKey('hostRosterSearch-$label'),
      label: label,
      showLabel: false,
      initialValue: value,
      hintText: label,
      size: CatchTextFieldSize.compact,
      shape: CatchTextFieldShape.pill,
      textInputAction: TextInputAction.search,
      prefixIcon: Icon(CatchIcons.searchRounded),
      showClearButton: true,
      onChanged: onChanged,
    );
  }
}

class _RosterFilterHeader extends StatelessWidget {
  const _RosterFilterHeader({
    required this.title,
    required this.subtitle,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
  });

  final String? title;
  final String? subtitle;
  final List<_RosterFilterSpec> filters;
  final _RosterFilter selectedFilter;
  final ValueChanged<_RosterFilter> onFilterChanged;

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
          onSelect: (id) => onFilterChanged(_RosterFilter.values.byName(id)),
        ),
      ],
    );
  }
}

class _WaitlistBulkOfferAction extends StatelessWidget {
  const _WaitlistBulkOfferAction({
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

int _bulkOfferCount(List<String> offerableIds, int remainingSlots) {
  if (offerableIds.isEmpty || remainingSlots <= 0) return 0;
  return offerableIds.length < remainingSlots
      ? offerableIds.length
      : remainingSlots;
}

bool _canCreateWaitlistOffer(EventParticipation? participation) {
  if (participation?.status != EventParticipationStatus.waitlisted) {
    return false;
  }
  final offerStatus = participation?.waitlistOfferStatus;
  return offerStatus != EventWaitlistOfferStatus.active &&
      offerStatus != EventWaitlistOfferStatus.accepted;
}

String _personNoun(int count) => count == 1 ? 'person' : 'people';

({String label, CatchBadgeTone tone}) _liveSignal(
  EventParticipation? participation,
  bool attended,
  bool usesRequestApproval,
) {
  final status = participation?.status;
  return switch (status) {
    EventParticipationStatus.waitlisted
        when participation?.waitlistOfferStatus ==
            EventWaitlistOfferStatus.active =>
      (label: 'Offered', tone: CatchBadgeTone.brand),
    EventParticipationStatus.waitlisted
        when participation?.waitlistOfferStatus ==
            EventWaitlistOfferStatus.accepted =>
      (label: 'Accepted', tone: CatchBadgeTone.success),
    EventParticipationStatus.waitlisted when usesRequestApproval => (
      label: 'Request',
      tone: CatchBadgeTone.brand,
    ),
    EventParticipationStatus.waitlisted => (
      label: 'Wait',
      tone: CatchBadgeTone.warning,
    ),
    _ when attended => (label: 'In', tone: CatchBadgeTone.success),
    _ => (label: 'Due', tone: CatchBadgeTone.neutral),
  };
}

({String label, CatchBadgeTone tone}) _reportAttendance(
  EventParticipation? participation,
  bool attended,
) {
  final status = participation?.status;
  final offerStatus = participation?.waitlistOfferStatus;
  return switch (status) {
    EventParticipationStatus.waitlisted
        when offerStatus == EventWaitlistOfferStatus.active =>
      (label: 'Offered', tone: CatchBadgeTone.brand),
    EventParticipationStatus.waitlisted
        when offerStatus == EventWaitlistOfferStatus.accepted =>
      (label: 'Accepted', tone: CatchBadgeTone.success),
    EventParticipationStatus.waitlisted
        when offerStatus == EventWaitlistOfferStatus.expired =>
      (label: 'Expired', tone: CatchBadgeTone.neutral),
    EventParticipationStatus.waitlisted => (
      label: 'Wait',
      tone: CatchBadgeTone.warning,
    ),
    _ when attended => (label: 'Attended', tone: CatchBadgeTone.success),
    _ => (label: 'No-show', tone: CatchBadgeTone.neutral),
  };
}

({String label, CatchBadgeTone tone}) _setupSignal(
  EventParticipation? participation,
  bool usesRequestApproval,
) {
  final offerStatus = participation?.waitlistOfferStatus;
  if (participation?.status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.active) {
    return (label: 'Offered', tone: CatchBadgeTone.brand);
  }
  if (participation?.status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.accepted) {
    return (label: 'Accepted', tone: CatchBadgeTone.success);
  }
  return switch (participation?.status) {
    EventParticipationStatus.attended || EventParticipationStatus.signedUp => (
      label: 'Booked',
      tone: CatchBadgeTone.success,
    ),
    EventParticipationStatus.waitlisted when usesRequestApproval => (
      label: 'Request',
      tone: CatchBadgeTone.brand,
    ),
    EventParticipationStatus.waitlisted => (
      label: 'Wait',
      tone: CatchBadgeTone.warning,
    ),
    _ => (label: 'New', tone: CatchBadgeTone.neutral),
  };
}

String _setupMeta(EventParticipation? participation, bool usesRequestApproval) {
  final offerStatus = participation?.waitlistOfferStatus;
  if (participation?.status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.active) {
    return 'Offer sent';
  }
  if (participation?.status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.accepted) {
    return 'Accepted offer';
  }
  if (participation?.status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.expired) {
    return 'Offer expired';
  }
  return switch (participation?.status) {
    EventParticipationStatus.attended ||
    EventParticipationStatus.signedUp => 'Approved',
    EventParticipationStatus.waitlisted when usesRequestApproval =>
      'View profile',
    EventParticipationStatus.waitlisted => 'Waitlisted',
    _ => 'Profile ready',
  };
}

String _reportMeta(EventParticipation? participation) {
  final status = participation?.status;
  final offerStatus = participation?.waitlistOfferStatus;
  if (status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.active) {
    return 'Offer sent';
  }
  if (status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.accepted) {
    return 'Accepted offer';
  }
  if (status == EventParticipationStatus.waitlisted &&
      offerStatus == EventWaitlistOfferStatus.expired) {
    return 'Offer expired';
  }
  return switch (status) {
    EventParticipationStatus.waitlisted => 'Waitlisted',
    EventParticipationStatus.attended ||
    EventParticipationStatus.signedUp => 'Booked',
    EventParticipationStatus.cancelled => 'Cancelled',
    EventParticipationStatus.deleted => 'Deleted',
    null => 'Participant',
  };
}

class _ExportReportButton extends StatelessWidget {
  const _ExportReportButton({
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

void _openPublicProfile(BuildContext context, String uid) {
  final router = GoRouter.maybeOf(context);
  if (router == null) return;
  router.pushNamed(
    Routes.publicProfileScreen.name,
    pathParameters: {'uid': uid},
  );
}

extension on HostEventParticipantsMode {
  String get emptyTitle {
    return switch (this) {
      HostEventParticipantsMode.live => 'No attendees yet',
      HostEventParticipantsMode.setup ||
      HostEventParticipantsMode.report => 'No participants yet',
    };
  }

  String get emptyMessage {
    return switch (this) {
      HostEventParticipantsMode.live =>
        'No one has signed up for this event yet.',
      HostEventParticipantsMode.setup =>
        'Booked and waitlisted people will appear here.',
      HostEventParticipantsMode.report =>
        'Attendance and waitlist history will appear here once people sign up.',
    };
  }
}
