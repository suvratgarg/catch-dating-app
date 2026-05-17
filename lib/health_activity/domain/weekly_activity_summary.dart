import 'package:catch_dating_app/health_activity/domain/runner_activity.dart';

enum HealthActivityConnectionStatus {
  unsupported,
  needsHealthConnect,
  permissionRequired,
  connected,
}

enum WeeklyRunningActivitySource { none, healthPlatform, catchFallback, mixed }

class WeeklyActivitySummary {
  const WeeklyActivitySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.distanceMetersByWeekday,
    required this.runCount,
    this.refreshedAt,
  }) : assert(distanceMetersByWeekday.length == 7);

  final DateTime weekStart;
  final DateTime weekEnd;
  final List<double> distanceMetersByWeekday;
  final int runCount;
  final DateTime? refreshedAt;

  double get totalDistanceMeters =>
      distanceMetersByWeekday.fold<double>(0, (sum, meters) => sum + meters);

  double get totalDistanceKm => totalDistanceMeters / 1000;

  double get maxDailyDistanceMeters => distanceMetersByWeekday.fold<double>(
    0,
    (max, meters) => meters > max ? meters : max,
  );

  bool get hasRuns => runCount > 0 && totalDistanceMeters > 0;

  static DateTime weekStartFor(DateTime date) {
    return DateTime(date.year, date.month, date.day - (date.weekday - 1));
  }

  factory WeeklyActivitySummary.emptyForWeek(
    DateTime referenceDate, {
    DateTime? refreshedAt,
  }) {
    final weekStart = weekStartFor(referenceDate);
    return WeeklyActivitySummary(
      weekStart: weekStart,
      weekEnd: weekStart.add(const Duration(days: 7)),
      distanceMetersByWeekday: List<double>.filled(7, 0),
      runCount: 0,
      refreshedAt: refreshedAt,
    );
  }

  factory WeeklyActivitySummary.fromActivities(
    Iterable<RunnerActivity> activities, {
    required DateTime referenceDate,
    DateTime? refreshedAt,
  }) {
    final weekStart = weekStartFor(referenceDate);
    final weekEnd = weekStart.add(const Duration(days: 7));
    final metersByWeekday = List<double>.filled(7, 0);
    var count = 0;

    for (final activity in activities) {
      final startsInWeek =
          !activity.startTime.isBefore(weekStart) &&
          activity.startTime.isBefore(weekEnd);
      if (!startsInWeek || activity.distanceMeters <= 0) {
        continue;
      }

      metersByWeekday[activity.startTime.weekday - 1] +=
          activity.distanceMeters;
      count++;
    }

    return WeeklyActivitySummary(
      weekStart: weekStart,
      weekEnd: weekEnd,
      distanceMetersByWeekday: metersByWeekday,
      runCount: count,
      refreshedAt: refreshedAt,
    );
  }
}

class WeeklyRunningActivitySnapshot {
  const WeeklyRunningActivitySnapshot({
    required this.connectionStatus,
    required this.platformLabel,
    required this.summary,
    required this.activities,
    required this.source,
    this.message,
    this.canRequestPermission = false,
    this.canInstallHealthConnect = false,
  });

  final HealthActivityConnectionStatus connectionStatus;
  final String platformLabel;
  final WeeklyActivitySummary summary;
  final List<RunnerActivity> activities;
  final WeeklyRunningActivitySource source;
  final String? message;
  final bool canRequestPermission;
  final bool canInstallHealthConnect;

  bool get hasPlatformConnection =>
      connectionStatus == HealthActivityConnectionStatus.connected;

  bool get hasRuns => summary.hasRuns;

  factory WeeklyRunningActivitySnapshot.unsupported({
    required DateTime referenceDate,
    DateTime? refreshedAt,
    String message = 'Running activity is available on iPhone and Android.',
  }) {
    return WeeklyRunningActivitySnapshot(
      connectionStatus: HealthActivityConnectionStatus.unsupported,
      platformLabel: 'Health',
      summary: WeeklyActivitySummary.emptyForWeek(
        referenceDate,
        refreshedAt: refreshedAt,
      ),
      activities: const [],
      source: WeeklyRunningActivitySource.none,
      message: message,
    );
  }

  factory WeeklyRunningActivitySnapshot.needsHealthConnect({
    required DateTime referenceDate,
    DateTime? refreshedAt,
  }) {
    return WeeklyRunningActivitySnapshot(
      connectionStatus: HealthActivityConnectionStatus.needsHealthConnect,
      platformLabel: 'Health Connect',
      summary: WeeklyActivitySummary.emptyForWeek(
        referenceDate,
        refreshedAt: refreshedAt,
      ),
      activities: const [],
      source: WeeklyRunningActivitySource.none,
      message: 'Install or update Health Connect to show weekly runs.',
      canInstallHealthConnect: true,
    );
  }

  factory WeeklyRunningActivitySnapshot.permissionRequired({
    required DateTime referenceDate,
    required String platformLabel,
    DateTime? refreshedAt,
  }) {
    return WeeklyRunningActivitySnapshot(
      connectionStatus: HealthActivityConnectionStatus.permissionRequired,
      platformLabel: platformLabel,
      summary: WeeklyActivitySummary.emptyForWeek(
        referenceDate,
        refreshedAt: refreshedAt,
      ),
      activities: const [],
      source: WeeklyRunningActivitySource.none,
      message: 'Connect $platformLabel to include runs outside Catch.',
      canRequestPermission: true,
    );
  }

  factory WeeklyRunningActivitySnapshot.connected({
    required DateTime referenceDate,
    required String platformLabel,
    required List<RunnerActivity> activities,
    DateTime? refreshedAt,
  }) {
    final summary = WeeklyActivitySummary.fromActivities(
      activities,
      referenceDate: referenceDate,
      refreshedAt: refreshedAt,
    );
    return WeeklyRunningActivitySnapshot(
      connectionStatus: HealthActivityConnectionStatus.connected,
      platformLabel: platformLabel,
      summary: summary,
      activities: List.unmodifiable(activities),
      source: summary.hasRuns
          ? WeeklyRunningActivitySource.healthPlatform
          : WeeklyRunningActivitySource.none,
      message: null,
    );
  }

  WeeklyRunningActivitySnapshot copyWith({
    WeeklyActivitySummary? summary,
    List<RunnerActivity>? activities,
    WeeklyRunningActivitySource? source,
    String? message,
    bool clearMessage = false,
    bool? canRequestPermission,
    bool? canInstallHealthConnect,
  }) {
    return WeeklyRunningActivitySnapshot(
      connectionStatus: connectionStatus,
      platformLabel: platformLabel,
      summary: summary ?? this.summary,
      activities: activities == null
          ? this.activities
          : List.unmodifiable(activities),
      source: source ?? this.source,
      message: clearMessage ? null : message ?? this.message,
      canRequestPermission: canRequestPermission ?? this.canRequestPermission,
      canInstallHealthConnect:
          canInstallHealthConnect ?? this.canInstallHealthConnect,
    );
  }
}
