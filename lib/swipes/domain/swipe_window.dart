import 'package:catch_dating_app/events/domain/event.dart';
import 'package:collection/collection.dart';

const swipeWindowDuration = Duration(hours: 24);

DateTime swipeWindowClosesAt(Event event) =>
    event.endTime.add(swipeWindowDuration);

bool hasOpenSwipeWindow(Event event, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  if (event.endTime.isAfter(currentTime)) return false;
  return !swipeWindowClosesAt(event).isBefore(currentTime);
}

List<Event> eventsWithOpenSwipeWindow(Iterable<Event> events, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  return events
      .where((event) => hasOpenSwipeWindow(event, now: currentTime))
      .toList();
}

Event? latestEventWithOpenSwipeWindow(Iterable<Event> events, {DateTime? now}) {
  final currentTime = now ?? DateTime.now();
  return maxBy(
    events.where((event) => hasOpenSwipeWindow(event, now: currentTime)),
    (event) => event.endTime,
  );
}
