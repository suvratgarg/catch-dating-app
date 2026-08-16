import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/responsive/breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_contact_merge_review.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_row.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_campaign_composer.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

enum _HostCustomersHeaderAction {
  sortLastSeen,
  sortMostAttended,
  sortName,
  reviewDuplicates,
  export,
  whatsappReady,
  sources,
}

class HostCustomersScreen extends ConsumerStatefulWidget {
  const HostCustomersScreen({super.key, this.initialOrganizerId});

  final String? initialOrganizerId;

  @override
  ConsumerState<HostCustomersScreen> createState() =>
      _HostCustomersScreenState();
}

class _HostCustomersScreenState extends ConsumerState<HostCustomersScreen> {
  Timer? _searchDebounce;
  String? _search;
  HostCustomerFilter _filter = HostCustomerFilter.all;
  HostCustomerManualTag? _manualTag;
  HostCustomerSort _sort = HostCustomerSort.lastSeen;
  bool _exporting = false;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uidAsync = ref.watch(uidProvider);
    final uid = uidAsync.asData?.value;
    if (uidAsync.isLoading || uid == null && !uidAsync.hasError) {
      return HostLoadingScreen(title: context.l10n.hostNavigationCustomers);
    }
    if (uidAsync.hasError) {
      return CatchErrorScaffold.fromError(
        uidAsync.error!,
        context: AppErrorContext.auth,
        onRetry: () => ref.invalidate(uidProvider),
      );
    }
    if (uid == null) return const HostAuthRequiredScreen();

    final clubsAsync = ref.watch(hostOperableClubsProvider(uid));
    if (clubsAsync.isLoading) {
      return HostLoadingScreen(title: context.l10n.hostNavigationCustomers);
    }
    if (clubsAsync.hasError) {
      return CatchErrorScaffold.fromError(
        clubsAsync.error!,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(hostOperableClubsProvider(uid)),
      );
    }
    final clubs = clubsAsync.asData?.value ?? const <Club>[];
    if (clubs.isEmpty) return const HostCustomersNoOrganizer();
    final selectedOrganizerId = ref.watch(hostOrganizerSelectionProvider(uid));
    final selectedClub = resolveSelectedHostOrganizer(
      clubs,
      selectedOrganizerId: selectedOrganizerId,
      preferredOrganizerId: selectedOrganizerId == null
          ? widget.initialOrganizerId
          : null,
    )!;
    final summary = ref.watch(hostCrmSummaryProvider(selectedClub.id));
    final messagingSetup = ref.watch(
      hostMessagingSetupProvider(selectedClub.id),
    );
    final visibleFilters = hostCustomerFiltersForSmsReadiness(
      summary.asData?.value.smsReadiness,
    );
    final effectiveFilter = visibleFilters.contains(_filter)
        ? _filter
        : HostCustomerFilter.all;
    final request = HostCustomersDirectoryRequest(
      organizerId: selectedClub.id,
      search: _search,
      filter: _manualTag == null ? effectiveFilter : HostCustomerFilter.all,
      manualTagId: _manualTag?.tagId,
      sort: _sort,
    );
    final directory = ref.watch(
      hostCustomersDirectoryControllerProvider(request),
    );
    final activeSegment = hostAudienceSegmentForCustomerFilter(effectiveFilter);
    final campaignBridgeBlocker = hostCampaignBridgeBlocker(
      segment: activeSegment,
      smsReadiness: summary.asData?.value.smsReadiness,
      messagingSetup: messagingSetup.asData?.value,
    );
    final t = CatchTokens.of(context);
    final compactHeader = ScreenSize.fromWidth(
      MediaQuery.sizeOf(context).width,
    ).isCompact;

    return Scaffold(
      backgroundColor: t.bg,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: CatchScreenHeaderTitle.block(
                title: context.l10n.hostNavigationCustomers,
                actions: [
                  if (compactHeader)
                    CatchIconAction(
                      key: const ValueKey<String>(
                        'host-customers-add-customer',
                      ),
                      icon: CatchIcons.personAddAlt1Rounded,
                      tooltip: context.l10n.hostCustomersAdd,
                      onPressed: () => _addCustomer(selectedClub, request),
                    )
                  else
                    CatchButton(
                      key: const ValueKey<String>(
                        'host-customers-add-customer',
                      ),
                      label: context.l10n.hostCustomersAdd,
                      icon: Icon(
                        CatchIcons.personAddAlt1Rounded,
                        size: CatchIcon.sm,
                      ),
                      size: CatchButtonSize.sm,
                      onPressed: () => _addCustomer(selectedClub, request),
                    ),
                  CatchTopBarMenuAction<_HostCustomersHeaderAction>(
                    tooltip: context.l10n.hostsHostAudienceExport,
                    items: _hostCustomersHeaderActions(
                      context,
                      summary.asData?.value,
                      selectedSort: _sort,
                      exportEnabled: !_exporting && _manualTag == null,
                      exportSublabel: _manualTag == null
                          ? null
                          : context
                                .l10n
                                .hostCustomersManualTagExportUnavailable,
                    ),
                    onSelected: (action) {
                      final selectedSort = switch (action) {
                        _HostCustomersHeaderAction.sortLastSeen =>
                          HostCustomerSort.lastSeen,
                        _HostCustomersHeaderAction.sortMostAttended =>
                          HostCustomerSort.mostAttended,
                        _HostCustomersHeaderAction.sortName =>
                          HostCustomerSort.name,
                        _ => null,
                      };
                      if (selectedSort != null) {
                        setState(() => _sort = selectedSort);
                      }
                      if (action ==
                          _HostCustomersHeaderAction.reviewDuplicates) {
                        unawaited(_reviewDuplicates(selectedClub.id));
                      }
                      if (action == _HostCustomersHeaderAction.export) {
                        unawaited(
                          _exportCustomers(selectedClub, effectiveFilter),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: CatchInsets.pageHorizontal,
              sliver: SliverList.list(
                children: [
                  HostCustomersSummary(
                    summary: summary,
                    onRetry: () =>
                        ref.invalidate(hostCrmSummaryProvider(selectedClub.id)),
                  ),
                  gapH16,
                  LayoutBuilder(
                    builder: (context, constraints) => CatchSearchField(
                      key: const ValueKey('host-customers-search'),
                      mode: CatchSearchFieldMode.expanded,
                      maxWidth: constraints.maxWidth,
                      value: _search ?? '',
                      contract: CatchContractConstraints
                          .listOrganizerContactsCallablePayloadQuery,
                      placeholder: context.l10n.hostsHostAudienceSearch,
                      semanticLabel: context.l10n.hostsHostAudienceSearch,
                      textInputAction: TextInputAction.search,
                      onChanged: _scheduleSearch,
                      onSubmitted: _applySearch,
                      onCloseSearch: _closeSearch,
                    ),
                  ),
                  gapH16,
                  CatchAsyncValueView<HostCustomersDirectoryState>(
                    value: directory,
                    onRetry: () => ref.invalidate(
                      hostCustomersDirectoryControllerProvider(request),
                    ),
                    initialLoadTimeout: null,
                    loadingBuilder: (_) => const CatchSkeletonRows(count: 5),
                    errorBuilder: (_, error, _) => CatchErrorState.fromError(
                      error,
                      context: AppErrorContext.club,
                      mode: CatchErrorStateMode.compact,
                      onRetry: () => ref.invalidate(
                        hostCustomersDirectoryControllerProvider(request),
                      ),
                    ),
                    builder: (context, state) => Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HostCustomerFilterSummary(
                          filter: effectiveFilter,
                          manualTag: _manualTag,
                          count: state.matchCount,
                          countCoverage: state.matchCountCoverage,
                          campaignBlocker: campaignBridgeBlocker,
                          onMessage:
                              campaignBridgeBlocker == null &&
                                  activeSegment != null
                              ? () => _messageCustomers(
                                  selectedClub,
                                  activeSegment,
                                )
                              : null,
                          onOpenFilters: () => _openFilters(
                            selectedClub,
                            effectiveFilter,
                            _manualTag,
                            state,
                            summary.asData?.value.smsReadiness,
                          ),
                          onClear:
                              effectiveFilter == HostCustomerFilter.all &&
                                  _manualTag == null
                              ? null
                              : () => setState(() {
                                  _filter = HostCustomerFilter.all;
                                  _manualTag = null;
                                }),
                        ),
                        gapH16,
                        HostCustomersDirectory(
                          state: state,
                          hasActiveQuery:
                              _search != null ||
                              effectiveFilter != HostCustomerFilter.all ||
                              _manualTag != null,
                          onCustomerSelected: (contact) =>
                              _openCustomer(selectedClub, contact),
                          onLoadMore: state.canLoadMore
                              ? () => ref
                                    .read(
                                      hostCustomersDirectoryControllerProvider(
                                        request,
                                      ).notifier,
                                    )
                                    .loadMore()
                              : null,
                        ),
                      ],
                    ),
                  ),
                  const CatchScrollTerminalPadding(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CatchActionMenuItem<_HostCustomersHeaderAction>>
  _hostCustomersHeaderActions(
    BuildContext context,
    HostCrmSummary? summary, {
    required HostCustomerSort selectedSort,
    required bool exportEnabled,
    String? exportSublabel,
  }) => [
    CatchActionMenuItem(
      value: _HostCustomersHeaderAction.sortLastSeen,
      label: context.l10n.hostCustomersSortLastSeen,
      sublabel: context.l10n.hostCustomersSort,
      icon: CatchIcons.sort,
      selected: selectedSort == HostCustomerSort.lastSeen,
    ),
    CatchActionMenuItem(
      value: _HostCustomersHeaderAction.sortMostAttended,
      label: context.l10n.hostCustomersSortMostAttended,
      sublabel: context.l10n.hostCustomersSort,
      icon: CatchIcons.sort,
      selected: selectedSort == HostCustomerSort.mostAttended,
    ),
    CatchActionMenuItem(
      value: _HostCustomersHeaderAction.sortName,
      label: context.l10n.hostCustomersSortName,
      sublabel: context.l10n.hostCustomersSort,
      icon: CatchIcons.sort,
      selected: selectedSort == HostCustomerSort.name,
    ),
    CatchActionMenuItem(
      value: _HostCustomersHeaderAction.reviewDuplicates,
      label: context.l10n.hostCustomersReviewDuplicates,
      icon: CatchIcons.peopleOutlineRounded,
    ),
    CatchActionMenuItem(
      value: _HostCustomersHeaderAction.export,
      label: context.l10n.hostsHostAudienceExport,
      sublabel: exportSublabel,
      icon: CatchIcons.downloadRounded,
      enabled: exportEnabled,
    ),
    if (summary != null) ...[
      CatchActionMenuItem(
        value: _HostCustomersHeaderAction.whatsappReady,
        label: context.l10n.hostsHostAudienceWhatsappReady,
        sublabel: '${summary.whatsappOptInCount}',
        icon: CatchIcons.tabChats,
        enabled: false,
      ),
      CatchActionMenuItem(
        value: _HostCustomersHeaderAction.sources,
        label: context.l10n.hostsHostAudienceSources(
          importedCount: summary.importedContactCount,
          linkedCount: summary.linkedAccountCount,
        ),
        icon: CatchIcons.info,
        enabled: false,
      ),
    ],
  ];

  Future<void> _reviewDuplicates(String organizerId) async {
    final changed = await showCatchBottomSheet<bool>(
      context: context,
      builder: (_) => HostContactMergeReviewSheet(organizerId: organizerId),
    );
    if (!mounted || changed != true) return;
    ref.invalidate(hostCustomersDirectoryControllerProvider);
    ref.invalidate(hostCrmSummaryProvider(organizerId));
  }

  void _scheduleSearch(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      CatchMotion.searchDebounce,
      () => _applySearch(value),
    );
  }

  void _applySearch(String value) {
    _searchDebounce?.cancel();
    final normalized = value.trim();
    final nextSearch = normalized.isEmpty ? null : normalized;
    if (_search == nextSearch) return;
    if (mounted) {
      setState(() => _search = nextSearch);
    }
  }

  void _closeSearch() {
    FocusManager.instance.primaryFocus?.unfocus();
    _applySearch('');
  }

  Future<void> _openFilters(
    Club club,
    HostCustomerFilter activeFilter,
    HostCustomerManualTag? activeManualTag,
    HostCustomersDirectoryState directory,
    HostCrmChannelReadiness? smsReadiness,
  ) async {
    final selected = await showCatchBottomSheet<HostCustomerFilterSelection>(
      context: context,
      builder: (_) => HostCustomerFilterSheet(
        organizerId: club.id,
        search: _search,
        selectedFilter: activeFilter,
        selectedManualTag: activeManualTag,
        manualTagVocabulary: directory.manualTagVocabulary,
        selectedCount: HostCustomerSegmentCount(
          count: directory.matchCount,
          coverage: directory.matchCountCoverage,
        ),
        smsReadiness: smsReadiness,
      ),
    );
    if (selected != null && mounted) {
      setState(() {
        _filter = selected.filter;
        _manualTag = selected.manualTag;
      });
    }
  }

  void _messageCustomers(Club club, HostAudienceSegment segment) =>
      context.goNamed(
        Routes.hostInboxScreen.name,
        queryParameters: {
          'workspace': HostMessagingWorkspace.campaigns.name,
          'compose': '1',
          'segment': segment.wireValue,
          'search': ?_search,
        },
        extra: club,
      );

  Future<void> _addCustomer(
    Club club,
    HostCustomersDirectoryRequest request,
  ) async {
    final created = await showCatchBottomSheet<HostCreatedCustomer>(
      context: context,
      builder: (context) => HostAddCustomerSheet(organizerId: club.id),
    );
    if (!mounted || created == null) return;
    ref.invalidate(hostCrmSummaryProvider(club.id));
    ref.invalidate(hostCustomersDirectoryControllerProvider(request));
    _openCustomerById(club, created.contactId);
  }

  Future<void> _exportCustomers(Club club, HostCustomerFilter filter) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final export = await ref
          .read(hostCustomersControllerProvider)
          .exportCustomers(
            organizerId: club.id,
            segment: hostAudienceSegmentForCustomerFilter(filter),
          );
      if (!mounted) return;
      await ref
          .read(externalShareControllerProvider)
          .shareCsvFile(
            csv: export.csv,
            fileName: export.fileName,
            subject: context.l10n.hostsHostAudienceExportSubject,
            text: export.truncated
                ? context.l10n.hostsHostAudienceExportTruncated
                : context.l10n.hostsHostAudienceExportCount(
                    count: export.rowCount,
                  ),
          );
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _openCustomer(Club club, HostCustomerDirectoryContact contact) =>
      _openCustomerById(club, contact.contactId);

  void _openCustomerById(Club club, String contactId) {
    context.pushNamed(
      Routes.hostCustomerDetailScreen.name,
      pathParameters: {'contactId': contactId},
      queryParameters: {'organizerId': club.id},
    );
  }
}

class HostCustomersNoOrganizer extends StatelessWidget {
  const HostCustomersNoOrganizer({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: CatchScreenHeaderTitle.block(
              title: context.l10n.hostNavigationCustomers,
            ),
          ),
          CatchSliverEmptyState(
            icon: CatchIcons.groupsOutlined,
            title: context.l10n.hostsHostEventsScaffoldTitleCreateYourFirstClub,
            message: context.l10n.hostsHostEventsScaffoldBodyCreateAClubTo,
            action: CatchButton(
              label: context.l10n.hostsHostEventsScaffoldLabelCreateClub,
              onPressed: () =>
                  context.pushNamed(Routes.hostCreateClubScreen.name),
            ),
          ),
        ],
      ),
    ),
  );
}

class HostCustomerFilterSummary extends StatelessWidget {
  const HostCustomerFilterSummary({
    super.key,
    required this.filter,
    this.manualTag,
    required this.count,
    required this.countCoverage,
    required this.campaignBlocker,
    required this.onOpenFilters,
    required this.onMessage,
    this.onClear,
  });

  final HostCustomerFilter filter;
  final HostCustomerManualTag? manualTag;
  final int count;
  final HostCustomerMatchCountCoverage countCoverage;
  final String? campaignBlocker;
  final VoidCallback onOpenFilters;
  final VoidCallback? onMessage;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    final countLabel = _customerPeopleCountLabel(context, count, countCoverage);
    final header = context.l10n.hostCustomersFilterSummary(
      label: manualTag?.label ?? _customerFilterLabel(context, filter),
      countLabel: countLabel,
    );
    return CatchSurface(
      radius: CatchRadius.md,
      padding: CatchInsets.tileContentCompact,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: CatchSpacing.s3,
            runSpacing: CatchSpacing.s2,
            children: [
              Text(header, style: CatchTextStyles.labelL(context)),
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: CatchSpacing.s1,
                children: [
                  if (onClear case final clear?)
                    CatchButton(
                      label: context.l10n.hostCustomersClearFilter,
                      variant: CatchButtonVariant.ghost,
                      size: CatchButtonSize.sm,
                      onPressed: clear,
                    ),
                  CatchButton(
                    label: context.l10n.hostCustomersFilters,
                    icon: Icon(CatchIcons.tuneRounded),
                    variant: CatchButtonVariant.secondary,
                    size: CatchButtonSize.sm,
                    onPressed: onOpenFilters,
                  ),
                ],
              ),
            ],
          ),
          if (manualTag == null) ...[
            gapH12,
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: CatchSpacing.s3,
              runSpacing: CatchSpacing.s2,
              children: [
                if (campaignBlocker case final String blocker)
                  Text(
                    hostCampaignBlockerLabel(context, blocker),
                    style: CatchTextStyles.supporting(
                      context,
                      color: CatchTokens.of(context).warning,
                    ),
                  ),
                CatchButton(
                  key: const ValueKey('host-customers-message-segment'),
                  label: countCoverage == HostCustomerMatchCountCoverage.exact
                      ? context.l10n.hostCustomersMessageThese(count: count)
                      : context.l10n.hostCustomersMessageTheseAtLeast(
                          count: count,
                        ),
                  size: CatchButtonSize.sm,
                  onPressed: onMessage,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class HostCustomerFilterSheet extends ConsumerWidget {
  const HostCustomerFilterSheet({
    super.key,
    required this.organizerId,
    required this.selectedFilter,
    required this.selectedManualTag,
    required this.manualTagVocabulary,
    required this.selectedCount,
    required this.smsReadiness,
    this.search,
  });

  final String organizerId;
  final String? search;
  final HostCustomerFilter selectedFilter;
  final HostCustomerManualTag? selectedManualTag;
  final List<HostCustomerManualTag> manualTagVocabulary;
  final HostCustomerSegmentCount selectedCount;
  final HostCrmChannelReadiness? smsReadiness;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = hostCustomerFilterGroupsForSmsReadiness(smsReadiness);
    return CatchBottomSheetScaffold(
      title: context.l10n.hostCustomersFilterSheetTitle,
      subtitle: context.l10n.hostCustomersFilterSheetSubtitle,
      child: SingleChildScrollView(
        child: CatchSectionList(
          emptyStateOmitted: true,
          children: [
            for (final entry in groups.entries)
              CatchSection.divided(
                title: _customerFilterGroupLabel(context, entry.key),
                child: Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    for (final filter in entry.value)
                      _HostCustomerFilterCountChip(
                        organizerId: organizerId,
                        search: search,
                        filter: filter,
                        selected:
                            selectedManualTag == null &&
                            selectedFilter == filter,
                        selectedCount: selectedCount,
                      ),
                  ],
                ),
              ),
            if (manualTagVocabulary.isNotEmpty)
              CatchSection.divided(
                title: context.l10n.hostCustomersFilterGroupYourTags,
                child: Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    for (final tag in manualTagVocabulary)
                      _HostCustomerManualTagCountChip(
                        organizerId: organizerId,
                        search: search,
                        tag: tag,
                        selected: selectedManualTag?.tagId == tag.tagId,
                        selectedCount: selectedCount,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HostCustomerFilterCountChip extends ConsumerWidget {
  const _HostCustomerFilterCountChip({
    required this.organizerId,
    required this.search,
    required this.filter,
    required this.selected,
    required this.selectedCount,
  });

  final String organizerId;
  final String? search;
  final HostCustomerFilter filter;
  final bool selected;
  final HostCustomerSegmentCount selectedCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = selected
        ? AsyncValue.data(selectedCount)
        : ref.watch(
            hostCustomerSegmentCountProvider(
              HostCustomerSegmentCountRequest(
                organizerId: organizerId,
                search: search,
                filter: filter,
              ),
            ),
          );
    final countLabel = count.when(
      data: (value) =>
          _customerPeopleCountLabel(context, value.count, value.coverage),
      loading: () => context.l10n.hostCustomersCountLoading,
      error: (_, _) => context.l10n.hostCustomersCountUnavailable,
    );
    return CatchChip.selectable(
      key: ValueKey('host-customer-filter-${filter.name}'),
      label: context.l10n.hostCustomersFilterOption(
        label: _customerFilterLabel(context, filter),
        countLabel: countLabel,
      ),
      selected: selected,
      contractExemption: 'Customer filters map to reviewed CRM segments.',
      onChanged: (_) => Navigator.of(
        context,
      ).pop(HostCustomerFilterSelection.computed(filter)),
    );
  }
}

class _HostCustomerManualTagCountChip extends ConsumerWidget {
  const _HostCustomerManualTagCountChip({
    required this.organizerId,
    required this.search,
    required this.tag,
    required this.selected,
    required this.selectedCount,
  });

  final String organizerId;
  final String? search;
  final HostCustomerManualTag tag;
  final bool selected;
  final HostCustomerSegmentCount selectedCount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = selected
        ? AsyncValue.data(selectedCount)
        : ref.watch(
            hostCustomerManualTagCountProvider(
              HostCustomerManualTagCountRequest(
                organizerId: organizerId,
                manualTagId: tag.tagId,
                search: search,
              ),
            ),
          );
    final countLabel = count.when(
      data: (value) =>
          _customerPeopleCountLabel(context, value.count, value.coverage),
      loading: () => context.l10n.hostCustomersCountLoading,
      error: (_, _) => context.l10n.hostCustomersCountUnavailable,
    );
    return CatchChip.selectable(
      key: ValueKey('host-customer-manual-tag-${tag.tagId}'),
      label: context.l10n.hostCustomersFilterOption(
        label: tag.label,
        countLabel: countLabel,
      ),
      leading: Icon(CatchIcons.editNoteOutlined),
      selected: selected,
      accent: CatchTokens.of(context).ink2,
      contractExemption: 'Manual tags are organizer-owned CRM vocabulary.',
      onChanged: (_) =>
          Navigator.of(context).pop(HostCustomerFilterSelection.manual(tag)),
    );
  }
}

class HostCustomersDirectory extends StatelessWidget {
  const HostCustomersDirectory({
    super.key,
    required this.state,
    required this.hasActiveQuery,
    required this.onCustomerSelected,
    required this.onLoadMore,
  });

  final HostCustomersDirectoryState state;
  final bool hasActiveQuery;
  final ValueChanged<HostCustomerDirectoryContact> onCustomerSelected;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final contacts = state.contacts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.sourceCoverage != HostCustomerDirectoryCoverage.exact) ...[
          CatchSurface.message(
            title: context.l10n.hostsHostAudienceCoveragePartial,
            message: context.l10n.hostsHostAudienceCoveragePartialBody,
            messageIcon: CatchIcons.infoOutlineRounded,
            messageTone: CatchSurfaceMessageTone.warning,
          ),
          gapH12,
        ],
        if (contacts.isEmpty)
          CatchEmptyState(
            icon: CatchIcons.peopleOutlineRounded,
            title: hasActiveQuery
                ? context.l10n.hostCustomersNoResults
                : context.l10n.hostCustomersEmpty,
            message: hasActiveQuery ? null : context.l10n.hostCustomersIntro,
            layout: CatchEmptyStateLayout.inline,
          )
        else
          CatchFieldLanes.single(
            child: Column(
              children: [
                for (final (index, contact) in contacts.indexed)
                  HostCustomerRow(
                    contact: contact,
                    divider: index < contacts.length - 1,
                    onTap: () => onCustomerSelected(contact),
                  ),
              ],
            ),
          ),
        if (onLoadMore != null) ...[
          gapH12,
          CatchButton(
            label: context.l10n.hostCustomersLoadMore,
            variant: CatchButtonVariant.secondary,
            size: CatchButtonSize.sm,
            isLoading: state.loadingMore,
            onPressed: state.loadingMore ? null : onLoadMore,
          ),
        ],
        if (state.loadMoreError != null) ...[
          gapH8,
          CatchErrorState.fromError(
            state.loadMoreError!,
            context: AppErrorContext.club,
            mode: CatchErrorStateMode.compact,
            onRetry: onLoadMore,
          ),
        ],
      ],
    );
  }
}

class HostAddCustomerSheet extends ConsumerStatefulWidget {
  const HostAddCustomerSheet({super.key, required this.organizerId});

  final String organizerId;

  @override
  ConsumerState<HostAddCustomerSheet> createState() =>
      _HostAddCustomerSheetState();
}

class _HostAddCustomerSheetState extends ConsumerState<HostAddCustomerSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _noteController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: context.l10n.hostCustomersAddTitle,
    subtitle: context.l10n.hostCustomersAddHelp,
    keyboardSafe: true,
    child: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: CatchFieldLanes.custom(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchField.input(
                key: const ValueKey('host-add-customer-name'),
                title: context.l10n.hostCustomersName,
                contract: CatchContractConstraints
                    .createOrganizerContactCallablePayloadDisplayName,
                controller: _nameController,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.name],
                validator: (value) => (value ?? '').trim().isEmpty
                    ? context.l10n.hostCustomersNameRequired
                    : null,
              ),
              gapH12,
              CatchField.input(
                key: const ValueKey('host-add-customer-phone'),
                title: context.l10n.hostCustomersPhone,
                contract: CatchContractConstraints
                    .createOrganizerContactCallablePayloadPhoneE164,
                controller: _phoneController,
                isOptional: true,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.telephoneNumber],
                placeholder: '+919876543210',
                helperText: context.l10n.hostCustomersPhoneHelp,
                validator: (value) => _manualPhoneError(context, value),
              ),
              gapH12,
              CatchField.input(
                key: const ValueKey('host-add-customer-email'),
                title: context.l10n.hostCustomersEmail,
                contract: CatchContractConstraints
                    .createOrganizerContactCallablePayloadEmail,
                controller: _emailController,
                isOptional: true,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.email],
                validator: (value) => _manualEmailError(context, value),
              ),
              gapH12,
              CatchField.input(
                key: const ValueKey('host-add-customer-note'),
                title: context.l10n.hostCustomersInitialNote,
                contract: CatchContractConstraints
                    .createOrganizerContactCallablePayloadInitialNote,
                controller: _noteController,
                isOptional: true,
                minLines: 3,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => unawaited(_submit()),
              ),
              gapH16,
              CatchButton(
                key: const ValueKey('host-add-customer-submit'),
                label: context.l10n.hostCustomersAdd,
                isLoading: _saving,
                onPressed: _saving ? null : _submit,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (_saving || !(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _saving = true);
    try {
      final customer = await ref
          .read(hostCustomersControllerProvider)
          .createCustomer(
            organizerId: widget.organizerId,
            displayName: name,
            phoneE164: _optionalManualPhone(_phoneController.text),
            email: _optionalNormalizedEmail(_emailController.text),
            initialNote: _optionalTrimmed(_noteController.text),
          );
      if (mounted) Navigator.of(context).pop(customer);
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

enum HostCustomerManageResult { updated, hidden }

class HostCustomerManageSheet extends ConsumerStatefulWidget {
  const HostCustomerManageSheet({super.key, required this.customer});

  final HostAudienceContactDetail customer;

  @override
  ConsumerState<HostCustomerManageSheet> createState() =>
      _HostCustomerManageSheetState();
}

class _HostCustomerManageSheetState
    extends ConsumerState<HostCustomerManageSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController = TextEditingController(
    text:
        widget.customer.displayNameOverride ??
        widget.customer.sourceDisplayName,
  );
  late final TextEditingController _phoneController = TextEditingController(
    text: widget.customer.phoneE164,
  );
  late final TextEditingController _emailController = TextEditingController(
    text: widget.customer.email,
  );
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: widget.customer.displayName,
    subtitle: context.l10n.hostsHostAudienceContactSubtitle,
    keyboardSafe: true,
    child: SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: CatchFieldLanes.custom(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchField.input(
                title: context.l10n.hostsHostAudienceContactName,
                contract: CatchContractConstraints
                    .mutateOrganizerContactCallablePayloadDisplayNameOverride,
                controller: _nameController,
                helperText: context.l10n.hostsHostAudienceContactNameHelp,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                validator: (value) => (value ?? '').trim().isEmpty
                    ? context.l10n.hostCustomersNameRequired
                    : null,
              ),
              if (_canEditContactDetails) ...[
                gapH12,
                CatchField.input(
                  title: context.l10n.hostCustomersPhone,
                  contract: CatchContractConstraints
                      .mutateOrganizerContactCallablePayloadPhoneE164,
                  controller: _phoneController,
                  isOptional: true,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  placeholder: '+919876543210',
                  helperText: context.l10n.hostCustomersPhoneHelp,
                  validator: (value) => _manualPhoneError(context, value),
                ),
                gapH12,
                CatchField.input(
                  title: context.l10n.hostCustomersEmail,
                  contract: CatchContractConstraints
                      .mutateOrganizerContactCallablePayloadEmail,
                  controller: _emailController,
                  isOptional: true,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.done,
                  validator: (value) => _manualEmailError(context, value),
                ),
              ] else ...[
                gapH12,
                Text(
                  context.l10n.hostCustomersVerifiedDetailsManagedByCatch,
                  style: CatchTextStyles.supporting(context),
                ),
              ],
              gapH12,
              CatchButton(
                key: const ValueKey('host-customer-save-details'),
                label: context.l10n.hostCustomersSaveDetails,
                size: CatchButtonSize.sm,
                isLoading: _saving,
                onPressed: _saving ? null : _saveDetails,
              ),
              gapH16,
              CatchNotice(
                notice: CatchNoticeData(
                  id: 'host.customers.contact.delivery-boundary',
                  title: context.l10n.hostsHostAudienceContactConsentTitle,
                  message: widget.customer.whatsappAdminSuppressed
                      ? context.l10n.hostsHostAudienceContactConsentPaused
                      : context.l10n.hostsHostAudienceContactConsentActive,
                ),
              ),
              gapH12,
              CatchButton(
                label: widget.customer.whatsappAdminSuppressed
                    ? context.l10n.hostsHostAudienceContactResumeMessages
                    : context.l10n.hostsHostAudienceContactPauseMessages,
                variant: CatchButtonVariant.secondary,
                onPressed: _saving ? null : _toggleSuppression,
              ),
              gapH8,
              CatchButton(
                label: context.l10n.hostsHostAudienceRemoveAction,
                variant: CatchButtonVariant.ghost,
                onPressed: _saving ? null : _hideCustomer,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  bool get _canEditContactDetails => widget.customer.contactDetailsEditable;

  Future<void> _saveDetails() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final value = _nameController.text.trim();
    await _mutate(
      displayNameOverride: value == widget.customer.sourceDisplayName
          ? null
          : value,
      clearDisplayNameOverride: value == widget.customer.sourceDisplayName,
      phoneE164: _optionalManualPhone(_phoneController.text),
      updatePhoneE164: _canEditContactDetails,
      email: _optionalNormalizedEmail(_emailController.text),
      updateEmail: _canEditContactDetails,
      result: HostCustomerManageResult.updated,
    );
  }

  Future<void> _toggleSuppression() => _mutate(
    whatsappAdminSuppressed: !widget.customer.whatsappAdminSuppressed,
    result: HostCustomerManageResult.updated,
  );

  Future<void> _hideCustomer() async {
    final confirmed = await showCatchConfirmDialog(
      context: context,
      title: context.l10n.hostsHostAudienceRemoveTitle,
      message: context.l10n.hostsHostAudienceRemoveBody,
      confirmLabel: context.l10n.hostsHostAudienceRemoveConfirm,
      danger: true,
    );
    if (confirmed != true) return;
    await _mutate(hidden: true, result: HostCustomerManageResult.hidden);
  }

  Future<void> _mutate({
    String? displayNameOverride,
    bool clearDisplayNameOverride = false,
    String? phoneE164,
    bool updatePhoneE164 = false,
    String? email,
    bool updateEmail = false,
    bool? whatsappAdminSuppressed,
    bool? hidden,
    required HostCustomerManageResult result,
  }) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref
          .read(hostCustomersControllerProvider)
          .mutateCustomer(
            organizerId: widget.customer.organizerId,
            contactId: widget.customer.contactId,
            expectedRevision: widget.customer.revision,
            displayNameOverride: displayNameOverride,
            clearDisplayNameOverride: clearDisplayNameOverride,
            phoneE164: phoneE164,
            updatePhoneE164: updatePhoneE164,
            email: email,
            updateEmail: updateEmail,
            whatsappAdminSuppressed: whatsappAdminSuppressed,
            hidden: hidden,
          );
      if (mounted) Navigator.of(context).pop(result);
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.club,
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class HostCustomerIdentityCard extends StatelessWidget {
  const HostCustomerIdentityCard({
    super.key,
    required this.customer,
    required this.onManage,
  });

  final HostAudienceContactDetail customer;
  final VoidCallback onManage;

  @override
  Widget build(BuildContext context) => CatchSection.divided(
    title: context.l10n.hostCustomersContactDetails,
    trailing: CatchButton(
      label: customer.contactDetailsEditable
          ? context.l10n.hostCustomersEditDetails
          : context.l10n.hostCustomersManage,
      variant: CatchButtonVariant.secondary,
      size: CatchButtonSize.sm,
      onPressed: onManage,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (customer.phoneE164 == null && customer.email == null)
          Text(
            context.l10n.hostCustomersNoContactDetails,
            style: CatchTextStyles.supporting(context),
          )
        else ...[
          if (customer.identityConfidence != 'verified') ...[
            Text(
              context.l10n.hostCustomersUnverifiedContactDetails,
              style: CatchTextStyles.supporting(context),
            ),
            gapH8,
          ],
          CatchFieldLanes.single(
            child: Column(
              children: [
                if (customer.phoneE164 != null)
                  CatchField.read(
                    title: customer.identityConfidence == 'verified'
                        ? context.l10n.hostsHostAudienceContactVerifiedPhone
                        : context.l10n.hostCustomersPhone,
                    body: customer.phoneE164,
                    divider: customer.email != null,
                  ),
                if (customer.email != null)
                  CatchField.read(
                    title: context.l10n.hostsHostAudienceContactEmail,
                    body: customer.email,
                  ),
              ],
            ),
          ),
        ],
      ],
    ),
  );
}

class HostCustomerConversationCard extends StatelessWidget {
  const HostCustomerConversationCard({
    super.key,
    required this.customer,
    required this.loading,
    required this.onOpen,
    this.onReview,
  });

  final HostAudienceContactDetail customer;
  final bool loading;
  final VoidCallback? onOpen;
  final VoidCallback? onReview;

  @override
  Widget build(BuildContext context) {
    final availability = customerConversationAvailability(
      linkedAccount: customer.linkedAccount,
      identityVerified:
          customer.identityState == HostAudienceIdentityState.verified,
      ambiguousCandidateCount: customer.ambiguousCandidateCount,
    );
    final message = switch (availability) {
      HostCustomerConversationAvailability.ready => null,
      HostCustomerConversationAvailability.unlinked =>
        context.l10n.hostCustomersConversationUnlinked,
      HostCustomerConversationAvailability.ambiguous =>
        context.l10n.hostCustomersConversationAmbiguous,
    };
    return CatchSurface(
      padding: CatchInsets.cardContent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (message != null) ...[
            Text(message, style: CatchTextStyles.supporting(context)),
            gapH12,
          ],
          if (availability == HostCustomerConversationAvailability.ambiguous &&
              onReview != null) ...[
            CatchButton(
              label: context.l10n.hostCustomersReviewDuplicates,
              variant: CatchButtonVariant.secondary,
              onPressed: onReview,
            ),
            gapH12,
          ],
          CatchButton(
            label: context.l10n.hostCustomersNewConversation,
            icon: Icon(CatchIcons.tabChats),
            isLoading: loading,
            onPressed: loading ? null : onOpen,
          ),
        ],
      ),
    );
  }
}

class HostCustomerAttendanceCard extends StatelessWidget {
  const HostCustomerAttendanceCard({super.key, required this.customer});

  final HostAudienceContactDetail customer;

  @override
  Widget build(BuildContext context) {
    final traits = customer.traits;
    final attendanceRate = traits.attendanceRate == null
        ? '—'
        : '${(traits.attendanceRate! * 100).round()}%';
    return CatchSection.divided(
      title: context.l10n.hostCustomersDetailAttendance,
      child: Row(
        children: [
          Expanded(
            child: CatchStatColumn(
              value: '${traits.attendedEventCount}',
              label: context.l10n.hostsHostAudienceAttended,
              monoValue: true,
            ),
          ),
          Expanded(
            child: CatchStatColumn(
              value: '${traits.expectedEventCount}',
              label: context.l10n.hostCustomersExpected,
              monoValue: true,
            ),
          ),
          Expanded(
            child: CatchStatColumn(
              value: attendanceRate,
              label: context.l10n.hostCustomersAttendanceRate,
              monoValue: true,
            ),
          ),
        ],
      ),
    );
  }
}

class HostCustomerRevenueCard extends StatelessWidget {
  const HostCustomerRevenueCard({super.key, required this.revenue});

  final HostCustomerRevenue revenue;

  @override
  Widget build(BuildContext context) => CatchSection.divided(
    title: context.l10n.hostCustomersDetailRevenue,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (revenue.coverage == HostCustomerRevenueCoverage.unavailable)
          Text(
            context.l10n.hostCustomersDetailRevenueUnavailable,
            style: CatchTextStyles.supporting(context),
          )
        else if (revenue.amounts.isEmpty)
          Text(
            context.l10n.hostCustomersDetailNoRevenue,
            style: CatchTextStyles.supporting(context),
          )
        else
          CatchFieldLanes.single(
            child: Column(
              children: [
                for (final (index, amount) in revenue.amounts.indexed)
                  CatchField.read(
                    title: NumberFormat.simpleCurrency(
                      name: amount.currency,
                    ).format(amount.amountMinor / 100),
                    body: context.l10n.hostCustomersDetailPaidOrders(
                      count: amount.paidOrderCount,
                    ),
                    valueText: amount.currency,
                    divider: index < revenue.amounts.length - 1,
                  ),
              ],
            ),
          ),
        if (revenue.coverage == HostCustomerRevenueCoverage.partial) ...[
          gapH12,
          CatchNotice(
            notice: CatchNoticeData(
              id: 'host.customers.revenue.partial',
              title: context.l10n.hostsHostAudienceCoveragePartial,
              message: context.l10n.hostCustomersDetailRevenuePartial,
              tone: CatchNoticeTone.warning,
            ),
          ),
        ],
      ],
    ),
  );
}

class HostCustomerAttendanceHistory extends StatelessWidget {
  const HostCustomerAttendanceHistory({super.key, required this.customer});

  final HostAudienceContactDetail customer;

  @override
  Widget build(BuildContext context) {
    final events = customer.events;
    return CatchSection.divided(
      title: context.l10n.hostCustomersEventHistory,
      child: events.isEmpty
          ? Text(
              context.l10n.hostCustomersNoAttendance,
              style: CatchTextStyles.supporting(context),
            )
          : CatchFieldLanes.single(
              child: Column(
                children: [
                  for (final (index, event) in events.indexed)
                    CatchField.nav(
                      title: event.displayName,
                      body: event.eventStartAt == null
                          ? event.source
                          : '${AppTimeFormatters.shortDate(event.eventStartAt!)} · ${event.source}',
                      valueText: event.checkedIn
                          ? context.l10n.hostCustomersCheckedIn
                          : event.status,
                      divider: index < events.length - 1,
                      onTap: () => context.pushNamed(
                        Routes.hostAppEventDetailScreen.name,
                        pathParameters: {
                          'clubId': customer.organizerId,
                          'eventId': event.eventId,
                        },
                      ),
                    ),
                ],
              ),
            ),
    );
  }
}

class HostCustomersSummary extends StatelessWidget {
  const HostCustomersSummary({
    super.key,
    required this.summary,
    required this.onRetry,
  });

  final AsyncValue<HostCrmSummary> summary;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => CatchAsyncValueView<HostCrmSummary>(
    value: summary,
    onRetry: onRetry,
    initialLoadTimeout: null,
    loadingBuilder: (_) => const CatchSkeletonRows(count: 1),
    errorBuilder: (_, error, _) => CatchErrorState.fromError(
      error,
      context: AppErrorContext.club,
      mode: CatchErrorStateMode.compact,
      onRetry: onRetry,
    ),
    builder: (context, value) {
      final usesLargeText = MediaQuery.textScalerOf(context).scale(1) >= 1.5;
      return CatchSurface(
        padding: CatchInsets.cardContent,
        child: usesLargeText
            ? CatchFieldLanes.single(
                child: Column(
                  children: [
                    CatchField.read(
                      title: context.l10n.hostsHostAudienceContacts,
                      valueText: '${value.contactCount}',
                    ),
                    CatchField.read(
                      title: context.l10n.hostsHostAudienceAttended,
                      valueText: '${value.pastAttendeeCount}',
                    ),
                    CatchField.read(
                      title: context.l10n.hostsHostAudienceRepeat,
                      valueText: '${value.repeatAttendeeCount}',
                    ),
                  ],
                ),
              )
            : Row(
                children: [
                  Expanded(
                    child: CatchStatColumn(
                      value: '${value.contactCount}',
                      label: context.l10n.hostsHostAudienceContacts,
                      monoValue: true,
                    ),
                  ),
                  Expanded(
                    child: CatchStatColumn(
                      value: '${value.pastAttendeeCount}',
                      label: context.l10n.hostsHostAudienceAttended,
                      monoValue: true,
                    ),
                  ),
                  Expanded(
                    child: CatchStatColumn(
                      value: '${value.repeatAttendeeCount}',
                      label: context.l10n.hostsHostAudienceRepeat,
                      monoValue: true,
                    ),
                  ),
                ],
              ),
      );
    },
  );
}

String _customerFilterLabel(
  BuildContext context,
  HostCustomerFilter filter,
) => switch (filter) {
  HostCustomerFilter.all => context.l10n.hostsHostAudienceAll,
  HostCustomerFilter.newToOrganizer => context.l10n.hostsHostAudienceSegmentNew,
  HostCustomerFilter.firstTime =>
    context.l10n.hostsHostAudienceSegmentFirstTime,
  HostCustomerFilter.repeat => context.l10n.hostsHostAudienceSegmentRepeat,
  HostCustomerFilter.regular => context.l10n.hostsHostAudienceSegmentRegular,
  HostCustomerFilter.atRisk => context.l10n.hostCustomersFilterAtRisk,
  HostCustomerFilter.reliable => context.l10n.hostsHostAudienceSegmentReliable,
  HostCustomerFilter.needsConfirmation =>
    context.l10n.hostsHostAudienceSegmentNeedsConfirmation,
  HostCustomerFilter.advocate => context.l10n.hostsHostAudienceSegmentAdvocate,
  HostCustomerFilter.highImpactAdvocate =>
    context.l10n.hostsHostAudienceSegmentHighImpact,
  HostCustomerFilter.whatsappReachable =>
    context.l10n.hostsHostAudienceSegmentWhatsapp,
  HostCustomerFilter.smsReachable => context.l10n.hostsHostAudienceSegmentSms,
};

String _customerFilterGroupLabel(
  BuildContext context,
  HostCustomerFilterGroup group,
) => switch (group) {
  HostCustomerFilterGroup.attendance =>
    context.l10n.hostCustomersFilterGroupAttendance,
  HostCustomerFilterGroup.reliability =>
    context.l10n.hostCustomersFilterGroupReliability,
  HostCustomerFilterGroup.advocacy =>
    context.l10n.hostCustomersFilterGroupAdvocacy,
  HostCustomerFilterGroup.reachable =>
    context.l10n.hostCustomersFilterGroupReachable,
};

String _customerPeopleCountLabel(
  BuildContext context,
  int count,
  HostCustomerMatchCountCoverage coverage,
) => switch (coverage) {
  HostCustomerMatchCountCoverage.exact => context.l10n.hostCustomersPeopleCount(
    count: count,
  ),
  HostCustomerMatchCountCoverage.atLeast =>
    context.l10n.hostCustomersPeopleCountAtLeast(count: count),
};

String? _optionalTrimmed(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

String? _optionalManualPhone(String value) {
  final trimmed = _optionalTrimmed(value);
  return trimmed?.replaceAll(RegExp(r'[()\s-]+'), '');
}

String? _optionalNormalizedEmail(String value) =>
    _optionalTrimmed(value)?.toLowerCase();

String? _manualPhoneError(BuildContext context, String? value) {
  final phone = _optionalManualPhone(value ?? '');
  if (phone == null) return null;
  return RegExp(r'^\+[1-9][0-9]{7,14}$').hasMatch(phone)
      ? null
      : context.l10n.hostCustomersPhoneInvalid;
}

String? _manualEmailError(BuildContext context, String? value) {
  final email = _optionalNormalizedEmail(value ?? '');
  if (email == null) return null;
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email)
      ? null
      : context.l10n.hostCustomersEmailInvalid;
}
