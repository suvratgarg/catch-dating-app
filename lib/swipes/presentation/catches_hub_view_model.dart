import 'package:catch_dating_app/core/riverpod_ui/catch_async_value_adapter.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/swipes/presentation/catches_hub_screen_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

CatchesHubScreenState buildCatchesHubScreenState({
  required AsyncValue<String?> uid,
  required AsyncValue<List<Event>>? attendedEvents,
  required DateTime now,
}) {
  final uidState = catchAsyncStateFromAsyncValue(uid);
  if (uidState.isLoading) {
    return const CatchesHubAccessLoading();
  }

  if (uidState.hasError) {
    return CatchesHubAccessError(uidState.error!);
  }

  final userId = uidState.value;
  if (userId == null) return const CatchesHubSignedOut();

  final eventsAsync = attendedEvents;
  if (eventsAsync == null) {
    return CatchesHubEventsLoading(uid: userId);
  }
  final eventsState = catchAsyncStateFromAsyncValue(eventsAsync);
  if (eventsState.isLoading) return CatchesHubEventsLoading(uid: userId);

  if (eventsState.hasError) {
    return CatchesHubEventsError(uid: userId, error: eventsState.error!);
  }

  final rows = catchesHubRowsFromEvents(
    eventsState.value ?? const <Event>[],
    now: now,
  );
  if (rows.isEmpty) return CatchesHubEmpty(uid: userId);

  return CatchesHubReady(uid: userId, rows: rows);
}
