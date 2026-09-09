import 'dart:convert';

import 'package:catch_dating_app/core/cryptography/sha256_digest.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_membership.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_parsing.dart';

enum RehearsalMembershipAvailability {
  ready,
  notApplicable,
  participationNotRecorded,
  invalidSource,
}

typedef RehearsalMembershipScope = ({
  String sessionId,
  String organizerId,
  int setupRevision,
  String clockId,
  String actorId,
});

final class RehearsalMembershipRow {
  const RehearsalMembershipRow._(
    this.scope,
    this.actorUid,
    this.facts,
    this.availability,
    this.receivingOperatorIds,
  );
  final RehearsalMembershipScope scope;
  final String actorUid;
  final AssistanceMembershipFacts facts;
  final RehearsalMembershipAvailability availability;
  final Set<String> receivingOperatorIds;
}

final class RehearsalMembershipReviews {
  const RehearsalMembershipReviews._(this.clockId, this.actorUid, this.rows);
  final String clockId, actorUid;
  final List<RehearsalMembershipRow> rows;

  factory RehearsalMembershipReviews.fromJson(
    Object? value, {
    required EventRehearsalSession session,
    required List<EventRehearsalActor> actors,
  }) {
    final map = assistanceObject(value, {
      'clockId',
      'actorUid',
      'coverage',
      'receivingOperatorIds',
      'rows',
    });
    final start = session.virtualStartedAt?.millisecondsSinceEpoch;
    final now = session.virtualNow.millisecondsSinceEpoch;
    if (start == null ||
        start < 0 ||
        start > now ||
        session.setupRevision < 0 ||
        session.setupRevision > 2147483647 ||
        session.runtimeRevision < 0 ||
        session.runtimeRevision > 2147483647 ||
        session.actionCount < 0 ||
        session.actionCount > 500 ||
        session.actorCount < 2 ||
        session.actorCount > 50) {
      throw const FormatException('Invalid practice membership generation.');
    }
    final clock =
        'clock:${sha256Digest(jsonEncode([session.id, start, session.setupRevision]))}';
    final uid = assistanceText(map['actorUid'], 180);
    final rawOperators = map['receivingOperatorIds'];
    if (rawOperators is! List || rawOperators.length > 42) {
      throw const FormatException('Invalid practice receiving Hosts.');
    }
    final operators = rawOperators.map((v) => assistanceText(v, 180)).toSet();
    final raw = map['rows'];
    if (operators.length != rawOperators.length ||
        !operators.contains(uid) ||
        map['clockId'] != clock ||
        map['coverage'] != 'boundedSession' ||
        raw is! List ||
        raw.length != actors.length ||
        actors.length != session.actorCount ||
        actors.map((a) => a.actorId).toSet().length != actors.length) {
      throw const FormatException('Incomplete practice membership review.');
    }
    final rows = <RehearsalMembershipRow>[];
    final seen = <String>{};
    for (final value in raw) {
      final row = Map<Object?, Object?>.from(assistanceObject(value));
      final actorId = assistanceId(row.remove('attendeeId'));
      final availability = assistanceEnum(
        RehearsalMembershipAvailability.values,
        row.remove('availability'),
      );
      final facts = AssistanceMembershipFacts.fromJson(row);
      if (!seen.add(actorId) ||
          !actors.any((a) => a.actorId == actorId) ||
          facts.serverTime != now ||
          facts.episodeId != null &&
              !RegExp(r'^episode:[a-f0-9]{64}$').hasMatch(facts.episodeId!) ||
          availability != RehearsalMembershipAvailability.ready &&
              (facts.ready || facts.actions.isNotEmpty) ||
          facts.actions.isNotEmpty &&
              (session.actionCount >= 500 ||
                  session.runtimeRevision >= 2147483647 ||
                  ![
                    EventRehearsalStatus.running,
                    EventRehearsalStatus.paused,
                    EventRehearsalStatus.complete,
                  ].contains(session.status)) ||
          facts.ready &&
              (session.status == EventRehearsalStatus.complete ||
                  now >= start + session.setup.durationMinutes * 60000) ||
          facts.actions.any(
                (a) => [
                  AssistanceMembershipAction.accept,
                  AssistanceMembershipAction.reject,
                ].contains(a),
              ) &&
              facts.transfer?.proposal.receivingOperatorId != uid) {
        throw const FormatException('Inconsistent practice membership review.');
      }
      rows.add(
        RehearsalMembershipRow._(
          (
            sessionId: session.id,
            organizerId: session.organizerId,
            setupRevision: session.setupRevision,
            clockId: clock,
            actorId: actorId,
          ),
          uid,
          facts,
          availability,
          Set.unmodifiable(operators),
        ),
      );
    }
    return RehearsalMembershipReviews._(clock, uid, List.unmodifiable(rows));
  }
}
