import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_recommendations_provider.g.dart';

class DashboardRecommendationsQuery {
  const DashboardRecommendationsQuery({
    required this.userId,
    required this.followedClubIds,
  });

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

/// **Pattern D: View-model provider**
///
/// Keeps dashboard recommendation fetching behind generated Riverpod so this
/// presentation provider follows the same declaration style as the rest of the
/// app.
@riverpod
Future<List<Run>> dashboardRecommendedRuns(
  Ref ref,
  DashboardRecommendationsQuery query,
) {
  return ref
      .watch(runRepositoryProvider)
      .fetchUpcomingRunsForClubs(query.followedClubIds);
}
