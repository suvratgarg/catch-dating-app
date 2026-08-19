enum EventRehearsalScenario {
  smoothRun(12),
  lateAndNoShow(16),
  earlyExitAndReturn(14),
  rosterAndCapacity(15),
  walkInAndAmbiguousClaim(12),
  privacyAndKeepApart(14),
  lowConnectivity(12),
  concurrentHosts(12),
  revealInterrupted(12),
  externalProfiles(14),
  accountabilitySweep(18);

  const EventRehearsalScenario(this.defaultActorCount);
  final int defaultActorCount;

  static EventRehearsalScenario fromWire(String value) =>
      values.firstWhere((item) => item.name == value);
}

enum EventRehearsalStatus { draft, ready, running, paused, complete, expired }

enum EventRehearsalActorStatus {
  expected,
  present,
  late,
  noShow,
  departed,
  returned,
  disconnected,
  walkIn,
  ambiguousClaim,
}

enum EventRehearsalGuestMoment {
  welcome,
  checkIn,
  firstHello,
  assignment,
  rotation,
  pause,
  reveal,
  afterglow,
  complete,
}

enum EventRehearsalModule {
  arrival,
  firstHello,
  pods,
  rotations,
  conversationCues,
  reveal,
  afterglow,
  accountability,
}

enum EventRehearsalFault {
  none,
  latency,
  oneShotFailure,
  listenerDisconnect,
  staleRevision,
  duplicateDelivery,
  legacyFixture,
  reducedMotion,
  lowBandwidth,
}

enum EventRehearsalControlAction {
  markReady,
  start,
  pause,
  resume,
  advance,
  previous,
  advanceClock,
  complete,
}

enum EventRehearsalBehavior {
  arrive,
  arriveLate,
  markNoShow,
  leaveEarly,
  returnActor,
  walkIn,
  ambiguousClaim,
  resolveClaim,
  optOut,
  optIn,
  keepApart,
  disconnect,
  reconnect;

  String get wireValue => this == returnActor ? 'return' : name;
}

class EventRehearsalSetup {
  const EventRehearsalSetup({
    required this.title,
    required this.locationName,
    required this.durationMinutes,
    required this.hostGoal,
    required this.attendeePrompt,
    required this.modules,
  });

  factory EventRehearsalSetup.fromMap(Map<Object?, Object?> map) =>
      EventRehearsalSetup(
        title: _requiredString(map, 'title'),
        locationName: _requiredString(map, 'locationName'),
        durationMinutes: _requiredInt(map, 'durationMinutes'),
        hostGoal: _requiredString(map, 'hostGoal'),
        attendeePrompt: _requiredString(map, 'attendeePrompt'),
        modules: _stringList(map['moduleIds'])
            .map((value) => EventRehearsalModule.values.byName(value))
            .toList(growable: false),
      );

  final String title;
  final String locationName;
  final int durationMinutes;
  final String hostGoal;
  final String attendeePrompt;
  final List<EventRehearsalModule> modules;

  Map<String, Object?> toJson() => {
    'title': title,
    'locationName': locationName,
    'durationMinutes': durationMinutes,
    'hostGoal': hostGoal,
    'attendeePrompt': attendeePrompt,
    'moduleIds': modules.map((module) => module.name).toList(growable: false),
  };

  EventRehearsalSetup copyWith({
    String? title,
    String? locationName,
    int? durationMinutes,
    String? hostGoal,
    String? attendeePrompt,
    List<EventRehearsalModule>? modules,
  }) => EventRehearsalSetup(
    title: title ?? this.title,
    locationName: locationName ?? this.locationName,
    durationMinutes: durationMinutes ?? this.durationMinutes,
    hostGoal: hostGoal ?? this.hostGoal,
    attendeePrompt: attendeePrompt ?? this.attendeePrompt,
    modules: modules ?? this.modules,
  );
}

class EventRehearsalSession {
  const EventRehearsalSession({
    required this.id,
    required this.organizerId,
    required this.sourceEventId,
    required this.scenario,
    required this.seed,
    required this.actorCount,
    required this.actionCount,
    required this.status,
    required this.setup,
    required this.setupRevision,
    required this.runtimeRevision,
    required this.activeStepIndex,
    required this.virtualNow,
    required this.fault,
    required this.expiresAt,
  });

  factory EventRehearsalSession.fromMap(
    Map<Object?, Object?> map,
  ) => EventRehearsalSession(
    id: _requiredString(map, 'id'),
    organizerId: _requiredString(map, 'organizerId'),
    sourceEventId: map['sourceEventId'] as String?,
    scenario: EventRehearsalScenario.fromWire(
      _requiredString(map, 'scenarioId'),
    ),
    seed: _requiredInt(map, 'seed'),
    actorCount: _requiredInt(map, 'actorCount'),
    actionCount: _requiredInt(map, 'actionCount'),
    status: EventRehearsalStatus.values.byName(_requiredString(map, 'status')),
    setup: EventRehearsalSetup.fromMap(_requiredMap(map['setup'], 'setup')),
    setupRevision: _requiredInt(map, 'setupRevision'),
    runtimeRevision: _requiredInt(map, 'runtimeRevision'),
    activeStepIndex: _requiredInt(map, 'activeStepIndex'),
    virtualNow: DateTime.fromMillisecondsSinceEpoch(
      _requiredInt(map, 'virtualNowMillis'),
    ),
    fault: EventRehearsalFault.values.byName(_requiredString(map, 'faultId')),
    expiresAt: DateTime.fromMillisecondsSinceEpoch(
      _requiredInt(map, 'expiresAtMillis'),
    ),
  );

  final String id;
  final String organizerId;
  final String? sourceEventId;
  final EventRehearsalScenario scenario;
  final int seed;
  final int actorCount;
  final int actionCount;
  final EventRehearsalStatus status;
  final EventRehearsalSetup setup;
  final int setupRevision;
  final int runtimeRevision;
  final int activeStepIndex;
  final DateTime virtualNow;
  final EventRehearsalFault fault;
  final DateTime expiresAt;

  bool get canEditSetup =>
      status == EventRehearsalStatus.draft ||
      status == EventRehearsalStatus.ready;
  bool get hasStarted =>
      status == EventRehearsalStatus.running ||
      status == EventRehearsalStatus.paused ||
      status == EventRehearsalStatus.complete;
}

class EventRehearsalActor {
  const EventRehearsalActor({
    required this.actorId,
    required this.displayName,
    required this.persona,
    required this.status,
    required this.guestMoment,
    required this.optedOut,
    required this.keepApartActorIds,
    required this.helpRequested,
    required this.promptCompleted,
  });

  factory EventRehearsalActor.fromMap(Map<Object?, Object?> map) =>
      EventRehearsalActor(
        actorId: _requiredString(map, 'actorId'),
        displayName: _requiredString(map, 'displayName'),
        persona: _requiredString(map, 'persona'),
        status: EventRehearsalActorStatus.values.byName(
          _requiredString(map, 'status'),
        ),
        guestMoment: EventRehearsalGuestMoment.values.byName(
          _requiredString(map, 'guestMoment'),
        ),
        optedOut: _requiredBool(map, 'optedOut'),
        keepApartActorIds: _stringList(map['keepApartActorIds']),
        helpRequested: _requiredBool(map, 'helpRequested'),
        promptCompleted: _requiredBool(map, 'promptCompleted'),
      );

  final String actorId;
  final String displayName;
  final String persona;
  final EventRehearsalActorStatus status;
  final EventRehearsalGuestMoment guestMoment;
  final bool optedOut;
  final List<String> keepApartActorIds;
  final bool helpRequested;
  final bool promptCompleted;
}

class EventRehearsalActionRecord {
  const EventRehearsalActionRecord({
    required this.clientActionId,
    required this.actorId,
    required this.kind,
    required this.name,
    required this.runtimeRevision,
    required this.virtualNow,
  });

  factory EventRehearsalActionRecord.fromMap(Map<Object?, Object?> map) =>
      EventRehearsalActionRecord(
        clientActionId: _requiredString(map, 'clientActionId'),
        actorId: map['actorId'] as String?,
        kind: _requiredString(map, 'kind'),
        name: _requiredString(map, 'name'),
        runtimeRevision: _requiredInt(map, 'runtimeRevision'),
        virtualNow: DateTime.fromMillisecondsSinceEpoch(
          _requiredInt(map, 'virtualNowMillis'),
        ),
      );

  final String clientActionId;
  final String? actorId;
  final String kind;
  final String name;
  final int runtimeRevision;
  final DateTime virtualNow;
}

class EventRehearsalBootstrap {
  const EventRehearsalBootstrap({
    required this.session,
    required this.actors,
    required this.actions,
    required this.guestUrl,
    required this.canUseInternalFaults,
  });

  factory EventRehearsalBootstrap.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'event rehearsal bootstrap');
    return EventRehearsalBootstrap(
      session: EventRehearsalSession.fromMap(
        _requiredMap(map['session'], 'session'),
      ),
      actors: _mapList(
        map['actors'],
        'actors',
      ).map(EventRehearsalActor.fromMap).toList(growable: false),
      actions: _mapList(
        map['actions'],
        'actions',
      ).map(EventRehearsalActionRecord.fromMap).toList(growable: false),
      guestUrl: _requiredString(map, 'guestUrl'),
      canUseInternalFaults: _requiredBool(map, 'canUseInternalFaults'),
    );
  }

  final EventRehearsalSession session;
  final List<EventRehearsalActor> actors;
  final List<EventRehearsalActionRecord> actions;
  final String guestUrl;
  final bool canUseInternalFaults;

  int get presentCount => actors
      .where(
        (actor) =>
            actor.status == EventRehearsalActorStatus.present ||
            actor.status == EventRehearsalActorStatus.late ||
            actor.status == EventRehearsalActorStatus.returned ||
            actor.status == EventRehearsalActorStatus.walkIn,
      )
      .length;
  int get unresolvedCount => actors
      .where(
        (actor) =>
            actor.status == EventRehearsalActorStatus.disconnected ||
            actor.status == EventRehearsalActorStatus.ambiguousClaim,
      )
      .length;
}

class EventRehearsalCreated {
  const EventRehearsalCreated({
    required this.sessionId,
    required this.guestUrl,
    required this.setupRevision,
    required this.runtimeRevision,
  });

  factory EventRehearsalCreated.fromCallableData(Object? data) {
    final map = _requiredMap(data, 'created event rehearsal');
    return EventRehearsalCreated(
      sessionId: _requiredString(map, 'sessionId'),
      guestUrl: _requiredString(map, 'guestUrl'),
      setupRevision: _requiredInt(map, 'setupRevision'),
      runtimeRevision: _requiredInt(map, 'runtimeRevision'),
    );
  }

  final String sessionId;
  final String guestUrl;
  final int setupRevision;
  final int runtimeRevision;
}

Map<Object?, Object?> _requiredMap(Object? value, String label) {
  if (value is Map<Object?, Object?>) return value;
  throw FormatException('$label must be a map.');
}

List<Map<Object?, Object?>> _mapList(Object? value, String label) {
  if (value is! List<Object?>) throw FormatException('$label must be a list.');
  return value.map((item) => _requiredMap(item, label)).toList(growable: false);
}

List<String> _stringList(Object? value) {
  if (value is! List<Object?>) throw const FormatException('Expected a list.');
  return value.cast<String>();
}

String _requiredString(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is String) return value;
  throw FormatException('$key must be a string.');
}

int _requiredInt(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw FormatException('$key must be an integer.');
}

bool _requiredBool(Map<Object?, Object?> map, String key) {
  final value = map[key];
  if (value is bool) return value;
  throw FormatException('$key must be a boolean.');
}
