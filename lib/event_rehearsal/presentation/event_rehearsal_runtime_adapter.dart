import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/event_success/domain/event_success_assignment.dart';
import 'package:catch_dating_app/event_success/domain/event_success_layout.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_presence.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

/// A read-only projection of one rehearsal session into the canonical Event
/// Success host runtime. Mutations remain owned by [EventRehearsalController].
final class EventRehearsalRuntimeProjection {
  const EventRehearsalRuntimeProjection({
    required this.event,
    required this.plan,
    required this.roster,
    required this.profiles,
    required this.presence,
    required this.layout,
    required this.assignments,
  });

  final Event event;
  final EventSuccessPlan plan;
  final EventParticipationRoster roster;
  final List<PublicProfile> profiles;
  final EventSuccessPresenceSummary presence;
  final EventSuccessLayout layout;
  final List<EventSuccessAssignment> assignments;
}

EventRehearsalRuntimeProjection buildEventRehearsalRuntimeProjection(
  EventRehearsalBootstrap rehearsal, {
  required String practiceGuestLabel,
  required String latePracticeGuestLabel,
}) {
  final session = rehearsal.session;
  final eventId = 'rehearsal_${session.id}';
  final virtualNow = session.virtualNow;
  final eventStart = virtualNow.subtract(
    Duration(minutes: math.max(10, session.activeStepIndex * 12)),
  );
  final movementSimulation = session.setup.movementSimulation;
  final tableCount = math.max(1, (session.actorCount / 4).ceil());
  final selectedModuleIds = session.setup.modules
      .expand(_eventSuccessModuleIds)
      .toSet()
      .toList(growable: false);
  final event = Event(
    id: eventId,
    synthetic: true,
    seedPrefix: session.seed.toString(),
    clubId: session.organizerId,
    startTime: eventStart,
    endTime: eventStart.add(Duration(minutes: session.setup.durationMinutes)),
    meetingPoint: session.setup.locationName,
    eventFormat: EventFormatSnapshot(
      activityKind: ActivityKind.singlesMixer,
      interactionModel: EventInteractionModel.seatedTable,
      defaultPlaybookId: 'algorithmic_mixer_reveal',
      defaultModuleIds: selectedModuleIds,
      activityDetails: {
        if (movementSimulation?.routePlan != null)
          'routePlan': movementSimulation!.routePlan!.toJson(),
      },
    ),
    itinerary: movementSimulation?.itinerary ?? const [],
    distanceKm: 0,
    pace: PaceLevel.easy,
    capacityLimit: math.max(1, session.actorCount),
    description: session.setup.hostGoal,
    priceInPaise: 0,
    bookedCount: rehearsal.actors.length,
    checkedInCount: rehearsal.actors.where(_isCheckedIn).length,
  );
  final basePlan = EventSuccessPlan.defaultForEvent(event, now: virtualNow);
  final plan = basePlan.copyWith(
    selectedModuleIds: selectedModuleIds,
    targetAttendeeCount: math.max(1, session.actorCount),
    structureConfig: basePlan.structureConfig.copyWith(
      unitKind: EventSuccessUnitKind.tables,
      unitSize: 4,
      unitCount: tableCount,
      rotationIntervalMinutes: 12,
    ),
    hostGoal: session.setup.hostGoal,
    attendeePrompt: session.setup.attendeePrompt,
    activeStepIndex: session.activeStepIndex,
    liveControlRevision: session.runtimeRevision,
    status: switch (session.status) {
      EventRehearsalStatus.draft ||
      EventRehearsalStatus.ready => EventSuccessPlanStatus.setup,
      EventRehearsalStatus.running ||
      EventRehearsalStatus.paused => EventSuccessPlanStatus.live,
      EventRehearsalStatus.complete ||
      EventRehearsalStatus.expired => EventSuccessPlanStatus.complete,
    },
    frozenAt: session.hasStarted ? eventStart : null,
    completedAt: session.status == EventRehearsalStatus.complete
        ? virtualNow
        : null,
    updatedAt: virtualNow,
  );
  final layout = EventSuccessLayout(
    layoutId: 'rehearsal-room-${session.id}',
    label: session.setup.locationName,
    units: [
      for (var index = 0; index < tableCount; index++)
        EventSuccessLayoutUnit(
          id: 'table-${index + 1}',
          label: _tableLabelForIndex(index),
          shape: EventSuccessLayoutShape.round,
          capacity: 4,
          gridX: index % 2,
          gridY: index ~/ 2,
          order: index + 1,
        ),
    ],
  );
  final placedActors = rehearsal.actors.where(_isPlaceable).toList();
  final assignments = <EventSuccessAssignment>[
    for (final indexed in placedActors.indexed)
      _assignmentFor(
        actor: indexed.$2,
        index: indexed.$1,
        tableCount: tableCount,
        eventId: eventId,
        clubId: session.organizerId,
        now: virtualNow,
        practiceGuestLabel: practiceGuestLabel,
        latePracticeGuestLabel: latePracticeGuestLabel,
      ),
  ];
  final checkedInActors = rehearsal.actors.where(_isCheckedIn).toList();
  final roster = EventParticipationRoster(
    bookedIds: [for (final actor in rehearsal.actors) actor.actorId],
    checkedInIds: [for (final actor in checkedInActors) actor.actorId],
    waitlistedIds: const [],
    checkedInAtByUid: {
      for (final indexed in checkedInActors.indexed)
        indexed.$2.actorId: virtualNow.subtract(
          Duration(minutes: indexed.$1 + 1),
        ),
    },
  );
  final profiles = <PublicProfile>[
    for (final indexed in rehearsal.actors.indexed)
      PublicProfile(
        uid: indexed.$2.actorId,
        name: indexed.$2.displayName,
        age: 26 + (indexed.$1 % 9),
        gender: Gender.values[indexed.$1 % Gender.values.length],
      ),
  ];
  final virtualNowMillis = virtualNow.millisecondsSinceEpoch;
  final presence = EventSuccessPresenceSummary(
    serverTimeMillis: virtualNowMillis,
    liveControlRevision: session.runtimeRevision,
    nextRoundIndex: session.activeStepIndex + 1,
    policy: const EventSuccessPresencePolicy(
      heartbeatIntervalSeconds: 30,
      presentWindowSeconds: 90,
      likelyDepartedAfterSeconds: 180,
    ),
    entries: [
      for (final actor in rehearsal.actors)
        EventSuccessPresenceEntry(
          uid: actor.actorId,
          displayName: actor.displayName,
          state: _presenceState(actor.status),
          heartbeatAtMillis: virtualNowMillis,
        ),
    ],
    lateArrivals: [
      for (final actor in rehearsal.actors)
        if (actor.status == EventRehearsalActorStatus.late)
          EventSuccessLateArrivalCandidate(
            uid: actor.actorId,
            displayName: actor.displayName,
            checkedInAtMillis: virtualNowMillis,
          ),
    ],
  );

  return EventRehearsalRuntimeProjection(
    event: event,
    plan: plan,
    roster: roster,
    profiles: profiles,
    presence: presence,
    layout: layout,
    assignments: assignments,
  );
}

Iterable<String> _eventSuccessModuleIds(EventRehearsalModule module) =>
    switch (module) {
      EventRehearsalModule.arrival => [EventSuccessModuleCatalog.checkIn.id],
      EventRehearsalModule.firstHello => [
        EventSuccessModuleCatalog.firstHelloCheckIn.id,
      ],
      EventRehearsalModule.pods => [EventSuccessModuleCatalog.microPods.id],
      EventRehearsalModule.rotations => [
        EventSuccessModuleCatalog.guidedRotations.id,
      ],
      EventRehearsalModule.conversationCues => [
        EventSuccessModuleCatalog.socialMissions.id,
      ],
      EventRehearsalModule.reveal => [EventSuccessModuleCatalog.liveReveal.id],
      EventRehearsalModule.afterglow => [
        EventSuccessModuleCatalog.hostAnalytics.id,
      ],
      EventRehearsalModule.accountability => [
        EventSuccessModuleCatalog.safetyControls.id,
      ],
    };

bool _isCheckedIn(EventRehearsalActor actor) => switch (actor.status) {
  EventRehearsalActorStatus.present ||
  EventRehearsalActorStatus.late ||
  EventRehearsalActorStatus.returned ||
  EventRehearsalActorStatus.walkIn => true,
  _ => false,
};

bool _isPlaceable(EventRehearsalActor actor) => switch (actor.status) {
  EventRehearsalActorStatus.noShow ||
  EventRehearsalActorStatus.departed ||
  EventRehearsalActorStatus.disconnected => false,
  _ => true,
};

EventSuccessPresenceState _presenceState(EventRehearsalActorStatus status) =>
    switch (status) {
      EventRehearsalActorStatus.departed ||
      EventRehearsalActorStatus.disconnected =>
        EventSuccessPresenceState.likelyDeparted,
      EventRehearsalActorStatus.present ||
      EventRehearsalActorStatus.late ||
      EventRehearsalActorStatus.returned ||
      EventRehearsalActorStatus.walkIn => EventSuccessPresenceState.present,
      _ => EventSuccessPresenceState.idle,
    };

EventSuccessAssignment _assignmentFor({
  required EventRehearsalActor actor,
  required int index,
  required int tableCount,
  required String eventId,
  required String clubId,
  required DateTime now,
  required String practiceGuestLabel,
  required String latePracticeGuestLabel,
}) {
  final fallbackLayoutUnitId = 'table-${(index % tableCount) + 1}';
  final layoutUnitId = actor.layoutUnitId ?? fallbackLayoutUnitId;
  final parsedTableIndex = int.tryParse(layoutUnitId.split('-').last);
  final tableIndex = parsedTableIndex == null
      ? index % tableCount
      : (parsedTableIndex - 1).clamp(0, tableCount - 1);
  final tableLabel = _tableLabelForIndex(tableIndex);
  final legacyConfirmed =
      actor.layoutUnitId == null &&
      (actor.status == EventRehearsalActorStatus.present ||
          actor.status == EventRehearsalActorStatus.returned);
  return EventSuccessAssignment(
    id: 'rehearsal-assignment-${actor.actorId}',
    eventId: eventId,
    clubId: clubId,
    uid: actor.actorId,
    moduleId: EventSuccessModuleCatalog.microPods.id,
    label: tableLabel,
    displayTitle: actor.displayName,
    displaySubtitle: actor.status == EventRehearsalActorStatus.late
        ? latePracticeGuestLabel
        : practiceGuestLabel,
    peerUids: const [],
    unitKind: 'table',
    unitIndex: tableIndex,
    unitLabel: tableLabel,
    layoutUnitId: layoutUnitId,
    confirmedLayoutUnitId:
        actor.confirmedLayoutUnitId ?? (legacyConfirmed ? layoutUnitId : null),
    source: 'rehearsal',
    createdAt: now,
    updatedAt: now,
  );
}

String _tableLabelForIndex(int index) {
  final noun = EventSuccessUnitKind.tables.singularLabel;
  final titleNoun = noun.isEmpty
      ? noun
      : '${noun[0].toUpperCase()}${noun.substring(1)}';
  return '$titleNoun ${index + 1}';
}
