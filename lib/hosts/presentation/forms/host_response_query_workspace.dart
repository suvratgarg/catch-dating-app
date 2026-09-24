import 'dart:convert';

import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/hosts/domain/forms/host_response_query.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_response_query_controller.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_response_query_editor.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Labels are supplied by the owning Forms route when its callable is live.
class HostResponseQueryWorkspaceCopy {
  const HostResponseQueryWorkspaceCopy({
    required this.filter,
    required this.sort,
    required this.newest,
    required this.oldest,
    required this.refresh,
    required this.loadMore,
    required this.loading,
    required this.empty,
    required this.stale,
    required this.budgetExceeded,
    required this.permissionLost,
    required this.failed,
    required this.selected,
    required this.clearSelection,
    required this.reviewSelection,
    required this.withdrawn,
    required this.select,
    required this.deselect,
    required this.editor,
  });

  final String filter;
  final String sort;
  final String newest;
  final String oldest;
  final String refresh;
  final String loadMore;
  final String loading;
  final String empty;
  final String stale;
  final String budgetExceeded;
  final String permissionLost;
  final String failed;
  final String Function(int) selected;
  final String clearSelection;
  final String reviewSelection;
  final String withdrawn;
  final String select;
  final String deselect;
  final HostResponseQueryEditorCopy editor;
}

/// Opt-in boundary supplied by the Forms route only after the manager query
/// callable and localized copy are registered. The legacy inbox stays in use
/// until then.
class HostResponseQueryCapability {
  const HostResponseQueryCapability({
    required this.versionId,
    required this.gateway,
    required this.copy,
    this.onReviewSelection,
  });

  final String versionId;
  final HostResponseQueryGateway gateway;
  final HostResponseQueryWorkspaceCopy copy;
  final void Function(List<String> ids, String resultHash)? onReviewSelection;
}

/// Manager query workspace for one published form version. Its bulk callback
/// carries review intent only; the write endpoint must independently recheck
/// current manager, response, identity, query hash and conversion authority.
class HostResponseQueryWorkspace extends StatefulWidget {
  const HostResponseQueryWorkspace({
    super.key,
    required this.controller,
    required this.request,
    required this.copy,
    required this.onOpenResponse,
    this.onReviewSelection,
  });

  final HostResponseQueryController controller;
  final HostResponseQueryRequest request;
  final HostResponseQueryWorkspaceCopy copy;
  final ValueChanged<String> onOpenResponse;
  final void Function(List<String> ids, String resultHash)? onReviewSelection;

  @override
  State<HostResponseQueryWorkspace> createState() =>
      _HostResponseQueryWorkspaceState();
}

class _HostResponseQueryWorkspaceState
    extends State<HostResponseQueryWorkspace> {
  late HostResponseQueryRequest _request;
  bool _showFilter = false;

  @override
  void initState() {
    super.initState();
    _request = widget.request.withCursor(null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.controller.apply(_request);
    });
  }

  @override
  void didUpdateWidget(covariant HostResponseQueryWorkspace oldWidget) {
    super.didUpdateWidget(oldWidget);
    final changed =
        jsonEncode(oldWidget.request.toJson()) !=
        jsonEncode(widget.request.toJson());
    if (changed || oldWidget.controller != widget.controller) {
      _request = widget.request.withCursor(null);
      _showFilter = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.controller.apply(_request);
      });
    }
  }

  void _apply(HostResponseQueryRequest request) {
    setState(() {
      _request = request.withCursor(null);
      _showFilter = false;
    });
    widget.controller.apply(_request);
  }

  HostResponseQueryRequest _with({
    HostResponsePredicate? predicate,
    bool clearPredicate = false,
    HostResponseSort? sort,
  }) => HostResponseQueryRequest(
    organizerId: _request.organizerId,
    formId: _request.formId,
    versionId: _request.versionId,
    statuses: _request.statuses,
    predicate: clearPredicate ? null : predicate ?? _request.predicate,
    sort: sort ?? _request.sort,
    limit: _request.limit,
  );

  Future<void> _chooseSort(HostResponseQueryView view) async {
    final options = <HostResponseSort>[
      const HostResponseSort(),
      const HostResponseSort(direction: 'asc'),
      for (final field in view.catalog.where((field) => field.sortable)) ...[
        HostResponseSort(questionId: field.questionId),
        HostResponseSort(questionId: field.questionId, direction: 'asc'),
      ],
    ];
    final chosen = await showCatchSelectionSheet<int>(
      context: context,
      title: widget.copy.sort,
      value: options.indexWhere(
        (item) =>
            item.questionId == _request.sort.questionId &&
            item.direction == _request.sort.direction,
      ),
      items: [
        for (var index = 0; index < options.length; index++)
          CatchSelectionMenuItem(
            value: index,
            label: options[index].questionId == null
                ? options[index].direction == 'asc'
                      ? widget.copy.oldest
                      : widget.copy.newest
                : '${view.catalog.firstWhere((field) => field.questionId == options[index].questionId).label} · ${options[index].direction == 'asc' ? widget.copy.oldest : widget.copy.newest}',
          ),
      ],
    );
    if (!mounted || chosen == null || chosen < 0) return;
    _apply(_with(sort: options[chosen]));
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.controller,
    builder: (context, _) {
      final view = widget.controller.view;
      final copy = widget.copy;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CatchSection.content(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: CatchSpacing.s3,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    CatchButton(
                      label: copy.filter,
                      variant: CatchButtonVariant.secondary,
                      onPressed: view.catalog.isEmpty
                          ? null
                          : () => setState(() => _showFilter = !_showFilter),
                    ),
                    CatchButton(
                      label: copy.sort,
                      variant: CatchButtonVariant.secondary,
                      onPressed: view.catalog.isEmpty
                          ? null
                          : () => _chooseSort(view),
                    ),
                    CatchButton(
                      label: copy.refresh,
                      variant: CatchButtonVariant.secondary,
                      onPressed: view.status == HostResponseQueryStatus.loading
                          ? null
                          : () => widget.controller.apply(_request),
                    ),
                  ],
                ),
                if (_showFilter && view.catalog.isNotEmpty) ...[
                  gapH16,
                  HostResponseQueryEditor(
                    fields: view.catalog,
                    copy: copy.editor,
                    initial: _request.predicate,
                    onApply: (predicate) => _apply(
                      _with(
                        predicate: predicate,
                        clearPredicate: predicate == null,
                      ),
                    ),
                  ),
                ],
                gapH16,
                if (view.status == HostResponseQueryStatus.loading)
                  Text(copy.loading, style: CatchTextStyles.supporting(context))
                else if (view.status == HostResponseQueryStatus.empty)
                  Text(copy.empty, style: CatchTextStyles.supporting(context))
                else if (view.status == HostResponseQueryStatus.stale)
                  Text(copy.stale, style: CatchTextStyles.supporting(context))
                else if (view.status == HostResponseQueryStatus.budgetExceeded)
                  Text(
                    copy.budgetExceeded,
                    style: CatchTextStyles.supporting(context),
                  )
                else if (view.status == HostResponseQueryStatus.permissionLost)
                  Text(
                    copy.permissionLost,
                    style: CatchTextStyles.supporting(context),
                  )
                else if (view.status == HostResponseQueryStatus.failure)
                  Text(copy.failed, style: CatchTextStyles.supporting(context)),
                if (view.status == HostResponseQueryStatus.ready) ...[
                  if (view.selectedIds.isNotEmpty) ...[
                    Text(
                      copy.selected(view.selectedIds.length),
                      style: CatchTextStyles.supporting(context),
                    ),
                    Wrap(
                      spacing: CatchSpacing.s3,
                      children: [
                        CatchButton(
                          label: copy.clearSelection,
                          variant: CatchButtonVariant.secondary,
                          onPressed: widget.controller.clearSelection,
                        ),
                        if (widget.onReviewSelection != null)
                          CatchButton(
                            label: copy.reviewSelection,
                            onPressed: () {
                              final intent = widget.controller.selectionIntent;
                              if (intent != null) {
                                widget.onReviewSelection!(
                                  intent.ids,
                                  intent.resultHash,
                                );
                              }
                            },
                          ),
                      ],
                    ),
                    gapH12,
                  ],
                  if (view.canLoadMore) ...[
                    gapH16,
                    CatchButton(
                      label: copy.loadMore,
                      status: view.loadingMore
                          ? CatchButtonStatus.loading
                          : CatchButtonStatus.idle,
                      onPressed: view.loadingMore
                          ? null
                          : widget.controller.loadMore,
                    ),
                  ],
                ],
              ],
            ),
          ),
          if (view.status == HostResponseQueryStatus.ready)
            CatchSection.fieldRows(
              children: [
                for (final row in view.rows)
                  CatchField.content(
                    key: ValueKey('query-response-${row.responseId}'),
                    copy: catchFieldCopy(context.l10n),
                    title: row.identity.primaryLabel ??
                        context.l10n.hostFormResponsesAnonymous,
                    body: row.status.name == 'withdrawn'
                        ? copy.withdrawn
                        : row.formTitle,
                    onTap: () => widget.onOpenResponse(row.responseId),
                    actions: widget.onReviewSelection == null
                        ? null
                        : CatchButton.command(
                            label: view.selectedIds.contains(row.responseId)
                                ? copy.deselect
                                : copy.select,
                            onPressed:
                                view.availableIds.contains(row.responseId)
                                ? () => widget.controller.toggleSelection(
                                    row.responseId,
                                  )
                                : null,
                          ),
                  ),
              ],
            ),
        ],
      );
    },
  );
}
