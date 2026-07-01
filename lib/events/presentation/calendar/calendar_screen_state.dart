import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter/material.dart';

class CalendarHomeState {
  const CalendarHomeState({
    required this.summary,
    required this.selectedDate,
    required this.expanded,
  });

  factory CalendarHomeState.from({
    required List<Event> signedUpEvents,
    List<Event> savedEvents = const <Event>[],
    required DateTime now,
    DateTime? selectedDate,
    bool expanded = false,
  }) {
    final summary = CalendarEventSummary.from(
      signedUpEvents: signedUpEvents,
      savedEvents: savedEvents,
      now: now,
    );
    return CalendarHomeState(
      summary: summary,
      selectedDate: DateUtils.dateOnly(selectedDate ?? summary.anchorDate),
      expanded: expanded,
    );
  }

  final CalendarEventSummary summary;
  final DateTime selectedDate;
  final bool expanded;

  bool get hasEvents => summary.events.isNotEmpty;
  Iterable<String> get clubIds => summary.events.map((event) => event.clubId);
}

class CalendarEventSummary {
  const CalendarEventSummary({
    required this.events,
    required this.agendaEvents,
    required this.savedOnlyEventIds,
    required this.today,
    required this.anchorDate,
    required this.totalDistance,
    this.nextEvent,
  });

  final List<Event> events;
  final List<Event> agendaEvents;
  final Set<String> savedOnlyEventIds;
  final DateTime today;
  final DateTime anchorDate;
  final double totalDistance;
  final Event? nextEvent;

  bool isSavedOnly(Event event) => savedOnlyEventIds.contains(event.id);

  static CalendarEventSummary from({
    required List<Event> signedUpEvents,
    List<Event> savedEvents = const <Event>[],
    required DateTime now,
  }) {
    final signedUpIds = signedUpEvents.map((event) => event.id).toSet();
    final savedOnlyEventIds = <String>{};
    final byId = <String, Event>{};

    for (final event in savedEvents) {
      if (event.isCancelled || !event.startTime.isAfter(now)) continue;
      byId[event.id] = event;
      if (!signedUpIds.contains(event.id)) savedOnlyEventIds.add(event.id);
    }
    for (final event in signedUpEvents) {
      byId[event.id] = event;
    }

    final sorted = byId.values.toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime));
    final today = DateUtils.dateOnly(now);
    // Cancelled events stay visible in the agenda but never count toward
    // distance stats and are never the user's next event.
    final totalDistance = sorted
        .where((event) => !event.isCancelled)
        .fold<double>(0, (sum, event) => sum + event.distanceKm);

    final upcoming = <Event>[];
    final cancelledUpcoming = <Event>[];
    final past = <Event>[];
    for (final event in sorted) {
      if (!event.startTime.isBefore(now) && event.isCancelled) {
        cancelledUpcoming.add(event);
      } else if (event.startTime.isBefore(now)) {
        past.add(event);
      } else {
        upcoming.add(event);
      }
    }

    final nextEvent = upcoming.isEmpty ? null : upcoming.first;
    final latestPastFirst = [...past]
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
    final anchorDate = nextEvent?.startTime ?? today;

    return CalendarEventSummary(
      events: List.unmodifiable(sorted),
      agendaEvents: List.unmodifiable([
        ...upcoming,
        ...cancelledUpcoming,
        ...latestPastFirst,
      ]),
      savedOnlyEventIds: Set.unmodifiable(savedOnlyEventIds),
      today: today,
      anchorDate: anchorDate,
      totalDistance: totalDistance,
      nextEvent: nextEvent,
    );
  }
}
