import 'package:catch_dating_app/runs/domain/run.dart';

const swipeWindowDuration = Duration(hours: 24);

DateTime swipeWindowClosesAt(Run run) => run.endTime.add(swipeWindowDuration);

bool hasOpenSwipeWindow(Run run, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  if (run.endTime.isAfter(currentTime)) return false;
  return !swipeWindowClosesAt(run).isBefore(currentTime);
}

List<Run> runsWithOpenSwipeWindow(Iterable<Run> runs, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  final open = <Run>[];
  for (final run in runs) {
    if (hasOpenSwipeWindow(run, now: currentTime)) open.add(run);
  }
  return open;
}

Run? latestRunWithOpenSwipeWindow(Iterable<Run> runs, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  Run? latestRun;
  for (final run in runs) {
    if (!hasOpenSwipeWindow(run, now: currentTime)) continue;
    if (latestRun == null || run.endTime.isAfter(latestRun.endTime)) {
      latestRun = run;
    }
  }
  return latestRun;
}
