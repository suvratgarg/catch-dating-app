import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HostFormAutomationsScreen extends ConsumerWidget {
  const HostFormAutomationsScreen({
    super.key,
    required this.organizerId,
    required this.formId,
  });

  final String organizerId;
  final String formId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = hostFormAutomationsControllerProvider(organizerId, formId);
    final automations = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: context.l10n.hostFormAutomationsTitle,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      body: CatchRouteBody.standard(
        constrainToContentWidth: true,
        child: CatchAsyncValueView<HostFormAutomationsState>(
          value: automations,
          onRetry: () => ref.invalidate(provider),
          initialLoadTimeout: null,
          loadingBuilder: (_) => const CatchSkeletonRows(count: 7),
          errorBuilder: (_, error, _) => CatchErrorState.fromError(
            error,
            context: AppErrorContext.forms,
            onRetry: () => ref.invalidate(provider),
          ),
          builder: (context, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                context.l10n.hostFormAutomationsSubtitle,
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).ink2,
                ),
              ),
              gapH16,
              Wrap(
                spacing: CatchSpacing.s3,
                runSpacing: CatchSpacing.s3,
                children: [
                  CatchButton(
                    label: context.l10n.hostFormAutomationNotifyPreset,
                    icon: Icon(CatchIcons.notificationsNoneRounded),
                    isLoading: state.mutatingRuleIds.contains('new'),
                    onPressed: state.mutatingRuleIds.contains('new')
                        ? null
                        : () => _createPreset(
                            context,
                            controller,
                            () => ref.read(provider).asData?.value.error,
                            context.l10n.hostFormAutomationNotifyPreset,
                            const [HostFormAutomationActionKind.notifyTeam],
                          ),
                  ),
                  CatchButton(
                    label: context.l10n.hostFormAutomationCrmPreset,
                    icon: Icon(CatchIcons.peopleOutlineRounded),
                    variant: CatchButtonVariant.secondary,
                    isLoading: state.mutatingRuleIds.contains('new'),
                    onPressed: state.mutatingRuleIds.contains('new')
                        ? null
                        : () => _createPreset(
                            context,
                            controller,
                            () => ref.read(provider).asData?.value.error,
                            context.l10n.hostFormAutomationCrmPreset,
                            const [
                              HostFormAutomationActionKind.createCrmContact,
                            ],
                          ),
                  ),
                ],
              ),
              if (state.error case final error?) ...[
                gapH12,
                CatchErrorState.fromError(
                  error,
                  context: AppErrorContext.forms,
                  mode: CatchErrorStateMode.compact,
                  onRetry: () => ref.invalidate(provider),
                ),
              ],
              gapH24,
              if (state.rules.isEmpty)
                CatchEmptyState(
                  icon: CatchIcons.autoAwesomeOutlined,
                  title: context.l10n.hostFormAutomationsEmptyTitle,
                  message: context.l10n.hostFormAutomationsEmptyBody,
                )
              else
                CatchSection.fieldRows(
                  title: context.l10n.hostFormAutomationsRules,
                  children: [
                    for (final rule in state.rules)
                      CatchField.toggle(
                        title: rule.name,
                        contract: CatchContractConstraints
                            .organizerFormAutomationRuleDocumentEnabled,
                        body:
                            '${_triggerLabel(context, rule.trigger)} · '
                            '${context.l10n.hostFormAutomationActionCount(count: rule.actions.length)}',
                        value: rule.enabled,
                        status: state.mutatingRuleIds.contains(rule.ruleId)
                            ? CatchFieldStatus.saving
                            : CatchFieldStatus.idle,
                        onChanged: state.mutatingRuleIds.contains(rule.ruleId)
                            ? null
                            : (enabled) => ref
                                  .read(provider.notifier)
                                  .setEnabled(rule, enabled),
                      ),
                  ],
                ),
              if (state.runs.isNotEmpty) ...[
                gapH24,
                CatchSection.fieldRows(
                  title: context.l10n.hostFormAutomationsRuns,
                  children: [
                    for (final run in state.runs)
                      CatchField.read(
                        title: _runStatusLabel(context, run.status),
                        body: context.l10n.hostFormAutomationRunSummary(
                          trigger: run.eventKind,
                          attempt: run.attemptCount,
                        ),
                        valueText: AppTimeFormatters.compactRelativeTime(
                          run.createdAt,
                        ),
                        tone:
                            run.status == HostFormAutomationRunStatus.failed ||
                                run.status ==
                                    HostFormAutomationRunStatus.partiallyFailed
                            ? CatchFieldTone.danger
                            : CatchFieldTone.normal,
                      ),
                  ],
                ),
                if (state.canLoadMore) ...[
                  gapH16,
                  CatchButton(
                    label: context.l10n.hostFormAutomationsLoadMore,
                    variant: CatchButtonVariant.secondary,
                    fullWidth: true,
                    isLoading: state.loadingMore,
                    onPressed: state.loadingMore
                        ? null
                        : () => ref.read(provider.notifier).loadMore(),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createPreset(
    BuildContext context,
    HostFormAutomationsController controller,
    Object? Function() readError,
    String name,
    List<HostFormAutomationActionKind> actions,
  ) async {
    final saved = await controller.createPreset(
      name: name,
      trigger: HostFormAutomationTrigger.responseSubmitted,
      actions: actions,
    );
    if (!saved && context.mounted) {
      final error = readError();
      if (error != null) showCatchErrorSnackBar(context, error);
    }
  }
}

String _triggerLabel(BuildContext context, HostFormAutomationTrigger trigger) =>
    switch (trigger) {
      HostFormAutomationTrigger.responseSubmitted =>
        context.l10n.hostFormAutomationSubmittedTrigger,
      HostFormAutomationTrigger.responseWithdrawn =>
        context.l10n.hostFormAutomationWithdrawnTrigger,
      HostFormAutomationTrigger.answerMatches =>
        context.l10n.hostFormAutomationAnswerTrigger,
    };

String _runStatusLabel(
  BuildContext context,
  HostFormAutomationRunStatus status,
) => switch (status) {
  HostFormAutomationRunStatus.pending => context.l10n.hostFormAutomationPending,
  HostFormAutomationRunStatus.running => context.l10n.hostFormAutomationRunning,
  HostFormAutomationRunStatus.succeeded =>
    context.l10n.hostFormAutomationSucceeded,
  HostFormAutomationRunStatus.partiallyFailed =>
    context.l10n.hostFormAutomationPartiallyFailed,
  HostFormAutomationRunStatus.failed => context.l10n.hostFormAutomationFailed,
  HostFormAutomationRunStatus.skipped => context.l10n.hostFormAutomationSkipped,
};
