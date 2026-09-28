import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/explore/data/explore_recommendations_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart' as fixtures;

void main() {
  test('non-distance recommendations ignore legacy run distance and pace', () {
    final now = DateTime(2030);
    final viewer = fixtures.buildUser().copyWith(
      activityPreferences: const ActivityPreferences(
        running: RunningPreferences(
          paceMinSecsPerKm: 400,
          paceMaxSecsPerKm: 440,
          preferredDistances: [PreferredDistance.fiveK],
        ),
      ),
    );
    final dinner = fixtures.buildEvent(
      id: 'dinner',
      startTime: now.add(const Duration(days: 1)),
      eventFormat: const EventFormatSnapshot(
        activityKind: ActivityKind.dinner,
        interactionModel: EventInteractionModel.seatedTable,
      ),
      distanceKm: 0,
    );
    final alternateLegacyValues = dinner.copyWith(
      id: 'other-dinner',
      distanceKm: 5,
      pace: PaceLevel.competitive,
    );
    final run = dinner.copyWith(
      id: 'run',
      eventFormat: const EventFormatSnapshot.socialRun(),
      distanceKm: 5,
    );
    final results = rankExploreEventRecommendations(
      candidates: [
        for (final event in [dinner, alternateLegacyValues, run])
          ExploreEventRecommendationCandidate(event: event, clubName: 'Club'),
      ],
      signedUpEventIds: {},
      attendedEvents: [],
      signedUpEvents: [],
      now: now,
      viewer: viewer,
    );
    final firstDinner = results.singleWhere(
      (item) => item.event.id == 'dinner',
    );
    final otherDinner = results.singleWhere(
      (item) => item.event.id == 'other-dinner',
    );
    expect(firstDinner.score, otherDinner.score);
    expect(firstDinner.reasonLabel, 'From organizers you follow');
    expect(results.first.event.id, 'run');
    expect(results.first.reasonLabel, contains('5'));
  });
}
