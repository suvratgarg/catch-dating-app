import 'package:catch_dating_app/runs/domain/run.dart';

enum RunArrivalActionKind { selfCheckIn, takeAttendance }

class RunArrivalAction {
  const RunArrivalAction({required this.kind, required this.run});

  final RunArrivalActionKind kind;
  final Run run;
}

RunArrivalAction? selectRunArrivalAction({
  required List<Run> signedUpRuns,
  required List<Run> hostedRuns,
  required String uid,
  required DateTime now,
}) {
  final candidates = <RunArrivalAction>[
    for (final run in signedUpRuns)
      if (isSelfCheckInOpen(run: run, uid: uid, now: now))
        RunArrivalAction(kind: RunArrivalActionKind.selfCheckIn, run: run),
    for (final run in hostedRuns)
      if (isHostAttendanceOpen(run: run, now: now))
        RunArrivalAction(kind: RunArrivalActionKind.takeAttendance, run: run),
  ];

  candidates.sort((a, b) {
    final time = a.run.startTime.compareTo(b.run.startTime);
    if (time != 0) return time;
    return a.kind.index.compareTo(b.kind.index);
  });

  return candidates.firstOrNull;
}

bool isSelfCheckInOpen({
  required Run run,
  required String uid,
  required DateTime now,
}) {
  final startsAt = run.startTime.subtract(const Duration(minutes: 30));
  final endsAt = run.startTime.add(const Duration(minutes: 30));
  return run.isSignedUp(uid) &&
      !run.hasAttended(uid) &&
      now.isAfter(startsAt) &&
      now.isBefore(endsAt);
}

bool isHostAttendanceOpen({required Run run, required DateTime now}) {
  final startsAt = run.startTime.subtract(const Duration(minutes: 10));
  final endsAt = run.endTime.add(const Duration(hours: 6));
  return now.isAfter(startsAt) && now.isBefore(endsAt);
}
