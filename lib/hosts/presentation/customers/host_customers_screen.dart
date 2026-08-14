import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_share.dart';
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
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_stat_column.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_controller.dart';
import 'package:catch_dating_app/hosts/presentation/customers/host_customers_screen_state.dart';
import 'package:catch_dating_app/hosts/presentation/host_operations_screen.dart';
import 'package:catch_dating_app/hosts/presentation/host_organizer_selection_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HostCustomersScreen extends ConsumerStatefulWidget {
  const HostCustomersScreen({super.key, this.initialOrganizerId});

  final String? initialOrganizerId;

  @override
  ConsumerState<HostCustomersScreen> createState() =>
      _HostCustomersScreenState();
}

class _HostCustomersScreenState extends ConsumerState<HostCustomersScreen> {
  final _searchController = TextEditingController();
  String? _search;
  HostCustomerFilter _filter = HostCustomerFilter.all;
  bool _exporting = false;

  @override
  void dispose() {
    _searchController.dispose();
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
    final request = HostCustomersDirectoryRequest(
      organizerId: selectedClub.id,
      search: _search,
      filter: _filter,
    );
    final directory = ref.watch(
      hostCustomersDirectoryControllerProvider(request),
    );
    final summary = ref.watch(hostCrmSummaryProvider(selectedClub.id));
    final t = CatchTokens.of(context);

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
                  CatchButton(
                    key: const ValueKey<String>('host-customers-add-customer'),
                    label: context.l10n.hostCustomersAdd,
                    icon: Icon(
                      CatchIcons.personAddAlt1Rounded,
                      size: CatchIcon.sm,
                    ),
                    size: CatchButtonSize.sm,
                    onPressed: () => _addCustomer(selectedClub, request),
                  ),
                ],
              ),
            ),
            SliverPadding(
              padding: CatchInsets.pageHorizontal,
              sliver: SliverList.list(
                children: [
                  Text(
                    context.l10n.hostCustomersIntro,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                  gapH16,
                  HostCustomersSummary(
                    summary: summary,
                    onRetry: () =>
                        ref.invalidate(hostCrmSummaryProvider(selectedClub.id)),
                  ),
                  gapH16,
                  Wrap(
                    spacing: CatchSpacing.s2,
                    runSpacing: CatchSpacing.s2,
                    children: [
                      CatchButton(
                        label: context.l10n.hostsHostAudienceExport,
                        icon: Icon(CatchIcons.downloadRounded),
                        variant: CatchButtonVariant.secondary,
                        size: CatchButtonSize.sm,
                        isLoading: _exporting,
                        onPressed: _exporting
                            ? null
                            : () => _exportCustomers(selectedClub),
                      ),
                    ],
                  ),
                  gapH20,
                  CatchFieldLanes.single(
                    child: CatchField.input(
                      title: context.l10n.hostsHostAudienceSearch,
                      contract: CatchContractConstraints
                          .listOrganizerContactsCallablePayloadQuery,
                      controller: _searchController,
                      textInputAction: TextInputAction.search,
                      prefixIcon: Icon(CatchIcons.searchRounded),
                      showClearButton: true,
                      onSubmitted: (value) => setState(() {
                        final normalized = value.trim();
                        _search = normalized.isEmpty ? null : normalized;
                      }),
                    ),
                  ),
                  gapH16,
                  Text(
                    context.l10n.hostCustomersFilterByTag,
                    style: CatchTextStyles.fieldRowTitle(context),
                  ),
                  gapH8,
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final filter in HostCustomerFilter.values) ...[
                          if (filter != HostCustomerFilter.values.first) gapW8,
                          CatchChip.selectable(
                            label: _customerFilterLabel(context, filter),
                            selected: _filter == filter,
                            contractExemption:
                                'Customer filters map to reviewed CRM segments.',
                            onChanged: (_) => setState(() => _filter = filter),
                          ),
                        ],
                      ],
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
                    builder: (context, state) => HostCustomersDirectory(
                      state: state,
                      filter: _filter,
                      hasActiveQuery:
                          _search != null || _filter != HostCustomerFilter.all,
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

  Future<void> _exportCustomers(Club club) async {
    if (_exporting) return;
    setState(() => _exporting = true);
    try {
      final export = await ref
          .read(hostCustomersControllerProvider)
          .exportCustomers(
            organizerId: club.id,
            segment: hostAudienceSegmentForCustomerFilter(_filter),
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

class HostCustomersDirectory extends StatelessWidget {
  const HostCustomersDirectory({
    super.key,
    required this.state,
    required this.filter,
    required this.hasActiveQuery,
    required this.onCustomerSelected,
    required this.onLoadMore,
  });

  final HostCustomersDirectoryState state;
  final HostCustomerFilter filter;
  final bool hasActiveQuery;
  final ValueChanged<HostCustomerDirectoryContact> onCustomerSelected;
  final VoidCallback? onLoadMore;

  @override
  Widget build(BuildContext context) {
    final contacts = filter == HostCustomerFilter.attended
        ? state.contacts
              .where((contact) => contact.attendedEventCount > 0)
              .toList(growable: false)
        : state.contacts;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.sourceCoverage != HostCustomerDirectoryCoverage.exact) ...[
          CatchNotice(
            notice: CatchNoticeData(
              id: 'host.customers.coverage',
              title: context.l10n.hostsHostAudienceCoveragePartial,
              message: context.l10n.hostsHostAudienceCoveragePartialBody,
              tone: CatchNoticeTone.warning,
            ),
          ),
          gapH12,
        ],
        if (contacts.isEmpty)
          CatchEmptyState(
            icon: CatchIcons.peopleOutlineRounded,
            title: hasActiveQuery
                ? context.l10n.hostCustomersNoResults
                : context.l10n.hostCustomersEmpty,
            message: hasActiveQuery
                ? null
                : context.l10n.hostCustomersEmptyBody,
            layout: CatchEmptyStateLayout.inline,
          )
        else
          CatchFieldLanes.single(
            child: Column(
              children: [
                for (final (index, contact) in contacts.indexed)
                  HostCustomerDirectoryRow(
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

class HostCustomerDirectoryRow extends StatelessWidget {
  const HostCustomerDirectoryRow({
    super.key,
    required this.contact,
    required this.divider,
    required this.onTap,
  });

  final HostCustomerDirectoryContact contact;
  final bool divider;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final metadata = <String>[
      context.l10n.hostsHostAudienceEventsAttended(
        count: contact.attendedEventCount,
      ),
      if (contact.lastAttendedAt != null)
        context.l10n.hostsHostAudienceLastSeen(
          date: AppTimeFormatters.shortDate(contact.lastAttendedAt!),
        ),
      if (contact.whatsappOptedIn)
        context.l10n.hostsHostAudienceWhatsappOptedIn,
      if (contact.whatsappAdminSuppressed)
        context.l10n.hostsHostAudienceContactConsentPaused,
    ];
    return CatchFieldLanes.single(
      child: CatchField.nav(
        title: contact.displayName,
        body: metadata.join(' · '),
        valueText: _preferredCustomerTag(context, contact.tags),
        leading: CatchPersonAvatar(
          size: CatchSpacing.s7,
          name: contact.displayName,
        ),
        leadingExtent: CatchSpacing.s7,
        valid: !contact.hasAmbiguousIdentity,
        divider: divider,
        onTap: onTap,
      ),
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
  final _nameController = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: context.l10n.hostCustomersAddTitle,
    subtitle: context.l10n.hostCustomersAddHelp,
    child: CatchFieldLanes.custom(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchField.input(
            title: context.l10n.hostCustomersName,
            contract: CatchContractConstraints
                .createOrganizerContactCallablePayloadDisplayName,
            controller: _nameController,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => unawaited(_submit()),
          ),
          gapH12,
          CatchButton(
            label: context.l10n.hostCustomersAdd,
            isLoading: _saving,
            onPressed: _saving ? null : _submit,
          ),
        ],
      ),
    ),
  );

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (_saving || name.isEmpty) return;
    setState(() => _saving = true);
    try {
      final customer = await ref
          .read(hostCustomersControllerProvider)
          .createCustomer(organizerId: widget.organizerId, displayName: name);
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
  late final TextEditingController _nameController = TextEditingController(
    text:
        widget.customer.displayNameOverride ??
        widget.customer.sourceDisplayName,
  );
  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: widget.customer.displayName,
    subtitle: context.l10n.hostsHostAudienceContactSubtitle,
    child: SingleChildScrollView(
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
            ),
            gapH8,
            CatchButton(
              label: context.l10n.hostsHostAudienceContactSaveName,
              size: CatchButtonSize.sm,
              isLoading: _saving,
              onPressed: _saving ? null : _saveName,
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
  );

  Future<void> _saveName() async {
    final value = _nameController.text.trim();
    if (value.isEmpty) return;
    await _mutate(
      displayNameOverride: value == widget.customer.sourceDisplayName
          ? null
          : value,
      clearDisplayNameOverride: value == widget.customer.sourceDisplayName,
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
  const HostCustomerIdentityCard({super.key, required this.customer});

  final HostAudienceContactDetail customer;

  @override
  Widget build(BuildContext context) => CatchSection.divided(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CatchPersonAvatar(
              size: CatchSpacing.s9,
              name: customer.displayName,
            ),
            gapW12,
            Expanded(
              child: Text(
                customer.displayName,
                style: CatchTextStyles.sectionTitle(context),
              ),
            ),
          ],
        ),
        if (customer.phoneE164 != null || customer.email != null) ...[
          gapH12,
          CatchFieldLanes.single(
            child: Column(
              children: [
                if (customer.phoneE164 != null)
                  CatchField.read(
                    title: context.l10n.hostsHostAudienceContactVerifiedPhone,
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
  });

  final HostAudienceContactDetail customer;
  final bool loading;
  final VoidCallback? onOpen;

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
                    CatchField.read(
                      title: event.displayName,
                      body: event.eventStartAt == null
                          ? event.source
                          : '${AppTimeFormatters.shortDate(event.eventStartAt!)} · ${event.source}',
                      valueText: event.checkedIn
                          ? context.l10n.hostCustomersCheckedIn
                          : event.status,
                      divider: index < events.length - 1,
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
    builder: (context, value) => CatchSurface(
      padding: CatchInsets.cardContent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
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
              Expanded(
                child: CatchStatColumn(
                  value: '${value.whatsappOptInCount}',
                  label: context.l10n.hostsHostAudienceWhatsappReady,
                  monoValue: true,
                  highlight: true,
                ),
              ),
            ],
          ),
          gapH12,
          Text(
            context.l10n.hostsHostAudienceSources(
              importedCount: value.importedContactCount,
              linkedCount: value.linkedAccountCount,
            ),
            style: CatchTextStyles.supporting(
              context,
              color: CatchTokens.of(context).ink2,
            ),
          ),
        ],
      ),
    ),
  );
}

String _customerFilterLabel(
  BuildContext context,
  HostCustomerFilter filter,
) => switch (filter) {
  HostCustomerFilter.all => context.l10n.hostsHostAudienceAll,
  HostCustomerFilter.attended => context.l10n.hostCustomersFilterAttended,
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

String? _preferredCustomerTag(BuildContext context, Set<HostCustomerTag> tags) {
  if (tags.contains(HostCustomerTag.highImpactAdvocate)) {
    return context.l10n.hostsHostAudienceSegmentHighImpact;
  }
  if (tags.contains(HostCustomerTag.atRisk)) {
    return context.l10n.hostCustomersFilterAtRisk;
  }
  if (tags.contains(HostCustomerTag.needsConfirmation)) {
    return context.l10n.hostsHostAudienceSegmentNeedsConfirmation;
  }
  if (tags.contains(HostCustomerTag.regular)) {
    return context.l10n.hostsHostAudienceSegmentRegular;
  }
  if (tags.contains(HostCustomerTag.reliable)) {
    return context.l10n.hostsHostAudienceSegmentReliable;
  }
  if (tags.contains(HostCustomerTag.repeat)) {
    return context.l10n.hostsHostAudienceSegmentRepeat;
  }
  if (tags.contains(HostCustomerTag.firstTime)) {
    return context.l10n.hostsHostAudienceSegmentFirstTime;
  }
  if (tags.contains(HostCustomerTag.newToOrganizer)) {
    return context.l10n.hostsHostAudienceSegmentNew;
  }
  if (tags.contains(HostCustomerTag.advocate)) {
    return context.l10n.hostsHostAudienceSegmentAdvocate;
  }
  if (tags.contains(HostCustomerTag.whatsappReachable)) {
    return context.l10n.hostsHostAudienceSegmentWhatsapp;
  }
  if (tags.contains(HostCustomerTag.smsReachable)) {
    return context.l10n.hostsHostAudienceSegmentSms;
  }
  return null;
}
