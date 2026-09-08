import 'dart:convert';
import 'dart:math';

import 'package:catch_dating_app/core/cryptography/sha256_digest.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_assistance_command.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_assistance_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_destination.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_rules.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_observation.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_configuration.dart';
import 'package:catch_dating_app/events/domain/event_itinerary.dart';
import 'package:catch_dating_app/events/domain/route_event_plan.dart';

/// A configured place for a Host to review. It is not a location report or a
/// recommendation to intercept a moving group.
final class RehearsalJoiningPoint {
  const RehearsalJoiningPoint._({
    required this.sessionId,
    required this.setupRevision,
    required this.label,
    required this.target,
    this.groupLabel,
  });
  final String sessionId;
  final int setupRevision;
  final String label;
  final String? groupLabel;
  final AssistanceJoiningTarget target;
}

List<RehearsalJoiningPoint> rehearsalJoiningPoints(
  EventRehearsalSession session,
) {
  final points = <RehearsalJoiningPoint>[];
  void add(String label, AssistanceJoiningTarget target, [String? group]) {
    points.add(
      RehearsalJoiningPoint._(
        sessionId: session.id,
        setupRevision: session.setupRevision,
        label: label,
        target: target,
        groupLabel: group,
      ),
    );
  }

  if (session.setup.locationName.trim().isNotEmpty) {
    add(
      session.setup.locationName,
      const AssistanceFixedPlace(
        placeId: 'venue',
        lateEntry: AssistanceLateEntry.allowed,
      ),
    );
  }
  final movement = session.setup.movementSimulation;
  if (movement == null) return List.unmodifiable(points);
  // Timetable order is descriptive; it never confirms departure or position.
  final stops =
      movement.itinerary
          .where(
            (item) => {
              EventItineraryKind.gather,
              EventItineraryKind.stop,
              EventItineraryKind.breakTime,
              EventItineraryKind.finish,
            }.contains(item.kind),
          )
          .toList()
        ..sort((a, b) {
          final order = a.offsetMinutes.compareTo(b.offsetMinutes);
          return order != 0 ? order : a.id.compareTo(b.id);
        });
  if (stops.map((stop) => stop.id).toSet().length != stops.length) {
    throw const FormatException(
      'Practice joining points have duplicate identities.',
    );
  }
  for (final stop in stops) {
    add(
      stop.title,
      AssistanceItineraryStop(
        itineraryId: 'practice-itinerary',
        stopId: stop.id,
      ),
    );
  }
  final route = movement.routePlan;
  if (route?.groupStrategy == RouteGroupStrategy.paceGroups) {
    final groups = [...route!.paceGroups]
      ..sort((a, b) {
        final order = a.sortOrder.compareTo(b.sortOrder);
        return order != 0 ? order : a.id.compareTo(b.id);
      });
    if (groups.map((group) => group.id).toSet().length != groups.length) {
      throw const FormatException(
        'Practice pace groups have duplicate identities.',
      );
    }
    for (final group in groups) {
      for (final stop in stops.where(
        (item) => item.location != null || item.routeDistanceMeters != null,
      )) {
        add(
          stop.title,
          AssistanceGroupCheckpoint(
            routeId: 'practice-route',
            groupId: group.id,
            checkpointId: stop.id,
          ),
          group.label,
        );
      }
    }
  }
  return List.unmodifiable(points);
}

/// Host choices for one instruction. All authority and communication are
/// synthetic. Guidance and departure are explicit; GPS and schedule never fill
/// them in. The current review supplies actor scope, time and run generation.
final class RehearsalPublicationDraft {
  RehearsalPublicationDraft({
    required this.actorId,
    required this.joiningPoint,
    required this.rules,
    required this.guidanceText,
    required this.departureConfirmed,
    required List<AssistanceMessageRoute> routes,
    required this.deliveryPolicy,
    this.responseDeadline,
    List<RehearsalJoiningPoint> laterPoints = const [],
  }) : routes = List.unmodifiable(routes),
       laterPoints = List.unmodifiable(laterPoints);
  final String actorId;
  final RehearsalJoiningPoint joiningPoint;
  final AssistanceLateJoinRules rules;
  final String guidanceText;
  final bool departureConfirmed;
  final List<AssistanceMessageRoute> routes;
  final AssistanceDeliveryPolicy deliveryPolicy;
  final DateTime? responseDeadline;
  final List<RehearsalJoiningPoint> laterPoints;

  RehearsalPublishInstruction prepare(EventRehearsalBootstrap snapshot) {
    final session = snapshot.session;
    final start = session.virtualStartedAt;
    if (start == null ||
        start.millisecondsSinceEpoch < 0 ||
        session.setup.durationMinutes < 30 ||
        session.setup.durationMinutes > 360 ||
        session.virtualNow.isBefore(start) ||
        ![
          EventRehearsalStatus.running,
          EventRehearsalStatus.paused,
        ].contains(session.status)) {
      throw const FormatException(
        'Load a started rehearsal with its virtual clock.',
      );
    }
    final now = session.virtualNow.millisecondsSinceEpoch;
    final end =
        start.millisecondsSinceEpoch + session.setup.durationMinutes * 60000;
    final cutoff = rules.cutoff;
    final until = cutoff is LateJoinAtTime ? min(end, cutoff.at) : end;
    final deadline = responseDeadline?.millisecondsSinceEpoch;
    if (until <= now ||
        cutoff is LateJoinAtTime && cutoff.at > end ||
        deadline != null && (deadline <= now || deadline > until)) {
      throw const FormatException(
        'Review the remaining practice window and response deadline.',
      );
    }
    if (!snapshot.actors.any((actor) => actor.actorId == actorId)) {
      throw const FormatException('Choose a guest from this practice roster.');
    }
    final catalog = rehearsalJoiningPoints(session);
    for (final point in [joiningPoint, ...laterPoints]) {
      if (point.sessionId != session.id ||
          point.setupRevision != session.setupRevision ||
          !catalog.any(
            (current) =>
                current.target == point.target &&
                current.label == point.label &&
                current.groupLabel == point.groupLabel,
          )) {
        throw const FormatException(
          'Review joining points from the current rehearsal setup.',
        );
      }
    }
    var target = joiningPoint.target;
    final configured = rules.destination;
    if (target is AssistanceFixedPlace && configured is LateJoinFixedPlace) {
      target = AssistanceFixedPlace(
        placeId: target.placeId,
        lateEntry: AssistanceLateEntry.values.byName(configured.lateEntry.name),
      );
    }
    final destinations = [target, ...laterPoints.map((point) => point.target)];
    if (laterPoints.length > 17 ||
        destinations.toSet().length != destinations.length) {
      throw const FormatException('Choose distinct later joining points.');
    }
    final destination = configured is LateJoinConfirmedProgress
        ? _resolveDestination(target, destinations)
        : configured;
    if (!destinations.every(destination.permits)) {
      throw const FormatException(
        'The joining policy does not permit these points.',
      );
    }
    final resolvedRules = AssistanceLateJoinRules(
      destination: destination,
      cutoff: cutoff,
      maxMessagesPerEpisode: rules.maxMessagesPerEpisode,
      minimumMinutesBetweenMessages: rules.minimumMinutesBetweenMessages,
      unanswered: rules.unanswered,
    );
    final text = guidanceText.trim();
    final materialHash = sha256Digest(
      jsonEncode({
        'target': target.toJson(),
        'text': text,
        'validUntil': until,
      }),
    );
    final materialKey = 'practice:$materialHash';
    return RehearsalPublishInstruction(
      actorId: actorId,
      plan: RehearsalAssistancePlan(
        rules: resolvedRules,
        guidance: AssistanceJoiningGuidance(
          revision: session.runtimeRevision + 1,
          destination: target,
          materialKey: materialKey,
          text: text,
          validUntil: until,
        ),
        departureConfirmed: departureConfirmed,
        responseDeadline: deadline,
        routes: routes,
        deliveryPolicy: deliveryPolicy,
        laterChoices: laterPoints
            .map(
              (point) => AssistanceLaterJoiningChoice(
                label: point.label,
                target: point.target,
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

LateJoinDestination _resolveDestination(
  AssistanceJoiningTarget target,
  List<AssistanceJoiningTarget> candidates,
) {
  switch (target) {
    case AssistanceFixedPlace(:final placeId, :final lateEntry):
      return LateJoinFixedPlace(
        placeId: placeId,
        lateEntry: LateEntryRule.values.byName(lateEntry.name),
      );
    case AssistanceItineraryStop(:final itineraryId):
      if (candidates.any(
        (point) =>
            point is! AssistanceItineraryStop ||
            point.itineraryId != itineraryId,
      )) {
        throw const FormatException(
          'Later stops must belong to the same itinerary.',
        );
      }
      return LateJoinItinerary(
        itineraryId: itineraryId,
        permittedStopIds: candidates
            .cast<AssistanceItineraryStop>()
            .map((point) => point.stopId)
            .toList(),
      );
    case AssistanceGroupCheckpoint(:final routeId, :final groupId):
      if (candidates.any(
        (point) =>
            point is! AssistanceGroupCheckpoint ||
            point.routeId != routeId ||
            point.groupId != groupId,
      )) {
        throw const FormatException(
          'Later checkpoints must belong to the same pace group.',
        );
      }
      return LateJoinGroupCheckpoints(
        routeId: routeId,
        groupId: groupId,
        permittedCheckpointIds: candidates
            .cast<AssistanceGroupCheckpoint>()
            .map((point) => point.checkpointId)
            .toList(),
      );
  }
}
