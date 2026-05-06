import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/domain/run_participation_roster.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'attendance_sheet_view_model.g.dart';

class AttendanceSheetViewModel {
  const AttendanceSheetViewModel({
    required this.run,
    required this.attendeeIds,
    required this.attendedIds,
  });

  final Run run;
  final List<String> attendeeIds;
  final Set<String> attendedIds;

  int get checkedInCount => attendeeIds.where(attendedIds.contains).length;

  int get totalCount => attendeeIds.length;

  bool get isEmpty => attendeeIds.isEmpty;

  bool isAttended(String uid) => attendedIds.contains(uid);
}

@riverpod
AsyncValue<AttendanceSheetViewModel?> attendanceSheetViewModel(
  Ref ref,
  String runId,
) {
  return buildAttendanceSheetViewModel(
    runAsync: ref.watch(watchRunProvider(runId)),
    participationsAsync: ref.watch(watchRunParticipationsForRunProvider(runId)),
  );
}

AsyncValue<AttendanceSheetViewModel?> buildAttendanceSheetViewModel({
  required AsyncValue<Run?> runAsync,
  required AsyncValue<List<RunParticipation>> participationsAsync,
}) {
  if (runAsync.isLoading || participationsAsync.isLoading) {
    return const AsyncLoading();
  }

  if (runAsync.hasError) {
    return AsyncError(
      runAsync.error!,
      runAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (participationsAsync.hasError) {
    return AsyncError(
      participationsAsync.error!,
      participationsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final run = runAsync.asData?.value;
  if (run == null) return const AsyncData(null);

  final roster = RunParticipationRoster.fromParticipations(
    participationsAsync.asData?.value ?? const [],
  );

  return AsyncData(
    AttendanceSheetViewModel(
      run: run,
      attendeeIds: roster.bookedIds,
      attendedIds: Set.unmodifiable(roster.checkedInIds),
    ),
  );
}
