import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_sliver_error_state.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_summary.dart';
import 'package:catch_dating_app/hosts/domain/host_application_summary.dart';
import 'package:catch_dating_app/hosts/presentation/applications/host_application_copy.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
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

  @override
  ConsumerState<HostFormResponsesPanel> createState() =>
      _HostFormResponsesPanelState();
}

class _HostFormResponsesPanelState
    extends ConsumerState<HostFormResponsesPanel> {
  HostApplicationReviewStatus? _status;
  bool _oldestFirst = false;
  final Map<String, Set<String>> _answerFilters = {};
  List<HostFormResponseFilterOption> _filterOptions = const [];

  @override
  void didUpdateWidget(covariant HostFormResponsesPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.formId != widget.formId ||
        oldWidget.organizerId != widget.organizerId) {
      _answerFilters.clear();
      _filterOptions = const [];
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = _responseRequest(widget.formId);
    final responses = ref.watch(hostFormResponsesControllerProvider(request));
    final loaded = catchAsyncStateFromAsyncValue(responses).value;
    if (loaded != null) _filterOptions = loaded.answerFilterOptions;
    final activeFilters = [
      if (widget.showFormContext && widget.formId != null)
        _formLabel(context, loaded),
      if (widget.contactId != null) context.l10n.hostAudienceSelectedPerson,
      for (final entry in _answerFilters.entries)
        for (final option in _filterOptions.where(
          (item) => item.questionId == entry.key,
        ))
          '${option.label}: ${entry.value.map((value) => option.options[value] ?? value).join(', ')}',
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
                        if (application != null) {
                          await context.pushNamed(
                            Routes.hostApplicationDetailScreen.name,
                            pathParameters: {
                              'applicationId': application.applicationId,
                            },
                            queryParameters: {
                              'organizerId': widget.organizerId,
                            },
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
                          );
                        }
                        if (mounted) {
                          ref.invalidate(hostFormResponsesControllerProvider);
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

  HostFormResponseListRequest _responseRequest(String? formId) =>
      HostFormResponseListRequest(
        organizerId: widget.organizerId,
        formId: formId,
        includeApplications: true,
        reviewStatus: _status,
        contactId: widget.contactId,
        query: widget.query,
        answerFilters: Map.unmodifiable(_answerFilters),
        oldestFirst: _oldestFirst,
      );
}
