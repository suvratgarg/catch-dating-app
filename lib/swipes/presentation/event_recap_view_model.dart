import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/events/data/event_participation_repository.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_participation.dart';
import 'package:catch_dating_app/events/domain/event_participation_roster.dart';
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
    participationsAsync: ref.watch(
      watchEventParticipationsForEventProvider(eventId),
    ),
  );
}

AsyncValue<EventRecapViewModel?> buildEventRecapViewModel({
  required AsyncValue<Event?> eventAsync,
  required AsyncValue<String?> uidAsync,
  required AsyncValue<List<EventParticipation>> participationsAsync,
}) {
  if (eventAsync.isLoading ||
      uidAsync.isLoading ||
      participationsAsync.isLoading) {
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
  if (participationsAsync.hasError) {
    return AsyncError(
      participationsAsync.error!,
      participationsAsync.stackTrace ?? StackTrace.current,
    );
  }

  final event = eventAsync.asData?.value;
  if (event == null) return const AsyncData(null);

  final currentUid = uidAsync.asData?.value;
  final roster = EventParticipationRoster.fromParticipations(
    participationsAsync.asData?.value ?? const [],
  );
  final attendeeIds = roster.checkedInIds
      .where((uid) => uid != currentUid)
      .toList(growable: false);

  return AsyncData(
    EventRecapViewModel(
      event: event,
      attendeeIds: List.unmodifiable(attendeeIds),
      checkedInCount: roster.checkedInCount,
    ),
  );
}
