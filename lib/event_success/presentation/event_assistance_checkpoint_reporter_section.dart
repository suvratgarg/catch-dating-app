import 'package:catch_dating_app/core/presentation/catch_ui_copy.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/field_constraints.g.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_checkpoint.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

/// Revealed inside request management; choices never grant new group access.
class EventAssistanceCheckpointReporterSection extends StatelessWidget {
  const EventAssistanceCheckpointReporterSection({
    super.key,
    required this.options,
    required this.currentReporterId,
    required this.value,
    required this.onChanged,
  });
  final AssistanceCheckpointReporterOptions options;
  final String currentReporterId;
  final String? value;
  final ValueChanged<String?> onChanged;
  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final alternatives = options.reporters.where(
      (r) => r.operatorId != currentReporterId,
    );
    final named = alternatives
        .where((r) => r.displayName != null || r.operatorId == options.actorUid)
        .toList();
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(l10n.eventAssistanceCheckpointReporterBody),
        gapH8,
        if (named.isNotEmpty)
          CatchField<String>.select(
            key: const ValueKey('checkpoint.request.reporter'),
            copy: catchFieldCopy(l10n),
            title: l10n.eventAssistanceCheckpointReporterLabel,
            contract: CatchContractConstraints
                .reassignEventAssistanceCheckpointReporterCallablePayloadCommandPayloadResponsibleOperatorId,
            values: named.map((r) => r.operatorId).toList(),
            value: value,
            itemLabelBuilder: (id) => id == options.actorUid
                ? l10n.eventAssistanceGroupYou
                : named.firstWhere((r) => r.operatorId == id).displayName!,
            onChanged: onChanged,
          )
        else
          Text(l10n.eventAssistanceCheckpointReporterEmpty),
        if (alternatives.length != named.length)
          Text(l10n.eventAssistanceCheckpointReporterUnnamed),
      ],
    );
  }
}

String checkpointReporterName(
  BuildContext context,
  AssistanceCheckpointReporterOptions? options,
  String id,
) {
  if (id == options?.actorUid) return context.l10n.eventAssistanceGroupYou;
  for (final reporter
      in options?.reporters ?? <AssistanceCheckpointReporterCandidate>[]) {
    if (reporter.operatorId == id && reporter.displayName != null) {
      return reporter.displayName!;
    }
  }
  return context.l10n.eventAssistanceCheckpointReporterUnknown;
}
