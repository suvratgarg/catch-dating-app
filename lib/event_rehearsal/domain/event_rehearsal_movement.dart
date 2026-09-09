import 'dart:convert';

import 'package:catch_dating_app/core/cryptography/sha256_digest.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_checkpoint.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_departure.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_observation.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_parsing.dart';

part 'event_rehearsal_movement_records.dart';
part 'event_rehearsal_checkpoint_management_records.dart';
part 'event_rehearsal_checkpoint_management_review.dart';
part 'event_rehearsal_movement_checkpoint.dart';

typedef RehearsalMovementScope = ({
  String sessionId,
  String organizerId,
  int setupRevision,
  String clockId,
  String groupId,
});
RehearsalMovementScope rehearsalMovementScope(
  EventRehearsalSession session,
  String groupId,
) {
  final start = session.virtualStartedAt?.millisecondsSinceEpoch;
  if (start == null ||
      start < 0 ||
      session.setupRevision < 0 ||
      session.setupRevision > 2147483647) {
    throw const FormatException('Review the current rehearsal generation.');
  }
  return (
    sessionId: _movementId(session.id),
    organizerId: _movementId(session.organizerId),
    setupRevision: session.setupRevision,
    groupId: _movementId(groupId),
    clockId:
        'clock:${_movementHash([session.id, start, session.setupRevision])}',
  );
}

final class RehearsalMovementSelection {
  RehearsalMovementSelection({
    required this.scope,
    this.progressRevision,
    this.beforeRevision,
  }) {
    if (progressRevision != null) {
      _movementRevision(progressRevision, positive: true);
    }
    if (beforeRevision != null &&
        (beforeRevision! < 1 || beforeRevision! > 501)) {
      throw const FormatException('Invalid movement history cursor.');
    }
  }
  final RehearsalMovementScope scope;
  final int? progressRevision, beforeRevision;
  Map<String, Object?> toJson() => {
    'groupId': scope.groupId,
    if (progressRevision != null) 'progressRevision': progressRevision,
    if (beforeRevision != null) 'beforeRevision': beforeRevision,
  };
  @override
  bool operator ==(Object other) =>
      other is RehearsalMovementSelection &&
      scope == other.scope &&
      progressRevision == other.progressRevision &&
      beforeRevision == other.beforeRevision;
  @override
  int get hashCode => Object.hash(scope, progressRevision, beforeRevision);
}

typedef RehearsalMovementGroup = ({String groupId, String label});
typedef RehearsalMovementDestination = ({
  AssistanceJoiningTarget target,
  String label,
  String text,
});

enum RehearsalDepartureUnavailableReason {
  notCheckedIn,
  participationUnavailable,
  membershipUnavailable,
  invalidSource,
}

/// Current candidates and recorded departure visits are separate observations.
final class RehearsalMovementReview {
  const RehearsalMovementReview._({
    required this.selection,
    required this.session,
    required this.actorUid,
    required this.groups,
    required this.revision,
    required this.sourceHash,
    required this.eventOpen,
    required this.runtimeLive,
    required this.destinations,
    required this.current,
    required this.guidance,
    required this.selected,
    required this.rosterSourceHash,
    required this.candidates,
    required this.unavailable,
    required this.checkpoint,
    required this.history,
    required this.nextBeforeRevision,
  });
  final RehearsalMovementSelection selection;
  RehearsalMovementScope get scope => selection.scope;
  final EventRehearsalSession session;
  final String actorUid, sourceHash, rosterSourceHash;
  final int revision;
  final bool eventOpen, runtimeLive;
  final List<RehearsalMovementGroup> groups;
  final List<RehearsalMovementDestination> destinations;
  final RehearsalMovementRecord? current, selected;
  final AssistanceJoiningGuidance? guidance;
  final List<RehearsalDepartureMember> candidates;
  final Map<String, RehearsalDepartureUnavailableReason> unavailable;
  final RehearsalMovementCheckpoint? checkpoint;
  final List<RehearsalMovementSummary> history;
  final int? nextBeforeRevision;
  int get serverTime => session.virtualNow.millisecondsSinceEpoch;
  int get endAt =>
      session.virtualStartedAt!.millisecondsSinceEpoch +
      session.setup.durationMinutes * 60000;
  bool get canConfirm =>
      revision < 500 &&
      eventOpen &&
      runtimeLive &&
      destinations.isNotEmpty &&
      session.actionCount < 500 &&
      session.runtimeRevision < 2147483647;
  bool get canReport =>
      checkpoint?.availability is AssistanceCheckpointRoster &&
      session.actionCount < 500 &&
      session.runtimeRevision < 2147483647 &&
      [
        EventRehearsalStatus.running,
        EventRehearsalStatus.paused,
        EventRehearsalStatus.complete,
      ].contains(session.status);

  factory RehearsalMovementReview.fromBootstrapJson(
    Object? value, {
    required EventRehearsalSession session,
    required List<EventRehearsalActor> actors,
  }) {
    final m = assistanceObject(value);
    final selected = m['selected'] == null
        ? null
        : assistanceObject(m['selected']);
    return RehearsalMovementReview.fromJson(
      value,
      session: session,
      actors: actors,
      selection: RehearsalMovementSelection(
        scope: rehearsalMovementScope(session, _movementId(m['groupId'])),
        progressRevision: selected == null
            ? null
            : _movementRevision(selected['progressRevision'], positive: true),
      ),
    );
  }

  factory RehearsalMovementReview.fromJson(
    Object? value, {
    required EventRehearsalSession session,
    required List<EventRehearsalActor> actors,
    required RehearsalMovementSelection selection,
    String? expectedActorUid,
  }) {
    final root = assistanceObject(value, {
      'sessionId',
      'organizerId',
      'clockId',
      'setupRevision',
      'runtimeRevision',
      'actorUid',
      'serverTime',
      'groupId',
      'groups',
      'progress',
      'roster',
      'selected',
      'checkpoint',
      'history',
      'nextBeforeRevision',
    });
    final scope = selection.scope;
    final now = session.virtualNow.millisecondsSinceEpoch;
    final uid = _movementId(root['actorUid']);
    final end = session.virtualStartedAt?.millisecondsSinceEpoch;
    if (scope != rehearsalMovementScope(session, scope.groupId) ||
        root['sessionId'] != scope.sessionId ||
        root['organizerId'] != scope.organizerId ||
        root['clockId'] != scope.clockId ||
        root['groupId'] != scope.groupId ||
        assistanceInteger(root['setupRevision']) != scope.setupRevision ||
        assistanceInteger(root['runtimeRevision']) != session.runtimeRevision ||
        assistanceInteger(root['serverTime']) != now ||
        expectedActorUid != null && uid != expectedActorUid ||
        end == null ||
        now < end ||
        session.actorCount < 2 ||
        session.actorCount > 50 ||
        session.actionCount < 0 ||
        session.actionCount > 500 ||
        session.runtimeRevision < 0 ||
        session.runtimeRevision > 2147483647 ||
        actors.length != session.actorCount ||
        actors.map((a) => a.actorId).toSet().length != actors.length) {
      throw const FormatException(
        'Movement review belongs to another snapshot.',
      );
    }
    final groups = _movementList(root['groups'], 41).map((v) {
      final m = assistanceObject(v, {'groupId', 'label'});
      return (
        groupId: _movementId(m['groupId']),
        label: assistanceText(m['label'], 500),
      );
    }).toList();
    if (!groups.any((g) => g.groupId == 'event:whole') ||
        !groups.any((g) => g.groupId == scope.groupId) ||
        groups.map((g) => g.groupId).toSet().length != groups.length) {
      throw const FormatException('Invalid rehearsal movement groups.');
    }
    final progress = assistanceObject(root['progress'], {
      'revision',
      'sourceHash',
      'eventOpen',
      'runtimeLive',
      'destinations',
      'current',
      'guidance',
    });
    final revision = _movementRevision(progress['revision']);
    final sourceHash = assistanceHash(progress['sourceHash']);
    final runtimeLive = assistanceBoolean(progress['runtimeLive']);
    final eventOpen = assistanceBoolean(progress['eventOpen']);
    final expectedLive = [
      EventRehearsalStatus.running,
      EventRehearsalStatus.paused,
    ].contains(session.status);
    if (runtimeLive != expectedLive ||
        eventOpen !=
            (expectedLive &&
                now < end + session.setup.durationMinutes * 60000)) {
      throw const FormatException(
        'Movement runtime readiness is inconsistent.',
      );
    }
    final destinations = _movementList(progress['destinations'], 41).map((v) {
      final m = assistanceObject(v, {'target', 'label', 'text'});
      return (
        target: _movementTarget(m['target'], scope),
        label: assistanceText(m['label'], 500),
        text: assistanceText(m['text'], 4000),
      );
    }).toList();
    if (destinations.map((d) => d.target).toSet().length !=
        destinations.length) {
      throw const FormatException('Duplicate rehearsal destination.');
    }
    final current = progress['current'] == null
        ? null
        : RehearsalMovementRecord._parse(progress['current'], scope, session);
    if (revision != (current?.revision ?? 0)) {
      throw const FormatException('Movement progress revision mismatch.');
    }
    final guidance = progress['guidance'] == null
        ? null
        : AssistanceJoiningGuidance.fromJson(progress['guidance']);
    final destination = destinations
        .where((d) => d.target == current?.departure.destination)
        .firstOrNull;
    final hasGuidance =
        current != null &&
        destination != null &&
        eventOpen &&
        runtimeLive &&
        current.departure.sourceHash == sourceHash;
    if (hasGuidance != (guidance != null) ||
        guidance != null &&
            (guidance.revision != revision ||
                guidance.destination != destination?.target ||
                guidance.text != destination?.text ||
                guidance.validUntil !=
                    end + session.setup.durationMinutes * 60000 ||
                guidance.materialKey !=
                    _movementHash([
                      sourceHash,
                      guidance.destination.toJson(),
                    ]))) {
      throw const FormatException(
        'Joining guidance is not confirmed progress.',
      );
    }
    final roster = assistanceObject(root['roster'], {
      'sourceHash',
      'members',
      'unavailable',
      'coverage',
    });
    final candidates = _movementList(
      roster['members'],
      50,
    ).map((v) => RehearsalDepartureMember._parse(v, scope)).toList();
    final unavailable = <String, RehearsalDepartureUnavailableReason>{};
    for (final v in _movementList(roster['unavailable'], 50)) {
      final m = assistanceObject(v, {'attendeeId', 'reason'});
      final id = _movementId(m['attendeeId']);
      if (unavailable.containsKey(id)) {
        throw const FormatException('Duplicate guest.');
      }
      unavailable[id] = assistanceEnum(
        RehearsalDepartureUnavailableReason.values,
        m['reason'],
      );
    }
    final covered = [
      ...candidates.map((m) => m.attendeeId),
      ...unavailable.keys,
    ];
    if (roster['coverage'] != 'boundedSession' ||
        covered.length != actors.length ||
        covered.toSet().length != covered.length ||
        !covered.every((id) => actors.any((a) => a.actorId == id))) {
      throw const FormatException('Movement candidate coverage is incomplete.');
    }
    final selected = root['selected'] == null
        ? null
        : RehearsalMovementRecord._parse(root['selected'], scope, session);
    final selectedRevision = selection.progressRevision ?? revision;
    if (selectedRevision != (selected?.revision ?? 0) ||
        selectedRevision > revision ||
        selected?.revision == current?.revision &&
            _movementHash(selected?.toJson()) !=
                _movementHash(current?.toJson())) {
      throw const FormatException('Selected movement history changed.');
    }
    final checkpoint = root['checkpoint'] == null
        ? null
        : RehearsalMovementCheckpoint._parse(
            root['checkpoint'],
            scope,
            session,
            sourceHash: sourceHash,
            destinations: destinations,
            selected: selected,
          );
    if ((selected?.departure.checkpointId != null) != (checkpoint != null)) {
      throw const FormatException('Selected departure checkpoint is missing.');
    }
    final history = _movementList(
      root['history'],
      25,
    ).map((v) => RehearsalMovementSummary._parse(v, scope, session)).toList();
    for (var i = 0; i < history.length; i++) {
      if (history[i].revision > revision ||
          selection.beforeRevision != null &&
              history[i].revision >= selection.beforeRevision! ||
          i > 0 && history[i - 1].revision <= history[i].revision) {
        throw const FormatException('Movement history is not an ordered page.');
      }
    }
    final cursor = assistanceNullableInteger(root['nextBeforeRevision']);
    if (cursor != null &&
        (history.length != 25 ||
            cursor != history.last.revision ||
            cursor <= 1)) {
      throw const FormatException('Invalid movement history continuation.');
    }
    return RehearsalMovementReview._(
      selection: selection,
      session: session,
      actorUid: uid,
      groups: List.unmodifiable(groups),
      revision: revision,
      sourceHash: sourceHash,
      eventOpen: eventOpen,
      runtimeLive: runtimeLive,
      destinations: List.unmodifiable(destinations),
      current: current,
      guidance: guidance,
      selected: selected,
      rosterSourceHash: assistanceHash(roster['sourceHash']),
      candidates: List.unmodifiable(candidates),
      unavailable: Map.unmodifiable(unavailable),
      checkpoint: checkpoint,
      history: List.unmodifiable(history),
      nextBeforeRevision: cursor,
    );
  }
}

List<Object?> _movementList(Object? value, int max) {
  if (value is! List || value.length > max) {
    throw const FormatException('Invalid movement list.');
  }
  return value.cast<Object?>();
}

String _movementId(Object? value) {
  final id = assistanceText(value, 180);
  if (id.contains('/') || id.trim() != id) {
    throw const FormatException('Invalid movement identity.');
  }
  return id;
}

int _movementRevision(Object? value, {bool positive = false}) {
  final n = assistanceInteger(value);
  if (n > 500 || positive && n < 1) {
    throw const FormatException('Invalid movement revision.');
  }
  return n;
}

AssistanceJoiningTarget _movementTarget(
  Object? value,
  RehearsalMovementScope scope,
) {
  final target = AssistanceJoiningTarget.fromJson(value);
  if (target is AssistanceGroupCheckpoint
      ? target.groupId != scope.groupId || scope.groupId == 'event:whole'
      : scope.groupId != 'event:whole') {
    throw const FormatException(
      'Movement destination belongs to another group.',
    );
  }
  return target;
}

String _movementHash(Object? value) {
  Object? canonical(Object? v) {
    if (v == null || v is String || v is bool) return v;
    if (v is num) return assistanceInteger(v);
    if (v is List) return v.map(canonical).toList();
    final m = assistanceObject(v);
    final keys = m.keys.cast<String>().toList()..sort();
    return {for (final key in keys) key: canonical(m[key])};
  }

  return sha256Digest(jsonEncode(canonical(value)));
}
