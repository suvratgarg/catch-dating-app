import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/runs/data/run_participation_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_participation.dart';
import 'package:catch_dating_app/runs/domain/run_participation_roster.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_recap_view_model.g.dart';

class RunRecapViewModel {
  const RunRecapViewModel({
    required this.run,
    required this.attendeeIds,
    required this.checkedInCount,
  });

  final Run run;
  final List<String> attendeeIds;
  final int checkedInCount;
}

@riverpod
AsyncValue<RunRecapViewModel?> runRecapViewModel(Ref ref, String runId) {
  return buildRunRecapViewModel(
    runAsync: ref.watch(watchRunProvider(runId)),
    uidAsync: ref.watch(uidProvider),
    participationsAsync: ref.watch(watchRunParticipationsForRunProvider(runId)),
  );
}

AsyncValue<RunRecapViewModel?> buildRunRecapViewModel({
  required AsyncValue<Run?> runAsync,
  required AsyncValue<String?> uidAsync,
  required AsyncValue<List<RunParticipation>> participationsAsync,
}) {
  if (runAsync.isLoading ||
      uidAsync.isLoading ||
      participationsAsync.isLoading) {
    return const AsyncLoading();
  }

  if (runAsync.hasError) {
    return AsyncError(
      runAsync.error!,
      runAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (uidAsync.hasError) {
    return AsyncError(
      uidAsync.error!,
      uidAsync.stackTrace ?? StackTrace.current,
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

  final currentUid = uidAsync.asData?.value;
  final roster = RunParticipationRoster.fromParticipations(
    participationsAsync.asData?.value ?? const [],
  );
  final attendeeIds = roster.checkedInIds
      .where((uid) => uid != currentUid)
      .toList(growable: false);

  return AsyncData(
    RunRecapViewModel(
      run: run,
      attendeeIds: List.unmodifiable(attendeeIds),
      checkedInCount: roster.checkedInCount,
    ),
  );
}
