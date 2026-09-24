import 'dart:async';
import 'dart:convert';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/country_markets.dart';
import 'package:catch_dating_app/core/external_share.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_error_snack_bar.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_sliver_error_state.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/hosts/data/crm/host_contacts_repository.dart';
import 'package:catch_dating_app/hosts/data/crm/host_saved_audience_repository.dart';
import 'package:catch_dating_app/hosts/data/crm/host_whatsapp_repository.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_audience_contact.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_audience_contact_detail.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_audience_query.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_campaign_policy.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_crm_summary.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_customer_revenue.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_messaging_setup.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience_definition.dart';
import 'package:catch_dating_app/hosts/domain/crm/host_saved_audience_filter_options.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_contact_merge_review.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_detail_route_arguments.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_detail_screen.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_row.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_saved_audience_members_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_controller.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_no_organizer_empty_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_audience_view.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_campaign_composer.dart';
import 'package:catch_dating_app/hosts/presentation/inbox/host_inbox_screen.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

part 'host_customer_detail_cards.dart';
part 'host_customer_editor.dart';
part 'host_customer_editor_sheets.dart';
part 'host_customer_filter_sheet.dart';
part 'host_customers_directory.dart';
part 'host_saved_audience_editor.dart';
part 'host_saved_audience_rule_draft.dart';
part 'host_static_audience_members_editor.dart';
part 'host_saved_audience_source_rules.dart';
part 'host_saved_audience_overview.dart';
part 'host_saved_audiences_workspace.dart';

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
  Set<HostCustomerFilter> _filters = const {};
  List<HostCustomerManualTag> _manualTags = const [];
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
          CatchLocalizedSliverErrorState(
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
        slivers: const [CatchStateViewport.sliverLoading()],
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
          CatchLocalizedSliverErrorState(
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
        slivers: const [CatchStateViewport.sliverLoading()],
      );
    }
    final clubs = clubsState.value ?? const <Club>[];
    if (clubs.isEmpty) {
      return HostAudienceNoOrganizerEmptyState(selected: _view);
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
    final effectiveFilters = _filters.intersection(visibleFilters.toSet());
    final effectiveFilter = effectiveFilters.length == 1
        ? effectiveFilters.single
        : HostCustomerFilter.all;
    final selectionLabel = _customerSelectionLabel(
      context,
      effectiveFilters,
      _manualTags,
    );
    final request = HostCustomersDirectoryRequest(
      organizerId: selectedClub.id,
      search: _search,
      filters: effectiveFilters,
      manualTagIds: {for (final tag in _manualTags) tag.tagId},
      sort: _sort,
    );
    final directory = peopleView
        ? ref.watch(hostCustomersDirectoryControllerProvider(request))
        : const AsyncLoading<HostCustomersDirectoryState>();
    final directoryState = catchAsyncStateFromAsyncValue(directory).value;
    final campaignAudienceDefinition =
        hostSavedAudienceDefinitionForCustomerSelection(
          filters: effectiveFilters,
          manualTags: _manualTags,
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
    return CatchViewport.box(
      builder: (context, viewport) {
        final screenSize = viewport.sizeClass;
        final activeQuery = peopleView ? _search : _audienceSearch;
        final directoryControls = HostCustomerDirectoryControls(
          sort: _sort,
          activeFilters: effectiveFilters.isEmpty && _manualTags.isEmpty
              ? null
              : selectionLabel,
          onClear: effectiveFilters.isEmpty && _manualTags.isEmpty
              ? null
              : () => setState(() {
                  _filters = {};
                  _manualTags = [];
                }),
          shrinkWrap: true,
          condensed: screenSize.isCompact || screenSize.isExpanded,
          onSortChanged: (sort) => setState(() => _sort = sort),
          onOpenFilters: directoryState == null
              ? null
              : () => _openFilters(
                  effectiveFilters,
                  _manualTags,
                  directoryState,
                  summaryState.value?.smsReadiness,
                ),
        );
        return CatchRootScreenScaffold.withPrimaryRail(
          header: CatchRootScreenHeader.custom(
            HostAudienceHeader(
              organizerId: selectedClub.id,
              primaryAction: peopleView
                  ? CatchTopBarPrimaryButton(
                      key: const ValueKey<String>(
                        'host-customers-add-customer',
                      ),
                      label: context.l10n.hostCustomersAdd,
                      icon: CatchIcons.personAddAlt1Rounded,
                      onPressed: () => _addCustomer(selectedClub, request),
                    )
                  : CatchTopBarPrimaryButton(
                      key: const ValueKey('host-saved-audience-create'),
                      label: context.l10n.hostSavedAudienceNew,
                      icon: CatchIcons.add,
                      onPressed: () => _openAudienceEditor(selectedClub),
                    ),
              menuItems: peopleView
                  ? _hostCustomersHeaderActions(
                      context,
                      includeExport: !_exporting,
                      exportEnabled: true,
                    )
                  : const [],
              onMenuAction: (action) {
                if (action == HostAudienceMenuAction.reviewDuplicates) {
                  unawaited(_reviewDuplicates(selectedClub.id));
                }
                if (action == HostAudienceMenuAction.export) {
                  unawaited(_exportCustomers(selectedClub, effectiveFilters));
                }
              },
              search: CatchTopBarSearch(
                copy: catchSearchFieldCopy(context.l10n),
                fieldKey: ValueKey(
                  peopleView
                      ? 'host-customers-search'
                      : 'host-audiences-search',
                ),
                value: activeQuery ?? '',
                contract: peopleView
                    ? CatchContractConstraints
                          .listOrganizerContactsCallablePayloadQuery
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
            ),
          ),
          actions: HostAudienceTabRail(
            selected: _view,
            selectionAnimation: _tabController.animation!,
            onChanged: (view) => _selectAudienceView(view, selectedClub.id),
          ),
          body: CatchRootScreenBody.paged(
            controller: _tabController,
            pages: [
              CatchRootScreenPageSpec.masterDetail(
                expanded: screenSize.isExpanded,
                master: CatchRootScreenPageScrollView.sections(
                  scrollKey: const PageStorageKey<String>(
                    'host-customers-people',
                  ),
                  children: [
                    SliverToBoxAdapter(
                      child: CatchSection.content(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            HostCustomersSummary(
                              summary: summary,
                              newCustomerCount: ref
                                  .watch(
                                    hostCustomerSegmentCountProvider(
                                      HostCustomerSegmentCountRequest(
                                        organizerId: selectedClub.id,
                                        filter:
                                            HostCustomerFilter.newToOrganizer,
                                      ),
                                    ),
                                  )
                                  .when(
                                    data: (value) => value,
                                    loading: () => null,
                                    error: (_, _) => null,
                                  ),
                              onRetry: () => ref.invalidate(
                                hostCrmSummaryProvider(selectedClub.id),
                              ),
                              selectedFilter:
                                  _manualTags.isEmpty &&
                                      effectiveFilters.length <= 1 &&
                                      const {
                                        HostCustomerFilter.all,
                                        HostCustomerFilter.repeat,
                                        HostCustomerFilter.newToOrganizer,
                                      }.contains(effectiveFilter)
                                  ? effectiveFilter
                                  : null,
                              onFilterSelected: (selectedFilter) =>
                                  setState(() {
                                    _filters =
                                        selectedFilter ==
                                                HostCustomerFilter.all ||
                                            (effectiveFilters.length == 1 &&
                                                effectiveFilters.contains(
                                                  selectedFilter,
                                                ))
                                        ? {}
                                        : {selectedFilter};
                                    _manualTags = [];
                                  }),
                            ),
                            gapH16,
                          ],
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(child: directoryControls),
                    if (directoryState != null &&
                        (effectiveFilters.isNotEmpty ||
                            _manualTags.isNotEmpty ||
                            _search != null))
                      CatchPageBody.sliver(
                        child: SliverList.list(
                          children: [
                            HostCustomerFilterSummary(
                              filter: effectiveFilter,
                              selectionLabel: selectionLabel,
                              count: directoryState.matchCount,
                              countCoverage: directoryState.matchCountCoverage,
                              campaignBlocker: campaignBridgeBlocker,
                              onMessage:
                                  campaignBridgePhase ==
                                          HostCustomerCampaignBridgePhase
                                              .ready &&
                                      campaignAudienceDefinition != null
                                  ? () => _saveAndMessageCustomers(
                                      selectedClub,
                                      selectionLabel,
                                      campaignAudienceDefinition,
                                    )
                                  : null,
                              onReviewSenderSetup:
                                  campaignBridgePhase ==
                                      HostCustomerCampaignBridgePhase
                                          .senderSetupRequired
                                  ? () =>
                                        _reviewWhatsappSenderSetup(selectedClub)
                                  : null,
                            ),
                          ],
                        ),
                      ),
                    CatchAsyncBoundary<HostCustomersDirectoryState>.sliver(
                      value: directory,
                      onRetry: () => ref.invalidate(
                        hostCustomersDirectoryControllerProvider(request),
                      ),
                      initialLoadTimeout: null,
                      loadingBuilder: (_) => CatchSection.sliverLoadingRows(
                        itemCount: 5,
                        layoutBuilder: (_, _) =>
                            const CatchPersonLayout.placeholder(
                              hasSupportingText: true,
                              hasBadge: true,
                            ),
                      ),
                      errorBuilder: (_, error, _, onBoundaryRetry) =>
                          CatchLocalizedSliverErrorState(
                            error,
                            context: AppErrorContext.customers,
                            onRetry: onBoundaryRetry,
                          ),
                      builder: (context, state) => HostCustomersDirectory(
                        state: state,
                        selectedContactId: screenSize.isExpanded
                            ? _selectedContactId
                            : null,
                        hasActiveQuery:
                            _search != null ||
                            effectiveFilters.isNotEmpty ||
                            _manualTags.isNotEmpty,
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
              CatchRootScreenPageSpec.scroll(
                page: HostSavedAudiencesWorkspace(
                  organizerId: selectedClub.id,
                  query: _audienceSearch,

                  onOpen: (audience) =>
                      _openAudienceEditor(selectedClub, audience: audience),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

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
    Set<HostCustomerFilter> activeFilters,
    List<HostCustomerManualTag> activeManualTags,
    HostCustomersDirectoryState directory,
    HostCrmChannelReadiness? smsReadiness,
  ) async {
    await showCatchBottomSheet<HostCustomerFilterSelection>(
      context: context,
      builder: (_) => HostCustomerFilterSheet(
        selectedFilters: activeFilters,
        selectedManualTags: activeManualTags,
        manualTagVocabulary: directory.manualTagVocabulary,
        smsReadiness: smsReadiness,
        onChanged: (selection) {
          if (!mounted) return;
          setState(() {
            _filters = selection.allFilters;
            _manualTags = selection.allManualTags;
          });
        },
      ),
    );
  }

  Future<void> _saveAndMessageCustomers(
    Club club,
    String label,
    HostSavedAudienceDefinition definition,
  ) async {
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

  Future<void> _exportCustomers(
    Club club,
    Set<HostCustomerFilter> filters,
  ) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final export = await ref
          .read(hostCustomersControllerProvider)
          .exportCustomers(
            organizerId: club.id,
            query: HostAudienceQuery(
              search: _search,
              segments: {
                for (final filter in filters)
                  ?hostAudienceSegmentForCustomerFilter(filter),
              },
              manualTagIds: {for (final tag in _manualTags) tag.tagId},
            ),
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
    if (CatchWindowSize.fromWidth(
      (context.findRenderObject()! as RenderBox).size.width,
    ).isExpanded) {
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
