import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_membership.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/core/device_location.dart';
import 'package:catch_dating_app/event_policies/domain/event_policy.dart';
import 'package:catch_dating_app/events/data/event_discovery_repository.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_eligibility.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/saved_event.dart';
import 'package:catch_dating_app/events/domain/viewer_event_availability.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/locations/domain/location_coordinate.dart';
import 'package:catch_dating_app/search/data/explore_search_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EventDiscoveryViewModel {
  const EventDiscoveryViewModel({required this.items});

  final List<EventDiscoveryItem> items;

  bool get isEmpty => items.isEmpty;
  int get count => items.length;
  EventDiscoveryItem? get featuredItem => items.isEmpty ? null : items.first;
  List<EventDiscoveryItem> get railItems => items.skip(1).take(8).toList();

  /// All items except the featured hero, grouped by local-time day in
  /// chronological order. The day buckets are what the Explore feed renders
  /// as sticky sections (`TODAY`, `TOMORROW`, day-of-week + date for further
  /// out).
  List<EventDiscoveryDayGroup> dayGroupsExcludingFeatured({DateTime? now}) {
    final featured = featuredItem;
    final referenceNow = now ?? DateTime.now();
    return _groupByDay(items.where((item) => item != featured), referenceNow);
  }

  /// All items grouped by day, including the featured one. Useful when the
  /// caller doesn't want a separate hero treatment (e.g. the map sheet HALF
  /// state, which shows a uniform feed).
  List<EventDiscoveryDayGroup> dayGroups({DateTime? now}) {
    final referenceNow = now ?? DateTime.now();
    return _groupByDay(items, referenceNow);
  }
}

class EventDiscoveryDayGroup {
  const EventDiscoveryDayGroup({
    required this.day,
    required this.label,
    required this.items,
  });

  /// Midnight of the local day for the events in this group.
  final DateTime day;

  /// Sticky-header label such as `TODAY · WED 27 MAY` or `SAT 30 MAY`.
  final String label;

  final List<EventDiscoveryItem> items;

  int get count => items.length;
}

List<EventDiscoveryDayGroup> _groupByDay(
  Iterable<EventDiscoveryItem> items,
  DateTime now,
) {
  final today = DateTime(now.year, now.month, now.day);
  final tomorrow = today.add(const Duration(days: 1));
  final groups = <DateTime, List<EventDiscoveryItem>>{};
  for (final item in items) {
    final start = item.event.startTime;
    final dayKey = DateTime(start.year, start.month, start.day);
    groups.putIfAbsent(dayKey, () => <EventDiscoveryItem>[]).add(item);
  }

  final keys = groups.keys.toList()..sort();
  return [
    for (final key in keys)
      EventDiscoveryDayGroup(
        day: key,
        label: _labelForDay(key, today, tomorrow),
        items: List.unmodifiable(
          groups[key]!
            ..sort((a, b) => a.event.startTime.compareTo(b.event.startTime)),
        ),
      ),
  ];
}

String _labelForDay(DateTime day, DateTime today, DateTime tomorrow) {
  if (day == today) {
    return 'Today · ${EventFormatters.shortDate(day)}';
  }
  if (day == tomorrow) {
    return 'Tomorrow · ${EventFormatters.shortDate(day)}';
  }
  return EventFormatters.shortDate(day);
}

class EventDiscoveryItem {
  const EventDiscoveryItem({
    required this.event,
    required this.club,
    this.availability,
    EventTileStatus? status,
    this.distanceFromUserKm,
    this.isJoinedClubMember = false,
  }) : _status = status;

  final Event event;
  final Club club;
  final ViewerEventAvailability? availability;

  /// Compatibility override for tests and legacy callers that still construct
  /// Explore items directly. New production paths should pass [availability].
  final EventTileStatus? _status;
  final double? distanceFromUserKm;
  final bool isJoinedClubMember;

  EventTileStatus get status =>
      _status ??
      _statusForAvailability(
        availability,
        isJoinedClubMember: isJoinedClubMember,
      );
  EventTileStatus get tileStatus => status;

  String? get distanceFromUserLabel {
    final distance = distanceFromUserKm;
    if (distance == null) return null;
    if (distance < 1) {
      return '${(distance * 1000).round()} m away';
    }
    final rounded = distance >= 10
        ? distance.round().toString()
        : distance.toStringAsFixed(1);
    return '$rounded km away';
  }

  String get priceLabel {
    final quotedPrice = availability?.quotedPriceInPaise;
    if (quotedPrice == null) return tileData.priceLabel;
    if (quotedPrice <= 0) return 'Free';
    return EventFormatters.priceInPaise(
      quotedPrice,
      currencyCode: event.currency,
    );
  }

  String? get availabilityLabel {
    final viewerAvailability = availability;
    if (viewerAvailability == null) return null;
    return _availabilityLabel(viewerAvailability);
  }

  EventTileData get tileData => EventTileData.fromEvent(
    event: event,
    status: tileStatus,
    clubName: club.name,
  );
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

String? _availabilityLabel(ViewerEventAvailability availability) {
  final lowSpotLabel = _lowSpotLabel(availability.spotsRemaining);
  return switch (availability.status) {
    ViewerEventAvailabilityStatus.open => lowSpotLabel ?? 'Open',
    ViewerEventAvailabilityStatus.saved => lowSpotLabel,
    ViewerEventAvailabilityStatus.hosted => lowSpotLabel,
    ViewerEventAvailabilityStatus.joined ||
    ViewerEventAvailabilityStatus.waitlisted ||
    ViewerEventAvailabilityStatus.attended => null,
    ViewerEventAvailabilityStatus.approvedToBook => 'Approved to join',
    ViewerEventAvailabilityStatus.requestRequired => 'Request required',
    ViewerEventAvailabilityStatus.waitlistAvailable => 'Waitlist open',
    ViewerEventAvailabilityStatus.full => 'Full',
    ViewerEventAvailabilityStatus.fullForViewer => 'Full for you',
    ViewerEventAvailabilityStatus.inviteRequired => 'Invite required',
    ViewerEventAvailabilityStatus.membershipRequired => 'Members only',
    ViewerEventAvailabilityStatus.runPreferencesRequired => 'Set preferences',
    ViewerEventAvailabilityStatus.ageRestricted => _ageRestrictedLabel(
      availability,
    ),
    ViewerEventAvailabilityStatus.past => 'Ended',
    ViewerEventAvailabilityStatus.cancelled => 'Cancelled',
  };
}

String? _lowSpotLabel(int spotsRemaining) {
  if (spotsRemaining <= 0) return null;
  if (spotsRemaining == 1) return '1 spot left';
  if (spotsRemaining <= 4) return '$spotsRemaining spots left';
  return null;
}

String _ageRestrictedLabel(ViewerEventAvailability availability) {
  return switch (availability.eligibility) {
    AgeTooYoung(:final minAge) => 'Must be $minAge+',
    AgeTooOld(:final maxAge) => 'Max age $maxAge',
    _ => 'Age restricted',
  };
}

final eventDiscoveryViewerCohortIdProvider = Provider<AsyncValue<String?>>((
  ref,
) {
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
});

final eventDiscoveryViewModelProvider =
    Provider<AsyncValue<EventDiscoveryViewModel>>((ref) {
      final city = ref.watch(selectedClubCityProvider);
      final query = ref.watch(clubSearchQueryProvider);
      final filters = ref.watch(clubBrowseFiltersProvider);
      final clubsAsync = ref.watch(exploreSourceClubsProvider);
      final uidAsync = ref.watch(uidProvider);
      final now = _discoveryReferenceNow();
      final timeWindow = exploreTimeWindowFor(filters.timeFilter, now);
      final activityKindFilter = _activityKindForFilter(filters.activityTag);
      final distanceFilterKm = exploreDistanceFilterKm(filters.distanceFilter);
      final normalizedQuery = query.trim().toLowerCase();
      final deviceLocationAsync = distanceFilterKm == null
          ? const AsyncData<LocationCoordinate?>(null)
          : ref.watch(deviceLocationProvider);
      final searchAsync = normalizedQuery.isEmpty
          ? const AsyncData<ExploreSearchResult?>(null)
          : ref.watch(
              exploreServerSearchProvider(query: query, cityName: city.name),
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
          : ref.watch(eventDiscoveryViewerCohortIdProvider);
      final userProfileAsync = uid == null
          ? const AsyncData(null)
          : ref.watch(watchUserProfileProvider);
      final membershipsAsync = uid == null
          ? const AsyncData<List<ClubMembership>>([])
          : ref.watch(watchActiveClubMembershipsForUserProvider(uid));
      final participationsAsync = uid == null
          ? const AsyncData<List<EventParticipation>>([])
          : ref.watch(watchEventParticipationsForUserProvider(uid));
      final savedEventEdgesAsync = uid == null
          ? const AsyncData<List<SavedEvent>>([])
          : ref.watch(watchSavedEventsForUserProvider(uid));

      if (userProfileAsync.isLoading ||
          viewerCohortIdAsync.isLoading ||
          membershipsAsync.isLoading ||
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
      if (membershipsAsync.hasError) {
        return AsyncError(
          membershipsAsync.error!,
          membershipsAsync.stackTrace ?? StackTrace.current,
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

      final membershipClubIds =
          membershipsAsync.asData?.value
              .map((membership) => membership.clubId)
              .toSet() ??
          <String>{};
      final hostedClubIds = uid == null
          ? <String>{}
          : sourceClubs
                .where((club) => club.isHostedBy(uid))
                .map((club) => club.id)
                .toSet();
      final userProfile = userProfileAsync.asData?.value;
      final viewerCohortId = viewerCohortIdAsync.asData?.value;

      final eventsAsync = ref.watch(
        discoverableEventsProvider(
          EventDiscoveryQuery.forCity(
            cityName: city.name,
            startAt: timeWindow?.start ?? now,
            endBefore: timeWindow?.end,
            activityKinds: [?activityKindFilter],
            center: deviceLocationAsync.asData?.value,
            maxDistanceKm: distanceFilterKm,
            viewerCohortId: viewerCohortId,
          ),
        ),
      );
      if (eventsAsync.isLoading) return const AsyncLoading();
      if (eventsAsync.hasError) {
        return AsyncError(
          eventsAsync.error!,
          eventsAsync.stackTrace ?? StackTrace.current,
        );
      }

      final eventsById = <String, Event>{
        for (final event in eventsAsync.asData?.value ?? const <Event>[])
          event.id: event,
      };
      final savedEventIds =
          savedEventEdgesAsync.asData?.value
              .map((savedEvent) => savedEvent.eventId)
              .toSet() ??
          <String>{};
      final missingPersonalEventIds = <String>{
        for (final participation
            in participationsAsync.asData?.value ??
                const <EventParticipation>[])
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
              watchEventsByIdsProvider(
                EventsByIdQuery(missingPersonalEventIds),
              ),
            );
      final searchEventsAsync =
          searchResult == null || searchResult.eventIds.isEmpty
          ? const AsyncData<List<Event>>([])
          : ref.watch(
              watchEventsByIdsProvider(EventsByIdQuery(searchResult.eventIds)),
            );
      if (searchEventsAsync.isLoading) return const AsyncLoading();
      if (searchEventsAsync.hasError) {
        return AsyncError(
          searchEventsAsync.error!,
          searchEventsAsync.stackTrace ?? StackTrace.current,
        );
      }

      final participationByEventId = <String, EventParticipation>{
        for (final participation
            in participationsAsync.asData?.value ??
                const <EventParticipation>[])
          participation.eventId: participation,
      };
      for (final event
          in personalEventsAsync.asData?.value ?? const <Event>[]) {
        if (sourceClubIds.contains(event.clubId)) {
          eventsById[event.id] = event;
        }
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
      final items =
          eventsById.values
              .where((event) => event.isUpcomingAt(now))
              .where((event) => _matchesEventTimeFilters(event, filters, now))
              .map((event) {
                final club = clubById[event.clubId];
                if (club == null) return null;
                final isClubMember = membershipClubIds.contains(event.clubId);
                final distanceFromUserKm = _distanceFromUserKm(
                  event: event,
                  deviceLocation: deviceLocation,
                );
                return EventDiscoveryItem(
                  event: event,
                  club: club,
                  availability: resolveViewerEventAvailability(
                    event: event,
                    userProfile: userProfile,
                    participation: participationByEventId[event.id],
                    isSaved: savedEventIds.contains(event.id),
                    isHosted: hostedClubIds.contains(club.id),
                    isClubMember: isClubMember,
                    now: now,
                  ),
                  isJoinedClubMember: isClubMember,
                  distanceFromUserKm: distanceFromUserKm,
                );
              })
              .nonNulls
              .where(
                (item) => _matchesClubScopeFilters(
                  club: item.club,
                  filters: filters,
                  joinedClubIds: {...membershipClubIds, ...hostedClubIds},
                  hostedClubIds: hostedClubIds,
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
              .toList()
            ..sort((a, b) => a.event.startTime.compareTo(b.event.startTime));

      return AsyncData(
        EventDiscoveryViewModel(items: List.unmodifiable(items)),
      );
    });

bool _matchesClubScopeFilters({
  required Club club,
  required ClubBrowseFilterSelection filters,
  required Set<String> joinedClubIds,
  required Set<String> hostedClubIds,
  required ActivityKind? activityKindFilter,
}) {
  if (filters.highRatedOnly && club.rating < 4.5) return false;
  if (filters.joinedOnly && !joinedClubIds.contains(club.id)) return false;
  if (filters.hostedOnly && !hostedClubIds.contains(club.id)) return false;
  final activityTag = filters.activityTag;
  if (activityTag != null &&
      activityKindFilter == null &&
      !club.tags.any((tag) => _sameFilterValue(tag, activityTag))) {
    return false;
  }
  final area = filters.area;
  if (area != null && !_sameFilterValue(club.area, area)) return false;
  return true;
}

bool _matchesEventTimeFilters(
  Event event,
  ClubBrowseFilterSelection filters,
  DateTime now,
) {
  final window = exploreTimeWindowFor(filters.timeFilter, now);
  return window == null || window.contains(event.startTime);
}

bool _matchesDistanceFilter(EventDiscoveryItem item, double? maxKm) {
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

bool _matchesSearch(
  EventDiscoveryItem item,
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
    club.hostName,
    ...club.tags,
  ].join(' ').toLowerCase();
  return searchable.contains(normalizedQuery);
}

bool _sameFilterValue(String? left, String right) {
  return left?.trim().toLowerCase() == right.trim().toLowerCase();
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
