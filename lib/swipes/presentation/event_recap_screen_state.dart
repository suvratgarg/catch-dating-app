import 'package:catch_dating_app/core/presentation/catch_async_state.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/domain/swipe_window.dart';
import 'package:catch_dating_app/swipes/presentation/event_recap_view_model.dart';

sealed class EventRecapScreenState {
  const EventRecapScreenState();
}

final class EventRecapLoading extends EventRecapScreenState {
  const EventRecapLoading();
}

final class EventRecapError extends EventRecapScreenState {
  const EventRecapError({required this.error, required this.retryIntent});

  final Object error;
  final EventRecapRetryIntent retryIntent;
}

final class EventRecapMissingEvent extends EventRecapScreenState {
  const EventRecapMissingEvent();
}

final class EventRecapReady extends EventRecapScreenState {
  const EventRecapReady({
    required this.hero,
    required this.attendeeRows,
    required this.selectedVibeIds,
    required this.openDeckIntent,
    required this.openDeckActionEnabled,
  });

  final EventRecapHeroState hero;
  final List<EventRecapAttendeeRow> attendeeRows;
  final Set<String> selectedVibeIds;
  final EventRecapOpenDeckIntent openDeckIntent;
  final bool openDeckActionEnabled;

  bool get hasAttendees => attendeeRows.isNotEmpty;
}

class EventRecapHeroState {
  const EventRecapHeroState({
    required this.kicker,
    required this.distanceLabel,
    required this.activityCheckedInLabel,
    required this.whenLabel,
    required this.timeLabel,
    required this.windowLabel,
  });

  final String kicker;
  final String distanceLabel;
  final String activityCheckedInLabel;
  final String whenLabel;
  final String timeLabel;
  final String windowLabel;

  factory EventRecapHeroState.fromEvent({
    required Event event,
    required int checkedInCount,
    required DateTime now,
  }) {
    final closesAt = swipeWindowClosesAt(event);
    final windowLabel = closesAt.isAfter(now)
        ? 'Catches open until ${EventFormatters.time(closesAt)}'
        : 'Catch window closed';

    return EventRecapHeroState(
      kicker: '${event.title.toUpperCase()} · COMPLETE',
      distanceLabel: event.distanceLabel,
      activityCheckedInLabel:
          '${event.activitySummaryLabel} · $checkedInCount checked in',
      whenLabel: event.shortDateLabel,
      timeLabel: event.compactTimeRangeLabel,
      windowLabel: windowLabel,
    );
  }
}

class EventRecapAttendeeRow {
  const EventRecapAttendeeRow({
    required this.attendeeId,
    required this.profile,
    required this.selected,
  });

  final String attendeeId;
  final PublicProfile? profile;
  final bool selected;

  String get displayName => profile?.name ?? 'Guest';
  String get semanticLabel => profile?.name ?? 'Guest';
  String get tooltipName => profile?.name ?? 'guest';
  String get tooltip =>
      selected ? 'Remove $tooltipName' : 'Remember $tooltipName';
}

class EventRecapRetryIntent {
  const EventRecapRetryIntent({required this.eventId});

  final String eventId;
}

class EventRecapOpenDeckIntent {
  const EventRecapOpenDeckIntent({
    required this.eventId,
    required this.selectedVibeIds,
  });

  final String eventId;
  final Set<String> selectedVibeIds;
}

EventRecapScreenState buildEventRecapScreenState({
  required String eventId,
  required CatchAsyncState<EventRecapViewModel?> viewModel,
  required Map<String, PublicProfile> rosterProfiles,
  required Set<String> selectedVibeIds,
  DateTime? now,
}) {
  return switch (viewModel.status) {
    CatchAsyncStatus.loading => const EventRecapLoading(),
    CatchAsyncStatus.error => EventRecapError(
      error: viewModel.error!,
      retryIntent: EventRecapRetryIntent(eventId: eventId),
    ),
    CatchAsyncStatus.data => _eventRecapDataState(
      viewModel: viewModel.value,
      rosterProfiles: rosterProfiles,
      selectedVibeIds: selectedVibeIds,
      now: now ?? DateTime.now(),
    ),
  };
}

EventRecapScreenState _eventRecapDataState({
  required EventRecapViewModel? viewModel,
  required Map<String, PublicProfile> rosterProfiles,
  required Set<String> selectedVibeIds,
  required DateTime now,
}) {
  if (viewModel == null) return const EventRecapMissingEvent();

  final selected = Set<String>.unmodifiable(selectedVibeIds);
  final attendeeRows = [
    for (final attendeeId in viewModel.attendeeIds)
      EventRecapAttendeeRow(
        attendeeId: attendeeId,
        profile: rosterProfiles[attendeeId],
        selected: selected.contains(attendeeId),
      ),
  ];

  return EventRecapReady(
    hero: EventRecapHeroState.fromEvent(
      event: viewModel.event,
      checkedInCount: viewModel.checkedInCount,
      now: now,
    ),
    attendeeRows: List.unmodifiable(attendeeRows),
    selectedVibeIds: selected,
    openDeckIntent: EventRecapOpenDeckIntent(
      eventId: viewModel.event.id,
      selectedVibeIds: selected,
    ),
    openDeckActionEnabled: true,
  );
}
