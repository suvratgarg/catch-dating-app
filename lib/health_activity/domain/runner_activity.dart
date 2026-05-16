enum RunnerActivityProvider { catchAttendance, appleHealth, healthConnect }

enum RunnerActivityType { running, treadmillRunning }

class RunnerActivity {
  const RunnerActivity({
    required this.stableId,
    required this.provider,
    required this.type,
    required this.startTime,
    required this.endTime,
    required this.distanceMeters,
    this.isManualEntry = false,
    this.sourceName,
    this.matchedCatchRunId,
  });

  final String stableId;
  final RunnerActivityProvider provider;
  final RunnerActivityType type;
  final DateTime startTime;
  final DateTime endTime;
  final double distanceMeters;
  final bool isManualEntry;
  final String? sourceName;
  final String? matchedCatchRunId;

  double get distanceKm => distanceMeters / 1000;

  bool overlaps(DateTime start, DateTime end) {
    return startTime.isBefore(end) && endTime.isAfter(start);
  }
}
