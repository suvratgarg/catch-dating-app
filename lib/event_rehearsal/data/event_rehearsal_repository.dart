import 'dart:async';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart';
import 'package:catch_dating_app/event_rehearsal/domain/event_rehearsal.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_rehearsal_repository.g.dart';

class EventRehearsalRepository {
  const EventRehearsalRepository(this._functions);

  final FirebaseFunctions _functions;

  Future<EventRehearsalCreated> create({
    required String organizerId,
    required String? sourceEventId,
    required EventRehearsalScenario scenario,
    required int seed,
    required int actorCount,
  }) => _call(
    name: 'createEventRehearsal',
    payload: CreateEventRehearsalCallableRequest(
      organizerId: organizerId,
      sourceEventId: sourceEventId,
      scenarioId: scenario.name,
      seed: seed,
      actorCount: actorCount,
    ).toJson(),
    action: 'create an event dress rehearsal',
    parse: EventRehearsalCreated.fromCallableData,
  );

  Future<EventRehearsalBootstrap> fetch(String sessionId) => _call(
    name: 'getEventRehearsalBootstrap',
    payload: GetEventRehearsalBootstrapCallableRequest(
      sessionId: sessionId,
    ).toJson(),
    action: 'load an event dress rehearsal',
    parse: EventRehearsalBootstrap.fromCallableData,
  );

  Stream<EventRehearsalBootstrap> watch(String sessionId) async* {
    while (true) {
      yield await fetch(sessionId);
      await Future<void>.delayed(const Duration(milliseconds: 1200));
    }
  }

  Future<EventRehearsalBootstrap> updateSetup({
    required EventRehearsalSession session,
    required EventRehearsalSetup setup,
    required EventRehearsalScenario scenario,
    required int actorCount,
  }) => _call(
    name: 'updateEventRehearsalSetup',
    payload: UpdateEventRehearsalSetupCallableRequest(
      sessionId: session.id,
      expectedRevision: session.setupRevision,
      scenarioId: scenario.name,
      actorCount: actorCount,
      setup: setup.toJson(),
    ).toJson(),
    action: 'update event rehearsal setup',
    parse: EventRehearsalBootstrap.fromCallableData,
  );

  Future<EventRehearsalBootstrap> control({
    required EventRehearsalSession session,
    required EventRehearsalControlAction action,
    required String clientActionId,
    int? minutes,
  }) => _call(
    name: 'controlEventRehearsal',
    payload: ControlEventRehearsalCallableRequest(
      sessionId: session.id,
      expectedRevision: session.runtimeRevision,
      clientActionId: clientActionId,
      action: action.name,
      minutes: minutes,
    ).toJson(),
    action: 'control an event rehearsal',
    parse: EventRehearsalBootstrap.fromCallableData,
  );

  Future<EventRehearsalBootstrap> inject({
    required EventRehearsalSession session,
    required String clientActionId,
    String? actorId,
    EventRehearsalBehavior? behavior,
    EventRehearsalFault fault = EventRehearsalFault.none,
  }) => _call(
    name: 'injectEventRehearsalBehavior',
    payload: InjectEventRehearsalBehaviorCallableRequest(
      sessionId: session.id,
      expectedRevision: session.runtimeRevision,
      clientActionId: clientActionId,
      actorId: actorId,
      behavior: behavior?.wireValue,
      faultId: fault.name,
    ).toJson(),
    action: 'simulate an event rehearsal behavior',
    parse: EventRehearsalBootstrap.fromCallableData,
  );

  Future<EventRehearsalBootstrap> controlSpatial({
    required EventRehearsalSession session,
    required String clientActionId,
    required String actorId,
    required EventRehearsalSpatialAction action,
    String? destinationUnitId,
    EventRehearsalSpatialScope? scope,
  }) => _call(
    name: 'controlEventRehearsalSpatial',
    payload: ControlEventRehearsalSpatialCallableRequest(
      sessionId: session.id,
      expectedRevision: session.runtimeRevision,
      clientActionId: clientActionId,
      actorId: actorId,
      action: action.name,
      destinationUnitId: destinationUnitId,
      scope: scope?.name,
    ).toJson(),
    action: 'change a rehearsal Room placement',
    parse: EventRehearsalBootstrap.fromCallableData,
  );

  Future<EventRehearsalBootstrap> reset({
    required String sessionId,
    int? seed,
  }) => _call(
    name: 'resetEventRehearsal',
    payload: ResetEventRehearsalCallableRequest(
      sessionId: sessionId,
      fork: false,
      seed: seed,
    ).toJson(),
    action: 'reset an event rehearsal',
    parse: EventRehearsalBootstrap.fromCallableData,
  );

  Future<EventRehearsalCreated> fork({required String sessionId, int? seed}) =>
      _call(
        name: 'resetEventRehearsal',
        payload: ResetEventRehearsalCallableRequest(
          sessionId: sessionId,
          fork: true,
          seed: seed,
        ).toJson(),
        action: 'fork an event rehearsal',
        parse: EventRehearsalCreated.fromCallableData,
      );

  Future<EventRehearsalBootstrap> rotateGuestLink(String sessionId) => _call(
    name: 'rotateEventRehearsalGuestLink',
    payload: RotateEventRehearsalGuestLinkCallableRequest(
      sessionId: sessionId,
    ).toJson(),
    action: 'rotate an event rehearsal guest link',
    parse: EventRehearsalBootstrap.fromCallableData,
  );

  Future<EventRehearsalBootstrap> complete(String sessionId) => _call(
    name: 'completeEventRehearsal',
    payload: GetEventRehearsalBootstrapCallableRequest(
      sessionId: sessionId,
    ).toJson(),
    action: 'complete an event rehearsal',
    parse: EventRehearsalBootstrap.fromCallableData,
  );

  Future<Map<Object?, Object?>> exportReproduction(String sessionId) => _call(
    name: 'exportEventRehearsalReproduction',
    payload: GetEventRehearsalBootstrapCallableRequest(
      sessionId: sessionId,
    ).toJson(),
    action: 'export an event rehearsal reproduction',
    parse: (data) {
      if (data is Map<Object?, Object?>) return data;
      throw const FormatException('Rehearsal reproduction must be a map.');
    },
  );

  Future<T> _call<T>({
    required String name,
    required Map<String, Object?> payload,
    required String action,
    required T Function(Object?) parse,
  }) => withBackendErrorContext(
    () async {
      final result = await _functions
          .httpsCallable(name)
          .call<Object?>(payload);
      return parse(result.data);
    },
    context: BackendErrorContext(
      service: BackendService.functions,
      action: action,
      resource: name,
    ),
  );
}

// keepalive: One callable client owns the isolated rehearsal domain.
@Riverpod(keepAlive: true)
EventRehearsalRepository eventRehearsalRepository(Ref ref) =>
    EventRehearsalRepository(ref.watch(firebaseFunctionsProvider));

@riverpod
Stream<EventRehearsalBootstrap> eventRehearsal(Ref ref, String sessionId) =>
    ref.watch(eventRehearsalRepositoryProvider).watch(sessionId);
