import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:collection/collection.dart';

const swipeWindowDuration = Duration(hours: 24);

DateTime swipeWindowClosesAt(Run run) => run.endTime.add(swipeWindowDuration);

bool hasOpenSwipeWindow(Run run, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  if (run.endTime.isAfter(currentTime)) return false;
  return !swipeWindowClosesAt(run).isBefore(currentTime);
}

List<Run> runsWithOpenSwipeWindow(Iterable<Run> runs, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  return runs
      .where((run) => hasOpenSwipeWindow(run, now: currentTime))
      .toList();
}

Run? latestRunWithOpenSwipeWindow(Iterable<Run> runs, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  return maxBy(
    runs.where((run) => hasOpenSwipeWindow(run, now: currentTime)),
    (run) => run.endTime,
  );
}
