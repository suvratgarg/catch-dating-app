import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── helpers ────────────────────────────────────────────────────────────────

  Run buildRun({
    String id = 'run-1',
    DateTime? startTime,
    DateTime? endTime,
    int capacityLimit = 20,
    int priceInPaise = 0,
    int? bookedCount,
    int? checkedInCount,
    int? waitlistedCount,
    RunLifecycleStatus status = RunLifecycleStatus.active,
  }) {
    final start = startTime ?? DateTime.now().add(const Duration(hours: 1));
    return Run(
      id: id,
      runClubId: 'club-1',
      startTime: start,
      endTime: endTime ?? start.add(const Duration(hours: 1)),
      meetingPoint: 'Carter Road',
      distanceKm: 5.0,
      pace: PaceLevel.easy,
      capacityLimit: capacityLimit,
      description: 'A test run',
      priceInPaise: priceInPaise,
      bookedCount: bookedCount,
      checkedInCount: checkedInCount,
      waitlistedCount: waitlistedCount,
      status: status,
    );
  }

  // ── #1-2: title ────────────────────────────────────────────────────────────

  group('Run.title', () {
    test('#1 Saturday 6 AM → "Saturday Morning Run"', () {
      // Find the next Saturday 06:00
      var dt = DateTime(2025, 1, 1, 6, 0); // 2025-01-01 is a Wednesday
      while (dt.weekday != DateTime.saturday) {
        dt = dt.add(const Duration(days: 1));
      }
      final run = buildRun(startTime: dt);
      expect(run.title, 'Saturday Morning Run');
    });

    test('#2 Wednesday 14:00 → "Wednesday Afternoon Run"', () {
      var dt = DateTime(2025, 1, 1, 14, 0);
      while (dt.weekday != DateTime.wednesday) {
        dt = dt.add(const Duration(days: 1));
      }
      final run = buildRun(startTime: dt);
      expect(run.title, 'Wednesday Afternoon Run');
    });

    test('Evening period for 18:00', () {
      var dt = DateTime(2025, 1, 1, 18, 0);
      while (dt.weekday != DateTime.friday) {
        dt = dt.add(const Duration(days: 1));
      }
      final run = buildRun(startTime: dt);
      expect(run.title, 'Friday Evening Run');
    });
  });

  // ── #3-4: isUpcoming ───────────────────────────────────────────────────────

  group('Run.isUpcoming', () {
    test('#3 true when startTime is 1 h in the future', () {
      final run = buildRun(
        startTime: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(run.isUpcoming, isTrue);
    });

    test('#4 false when startTime is 1 h in the past', () {
      final run = buildRun(
        startTime: DateTime.now().subtract(const Duration(hours: 1)),
      );
      expect(run.isUpcoming, isFalse);
    });

    test('false when the run has been cancelled', () {
      final run = buildRun(
        status: RunLifecycleStatus.cancelled,
        startTime: DateTime.now().add(const Duration(hours: 1)),
      );

      expect(run.isCancelled, isTrue);
      expect(run.isUpcoming, isFalse);
    });
  });

  // ── #5-6: isFull ──────────────────────────────────────────────────────────

  group('Run.isFull', () {
    test('#5 false when signedUpCount < capacityLimit', () {
      final run = buildRun(capacityLimit: 5, bookedCount: 2);
      expect(run.isFull, isFalse);
    });

    test('#6 true when signedUpCount == capacityLimit', () {
      final run = buildRun(capacityLimit: 2, bookedCount: 2);
      expect(run.isFull, isTrue);
    });

    test('true when signedUpCount exceeds capacityLimit', () {
      final run = buildRun(capacityLimit: 2, bookedCount: 3);
      expect(run.isFull, isTrue);
    });

    test('uses projected bookedCount for roster capacity', () {
      final run = buildRun(capacityLimit: 5, bookedCount: 4);

      expect(run.signedUpCount, 4);
      expect(run.spotsRemaining, 1);
      expect(run.isFull, isFalse);
    });

    test('uses projected checked-in and waitlist counts', () {
      final run = buildRun(checkedInCount: 3, waitlistedCount: 2);

      expect(run.attendedCount, 3);
      expect(run.waitlistCount, 2);
    });
  });

  // ── #7: isFree ────────────────────────────────────────────────────────────

  group('Run.isFree', () {
    test('#7 true when priceInPaise == 0', () {
      expect(buildRun(priceInPaise: 0).isFree, isTrue);
    });

    test('false when priceInPaise > 0', () {
      expect(buildRun(priceInPaise: 50000).isFree, isFalse);
    });
  });

  group('Run.distanceMiles', () {
    test('converts kilometres to miles', () {
      final run = buildRun();
      expect(run.distanceMiles, closeTo(3.106855, 0.000001));
    });
  });
}
