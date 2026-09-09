import 'dart:convert';

import 'package:catch_dating_app/event_success/domain/event_assistance_parsing.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_scope.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_setting.dart';

enum AssistanceRuntimeOutcome { read, applied, replayed }

final class AssistanceRuntimeResult {
  const AssistanceRuntimeResult._(
    this.outcome,
    this.operationRevision,
    this.view,
  );
  final AssistanceRuntimeOutcome outcome;
  final int? operationRevision;
  final AssistanceRuntimeView view;
  factory AssistanceRuntimeResult.fromCallableData(
    Object? value, {
    required EventAssistanceRuntimeScope expectedScope,
    AssistanceRuntimeChange? expectedChange,
  }) {
    final map = assistanceObject(value, {
      'outcome',
      'operationRevision',
      'view',
    });
    final outcome = assistanceEnum(
      AssistanceRuntimeOutcome.values,
      map['outcome'],
    );
    final revision = assistanceNullableInteger(map['operationRevision']);
    final view = AssistanceRuntimeView.fromJson(
      map['view'],
      expectedScope: expectedScope,
    );
    if (expectedChange == null) {
      if (outcome != AssistanceRuntimeOutcome.read || revision != null) {
        _invalid();
      }
    } else {
      if (expectedScope != expectedChange.snapshot.scope ||
          outcome == AssistanceRuntimeOutcome.read ||
          revision != expectedChange.snapshot.revision + 1 ||
          revision! > view.revision ||
          view.serverTime < expectedChange.snapshot.serverTime) {
        _invalid();
      }
      if (outcome == AssistanceRuntimeOutcome.applied) {
        if (view.revision != revision ||
            view.sourceHash != expectedChange.snapshot.sourceHash ||
            view.runtime?.sourceHash != view.sourceHash) {
          _invalid();
        }
        final command = expectedChange.command;
        final expectedStatus = command is AssistanceRuntimeConfigure
            ? AssistanceRuntimeRecordStatus.enabled
            : AssistanceRuntimeRecordStatus.paused;
        final configuration = command is AssistanceRuntimeConfigure
            ? command.configuration
            : expectedChange.snapshot.runtime?.configuration;
        if (view.runtime?.status != expectedStatus ||
            jsonEncode(view.runtime?.configuration?.toJson()) !=
                jsonEncode(configuration?.toJson())) {
          _invalid();
        }
      }
    }
    return AssistanceRuntimeResult._(outcome, revision, view);
  }
}

Never _invalid() =>
    throw const FormatException('Invalid event automation confirmation.');
