import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/dashboard/data/dashboard_recommendations_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/health_activity/domain/weekly_activity_summary.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const noRecommendationCandidates =
    AsyncData<List<DashboardEventRecommendationCandidate>>([]);

DashboardRecommendationsQuery recommendationsQueryFor(
  String uid,
  List<String> followedClubIds,
) => DashboardRecommendationsQuery(
  userId: uid,
  followedClubIds: followedClubIds,
);

AsyncData<WeeklyActivitySnapshot> emptyWeeklyActivitySnapshot() {
  return AsyncData(
    WeeklyActivitySnapshot.permissionRequired(
      referenceDate: DateTime(2026, 5, 13),
      platformLabel: 'Apple Health',
    ),
  );
}

DashboardEventRecommendationCandidate recommendationCandidate(
  Event event, {
  String clubName = 'Stride Social',
  String? clubLocation = 'mumbai',
}) => DashboardEventRecommendationCandidate(
  event: event,
  clubName: clubName,
  clubLocation: clubLocation,
);

ClubMembership membership({required String clubId, String uid = 'runner-1'}) {
  return ClubMembership(
    id: clubMembershipId(clubId: clubId, uid: uid),
    clubId: clubId,
    uid: uid,
    role: ClubMembershipRole.member,
    status: ClubMembershipStatus.active,
    joinedAt: DateTime(2026),
  );
}
