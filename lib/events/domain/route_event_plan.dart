import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:collection/collection.dart';

enum RouteMovementMode { run, walk, ride, mixed }

enum RouteShape { loop, outAndBack, pointToPoint }

enum RouteGroupStrategy { together, paceGroups, selfDirected }

enum RouteStopCadence { continuous, flexibleStops, hostedStops }

enum RouteStopKind {
  water,
  regroup,
  venue,
  photoSpot,
  viewpoint,
  hazard,
  turnaround,
}

enum RouteRoleKind { routeLead, sweep, pacer, stopHost, marshal, photographer }

/// Activity-agnostic operations for an event that moves through a route.
///
/// Activity type remains responsible for the broader event format. This plan
/// composes only how attendees move, stop, and stay accounted for, so runs,
/// walks, crawls, rides, and custom moving events can reuse one contract.
class RouteEventPlan {
  const RouteEventPlan({
    this.version = 1,
    required this.movementMode,
    required this.routeShape,
    required this.groupStrategy,
    required this.stopCadence,
    required this.stopKinds,
    required this.roleKinds,
  });

  static const socialRun = RouteEventPlan(
    movementMode: RouteMovementMode.run,
    routeShape: RouteShape.loop,
    groupStrategy: RouteGroupStrategy.paceGroups,
    stopCadence: RouteStopCadence.continuous,
    stopKinds: [
      RouteStopKind.water,
      RouteStopKind.regroup,
      RouteStopKind.hazard,
    ],
    roleKinds: [
      RouteRoleKind.routeLead,
      RouteRoleKind.sweep,
      RouteRoleKind.pacer,
    ],
  );

  static const socialWalk = RouteEventPlan(
    movementMode: RouteMovementMode.walk,
    routeShape: RouteShape.loop,
    groupStrategy: RouteGroupStrategy.together,
    stopCadence: RouteStopCadence.flexibleStops,
    stopKinds: [
      RouteStopKind.regroup,
      RouteStopKind.viewpoint,
      RouteStopKind.hazard,
    ],
    roleKinds: [RouteRoleKind.routeLead, RouteRoleKind.sweep],
  );

  static const socialRide = RouteEventPlan(
    movementMode: RouteMovementMode.ride,
    routeShape: RouteShape.loop,
    groupStrategy: RouteGroupStrategy.paceGroups,
    stopCadence: RouteStopCadence.flexibleStops,
    stopKinds: [
      RouteStopKind.water,
      RouteStopKind.regroup,
      RouteStopKind.hazard,
      RouteStopKind.turnaround,
    ],
    roleKinds: [
      RouteRoleKind.routeLead,
      RouteRoleKind.sweep,
      RouteRoleKind.pacer,
      RouteRoleKind.marshal,
    ],
  );

  static const hostedWalk = RouteEventPlan(
    movementMode: RouteMovementMode.walk,
    routeShape: RouteShape.pointToPoint,
    groupStrategy: RouteGroupStrategy.together,
    stopCadence: RouteStopCadence.hostedStops,
    stopKinds: [
      RouteStopKind.venue,
      RouteStopKind.regroup,
      RouteStopKind.hazard,
    ],
    roleKinds: [
      RouteRoleKind.routeLead,
      RouteRoleKind.sweep,
      RouteRoleKind.stopHost,
    ],
  );

  static const customWalk = RouteEventPlan(
    movementMode: RouteMovementMode.walk,
    routeShape: RouteShape.loop,
    groupStrategy: RouteGroupStrategy.together,
    stopCadence: RouteStopCadence.hostedStops,
    stopKinds: [
      RouteStopKind.regroup,
      RouteStopKind.photoSpot,
      RouteStopKind.viewpoint,
      RouteStopKind.hazard,
    ],
    roleKinds: [
      RouteRoleKind.routeLead,
      RouteRoleKind.sweep,
      RouteRoleKind.stopHost,
      RouteRoleKind.photographer,
    ],
  );

  static RouteEventPlan? defaultForActivity(ActivityKind activityKind) =>
      switch (activityKind) {
        ActivityKind.socialRun || ActivityKind.running => socialRun,
        ActivityKind.walking => socialWalk,
        ActivityKind.cycling => socialRide,
        ActivityKind.barCrawl => hostedWalk,
        ActivityKind.pickleball ||
        ActivityKind.padel ||
        ActivityKind.tennis ||
        ActivityKind.badminton ||
        ActivityKind.spinClass ||
        ActivityKind.yoga ||
        ActivityKind.strengthTraining ||
        ActivityKind.pubQuiz ||
        ActivityKind.dinner ||
        ActivityKind.singlesMixer ||
        ActivityKind.openActivity => null,
      };

  static RouteEventPlan? tryFromJson(Object? value) {
    if (value is! Map<Object?, Object?>) return null;
    final version = value['version'];
    final movementMode = _enumByName(
      RouteMovementMode.values,
      value['movementMode'],
    );
    final routeShape = _enumByName(RouteShape.values, value['routeShape']);
    final groupStrategy = _enumByName(
      RouteGroupStrategy.values,
      value['groupStrategy'],
    );
    final stopCadence = _enumByName(
      RouteStopCadence.values,
      value['stopCadence'],
    );
    final stopKinds = _enumList(RouteStopKind.values, value['stopKinds']);
    final roleKinds = _enumList(RouteRoleKind.values, value['roleKinds']);
    if (version != 1 ||
        movementMode == null ||
        routeShape == null ||
        groupStrategy == null ||
        stopCadence == null ||
        stopKinds.isEmpty ||
        roleKinds.isEmpty) {
      return null;
    }
    return RouteEventPlan(
      movementMode: movementMode,
      routeShape: routeShape,
      groupStrategy: groupStrategy,
      stopCadence: stopCadence,
      stopKinds: stopKinds,
      roleKinds: roleKinds,
    );
  }

  final int version;
  final RouteMovementMode movementMode;
  final RouteShape routeShape;
  final RouteGroupStrategy groupStrategy;
  final RouteStopCadence stopCadence;
  final List<RouteStopKind> stopKinds;
  final List<RouteRoleKind> roleKinds;

  RouteEventPlan copyWith({
    RouteMovementMode? movementMode,
    RouteShape? routeShape,
    RouteGroupStrategy? groupStrategy,
    RouteStopCadence? stopCadence,
    List<RouteStopKind>? stopKinds,
    List<RouteRoleKind>? roleKinds,
  }) => RouteEventPlan(
    version: version,
    movementMode: movementMode ?? this.movementMode,
    routeShape: routeShape ?? this.routeShape,
    groupStrategy: groupStrategy ?? this.groupStrategy,
    stopCadence: stopCadence ?? this.stopCadence,
    stopKinds: stopKinds ?? this.stopKinds,
    roleKinds: roleKinds ?? this.roleKinds,
  );

  Map<String, dynamic> toJson() => {
    'version': version,
    'movementMode': movementMode.name,
    'routeShape': routeShape.name,
    'groupStrategy': groupStrategy.name,
    'stopCadence': stopCadence.name,
    'stopKinds': stopKinds.map((value) => value.name).toList(growable: false),
    'roleKinds': roleKinds.map((value) => value.name).toList(growable: false),
  };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RouteEventPlan &&
          version == other.version &&
          movementMode == other.movementMode &&
          routeShape == other.routeShape &&
          groupStrategy == other.groupStrategy &&
          stopCadence == other.stopCadence &&
          const ListEquality<RouteStopKind>().equals(
            stopKinds,
            other.stopKinds,
          ) &&
          const ListEquality<RouteRoleKind>().equals(
            roleKinds,
            other.roleKinds,
          );

  @override
  int get hashCode => Object.hash(
    version,
    movementMode,
    routeShape,
    groupStrategy,
    stopCadence,
    const ListEquality<RouteStopKind>().hash(stopKinds),
    const ListEquality<RouteRoleKind>().hash(roleKinds),
  );
}

extension RouteEventFormatX on EventFormatSnapshot {
  RouteEventPlan? get routePlan =>
      RouteEventPlan.tryFromJson(activityDetails['routePlan']);
}

T? _enumByName<T extends Enum>(List<T> values, Object? rawName) {
  if (rawName is! String) return null;
  for (final value in values) {
    if (value.name == rawName) return value;
  }
  return null;
}

List<T> _enumList<T extends Enum>(List<T> values, Object? rawValues) {
  if (rawValues is! List<Object?>) return const [];
  final resolved = <T>[];
  for (final rawValue in rawValues) {
    final value = _enumByName(values, rawValue);
    if (value != null && !resolved.contains(value)) resolved.add(value);
  }
  return resolved;
}
