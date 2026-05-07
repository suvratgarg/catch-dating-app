import 'package:catch_dating_app/dashboard/presentation/dashboard_recommendations_provider.dart';
import 'package:catch_dating_app/reviews/data/reviews_repository.dart';
import 'package:catch_dating_app/reviews/domain/review.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_arrival_action.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
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
    required this.arrivalAction,
    required this.activeSwipeRun,
    required this.pendingReviewRun,
    required this.attendedRunsSection,
    required this.recommendationsSection,
  });

  final Run? nextRun;
  final RunArrivalAction? arrivalAction;
  final Run? activeSwipeRun;
  final Run? pendingReviewRun;
  final DashboardSectionModel<List<Run>> attendedRunsSection;
  final DashboardSectionModel<List<Run>> recommendationsSection;
}

DashboardFullViewModel buildDashboardFullViewModel({
  required List<Run> signedUpRuns,
  String? uid,
  List<Run> hostedRuns = const [],
  required AsyncValue<List<Run>> attendedRunsAsync,
  required AsyncValue<List<Run>> recommendedRunsAsync,
  AsyncValue<List<Review>> reviewsByUserAsync = const AsyncData<List<Review>>(
    [],
  ),
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
  final reviewedRunIds =
      reviewsByUserAsync.asData?.value
          .map((review) => review.runId)
          .whereType<String>()
          .toSet() ??
      const <String>{};
  final pendingReviewRun = attendedRunsSection.data == null
      ? null
      : _latestUnreviewedAttendedRun(
          attendedRunsSection.data!,
          reviewedRunIds: reviewedRunIds,
        );
  final arrivalAction = uid == null
      ? null
      : selectRunArrivalAction(
          signedUpRuns: signedUpRuns,
          hostedRuns: hostedRuns,
          uid: uid,
          now: effectiveNow,
        );

  return DashboardFullViewModel(
    nextRun: nextRun,
    arrivalAction: arrivalAction,
    activeSwipeRun: activeSwipeRun,
    pendingReviewRun: pendingReviewRun,
    attendedRunsSection: attendedRunsSection,
    recommendationsSection: recommendationsSection,
  );
}

Run? _latestUnreviewedAttendedRun(
  List<Run> attendedRuns, {
  required Set<String> reviewedRunIds,
}) {
  final unreviewedRuns =
      attendedRuns.where((run) => !reviewedRunIds.contains(run.id)).toList()
        ..sort((a, b) => b.endTime.compareTo(a.endTime));
  return unreviewedRuns.firstOrNull;
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
  final hostedClubs = ref
      .watch(watchRunClubsHostedByProvider(uid))
      .asData
      ?.value;
  final hostedRuns = <Run>[];
  for (final club in hostedClubs ?? const <RunClub>[]) {
    final runs = ref.watch(watchRunsForClubProvider(club.id)).asData?.value;
    if (runs != null) {
      hostedRuns.addAll(runs);
    }
  }

  return buildDashboardFullViewModel(
    signedUpRuns: signedUpRuns,
    uid: uid,
    hostedRuns: hostedRuns,
    attendedRunsAsync: ref.watch(watchAttendedRunsProvider(uid)),
    reviewsByUserAsync: ref.watch(watchReviewsByUserProvider(uid)),
    recommendedRunsAsync: ref.watch(
      dashboardRecommendedRunsProvider(
        DashboardRecommendationsQuery(
          userId: uid,
          followedClubIds: followedClubIds,
        ),
      ),
    ),
  );
}
