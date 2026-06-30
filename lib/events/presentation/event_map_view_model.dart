import 'package:catch_dating_app/clubs/data/club_membership_repository.dart';
import 'package:catch_dating_app/clubs/data/club_name_lookup.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/data/saved_event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/widgets/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_map_view_model.g.dart';

class EventMapItem {
  const EventMapItem({
    required this.event,
    required this.status,
    this.clubName,
  });

  final Event event;
  final EventTileStatus status;
  final String? clubName;

  EventTileData get tileData =>
      EventTileData.fromEvent(event: event, status: status, clubName: clubName);
}

class EventMapViewModel {
  const EventMapViewModel({
    required this.events,
    required this.pinnedEvents,
    this.items = const [],
    this.pinnedItems = const [],
  });

  final List<Event> events;
  final List<Event> pinnedEvents;
  final List<EventMapItem> items;
  final List<EventMapItem> pinnedItems;

  bool get isEmpty => events.isEmpty;
  bool get hasPinnedEvents => pinnedEvents.isNotEmpty;
  List<EventMapItem> get effectiveItems => items.isEmpty && events.isNotEmpty
      ? [
          for (final event in events)
            EventMapItem(event: event, status: EventTileStatus.open),
        ]
      : items;
  List<EventMapItem> get effectivePinnedItems =>
      pinnedItems.isEmpty && pinnedEvents.isNotEmpty
      ? [
          for (final event in pinnedEvents)
            EventMapItem(event: event, status: EventTileStatus.open),
        ]
      : pinnedItems;

  Event? selectedEvent(String? eventId) {
    if (eventId == null) return null;
    for (final event in events) {
      if (event.id == eventId) return event;
    }
    return null;
  }

  EventMapItem? selectedItem(String? eventId) {
    if (eventId == null) return null;
    for (final item in effectiveItems) {
      if (item.event.id == eventId) return item;
    }
    return null;
  }
}

EventMapViewModel buildEventMapViewModel({
  required List<Event> signedUpEvents,
  List<Event> savedEvents = const <Event>[],
  required List<Event> recommendedEvents,
  Map<String, String> clubNamesById = const <String, String>{},
  DateTime? now,
}) {
  final effectiveNow = now ?? DateTime.now();
  final byId = <String, EventMapItem>{};

  void addRun(Event event, EventTileStatus status) {
    if (!isUpcomingMapRun(event, effectiveNow)) return;
    byId[event.id] = EventMapItem(
      event: event,
      status: status,
      clubName: clubNamesById[event.clubId],
    );
  }

  for (final event in recommendedEvents) {
    addRun(event, EventTileStatus.recommended);
  }
  for (final event in savedEvents) {
    addRun(event, EventTileStatus.saved);
  }
  for (final event in signedUpEvents) {
    addRun(event, EventTileStatus.joined);
  }

  final items = byId.values.toList()
    ..sort((a, b) => a.event.startTime.compareTo(b.event.startTime));
  final pinnedItems = items
      .where((item) => hasEventMapPin(item.event))
      .toList(growable: false);
  final events = items.map((item) => item.event).toList(growable: false);
  final pinnedEvents = pinnedItems
      .map((item) => item.event)
      .toList(growable: false);

  return EventMapViewModel(
    events: List.unmodifiable(events),
    pinnedEvents: List.unmodifiable(pinnedEvents),
    items: List.unmodifiable(items),
    pinnedItems: List.unmodifiable(pinnedItems),
  );
}

bool hasEventMapPin(Event event) =>
    event.effectiveStartingPointLat != null &&
    event.effectiveStartingPointLng != null;

bool isUpcomingMapRun(Event event, DateTime now) =>
    !event.isCancelled && event.startTime.isAfter(now);

/// Combines the current user's booked events and recommended events for the map.
///
/// The screen owns map selection and tile rendering. This provider owns the
/// feature data seam: profile lookup, event streams, recommendation fetch, merge,
/// de-duplication, chronological sort, and pin filtering.
@riverpod
AsyncValue<EventMapViewModel> eventMapViewModel(Ref ref) {
  final userProfileAsync = ref.watch(watchUserProfileProvider);

  if (userProfileAsync.isLoading) return const AsyncLoading();
  if (userProfileAsync.hasError) {
    return AsyncError(
      userProfileAsync.error!,
      userProfileAsync.stackTrace ?? StackTrace.current,
    );
  }

  final user = userProfileAsync.asData?.value;
  if (user == null) {
    return const AsyncData(
      EventMapViewModel(events: <Event>[], pinnedEvents: <Event>[]),
    );
  }

  final signedUpAsync = ref.watch(watchSignedUpEventsProvider(user.uid));
  final savedAsync = ref.watch(watchSavedEventDetailsForUserProvider(user.uid));
  final membershipsAsync = ref.watch(
    watchActiveClubMembershipsForUserProvider(user.uid),
  );
  final followedClubIds =
      membershipsAsync.asData?.value
          .map((membership) => membership.clubId)
          .toList(growable: false) ??
      const <String>[];
  final recommendedAsync = ref.watch(
    recommendedEventsProvider(
      RecommendedEventsQuery.fromClubIds(followedClubIds),
    ),
  );

  if (signedUpAsync.isLoading ||
      savedAsync.isLoading ||
      membershipsAsync.isLoading ||
      recommendedAsync.isLoading) {
    return const AsyncLoading();
  }
  if (signedUpAsync.hasError) {
    return AsyncError(
      signedUpAsync.error!,
      signedUpAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (savedAsync.hasError) {
    return AsyncError(
      savedAsync.error!,
      savedAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (membershipsAsync.hasError) {
    return AsyncError(
      membershipsAsync.error!,
      membershipsAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (recommendedAsync.hasError) {
    return AsyncError(
      recommendedAsync.error!,
      recommendedAsync.stackTrace ?? StackTrace.current,
    );
  }

  final allEvents = <Event>[
    ...?signedUpAsync.asData?.value,
    ...?savedAsync.asData?.value,
    ...?recommendedAsync.asData?.value,
  ];
  final clubNamesAsync = ref.watch(
    clubNameLookupProvider(
      ClubNameLookupQuery(allEvents.map((event) => event.clubId)),
    ),
  );
  if (clubNamesAsync.isLoading) return const AsyncLoading();
  if (clubNamesAsync.hasError) {
    return AsyncError(
      clubNamesAsync.error!,
      clubNamesAsync.stackTrace ?? StackTrace.current,
    );
  }

  return AsyncData(
    buildEventMapViewModel(
      signedUpEvents: signedUpAsync.asData?.value ?? const <Event>[],
      savedEvents: savedAsync.asData?.value ?? const <Event>[],
      recommendedEvents: recommendedAsync.asData?.value ?? const <Event>[],
      clubNamesById: clubNamesAsync.asData?.value ?? const <String, String>{},
    ),
  );
}
