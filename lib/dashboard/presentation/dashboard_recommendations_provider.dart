import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/domain/run_club.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_recommendations_provider.g.dart';

class DashboardRecommendationsQuery {
  DashboardRecommendationsQuery({
    required this.userId,
    required Iterable<String> followedClubIds,
  }) : followedClubIds = List.unmodifiable(
         (followedClubIds.toSet().toList()..sort()),
       );

  final String userId;
  final List<String> followedClubIds;

  @override
  bool operator ==(Object other) {
    return other is DashboardRecommendationsQuery &&
        other.userId == userId &&
        listEquals(other.followedClubIds, followedClubIds);
  }

  @override
  int get hashCode => Object.hash(userId, Object.hashAll(followedClubIds));
}

class DashboardRunRecommendationCandidate {
  const DashboardRunRecommendationCandidate({
    required this.run,
    required this.clubName,
    this.clubLocation,
  });

  final Run run;
  final String clubName;
  final String? clubLocation;
}

/// **Pattern D: View-model provider**
///
/// Keeps dashboard recommendation fetching behind generated Riverpod so this
/// presentation provider follows the same declaration style as the rest of the
/// app.
@riverpod
Future<List<DashboardRunRecommendationCandidate>> dashboardRecommendedRuns(
  Ref ref,
  DashboardRecommendationsQuery query,
) async {
  final runs = await ref
      .watch(runRepositoryProvider)
      .fetchUpcomingRunsForClubs(query.followedClubIds);
  if (runs.isEmpty) return const [];

  final runClubsRepository = ref.watch(runClubsRepositoryProvider);
  final clubIds = runs.map((run) => run.runClubId).toSet().toList()..sort();
  final clubs = await Future.wait(clubIds.map(runClubsRepository.fetchRunClub));
  final clubsById = <String, RunClub>{};
  for (final club in clubs) {
    if (club != null) {
      clubsById[club.id] = club;
    }
  }

  return [
    for (final run in runs)
      DashboardRunRecommendationCandidate(
        run: run,
        clubName: clubsById[run.runClubId]?.name ?? 'Your run club',
        clubLocation: clubsById[run.runClubId]?.location,
      ),
  ];
}
