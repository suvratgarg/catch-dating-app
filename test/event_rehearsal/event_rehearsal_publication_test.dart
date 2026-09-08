import 'package:catch_dating_app/core/schema_contracts/generated/schema_contracts.g.dart'
    as schemas;
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_assistance_command.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal_publication.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_destination.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_late_join_rules.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_observation.dart';
import 'package:catch_dating_app/event_success/domain/event_assistance_runtime_configuration.dart';
import 'package:catch_dating_app/events/domain/event_itinerary.dart';
import 'package:catch_dating_app/events/domain/route_event_plan.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:json_schema/json_schema.dart';

import 'event_rehearsal_assistance_fixtures.dart';

void main() {
  final deliveryPolicy = AssistanceDeliveryPolicy(
    maxAttempts: 3,
    maxAttemptsPerRoute: 1,
    minimumRetrySeconds: 30,
  );
  const stops = [
    EventItineraryItem(
      id: 'finish',
      kind: EventItineraryKind.finish,
      offsetMinutes: 50,
      title: 'Finish cafe',
      routeDistanceMeters: 5000,
    ),
    EventItineraryItem(
      id: 'water',
      kind: EventItineraryKind.stop,
      offsetMinutes: 20,
      title: 'Water stop',
      routeDistanceMeters: 2000,
    ),
    EventItineraryItem(
      id: 'gather',
      kind: EventItineraryKind.gather,
      offsetMinutes: 0,
      title: 'Gather',
    ),
    EventItineraryItem(
      id: 'move',
      kind: EventItineraryKind.transition,
      offsetMinutes: 30,
      title: 'On the move',
    ),
  ];
  const crawl = EventRehearsalMovementSimulation(
    itinerary: stops,
    routePlan: RouteEventPlan.hostedWalk,
    livePositions: [],
    lateArrivalGuidance: 'This timetable is not a departure confirmation.',
  );
  const run = EventRehearsalMovementSimulation(
    itinerary: stops,
    routePlan: RouteEventPlan(
      version: 2,
      movementMode: RouteMovementMode.run,
      routeShape: RouteShape.pointToPoint,
      groupStrategy: RouteGroupStrategy.paceGroups,
      stopCadence: RouteStopCadence.flexibleStops,
      stopKinds: [RouteStopKind.water],
      roleKinds: [RouteRoleKind.pacer],
      paceGroups: [
        RoutePaceGroup(id: 'fast', label: 'Fast group', sortOrder: 1),
        RoutePaceGroup(id: 'easy', label: 'Easy group', sortOrder: 0),
      ],
    ),
    livePositions: [],
    lateArrivalGuidance: 'Do not infer a live location.',
  );

  EventRehearsalBootstrap snapshot({
    EventRehearsalMovementSimulation? movement,
    int? start = 0,
    int now = 1000,
    int runtime = 4,
    int setup = 1,
    String sessionId = 'session-1',
    String status = 'running',
  }) {
    final data = practiceBootstrap(
      runtimeRevision: runtime,
      setupRevision: setup,
      sessionId: sessionId,
      status: status,
    );
    final session = data['session']! as Map<String, Object?>;
    session['virtualNowMillis'] = now;
    if (start == null) {
      session.remove('virtualStartedAtMillis');
    } else {
      session['virtualStartedAtMillis'] = start;
    }
    if (movement != null) {
      (session['setup']! as Map<String, Object?>)['movementSimulation'] =
          movement.toJson();
    }
    return EventRehearsalBootstrap.fromCallableData(data);
  }

  RehearsalPublicationDraft draft(
    RehearsalJoiningPoint point, {
    List<RehearsalJoiningPoint> later = const [],
    String text = 'Meet us here.',
    AssistanceLateJoinRules? rules,
    DateTime? deadline,
    List<AssistanceMessageRoute>? routes,
  }) => RehearsalPublicationDraft(
    actorId: 'actor-01',
    joiningPoint: point,
    rules:
        rules ?? practiceRules(destination: const LateJoinConfirmedProgress()),
    guidanceText: text,
    departureConfirmed: false,
    routes:
        routes ??
        [
          AssistanceMessageRoute.organizerEventWhatsapp,
          AssistanceMessageRoute.catchEventSms,
        ],
    deliveryPolicy: deliveryPolicy,
    responseDeadline: deadline,
    laterPoints: later,
  );

  test(
    'venue, crawl and pace-group options come only from the copied setup',
    () {
      expect(rehearsalJoiningPoints(snapshot().session).single.label, 'Studio');
      final crawlPoints = rehearsalJoiningPoints(
        snapshot(movement: crawl).session,
      );
      expect(crawlPoints.map((p) => p.label), [
        'Studio',
        'Gather',
        'Water stop',
        'Finish cafe',
      ]);
      expect(
        crawlPoints.where((p) => p.target is AssistanceGroupCheckpoint),
        isEmpty,
      );
      final runPoints = rehearsalJoiningPoints(snapshot(movement: run).session);
      final checkpoints = runPoints
          .where((p) => p.target is AssistanceGroupCheckpoint)
          .toList();
      expect(checkpoints.map((p) => p.groupLabel), [
        'Easy group',
        'Easy group',
        'Fast group',
        'Fast group',
      ]);
      expect(
        checkpoints.map(
          (p) => (p.target as AssistanceGroupCheckpoint).checkpointId,
        ),
        ['water', 'finish', 'water', 'finish'],
      );
      expect(() => runPoints.clear(), throwsUnsupportedError);
    },
  );

  test('plans for every joining family match the callable contract', () {
    final review = snapshot(movement: run);
    final schema = JsonSchema.create(
      schemas.schemaContractsByName['ControlEventRehearsalCallablePayload']!,
    );
    for (final point in rehearsalJoiningPoints(review.session)) {
      final command = draft(point).prepare(review);
      final change = RehearsalAssistanceChange(
        snapshot: review,
        command: command,
        clientActionId: 'practice-publication-1',
      );
      final result = schema.validate(change.toJson());
      expect(result.isValid, isTrue, reason: '${result.errors}');
      expect(command.plan.departureConfirmed, isFalse);
      expect(command.plan.guidance.destination, point.target);
      expect(command.plan.rules.destination.permits(point.target), isTrue);
      expect(command.plan.guidance.validUntil, 3600000);
    }
  });

  test(
    'elapsed time reduces the window and cannot extend it or invent progress',
    () {
      final review = snapshot(movement: crawl, now: 1800000);
      final point = rehearsalJoiningPoints(review.session).last;
      final plan = draft(point).prepare(review).plan;
      expect(plan.guidance.validUntil, 3600000);
      expect(plan.departureConfirmed, isFalse);
      for (final invalid in [
        snapshot(start: null),
        snapshot(start: 2000),
        snapshot(now: 3600000),
        snapshot(status: 'draft'),
        snapshot(status: 'complete'),
      ]) {
        expect(() => draft(point).prepare(invalid), throwsFormatException);
      }
      expect(
        () => draft(
          point,
          deadline: DateTime.fromMillisecondsSinceEpoch(3600001),
        ).prepare(review),
        throwsFormatException,
      );
      expect(
        () => draft(point, deadline: review.session.virtualNow).prepare(review),
        throwsFormatException,
      );
    },
  );

  test(
    'material identity changes with guidance, not an unrelated clock tick',
    () {
      final original = snapshot();
      final point = rehearsalJoiningPoints(original.session).single;
      final input = draft(point);
      final first = input.prepare(original).plan.guidance;
      final later = input
          .prepare(snapshot(now: 120000, runtime: 9))
          .plan
          .guidance;
      expect(later.materialKey, first.materialKey);
      expect(later.revision, 10);
      expect(
        draft(
          point,
          text: 'Meet at the other entrance.',
        ).prepare(original).plan.guidance.materialKey,
        isNot(first.materialKey),
      );
    },
  );

  test(
    'later checkpoints stay in the same group and freeze the reviewed list',
    () {
      final review = snapshot(movement: run);
      final choices = rehearsalJoiningPoints(
        review.session,
      ).where((p) => p.target is AssistanceGroupCheckpoint).toList();
      final later = [choices[1]];
      final routes = [
        AssistanceMessageRoute.catchEventRcs,
        AssistanceMessageRoute.catchEventSms,
      ];
      final input = draft(choices[0], later: later, routes: routes);
      later.clear();
      routes.clear();
      final plan = input.prepare(review).plan;
      expect(plan.laterChoices!.single.label, 'Finish cafe');
      expect(plan.routes, [
        AssistanceMessageRoute.catchEventRcs,
        AssistanceMessageRoute.catchEventSms,
      ]);
      expect(
        () => draft(choices[0], later: [choices[2]]).prepare(review),
        throwsFormatException,
      );
      expect(
        () => draft(choices[0], later: [choices[0]]).prepare(review),
        throwsFormatException,
      );
      expect(
        () => draft(
          choices[0],
          later: [rehearsalJoiningPoints(review.session).first],
        ).prepare(review),
        throwsFormatException,
      );
    },
  );

  test(
    'foreign, reset and changed setup choices cannot be silently retargeted',
    () {
      final review = snapshot(movement: crawl);
      final point = rehearsalJoiningPoints(review.session).last;
      expect(
        () => draft(point).prepare(snapshot(movement: crawl, setup: 2)),
        throwsFormatException,
      );
      expect(
        () =>
            draft(point).prepare(snapshot(movement: crawl, sessionId: 'other')),
        throwsFormatException,
      );
      expect(() => draft(point).prepare(snapshot()), throwsFormatException);
      final venue = rehearsalJoiningPoints(snapshot().session).single;
      expect(
        () => draft(venue, rules: practiceRules()).prepare(snapshot()),
        throwsFormatException,
      );
    },
  );

  test(
    'configured entry rules are retained and do not imply dispatch authority',
    () {
      final review = snapshot();
      final venue = rehearsalJoiningPoints(review.session).single;
      for (final entry in LateEntryRule.values) {
        final plan = draft(
          venue,
          rules: practiceRules(
            destination: LateJoinFixedPlace(placeId: 'venue', lateEntry: entry),
          ),
        ).prepare(review).plan;
        expect(
          (plan.guidance.destination as AssistanceFixedPlace).lateEntry.name,
          entry.name,
        );
      }
      final rules = AssistanceLateJoinRules(
        destination: const LateJoinConfirmedProgress(),
        cutoff: LateJoinAtTime(1800000),
        maxMessagesPerEpisode: 0,
        minimumMinutesBetweenMessages: 5,
        unanswered: LateJoinUnansweredRule.hostReviewAtDeadline,
      );
      expect(
        () => draft(venue, rules: rules).prepare(review),
        throwsFormatException,
      );
      final plan = draft(
        venue,
        rules: rules,
        deadline: DateTime.fromMillisecondsSinceEpoch(1200000),
      ).prepare(review).plan;
      expect(plan.guidance.validUntil, 1800000);
      expect(plan.rules.maxMessagesPerEpisode, 0);
    },
  );
}
