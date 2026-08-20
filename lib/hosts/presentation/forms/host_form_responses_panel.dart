import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/routing/go_router.dart';
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
    this.showFormContext = true,
  });

  final String organizerId;
  final String? query;
  final String? formId;
  final String? formTitle;
  final VoidCallback? onClearFormFilter;
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
        Text(
          context.l10n.hostFormResponsesSubtitle,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: CatchTokens.of(context).ink2),
        ),
        gapH16,
        if (widget.formId != null && widget.showFormContext) ...[
          CatchSection.containedFieldRows(
            children: [
              CatchField.content(
                title: context.l10n.hostFormResponseFilteredTo(
                  formTitle: widget.formTitle ?? widget.formId!,
                ),
                body: context.l10n.hostFormResponsesSubtitle,
                action: CatchButton(
                  label: context.l10n.hostFormResponseClearFormFilter,
                  size: CatchButtonSize.sm,
                  variant: CatchButtonVariant.ghost,
                  onPressed: widget.onClearFormFilter,
                ),
              ),
            ],
          ),
          gapH16,
        ],
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              CatchChip.selectable(
                label: context.l10n.hostFormResponsesAll,
                selected: _status == null,
                contractExemption:
                    'All responses intentionally omits the status filter.',
                onChanged: (_) => setState(() => _status = null),
              ),
              gapW8,
              CatchChip.selectable(
                label: context.l10n.hostFormResponsesSubmitted,
                selected: _status == HostFormResponseStatus.submitted,
                contract: CatchContractConstraints
                    .listOrganizerFormResponsesCallablePayloadStatusesItems,
                contractValue: HostFormResponseStatus.submitted.name,
                onChanged: (_) =>
                    setState(() => _status = HostFormResponseStatus.submitted),
              ),
              gapW8,
              CatchChip.selectable(
                label: context.l10n.hostFormResponsesWithdrawn,
                selected: _status == HostFormResponseStatus.withdrawn,
                contract: CatchContractConstraints
                    .listOrganizerFormResponsesCallablePayloadStatusesItems,
                contractValue: HostFormResponseStatus.withdrawn.name,
                onChanged: (_) =>
                    setState(() => _status = HostFormResponseStatus.withdrawn),
              ),
            ],
          ),
        ),
        gapH16,
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
                CatchSection.containedFieldRows(
                  children: [
                    for (final response in state.responses)
                      CatchField.nav(
                        key: ValueKey(
                          'host-form-response-${response.responseId}',
                        ),
                        title:
                            response.identity.primaryLabel ??
                            context.l10n.hostFormResponsesAnonymous,
                        body: context.l10n.hostFormResponseRowSummary(
                          formTitle: response.formTitle,
                          source:
                              response.sourceLabel ??
                              context.l10n.hostFormResponseDirectSource,
                        ),
                        valueText: AppTimeFormatters.compactRelativeTime(
                          response.submittedAt,
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
}
