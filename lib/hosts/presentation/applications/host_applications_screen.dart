import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_notice.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_search_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_selection_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/data/host_application_repository.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_application_import.dart';
import 'package:catch_dating_app/hosts/domain/host_roster_import.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_application_context.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_applications_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

part 'host_application_detail_screen.dart';

class HostApplicationsScreen extends ConsumerStatefulWidget {
  const HostApplicationsScreen({
    super.key,
    required this.organizerId,
    this.formId,
    this.contactId,
  });

  final String organizerId;
  final String? formId;
  final String? contactId;

  @override
  ConsumerState<HostApplicationsScreen> createState() =>
      _HostApplicationsScreenState();
}

class _HostApplicationsScreenState
    extends ConsumerState<HostApplicationsScreen> {
  String? _query;
  HostApplicationReviewStatus? _status;
  HostApplicationSort _sort = HostApplicationSort.newest;
  bool _importing = false;

  @override
  Widget build(BuildContext context) {
    final sourcesProvider = hostSavedAudienceFilterOptionsProvider(
      widget.organizerId,
    );
    final sources = catchAsyncStateFromAsyncValue(ref.watch(sourcesProvider));
    final request = HostApplicationListRequest(
      organizerId: widget.organizerId,
      formId: widget.formId,
      contactId: widget.contactId,
      reviewStatus: _status,
      query: _query,
      sort: _sort,
    );
    final directory = ref.watch(
      hostApplicationsDirectoryControllerProvider(request),
    );
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: context.l10n.hostApplicationsTitle,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
        actions: [
          CatchAdaptiveSelectionMenu<HostApplicationSort>(
            title: context.l10n.hostApplicationsSort,
            value: _sort,
            items: [
              for (final sort in HostApplicationSort.values)
                CatchSelectionMenuItem(
                  value: sort,
                  label: _sortLabel(context, sort),
                ),
            ],
            onSelected: (sort) => setState(() => _sort = sort),
            builder: (context, selected, open, toggle) => CatchIconButton.icon(
              icon: CatchIcons.sort,
              tooltip: context.l10n.hostApplicationsSort,
              active: open,
              onTap: toggle,
            ),
          ),
        ],
      ),
      body: CatchRouteBody.standardViewport(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.formId case final formId?) ...[
              Text(
                hostApplicationFormScopeLabel(context, formId, sources.value),
                style: CatchTextStyles.recordTitle(context),
              ),
              gapH16,
            ],
            if (sources.isTerminalError) ...[
              CatchButton.command(
                label: context.l10n.hostAudienceRetrySourceNames,
                onPressed: () => ref.invalidate(sourcesProvider),
              ),
              gapH12,
            ],
            CatchOptionGroup<String>(
              options: [
                CatchOption(
                  value: 'all',
                  label: context.l10n.hostAudienceApplicationsAll,
                ),
                CatchOption(
                  value: 'submitted',
                  label: context.l10n.hostAudienceApplicationsNew,
                ),
                CatchOption(
                  value: 'inReview',
                  label: context.l10n.hostApplicationsStatusInReview,
                ),
              ],
              selected: _status == null
                  ? 'all'
                  : const [
                      HostApplicationReviewStatus.submitted,
                      HostApplicationReviewStatus.inReview,
                    ].contains(_status)
                  ? _status!.name
                  : null,
              variant: CatchOptionGroupVariant.summary,
              contractExemption:
                  'Local application review lens; status is passed to the governed request.',
              onChanged: (value) => setState(
                () => _status = value == 'all'
                    ? null
                    : HostApplicationReviewStatus.values.byName(value),
              ),
            ),
            gapH16,
            CatchSearchField.expanded(
              key: const ValueKey('host-applications-search'),
              value: _query ?? '',
              contract: CatchContractConstraints
                  .listOrganizerApplicationsCallablePayloadQuery,
              placeholder: context.l10n.hostApplicationsSearch,
              semanticLabel: context.l10n.hostApplicationsSearch,
              textInputAction: TextInputAction.search,
              onChanged: (value) => setState(
                () => _query = value.trim().isEmpty ? null : value.trim(),
              ),
              onSubmitted: (value) => setState(
                () => _query = value.trim().isEmpty ? null : value.trim(),
              ),
            ),
            gapH12,
            CatchButton.command(
              key: const ValueKey('host-applications-review-status'),
              label: _status == null
                  ? context.l10n.hostApplicationsReviewStatusFilter
                  : hostApplicationStatusLabel(context, _status!),
              icon: Icon(CatchIcons.tune),
              onPressed: _chooseStatus,
            ),
            gapH16,
            Expanded(
              child: CatchAsyncValueView<HostApplicationsDirectoryState>(
                value: directory,
                onRetry: () => ref.invalidate(
                  hostApplicationsDirectoryControllerProvider(request),
                ),
                initialLoadTimeout: null,
                loadingBuilder: (_) => ListView(
                  padding: EdgeInsets.zero,
                  children: const [CatchSkeletonRows(count: 6)],
                ),
                errorBuilder: (_, error, _) => CatchErrorState.fromError(
                  error,
                  context: AppErrorContext.applications,
                  onRetry: () => ref.invalidate(
                    hostApplicationsDirectoryControllerProvider(request),
                  ),
                ),
                builder: (context, state) {
                  if (state.applications.isEmpty) {
                    return CatchEmptyState(
                      icon: CatchIcons.factCheckOutlined,
                      title: context.l10n.hostApplicationsEmptyTitle,
                      message: context.l10n.hostApplicationsEmptyBody,
                    );
                  }
                  return ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _HostApplicationListFrame(
                        applications: state.applications,
                        sources: sources.value,
                        onOpen: (application) => context.pushNamed(
                          Routes.hostApplicationDetailScreen.name,
                          pathParameters: {
                            'applicationId': application.applicationId,
                          },
                          queryParameters: {'organizerId': widget.organizerId},
                        ),
                      ),
                      if (state.nextCursor != null &&
                          state.loadMoreError == null) ...[
                        gapH16,
                        CatchButton(
                          label: context.l10n.hostApplicationsLoadMore,
                          variant: CatchButtonVariant.secondary,
                          isLoading: state.loadingMore,
                          fullWidth: true,
                          onPressed: state.loadingMore
                              ? null
                              : () => ref
                                    .read(
                                      hostApplicationsDirectoryControllerProvider(
                                        request,
                                      ).notifier,
                                    )
                                    .loadMore(),
                        ),
                      ],
                      if (state.loadMoreError != null) ...[
                        gapH12,
                        CatchErrorState.fromError(
                          state.loadMoreError!,
                          context: AppErrorContext.applications,
                          mode: CatchErrorStateMode.compact,
                          onRetry: () => ref.invalidate(
                            hostApplicationsDirectoryControllerProvider(
                              request,
                            ),
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
            CatchButton.command(
              key: const ValueKey('host-applications-import'),
              label: context.l10n.hostApplicationsImport,
              icon: Icon(CatchIcons.downloadRounded),
              onPressed: _importing ? null : _pickImport,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _chooseStatus() async {
    final selected = await showCatchSelectionSheet<String>(
      context: context,
      title: context.l10n.hostApplicationsReviewStatusFilter,
      value: _status?.name ?? 'all',
      items: [
        CatchSelectionMenuItem(
          value: 'all',
          label: context.l10n.hostApplicationsFilterAll,
        ),
        for (final status in HostApplicationReviewStatus.values)
          CatchSelectionMenuItem(
            value: status.name,
            label: hostApplicationStatusLabel(context, status),
          ),
      ],
    );
    if (selected != null && mounted) {
      setState(
        () => _status = selected == 'all'
            ? null
            : HostApplicationReviewStatus.values.byName(selected),
      );
    }
  }

  Future<void> _pickImport() async {
    setState(() => _importing = true);
    try {
      final table = await ref
          .read(hostApplicationsControllerProvider)
          .pickImportFile();
      if (table == null || !mounted) return;
      final draft = buildHostApplicationImportDraft(table);
      final confirmed = await showCatchBottomSheet<bool>(
        context: context,
        builder: (context) => _HostApplicationImportSheet(draft: draft),
      );
      if (confirmed != true || !mounted) return;
      final imported = await ref
          .read(hostApplicationsControllerProvider)
          .importDraft(
            organizerId: widget.organizerId,
            draft: draft,
            consentCopy: context.l10n.hostApplicationsConsentCopy,
            consentVersion: 'host-applications-v1',
            retentionCopy: context.l10n.hostApplicationsRetentionCopy,
          );
      ref.invalidate(hostApplicationsDirectoryControllerProvider);
      if (mounted) {
        showCatchSnackBar(
          context,
          context.l10n.hostApplicationsImportComplete(
            created: imported.createdCount,
            skipped: imported.skippedCount,
          ),
        );
      }
    } on HostApplicationImportException catch (error) {
      if (mounted) {
        showCatchSnackBar(context, _applicationImportIssue(context, error));
      }
    } on HostRosterImportException catch (error) {
      if (mounted) {
        showCatchSnackBar(context, _rosterImportIssue(context, error.issue));
      }
    } on Object catch (error) {
      if (mounted) {
        showCatchErrorSnackBar(
          context,
          error,
          errorContext: AppErrorContext.applications,
        );
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }
}

class _HostApplicationImportSheet extends StatelessWidget {
  const _HostApplicationImportSheet({required this.draft});

  final HostApplicationImportDraft draft;

  @override
  Widget build(BuildContext context) => CatchBottomSheetScaffold(
    title: context.l10n.hostApplicationsImportTitle,
    subtitle: context.l10n.hostApplicationsImportSubtitle,
    action: CatchButton(
      label: context.l10n.hostApplicationsImportAction(
        count: draft.rows.length,
      ),
      fullWidth: true,
      onPressed: () => Navigator.of(context).pop(true),
    ),
    child: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchSection.fieldRows(
            children: [
              for (final question in draft.questions)
                CatchField.read(
                  title: question.label,
                  body: question.canonicalFieldId == null
                      ? context.l10n.hostApplicationsImportOrganizerField
                      : context.l10n.hostApplicationsImportReusableField,
                ),
            ],
          ),
          if (draft.truncatedRowCount > 0) ...[
            gapH12,
            CatchNotice(
              notice: CatchNoticeData(
                id: 'application-import-limit',
                title: context.l10n.hostApplicationsImportLimit(
                  count: draft.truncatedRowCount,
                ),
                tone: CatchNoticeTone.warning,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

class _HostApplicationListFrame extends StatelessWidget {
  const _HostApplicationListFrame({
    required this.applications,
    required this.sources,
    required this.onOpen,
  });

  final List<HostApplicationSummary> applications;
  final HostSavedAudienceFilterOptions? sources;
  final ValueChanged<HostApplicationSummary> onOpen;

  @override
  Widget build(BuildContext context) {
    return CatchSection.divided(
      first: true,
      children: [
        for (final application in applications)
          CatchPersonRow.directory(
            data: CatchPersonRowData(
              name: application.applicantDisplayName,
              seed: application.applicationId,
            ),
            metadata: Text(
              hostApplicationContextLabel(
                context,
                formId: application.formId,
                targetKind: application.targetKind,
                targetId: application.targetId,
                sources: sources,
              ),
              style: CatchTextStyles.supporting(context),
            ),
            contextContent: Text(
              '${_sourceLabel(context, application.sourceKind)} · ${DateFormat.yMMMd().format(application.submittedAt)}',
              style: CatchTextStyles.recordContext(context),
            ),
            status: CatchBadge.status(
              label: hostApplicationStatusLabel(
                context,
                application.reviewStatus,
              ),
              tone: _applicationStatusTone(application.reviewStatus),
            ),
            onTap: () => onOpen(application),
          ),
      ],
    );
  }
}

CatchBadgeTone _applicationStatusTone(HostApplicationReviewStatus status) =>
    switch (status) {
      HostApplicationReviewStatus.approved => CatchBadgeTone.success,
      HostApplicationReviewStatus.declined => CatchBadgeTone.danger,
      HostApplicationReviewStatus.waitlisted => CatchBadgeTone.warning,
      _ => CatchBadgeTone.neutral,
    };

String hostApplicationStatusLabel(
  BuildContext context,
  HostApplicationReviewStatus status,
) => switch (status) {
  HostApplicationReviewStatus.submitted =>
    context.l10n.hostApplicationsStatusSubmitted,
  HostApplicationReviewStatus.inReview =>
    context.l10n.hostApplicationsStatusInReview,
  HostApplicationReviewStatus.approved =>
    context.l10n.hostApplicationsStatusApproved,
  HostApplicationReviewStatus.waitlisted =>
    context.l10n.hostApplicationsStatusWaitlisted,
  HostApplicationReviewStatus.declined =>
    context.l10n.hostApplicationsStatusDeclined,
  HostApplicationReviewStatus.withdrawn =>
    context.l10n.hostApplicationsStatusWithdrawn,
};

String _sourceLabel(BuildContext context, HostApplicationSourceKind source) =>
    switch (source) {
      HostApplicationSourceKind.native =>
        context.l10n.hostApplicationsSourceNative,
      HostApplicationSourceKind.tabularImport =>
        context.l10n.hostApplicationsSourceImport,
      HostApplicationSourceKind.connector =>
        context.l10n.hostApplicationsSourceConnector,
    };

String _sortLabel(BuildContext context, HostApplicationSort sort) =>
    switch (sort) {
      HostApplicationSort.newest => context.l10n.hostApplicationsSortNewest,
      HostApplicationSort.oldest => context.l10n.hostApplicationsSortOldest,
      HostApplicationSort.name => context.l10n.hostApplicationsSortName,
    };

String _answerText(
  BuildContext context,
  HostApplicationAnswerValue value,
) => switch (value.valueKind) {
  'text' => value.textValue ?? context.l10n.hostApplicationNotAnswered,
  'number' =>
    value.numberValue?.toString() ?? context.l10n.hostApplicationNotAnswered,
  'boolean' =>
    value.booleanValue == null
        ? context.l10n.hostApplicationNotAnswered
        : value.booleanValue!
        ? context.l10n.hostApplicationAnswerYes
        : context.l10n.hostApplicationAnswerNo,
  'date' => value.dateValue ?? context.l10n.hostApplicationNotAnswered,
  'options' =>
    value.optionValues.isEmpty
        ? context.l10n.hostApplicationNotAnswered
        : value.optionValues.join(', '),
  'assets' =>
    value.assetIds.isEmpty
        ? context.l10n.hostApplicationNotAnswered
        : context.l10n.hostApplicationAnswerFiles(count: value.assetIds.length),
  _ => context.l10n.hostApplicationNotAnswered,
};

String _applicationImportIssue(
  BuildContext context,
  HostApplicationImportException error,
) => switch (error.issue) {
  HostApplicationImportIssue.missingNameColumn =>
    context.l10n.hostApplicationsImportMissingName,
  HostApplicationImportIssue.noRows =>
    context.l10n.hostApplicationsImportNoRows,
};

String _rosterImportIssue(BuildContext context, HostRosterImportIssue issue) =>
    switch (issue) {
      HostRosterImportIssue.unsupportedFile =>
        context.l10n.hostsOperationalRosterIssueUnsupported,
      HostRosterImportIssue.fileTooLarge =>
        context.l10n.hostsOperationalRosterIssueFileTooLarge,
      HostRosterImportIssue.expandedFileTooLarge =>
        context.l10n.hostsOperationalRosterIssueExpandedFileTooLarge,
      HostRosterImportIssue.missingRows =>
        context.l10n.hostsOperationalRosterIssueMissingRows,
      HostRosterImportIssue.tooManyColumns =>
        context.l10n.hostsOperationalRosterIssueTooManyColumns,
      HostRosterImportIssue.malformedCsv =>
        context.l10n.hostsOperationalRosterIssueMalformedCsv,
      HostRosterImportIssue.unreadableXlsx ||
      HostRosterImportIssue.missingWorksheet =>
        context.l10n.hostsOperationalRosterIssueUnreadableXlsx,
    };
