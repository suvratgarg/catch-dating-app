import 'package:catch_dating_app/clubs/data/club_name_lookup.dart';
import 'package:catch_dating_app/event_success/event_success_companion_clock.dart';
import 'package:catch_dating_app/explore/data/explore_recommendations_repository.dart';
import 'package:catch_dating_app/public_profile/data/public_profiles_lookup.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('generated provider families preserve override contracts', () async {
    final fixedNow = DateTime.utc(2026, 7, 16, 12);
    final container = ProviderContainer(
      overrides: [
        clubNameLookupProvider(
          ClubNameLookupQuery(const ['club-1']),
        ).overrideWithValue(
          const AsyncData<Map<String, String>>({'club-1': 'Stride Social'}),
        ),
        exploreRecommendedEventsProvider(
          ExploreRecommendationsQuery(
            userId: 'runner-1',
            followedClubIds: const ['club-1'],
          ),
        ).overrideWithValue(
          const AsyncData<List<ExploreEventRecommendationCandidate>>([]),
        ),
        publicProfilesByIdsProvider(
          PublicProfilesQuery(const ['runner-2']),
        ).overrideWithValue(const AsyncData({})),
        eventSuccessCompanionClockProvider.overrideWithValue(
          AsyncData(fixedNow),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(
      container
          .read(
            clubNameLookupProvider(
              ClubNameLookupQuery(const ['club-1', 'club-1']),
            ),
          )
          .requireValue,
      const {'club-1': 'Stride Social'},
    );
    expect(
      container
          .read(
            exploreRecommendedEventsProvider(
              ExploreRecommendationsQuery(
                userId: 'runner-1',
                followedClubIds: const ['club-1'],
              ),
            ),
          )
          .requireValue,
      isEmpty,
    );
    expect(
      container
          .read(
            publicProfilesByIdsProvider(
              PublicProfilesQuery(const ['runner-2', 'runner-2']),
            ),
          )
          .requireValue,
      isEmpty,
    );
    expect(
      container.read(eventSuccessCompanionClockProvider).requireValue,
      fixedNow,
    );
  });
}
