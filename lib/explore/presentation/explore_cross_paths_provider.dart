import 'dart:math';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/cross_paths/cross_paths.dart';
import 'package:catch_dating_app/events/domain/viewer_event_availability.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explore_cross_paths_provider.g.dart';

const int maximumCrossPathsExploreSuggestions = 2;
const int maximumCrossPathsExploreEventIds = 12;

/// One opaque identifier for the lifetime of a mounted Explore session.
///
/// It intentionally auto-disposes with the Explore enrichment graph. The
/// server hashes this value before storage and enforces the two-person cap.
@riverpod
String crossPathsExploreSessionId(Ref ref) {
  final random = Random.secure();
  return 'xp_${DateTime.now().microsecondsSinceEpoch.toRadixString(36)}_'
      '${random.nextInt(1 << 31).toRadixString(36)}_'
      '${random.nextInt(1 << 31).toRadixString(36)}';
}

/// Optional, failure-isolated enrichment for the default Explore list.
///
/// The primary event feed never waits on this provider. Signed-out viewers,
/// active search, disabled rollout configuration, and an unavailable event
/// set all resolve to an empty list without invoking the callable.
@riverpod
Future<List<CrossPathsSuggestion>> exploreCrossPathsSuggestions(Ref ref) async {
  final config = ref.watch(crossPathsFeatureConfigProvider);
  if (!config.exploreSuggestionsEnabled) return const [];

  final uidAsync = ref.watch(uidProvider);
  final uid = uidAsync.asData?.value;
  if (uid == null) return const [];

  final query = ref.watch(exploreSearchQueryProvider).trim();
  if (query.isNotEmpty) return const [];

  final feed = ref.watch(exploreFeedViewModelProvider).asData?.value;
  if (feed == null || feed.items.isEmpty) return const [];

  final eventIds = <String>[
    for (final item in feed.items)
      if (item.availability?.canBookNow == true ||
          item.availability?.status == ViewerEventAvailabilityStatus.joined)
        item.event.id,
  ].take(maximumCrossPathsExploreEventIds).toList(growable: false);
  if (eventIds.isEmpty) return const [];

  final response = await ref
      .watch(crossPathsRepositoryProvider)
      .getSuggestions(
        eventIds: eventIds,
        sessionId: ref.watch(crossPathsExploreSessionIdProvider),
      );
  final eventIdSet = eventIds.toSet();
  return List.unmodifiable(
    response.suggestions
        .where((suggestion) => eventIdSet.contains(suggestion.event.eventId))
        .take(maximumCrossPathsExploreSuggestions),
  );
}
