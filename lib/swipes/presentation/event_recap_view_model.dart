import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/data/swipe_candidate_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'event_recap_view_model.g.dart';

class EventRecapViewModel {
  const EventRecapViewModel({
    required this.event,
    required this.attendeeIds,
    required this.checkedInCount,
  });

  final Event event;
  final List<String> attendeeIds;
  final int checkedInCount;
}

@riverpod
AsyncValue<EventRecapViewModel?> eventRecapViewModel(Ref ref, String eventId) {
  return buildEventRecapViewModel(
    eventAsync: ref.watch(watchEventProvider(eventId)),
    uidAsync: ref.watch(uidProvider),
    candidatesAsync: ref.watch(swipeCandidatesProvider(eventId)),
  );
}

AsyncValue<EventRecapViewModel?> buildEventRecapViewModel({
  required AsyncValue<Event?> eventAsync,
  required AsyncValue<String?> uidAsync,
  required AsyncValue<List<PublicProfile>> candidatesAsync,
}) {
  if (eventAsync.isLoading || uidAsync.isLoading || candidatesAsync.isLoading) {
    return const AsyncLoading();
  }

  if (eventAsync.hasError) {
    return AsyncError(
      eventAsync.error!,
      eventAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (uidAsync.hasError) {
    return AsyncError(
      uidAsync.error!,
      uidAsync.stackTrace ?? StackTrace.current,
    );
  }
  if (candidatesAsync.hasError) {
    return AsyncError(
      candidatesAsync.error!,
      candidatesAsync.stackTrace ?? StackTrace.current,
    );
  }

  final event = eventAsync.asData?.value;
  if (event == null) return const AsyncData(null);

  final currentUid = uidAsync.asData?.value;
  final attendeeIds = (candidatesAsync.asData?.value ?? const <PublicProfile>[])
      .map((profile) => profile.uid)
      .where((uid) => uid != currentUid)
      .toList(growable: false);

  return AsyncData(
    EventRecapViewModel(
      event: event,
      attendeeIds: List.unmodifiable(attendeeIds),
      checkedInCount: event.attendedCount,
    ),
  );
}
