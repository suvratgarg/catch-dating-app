import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/calendar/calendar_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';

void main() {
  group('CalendarHomeState', () {
    test('uses the next event date as the default selected date', () {
      final now = DateTime(2026, 6, 30, 12);
      final nextEvent = buildEvent(
        id: 'next-event',
        startTime: now.add(const Duration(days: 1, hours: 3)),
      );

      final state = CalendarHomeState.from(
        signedUpEvents: [nextEvent],
        now: now,
      );

      expect(state.summary.nextEvent, nextEvent);
      expect(state.selectedDate, DateUtils.dateOnly(nextEvent.startTime));
      expect(state.expanded, isFalse);
      expect(state.hasEvents, isTrue);
      expect(state.clubIds, [nextEvent.clubId]);
    });

    test('preserves explicit selected date and header mode', () {
      final now = DateTime(2026, 6, 30, 12);
      final selectedDate = DateTime(2026, 7, 4, 18);

      final state = CalendarHomeState.from(
        signedUpEvents: const [],
        now: now,
        selectedDate: selectedDate,
        expanded: true,
      );

      expect(state.selectedDate, DateUtils.dateOnly(selectedDate));
      expect(state.expanded, isTrue);
      expect(state.hasEvents, isFalse);
      expect(state.clubIds, isEmpty);
    });
  });

  group('CalendarEventSummary', () {
    test('merges joined and saved events into the calendar display policy', () {
      final now = DateTime(2026, 6, 30, 12);
      final joinedUpcoming = buildEvent(
        id: 'joined-upcoming',
        startTime: now.add(const Duration(days: 2)),
      );
      final joinedPast = buildEvent(
        id: 'joined-past',
        startTime: now.subtract(const Duration(days: 1)),
        distanceKm: 3,
      );
      final cancelledUpcoming = buildEvent(
        id: 'cancelled-upcoming',
        startTime: now.add(const Duration(days: 1)),
        distanceKm: 9,
        status: EventLifecycleStatus.cancelled,
      );
      final savedUpcoming = buildEvent(
        id: 'saved-upcoming',
        startTime: now.add(const Duration(hours: 20)),
        distanceKm: 7,
      );
      final savedPast = buildEvent(
        id: 'saved-past',
        startTime: now.subtract(const Duration(hours: 2)),
        distanceKm: 50,
      );
      final savedDuplicate = buildEvent(
        id: joinedUpcoming.id,
        startTime: now.add(const Duration(hours: 8)),
        distanceKm: 99,
      );

      final summary = CalendarEventSummary.from(
        signedUpEvents: [joinedUpcoming, joinedPast, cancelledUpcoming],
        savedEvents: [savedUpcoming, savedPast, savedDuplicate],
        now: now,
      );

      expect(summary.events.map((event) => event.id), [
        'joined-past',
        'saved-upcoming',
        'cancelled-upcoming',
        'joined-upcoming',
      ]);
      expect(summary.agendaEvents.map((event) => event.id), [
        'saved-upcoming',
        'joined-upcoming',
        'cancelled-upcoming',
        'joined-past',
      ]);
      expect(summary.savedOnlyEventIds, {'saved-upcoming'});
      expect(summary.isSavedOnly(savedUpcoming), isTrue);
      expect(summary.isSavedOnly(joinedUpcoming), isFalse);
      expect(summary.nextEvent, savedUpcoming);
      expect(summary.anchorDate, savedUpcoming.startTime);
      expect(summary.totalDistance, 15);
    });
  });
}
