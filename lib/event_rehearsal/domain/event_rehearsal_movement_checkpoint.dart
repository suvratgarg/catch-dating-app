part of 'event_rehearsal_movement.dart';

final class RehearsalMovementCheckpoint {
  const RehearsalMovementCheckpoint._(
    this.record,
    this.checkpointId,
    this.sourceHash,
    this.availability,
    this.request,
  );
  final RehearsalMovementRecord record;
  final String checkpointId, sourceHash;
  final AssistanceCheckpointAvailability availability;
  final AssistanceCheckpointRequest? request;
  int get progressRevision => record.revision;
  int get revision => record.report?.revision ?? 0;
  RehearsalDeparture get departure => record.departure;
  RehearsalCheckpointReport? get report => record.report;

  factory RehearsalMovementCheckpoint._parse(
    Object? raw,
    RehearsalMovementScope scope,
    EventRehearsalSession session, {
    required String sourceHash,
    required List<RehearsalMovementDestination> destinations,
    required RehearsalMovementRecord? selected,
  }) {
    final m = assistanceObject(raw, {
      'progressRevision',
      'checkpointId',
      'sourceHash',
      'revision',
      'availability',
      'report',
      'request',
      'departure',
    });
    if (selected == null ||
        selected.departure.checkpointId == null ||
        assistanceInteger(m['progressRevision']) != selected.revision ||
        m['checkpointId'] != selected.departure.checkpointId ||
        assistanceInteger(m['revision']) != (selected.report?.revision ?? 0) ||
        _movementHash(m['departure']) != selected.departure.hash ||
        _movementHash(m['report']) !=
            _movementHash(selected.report?.toJson())) {
      throw const FormatException(
        'Checkpoint does not describe the selected departure.',
      );
    }
    final departure = selected.departure;
    final report = selected.report;
    final available = AssistanceCheckpointAvailability.fromJson(
      m['availability'],
      now: session.virtualNow.millisecondsSinceEpoch,
      accountedFor: report?.accountedFor,
    );
    final destination = destinations
        .where((d) => d.target == departure.destination)
        .firstOrNull;
    final reason = departure.roster == null
        ? AssistanceCheckpointUnavailableReason.rosterNotRecorded
        : departure.sourceHash != sourceHash || destination == null
        ? AssistanceCheckpointUnavailableReason.setupChanged
        : null;
    if (reason != null) {
      if (available is! AssistanceCheckpointUnavailable ||
          available.reason != reason) {
        throw const FormatException(
          'Checkpoint availability contradicts its source.',
        );
      }
    } else {
      final context = {
        'mode': 'rehearsal',
        'rehearsalId': scope.sessionId,
        'virtualEventId': 'practice:${_movementHash(scope.sessionId)}',
        'clockId': scope.clockId,
      };
      final rosterId =
          'departure-roster:${_movementHash([context, scope.groupId, selected.revision])}';
      if (available is! AssistanceCheckpointRoster ||
          available.rosterId != rosterId ||
          available.label != destination!.label ||
          _movementHash(available.members.map((m) => m.attendeeId).toList()) !=
              _movementHash(
                departure.roster!.members.map((m) => m.attendeeId).toList(),
              )) {
        throw const FormatException(
          'Checkpoint observations lost the original roster.',
        );
      }
    }
    final request = m['request'] == null
        ? null
        : AssistanceCheckpointRequest.fromJson(m['request']);
    final original = departure.checkpointRequest;
    final complete =
        report != null &&
        report.accountedFor.length == departure.roster?.members.length;
    final expected = complete
        ? AssistanceCheckpointRequestState.complete
        : available is! AssistanceCheckpointRoster
        ? AssistanceCheckpointRequestState.sourceUnavailable
        : report != null
        ? AssistanceCheckpointRequestState.discrepancy
        : session.virtualNow.millisecondsSinceEpoch >= (original?.dueAt ?? 0)
        ? AssistanceCheckpointRequestState.overdue
        : AssistanceCheckpointRequestState.awaitingReport;
    if ((request == null) != (original == null) ||
        request != null &&
            (request.responsibleOperatorId != original!.responsibleOperatorId ||
                request.dueAt != original.dueAt ||
                request.state != expected)) {
      throw const FormatException(
        'Checkpoint request contradicts its departure or observations.',
      );
    }
    return RehearsalMovementCheckpoint._(
      selected,
      assistanceText(m['checkpointId']),
      assistanceHash(m['sourceHash']),
      available,
      request,
    );
  }
}
