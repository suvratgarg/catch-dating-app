import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'dashboard_recommendations_view_model.g.dart';

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

class DashboardEventRecommendationCandidate {
  const DashboardEventRecommendationCandidate({
    required this.event,
    required this.clubName,
    this.clubLocation,
  });

  final Event event;
  final String clubName;
  final String? clubLocation;
}

/// **Pattern D: View-model provider**
///
/// Keeps dashboard recommendation fetching behind generated Riverpod so this
/// presentation provider follows the same declaration style as the rest of the
/// app.
@riverpod
Future<List<DashboardEventRecommendationCandidate>> dashboardRecommendedEvents(
  Ref ref,
  DashboardRecommendationsQuery query,
) async {
  final events = await ref
      .watch(eventRepositoryProvider)
      .fetchUpcomingEventsForClubs(query.followedClubIds);
  if (events.isEmpty) return const [];

  final clubsRepository = ref.watch(clubsRepositoryProvider);
  final clubIds = events.map((event) => event.clubId).toSet().toList()..sort();
  final clubs = await Future.wait(clubIds.map(clubsRepository.fetchClub));
  final clubsById = <String, Club>{};
  for (final club in clubs) {
    if (club != null) {
      clubsById[club.id] = club;
    }
  }

  return [
    for (final event in events)
      DashboardEventRecommendationCandidate(
        event: event,
        clubName: clubsById[event.clubId]?.name ?? 'Your club',
        clubLocation: clubsById[event.clubId]?.location,
      ),
  ];
}
