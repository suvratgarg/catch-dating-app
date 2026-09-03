import 'dart:async';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/responsive/breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_adaptive_dialog.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_banner.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_row_press_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_selection_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_tabbed_screen.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_contact_merge_review.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_detail_route_arguments.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_detail_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_palette.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_row.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_typography.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_view.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_campaign_composer.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_screen.dart';
import 'package:catch_dating_app/hosts/presentation/widgets/host_loading_skeletons.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

part 'host_customer_detail_cards.dart';
part 'host_customer_editor.dart';
part 'host_customer_editor_sheets.dart';
part 'host_customers_directory.dart';
part 'host_saved_audience_editor.dart';
part 'host_saved_audiences_workspace.dart';

enum _HostCustomersHeaderAction { reviewDuplicates, export }

class HostCustomersScreen extends ConsumerStatefulWidget {
  const HostCustomersScreen({
    super.key,
    this.initialOrganizerId,
    this.initialContactId,
    this.initialContactDisplayName,
    this.initialView = HostAudienceView.people,
  }) : assert(
         initialView == HostAudienceView.people ||
             initialView == HostAudienceView.audiences,
       );

  final String? initialOrganizerId;
  final String? initialContactId;
  final String? initialContactDisplayName;
  final HostAudienceView initialView;

  @override
  ConsumerState<HostCustomersScreen> createState() =>
      _HostCustomersScreenState();
}

class _HostCustomersScreenState extends ConsumerState<HostCustomersScreen>
    with SingleTickerProviderStateMixin {
  Timer? _searchDebounce;
  String? _search;
  String? _audienceSearch;
  HostCustomerFilter _filter = HostCustomerFilter.all;
  HostCustomerManualTag? _manualTag;
  HostCustomerSort _sort = HostCustomerSort.lastSeen;
  bool _exporting = false;
  bool _searchExpanded = false;
  String? _selectedContactId;
  String? _selectedContactDisplayName;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      initialIndex: widget.initialView.index,
      vsync: this,
    )..addListener(_handleViewChanged);
    _selectedContactId = widget.initialContactId;
    _selectedContactDisplayName = widget.initialContactDisplayName;
  }

  @override
  void didUpdateWidget(covariant HostCustomersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialView != widget.initialView &&
        _tabController.index != widget.initialView.index) {
      _tabController.index = widget.initialView.index;
    }
    if (oldWidget.initialContactId != widget.initialContactId) {
      _selectedContactId = widget.initialContactId;
      if (widget.initialContactDisplayName != null ||
          oldWidget.initialContactId != widget.initialContactId) {
        _selectedContactDisplayName = widget.initialContactDisplayName;
      }
    }
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _tabController
      ..removeListener(_handleViewChanged)
      ..dispose();
    super.dispose();
  }

  HostAudienceView get _view => HostAudienceView.values[_tabController.index];

  void _handleViewChanged() {
    if (_tabController.indexIsChanging || !mounted) return;
    setState(() => _searchExpanded = false);
  }

  @override
  Widget build(BuildContext context) {
    final uidAsync = ref.watch(uidProvider);
    final uidState = catchAsyncStateFromAsyncValue(uidAsync);
    final uid = uidState.value;
    if (uidState.hasError) {
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-customers-route-state'),
        slivers: [
          CatchSliverErrorState.fromError(
            uidState.error!,
            context: AppErrorContext.auth,
            onRetry: () => ref.invalidate(uidProvider),
          ),
        ],
      );
    }
    if (uidState.isLoading) {
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-customers-route-state'),
        slivers: const [
          CatchSliverStateViewport(
            child: HostRouteLoadingBody(padding: EdgeInsets.zero),
          ),
        ],
      );
    }
    if (uid == null) {
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-customers-route-state'),
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
      );
    }

    final clubsAsync = ref.watch(hostOperableClubsProvider(uid));
    final clubsState = catchAsyncStateFromAsyncValue(clubsAsync);
    if (clubsState.hasError) {
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-customers-route-state'),
        slivers: [
          CatchSliverErrorState.fromError(
            clubsState.error!,
            context: AppErrorContext.club,
            onRetry: () => ref.invalidate(hostOperableClubsProvider(uid)),
          ),
        ],
      );
    }
    if (clubsState.isLoading) {
      return HostAudienceStateScaffold(
        selected: _view,
        scrollKey: const PageStorageKey<String>('host-customers-route-state'),
        slivers: const [
          CatchSliverStateViewport(
            child: HostRouteLoadingBody(padding: EdgeInsets.zero),
          ),
        ],
      );
    }
    final clubs = clubsState.value ?? const <Club>[];
    if (clubs.isEmpty) {
      return HostCustomersNoOrganizer(selected: _view);
    }
    final selectedOrganizerId = ref.watch(hostOrganizerSelectionProvider(uid));
    final selectedClub = resolveSelectedHostOrganizer(
      clubs,
      selectedOrganizerId: selectedOrganizerId,
      preferredOrganizerId: selectedOrganizerId == null
          ? widget.initialOrganizerId
          : null,
    )!;
    final peopleView = _view == HostAudienceView.people;
    final summary = peopleView
        ? ref.watch(hostCrmSummaryProvider(selectedClub.id))
        : const AsyncLoading<HostCrmSummary>();
    final messagingSetup = peopleView
        ? ref.watch(hostMessagingSetupProvider(selectedClub.id))
        : const AsyncLoading<HostMessagingSetup>();
    final summaryState = catchAsyncStateFromAsyncValue(summary);
    final messagingSetupState = catchAsyncStateFromAsyncValue(messagingSetup);
    final visibleFilters = hostCustomerFiltersForSmsReadiness(
      summaryState.value?.smsReadiness,
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
    final directory = peopleView
        ? ref.watch(hostCustomersDirectoryControllerProvider(request))
        : const AsyncLoading<HostCustomersDirectoryState>();
    final directoryState = catchAsyncStateFromAsyncValue(directory).value;
    final campaignAudienceDefinition =
        hostSavedAudienceDefinitionForCustomerSelection(
          filter: effectiveFilter,
          manualTag: _manualTag,
        );
    final campaignBridgePhase = directoryState == null
        ? HostCustomerCampaignBridgePhase.notApplicable
        : hostCustomerCampaignBridgePhase(
            hasAudienceDefinition: campaignAudienceDefinition != null,
            hasActiveSearch: _search != null,
            directory: directoryState,
            messagingSetup: messagingSetupState,
          );
    final campaignBridgeBlocker = switch (campaignBridgePhase) {
      HostCustomerCampaignBridgePhase.noReachableRecipients =>
        HostCampaignBlockers.noReachableRecipients,
      HostCustomerCampaignBridgePhase.audienceCoveragePartial =>
        HostCampaignBlockers.audienceCoveragePartial,
      HostCustomerCampaignBridgePhase.providerUnavailable =>
        HostCampaignBlockers.providerSetupRequired,
      HostCustomerCampaignBridgePhase.senderSetupRequired =>
        HostCampaignBlockers.senderInactive,
      _ => null,
    };
    final screenSize = ScreenSize.fromWidth(MediaQuery.sizeOf(context).width);
    final activeQuery = peopleView ? _search : _audienceSearch;
    final directoryControls = HostCustomerDirectoryControls(
      sort: _sort,
      shrinkWrap: true,
      condensed: screenSize.isCompact || screenSize.isExpanded,
      onSortChanged: (sort) => setState(() => _sort = sort),
      onOpenFilters: directoryState == null
          ? null
          : () => _openFilters(
              effectiveFilter,
              _manualTag,
              directoryState,
              summaryState.value?.smsReadiness,
            ),
    );
    return CatchTabbedScreenScaffold(
      title: context.l10n.hostNavigationAudience,
      actions: peopleView
          ? [
              CatchTopBarPrimaryAction(
                key: const ValueKey<String>('host-customers-add-customer'),
                label: context.l10n.hostCustomersAdd,
                icon: CatchIcons.personAddAlt1Rounded,
                onPressed: () => _addCustomer(selectedClub, request),
              ),
              CatchTopBarMenuAction<_HostCustomersHeaderAction>(
                variant: CatchIconButtonVariant.plain,
                tooltip: context.l10n.hostCustomersMoreActions,
                items: _hostCustomersHeaderActions(
                  context,
                  includeExport: !_exporting,
                  exportEnabled: _manualTag == null,
                  exportSublabel: _manualTag == null
                      ? null
                      : context.l10n.hostCustomersManualTagExportUnavailable,
                ),
                onSelected: (action) {
                  if (action == _HostCustomersHeaderAction.reviewDuplicates) {
                    unawaited(_reviewDuplicates(selectedClub.id));
                  }
                  if (action == _HostCustomersHeaderAction.export) {
                    unawaited(_exportCustomers(selectedClub, effectiveFilter));
                  }
                },
              ),
            ]
          : const [],
      search: CatchTopBarSearch(
        backgroundColor: Colors.transparent,
        borderColor: Colors.transparent,
        fieldKey: ValueKey(
          peopleView ? 'host-customers-search' : 'host-audiences-search',
        ),
        value: activeQuery ?? '',
        contract: peopleView
            ? CatchContractConstraints.listOrganizerContactsCallablePayloadQuery
            : CatchContractConstraints
                  .upsertOrganizerSavedAudienceCallablePayloadName,
        placeholder: peopleView
            ? context.l10n.hostsHostAudienceSearch
            : context.l10n.hostSavedAudiencesSearch,
        tooltip: peopleView
            ? context.l10n.hostsHostAudienceSearch
            : context.l10n.hostSavedAudiencesSearch,
        semanticLabel: peopleView
            ? context.l10n.hostsHostAudienceSearch
            : context.l10n.hostSavedAudiencesSearch,
        expanded: _searchExpanded || activeQuery != null,
        onExpandedChanged: (expanded) {
          if (_searchExpanded == expanded) return;
          setState(() => _searchExpanded = expanded);
        },
        onChanged: (value) => _scheduleSearch(_view, value),
        onSubmitted: (value) => _applySearch(_view, value),
        onFocusChanged: (focused) {
          if (!focused && activeQuery == null && _searchExpanded) {
            setState(() => _searchExpanded = false);
          }
        },
        textInputAction: TextInputAction.search,
      ),
      tabRail: PreferredSize(
        preferredSize: const Size.fromHeight(CatchLayout.tabRailHeight),
        child: AnimatedBuilder(
          animation: _tabController.animation!,
          builder: (context, _) => HostAudienceTabRail(
            selected: _view,
            selectionPosition: _tabController.animation!.value,
            onChanged: (view) => _selectAudienceView(view, selectedClub.id),
          ),
        ),
      ),
      body: CatchTabbedScreenBody.paged(
        controller: _tabController,
        pages: [
          CatchTabbedPageSpec.masterDetail(
            bodyLayout: CatchScreenBodyLayout.standard,
            expanded: screenSize.isExpanded,
            master: CatchTabbedPageScrollView(
              scrollKey: const PageStorageKey<String>('host-customers-people'),
              bodyLayout: CatchScreenBodyLayout.standard,
              constrainToContentWidth: true,
              slivers: [
                SliverList.list(
                  children: [
                    HostCustomersSummary(
                      summary: summary,
                      newCustomerCount: ref
                          .watch(
                            hostCustomerSegmentCountProvider(
                              HostCustomerSegmentCountRequest(
                                organizerId: selectedClub.id,
                                filter: HostCustomerFilter.newToOrganizer,
                              ),
                            ),
                          )
                          .asData
                          ?.value,
                      onRetry: () => ref.invalidate(
                        hostCrmSummaryProvider(selectedClub.id),
                      ),
                      selectedFilter:
                          _manualTag == null &&
                              const {
                                HostCustomerFilter.all,
                                HostCustomerFilter.repeat,
                                HostCustomerFilter.newToOrganizer,
                              }.contains(effectiveFilter)
                          ? effectiveFilter
                          : null,
                      onFilterSelected: (selectedFilter) => setState(() {
                        _filter =
                            selectedFilter == effectiveFilter &&
                                selectedFilter != HostCustomerFilter.all
                            ? HostCustomerFilter.all
                            : selectedFilter;
                        _manualTag = null;
                      }),
                    ),
                    gapH8,
                    const CatchDivider.section(),
                    directoryControls,
                    const CatchDivider.section(),
                    if (directoryState != null &&
                        (effectiveFilter != HostCustomerFilter.all ||
                            _manualTag != null ||
                            _search != null))
                      HostCustomerFilterSummary(
                        filter: effectiveFilter,
                        manualTag: _manualTag,
                        count: directoryState.matchCount,
                        countCoverage: directoryState.matchCountCoverage,
                        campaignBlocker: campaignBridgeBlocker,
                        onMessage:
                            campaignBridgePhase ==
                                    HostCustomerCampaignBridgePhase.ready &&
                                campaignAudienceDefinition != null
                            ? () => _saveAndMessageCustomers(
                                selectedClub,
                                effectiveFilter,
                                _manualTag,
                                campaignAudienceDefinition,
                              )
                            : null,
                        onReviewSenderSetup:
                            campaignBridgePhase ==
                                HostCustomerCampaignBridgePhase
                                    .senderSetupRequired
                            ? () => _reviewWhatsappSenderSetup(selectedClub)
                            : null,
                        onClear:
                            effectiveFilter == HostCustomerFilter.all &&
                                _manualTag == null
                            ? null
                            : () => setState(() {
                                _filter = HostCustomerFilter.all;
                                _manualTag = null;
                              }),
                      ),
                    CatchAsyncValueView<HostCustomersDirectoryState>(
                      value: directory,
                      onRetry: () => ref.invalidate(
                        hostCustomersDirectoryControllerProvider(request),
                      ),
                      initialLoadTimeout: null,
                      loadingBuilder: (_) => const CatchSkeletonRows(count: 5),
                      errorBuilder: (_, error, _) => CatchErrorState.fromError(
                        error,
                        context: AppErrorContext.customers,
                        mode: CatchErrorStateMode.compact,
                        onRetry: () => ref.invalidate(
                          hostCustomersDirectoryControllerProvider(request),
                        ),
                      ),
                      builder: (context, state) => HostCustomersDirectory(
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
                        onRefreshCoverage: () {
                          ref.invalidate(
                            hostCrmSummaryProvider(selectedClub.id),
                          );
                          ref.invalidate(
                            hostCustomersDirectoryControllerProvider(request),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            detail: _selectedContactId == null
                ? CatchEmptyState(
                    icon: CatchIcons.personSearchOutlined,
                    title: context.l10n.hostCustomersSelectCustomerTitle,
                    message: context.l10n.hostCustomersSelectCustomerBody,
                  )
                : HostCustomerDetailScreen(
                    organizerId: selectedClub.id,
                    contactId: _selectedContactId!,
                    initialDisplayName: _selectedContactDisplayName,
                    embedded: true,
                  ),
          ),
          CatchTabbedPageSpec.scroll(
            bodyLayout: CatchScreenBodyLayout.standard,
            page: HostSavedAudiencesWorkspace(
              organizerId: selectedClub.id,
              query: _audienceSearch,
              onCreate: () => _openAudienceEditor(selectedClub),
              onOpen: (audience) =>
                  _openAudienceEditor(selectedClub, audience: audience),
            ),
          ),
        ],
      ),
    );
  }

  List<CatchActionMenuItem<_HostCustomersHeaderAction>>
  _hostCustomersHeaderActions(
    BuildContext context, {
    required bool includeExport,
    required bool exportEnabled,
    String? exportSublabel,
  }) => [
    CatchActionMenuItem(
      value: _HostCustomersHeaderAction.reviewDuplicates,
      label: context.l10n.hostCustomersReviewDuplicates,
      icon: CatchIcons.peopleOutlineRounded,
    ),
    if (includeExport)
      CatchActionMenuItem(
        value: _HostCustomersHeaderAction.export,
        label: context.l10n.hostsHostAudienceExport,
        sublabel: exportSublabel,
        icon: CatchIcons.downloadRounded,
        enabled: exportEnabled,
      ),
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

  void _scheduleSearch(HostAudienceView view, String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      CatchMotion.searchDebounce,
      () => _applySearch(view, value),
    );
  }

  void _applySearch(HostAudienceView view, String value) {
    _searchDebounce?.cancel();
    final normalized = value.trim();
    final nextSearch = normalized.isEmpty ? null : normalized;
    if (!mounted) return;
    switch (view) {
      case HostAudienceView.people:
        if (_search == nextSearch) return;
        setState(() => _search = nextSearch);
      case HostAudienceView.audiences:
        if (_audienceSearch == nextSearch) return;
        setState(() => _audienceSearch = nextSearch);
      case HostAudienceView.forms:
      case HostAudienceView.responses:
        return;
    }
  }

  void _selectAudienceView(HostAudienceView view, String organizerId) {
    if (view == HostAudienceView.people || view == HostAudienceView.audiences) {
      _tabController.animateTo(view.index);
      return;
    }
    context.goNamed(
      Routes.hostAudienceScreen.name,
      queryParameters: {'view': view.name, 'organizerId': organizerId},
    );
  }

  Future<void> _openAudienceEditor(
    Club club, {
    HostSavedAudience? audience,
  }) async {
    final saved = await context.pushNamed<HostSavedAudience>(
      audience == null
          ? Routes.hostCreateSavedAudienceScreen.name
          : Routes.hostSavedAudienceDetailScreen.name,
      pathParameters: audience == null
          ? const {}
          : {'audienceId': audience.audienceId},
      queryParameters: {'organizerId': club.id},
      extra: audience,
    );
    if (!mounted || saved == null) return;
    ref.invalidate(hostSavedAudiencesProvider(club.id));
    ref.invalidate(hostAllSavedAudiencesProvider(club.id));
  }

  Future<void> _openFilters(
    HostCustomerFilter activeFilter,
    HostCustomerManualTag? activeManualTag,
    HostCustomersDirectoryState directory,
    HostCrmChannelReadiness? smsReadiness,
  ) async {
    final selected = await showCatchBottomSheet<HostCustomerFilterSelection>(
      context: context,
      builder: (_) => HostCustomerFilterSheet(
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

  Future<void> _saveAndMessageCustomers(
    Club club,
    HostCustomerFilter filter,
    HostCustomerManualTag? manualTag,
    HostSavedAudienceDefinition definition,
  ) async {
    final label = manualTag?.label ?? _customerFilterLabel(context, filter);
    final audience = await showCatchBottomSheet<HostSavedAudience>(
      context: context,
      builder: (_) => HostSaveAudienceSheet(
        organizerId: club.id,
        suggestedName: label,
        definition: definition,
      ),
    );
    if (!mounted || audience == null) return;
    context.goNamed(
      Routes.hostInboxScreen.name,
      queryParameters: {
        'workspace': HostMessagingWorkspace.campaigns.name,
        'compose': '1',
        'audienceId': audience.audienceId,
      },
      extra: club,
    );
  }

  void _reviewWhatsappSenderSetup(Club club) => context.pushNamed(
    Routes.hostOrganizerMessagingScreen.name,
    pathParameters: {'clubId': club.id},
  );

  Future<void> _addCustomer(
    Club club,
    HostCustomersDirectoryRequest request,
  ) async {
    final created = await context.pushNamed<HostCreatedCustomer>(
      Routes.hostAddCustomerScreen.name,
      queryParameters: {'organizerId': club.id},
    );
    if (!mounted || created == null) return;
    ref.invalidate(hostCrmSummaryProvider(club.id));
    ref.invalidate(hostCustomersDirectoryControllerProvider(request));
    _openCustomerById(
      club,
      created.contactId,
      displayName: created.displayName,
    );
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
          errorContext: AppErrorContext.customer,
        );
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  void _openCustomer(Club club, HostCustomerDirectoryContact contact) =>
      _openCustomerById(
        club,
        contact.contactId,
        displayName: contact.displayName,
      );

  void _openCustomerById(
    Club club,
    String contactId, {
    required String displayName,
  }) {
    if (ScreenSize.fromWidth(MediaQuery.sizeOf(context).width).isExpanded) {
      setState(() {
        _selectedContactId = contactId;
        _selectedContactDisplayName = displayName;
      });
      context.goNamed(
        Routes.hostAudienceScreen.name,
        queryParameters: {'organizerId': club.id, 'contactId': contactId},
        extra: HostCustomerDetailRouteArguments(displayName: displayName),
      );
      return;
    }
    context.pushNamed(
      Routes.hostCustomerDetailScreen.name,
      pathParameters: {'contactId': contactId},
      queryParameters: {'organizerId': club.id},
      extra: HostCustomerDetailRouteArguments(displayName: displayName),
    );
  }
}
