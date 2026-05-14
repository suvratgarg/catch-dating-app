import 'package:catch_dating_app/run_clubs/data/run_club_membership_repository.dart';
import 'package:catch_dating_app/run_clubs/presentation/run_club_name_lookup.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/data/saved_run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/widgets/run_tiles/run_tiles.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_map_view_model.g.dart';

class RunMapItem {
  const RunMapItem({required this.run, required this.status, this.clubName});

  final Run run;
  final RunTileStatus status;
  final String? clubName;

  RunTileData get tileData =>
      RunTileData.fromRun(run: run, status: status, clubName: clubName);
}

class RunMapViewModel {
  const RunMapViewModel({
    required this.runs,
    required this.pinnedRuns,
    this.items = const [],
    this.pinnedItems = const [],
  });

  final List<Run> runs;
  final List<Run> pinnedRuns;
  final List<RunMapItem> items;
  final List<RunMapItem> pinnedItems;

  bool get isEmpty => runs.isEmpty;
  bool get hasPinnedRuns => pinnedRuns.isNotEmpty;
  List<RunMapItem> get effectiveItems => items.isEmpty && runs.isNotEmpty
      ? [
          for (final run in runs)
            RunMapItem(run: run, status: RunTileStatus.open),
        ]
      : items;
  List<RunMapItem> get effectivePinnedItems =>
      pinnedItems.isEmpty && pinnedRuns.isNotEmpty
      ? [
          for (final run in pinnedRuns)
            RunMapItem(run: run, status: RunTileStatus.open),
        ]
      : pinnedItems;

  Run? selectedRun(String? runId) {
    if (runId == null) return null;
    for (final run in runs) {
      if (run.id == runId) return run;
    }
    return null;
  }

  RunMapItem? selectedItem(String? runId) {
    if (runId == null) return null;
    for (final item in effectiveItems) {
      if (item.run.id == runId) return item;
    }
    return null;
  }
}

RunMapViewModel buildRunMapViewModel({
  required List<Run> signedUpRuns,
  List<Run> savedRuns = const <Run>[],
  required List<Run> recommendedRuns,
  Map<String, String> clubNamesById = const <String, String>{},
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final byId = <String, RunMapItem>{};

  void addRun(Run run, RunTileStatus status) {
    if (!isUpcomingMapRun(run, effectiveNow)) return;
    byId[run.id] = RunMapItem(
      run: run,
      status: status,
      clubName: clubNamesById[run.runClubId],
    );
  }

  for (final run in recommendedRuns) {
    addRun(run, RunTileStatus.recommended);
  }
  for (final run in savedRuns) {
    addRun(run, RunTileStatus.saved);
  }
  for (final run in signedUpRuns) {
    addRun(run, RunTileStatus.joined);
  }

  final items = byId.values.toList()
    ..sort((a, b) => a.run.startTime.compareTo(b.run.startTime));
  final pinnedItems = items
      .where((item) => hasRunMapPin(item.run))
      .toList(growable: false);
  final runs = items.map((item) => item.run).toList(growable: false);
  final pinnedRuns = pinnedItems
      .map((item) => item.run)
      .toList(growable: false);

  return RunMapViewModel(
    runs: List.unmodifiable(runs),
    pinnedRuns: List.unmodifiable(pinnedRuns),
    items: List.unmodifiable(items),
    pinnedItems: List.unmodifiable(pinnedItems),
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
  final savedAsync = ref.watch(watchSavedRunDetailsForUserProvider(user.uid));
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
      savedAsync.isLoading ||
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
  if (savedAsync.hasError) {
    return AsyncError(
      savedAsync.error!,
      savedAsync.stackTrace ?? StackTrace.current,
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

  final allRuns = <Run>[
    ...?signedUpAsync.asData?.value,
    ...?savedAsync.asData?.value,
    ...?recommendedAsync.asData?.value,
  ];
  final clubNamesAsync = ref.watch(
    runClubNameLookupProvider(
      RunClubNameLookupQuery(allRuns.map((run) => run.runClubId)),
    ),
  );
  if (clubNamesAsync.isLoading) return const AsyncLoading();
  if (clubNamesAsync.hasError) {
    return AsyncError(
      clubNamesAsync.error!,
      clubNamesAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(
    buildRunMapViewModel(
      signedUpRuns: signedUpAsync.asData?.value ?? const <Run>[],
      savedRuns: savedAsync.asData?.value ?? const <Run>[],
      recommendedRuns: recommendedAsync.asData?.value ?? const <Run>[],
      clubNamesById: clubNamesAsync.asData?.value ?? const <String, String>{},
    ),
  );
}
