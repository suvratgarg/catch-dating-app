import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_full_view_model.g.dart';

enum DashboardSectionStatus { loading, error, data }

class DashboardSectionModel<T> {
  const DashboardSectionModel._({
    required this.status,
    this.message,
    this.data,
  });

  const DashboardSectionModel.loading(String message)
    : this._(status: DashboardSectionStatus.loading, message: message);

  const DashboardSectionModel.error(String message)
    : this._(status: DashboardSectionStatus.error, message: message);

  const DashboardSectionModel.data(T data)
    : this._(status: DashboardSectionStatus.data, data: data);

  final DashboardSectionStatus status;
  final String? message;
  final T? data;

  bool get isLoading => status == DashboardSectionStatus.loading;
  bool get hasError => status == DashboardSectionStatus.error;
}

class DashboardFullViewModel {
  const DashboardFullViewModel({
    required this.nextRun,
    required this.activeSwipeRun,
    required this.attendedRunsSection,
    required this.recommendationsSection,
  });

  final Run? nextRun;
  final Run? activeSwipeRun;
  final DashboardSectionModel<List<Run>> attendedRunsSection;
  final DashboardSectionModel<List<Run>> recommendationsSection;
}

DashboardFullViewModel buildDashboardFullViewModel({
  required List<Run> signedUpRuns,
  required AsyncValue<List<Run>> attendedRunsAsync,
  required AsyncValue<List<Run>> recommendedRunsAsync,
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();

  final nextRun = signedUpRuns
      .where((run) => run.startTime.isAfter(effectiveNow))
      .fold<Run?>(
        null,
        (best, run) =>
            best == null || run.startTime.isBefore(best.startTime) ? run : best,
      );

  final attendedRunsSection = attendedRunsAsync.when(
    loading: () => const DashboardSectionModel<List<Run>>.loading(
      'Loading your recent runs...',
    ),
    error: (error, stackTrace) => const DashboardSectionModel<List<Run>>.error(
      'Unable to load your recent runs.',
    ),
    data: DashboardSectionModel<List<Run>>.data,
  );

  final recommendationsSection = recommendedRunsAsync.when(
    loading: () => const DashboardSectionModel<List<Run>>.loading(
      'Loading recommended runs...',
    ),
    error: (error, stackTrace) => const DashboardSectionModel<List<Run>>.error(
      'Unable to load recommended runs.',
    ),
    data: DashboardSectionModel<List<Run>>.data,
  );

  final activeSwipeRun = attendedRunsSection.data == null
      ? null
      : latestRunWithOpenSwipeWindow(
          attendedRunsSection.data!,
          now: effectiveNow,
        );

  return DashboardFullViewModel(
    nextRun: nextRun,
    activeSwipeRun: activeSwipeRun,
    attendedRunsSection: attendedRunsSection,
    recommendationsSection: recommendationsSection,
  );
}

/// Combines signed-up runs, attended runs, and recommended runs into a single
/// [DashboardFullViewModel] for the dashboard screen.
@riverpod
DashboardFullViewModel dashboardFullViewModel(
  Ref ref, {
  required List<Run> signedUpRuns,
  required String uid,
  required List<String> followedClubIds,
}) {
  return buildDashboardFullViewModel(
    signedUpRuns: signedUpRuns,
    attendedRunsAsync: ref.watch(watchAttendedRunsProvider(uid)),
    recommendedRunsAsync: ref.watch(recommendedRunsProvider(followedClubIds)),
  );
}
