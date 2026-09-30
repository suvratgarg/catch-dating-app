import 'package:catch_dating_app/core/data/cursor_page.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/data/private_event_setup_repository.dart';
import 'package:catch_dating_app/hosts/presentation/event_management/private_event_setup_capability.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_events_timeline_controller.g.dart';

@immutable
class HostEventsTimelineRequest {
  const HostEventsTimelineRequest({
    required this.organizerId,
    required this.sessionBoundary,
  });

  final String organizerId;
  final DateTime sessionBoundary;

  @override
  bool operator ==(Object other) =>
      other is HostEventsTimelineRequest &&
      other.organizerId == organizerId &&
      other.sessionBoundary == sessionBoundary;

  @override
  int get hashCode => Object.hash(organizerId, sessionBoundary);
}

@immutable
class HostEventsTimelineData {
  const HostEventsTimelineData({
    required this.activeEvents,
    required this.pastEvents,
    required this.activeCursor,
    required this.pastCursor,
    required this.hasMoreActive,
    required this.hasMorePast,
    this.unpublishedUpcoming = const <PrivateEventSetupInventoryItem>[],
    this.unpublishedHistory = const <PrivateEventSetupInventoryItem>[],
    this.cancelledEvents = const <Event>[],
    this.cancelledCursor,
    this.hasMoreCancelled = false,
    this.loadingMoreActive = false,
    this.loadingMorePast = false,
    this.activeLoadMoreError,
    this.pastError,
    this.pastStackTrace,
  });

  final List<Event> activeEvents;
  final List<Event> pastEvents;

  /// Organizer-only events still in setup (`publicationState: 'private'`).
  /// They share the `events` collection and this timeline; the light
  /// inventory projection is used because setup drafts may not yet carry
  /// the fields the rich Event model requires.
  final List<PrivateEventSetupInventoryItem> unpublishedUpcoming;
  final List<PrivateEventSetupInventoryItem> unpublishedHistory;
  final List<Event> cancelledEvents;
  final DocumentSnapshot<Event>? activeCursor;
  final DocumentSnapshot<Event>? pastCursor;
  final DocumentSnapshot<Event>? cancelledCursor;
  final bool hasMoreActive;
  final bool hasMorePast;
  final bool hasMoreCancelled;
  final bool loadingMoreActive;
  final bool loadingMorePast;
  final Object? activeLoadMoreError;
  final Object? pastError;
  final StackTrace? pastStackTrace;

  List<Event> get allEvents {
    final byId = <String, Event>{
      for (final event in pastEvents) event.id: event,
      for (final event in activeEvents) event.id: event,
    };
    return List.unmodifiable(byId.values);
  }

  bool get canLoadMoreActive => hasMoreActive && !loadingMoreActive;
  bool get canLoadMorePast =>
      (hasMorePast || hasMoreCancelled) && !loadingMorePast;

  HostEventsTimelineData copyWith({
    List<Event>? activeEvents,
    List<Event>? pastEvents,
    List<PrivateEventSetupInventoryItem>? unpublishedUpcoming,
    List<PrivateEventSetupInventoryItem>? unpublishedHistory,
    List<Event>? cancelledEvents,
    DocumentSnapshot<Event>? activeCursor,
    bool clearActiveCursor = false,
    DocumentSnapshot<Event>? pastCursor,
    bool clearPastCursor = false,
    DocumentSnapshot<Event>? cancelledCursor,
    bool clearCancelledCursor = false,
    bool? hasMoreActive,
    bool? hasMorePast,
    bool? hasMoreCancelled,
    bool? loadingMoreActive,
    bool? loadingMorePast,
    Object? activeLoadMoreError,
    bool clearActiveLoadMoreError = false,
    Object? pastError,
    StackTrace? pastStackTrace,
    bool clearPastError = false,
  }) => HostEventsTimelineData(
    activeEvents: activeEvents ?? this.activeEvents,
    pastEvents: pastEvents ?? this.pastEvents,
    unpublishedUpcoming: unpublishedUpcoming ?? this.unpublishedUpcoming,
    unpublishedHistory: unpublishedHistory ?? this.unpublishedHistory,
    cancelledEvents: cancelledEvents ?? this.cancelledEvents,
    activeCursor: clearActiveCursor ? null : activeCursor ?? this.activeCursor,
    pastCursor: clearPastCursor ? null : pastCursor ?? this.pastCursor,
    cancelledCursor: clearCancelledCursor
        ? null
        : cancelledCursor ?? this.cancelledCursor,
    hasMoreActive: hasMoreActive ?? this.hasMoreActive,
    hasMorePast: hasMorePast ?? this.hasMorePast,
    hasMoreCancelled: hasMoreCancelled ?? this.hasMoreCancelled,
    loadingMoreActive: loadingMoreActive ?? this.loadingMoreActive,
    loadingMorePast: loadingMorePast ?? this.loadingMorePast,
    activeLoadMoreError: clearActiveLoadMoreError
        ? null
        : activeLoadMoreError ?? this.activeLoadMoreError,
    pastError: clearPastError ? null : pastError ?? this.pastError,
    pastStackTrace: clearPastError
        ? null
        : pastStackTrace ?? this.pastStackTrace,
  );
}

@riverpod
class HostEventsTimelineController extends _$HostEventsTimelineController {
  int _generation = 0;

  @override
  Future<HostEventsTimelineData> build(
    HostEventsTimelineRequest request,
  ) async {
    ++_generation;
    ref.onDispose(() => ++_generation);
    final repository = ref.read(eventRepositoryProvider);
    final activePage = await repository.fetchActiveEventsPage(
      organizerId: request.organizerId,
      sessionBoundary: request.sessionBoundary,
    );
    // Unpublished organizer events are part of the same list — failing this
    // read must surface as the page-level error rather than silently
    // reintroducing the invisible-event gap.
    final unpublished = await _readUnpublishedSetups(request.organizerId);

    try {
      final pastPage = await repository.fetchPastEventsPage(
        organizerId: request.organizerId,
        sessionBoundary: request.sessionBoundary,
      );
      final cancelledPage = await repository.fetchCancelledEventsPage(
        organizerId: request.organizerId,
      );
      return _initialState(
        activePage,
        unpublishedUpcoming: unpublished.upcoming,
        unpublishedHistory: unpublished.history,
        pastPage: pastPage,
        cancelledPage: cancelledPage,
      );
    } on Object catch (error, stackTrace) {
      return _initialState(
        activePage,
        unpublishedUpcoming: unpublished.upcoming,
        unpublishedHistory: unpublished.history,
        pastError: error,
        pastStackTrace: stackTrace,
      );
    }
  }

  Future<void> loadMoreActive() async {
    final generation = _generation;
    final current = state.asData?.value;
    if (current == null || !current.canLoadMoreActive) return;
    state = AsyncData(
      current.copyWith(loadingMoreActive: true, clearActiveLoadMoreError: true),
    );
    try {
      final page = await ref
          .read(eventRepositoryProvider)
          .fetchActiveEventsPage(
            organizerId: request.organizerId,
            sessionBoundary: request.sessionBoundary,
            startAfter: current.activeCursor,
          );
      final latest = _currentData(generation);
      if (latest == null) return;
      state = AsyncData(
        _appendActive(latest, page).copyWith(loadingMoreActive: false),
      );
    } on Object catch (error) {
      final latest = _currentData(generation);
      if (latest == null) return;
      state = AsyncData(
        latest.copyWith(loadingMoreActive: false, activeLoadMoreError: error),
      );
    }
  }

  Future<void> loadMorePast() async {
    final generation = _generation;
    final current = state.asData?.value;
    if (current == null || !current.canLoadMorePast) return;
    state = AsyncData(
      current.copyWith(loadingMorePast: true, clearPastError: true),
    );
    try {
      final repository = ref.read(eventRepositoryProvider);
      final page = current.hasMorePast
          ? await repository.fetchPastEventsPage(
              organizerId: request.organizerId,
              sessionBoundary: request.sessionBoundary,
              startAfter: current.pastCursor,
            )
          : null;
      final cancelledPage = current.hasMoreCancelled
          ? await repository.fetchCancelledEventsPage(
              organizerId: request.organizerId,
              startAfter: current.cancelledCursor,
            )
          : null;
      final latest = _currentData(generation);
      if (latest == null) return;
      state = AsyncData(
        _appendPast(latest, page, cancelledPage).copyWith(
          loadingMorePast: false,
        ),
      );
    } on Object catch (error, stackTrace) {
      final latest = _currentData(generation);
      if (latest == null) return;
      state = AsyncData(
        latest.copyWith(
          loadingMorePast: false,
          pastError: error,
          pastStackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> retryPast() async {
    final generation = _generation;
    final current = state.asData?.value;
    if (current == null || current.loadingMorePast) return;
    if (current.pastEvents.isNotEmpty && current.hasMorePast) {
      await loadMorePast();
      return;
    }
    state = AsyncData(
      current.copyWith(loadingMorePast: true, clearPastError: true),
    );
    try {
      final repository = ref.read(eventRepositoryProvider);
      final page = await repository.fetchPastEventsPage(
        organizerId: request.organizerId,
        sessionBoundary: request.sessionBoundary,
      );
      final cancelledPage = await repository.fetchCancelledEventsPage(
        organizerId: request.organizerId,
      );
      final latest = _currentData(generation);
      if (latest == null) return;
      state = AsyncData(
        latest.copyWith(
          pastEvents: page.items,
          pastCursor: page.nextCursor,
          clearPastCursor: page.nextCursor == null,
          hasMorePast: page.hasMore,
          cancelledEvents: cancelledPage.items,
          cancelledCursor: cancelledPage.nextCursor,
          clearCancelledCursor: cancelledPage.nextCursor == null,
          hasMoreCancelled: cancelledPage.hasMore,
          loadingMorePast: false,
          clearPastError: true,
        ),
      );
    } on Object catch (error, stackTrace) {
      final latest = _currentData(generation);
      if (latest == null) return;
      state = AsyncData(
        latest.copyWith(
          loadingMorePast: false,
          pastError: error,
          pastStackTrace: stackTrace,
        ),
      );
    }
  }

  /// Reads the organizer's unpublished events across every setup scope so
  /// the timeline can merge them with published pages. Scopes are capped
  /// pages — an organizer's in-progress setup list is intentionally small.
  Future<
    ({
      List<PrivateEventSetupInventoryItem> upcoming,
      List<PrivateEventSetupInventoryItem> history,
    })
  >
  _readUnpublishedSetups(String organizerId) async {
    const none = (
      upcoming: <PrivateEventSetupInventoryItem>[],
      history: <PrivateEventSetupInventoryItem>[],
    );
    if (!ref.read(privateEventSetupAvailableProvider)) return none;
    final repository = PrivateEventSetupRepository(
      ref.read(firebaseFunctionsProvider),
    );
    final upcoming = await _readSetupScope(
      repository,
      organizerId,
      PrivateEventSetupScope.upcoming,
    );
    final past = await _readSetupScope(
      repository,
      organizerId,
      PrivateEventSetupScope.past,
    );
    final cancelled = await _readSetupScope(
      repository,
      organizerId,
      PrivateEventSetupScope.cancelled,
    );
    return (
      upcoming: upcoming,
      history: [...past, ...cancelled],
    );
  }

  // A page response updates its own lane in the latest state. Never restore a
  // pre-await snapshot over the other tab's progress, or a refreshed session.
  HostEventsTimelineData? _currentData(int generation) =>
      generation == _generation ? state.asData?.value : null;
}

const int _unpublishedScopePageCap = 10;

Future<List<PrivateEventSetupInventoryItem>> _readSetupScope(
  PrivateEventSetupRepository repository,
  String organizerId,
  PrivateEventSetupScope scope,
) async {
  final items = <PrivateEventSetupInventoryItem>[];
  String? cursor;
  for (var page = 0; page < _unpublishedScopePageCap; page++) {
    final result = await repository.list(
      organizerId: organizerId,
      scope: scope,
      cursor: cursor,
    );
    items.addAll(result.events);
    cursor = result.nextCursor;
    if (cursor == null) return List.unmodifiable(items);
  }
  return List.unmodifiable(items);
}

HostEventsTimelineData _initialState(
  CursorPage<Event, DocumentSnapshot<Event>> activePage, {
  List<PrivateEventSetupInventoryItem> unpublishedUpcoming =
      const <PrivateEventSetupInventoryItem>[],
  List<PrivateEventSetupInventoryItem> unpublishedHistory =
      const <PrivateEventSetupInventoryItem>[],
  CursorPage<Event, DocumentSnapshot<Event>>? pastPage,
  CursorPage<Event, DocumentSnapshot<Event>>? cancelledPage,
  Object? pastError,
  StackTrace? pastStackTrace,
}) => HostEventsTimelineData(
  activeEvents: activePage.items,
  pastEvents: pastPage?.items ?? const [],
  unpublishedUpcoming: unpublishedUpcoming,
  unpublishedHistory: unpublishedHistory,
  cancelledEvents: cancelledPage?.items ?? const [],
  activeCursor: activePage.nextCursor,
  pastCursor: pastPage?.nextCursor,
  cancelledCursor: cancelledPage?.nextCursor,
  hasMoreActive: activePage.hasMore,
  hasMorePast: pastPage?.hasMore ?? false,
  hasMoreCancelled: cancelledPage?.hasMore ?? false,
  pastError: pastError,
  pastStackTrace: pastStackTrace,
);

HostEventsTimelineData _appendActive(
  HostEventsTimelineData current,
  CursorPage<Event, DocumentSnapshot<Event>> page,
) => current.copyWith(
  activeEvents: _mergeEvents(current.activeEvents, page.items),
  activeCursor: page.nextCursor,
  clearActiveCursor: page.nextCursor == null,
  hasMoreActive: page.hasMore,
  clearActiveLoadMoreError: true,
);

HostEventsTimelineData _appendPast(
  HostEventsTimelineData current,
  CursorPage<Event, DocumentSnapshot<Event>>? page,
  CursorPage<Event, DocumentSnapshot<Event>>? cancelledPage,
) => current.copyWith(
  pastEvents: page == null
      ? current.pastEvents
      : _mergeEvents(current.pastEvents, page.items),
  pastCursor: page?.nextCursor,
  clearPastCursor: page != null && page.nextCursor == null,
  hasMorePast: page?.hasMore,
  cancelledEvents: cancelledPage == null
      ? current.cancelledEvents
      : _mergeEvents(current.cancelledEvents, cancelledPage.items),
  cancelledCursor: cancelledPage?.nextCursor,
  clearCancelledCursor:
      cancelledPage != null && cancelledPage.nextCursor == null,
  hasMoreCancelled: cancelledPage?.hasMore,
  clearPastError: true,
);

List<Event> _mergeEvents(Iterable<Event> current, Iterable<Event> next) {
  final byId = <String, Event>{
    for (final event in current) event.id: event,
    for (final event in next) event.id: event,
  };
  return List.unmodifiable(byId.values);
}
