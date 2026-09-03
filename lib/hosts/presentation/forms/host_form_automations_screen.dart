import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/presentation/catch_async_value_adapter.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_action.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_route_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/hosts/data/host_crm_repository.dart';
import 'package:catch_dating_app/hosts/domain/host_form_operations.dart';
import 'package:catch_dating_app/hosts/presentation/forms/host_form_operations_controller.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'host_automation_rule_editor.dart';

class HostFormAutomationsScreen extends ConsumerStatefulWidget {
  const HostFormAutomationsScreen({
    super.key,
    required this.organizerId,
    this.formId,
  });

  final String organizerId;
  final String? formId;
  @override
  ConsumerState<HostFormAutomationsScreen> createState() =>
      _HostFormAutomationsScreenState();
}

class _HostFormAutomationsScreenState
    extends ConsumerState<HostFormAutomationsScreen> {
  bool _editing = false;
  HostFormAutomationRule? _selectedRule;
  String get organizerId => widget.organizerId;
  String? get formId => widget.formId;
  @override
  Widget build(BuildContext context) {
    if (_editing) {
      return HostAutomationRuleEditor(
        organizerId: organizerId,
        scopeFormId: formId,
        initialRule: _selectedRule,
        onCancel: () => setState(() => _editing = false),
        onSaved: () {
          ref.invalidate(
            hostFormAutomationsControllerProvider(organizerId, formId),
          );
          setState(() => _editing = false);
        },
      );
    }
    final provider = hostFormAutomationsControllerProvider(organizerId, formId);
    final automations = ref.watch(provider);
    final controller = ref.read(provider.notifier);
    return CatchRouteScaffold(
      topBarBuilder: (context, scrolledUnder) => CatchTopBar(
        title: context.l10n.hostFormAutomationsTitle,
        leadingType: CatchTopBarLeading.back,
        divider: scrolledUnder,
      ),
      body: CatchRouteBody.standardConstrained(
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
                context.l10n.hostAutomationOverview,
                style: CatchTextStyles.supporting(
                  context,
                  color: CatchTokens.of(context).ink2,
                ),
              ),
              gapH16,
              CatchButton(
                label: context.l10n.hostAutomationNew,
                key: const ValueKey('automation-create'),
                onPressed: () => setState(() {
                  _selectedRule = null;
                  _editing = true;
                }),
              ),
              gapH16,
              if (formId != null)
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
                    for (final rule in state.rules) ...[
                      CatchField.nav(
                        title: rule.name,
                        body: context.l10n.hostAutomationEdit,
                        key: ValueKey('automation-edit-${rule.ruleId}'),
                        onTap: () => setState(() {
                          _selectedRule = rule;
                          _editing = true;
                        }),
                      ),
                      CatchField.toggle(
                        title: context.l10n.hostAutomationEnabled,
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
                  ],
                ),
              if (state.runs.isNotEmpty) ...[
                gapH24,
                Text(
                  context.l10n.hostAutomationRunHelp,
                  style: CatchTextStyles.supporting(context),
                ),
                gapH12,
                CatchSection.fieldRows(
                  title: context.l10n.hostFormAutomationsRuns,
                  children: [
                    for (final run in state.runs)
                      CatchField.read(
                        title:
                            '${state.rules.where((r) => r.ruleId == run.ruleId).firstOrNull?.name ?? context.l10n.hostFormAutomationsTitle} · ${_runStatusLabel(context, run.status)}',
                        body: _runBody(context, run),
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
      HostFormAutomationTrigger.applicationAccepted =>
        context.l10n.hostAutomationAccepted,
      HostFormAutomationTrigger.eventAttended =>
        context.l10n.hostAutomationAttended,
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

String _actionLabel(BuildContext context, HostFormAutomationActionKind kind) =>
    switch (kind) {
      HostFormAutomationActionKind.notifyTeam =>
        context.l10n.hostFormAutomationNotifyPreset,
      HostFormAutomationActionKind.createCrmContact =>
        context.l10n.hostFormAutomationCrmPreset,
      HostFormAutomationActionKind.addApplicationQueue =>
        context.l10n.hostAutomationQueue,
      HostFormAutomationActionKind.proposeEventAttendee =>
        context.l10n.hostAutomationAttendee,
      HostFormAutomationActionKind.addOrganizerTag =>
        context.l10n.hostAutomationTag,
      HostFormAutomationActionKind.signedWebhook =>
        context.l10n.hostAutomationWebhook,
      HostFormAutomationActionKind.campaignHandoff =>
        context.l10n.hostAutomationMessage,
    };

String _runBody(BuildContext context, HostFormAutomationRun run) {
  final trigger = switch (run.eventKind) {
    'submitted' => HostFormAutomationTrigger.responseSubmitted,
    'withdrawn' => HostFormAutomationTrigger.responseWithdrawn,
    'applicationAccepted' => HostFormAutomationTrigger.applicationAccepted,
    'eventAttended' => HostFormAutomationTrigger.eventAttended,
    _ => null,
  };
  return [
    context.l10n.hostFormAutomationRunSummary(
      trigger: trigger == null
          ? context.l10n.hostFormAutomationsTitle
          : _triggerLabel(context, trigger),
      attempt: run.attemptCount,
    ),
    if (run.dueAt case final due?)
      '${context.l10n.hostAutomationDue}: ${AppTimeFormatters.dateTime(due.toLocal())}',
    ?run.errorMessage,
    for (final result in run.actionResults)
      if (HostFormAutomationActionKind.values
              .where((k) => k.name == result['kind'])
              .firstOrNull
          case final kind?)
        '${_actionLabel(context, kind)}: ${switch (result['status']) {
          'succeeded' => context.l10n.hostFormAutomationSucceeded,
          'skipped' => context.l10n.hostFormAutomationSkipped,
          _ => context.l10n.hostFormAutomationFailed,
        }}',
  ].join('\n');
}
