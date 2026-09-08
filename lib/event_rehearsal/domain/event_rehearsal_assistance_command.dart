import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_assistance_plan.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_assistance_view.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_parsing.dart';

enum RehearsalConfirmedDelivery { accepted, delivered, read, revoked }

enum RehearsalDeliveryFailure {
  technical,
  policy,
  suppressed,
  invalidRecipient,
}

enum RehearsalDeliveryUncertainty { timeout, connectionLost, workerInterrupted }

sealed class RehearsalDeliveryOutcome {
  const RehearsalDeliveryOutcome();
  Map<String, Object?> toJson();
}

sealed class RehearsalConfirmedOutcome extends RehearsalDeliveryOutcome {
  const RehearsalConfirmedOutcome();
}

final class RehearsalDeliveryConfirmed extends RehearsalConfirmedOutcome {
  const RehearsalDeliveryConfirmed(this.result);
  final RehearsalConfirmedDelivery result;
  @override
  Map<String, Object?> toJson() => {'kind': result.name};
}

final class RehearsalDeliveryFailed extends RehearsalConfirmedOutcome {
  const RehearsalDeliveryFailed(this.classification);
  final RehearsalDeliveryFailure classification;
  @override
  Map<String, Object?> toJson() => {
    'kind': 'failed',
    'classification': classification.name,
  };
}

final class RehearsalDeliveryUnknown extends RehearsalDeliveryOutcome {
  const RehearsalDeliveryUnknown(this.reason);
  final RehearsalDeliveryUncertainty reason;
  @override
  Map<String, Object?> toJson() => {'kind': 'unknown', 'reason': reason.name};
}

sealed class RehearsalAssistanceCommand {
  RehearsalAssistanceCommand(this.actorId) {
    assistanceId(actorId);
  }
  final String actorId;
  String get kind;
  Map<String, Object?> toJson();
}

final class RehearsalPublishInstruction extends RehearsalAssistanceCommand {
  RehearsalPublishInstruction({required String actorId, required this.plan})
    : super(actorId);
  final RehearsalAssistancePlan plan;
  @override
  String get kind => 'publish';
  @override
  Map<String, Object?> toJson() => {
    'kind': kind,
    'actorId': actorId,
    'plan': plan.toJson(),
  };
}

final class RehearsalDispatchMessage extends RehearsalAssistanceCommand {
  RehearsalDispatchMessage({
    required String actorId,
    required String messageId,
    required this.outcome,
  }) : messageId = rehearsalMessageId(messageId),
       super(actorId);
  final String messageId;
  final RehearsalDeliveryOutcome outcome;
  @override
  String get kind => 'dispatch';
  @override
  Map<String, Object?> toJson() => {
    'kind': kind,
    'actorId': actorId,
    'messageId': messageId,
    'outcome': outcome.toJson(),
  };
}

final class RehearsalRecordReceipt extends RehearsalAssistanceCommand {
  RehearsalRecordReceipt({
    required String actorId,
    required String messageId,
    required this.attemptId,
    required this.outcome,
  }) : messageId = rehearsalMessageId(messageId),
       super(actorId) {
    assistanceId(attemptId);
  }
  final String messageId;
  final String attemptId;
  final RehearsalConfirmedOutcome outcome;
  @override
  String get kind => 'receipt';
  @override
  Map<String, Object?> toJson() => {
    'kind': kind,
    'actorId': actorId,
    'messageId': messageId,
    'attemptId': attemptId,
    'outcome': outcome.toJson(),
  };
}

/// Frozen review scope. Retrying never changes the revision or request identity.
final class RehearsalAssistanceChange {
  RehearsalAssistanceChange({
    required EventRehearsalBootstrap snapshot,
    required this.command,
    required this.clientActionId,
  }) : session = snapshot.session {
    if (!RegExp(r'^[A-Za-z0-9_-]{8,120}$').hasMatch(clientActionId) ||
        !snapshot.actors.any((actor) => actor.actorId == command.actorId) ||
        session.actionCount >= 500 ||
        !([
              EventRehearsalStatus.running,
              EventRehearsalStatus.paused,
            ].contains(session.status) ||
            command is RehearsalRecordReceipt &&
                session.status == EventRehearsalStatus.complete)) {
      throw const FormatException(
        'Refresh this practice review before continuing.',
      );
    }
  }
  final EventRehearsalSession session;
  final RehearsalAssistanceCommand command;
  final String clientActionId;
  Map<String, Object?> toJson() => {
    'sessionId': session.id,
    'expectedRevision': session.runtimeRevision,
    'expectedSetupRevision': session.setupRevision,
    'clientActionId': clientActionId,
    'action': 'assistance',
    'assistance': command.toJson(),
  };

  void requireResult(EventRehearsalBootstrap result) {
    if (result.session.id != session.id ||
        result.session.organizerId != session.organizerId ||
        result.session.setupRevision != session.setupRevision ||
        result.session.runtimeRevision <= session.runtimeRevision ||
        !result.actions.any(
          (action) =>
              action.clientActionId == clientActionId &&
              action.actorId == command.actorId &&
              action.kind == 'control' &&
              action.name == 'assistance:${command.kind}' &&
              action.runtimeRevision == session.runtimeRevision + 1,
        )) {
      throw const FormatException(
        'Practice response does not confirm this command.',
      );
    }
  }
}
