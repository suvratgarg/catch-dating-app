import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_screen_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

CatchesHubScreenState buildCatchesHubScreenState({
  required AsyncValue<String?> uid,
  required AsyncValue<List<Event>>? attendedEvents,
  required DateTime now,
}) {
  if (uid.isLoading && !uid.hasValue) {
    return const CatchesHubAccessLoading();
  }

  final uidError = uid.error;
  if (uidError != null && !uid.hasValue) {
    return CatchesHubAccessError(uidError);
  }

  final userId = uid.asData?.value;
  if (userId == null) return const CatchesHubSignedOut();

  final eventsAsync = attendedEvents;
  if (eventsAsync == null || (eventsAsync.isLoading && !eventsAsync.hasValue)) {
    return CatchesHubEventsLoading(uid: userId);
  }

  final eventsError = eventsAsync.error;
  if (eventsError != null && !eventsAsync.hasValue) {
    return CatchesHubEventsError(uid: userId, error: eventsError);
  }

  final rows = catchesHubRowsFromEvents(
    eventsAsync.asData?.value ?? const <Event>[],
    now: now,
  );
  if (rows.isEmpty) return CatchesHubEmpty(uid: userId);

  return CatchesHubReady(uid: userId, rows: rows);
}
