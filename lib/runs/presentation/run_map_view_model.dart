import 'package:catch_dating_app/run_clubs/data/run_club_membership_repository.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_map_view_model.g.dart';

class RunMapViewModel {
  const RunMapViewModel({required this.runs, required this.pinnedRuns});

  final List<Run> runs;
  final List<Run> pinnedRuns;

  bool get isEmpty => runs.isEmpty;
  bool get hasPinnedRuns => pinnedRuns.isNotEmpty;

  Run? selectedRun(String? runId) {
    if (runId == null) return null;
    for (final run in runs) {
      if (run.id == runId) return run;
    }
    return null;
  }
}

RunMapViewModel buildRunMapViewModel({
  required List<Run> signedUpRuns,
  required List<Run> recommendedRuns,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final byId = <String, Run>{};
  for (final run in [
    ...recommendedRuns,
    ...signedUpRuns,
  ].where((run) => isUpcomingMapRun(run, effectiveNow))) {
    byId[run.id] = run;
  }

  final runs = byId.values.toList()
    ..sort((a, b) => a.startTime.compareTo(b.startTime));
  final pinnedRuns = runs.where(hasRunMapPin).toList(growable: false);

  return RunMapViewModel(
    runs: List.unmodifiable(runs),
    pinnedRuns: List.unmodifiable(pinnedRuns),
  );
}

bool hasRunMapPin(Run run) =>
    run.startingPointLat != null && run.startingPointLng != null;

bool isUpcomingMapRun(Run run, DateTime now) =>
    !run.isCancelled && run.startTime.isAfter(now);

/// Combines the current user's booked runs and recommended runs for the map.
///
/// The screen owns map selection and tile rendering. This provider owns the
/// feature data seam: profile lookup, run streams, recommendation fetch, merge,
/// de-duplication, chronological sort, and pin filtering.
@riverpod
AsyncValue<RunMapViewModel> runMapViewModel(Ref ref) {
  final userProfileAsync = ref.watch(watchUserProfileProvider);

  if (userProfileAsync.isLoading) return const AsyncLoading();
  if (userProfileAsync.hasError) {
    return AsyncError(
      userProfileAsync.error!,
      userProfileAsync.stackTrace ?? StackTrace.current,
    );
  }

  final user = userProfileAsync.asData?.value;
  if (user == null) {
    return const AsyncData(RunMapViewModel(runs: <Run>[], pinnedRuns: <Run>[]));
  }

  final signedUpAsync = ref.watch(watchSignedUpRunsProvider(user.uid));
  final membershipsAsync = ref.watch(
    watchActiveRunClubMembershipsForUserProvider(user.uid),
  );
  final followedClubIds =
      membershipsAsync.asData?.value
          .map((membership) => membership.clubId)
          .toList(growable: false) ??
      const <String>[];
  final recommendedAsync = ref.watch(
    recommendedRunsProvider(RecommendedRunsQuery.fromClubIds(followedClubIds)),
  );

  if (signedUpAsync.isLoading ||
      membershipsAsync.isLoading ||
      recommendedAsync.isLoading) {
    return const AsyncLoading();
  }
  if (signedUpAsync.hasError) {
    return AsyncError(
      signedUpAsync.error!,
      signedUpAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (membershipsAsync.hasError) {
    return AsyncError(
      membershipsAsync.error!,
      membershipsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (recommendedAsync.hasError) {
    return AsyncError(
      recommendedAsync.error!,
      recommendedAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(
    buildRunMapViewModel(
      signedUpRuns: signedUpAsync.asData?.value ?? const <Run>[],
      recommendedRuns: recommendedAsync.asData?.value ?? const <Run>[],
    ),
  );
}
