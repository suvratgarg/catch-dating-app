import 'package:catch_dating_app/events/domain/event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── helpers ────────────────────────────────────────────────────────────────

  Event buildEvent({
    String id = 'event-1',
    DateTime? startTime,
    DateTime? endTime,
    int capacityLimit = 20,
    int priceInPaise = 0,
    int? bookedCount,
    int? checkedInCount,
    int? waitlistedCount,
    EventLifecycleStatus status = EventLifecycleStatus.active,
  }) {
    final start = startTime ?? DateTime.now().add(const Duration(hours: 1));
    return Event(
      id: id,
      clubId: 'club-1',
      startTime: start,
      endTime: endTime ?? start.add(const Duration(hours: 1)),
      meetingPoint: 'Carter Road',
      distanceKm: 5.0,
      pace: PaceLevel.easy,
      capacityLimit: capacityLimit,
      description: 'A test event',
      priceInPaise: priceInPaise,
      bookedCount: bookedCount,
      checkedInCount: checkedInCount,
      waitlistedCount: waitlistedCount,
      status: status,
    );
  }

  // ── #1-2: title ────────────────────────────────────────────────────────────

  group('Event.title', () {
    test('#1 Saturday 6 AM → "Saturday Morning Event"', () {
      // Find the next Saturday 06:00
      var dt = DateTime(2025, 1, 1, 6, 0); // 2025-01-01 is a Wednesday
      while (dt.weekday != DateTime.saturday) {
        dt = dt.add(const Duration(days: 1));
      }
      final event = buildEvent(startTime: dt);
      expect(event.title, 'Saturday Morning Event');
    });

    test('#2 Wednesday 14:00 → "Wednesday Afternoon Event"', () {
      var dt = DateTime(2025, 1, 1, 14, 0);
      while (dt.weekday != DateTime.wednesday) {
        dt = dt.add(const Duration(days: 1));
      }
      final event = buildEvent(startTime: dt);
      expect(event.title, 'Wednesday Afternoon Event');
    });

    test('Evening period for 18:00', () {
      var dt = DateTime(2025, 1, 1, 18, 0);
      while (dt.weekday != DateTime.friday) {
        dt = dt.add(const Duration(days: 1));
      }
      final event = buildEvent(startTime: dt);
      expect(event.title, 'Friday Evening Event');
    });
  });

  // ── #3-4: isUpcoming ───────────────────────────────────────────────────────

  group('Event.isUpcoming', () {
    test('#3 true when startTime is 1 h in the future', () {
      final event = buildEvent(
        startTime: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(event.isUpcoming, isTrue);
    });

    test('#4 false when startTime is 1 h in the past', () {
      final event = buildEvent(
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(event.isUpcoming, isFalse);
    });

    test('false when the event has been cancelled', () {
      final event = buildEvent(
        status: EventLifecycleStatus.cancelled,
        startTime: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(event.isCancelled, isTrue);
      expect(event.isUpcoming, isFalse);
    });
  });

  // ── #5-6: isFull ──────────────────────────────────────────────────────────

  group('Event.isFull', () {
    test('#5 false when signedUpCount < capacityLimit', () {
      final event = buildEvent(capacityLimit: 5, bookedCount: 2);
      expect(event.isFull, isFalse);
    });

    test('#6 true when signedUpCount == capacityLimit', () {
      final event = buildEvent(capacityLimit: 2, bookedCount: 2);
      expect(event.isFull, isTrue);
    });

    test('true when signedUpCount exceeds capacityLimit', () {
      final event = buildEvent(capacityLimit: 2, bookedCount: 3);
      expect(event.isFull, isTrue);
    });

    test('uses projected bookedCount for roster capacity', () {
      final event = buildEvent(capacityLimit: 5, bookedCount: 4);

      expect(event.signedUpCount, 4);
      expect(event.spotsRemaining, 1);
      expect(event.isFull, isFalse);
    });

    test('uses projected checked-in and waitlist counts', () {
      final event = buildEvent(checkedInCount: 3, waitlistedCount: 2);

      expect(event.attendedCount, 3);
      expect(event.waitlistCount, 2);
    });
  });

  // ── #7: isFree ────────────────────────────────────────────────────────────

  group('Event.isFree', () {
    test('#7 true when priceInPaise == 0', () {
      expect(buildEvent(priceInPaise: 0).isFree, isTrue);
    });

    test('false when priceInPaise > 0', () {
      expect(buildEvent(priceInPaise: 50000).isFree, isFalse);
    });
  });

  group('Event.distanceMiles', () {
    test('converts kilometres to miles', () {
      final event = buildEvent();
      expect(event.distanceMiles, closeTo(3.106855, 0.000001));
    });
  });
}
