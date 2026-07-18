import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/data/event_discovery_repository.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/external_event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/external_event.dart';
import 'package:catch_dating_app/events/domain/saved_event.dart';
import 'package:catch_dating_app/events/domain/viewer_event_availability.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/explore/data/explore_recommendations_repository.dart';
import 'package:catch_dating_app/explore/data/explore_search_repository.dart';
import 'package:catch_dating_app/explore/domain/explore_event_recommendation.dart';
import 'package:catch_dating_app/explore/presentation/explore_discovery_window_controller.dart';
import 'package:catch_dating_app/explore/presentation/explore_filter_logic.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'explore_feed_view_model.g.dart';

/// Shared wall-clock snapshot for one mounted Explore surface.
///
/// Keeping the query window and date-strip labels on the same provider avoids
/// midnight drift and gives capture/tests one explicit deterministic seam.
@riverpod
DateTime exploreDiscoveryReferenceNow(Ref ref) => _discoveryReferenceNow();

class ExploreFeedViewModel {
  const ExploreFeedViewModel({
    required this.items,
    this.externalItems = const <ExploreExternalEventItem>[],
    this.dateSupplyCounts = const <ExploreTimeFilter, int>{},
    this.isExhaustive = true,
    this.isLoadingMore = false,
    this.windowRequest,
  });

  final List<ExploreEventItem> items;
  final List<ExploreExternalEventItem> externalItems;
  final Map<ExploreTimeFilter, int> dateSupplyCounts;
  final bool isExhaustive;
  final bool isLoadingMore;
  final ExploreDiscoveryWindowRequest? windowRequest;

  bool get isEmpty => items.isEmpty && externalItems.isEmpty;
  int get count => items.length + externalItems.length;
  int get mappableEventCount =>
      items.where((item) => item.event.hasExactStartingPoint).length +
      externalItems
          .where(
            (item) =>
                item.event.latitude != null && item.event.longitude != null,
          )
          .length;
  bool get hasMore => !isExhaustive;
  int? dateSupplyCount(ExploreTimeFilter filter) => dateSupplyCounts[filter];
  ExploreEventItem? get featuredItem => items.isEmpty ? null : items.first;
  List<ExploreEventItem> get railItems => items.skip(1).take(8).toList();

  /// All items except the featured hero, grouped by local-time day in
  /// chronological order. The day buckets are what the Explore feed renders
  /// as sticky sections (`TODAY`, `TOMORROW`, day-of-week + date for further
  /// out).
  List<ExploreEventDayGroup> dayGroupsExcludingFeatured({DateTime? now}) {
    final featured = featuredItem;
    final referenceNow = now ?? DateTime.now();
    return _groupByDay(items.where((item) => item != featured), referenceNow);
  }

  /// All items grouped by day, including the featured one. Useful when the
  /// caller doesn't want a separate hero treatment (e.g. the map sheet HALF
  /// state, which shows a uniform feed).
  List<ExploreEventDayGroup> dayGroups({DateTime? now}) {
    final referenceNow = now ?? DateTime.now();
    return _groupByDay(items, referenceNow);
  }
}

class ExploreEventDayGroup {
  const ExploreEventDayGroup({
    required this.day,
    required this.label,
    required this.items,
  });

  /// Midnight of the local day for the events in this group.
  final DateTime day;

  /// Sticky-header label such as `TODAY · WED 27 MAY` or `SAT 30 MAY`.
  final String label;

  final List<ExploreEventItem> items;

  int get count => items.length;
}

List<ExploreEventDayGroup> _groupByDay(
  Iterable<ExploreEventItem> items,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final groups = <DateTime, List<ExploreEventItem>>{};
  for (final item in items) {
    final start = item.event.startTime;
    final dayKey = DateTime(start.year, start.month, start.day);
    groups.putIfAbsent(dayKey, () => <ExploreEventItem>[]).add(item);
  }

  final keys = groups.keys.toList()..sort();
  return [
    for (final key in keys)
      ExploreEventDayGroup(
        day: key,
        label: exploreFeedDayLabel(key, today: today, tomorrow: tomorrow),
        items: List.unmodifiable(
          groups[key]!
            ..sort((a, b) => a.event.startTime.compareTo(b.event.startTime)),
        ),
      ),
  ];
}

String exploreFeedDayLabel(
  DateTime day, {
  required DateTime today,
  required DateTime tomorrow,
}) {
  if (day == today) {
    return 'Today · ${EventFormatters.shortDate(day)}';
  }
  if (day == tomorrow) {
    return 'Tomorrow · ${EventFormatters.shortDate(day)}';
  }
  return EventFormatters.shortDate(day);
}

class ExploreEventItem {
  const ExploreEventItem({
    required this.event,
    required this.club,
    this.availability,
    this._status,
    this.distanceFromUserKm,
    this.isJoinedClubMember = false,
    this.isFollowedClubSignal = false,
  });

  final Event event;
  final Club club;
  final ViewerEventAvailability? availability;

  /// Compatibility override for tests and legacy callers that still construct
  /// Explore items directly. New production paths should pass [availability].
  final EventTileStatus? _status;
  final double? distanceFromUserKm;
  final bool isJoinedClubMember;
  final bool isFollowedClubSignal;

  EventTileStatus get status =>
      _status ??
      _statusForAvailability(
        availability,
        isJoinedClubMember: isJoinedClubMember,
      );
  EventTileStatus get tileStatus => status;

  EventTileData get tileData => EventTileData.fromEvent(
    event: event,
    status: tileStatus,
    clubName: club.name,
  );
}

class ExploreExternalEventItem {
  const ExploreExternalEventItem({
    required this.event,
    this.distanceFromUserKm,
  });

  final ExternalEvent event;
  final double? distanceFromUserKm;
}

EventTileStatus _statusForAvailability(
  ViewerEventAvailability? availability, {
  required bool isJoinedClubMember,
}) {
  return switch (availability?.status) {
    ViewerEventAvailabilityStatus.joined => EventTileStatus.joined,
    ViewerEventAvailabilityStatus.saved => EventTileStatus.saved,
    ViewerEventAvailabilityStatus.hosted => EventTileStatus.hosted,
    ViewerEventAvailabilityStatus.waitlisted => EventTileStatus.waitlisted,
    ViewerEventAvailabilityStatus.attended => EventTileStatus.attended,
    ViewerEventAvailabilityStatus.waitlistAvailable ||
    ViewerEventAvailabilityStatus.full => EventTileStatus.full,
    ViewerEventAvailabilityStatus.fullForViewer ||
    ViewerEventAvailabilityStatus.inviteRequired ||
    ViewerEventAvailabilityStatus.membershipRequired ||
    ViewerEventAvailabilityStatus.ageRestricted => EventTileStatus.ineligible,
    ViewerEventAvailabilityStatus.past => EventTileStatus.past,
    ViewerEventAvailabilityStatus.cancelled => EventTileStatus.cancelled,
    ViewerEventAvailabilityStatus.approvedToBook ||
    ViewerEventAvailabilityStatus.requestRequired ||
    ViewerEventAvailabilityStatus.runPreferencesRequired ||
    ViewerEventAvailabilityStatus.open ||
    null =>
      isJoinedClubMember ? EventTileStatus.recommended : EventTileStatus.open,
  };
}

@riverpod
AsyncValue<String?> exploreViewerCohortId(Ref ref) {
  final uidAsync = ref.watch(uidProvider);
  if (uidAsync.isLoading) return const AsyncLoading();
  if (uidAsync.hasError) {
    return AsyncError(
      uidAsync.error!,
      uidAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (uidAsync.asData?.value == null) return const AsyncData(null);

  final userProfileAsync = ref.watch(watchUserProfileProvider);
  if (userProfileAsync.isLoading) return const AsyncLoading();
  if (userProfileAsync.hasError) {
    return AsyncError(
      userProfileAsync.error!,
      userProfileAsync.stackTrace ?? StackTrace.current,
    );
  }
  final userProfile = userProfileAsync.asData?.value;
  if (userProfile == null) return const AsyncData(null);
  final cohortId = const EventCohortResolver()
      .resolve(EventAttendeeProfile.fromUserProfile(userProfile))
      .id;
  return AsyncData(cohortId);
}

@riverpod
AsyncValue<ExploreFeedViewModel> exploreFeedViewModel(Ref ref) {
  final city = ref.watch(selectedExploreCityProvider);
  final query = ref.watch(exploreSearchQueryProvider);
  final filters = ref.watch(exploreFiltersProvider);
  final clubsAsync = ref.watch(exploreSourceClubsProvider);
  final uidAsync = ref.watch(uidProvider);
  final now = ref.watch(exploreDiscoveryReferenceNowProvider);
  final selectedTimeWindow = exploreTimeWindowFor(filters.timeFilter, now);
  final queryTimeWindow =
      isExploreDateStripFilter(filters.timeFilter) &&
          filters.timeFilter != ExploreTimeFilter.anytime
      ? exploreDateStripQueryWindow(now)
      : selectedTimeWindow;
  final activityKindFilter = _activityKindForFilter(filters.activityTag);
  final distanceFilterKm = exploreDistanceFilterKm(filters.distanceFilter);
  final normalizedQuery = query.trim().toLowerCase();
  final deviceLocationAsync = distanceFilterKm == null
      ? const AsyncData<LocationCoordinate?>(null)
      : ref.watch(deviceLocationProvider);
  // Server search keys off the debounced query so typing doesn't fire a
  // Cloud Function call per keystroke. Local substring matching below uses
  // the live `normalizedQuery`, so the feed stays responsive while it settles.
  final debouncedQuery =
      ref.watch(debouncedExploreSearchQueryProvider).asData?.value ?? '';
  final searchAsync = debouncedQuery.length < 2
      ? const AsyncData<ExploreSearchResult?>(null)
      : ref.watch(
          exploreServerSearchProvider(
            query: debouncedQuery,
            cityName: city.effectiveMarketId,
          ),
        );

  if (clubsAsync.isLoading ||
      uidAsync.isLoading ||
      deviceLocationAsync.isLoading) {
    return const AsyncLoading();
  }
  if (clubsAsync.hasError) {
    return AsyncError(
      clubsAsync.error!,
      clubsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (uidAsync.hasError) {
    return AsyncError(
      uidAsync.error!,
      uidAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (deviceLocationAsync.hasError) {
    return AsyncError(
      deviceLocationAsync.error!,
      deviceLocationAsync.stackTrace ?? StackTrace.current,
    );
  }

  final sourceClubs = clubsAsync.asData?.value ?? const <Club>[];
  final sourceClubIds = sourceClubs.map((club) => club.id).toSet();
  final searchResult = searchAsync.asData?.value;
  final serverEventIds = searchResult?.eventIds.toSet();
  final serverClubIds = searchResult?.clubIds.toSet();

  final uid = uidAsync.asData?.value;
  final viewerCohortIdAsync = uid == null
      ? const AsyncData<String?>(null)
      : ref.watch(exploreViewerCohortIdProvider);
  final userProfileAsync = uid == null
      ? const AsyncData(null)
      : ref.watch(watchUserProfileProvider);
  final followedClubIdsAsync = ref.watch(currentUserFollowedClubIdsProvider);
  final participationsAsync = uid == null
      ? const AsyncData<List<EventParticipation>>([])
      : ref.watch(watchEventParticipationsForUserProvider(uid));
  final savedEventEdgesAsync = uid == null
      ? const AsyncData<List<SavedEvent>>([])
      : ref.watch(watchSavedEventsForUserProvider(uid));

  if (userProfileAsync.isLoading ||
      viewerCohortIdAsync.isLoading ||
      followedClubIdsAsync.isLoading ||
      participationsAsync.isLoading ||
      savedEventEdgesAsync.isLoading) {
    return const AsyncLoading();
  }
  if (viewerCohortIdAsync.hasError) {
    return AsyncError(
      viewerCohortIdAsync.error!,
      viewerCohortIdAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (userProfileAsync.hasError) {
    return AsyncError(
      userProfileAsync.error!,
      userProfileAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (followedClubIdsAsync.hasError) {
    return AsyncError(
      followedClubIdsAsync.error!,
      followedClubIdsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (participationsAsync.hasError) {
    return AsyncError(
      participationsAsync.error!,
      participationsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (savedEventEdgesAsync.hasError) {
    return AsyncError(
      savedEventEdgesAsync.error!,
      savedEventEdgesAsync.stackTrace ?? StackTrace.current,
    );
  }

  final followedClubIds = followedClubIdsAsync.asData?.value ?? <String>{};
  final membershipClubIds = followedClubIds;
  final userProfile = userProfileAsync.asData?.value;
  final viewerCohortId = viewerCohortIdAsync.asData?.value;

  final windowRequest = ExploreDiscoveryWindowRequest(
    internalQuery: EventDiscoveryQuery.forCity(
      marketId: city.effectiveMarketId,
      startAt: queryTimeWindow?.start ?? now,
      endBefore: queryTimeWindow?.end,
      activityKinds: [?activityKindFilter],
      center: deviceLocationAsync.asData?.value,
      maxDistanceKm: distanceFilterKm,
      viewerCohortId: viewerCohortId,
    ),
    externalQuery: ExternalEventDiscoveryQuery.forCity(
      citySlug: city.effectiveSlug,
      startAt: queryTimeWindow?.start ?? now,
      endBefore: queryTimeWindow?.end,
      activityKinds: [?activityKindFilter],
    ),
  );
  final discoveryWindowAsync = ref.watch(
    exploreDiscoveryWindowProvider(windowRequest),
  );
  if (discoveryWindowAsync.isLoading) {
    return const AsyncLoading();
  }
  if (discoveryWindowAsync.hasError) {
    return AsyncError(
      discoveryWindowAsync.error!,
      discoveryWindowAsync.stackTrace ?? StackTrace.current,
    );
  }
  final discoveryWindow = discoveryWindowAsync.requireValue;

  final eventsById = <String, Event>{
    for (final event in discoveryWindow.internalEvents) event.id: event,
  };
  final followedRecommendationsAsync = uid == null || followedClubIds.isEmpty
      ? const AsyncData<List<ExploreEventRecommendationCandidate>>([])
      : ref.watch(
          exploreRecommendedEventsProvider(
            ExploreRecommendationsQuery(
              userId: uid,
              followedClubIds: followedClubIds,
            ),
          ),
        );
  if (followedRecommendationsAsync.isLoading) return const AsyncLoading();
  if (followedRecommendationsAsync.hasError) {
    return AsyncError(
      followedRecommendationsAsync.error!,
      followedRecommendationsAsync.stackTrace ?? StackTrace.current,
    );
  }
  final savedEventIds =
      savedEventEdgesAsync.asData?.value
          .map((savedEvent) => savedEvent.eventId)
          .toSet() ??
      <String>{};
  final missingPersonalEventIds = <String>{
    for (final participation
        in participationsAsync.asData?.value ?? const <EventParticipation>[])
      if (participation.status == EventParticipationStatus.signedUp &&
          sourceClubIds.contains(participation.clubId) &&
          !eventsById.containsKey(participation.eventId))
        participation.eventId,
    for (final eventId in savedEventIds)
      if (!eventsById.containsKey(eventId)) eventId,
  };
  final personalEventsAsync = uid == null || missingPersonalEventIds.isEmpty
      ? const AsyncData<List<Event>>([])
      : ref.watch(
          watchEventsByIdsProvider(EventsByIdQuery(missingPersonalEventIds)),
        );
  final searchEventsAsync =
      searchResult == null || searchResult.eventIds.isEmpty
      ? const AsyncData<List<Event>>([])
      : ref.watch(
          watchEventsByIdsProvider(EventsByIdQuery(searchResult.eventIds)),
        );
  // Personal event enrichment (out-of-city joined/saved events) is
  // intentionally non-blocking: the feed renders immediately from in-city
  // discovery and personal events stream in progressively, degrading
  // gracefully if that secondary query is slow or fails. Search results, by
  // contrast, are the primary content and must block/surface errors.
  if (searchEventsAsync.isLoading) return const AsyncLoading();
  if (searchEventsAsync.hasError) {
    return AsyncError(
      searchEventsAsync.error!,
      searchEventsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final participationByEventId = <String, EventParticipation>{
    for (final participation
        in participationsAsync.asData?.value ?? const <EventParticipation>[])
      participation.eventId: participation,
  };
  for (final event in personalEventsAsync.asData?.value ?? const <Event>[]) {
    if (sourceClubIds.contains(event.clubId)) {
      eventsById[event.id] = event;
    }
  }
  for (final candidate
      in followedRecommendationsAsync.asData?.value ??
          const <ExploreEventRecommendationCandidate>[]) {
    eventsById.putIfAbsent(candidate.event.id, () => candidate.event);
  }
  for (final event in searchEventsAsync.asData?.value ?? const <Event>[]) {
    eventsById[event.id] = event;
  }
  final extraClubIds = <String>{
    for (final clubId in serverClubIds ?? const <String>{})
      if (!sourceClubIds.contains(clubId)) clubId,
    for (final event in eventsById.values)
      if (!sourceClubIds.contains(event.clubId)) event.clubId,
  };
  final extraClubsAsync = extraClubIds.isEmpty
      ? const AsyncData<List<Club>>([])
      : ref.watch(watchClubsByIdsProvider(ClubsByIdQuery(extraClubIds)));
  if (extraClubsAsync.isLoading) return const AsyncLoading();
  if (extraClubsAsync.hasError) {
    return AsyncError(
      extraClubsAsync.error!,
      extraClubsAsync.stackTrace ?? StackTrace.current,
    );
  }
  final clubById = {
    for (final club in sourceClubs) club.id: club,
    for (final club in extraClubsAsync.asData?.value ?? const <Club>[])
      club.id: club,
  };
  final deviceLocation = deviceLocationAsync.asData?.value;
  final allItems = eventsById.values
      .where((event) => event.isUpcomingAt(now))
      .map((event) {
        final club = clubById[event.clubId];
        if (club == null) return null;
        final isClubMember = membershipClubIds.contains(event.clubId);
        final distanceFromUserKm = _distanceFromUserKm(
          event: event,
          deviceLocation: deviceLocation,
        );
        return ExploreEventItem(
          event: event,
          club: club,
          availability: resolveViewerEventAvailability(
            event: event,
            userProfile: userProfile,
            participation: participationByEventId[event.id],
            isSaved: savedEventIds.contains(event.id),
            isClubMember: isClubMember,
            now: now,
          ),
          isJoinedClubMember: isClubMember,
          isFollowedClubSignal: followedClubIds.contains(event.clubId),
          distanceFromUserKm: distanceFromUserKm,
        );
      })
      .nonNulls
      .where(
        (item) => _matchesClubScopeFilters(
          club: item.club,
          filters: filters,
          joinedClubIds: membershipClubIds,
          activityKindFilter: activityKindFilter,
        ),
      )
      .where((item) => _matchesDistanceFilter(item, distanceFilterKm))
      .where(
        (item) => _matchesSearch(
          item,
          normalizedQuery,
          serverEventIds: serverEventIds,
          serverClubIds: serverClubIds,
        ),
      )
      .toList();
  final items =
      allItems
          .where((item) => _matchesEventTimeFilters(item.event, filters, now))
          .toList()
        ..sort((a, b) => a.event.startTime.compareTo(b.event.startTime));
  final allExternalItems = discoveryWindow.externalEvents
      .where((event) => event.isUpcomingAt(now))
      .map((event) {
        return ExploreExternalEventItem(
          event: event,
          distanceFromUserKm: _externalDistanceFromUserKm(
            event: event,
            deviceLocation: deviceLocation,
          ),
        );
      })
      .where((item) => _matchesExternalDistanceFilter(item, distanceFilterKm))
      .where((item) => _matchesExternalSearch(item, normalizedQuery))
      .toList();
  final externalItems =
      allExternalItems
          .where(
            (item) =>
                _matchesExternalEventTimeFilters(item.event, filters, now),
          )
          .toList()
        ..sort((a, b) => a.event.startTime.compareTo(b.event.startTime));
  final dateSupplyCounts = _exploreDateSupplyCounts(
    internalItems: allItems,
    externalItems: allExternalItems,
    now: now,
  );

  return AsyncData(
    ExploreFeedViewModel(
      items: List.unmodifiable(items),
      externalItems: List.unmodifiable(externalItems),
      dateSupplyCounts: dateSupplyCounts,
      isExhaustive: discoveryWindow.isExhaustive,
      isLoadingMore: discoveryWindow.isLoadingMore,
      windowRequest: windowRequest,
    ),
  );
}

Map<ExploreTimeFilter, int> _exploreDateSupplyCounts({
  required List<ExploreEventItem> internalItems,
  required List<ExploreExternalEventItem> externalItems,
  required DateTime now,
}) {
  final starts = <DateTime>[
    for (final item in internalItems) item.event.startTime,
    for (final item in externalItems) item.event.startTime,
  ];
  return Map.unmodifiable({
    for (final filter in displayedExploreDateFilters)
      filter: filter == ExploreTimeFilter.anytime
          ? starts.length
          : starts
                .where(
                  (start) => exploreTimeWindowFor(filter, now)!.contains(start),
                )
                .length,
  });
}

@riverpod
AsyncValue<List<ExploreEventRecommendation>> exploreRecommendations(Ref ref) {
  final uidAsync = ref.watch(uidProvider);
  final followedClubIdsAsync = ref.watch(currentUserFollowedClubIdsProvider);
  if (uidAsync.isLoading || followedClubIdsAsync.isLoading) {
    return const AsyncLoading();
  }
  if (uidAsync.hasError) {
    return AsyncError(
      uidAsync.error!,
      uidAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (followedClubIdsAsync.hasError) {
    return AsyncError(
      followedClubIdsAsync.error!,
      followedClubIdsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final uid = uidAsync.asData?.value;
  final followedClubIds = followedClubIdsAsync.asData?.value ?? <String>{};
  if (uid == null || followedClubIds.isEmpty) {
    return const AsyncData(<ExploreEventRecommendation>[]);
  }

  final userAsync = ref.watch(watchUserProfileProvider);
  final signedUpEventsAsync = ref.watch(watchSignedUpEventsProvider(uid));
  final attendedEventsAsync = ref.watch(watchAttendedEventsProvider(uid));
  final candidatesAsync = ref.watch(
    exploreRecommendedEventsProvider(
      ExploreRecommendationsQuery(
        userId: uid,
        followedClubIds: followedClubIds,
      ),
    ),
  );
  if (userAsync.isLoading ||
      signedUpEventsAsync.isLoading ||
      attendedEventsAsync.isLoading ||
      candidatesAsync.isLoading) {
    return const AsyncLoading();
  }
  if (userAsync.hasError) {
    return AsyncError(
      userAsync.error!,
      userAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (signedUpEventsAsync.hasError) {
    return AsyncError(
      signedUpEventsAsync.error!,
      signedUpEventsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (attendedEventsAsync.hasError) {
    return AsyncError(
      attendedEventsAsync.error!,
      attendedEventsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (candidatesAsync.hasError) {
    return AsyncError(
      candidatesAsync.error!,
      candidatesAsync.stackTrace ?? StackTrace.current,
    );
  }

  final signedUpEvents = signedUpEventsAsync.asData?.value ?? const <Event>[];
  return AsyncData(
    rankExploreEventRecommendations(
      candidates:
          candidatesAsync.asData?.value ??
          const <ExploreEventRecommendationCandidate>[],
      signedUpEventIds: signedUpEvents.map((event) => event.id).toSet(),
      attendedEvents: attendedEventsAsync.asData?.value ?? const <Event>[],
      signedUpEvents: signedUpEvents,
      viewer: userAsync.asData?.value,
      now: ref.watch(exploreDiscoveryReferenceNowProvider),
    ),
  );
}

bool _matchesClubScopeFilters({
  required Club club,
  required ExploreFilterSelection filters,
  required Set<String> joinedClubIds,
  required ActivityKind? activityKindFilter,
}) {
  // When the selected tag resolves to a concrete ActivityKind the events query
  // already filtered on it, so the club need not also carry the tag as text.
  return clubMatchesScopeFilters(
    club: club,
    filters: filters,
    joinedClubIds: joinedClubIds,
    activityHandledByEventFilter: activityKindFilter != null,
  );
}

bool _matchesEventTimeFilters(
  Event event,
  ExploreFilterSelection filters,
  DateTime now,
) {
  final window = exploreTimeWindowFor(filters.timeFilter, now);
  return window == null || window.contains(event.startTime);
}

bool _matchesExternalEventTimeFilters(
  ExternalEvent event,
  ExploreFilterSelection filters,
  DateTime now,
) {
  final window = exploreTimeWindowFor(filters.timeFilter, now);
  return window == null || window.contains(event.startTime);
}

bool _matchesDistanceFilter(ExploreEventItem item, double? maxKm) {
  if (maxKm == null) return true;
  final distance = item.distanceFromUserKm;
  return distance != null && distance <= maxKm;
}

bool _matchesExternalDistanceFilter(
  ExploreExternalEventItem item,
  double? maxKm,
) {
  if (maxKm == null) return true;
  final distance = item.distanceFromUserKm;
  return distance != null && distance <= maxKm;
}

double? _distanceFromUserKm({
  required Event event,
  required LocationCoordinate? deviceLocation,
}) {
  if (deviceLocation == null) return null;
  final eventLocation = LocationCoordinate.fromNullable(
    latitude: event.effectiveStartingPointLat,
    longitude: event.effectiveStartingPointLng,
  );
  if (eventLocation == null) return null;
  return deviceLocation.distanceTo(eventLocation) / 1000;
}

double? _externalDistanceFromUserKm({
  required ExternalEvent event,
  required LocationCoordinate? deviceLocation,
}) {
  if (deviceLocation == null) return null;
  final eventLocation = LocationCoordinate.fromNullable(
    latitude: event.latitude,
    longitude: event.longitude,
  );
  if (eventLocation == null) return null;
  return deviceLocation.distanceTo(eventLocation) / 1000;
}

bool _matchesSearch(
  ExploreEventItem item,
  String normalizedQuery, {
  Set<String>? serverEventIds,
  Set<String>? serverClubIds,
}) {
  if (normalizedQuery.isEmpty) return true;
  if (serverEventIds != null || serverClubIds != null) {
    return (serverEventIds?.contains(item.event.id) ?? false) ||
        (serverClubIds?.contains(item.club.id) ?? false);
  }
  final event = item.event;
  final club = item.club;
  final searchable = [
    event.title,
    event.locationName,
    event.description,
    event.eventFormat.label,
    event.pace.label,
    club.name,
    club.area,
    club.displayHostName,
    ...club.tags,
  ].join(' ').toLowerCase();
  return searchable.contains(normalizedQuery);
}

bool _matchesExternalSearch(
  ExploreExternalEventItem item,
  String normalizedQuery,
) {
  if (normalizedQuery.isEmpty) return true;
  final event = item.event;
  final searchable = [
    event.title,
    event.description,
    event.meetingPoint,
    event.locationDetails,
    event.activityKind.label,
    event.platformLabel,
  ].whereType<String>().join(' ').toLowerCase();
  return searchable.contains(normalizedQuery);
}

DateTime _discoveryReferenceNow() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day, now.hour, now.minute);
}

ActivityKind? _activityKindForFilter(String? value) {
  final normalized = value?.trim().toLowerCase();
  if (normalized == null || normalized.isEmpty) return null;
  for (final kind in ActivityKind.values) {
    if (kind.name.toLowerCase() == normalized ||
        kind.label.toLowerCase() == normalized) {
      return kind;
    }
  }
  return null;
}
