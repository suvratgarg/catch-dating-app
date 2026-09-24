import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_sliver_error_state.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/hosts/data/host_response_query_repository.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_summary.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_response_query.dart';
import 'package:catch_dating_app/hosts/domain/host_application_summary.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_application_copy.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_detail_screen.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_query_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_response_query_workspace_section.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

part 'host_form_responses_filter_sheet.dart';

class HostFormResponsesPanel extends ConsumerStatefulWidget {
  const HostFormResponsesPanel({
    super.key,
    required this.organizerId,
    this.query,
    this.contactId,
    this.onClearContactFilter,
    this.formId,
    this.formTitle,
    this.onClearFormFilter,
    this.onFormChanged,
    this.showFormContext = true,
    this.queryCapability,
  });

  final String organizerId;
  final String? query;
  final String? contactId;
  final VoidCallback? onClearContactFilter;
  final String? formId;
  final String? formTitle;
  final VoidCallback? onClearFormFilter;
  final ValueChanged<String?>? onFormChanged;
  final bool showFormContext;
  final HostResponseQueryCapability? queryCapability;

  @override
  ConsumerState<HostFormResponsesPanel> createState() =>
      _HostFormResponsesPanelState();
}

class _HostFormResponsesPanelState
    extends ConsumerState<HostFormResponsesPanel> {
  HostResponseQueryController? _queryController;
  HostApplicationReviewStatus? _status;
  bool _oldestFirst = false;
  String? _versionId;
  bool _versionResolved = false;
  HostFormResponseVersionScope? _versionScope;
  final Map<String, Set<String>> _answerFilters = {};
  List<HostFormResponseFilterOption> _filterOptions = const [];

  @override
  void initState() {
    super.initState();
    if (widget.queryCapability case final capability?) {
      _queryController = HostResponseQueryController(
        capability.gateway ??
            HostResponseQueryRepository(ref.read(firebaseFunctionsProvider)),
      );
    }
  }

  @override
  void dispose() {
    _queryController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HostFormResponsesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.queryCapability?.gateway != widget.queryCapability?.gateway ||
        oldWidget.queryCapability?.versionId !=
            widget.queryCapability?.versionId ||
        (oldWidget.queryCapability == null) !=
            (widget.queryCapability == null) ||
        oldWidget.formId != widget.formId ||
        oldWidget.organizerId != widget.organizerId) {
      _queryController?.dispose();
      final capability = widget.queryCapability;
      _queryController = capability == null
          ? null
          : HostResponseQueryController(
              capability.gateway ??
                  HostResponseQueryRepository(
                    ref.read(firebaseFunctionsProvider),
                  ),
            );
    }
    if (oldWidget.formId != widget.formId ||
        oldWidget.organizerId != widget.organizerId) {
      _answerFilters.clear();
      _filterOptions = const [];
      _versionId = null;
      _versionResolved = false;
      _versionScope = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final capability = widget.queryCapability;
    final queryController = _queryController;
    if (capability != null &&
        queryController != null &&
        widget.formId != null) {
      return SliverToBoxAdapter(
        child: HostResponseQueryWorkspaceSection(
          controller: queryController,
          request: HostResponseQueryRequest(
            organizerId: widget.organizerId,
            formId: widget.formId!,
            versionId: capability.versionId,
          ),
          copy: capability.copy,
          onReviewSelection: capability.onReviewSelection,
          onOpenResponse: (responseId) => context.pushNamed(
            Routes.hostFormResponseDetailScreen.name,
            pathParameters: {'responseId': responseId},
            queryParameters: {'organizerId': widget.organizerId},
          ),
        ),
      );
    }
    final request = _responseRequest(widget.formId);
    final responses = ref.watch(hostFormResponsesControllerProvider(request));
    final loaded = catchAsyncStateFromAsyncValue(responses).value;
    if (loaded?.versionScope != null) _versionScope = loaded!.versionScope;
    final resolvingVersion =
        widget.formId != null &&
        loaded?.versionScope?.activeVersionId != null &&
        !_versionResolved;
    if (resolvingVersion) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || _versionResolved || widget.formId != request.formId) {
          return;
        }
        setState(() {
          _versionId = loaded!.versionScope!.activeVersionId;
          _versionResolved = true;
        });
      });
    }
    if (loaded != null) _filterOptions = loaded.answerFilterOptions;
    final visibleVersionId = _versionResolved
        ? _versionId
        : _versionScope?.activeVersionId;
    final versionLabel = _versionScope == null
        ? null
        : visibleVersionId == null
        ? context.l10n.hostAudienceResponsesAllVersions
        : context.l10n.hostAudienceResultsVersion(
            version: _versionNumber(visibleVersionId),
          );
    final activeFilters = [
      if (widget.showFormContext && widget.formId != null)
        _formLabel(context, loaded),
      if (widget.contactId != null) context.l10n.hostAudienceSelectedPerson,
      if (widget.formId != null &&
          _versionScope != null &&
          _versionResolved &&
          _versionId != _versionScope!.activeVersionId)
        versionLabel!,
      for (final entry
          in (_answerFilters.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key))))
        for (final option in _filterOptions.where(
          (item) => item.questionId == entry.key,
        ))
          '${option.label}: ${(entry.value.toList()..sort()).map((value) => option.options[value] ?? value).join(', ')}',
    ];
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: CatchSection.content(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CatchChoiceInput<HostApplicationReviewStatus?>.segmented(
                  key: const ValueKey('host-responses-lifecycle'),
                  options: [
                    CatchOption(
                      value: null,
                      label: context.l10n.hostFormsFilterAll,
                    ),
                    for (final status in HostApplicationReviewStatus.values)
                      CatchOption(
                        value: status,
                        label: hostApplicationStatusLabel(context, status),
                      ),
                  ],
                  selected: _status,
                  variant: CatchChoiceInputVariant.summary,
                  contractExemption:
                      'Review lifecycle maps directly to the unified response request reviewStatus; All includes responses without application review.',
                  onChanged: (status) => setState(() => _status = status),
                  scrollable: true,
                  showDivider: false,
                ),
                if (widget.formId != null && versionLabel != null) ...[
                  gapH8,
                  Text(
                    versionLabel,
                    style: CatchTextStyles.supporting(context),
                  ),
                ],
                gapH16,
              ],
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: CatchSection.controls(
            sortLabel: context.l10n.hostCustomersSortControl(
              label: _oldestFirst
                  ? context.l10n.hostApplicationsSortOldest
                  : context.l10n.hostApplicationsSortNewest,
            ),
            onSort: _chooseSort,
            filtersLabel: context.l10n.hostCustomersFilters,
            onFilters: _openFilters,
            activeFilters: activeFilters.isEmpty
                ? null
                : activeFilters.join(' · '),
            clearLabel: activeFilters.isEmpty
                ? null
                : context.l10n.hostCustomersClearFilter,
            onClear: activeFilters.isEmpty
                ? null
                : () {
                    setState(() {
                      _answerFilters.clear();
                      _versionId = _versionScope?.activeVersionId;
                      _versionResolved = true;
                      _filterOptions = const [];
                    });
                    widget.onClearContactFilter?.call();
                    if (widget.showFormContext) {
                      widget.onClearFormFilter?.call();
                    }
                  },
          ),
        ),
        CatchAsyncBoundary<HostFormResponsesState>.sliver(
          value: responses,
          onRetry: () =>
              ref.invalidate(hostFormResponsesControllerProvider(request)),
          initialLoadTimeout: null,
          loadingBuilder: (_) => CatchSection.sliverLoadingRows(
            itemCount: 6,
            layoutBuilder: (_, _) => const CatchPersonLayout.placeholder(
              hasSupportingText: true,
              hasContext: true,
              hasBadge: true,
            ),
          ),
          errorBuilder: (_, error, _, onBoundaryRetry) =>
              CatchLocalizedSliverErrorState(
                error,
                context: AppErrorContext.formResponses,
                onRetry: onBoundaryRetry,
              ),
          builder: (context, state) {
            if (resolvingVersion) {
              return CatchSection.sliverLoadingRows(
                itemCount: 6,
                layoutBuilder: (_, _) => const CatchPersonLayout.placeholder(
                  hasSupportingText: true,
                  hasContext: true,
                  hasBadge: true,
                ),
              );
            }
            if (state.inboxEntries.isEmpty &&
                !state.canLoadMore &&
                !state.loadingMore &&
                state.loadMoreError == null) {
              final filtered =
                  widget.query != null ||
                  _status != null ||
                  _answerFilters.isNotEmpty;
              return CatchSliverEmptyState(
                icon: CatchIcons.descriptionOutlined,
                title: filtered
                    ? context.l10n.hostFormResponsesNoMatchesTitle
                    : context.l10n.hostFormResponsesEmptyTitle,
                message: filtered
                    ? context.l10n.hostFormResponsesNoMatchesBody
                    : context.l10n.hostFormResponsesEmptyBody,
              );
            }
            return SliverMainAxisGroup(
              slivers: [
                CatchSection.sliverRows(
                  itemCount: state.inboxEntries.length,
                  indexForKeyBuilder: (key) {
                    final index = state.inboxEntries.indexWhere(
                      (entry) =>
                          key ==
                          ValueKey('host-response-entry-${entry.entryId}'),
                    );
                    return index < 0 ? null : index;
                  },
                  itemBuilder: (context, index) {
                    final entry = state.inboxEntries[index];
                    final response = entry.response;
                    final application = entry.application;
                    return CatchField.navigate(
                      key: ValueKey('host-response-entry-${entry.entryId}'),
                      content: CatchPersonLayout(
                        name:
                            application?.applicantDisplayName ??
                            response?.identity.primaryLabel ??
                            context.l10n.hostFormResponsesAnonymous,
                        supportingText: response?.formTitle,
                        context:
                            '${AppTimeFormatters.compactRelativeTime(entry.submittedAt)} · ${application == null ? response?.sourceLabel ?? context.l10n.hostFormResponseDirectSource : hostApplicationSourceLabel(context, application.sourceKind)}',
                        badges: [
                          if (application != null)
                            CatchRowBadge(
                              label: hostApplicationStatusLabel(
                                context,
                                application.reviewStatus,
                              ),
                              tone: hostApplicationStatusTone(
                                application.reviewStatus,
                              ),
                            )
                          else if (response?.status ==
                              HostFormResponseStatus.withdrawn)
                            CatchRowBadge(
                              label: context.l10n.hostFormResponsesWithdrawn,
                              tone: CatchBadgeTone.neutral,
                            ),
                        ],
                      ),
                      onActivate: () async {
                        final queue = HostResponseReviewQueue(
                          request: request,
                          entryId: entry.entryId,
                          index: index,
                        );
                        if (application != null) {
                          await context.pushNamed(
                            Routes.hostApplicationDetailScreen.name,
                            pathParameters: {
                              'applicationId': application.applicationId,
                            },
                            queryParameters: {
                              'organizerId': widget.organizerId,
                            },
                            extra: queue,
                          );
                        } else {
                          await context.pushNamed(
                            Routes.hostFormResponseDetailScreen.name,
                            pathParameters: {
                              'responseId': response!.responseId,
                            },
                            queryParameters: {
                              'organizerId': widget.organizerId,
                            },
                            extra: queue,
                          );
                        }
                      },
                    );
                  },
                ),
                if (state.canLoadMore)
                  CatchPageBody.sliver(
                    child: SliverToBoxAdapter(
                      child: CatchButton(
                        label: context.l10n.hostFormResponsesLoadMore,
                        variant: CatchButtonVariant.secondary,
                        status: state.loadingMore
                            ? CatchButtonStatus.loading
                            : CatchButtonStatus.idle,
                        fullWidth: true,
                        onPressed: state.loadingMore
                            ? null
                            : () => ref
                                  .read(
                                    hostFormResponsesControllerProvider(
                                      request,
                                    ).notifier,
                                  )
                                  .loadMore(),
                      ),
                    ),
                  ),
                if (state.loadMoreError case final error?)
                  CatchLocalizedSliverErrorState(
                    error,
                    context: AppErrorContext.formResponses,
                    fillRemaining: false,
                    onRetry: () => ref
                        .read(
                          hostFormResponsesControllerProvider(request).notifier,
                        )
                        .loadMore(),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  String _formLabel(BuildContext context, HostFormResponsesState? loaded) =>
      widget.formId == null
      ? context.l10n.hostAudienceAllForms
      : widget.formTitle ??
            loaded?.responses.firstOrNull?.formTitle ??
            context.l10n.hostAudienceSelectedForm;

  Future<void> _chooseSort() async {
    final value = await showCatchSelectionSheet<bool>(
      context: context,
      title: context.l10n.hostCustomersSort,
      value: _oldestFirst,
      items: [
        CatchSelectionMenuItem(
          value: false,
          label: context.l10n.hostApplicationsSortNewest,
        ),
        CatchSelectionMenuItem(
          value: true,
          label: context.l10n.hostApplicationsSortOldest,
        ),
      ],
    );
    if (value != null && mounted) setState(() => _oldestFirst = value);
  }

  void _updateFilters(VoidCallback update) => setState(update);

  int _versionNumber(String id) => int.tryParse(id.split('_v').last) ?? 0;

  void _selectVersion(String? id) {
    if (_versionId == id && _versionResolved) return;
    setState(() {
      _versionId = id;
      _versionResolved = true;
      _answerFilters.clear();
      _filterOptions = const [];
    });
  }

  HostFormResponseListRequest _responseRequest(String? formId) =>
      HostFormResponseListRequest(
        organizerId: widget.organizerId,
        formId: formId,
        versionId: formId == widget.formId ? _versionId : null,
        includeApplications: true,
        reviewStatus: _status,
        contactId: widget.contactId,
        query: widget.query,
        answerFilters: Map.unmodifiable(_answerFilters),
        oldestFirst: _oldestFirst,
      );
}
