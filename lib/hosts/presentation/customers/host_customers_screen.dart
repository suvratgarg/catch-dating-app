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
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_master_detail_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_meta_row.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_selection_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_contact_merge_review.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_detail_route_arguments.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customer_detail_screen.dart';
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

part 'host_customer_detail_cards.dart';
part 'host_customer_editor_sheets.dart';
part 'host_customers_directory.dart';

enum _HostCustomersHeaderAction { applications, reviewDuplicates, export }

class HostCustomersScreen extends ConsumerStatefulWidget {
  const HostCustomersScreen({
    super.key,
    this.initialOrganizerId,
    this.initialContactId,
    this.initialContactDisplayName,
  });

  final String? initialOrganizerId;
  final String? initialContactId;
  final String? initialContactDisplayName;

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
  bool _searchExpanded = false;
  String? _selectedContactId;
  String? _selectedContactDisplayName;

  @override
  void initState() {
    super.initState();
    _selectedContactId = widget.initialContactId;
    _selectedContactDisplayName = widget.initialContactDisplayName;
  }

  @override
  void didUpdateWidget(covariant HostCustomersScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uidAsync = ref.watch(uidProvider);
    final uidState = catchAsyncStateFromAsyncValue(uidAsync);
    final uid = uidState.value;
    if (uidState.hasError) {
      return CatchErrorScaffold.fromError(
        uidState.error!,
        context: AppErrorContext.auth,
        onRetry: () => ref.invalidate(uidProvider),
      );
    }
    if (uidState.isLoading) {
      return HostLoadingScreen(title: context.l10n.hostNavigationCustomers);
    }
    if (uid == null) return const HostAuthRequiredScreen();

    final clubsAsync = ref.watch(hostOperableClubsProvider(uid));
    final clubsState = catchAsyncStateFromAsyncValue(clubsAsync);
    if (clubsState.hasError) {
      return CatchErrorScaffold.fromError(
        clubsState.error!,
        context: AppErrorContext.club,
        onRetry: () => ref.invalidate(hostOperableClubsProvider(uid)),
      );
    }
    if (clubsState.isLoading) {
      return HostLoadingScreen(title: context.l10n.hostNavigationCustomers);
    }
    final clubs = clubsState.value ?? const <Club>[];
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
    final directory = ref.watch(
      hostCustomersDirectoryControllerProvider(request),
    );
    final activeSegment = hostAudienceSegmentForCustomerFilter(effectiveFilter);
    final t = CatchTokens.of(context);
    final screenSize = ScreenSize.fromWidth(MediaQuery.sizeOf(context).width);
    final headerActions = [
      CatchTopBarPrimaryAction(
        key: const ValueKey<String>('host-customers-add-customer'),
        label: context.l10n.hostCustomersAdd,
        icon: CatchIcons.personAddAlt1Rounded,
        onPressed: () => _addCustomer(selectedClub, request),
      ),
      CatchTopBarMenuAction<_HostCustomersHeaderAction>(
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
          if (action == _HostCustomersHeaderAction.applications) {
            unawaited(
              context.pushNamed(
                Routes.hostApplicationsScreen.name,
                queryParameters: {'organizerId': selectedClub.id},
              ),
            );
          }
          if (action == _HostCustomersHeaderAction.export) {
            unawaited(_exportCustomers(selectedClub, effectiveFilter));
          }
        },
      ),
    ];

    return Scaffold(
      backgroundColor: t.bg,
      appBar: CatchScreenTopBar(
        context: context,
        title: context.l10n.hostNavigationCustomers,
        leadingType: CatchTopBarLeading.none,
        actions: headerActions,
        search: CatchTopBarSearch(
          fieldKey: const ValueKey('host-customers-search'),
          value: _search ?? '',
          contract: CatchContractConstraints
              .listOrganizerContactsCallablePayloadQuery,
          placeholder: context.l10n.hostsHostAudienceSearch,
          tooltip: context.l10n.hostsHostAudienceSearch,
          semanticLabel: context.l10n.hostsHostAudienceSearch,
          expanded: _searchExpanded || _search != null,
          onExpandedChanged: (expanded) {
            if (_searchExpanded == expanded) return;
            setState(() => _searchExpanded = expanded);
          },
          onChanged: _scheduleSearch,
          onSubmitted: _applySearch,
          onFocusChanged: (focused) {
            if (!focused && _search == null && _searchExpanded) {
              setState(() => _searchExpanded = false);
            }
          },
          textInputAction: TextInputAction.search,
        ),
      ),
      body: CatchMasterDetailLayout(
        expanded: screenSize.isExpanded,
        master: SafeArea(
          top: false,
          bottom: false,
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: CatchInsets.pageHorizontal,
                sliver: SliverList.list(
                  children: [
                    HostCustomersSummary(
                      summary: summary,
                      onRetry: () => ref.invalidate(
                        hostCrmSummaryProvider(selectedClub.id),
                      ),
                    ),
                    gapH16,
                    HostCustomerDirectorySortControl(
                      sort: _sort,
                      onSortChanged: (sort) => setState(() => _sort = sort),
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
                        context: AppErrorContext.customers,
                        mode: CatchErrorStateMode.compact,
                        onRetry: () => ref.invalidate(
                          hostCustomersDirectoryControllerProvider(request),
                        ),
                      ),
                      builder: (context, state) {
                        final campaignBridgeBlocker = hostCampaignBridgeBlocker(
                          segment: activeSegment,
                          smsReadiness: summaryState.value?.smsReadiness,
                          messagingSetup: messagingSetupState.value,
                          audienceCoverageComplete:
                              state.sourceCoverage ==
                              HostCustomerDirectoryCoverage.exact,
                        );
                        return Column(
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
                                effectiveFilter,
                                _manualTag,
                                state,
                                summaryState.value?.smsReadiness,
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
                              onRefreshCoverage: () {
                                ref.invalidate(
                                  hostCrmSummaryProvider(selectedClub.id),
                                );
                                ref.invalidate(
                                  hostCustomersDirectoryControllerProvider(
                                    request,
                                  ),
                                );
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    const CatchScrollTerminalPadding(),
                  ],
                ),
              ),
            ],
          ),
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
      value: _HostCustomersHeaderAction.applications,
      label: context.l10n.hostApplicationsOpen,
      icon: CatchIcons.factCheckOutlined,
    ),
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
        Routes.hostCustomersScreen.name,
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
