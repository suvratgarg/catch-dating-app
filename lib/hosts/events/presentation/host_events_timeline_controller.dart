import 'package:catch_dating_app/core/data/cursor_page.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
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
    this.loadingMoreActive = false,
    this.loadingMorePast = false,
    this.activeLoadMoreError,
    this.pastError,
    this.pastStackTrace,
  });

  final List<Event> activeEvents;
  final List<Event> pastEvents;
  final DocumentSnapshot<Event>? activeCursor;
  final DocumentSnapshot<Event>? pastCursor;
  final bool hasMoreActive;
  final bool hasMorePast;
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
  bool get canLoadMorePast => hasMorePast && !loadingMorePast;

  HostEventsTimelineData copyWith({
    List<Event>? activeEvents,
    List<Event>? pastEvents,
    DocumentSnapshot<Event>? activeCursor,
    bool clearActiveCursor = false,
    DocumentSnapshot<Event>? pastCursor,
    bool clearPastCursor = false,
    bool? hasMoreActive,
    bool? hasMorePast,
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
    activeCursor: clearActiveCursor ? null : activeCursor ?? this.activeCursor,
    pastCursor: clearPastCursor ? null : pastCursor ?? this.pastCursor,
    hasMoreActive: hasMoreActive ?? this.hasMoreActive,
    hasMorePast: hasMorePast ?? this.hasMorePast,
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
  @override
  Future<HostEventsTimelineData> build(
    HostEventsTimelineRequest request,
  ) async {
    final repository = ref.read(eventRepositoryProvider);
    final activePage = await repository.fetchActiveEventsPage(
      organizerId: request.organizerId,
      sessionBoundary: request.sessionBoundary,
    );

    try {
      final pastPage = await repository.fetchPastEventsPage(
        organizerId: request.organizerId,
        sessionBoundary: request.sessionBoundary,
      );
      return _initialState(activePage, pastPage: pastPage);
    } on Object catch (error, stackTrace) {
      return _initialState(
        activePage,
        pastError: error,
        pastStackTrace: stackTrace,
      );
    }
  }

  Future<void> loadMoreActive() async {
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
      state = AsyncData(
        _appendActive(current, page).copyWith(loadingMoreActive: false),
      );
    } on Object catch (error) {
      state = AsyncData(
        current.copyWith(loadingMoreActive: false, activeLoadMoreError: error),
      );
    }
  }

  Future<void> loadMorePast() async {
    final current = state.asData?.value;
    if (current == null || !current.canLoadMorePast) return;
    state = AsyncData(
      current.copyWith(loadingMorePast: true, clearPastError: true),
    );
    try {
      final page = await ref
          .read(eventRepositoryProvider)
          .fetchPastEventsPage(
            organizerId: request.organizerId,
            sessionBoundary: request.sessionBoundary,
            startAfter: current.pastCursor,
          );
      state = AsyncData(
        _appendPast(current, page).copyWith(loadingMorePast: false),
      );
    } on Object catch (error, stackTrace) {
      state = AsyncData(
        current.copyWith(
          loadingMorePast: false,
          pastError: error,
          pastStackTrace: stackTrace,
        ),
      );
    }
  }

  Future<void> retryPast() async {
    final current = state.asData?.value;
    if (current == null || current.loadingMorePast) return;
    state = AsyncData(
      current.copyWith(loadingMorePast: true, clearPastError: true),
    );
    try {
      final page = await ref
          .read(eventRepositoryProvider)
          .fetchPastEventsPage(
            organizerId: request.organizerId,
            sessionBoundary: request.sessionBoundary,
          );
      state = AsyncData(
        current.copyWith(
          pastEvents: page.items,
          pastCursor: page.nextCursor,
          clearPastCursor: page.nextCursor == null,
          hasMorePast: page.hasMore,
          loadingMorePast: false,
          clearPastError: true,
        ),
      );
    } on Object catch (error, stackTrace) {
      state = AsyncData(
        current.copyWith(
          loadingMorePast: false,
          pastError: error,
          pastStackTrace: stackTrace,
        ),
      );
    }
  }
}

HostEventsTimelineData _initialState(
  CursorPage<Event, DocumentSnapshot<Event>> activePage, {
  CursorPage<Event, DocumentSnapshot<Event>>? pastPage,
  Object? pastError,
  StackTrace? pastStackTrace,
}) => HostEventsTimelineData(
  activeEvents: activePage.items,
  pastEvents: pastPage?.items ?? const [],
  activeCursor: activePage.nextCursor,
  pastCursor: pastPage?.nextCursor,
  hasMoreActive: activePage.hasMore,
  hasMorePast: pastPage?.hasMore ?? false,
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
  CursorPage<Event, DocumentSnapshot<Event>> page,
) => current.copyWith(
  pastEvents: _mergeEvents(current.pastEvents, page.items),
  pastCursor: page.nextCursor,
  clearPastCursor: page.nextCursor == null,
  hasMorePast: page.hasMore,
  clearPastError: true,
);

List<Event> _mergeEvents(Iterable<Event> current, Iterable<Event> next) {
  final byId = <String, Event>{
    for (final event in current) event.id: event,
    for (final event in next) event.id: event,
  };
  return List.unmodifiable(byId.values);
}
