import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_today_feed_controller.g.dart';

@immutable
class HostTodayFeedRequest {
  const HostTodayFeedRequest({
    required this.organizerId,
    required this.sessionBoundary,
  });

  final String organizerId;
  final DateTime sessionBoundary;

  @override
  bool operator ==(Object other) =>
      other is HostTodayFeedRequest &&
      other.organizerId == organizerId &&
      other.sessionBoundary == sessionBoundary;

  @override
  int get hashCode => Object.hash(organizerId, sessionBoundary);
}

@immutable
class HostTodayFeedData {
  const HostTodayFeedData({
    required this.activeEvents,
    required this.pastEvents,
  });

  final List<Event> activeEvents;
  final List<Event> pastEvents;

  bool get hasPastEvents => pastEvents.isNotEmpty;
}

@riverpod
class HostTodayFeedController extends _$HostTodayFeedController {
  @override
  Future<HostTodayFeedData> build(HostTodayFeedRequest request) async {
    final repository = ref.watch(eventRepositoryProvider);
    final activePage = await repository.fetchActiveEventsPage(
      organizerId: request.organizerId,
      sessionBoundary: request.sessionBoundary,
    );
    final pastEvents = await _fetchPastEvents(repository, request);
    return HostTodayFeedData(
      activeEvents: activePage.items,
      pastEvents: pastEvents,
    );
  }

  Future<List<Event>> _fetchPastEvents(
    EventRepository repository,
    HostTodayFeedRequest request,
  ) async {
    try {
      final page = await repository.fetchPastEventsPage(
        organizerId: request.organizerId,
        sessionBoundary: request.sessionBoundary,
      );
      return page.items;
    } on Object {
      // History only enables the optional Repeat action. Today remains useful
      // when that secondary query is unavailable.
      return const <Event>[];
    }
  }

  void retry() {
    ref.invalidateSelf();
  }
}
