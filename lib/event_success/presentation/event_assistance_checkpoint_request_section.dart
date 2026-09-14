import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_banner.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_checkpoint.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_checkpoint_request.dart';
import 'package:catch_dating_app/event_success/presentation/event_assistance_checkpoint_section.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Closing a request resolves the obligation, without inventing arrival evidence.
class EventAssistanceCheckpointRequestSection extends StatefulWidget {
  const EventAssistanceCheckpointRequestSection({
    super.key,
    required this.reviewIdentity,
    required this.contextMessage,
    required this.request,
    required this.eligibility,
    required this.canClose,
    required this.canReopen,
    required this.phase,
    required this.onConfirm,
    required this.onRetry,
    required this.onReload,
    required this.onDone,
    this.submittedDecision,
    this.error,
    this.observationSummary,
    this.checkpointLabel,
  });
  final Object reviewIdentity;
  final String contextMessage;
  final AssistanceCheckpointRequest? request;
  final AssistanceCheckpointCloseoutEligibility? eligibility;
  final bool canClose, canReopen;
  final EventAssistanceCheckpointPhase phase;
  final CheckpointRequestDecision? submittedDecision;
  final Object? error;
  final String? observationSummary, checkpointLabel;
  final ValueChanged<CheckpointRequestDecision> onConfirm;
  final VoidCallback onRetry, onReload, onDone;
  @override
  State<EventAssistanceCheckpointRequestSection> createState() =>
      _EventAssistanceCheckpointRequestSectionState();
}

class _EventAssistanceCheckpointRequestSectionState
    extends State<EventAssistanceCheckpointRequestSection> {
  final _reason = TextEditingController();
  @override
  void initState() {
    super.initState();
    _reason.text = widget.submittedDecision?.reason ?? '';
  }

  @override
  void didUpdateWidget(covariant EventAssistanceCheckpointRequestSection old) {
    super.didUpdateWidget(old);
    if (!identical(widget.reviewIdentity, old.reviewIdentity)) {
      _reason.text = widget.submittedDecision?.reason ?? '';
    }
  }

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final ready = widget.phase == EventAssistanceCheckpointPhase.ready;
    final busy = widget.phase == EventAssistanceCheckpointPhase.submitting;
    final decision = widget.submittedDecision;
    final validReason =
        _reason.text.trim().isNotEmpty && _reason.text.trim().length <= 500;
    final eligibility = widget.eligibility;
    final due = widget.request == null
        ? null
        : DateTime.fromMillisecondsSinceEpoch(widget.request!.dueAt);
    final local = MaterialLocalizations.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.contextMessage),
        if (widget.checkpointLabel case final label?) ...[
          gapH8,
          Text(label, style: CatchTextStyles.titleL(context)),
        ],
        gapH12,
        Text(l10n.eventAssistanceCheckpointRequestBody),
        if (assistanceCheckpointRequestCopy(context, widget.request)
            case final status?) ...[
          gapH12,
          Text(status),
        ],
        if (due != null) ...[
          gapH8,
          Text(
            l10n.eventAssistanceCheckpointDue(
              deadline:
                  '${local.formatMediumDate(due)} · ${local.formatTimeOfDay(TimeOfDay.fromDateTime(due))}',
            ),
          ),
        ],
        if (widget.observationSummary case final summary?) ...[
          gapH8,
          Text(summary, style: CatchTextStyles.labelL(context)),
        ],
        if (ready) ...[
          gapH12,
          Text(
            widget.request == null
                ? l10n.eventAssistanceCheckpointRequestMissing
                : eligibility == null
                ? l10n.eventAssistanceCheckpointRequestUnknown
                : switch (eligibility) {
                    AssistanceCheckpointCloseoutReady() =>
                      l10n.eventAssistanceCheckpointRequestReady,
                    AssistanceCheckpointCloseoutUnavailable(:final reason) =>
                      switch (reason) {
                        AssistanceCheckpointCloseoutUnavailableReason
                            .sourceUnavailable =>
                          l10n.eventAssistanceCheckpointSetupChanged,
                        AssistanceCheckpointCloseoutUnavailableReason
                            .reportMissing =>
                          l10n.eventAssistanceCheckpointRequestReportFirst,
                        AssistanceCheckpointCloseoutUnavailableReason
                            .reportComplete =>
                          l10n.eventAssistanceCheckpointComplete,
                        AssistanceCheckpointCloseoutUnavailableReason
                            .unresolvedMembers =>
                          l10n.eventAssistanceCheckpointRequestResolveFirst,
                        AssistanceCheckpointCloseoutUnavailableReason
                            .alreadyClosed =>
                          l10n.eventAssistanceCheckpointClosedOut,
                      },
                  },
          ),
          if (widget.canClose || widget.canReopen) ...[
            gapH12,
            CatchField.input(
              key: const ValueKey('checkpoint.request.reason'),
              copy: catchFieldCopy(l10n),
              title: l10n.eventAssistanceCheckpointRequestReason,
              contract: CatchContractConstraints
                  .setEventAssistanceCheckpointCloseoutCallablePayloadCommandPayloadReason,
              controller: _reason,
              minLines: 2,
              maxLines: 4,
              onChanged: (_) => setState(() {}),
            ),
            gapH12,
            if (widget.canClose)
              CatchButton(
                key: const ValueKey('checkpoint.request.close'),
                label: l10n.eventAssistanceCheckpointRequestClose,
                onPressed: validReason
                    ? () =>
                          widget.onConfirm(CloseCheckpointRequest(_reason.text))
                    : null,
              ),
            if (widget.canReopen) ...[
              gapH8,
              CatchButton(
                key: const ValueKey('checkpoint.request.reopen'),
                label: l10n.eventAssistanceCheckpointRequestReopen,
                variant: CatchButtonVariant.secondary,
                onPressed: validReason
                    ? () => widget.onConfirm(
                        ReopenCheckpointRequest(_reason.text),
                      )
                    : null,
              ),
            ],
          ] else if (widget.request != null) ...[
            gapH8,
            Text(l10n.eventAssistanceCheckpointRequestAuthority),
          ],
        ] else ...[
          gapH12,
          Text(switch (widget.phase) {
            EventAssistanceCheckpointPhase.submitting =>
              l10n.eventAssistanceCheckpointRequestSaving,
            EventAssistanceCheckpointPhase.retryRequired =>
              l10n.eventAssistanceCheckpointRequestUnconfirmed,
            EventAssistanceCheckpointPhase.refreshRequired =>
              l10n.eventAssistanceCheckpointChanged,
            EventAssistanceCheckpointPhase.saved =>
              l10n.eventAssistanceCheckpointRequestSaved,
            EventAssistanceCheckpointPhase.unavailable =>
              l10n.eventAssistanceCheckpointRequestAuthority,
            EventAssistanceCheckpointPhase.ready => '',
          }),
          if ((busy ||
                  widget.phase ==
                      EventAssistanceCheckpointPhase.retryRequired) &&
              decision != null) ...[
            gapH8,
            Text(switch (decision) {
              CloseCheckpointRequest() =>
                l10n.eventAssistanceCheckpointRequestClose,
              ReopenCheckpointRequest() =>
                l10n.eventAssistanceCheckpointRequestReopen,
              ReassignCheckpointReporter() =>
                l10n.eventAssistanceCheckpointRequestReassign,
            }, style: CatchTextStyles.labelL(context)),
            gapH8,
            Text(decision.reason),
          ],
        ],
        if (widget.error != null) ...[
          gapH12,
          CatchLocalizedErrorBanner(widget.error!),
        ],
        if (widget.phase == EventAssistanceCheckpointPhase.retryRequired) ...[
          gapH12,
          CatchButton(
            label: l10n.eventAssistanceCheckpointRequestRetry,
            onPressed: widget.onRetry,
          ),
        ],
        if (ready ||
            widget.phase == EventAssistanceCheckpointPhase.refreshRequired) ...[
          gapH8,
          CatchButton(
            label: l10n.eventAssistanceCheckpointReload,
            variant: CatchButtonVariant.ghost,
            onPressed: widget.onReload,
          ),
        ],
        gapH8,
        CatchButton(
          label: l10n.eventAssistanceVisitDone,
          variant: CatchButtonVariant.ghost,
          status: busy ? CatchButtonStatus.loading : CatchButtonStatus.idle,
          onPressed: busy ? null : widget.onDone,
        ),
      ],
    );
  }
}
