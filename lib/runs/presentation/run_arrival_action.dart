import 'package:catch_dating_app/core/business_rules.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';

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
      if (isSelfCheckInOpenForParticipationStatus(
        run: run,
        status: RunParticipationStatus.signedUp,
        now: now,
      ))
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

bool isSelfCheckInOpenForParticipationStatus({
  required Run run,
  required RunParticipationStatus? status,
  required DateTime now,
}) {
  return _isSelfCheckInOpen(
    run: run,
    isSignedUp: status == RunParticipationStatus.signedUp,
    hasAttended: status == RunParticipationStatus.attended,
    now: now,
  );
}

bool _isSelfCheckInOpen({
  required Run run,
  required bool isSignedUp,
  required bool hasAttended,
  required DateTime now,
}) {
  final startsAt = run.startTime.subtract(
    const Duration(
      minutes: CatchBusinessRules.runSelfCheckInWindowBeforeMinutes,
    ),
  );
  final endsAt = run.startTime.add(
    const Duration(
      minutes: CatchBusinessRules.runSelfCheckInWindowAfterMinutes,
    ),
  );
  return isSignedUp &&
      !hasAttended &&
      now.isAfter(startsAt) &&
      now.isBefore(endsAt);
}

bool isHostAttendanceOpen({required Run run, required DateTime now}) {
  final startsAt = hostAttendanceWindowStartsAt(run);
  final endsAt = hostAttendanceWindowEndsAt(run);
  return now.isAfter(startsAt) && now.isBefore(endsAt);
}

DateTime hostAttendanceWindowStartsAt(Run run) {
  return run.startTime.subtract(
    const Duration(
      minutes: CatchBusinessRules.runHostAttendanceWindowBeforeMinutes,
    ),
  );
}

DateTime hostAttendanceWindowEndsAt(Run run) {
  return run.endTime.add(
    const Duration(
      hours: CatchBusinessRules.runHostAttendanceWindowAfterRunHours,
    ),
  );
}
