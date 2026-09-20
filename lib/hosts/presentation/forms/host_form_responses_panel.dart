import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_boundary.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_sliver_error_state.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_response.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_form_summary.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_forms_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class HostFormResponsesPanel extends ConsumerStatefulWidget {
  const HostFormResponsesPanel({
    super.key,
    required this.organizerId,
    this.query,
    this.formId,
    this.formTitle,
    this.onClearFormFilter,
    this.onFormChanged,
    this.showFormContext = true,
  });

  final String organizerId;
  final String? query;
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
  HostFormResponseStatus? _status;
  bool _oldestFirst = false;
  final Map<String, String> _answerFilters = {};
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
    final request = HostFormResponseListRequest(
      organizerId: widget.organizerId,
      formId: widget.formId,
      statuses: _status == null ? const {} : {_status!},
      query: widget.query,
      answerFilters: Map.unmodifiable(_answerFilters),
      oldestFirst: _oldestFirst,
    );
    final responses = ref.watch(hostFormResponsesControllerProvider(request));
    final loaded = catchAsyncStateFromAsyncValue(responses).value;
    if (loaded != null) _filterOptions = loaded.answerFilterOptions;
    final filterOptions = _filterOptions;
    final statusControl = CatchButton.command(
      label: switch (_status) {
        HostFormResponseStatus.submitted =>
          context.l10n.hostFormResponsesSubmitted,
        HostFormResponseStatus.withdrawn =>
          context.l10n.hostFormResponsesWithdrawn,
        null => context.l10n.hostAudienceAllStatuses,
      },
      leading: Icon(CatchIcons.tune),
      onPressed: _selectStatus,
    );
    final formControl = widget.showFormContext
        ? CatchButton.command(
            label: widget.formId == null
                ? context.l10n.hostAudienceAllForms
                : widget.formTitle ??
                      catchAsyncStateFromAsyncValue(
                        responses,
                      ).value?.responses.firstOrNull?.formTitle ??
                      context.l10n.hostAudienceSelectedForm,
            leading: Icon(CatchIcons.descriptionOutlined),
            onPressed: widget.onFormChanged != null
                ? _chooseForm
                : widget.onClearFormFilter,
          )
        : null;
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: CatchSection.rows(
            children: [
              CatchField.navigate(
                key: const ValueKey('host-form-responses-review-applications'),
                content: CatchRecordLayout(
                  title: context.l10n.hostApplicationsTitle,
                  icon: CatchIcons.factCheckOutlined,
                ),
                onActivate: () => context.pushNamed(
                  Routes.hostApplicationsScreen.name,
                  queryParameters: {
                    'organizerId': widget.organizerId,
                    if (widget.formId != null) 'formId': widget.formId!,
                  },
                ),
              ),
            ],
          ),
        ),
        SliverToBoxAdapter(
          child: CatchSection.controls(
            leading: Wrap(
              children: [
                if (formControl != null) formControl,
                statusControl,
                for (final filter in filterOptions.take(5))
                  CatchButton.command(
                    label:
                        '${filter.label}: ${filter.options[_answerFilters[filter.questionId]] ?? context.l10n.hostFormsFilterAll}',
                    leading: Icon(CatchIcons.tune),
                    onPressed: () => _selectAnswer(filter),
                  ),
              ],
            ),
            trailing: CatchButton.command(
              label: _oldestFirst
                  ? context.l10n.hostApplicationsSortOldest
                  : context.l10n.hostApplicationsSortNewest,
              leading: Icon(CatchIcons.sort),
              onPressed: () => setState(() => _oldestFirst = !_oldestFirst),
            ),
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
            if (state.responses.isEmpty &&
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
                  itemCount: state.responses.length,
                  indexForKeyBuilder: (key) {
                    final index = state.responses.indexWhere(
                      (response) =>
                          key ==
                          ValueKey('host-form-response-${response.responseId}'),
                    );
                    return index < 0 ? null : index;
                  },
                  itemBuilder: (context, index) {
                    final response = state.responses[index];
                    return CatchField.navigate(
                      key: ValueKey(
                        'host-form-response-${response.responseId}',
                      ),
                      content: CatchPersonLayout(
                        name:
                            response.identity.primaryLabel ??
                            context.l10n.hostFormResponsesAnonymous,
                        supportingText: response.highlights.isEmpty
                            ? response.formTitle
                            : response.highlights
                                  .where(
                                    (highlight) =>
                                        highlight.answer !=
                                        response.identity.primaryLabel,
                                  )
                                  .map(
                                    (highlight) =>
                                        '${highlight.label}: ${highlight.answer is List ? (highlight.answer as List).join(', ') : highlight.answer ?? ''}',
                                  )
                                  .join(' · '),
                        context:
                            '${AppTimeFormatters.compactRelativeTime(response.submittedAt)} · ${response.sourceLabel ?? context.l10n.hostFormResponseDirectSource}',
                        badges: [
                          CatchRowBadge(
                            label:
                                response.status ==
                                    HostFormResponseStatus.withdrawn
                                ? context.l10n.hostFormResponsesWithdrawn
                                : context.l10n.hostFormResponsesSubmitted,
                            tone: CatchBadgeTone.neutral,
                          ),
                        ],
                      ),
                      onActivate: () => context.pushNamed(
                        Routes.hostFormResponseDetailScreen.name,
                        pathParameters: {'responseId': response.responseId},
                        queryParameters: {'organizerId': widget.organizerId},
                      ),
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

  Future<void> _selectAnswer(HostFormResponseFilterOption filter) async {
    final selected = await showCatchSelectionSheet<String>(
      context: context,
      title: filter.label,
      value: _answerFilters[filter.questionId] ?? '',
      items: [
        CatchSelectionMenuItem(
          value: '',
          label: context.l10n.hostFormsFilterAll,
        ),
        for (final entry in filter.options.entries)
          CatchSelectionMenuItem(value: entry.key, label: entry.value),
      ],
    );
    if (selected == null || !mounted) return;
    setState(() {
      if (selected.isEmpty) {
        _answerFilters.remove(filter.questionId);
      } else {
        _answerFilters[filter.questionId] = selected;
      }
    });
  }

  Future<void> _selectStatus() async {
    final selected = await showCatchSelectionSheet<String>(
      context: context,
      title: context.l10n.hostAudienceFormStatusFilter,
      value: _status?.name ?? 'all',
      items: [
        CatchSelectionMenuItem(
          value: 'all',
          label: context.l10n.hostAudienceAllStatuses,
        ),
        CatchSelectionMenuItem(
          value: HostFormResponseStatus.submitted.name,
          label: context.l10n.hostFormResponsesSubmitted,
        ),
        CatchSelectionMenuItem(
          value: HostFormResponseStatus.withdrawn.name,
          label: context.l10n.hostFormResponsesWithdrawn,
        ),
      ],
    );
    if (selected != null && mounted) {
      setState(
        () => _status = selected == 'all'
            ? null
            : HostFormResponseStatus.values.byName(selected),
      );
    }
  }

  Future<void> _chooseForm() async {
    final request = HostFormListRequest(organizerId: widget.organizerId);
    final selected = await showCatchBottomSheet<String>(
      context: context,
      builder: (sheetContext) => Consumer(
        builder: (context, ref, _) => CatchSheet(
          title: context.l10n.hostAudienceChooseForm,
          mode: CatchSheetMode.scrollable,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchFieldLanes.single(
                child: CatchField.nav(
                  copy: catchFieldCopy(context.l10n),
                  title: context.l10n.hostAudienceAllForms,
                  onTap: () => Navigator.of(sheetContext).pop(''),
                ),
              ),
              CatchAsyncBoundary<HostFormsDirectoryState>(
                value: ref.watch(hostFormsDirectoryControllerProvider(request)),
                onRetry: () => ref.invalidate(
                  hostFormsDirectoryControllerProvider(request),
                ),
                loadingBuilder: (_) => CatchSkeleton.content(
                  child: CatchSection.fieldRows(
                    children: [
                      for (var index = 0; index < 3; index++)
                        CatchField.nav(
                          copy: catchFieldCopy(context.l10n),
                          title: CatchSkeleton.sampleFormTitle,
                        ),
                    ],
                  ),
                ),
                builder: (context, state) => CatchSection.fieldRows(
                  children: [
                    for (final form in state.forms)
                      CatchField.nav(
                        copy: catchFieldCopy(context.l10n),
                        title: form.title,
                        onTap: () =>
                            Navigator.of(sheetContext).pop(form.formId),
                      ),
                    if (state.canLoadMore || state.loadingMore)
                      CatchButton.command(
                        label: context.l10n.hostFormsLoadMore,
                        onPressed: state.loadingMore
                            ? null
                            : () => ref
                                  .read(
                                    hostFormsDirectoryControllerProvider(
                                      request,
                                    ).notifier,
                                  )
                                  .loadMore(),
                      ),
                    if (state.loadMoreError case final error?)
                      CatchLocalizedErrorState(
                        error,
                        context: AppErrorContext.forms,
                        mode: CatchErrorStateMode.compact,
                        onRetry: () => ref
                            .read(
                              hostFormsDirectoryControllerProvider(
                                request,
                              ).notifier,
                            )
                            .loadMore(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (selected != null && mounted) {
      widget.onFormChanged?.call(selected.isEmpty ? null : selected);
    }
  }
}
