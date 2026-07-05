import 'package:catch_dating_app/explore/data/explore_recommendations_repository.dart';

@Deprecated('Use ExploreRecommendationsQuery from explore recommendations.')
typedef DashboardRecommendationsQuery = ExploreRecommendationsQuery;

@Deprecated(
  'Use ExploreEventRecommendationCandidate from explore recommendations.',
)
typedef DashboardEventRecommendationCandidate =
    ExploreEventRecommendationCandidate;

@Deprecated('Use exploreRecommendedEventsProvider.')
final dashboardRecommendedEventsProvider = exploreRecommendedEventsProvider;
