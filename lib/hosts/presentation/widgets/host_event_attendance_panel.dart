import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_field.dart';
import 'package:catch_dating_app/core/widgets/error_banner.dart';
import 'package:catch_dating_app/core/widgets/mutation_error_util.dart';
import 'package:catch_dating_app/core/widgets/person_avatar.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/presentation/attendance_sheet_view_model.dart';
import 'package:catch_dating_app/events/presentation/event_booking_controller.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/who_is_going.dart';
import 'package:catch_dating_app/hosts/domain/host_report_export.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
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
  });

  final String eventId;
  final bool scrollable;
  final bool showSummaryHeader;

  @override
  Widget build(BuildContext context) {
    return HostEventParticipantsPanel(
      eventId: eventId,
      mode: HostEventParticipantsMode.live,
      scrollable: scrollable,
      showSummaryHeader: showSummaryHeader,
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
  });

  final String eventId;
  final HostEventParticipantsMode mode;
  final bool scrollable;
  final bool showSummaryHeader;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceAsync = ref.watch(
      attendanceSheetViewModelProvider(eventId),
    );

    return attendanceAsync.when(
      loading: () => const Padding(
        padding: EdgeInsets.symmetric(vertical: CatchSpacing.s6),
        child: Center(child: CatchLoadingIndicator()),
      ),
      error: (e, _) => Padding(
        padding: const EdgeInsets.all(CatchSpacing.s4),
        child: CatchInlineErrorState.fromError(
          e,
          context: AppErrorContext.event,
          onRetry: () {
            ref.invalidate(watchEventProvider(eventId));
            ref.invalidate(watchEventParticipationsForEventProvider(eventId));
            ref.invalidate(attendanceSheetViewModelProvider(eventId));
          },
        ),
      ),
      data: (viewModel) {
        if (viewModel == null) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: CatchSpacing.s5),
            child: CatchEmptyState(
              icon: Icons.event_busy_outlined,
              title: 'Event not found',
              message: 'This event is no longer available.',
              surface: false,
              iconStyle: CatchEmptyStateIconStyle.plain,
            ),
          );
        }
        return _ParticipantsList(
          viewModel: viewModel,
          mode: mode,
          scrollable: scrollable,
          showSummaryHeader: showSummaryHeader,
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
  });

  final AttendanceSheetViewModel viewModel;
  final HostEventParticipantsMode mode;
  final bool scrollable;
  final bool showSummaryHeader;

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
  var _searchQuery = '';
  var _selectedFilter = _RosterFilter.all;

  @override
  void didUpdateWidget(covariant _ParticipantsList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mode != widget.mode) {
      _selectedFilter = _RosterFilter.all;
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
    final errorMutation =
        [markAttendanceMutation, approveMutation, declineMutation].firstWhere(
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
    final Map<String, (String, String?)> profiles =
        profilesAsync?.asData?.value ?? const <String, (String, String?)>{};
    final Widget rows = switch (profilesAsync) {
      null => _ParticipationLifecycleBoard(
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
      ),
      AsyncValue(isLoading: true) => const Padding(
        padding: EdgeInsets.symmetric(vertical: CatchSpacing.s6),
        child: Center(child: CatchLoadingIndicator()),
      ),
      AsyncValue(hasError: true) => Padding(
        padding: const EdgeInsets.all(CatchSpacing.s4),
        child: CatchInlineErrorState.fromError(
          profilesAsync.error!,
          context: AppErrorContext.event,
          onRetry: () => ref.invalidate(attendeeProfilesProvider(profileIds)),
        ),
      ),
      _ => _ParticipationLifecycleBoard(
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
      ),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (errorMutation.hasError)
          ErrorBanner(message: mutationErrorMessage(errorMutation)),
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
      _RosterSearchBar(
        value: searchQuery,
        label: 'Search people',
        onChanged: onSearchChanged,
      ),
      gapH14,
      _RosterTableShell(
        columns: const ['Guest', 'Signal', 'Host action'],
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
            _SetupReviewRow(
              uid: uid,
              name: _nameFor(uid),
              photoUrl: _photoFor(uid),
              participation: viewModel.participationFor(uid),
              usesRequestApproval: usesRequestApproval,
              requestActionPending: requestActionPending,
              onApprove: () => _approveJoinRequest(ref, uid),
              onDecline: () => _declineJoinRequest(ref, uid),
            ),
        ],
      ),
    ];
  }

  List<Widget> _liveChildren(BuildContext context, WidgetRef ref) {
    final checkedInBaseIds = viewModel.attendeeIds
        .where(viewModel.attendedIds.contains)
        .toList(growable: false);
    final needsCheckInBaseIds = viewModel.attendeeIds
        .where((uid) => !viewModel.attendedIds.contains(uid))
        .toList(growable: false);
    final waitlistedBaseIds = viewModel.waitlistedIds;
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
      _RosterSearchBar(
        value: searchQuery,
        label: 'Search roster',
        onChanged: onSearchChanged,
      ),
      gapH14,
      _RosterTableShell(
        columns: const ['Guest', 'Status', 'Host action'],
        emptyTitle: hasSearch
            ? 'No matches'
            : _liveEmptyTitle(activeFilter, hasRoster),
        emptyMessage: hasSearch
            ? 'No live roster rows match this search.'
            : _liveEmptyMessage(activeFilter, hasRoster),
        rows: [
          for (final uid in rowIds)
            _LiveRosterRow(
              uid: uid,
              name: _nameFor(uid),
              photoUrl: _photoFor(uid),
              participation: viewModel.participationFor(uid),
              attended: viewModel.attendedIds.contains(uid),
              usesRequestApproval: usesRequestApproval,
              onToggle: () => _toggleAttendance(ref, uid),
            ),
        ],
      ),
    ];
  }

  List<Widget> _reportChildren(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
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
      _RosterTableShell(
        columns: const ['Name', 'Attendance', 'Payment'],
        emptyTitle: hasSearch ? 'No matches' : _reportEmptyTitle(activeFilter),
        emptyMessage: hasSearch
            ? 'No report rows match this search.'
            : _reportEmptyMessage(activeFilter),
        rows: [
          for (final uid in rowIds)
            _ReportRow(
              name: _nameFor(uid),
              participation: viewModel.participationFor(uid),
              attended: viewModel.attendedIds.contains(uid),
              priceInPaise: viewModel.event.priceInPaise,
              currencyCode: viewModel.event.currency,
            ),
        ],
      ),
      gapH12,
      CatchSurface(
        padding: const EdgeInsets.symmetric(
          horizontal: CatchSpacing.s3,
          vertical: CatchSpacing.s2,
        ),
        borderColor: t.line,
        radius: CatchRadius.md,
        backgroundColor: t.raised,
        child: Text(
          '${EventFormatters.priceInPaise(grossEstimate, currencyCode: viewModel.event.currency)} gross estimate · $checkedInCount attended · $noShowCount no-shows · ${viewModel.waitlistCount} waitlisted.',
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
      ),
      gapH12,
      Row(
        children: [
          Expanded(
            child: _ExportReportButton(
              label: 'Ops CSV',
              onExport: () => _shareOpsReport(context, ref),
            ),
          ),
          gapW10,
          Expanded(
            child: _ExportReportButton(
              label: 'Revenue CSV',
              primary: true,
              onExport: () => _shareRevenueReport(context, ref),
            ),
          ),
        ],
      ),
    ];
  }

  String _nameFor(String uid) => profiles[uid]?.$1 ?? 'Runner';

  String? _photoFor(String uid) => profiles[uid]?.$2;

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

  Future<void> _shareRevenueReport(BuildContext context, WidgetRef ref) async {
    final origin = _shareOrigin(context);
    final reportData = await _loadExportData(ref);
    final export = buildHostRevenueReportExport(
      event: viewModel.event,
      participations: reportData.participations,
      namesByUid: reportData.namesByUid,
    );
    await _shareExport(ref: ref, export: export, origin: origin);
  }

  Future<void> _shareOpsReport(BuildContext context, WidgetRef ref) async {
    final origin = _shareOrigin(context);
    final reportData = await _loadExportData(ref);
    final export = buildHostOpsReportExport(
      event: viewModel.event,
      participations: reportData.participations,
      namesByUid: reportData.namesByUid,
    );
    await _shareExport(ref: ref, export: export, origin: origin);
  }

  Future<
    ({List<EventParticipation> participations, Map<String, String> namesByUid})
  >
  _loadExportData(WidgetRef ref) async {
    final participations = await ref
        .read(eventParticipationRepositoryProvider)
        .fetchHostReportParticipationsForEvent(eventId: viewModel.event.id);
    final profileIds = _uniqueOrdered([
      ...participations.map((participation) => participation.uid),
      ...profiles.keys,
    ]);
    final exportProfiles = await ref
        .read(publicProfileRepositoryProvider)
        .fetchPublicProfiles(profileIds);
    final namesByUid = <String, String>{
      for (final entry in profiles.entries) entry.key: entry.value.$1,
      for (final profile in exportProfiles) profile.uid: profile.name,
    };
    return (participations: participations, namesByUid: namesByUid);
  }

  Future<void> _shareExport({
    required WidgetRef ref,
    required HostReportExport export,
    required Rect? origin,
  }) async {
    await ref
        .read(externalShareControllerProvider)
        .shareCsvFile(
          csv: export.csv,
          fileName: export.fileName,
          subject: export.subject,
          text: export.subject,
          origin: origin,
        );
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

List<String> _uniqueOrdered(Iterable<String> ids) {
  final seen = <String>{};
  return [
    for (final id in ids)
      if (seen.add(id)) id,
  ];
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
      prefixIcon: const Icon(Icons.search_rounded),
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
          Text(title!, style: CatchTextStyles.titleM(context)),
          if (subtitle != null) ...[
            gapH4,
            Text(
              subtitle!,
              style: CatchTextStyles.supporting(context, color: t.ink2),
            ),
          ],
          gapH12,
        ],
        Row(
          children: [
            for (final indexed in filters.indexed) ...[
              if (indexed.$1 > 0) gapW6,
              Expanded(
                child: _RosterFilterTile(
                  spec: indexed.$2,
                  selected: indexed.$2.filter == selectedFilter,
                  onTap: () => onFilterChanged(indexed.$2.filter),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _RosterFilterTile extends StatelessWidget {
  const _RosterFilterTile({
    required this.spec,
    required this.selected,
    required this.onTap,
  });

  final _RosterFilterSpec spec;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final foreground = selected ? t.surface : _filterForeground(spec.tone, t);
    return Semantics(
      button: true,
      selected: selected,
      label: '${spec.label}: ${spec.value}',
      child: Material(
        color: selected
            ? t.ink
            : _filterBackground(spec.tone, t).withValues(alpha: 0.42),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(CatchRadius.md),
          side: BorderSide(
            color: selected
                ? Colors.transparent
                : _filterForeground(spec.tone, t).withValues(alpha: 0.20),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 56),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: CatchSpacing.s2,
                vertical: CatchSpacing.s2,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${spec.value}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.sectionTitle(
                      context,
                      color: foreground,
                    ),
                  ),
                  gapH2,
                  Text(
                    spec.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.labelL(
                      context,
                      color: selected
                          ? t.surface.withValues(alpha: 0.78)
                          : t.ink2,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

Color _filterBackground(CatchBadgeTone tone, CatchTokens t) {
  return switch (tone) {
    CatchBadgeTone.success => t.success.withValues(alpha: 0.10),
    CatchBadgeTone.warning => t.gold.withValues(alpha: 0.14),
    CatchBadgeTone.brand => t.primary.withValues(alpha: 0.10),
    CatchBadgeTone.danger => t.danger.withValues(alpha: 0.08),
    CatchBadgeTone.solid => t.surface,
    CatchBadgeTone.live => t.primarySoft.withValues(alpha: 0.36),
    CatchBadgeTone.neutral => t.raised,
  };
}

Color _filterForeground(CatchBadgeTone tone, CatchTokens t) {
  return switch (tone) {
    CatchBadgeTone.success => t.success,
    CatchBadgeTone.warning => t.gold,
    CatchBadgeTone.brand || CatchBadgeTone.live => t.primary,
    CatchBadgeTone.danger => t.danger,
    CatchBadgeTone.solid => t.ink,
    CatchBadgeTone.neutral => t.ink2,
  };
}

class _RosterTableShell extends StatelessWidget {
  const _RosterTableShell({
    required this.columns,
    required this.rows,
    required this.emptyTitle,
    required this.emptyMessage,
  });

  final List<String> columns;
  final List<Widget> rows;
  final String emptyTitle;
  final String emptyMessage;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      borderColor: t.line,
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s3,
              CatchSpacing.s3,
              CatchSpacing.s3,
              CatchSpacing.s2,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Text(
                    columns[0],
                    style: CatchTextStyles.labelS(context, color: t.ink3),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    columns[1],
                    style: CatchTextStyles.labelS(context, color: t.ink3),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      columns[2],
                      style: CatchTextStyles.labelS(context, color: t.ink3),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _RosterDivider(),
          if (rows.isEmpty)
            Padding(
              padding: const EdgeInsets.all(CatchSpacing.s4),
              child: _TableEmptyState(title: emptyTitle, message: emptyMessage),
            )
          else
            for (var i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i < rows.length - 1) const _RosterDivider(),
            ],
        ],
      ),
    );
  }
}

class _TableEmptyState extends StatelessWidget {
  const _TableEmptyState({required this.title, required this.message});

  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.group_outlined, color: t.ink3, size: 22),
        gapW10,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: CatchTextStyles.labelM(context)),
              gapH4,
              Text(
                message,
                style: CatchTextStyles.supporting(context, color: t.ink2),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SetupReviewRow extends StatelessWidget {
  const _SetupReviewRow({
    required this.uid,
    required this.name,
    required this.photoUrl,
    required this.participation,
    required this.usesRequestApproval,
    required this.requestActionPending,
    required this.onApprove,
    required this.onDecline,
  });

  final String uid;
  final String name;
  final String? photoUrl;
  final EventParticipation? participation;
  final bool usesRequestApproval;
  final bool requestActionPending;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final isRequest =
        usesRequestApproval &&
        participation?.status == EventParticipationStatus.waitlisted;
    final signal = _setupSignal(participation, usesRequestApproval);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.s2,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _CompactPersonIdentity(
              name: name,
              photoUrl: photoUrl,
              meta: _setupMeta(participation, usesRequestApproval),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerLeft,
              child: CatchBadge(label: signal.label, tone: signal.tone),
            ),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: isRequest
                  ? _DecisionControls(
                      uid: uid,
                      isPending: requestActionPending,
                      onApprove: onApprove,
                      onDecline: onDecline,
                    )
                  : _ProfileButton(uid: uid),
            ),
          ),
        ],
      ),
    );
  }
}

({String label, CatchBadgeTone tone}) _setupSignal(
  EventParticipation? participation,
  bool usesRequestApproval,
) {
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
  return switch (participation?.status) {
    EventParticipationStatus.attended ||
    EventParticipationStatus.signedUp => 'Approved',
    EventParticipationStatus.waitlisted when usesRequestApproval =>
      'View profile',
    EventParticipationStatus.waitlisted => 'Waitlisted',
    _ => 'Profile ready',
  };
}

class _DecisionControls extends StatelessWidget {
  const _DecisionControls({
    required this.uid,
    required this.isPending,
    required this.onApprove,
    required this.onDecline,
  });

  final String uid;
  final bool isPending;
  final VoidCallback onApprove;
  final VoidCallback onDecline;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: 'Open profile',
          child: IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            color: t.ink2,
            onPressed: () => _openPublicProfile(context, uid),
            icon: const Icon(Icons.person_search_outlined),
          ),
        ),
        Tooltip(
          message: 'Approve request',
          child: IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            color: t.success,
            onPressed: isPending ? null : onApprove,
            icon: const Icon(Icons.check_circle_outline_rounded),
          ),
        ),
        Tooltip(
          message: 'Decline request',
          child: IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            color: t.danger,
            onPressed: isPending ? null : onDecline,
            icon: const Icon(Icons.cancel_outlined),
          ),
        ),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  const _ProfileButton({required this.uid});

  final String uid;

  @override
  Widget build(BuildContext context) {
    return CatchButton(
      label: 'Profile',
      size: CatchButtonSize.sm,
      variant: CatchButtonVariant.secondary,
      onPressed: () => _openPublicProfile(context, uid),
    );
  }
}

class _LiveRosterRow extends StatelessWidget {
  const _LiveRosterRow({
    required this.uid,
    required this.name,
    required this.photoUrl,
    required this.participation,
    required this.attended,
    required this.usesRequestApproval,
    required this.onToggle,
  });

  final String uid;
  final String name;
  final String? photoUrl;
  final EventParticipation? participation;
  final bool attended;
  final bool usesRequestApproval;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final status = participation?.status;
    final signal = switch (status) {
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
    final meta = attended
        ? participation?.attendedAt == null
              ? 'Checked in'
              : EventFormatters.time(participation!.attendedAt!)
        : _reportMeta(status);
    final canToggle =
        status == EventParticipationStatus.signedUp ||
        status == EventParticipationStatus.attended;

    return CatchSurface(
      borderWidth: 0,
      radius: CatchRadius.sm,
      backgroundColor: Colors.transparent,
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.s2,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _CompactPersonIdentity(
              name: name,
              photoUrl: photoUrl,
              meta: meta,
            ),
          ),
          Expanded(
            flex: 3,
            child: CatchBadge(label: signal.label, tone: signal.tone),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: canToggle
                  ? CatchButton(
                      label: attended ? 'Undo' : 'Check in',
                      size: CatchButtonSize.sm,
                      variant: attended
                          ? CatchButtonVariant.secondary
                          : CatchButtonVariant.primary,
                      onPressed: onToggle,
                    )
                  : _ProfileButton(uid: uid),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.name,
    required this.participation,
    required this.attended,
    required this.priceInPaise,
    required this.currencyCode,
  });

  final String name;
  final EventParticipation? participation;
  final bool attended;
  final int priceInPaise;
  final String currencyCode;

  @override
  Widget build(BuildContext context) {
    final status = participation?.status;
    final attendance = switch (status) {
      EventParticipationStatus.waitlisted => (
        label: 'Wait',
        tone: CatchBadgeTone.warning,
      ),
      _ when attended => (label: 'Attended', tone: CatchBadgeTone.success),
      _ => (label: 'No-show', tone: CatchBadgeTone.neutral),
    };
    final payment = status == EventParticipationStatus.waitlisted
        ? '-'
        : priceInPaise == 0
        ? 'Free'
        : EventFormatters.priceInPaise(
            priceInPaise,
            currencyCode: currencyCode,
          );

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: CatchSpacing.s3,
        vertical: CatchSpacing.s2,
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: _NameMeta(name: name, meta: _reportMeta(status)),
          ),
          Expanded(
            flex: 3,
            child: CatchBadge(label: attendance.label, tone: attendance.tone),
          ),
          Expanded(
            flex: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(payment, style: CatchTextStyles.labelL(context)),
            ),
          ),
        ],
      ),
    );
  }
}

String _reportMeta(EventParticipationStatus? status) {
  return switch (status) {
    EventParticipationStatus.waitlisted => 'Waitlisted',
    EventParticipationStatus.attended ||
    EventParticipationStatus.signedUp => 'Booked',
    EventParticipationStatus.cancelled => 'Cancelled',
    EventParticipationStatus.deleted => 'Deleted',
    null => 'Participant',
  };
}

class _ExportReportButton extends StatefulWidget {
  const _ExportReportButton({
    required this.label,
    required this.onExport,
    this.primary = false,
  });

  final String label;
  final Future<void> Function() onExport;
  final bool primary;

  @override
  State<_ExportReportButton> createState() => _ExportReportButtonState();
}

class _ExportReportButtonState extends State<_ExportReportButton> {
  var _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return CatchButton(
      label: widget.label,
      onPressed: _isExporting ? null : _export,
      isLoading: _isExporting,
      variant: widget.primary
          ? CatchButtonVariant.primary
          : CatchButtonVariant.secondary,
      icon: const Icon(Icons.ios_share_rounded),
      fullWidth: true,
    );
  }

  Future<void> _export() async {
    setState(() => _isExporting = true);
    try {
      await widget.onExport();
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${widget.label} ready.')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not export ${widget.label}.')),
      );
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }
}

class _CompactPersonIdentity extends StatelessWidget {
  const _CompactPersonIdentity({
    required this.name,
    required this.photoUrl,
    required this.meta,
  });

  final String name;
  final String? photoUrl;
  final String meta;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PersonAvatar(size: 34, name: name, imageUrl: photoUrl),
        gapW10,
        Expanded(
          child: _NameMeta(name: name, meta: meta),
        ),
      ],
    );
  }
}

class _NameMeta extends StatelessWidget {
  const _NameMeta({required this.name, required this.meta});

  final String name;
  final String meta;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.sectionTitle(context),
        ),
        Text(
          meta,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.supporting(context, color: t.ink2),
        ),
      ],
    );
  }
}

class _RosterDivider extends StatelessWidget {
  const _RosterDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: CatchTokens.of(context).line,
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
