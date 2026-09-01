import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/events/data/host_events_timeline_controller.dart';
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

  HostEventsTimelineRequest get timelineRequest => HostEventsTimelineRequest(
    organizerId: organizerId,
    sessionBoundary: sessionBoundary,
  );

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
    final timeline = await ref.watch(
      hostEventsTimelineControllerProvider(request.timelineRequest).future,
    );
    return HostTodayFeedData(
      activeEvents: timeline.activeEvents,
      pastEvents: timeline.pastEvents,
    );
  }

  void retry() {
    ref.invalidate(
      hostEventsTimelineControllerProvider(request.timelineRequest),
    );
    ref.invalidateSelf();
  }
}
