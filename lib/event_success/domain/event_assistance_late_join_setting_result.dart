import 'dart:convert';

import 'package:catch_dating_app/event_success/domain/event_assistance_group_progress.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_setting.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_parsing.dart';

enum AssistanceSettingOutcome { read, applied, replayed }

final class LateJoinSettingResult {
  const LateJoinSettingResult._(
    this.outcome,
    this.operationRevision,
    this.view,
  );
  final AssistanceSettingOutcome outcome;
  final int? operationRevision;
  final LateJoinSettingView view;

  factory LateJoinSettingResult.fromCallableData(
    Object? value, {
    required EventAssistanceGroupScope expectedScope,
    LateJoinSettingChange? expectedChange,
  }) {
    final map = assistanceObject(value, {
      'outcome',
      'operationRevision',
      'view',
    });
    final outcome = assistanceEnum(
      AssistanceSettingOutcome.values,
      map['outcome'],
    );
    final revision = assistanceNullableInteger(map['operationRevision']);
    final view = LateJoinSettingView.fromJson(
      map['view'],
      expectedScope: expectedScope,
    );
    if (expectedChange == null) {
      if (outcome != AssistanceSettingOutcome.read || revision != null) {
        _invalid();
      }
    } else {
      if (expectedChange.snapshot.scope != expectedScope ||
          outcome == AssistanceSettingOutcome.read ||
          revision != expectedChange.snapshot.ownRevision + 1 ||
          revision! > view.ownRevision ||
          view.serverTime < expectedChange.snapshot.serverTime) {
        _invalid();
      }
      // A replay carries the original receipt and the latest effective state.
      if (outcome == AssistanceSettingOutcome.applied &&
          (revision != view.ownRevision ||
              view.sourceHash != expectedChange.snapshot.sourceHash ||
              view.own?.sourceHash != view.sourceHash ||
              jsonEncode(view.own?.preference.toJson()) !=
                  jsonEncode(expectedChange.preference.toJson()))) {
        _invalid();
      }
    }
    return LateJoinSettingResult._(outcome, revision, view);
  }
}

Never _invalid() =>
    throw const FormatException('Invalid assistance setting result.');
