import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_person_row.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_selection_menu.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/hosts/domain/host_form.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
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

  @override
  Widget build(BuildContext context) {
    final request = HostFormResponseListRequest(
      organizerId: widget.organizerId,
      formId: widget.formId,
      statuses: _status == null ? const {} : {_status!},
      query: widget.query,
    );
    final responses = ref.watch(hostFormResponsesControllerProvider(request));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchOptionGroup<bool>(
          key: const ValueKey('host-form-responses-review-applications'),
          options: [
            CatchOption(
              value: false,
              label: context.l10n.hostAudienceAllResponses,
            ),
            CatchOption(value: true, label: context.l10n.hostApplicationsTitle),
          ],
          selected: false,
          variant: CatchOptionGroupVariant.summary,
          contractExemption:
              'Navigation between raw submissions and the application review queue; not a stored value.',
          onChanged: (applications) {
            if (!applications) return;
            context.pushNamed(
              Routes.hostApplicationsScreen.name,
              queryParameters: {
                'organizerId': widget.organizerId,
                if (widget.formId != null) 'formId': widget.formId!,
              },
            );
          },
        ),
        gapH16,
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: CatchSpacing.s4,
          children: [
            if (widget.showFormContext)
              CatchButton.command(
                label: widget.formId == null
                    ? context.l10n.hostAudienceAllForms
                    : widget.formTitle ??
                          catchAsyncStateFromAsyncValue(
                            responses,
                          ).value?.responses.firstOrNull?.formTitle ??
                          context.l10n.hostAudienceSelectedForm,
                icon: Icon(CatchIcons.descriptionOutlined),
                onPressed: widget.onFormChanged != null
                    ? _chooseForm
                    : widget.onClearFormFilter,
              ),
            CatchButton.command(
              label: switch (_status) {
                HostFormResponseStatus.submitted =>
                  context.l10n.hostFormResponsesSubmitted,
                HostFormResponseStatus.withdrawn =>
                  context.l10n.hostFormResponsesWithdrawn,
                null => context.l10n.hostAudienceAllStatuses,
              },
              icon: Icon(CatchIcons.tune),
              onPressed: _selectStatus,
            ),
          ],
        ),
        gapH8,
        CatchAsyncValueView<HostFormResponsesState>(
          value: responses,
          onRetry: () =>
              ref.invalidate(hostFormResponsesControllerProvider(request)),
          initialLoadTimeout: null,
          loadingBuilder: (_) => const CatchSkeletonRows(count: 6),
          errorBuilder: (_, error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.formResponses,
            mode: CatchErrorStateMode.compact,
            onRetry: () =>
                ref.invalidate(hostFormResponsesControllerProvider(request)),
          ),
          builder: (context, state) {
            if (state.responses.isEmpty) {
              final filtered = widget.query != null || _status != null;
              return CatchEmptyState(
                icon: CatchIcons.descriptionOutlined,
                title: filtered
                    ? context.l10n.hostFormResponsesNoMatchesTitle
                    : context.l10n.hostFormResponsesEmptyTitle,
                message: filtered
                    ? context.l10n.hostFormResponsesNoMatchesBody
                    : context.l10n.hostFormResponsesEmptyBody,
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CatchSection.divided(
                  first: true,
                  children: [
                    for (final response in state.responses)
                      CatchPersonRow.directory(
                        key: ValueKey(
                          'host-form-response-${response.responseId}',
                        ),
                        data: CatchPersonRowData(
                          name:
                              response.identity.primaryLabel ??
                              context.l10n.hostFormResponsesAnonymous,
                          seed: response.responseId,
                        ),
                        metadata: Text(
                          response.formTitle,
                          style: CatchTextStyles.supporting(context),
                        ),
                        contextContent: Text(
                          '${AppTimeFormatters.compactRelativeTime(response.submittedAt)} · ${response.sourceLabel ?? context.l10n.hostFormResponseDirectSource}',
                          style: CatchTextStyles.recordContext(context),
                        ),
                        status: CatchBadge.status(
                          label:
                              response.status ==
                                  HostFormResponseStatus.withdrawn
                              ? context.l10n.hostFormResponsesWithdrawn
                              : context.l10n.hostFormResponsesSubmitted,
                        ),
                        onTap: () => context.pushNamed(
                          Routes.hostFormResponseDetailScreen.name,
                          pathParameters: {'responseId': response.responseId},
                          queryParameters: {'organizerId': widget.organizerId},
                        ),
                      ),
                  ],
                ),
                if (state.canLoadMore) ...[
                  gapH16,
                  CatchButton(
                    label: context.l10n.hostFormResponsesLoadMore,
                    variant: CatchButtonVariant.secondary,
                    isLoading: state.loadingMore,
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
                ],
                if (state.loadMoreError case final error?) ...[
                  gapH12,
                  CatchErrorState.fromError(
                    error,
                    context: AppErrorContext.formResponses,
                    mode: CatchErrorStateMode.compact,
                    onRetry: () => ref
                        .read(
                          hostFormResponsesControllerProvider(request).notifier,
                        )
                        .loadMore(),
                  ),
                ],
              ],
            );
          },
        ),
      ],
    );
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
        builder: (context, ref, _) => CatchBottomSheetScaffold(
          title: context.l10n.hostAudienceChooseForm,
          scrollable: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CatchFieldLanes.single(
                child: CatchField.nav(
                  title: context.l10n.hostAudienceAllForms,
                  onTap: () => Navigator.of(sheetContext).pop(''),
                ),
              ),
              CatchAsyncValueView<HostFormsDirectoryState>(
                value: ref.watch(hostFormsDirectoryControllerProvider(request)),
                onRetry: () => ref.invalidate(
                  hostFormsDirectoryControllerProvider(request),
                ),
                loadingBuilder: (_) => const CatchSkeletonRows(),
                builder: (context, state) => CatchSection.fieldRows(
                  children: [
                    for (final form in state.forms)
                      CatchField.nav(
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
                      CatchErrorState.fromError(
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
