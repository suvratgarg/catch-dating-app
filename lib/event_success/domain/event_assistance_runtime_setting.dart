import 'package:catch_dating_app/event_success/domain/event_assistance_parsing.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_configuration.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_scope.dart';

sealed class AssistanceRuntimeCommand {
  const AssistanceRuntimeCommand();
  Map<String, Object?> toJson();
}

final class AssistanceRuntimeConfigure extends AssistanceRuntimeCommand {
  const AssistanceRuntimeConfigure(this.configuration);
  final AssistanceRuntimeConfiguration configuration;
  @override
  Map<String, Object?> toJson() => {
    'kind': 'configure',
    'configuration': configuration.toJson(),
  };
}

final class AssistanceRuntimePause extends AssistanceRuntimeCommand {
  const AssistanceRuntimePause();
  @override
  Map<String, Object?> toJson() => {'kind': 'pause'};
}

enum AssistanceRuntimeRecordStatus { enabled, paused }

enum AssistanceRuntimeStatus {
  unconfigured,
  paused,
  sourceChanged,
  expired,
  eventClosed,
  configured,
}

final class AssistanceRuntimeRecord {
  const AssistanceRuntimeRecord._({
    required this.revision,
    required this.status,
    required this.configuration,
    required this.sourceHash,
    required this.sourceGeneration,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });
  final int revision;
  final AssistanceRuntimeRecordStatus status;
  final AssistanceRuntimeConfiguration? configuration;
  final String sourceHash;
  final String sourceGeneration;
  final String updatedBy;
  final int createdAt;
  final int updatedAt;
  factory AssistanceRuntimeRecord.fromJson(
    Object? value,
    EventAssistanceRuntimeScope scope,
    int now,
  ) {
    final map = assistanceObject(value, {
      'schemaVersion',
      'runtimeId',
      'context',
      'workflowKind',
      'revision',
      'status',
      'configuration',
      'sourceHash',
      'sourceGeneration',
      'updatedBy',
      'createdAt',
      'updatedAt',
    });
    scope.requireMatch(map['context']);
    final revision = assistanceInteger(map['revision']);
    final created = assistanceInteger(map['createdAt']);
    final updated = assistanceInteger(map['updatedAt']);
    final status = assistanceEnum(
      AssistanceRuntimeRecordStatus.values,
      map['status'],
    );
    final configuration = map['configuration'] == null
        ? null
        : AssistanceRuntimeConfiguration.fromJson(map['configuration']);
    if (map['schemaVersion'] != 1 ||
        map['workflowKind'] != 'lateJoin' ||
        map['runtimeId'] is! String ||
        !RegExp(
          r'^runtime:lateJoin:[a-f0-9]{64}$',
        ).hasMatch(map['runtimeId']! as String) ||
        revision == 0 ||
        created > updated ||
        updated > now ||
        status == AssistanceRuntimeRecordStatus.enabled &&
            configuration == null) {
      throw const FormatException('Invalid saved event automation.');
    }
    return AssistanceRuntimeRecord._(
      revision: revision,
      status: status,
      configuration: configuration,
      sourceHash: assistanceHash(map['sourceHash']),
      sourceGeneration: assistanceHash(map['sourceGeneration']),
      updatedBy: assistanceText(map['updatedBy']),
      createdAt: created,
      updatedAt: updated,
    );
  }
}

/// Saved permission and its availability, without implying enrollment or sends.
final class AssistanceRuntimeView {
  const AssistanceRuntimeView._({
    required this.scope,
    required this.serverTime,
    required this.sourceHash,
    required this.revision,
    required this.runtime,
    required this.status,
    required this.canConfigure,
    required this.eventEnd,
  });
  final EventAssistanceRuntimeScope scope;
  final int serverTime;
  final String sourceHash;
  final int revision;
  final AssistanceRuntimeRecord? runtime;
  final AssistanceRuntimeStatus status;
  final bool canConfigure;
  final int eventEnd;
  factory AssistanceRuntimeView.fromJson(
    Object? value, {
    required EventAssistanceRuntimeScope expectedScope,
  }) {
    final map = assistanceObject(value, {
      'context',
      'serverTime',
      'sourceHash',
      'revision',
      'runtime',
      'status',
      'canConfigure',
      'eventEnd',
    });
    expectedScope.requireMatch(map['context']);
    final now = assistanceInteger(map['serverTime']);
    final runtime = map['runtime'] == null
        ? null
        : AssistanceRuntimeRecord.fromJson(map['runtime'], expectedScope, now);
    final view = AssistanceRuntimeView._(
      scope: expectedScope,
      serverTime: now,
      sourceHash: assistanceHash(map['sourceHash']),
      revision: assistanceInteger(map['revision']),
      runtime: runtime,
      status: assistanceEnum(AssistanceRuntimeStatus.values, map['status']),
      canConfigure: assistanceBoolean(map['canConfigure']),
      eventEnd: assistanceInteger(map['eventEnd']),
    );
    view._validate();
    return view;
  }
  void _validate() {
    if (revision != (runtime?.revision ?? 0) ||
        canConfigure && eventEnd <= serverTime) {
      throw const FormatException(
        'Inconsistent event automation revision or window.',
      );
    }
    final enabled = runtime?.status == AssistanceRuntimeRecordStatus.enabled;
    final valid = switch (status) {
      AssistanceRuntimeStatus.unconfigured => runtime == null,
      AssistanceRuntimeStatus.paused =>
        runtime?.status == AssistanceRuntimeRecordStatus.paused,
      AssistanceRuntimeStatus.eventClosed => enabled && !canConfigure,
      AssistanceRuntimeStatus.sourceChanged => enabled,
      AssistanceRuntimeStatus.expired =>
        enabled &&
            runtime!.sourceHash == sourceHash &&
            runtime!.configuration!.expiresAt <= serverTime,
      AssistanceRuntimeStatus.configured =>
        enabled &&
            canConfigure &&
            runtime!.sourceHash == sourceHash &&
            runtime!.configuration!.expiresAt > serverTime &&
            runtime!.configuration!.expiresAt <= eventEnd,
    };
    if (!valid) {
      throw const FormatException('Inconsistent event automation state.');
    }
  }

  AssistanceRuntimeChange prepareChange({
    required String requestId,
    required AssistanceRuntimeCommand command,
  }) {
    assistanceId(requestId);
    if (revision == 9007199254740991) {
      throw StateError('Automation revision exhausted.');
    }
    if (command case AssistanceRuntimeConfigure(:final configuration)) {
      if (!canConfigure ||
          configuration.expiresAt <= serverTime ||
          configuration.expiresAt > eventEnd) {
        throw StateError('Configure execution within the current open event.');
      }
    }
    return AssistanceRuntimeChange._(this, requestId, command);
  }
}

/// Keeps pause and configure distinct; retries never replace the reviewed basis.
final class AssistanceRuntimeChange {
  const AssistanceRuntimeChange._(this.snapshot, this.requestId, this.command);
  final AssistanceRuntimeView snapshot;
  final String requestId;
  final AssistanceRuntimeCommand command;
  Map<String, Object?> toJson() => {
    'context': snapshot.scope.context,
    'requestId': requestId,
    'expectedRevision': snapshot.revision,
    'expectedSourceHash': snapshot.sourceHash,
    'command': command.toJson(),
  };
}
