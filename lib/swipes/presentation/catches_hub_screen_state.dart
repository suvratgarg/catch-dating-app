import 'package:catch_dating_app/core/time_formatters.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';

sealed class CatchesHubScreenState {
  const CatchesHubScreenState();
}

final class CatchesHubAccessLoading extends CatchesHubScreenState {
  const CatchesHubAccessLoading();
}

final class CatchesHubAccessError extends CatchesHubScreenState {
  const CatchesHubAccessError(this.error);

  final Object error;
}

final class CatchesHubSignedOut extends CatchesHubScreenState {
  const CatchesHubSignedOut();
}

final class CatchesHubEventsLoading extends CatchesHubScreenState {
  const CatchesHubEventsLoading({required this.uid});

  final String uid;
}

final class CatchesHubEventsError extends CatchesHubScreenState {
  const CatchesHubEventsError({required this.uid, required this.error});

  final String uid;
  final Object error;
}

final class CatchesHubEmpty extends CatchesHubScreenState {
  const CatchesHubEmpty({required this.uid});

  final String uid;
}

final class CatchesHubReady extends CatchesHubScreenState {
  const CatchesHubReady({required this.uid, required this.rows});

  final String uid;
  final List<CatchesHubEventRow> rows;

  CatchesHubEventRow get featuredRow => rows.first;
}

class CatchesHubEventRow {
  const CatchesHubEventRow({
    required this.eventId,
    required this.title,
    required this.introSubtitle,
    required this.dateAttendeeLabel,
    required this.attendedCountLabel,
    required this.windowClosesAt,
    required this.introCountdownLabel,
    required this.tileCountdownLabel,
    required this.openCatchRoute,
    required this.recapRoute,
  });

  final String eventId;
  final String title;
  final String introSubtitle;
  final String dateAttendeeLabel;
  final String attendedCountLabel;
  final DateTime windowClosesAt;
  final String introCountdownLabel;
  final String tileCountdownLabel;
  final String openCatchRoute;
  final String recapRoute;
}

List<CatchesHubEventRow> catchesHubRowsFromEvents(
  Iterable<Event> events, {
  required DateTime now,
}) {
  return [
    for (final event in eventsWithOpenSwipeWindow(events, now: now))
      catchesHubRowFromEvent(event, now: now),
  ];
}

CatchesHubEventRow catchesHubRowFromEvent(
  Event event, {
  required DateTime now,
}) {
  final windowEnd = swipeWindowClosesAt(event);
  final remaining = windowEnd.difference(now);
  final dateLabel = AppTimeFormatters.weekdayDayMonth(event.startTime);

  return CatchesHubEventRow(
    eventId: event.id,
    title: event.title,
    introSubtitle: 'Only checked-in attendees from ${event.title} are here.',
    dateAttendeeLabel:
        '$dateLabel · ${event.attendedCount} attendees checked in',
    attendedCountLabel: '${event.attendedCount}',
    windowClosesAt: windowEnd,
    introCountdownLabel: catchesHubIntroCountdownLabel(remaining),
    tileCountdownLabel: catchesHubTileCountdownLabel(remaining),
    openCatchRoute: catchesHubOpenCatchRoute(event.id),
    recapRoute: catchesHubRecapRoute(event.id),
  );
}

String catchesHubOpenCatchRoute(String eventId) {
  return Routes.swipeEventScreen.path.replaceFirst(':eventId', eventId);
}

String catchesHubRecapRoute(String eventId) {
  return Routes.eventRecapScreen.path.replaceFirst(':eventId', eventId);
}

String catchesHubIntroCountdownLabel(Duration remaining) {
  if (remaining.isNegative) return 'Closed';
  final hours = remaining.inHours;
  final minutes = remaining.inMinutes.remainder(60);
  return '${hours}h ${minutes.toString().padLeft(2, '0')}m';
}

String catchesHubTileCountdownLabel(Duration remaining) {
  if (remaining.isNegative) return 'CLOSED';
  final hours = remaining.inHours;
  final minutes = remaining.inMinutes.remainder(60);
  if (hours > 0) return '${hours}H ${minutes.toString().padLeft(2, '0')}M';
  return '${minutes.clamp(0, 59)}M';
}
