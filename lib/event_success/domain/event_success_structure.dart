import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/labelled.dart';
import 'package:catch_dating_app/core/sentinels.dart';

enum EventSuccessUnitKind implements Labelled {
  wholeGroup('Whole group'),
  pods('Pods'),
  pairs('Pairs'),
  teams('Teams'),
  tables('Tables');

  const EventSuccessUnitKind(this.label);

  @override
  final String label;

  String get singularLabel => switch (this) {
    EventSuccessUnitKind.wholeGroup => 'group',
    EventSuccessUnitKind.pods => 'pod',
    EventSuccessUnitKind.pairs => 'pair',
    EventSuccessUnitKind.teams => 'team',
    EventSuccessUnitKind.tables => 'table',
  };

  String get setupHint => switch (this) {
    EventSuccessUnitKind.wholeGroup =>
      'Everyone stays in one shared flow; prompts happen at planned pauses.',
    EventSuccessUnitKind.pods =>
      'Small groups make arrival and first conversations less awkward.',
    EventSuccessUnitKind.pairs =>
      'Pairings work for racket sports, speed rounds, and direct rotations.',
    EventSuccessUnitKind.teams =>
      'Teams fit quizzes and collaborative activities with shared goals.',
    EventSuccessUnitKind.tables =>
      'Tables fit dinners and seated formats where movement is limited.',
  };

  bool get supportsUnitCount => this != EventSuccessUnitKind.wholeGroup;

  String get peoplePerLabel => switch (this) {
    EventSuccessUnitKind.wholeGroup => 'Attendance target',
    EventSuccessUnitKind.pods => 'People per pod',
    EventSuccessUnitKind.pairs => 'People per pair',
    EventSuccessUnitKind.teams => 'People per team',
    EventSuccessUnitKind.tables => 'People per table',
  };

  String get countLabel => switch (this) {
    EventSuccessUnitKind.wholeGroup => 'Group count',
    EventSuccessUnitKind.pods => 'Pod count',
    EventSuccessUnitKind.pairs => 'Pair count',
    EventSuccessUnitKind.teams => 'Team count',
    EventSuccessUnitKind.tables => 'Table count',
  };

  String countText(int count) =>
      '$count ${count == 1 ? singularLabel : label.toLowerCase()}';
}

enum EventSuccessRotationRepeatStrategy implements Labelled {
  avoid('Avoid repeats'),
  allowWhenExhausted('Allow when rounds run long');

  const EventSuccessRotationRepeatStrategy(this.label);

  @override
  final String label;
}

enum EventSuccessActivityAssignmentAttribute implements Labelled {
  paceBand('Pace'),
  skillBand('Skill'),
  roleBand('Role');

  const EventSuccessActivityAssignmentAttribute(this.label);

  @override
  final String label;

  String get balanceLabel => switch (this) {
    EventSuccessActivityAssignmentAttribute.paceBand => 'Spread pace',
    EventSuccessActivityAssignmentAttribute.skillBand => 'Spread skill',
    EventSuccessActivityAssignmentAttribute.roleBand => 'Spread roles',
  };

  String get clusterLabel => switch (this) {
    EventSuccessActivityAssignmentAttribute.paceBand => 'Pace together',
    EventSuccessActivityAssignmentAttribute.skillBand => 'Skill together',
    EventSuccessActivityAssignmentAttribute.roleBand => 'Role together',
  };
}

class EventSuccessStructureConfig {
  const EventSuccessStructureConfig({
    required this.unitKind,
    required this.unitSize,
    this.unitCount,
    this.rotationIntervalMinutes,
    this.revealCountdownSeconds = 10,
    this.rotationRepeatStrategy = EventSuccessRotationRepeatStrategy.avoid,
    this.maxPairMeetings = 2,
    this.balanceActivityAttributes = const [],
    this.clusterActivityAttributes = const [],
  }) : assert(unitSize > 0),
       assert(unitCount == null || unitCount > 0),
       assert(rotationIntervalMinutes == null || rotationIntervalMinutes >= 5),
       assert(revealCountdownSeconds >= 0),
       assert(maxPairMeetings >= 1);

  const EventSuccessStructureConfig.legacyDefault()
    : this(
        unitKind: EventSuccessUnitKind.pods,
        unitSize: 4,
        unitCount: null,
        rotationIntervalMinutes: null,
        revealCountdownSeconds: 10,
        rotationRepeatStrategy: EventSuccessRotationRepeatStrategy.avoid,
        maxPairMeetings: 2,
        balanceActivityAttributes: const [],
        clusterActivityAttributes: const [],
      );

  factory EventSuccessStructureConfig.defaultForActivity(
    ActivityKind activityKind, {
    int targetAttendeeCount = 20,
  }) => EventSuccessStructureConfig.defaultForInteractionModel(
    activityKind.defaultInteractionModel,
    targetAttendeeCount: targetAttendeeCount,
  );

  factory EventSuccessStructureConfig.defaultForFormat(
    EventFormatSnapshot format, {
    int targetAttendeeCount = 20,
  }) => EventSuccessStructureConfig.defaultForInteractionModel(
    format.interactionModel,
    targetAttendeeCount: targetAttendeeCount,
  );

  factory EventSuccessStructureConfig.defaultForInteractionModel(
    EventInteractionModel interactionModel, {
    int targetAttendeeCount = 20,
  }) {
    final safeTarget = targetAttendeeCount.clamp(1, 1000).toInt();
    return switch (interactionModel) {
      EventInteractionModel.pacePods => EventSuccessStructureConfig(
        unitKind: EventSuccessUnitKind.wholeGroup,
        unitSize: safeTarget,
        unitCount: 1,
      ),
      EventInteractionModel.pairedRotations =>
        const EventSuccessStructureConfig(
          unitKind: EventSuccessUnitKind.pairs,
          unitSize: 2,
          rotationIntervalMinutes: 15,
        ),
      EventInteractionModel.teamRotations => const EventSuccessStructureConfig(
        unitKind: EventSuccessUnitKind.teams,
        unitSize: 5,
      ),
      EventInteractionModel.seatedTable => const EventSuccessStructureConfig(
        unitKind: EventSuccessUnitKind.tables,
        unitSize: 4,
        rotationIntervalMinutes: 30,
      ),
      EventInteractionModel.freeFormMixer => const EventSuccessStructureConfig(
        unitKind: EventSuccessUnitKind.pairs,
        unitSize: 2,
        rotationIntervalMinutes: 15,
      ),
      EventInteractionModel.hostLedProgram ||
      EventInteractionModel.openFormat => EventSuccessStructureConfig(
        unitKind: EventSuccessUnitKind.wholeGroup,
        unitSize: safeTarget,
        unitCount: 1,
      ),
    };
  }

  factory EventSuccessStructureConfig.fromJson(Map<String, dynamic> json) {
    final unitKindName = json['unitKind'] as String?;
    final unitKind = EventSuccessUnitKind.values.firstWhere(
      (value) => value.name == unitKindName,
      orElse: () => EventSuccessUnitKind.pods,
    );
    return EventSuccessStructureConfig(
      unitKind: unitKind,
      unitSize: _intInRange(json['unitSize'], fallback: 4, min: 1, max: 1000),
      unitCount: _nullableIntInRange(json['unitCount'], min: 1, max: 200),
      rotationIntervalMinutes: _nullableIntInRange(
        json['rotationIntervalMinutes'],
        min: 5,
        max: 180,
      ),
      revealCountdownSeconds: _intInRange(
        json['revealCountdownSeconds'],
        fallback: 10,
        min: 0,
        max: 60,
      ),
      rotationRepeatStrategy: _repeatStrategyFromJson(
        json['rotationRepeatStrategy'],
      ),
      maxPairMeetings: _intInRange(
        json['maxPairMeetings'],
        fallback: 2,
        min: 1,
        max: 10,
      ),
      balanceActivityAttributes: _activityAttributesFromJson(
        json['balanceActivityAttributes'],
      ),
      clusterActivityAttributes: _activityAttributesFromJson(
        json['clusterActivityAttributes'],
      ),
    );
  }

  final EventSuccessUnitKind unitKind;
  final int unitSize;
  final int? unitCount;
  final int? rotationIntervalMinutes;
  final int revealCountdownSeconds;
  final EventSuccessRotationRepeatStrategy rotationRepeatStrategy;
  final int maxPairMeetings;
  final List<EventSuccessActivityAssignmentAttribute> balanceActivityAttributes;
  final List<EventSuccessActivityAssignmentAttribute> clusterActivityAttributes;

  bool get rotates => rotationIntervalMinutes != null;

  bool get isLegacyDefault =>
      unitKind == EventSuccessUnitKind.pods &&
      unitSize == 4 &&
      unitCount == null &&
      rotationIntervalMinutes == null &&
      revealCountdownSeconds == 10 &&
      rotationRepeatStrategy == EventSuccessRotationRepeatStrategy.avoid &&
      maxPairMeetings == 2 &&
      balanceActivityAttributes.isEmpty &&
      clusterActivityAttributes.isEmpty;

  bool get isDeprecatedTeamRotationDefault =>
      unitKind == EventSuccessUnitKind.teams &&
      unitSize == 5 &&
      unitCount == 3 &&
      rotationIntervalMinutes == null &&
      revealCountdownSeconds == 10 &&
      rotationRepeatStrategy == EventSuccessRotationRepeatStrategy.avoid &&
      maxPairMeetings == 2 &&
      balanceActivityAttributes.isEmpty &&
      clusterActivityAttributes.isEmpty;

  int estimatedUnitCount(int attendeeCount) {
    return estimateForAttendance(attendeeCount).unitCount;
  }

  EventSuccessStructureEstimate estimateForAttendance(int attendeeCount) {
    final safeAttendeeCount = attendeeCount.clamp(1, 1000).toInt();
    if (unitKind == EventSuccessUnitKind.wholeGroup) {
      return EventSuccessStructureEstimate(
        attendeeCount: safeAttendeeCount,
        unitCount: 1,
      );
    }
    final maxGroupCount = (safeAttendeeCount / 2).ceil().clamp(1, 200).toInt();
    final estimatedCount = (unitCount ?? (safeAttendeeCount / unitSize).ceil())
        .clamp(1, maxGroupCount)
        .toInt();
    return EventSuccessStructureEstimate(
      attendeeCount: safeAttendeeCount,
      unitCount: estimatedCount,
    );
  }

  int maxRotationRoundsForDuration(Duration duration) {
    final interval = rotationIntervalMinutes;
    if (interval == null || interval <= 0) return 0;
    return duration.inMinutes ~/ interval;
  }

  EventSuccessStructureConfig normalizedForTarget(int targetAttendeeCount) {
    if (unitKind != EventSuccessUnitKind.wholeGroup) return this;
    return copyWith(
      unitSize: targetAttendeeCount.clamp(1, 1000).toInt(),
      unitCount: 1,
    );
  }

  EventSuccessStructureConfig copyWith({
    EventSuccessUnitKind? unitKind,
    int? unitSize,
    Object? unitCount = unsetSentinel,
    Object? rotationIntervalMinutes = unsetSentinel,
    int? revealCountdownSeconds,
    EventSuccessRotationRepeatStrategy? rotationRepeatStrategy,
    int? maxPairMeetings,
    List<EventSuccessActivityAssignmentAttribute>? balanceActivityAttributes,
    List<EventSuccessActivityAssignmentAttribute>? clusterActivityAttributes,
  }) {
    return EventSuccessStructureConfig(
      unitKind: unitKind ?? this.unitKind,
      unitSize: unitSize ?? this.unitSize,
      unitCount: identical(unitCount, unsetSentinel)
          ? this.unitCount
          : unitCount as int?,
      rotationIntervalMinutes: identical(rotationIntervalMinutes, unsetSentinel)
          ? this.rotationIntervalMinutes
          : rotationIntervalMinutes as int?,
      revealCountdownSeconds:
          revealCountdownSeconds ?? this.revealCountdownSeconds,
      rotationRepeatStrategy:
          rotationRepeatStrategy ?? this.rotationRepeatStrategy,
      maxPairMeetings: maxPairMeetings ?? this.maxPairMeetings,
      balanceActivityAttributes:
          balanceActivityAttributes ?? this.balanceActivityAttributes,
      clusterActivityAttributes:
          clusterActivityAttributes ?? this.clusterActivityAttributes,
    );
  }

  Map<String, Object?> toJson() => {
    'unitKind': unitKind.name,
    'unitSize': unitSize,
    if (unitCount != null) 'unitCount': unitCount,
    if (rotationIntervalMinutes != null)
      'rotationIntervalMinutes': rotationIntervalMinutes,
    'revealCountdownSeconds': revealCountdownSeconds,
    'rotationRepeatStrategy': rotationRepeatStrategy.name,
    'maxPairMeetings': maxPairMeetings,
    if (balanceActivityAttributes.isNotEmpty)
      'balanceActivityAttributes': _activityAttributesToJson(
        balanceActivityAttributes,
      ),
    if (clusterActivityAttributes.isNotEmpty)
      'clusterActivityAttributes': _activityAttributesToJson(
        clusterActivityAttributes,
      ),
  };

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is EventSuccessStructureConfig &&
            other.unitKind == unitKind &&
            other.unitSize == unitSize &&
            other.unitCount == unitCount &&
            other.rotationIntervalMinutes == rotationIntervalMinutes &&
            other.revealCountdownSeconds == revealCountdownSeconds &&
            other.rotationRepeatStrategy == rotationRepeatStrategy &&
            other.maxPairMeetings == maxPairMeetings &&
            _activityAttributeListsEqual(
              other.balanceActivityAttributes,
              balanceActivityAttributes,
            ) &&
            _activityAttributeListsEqual(
              other.clusterActivityAttributes,
              clusterActivityAttributes,
            );
  }

  @override
  int get hashCode => Object.hash(
    unitKind,
    unitSize,
    unitCount,
    rotationIntervalMinutes,
    revealCountdownSeconds,
    rotationRepeatStrategy,
    maxPairMeetings,
    Object.hashAll(balanceActivityAttributes),
    Object.hashAll(clusterActivityAttributes),
  );
}

class EventSuccessStructureEstimate {
  const EventSuccessStructureEstimate({
    required this.attendeeCount,
    required this.unitCount,
  }) : assert(attendeeCount > 0),
       assert(unitCount > 0);

  final int attendeeCount;
  final int unitCount;

  int get minPeoplePerUnit => attendeeCount ~/ unitCount;

  int get maxPeoplePerUnit =>
      (attendeeCount / unitCount).ceil().clamp(1, attendeeCount).toInt();

  bool get isEven => minPeoplePerUnit == maxPeoplePerUnit;
}

int _intInRange(
  Object? value, {
  required int fallback,
  required int min,
  required int max,
}) {
  if (value is! num) return fallback;
  return value.toInt().clamp(min, max).toInt();
}

int? _nullableIntInRange(Object? value, {required int min, required int max}) {
  if (value == null || value is! num) return null;
  return value.toInt().clamp(min, max).toInt();
}

EventSuccessRotationRepeatStrategy _repeatStrategyFromJson(Object? value) {
  if (value is! String) return EventSuccessRotationRepeatStrategy.avoid;
  return EventSuccessRotationRepeatStrategy.values.firstWhere(
    (strategy) => strategy.name == value,
    orElse: () => EventSuccessRotationRepeatStrategy.avoid,
  );
}

List<EventSuccessActivityAssignmentAttribute> _activityAttributesFromJson(
  Object? value,
) {
  if (value is! Iterable) {
    return const [];
  }
  final seen = <EventSuccessActivityAssignmentAttribute>{};
  final attributes = <EventSuccessActivityAssignmentAttribute>[];
  for (final item in value) {
    if (item is! String) continue;
    EventSuccessActivityAssignmentAttribute? attribute;
    for (final candidate in EventSuccessActivityAssignmentAttribute.values) {
      if (candidate.name == item) {
        attribute = candidate;
        break;
      }
    }
    if (attribute == null || !seen.add(attribute)) continue;
    attributes.add(attribute);
  }
  return List.unmodifiable(attributes);
}

List<String> _activityAttributesToJson(
  List<EventSuccessActivityAssignmentAttribute> attributes,
) => [for (final attribute in attributes) attribute.name];

bool _activityAttributeListsEqual(
  List<EventSuccessActivityAssignmentAttribute> a,
  List<EventSuccessActivityAssignmentAttribute> b,
) {
  if (identical(a, b)) return true;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i += 1) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
