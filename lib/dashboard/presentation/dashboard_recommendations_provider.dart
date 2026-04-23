import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

final dashboardRecommendedRunsProvider = FutureProvider.autoDispose
    .family<List<Run>, DashboardRecommendationsQuery>((ref, query) {
      return ref
          .watch(runRepositoryProvider)
          .fetchUpcomingRunsForClubs(query.followedClubIds);
    });
