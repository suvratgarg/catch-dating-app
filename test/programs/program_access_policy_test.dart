import 'package:catch_dating_app/programs/domain/program_access_policy.dart';
import 'package:catch_dating_app/programs/domain/program_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final now = DateTime(2026);
  final soon = now.add(const Duration(minutes: 1));
  final later = now.add(const Duration(hours: 1));
  ProgramWorkAccess access(List<ProgramDutyAssignment> duties) =>
      ProgramWorkAccess(
        programId: 'p',
        organizerId: 'o',
        title: 'Program',
        kind: ProgramKind.wedding,
        timezone: 'Asia/Kolkata',
        status: ProgramStatus.active,
        actorRole: ProgramActorRole.staff,
        duties: duties,
        grantExpiresAt: later,
        capabilities: const {'arrivalsTransport'},
        pickupPoints: const [],
        hotels: const [],
        functions: const [],
        vehicleClasses: const [],
      );
  ProgramDutyAssignment dispatcher(
    String pickup,
    String hotel,
    DateTime expiry,
  ) => ProgramDutyAssignment(
    duty: ProgramStaffDuty.transportDispatcher,
    pickupPointIds: {pickup},
    hotelIds: {hotel},
    functionIds: {},
    expiresAt: expiry,
  );

  test('dispatch authority cannot combine the ends of different routes', () {
    final work = access([
      dispatcher('a', 'one', soon),
      dispatcher('b', 'two', later),
    ]);
    expect(programDispatchAccess(work, 'a', 'two', now: now).allowed, isFalse);
    expect(programDispatchAccess(work, 'b', 'one', now: now).allowed, isFalse);
    expect(programDispatchAccess(work, 'a', 'one', now: now), (
      allowed: true,
      expiresAt: soon,
    ));
  });

  test(
    'the sheet deadline excludes unrelated duties and tracks scope shrink',
    () {
      final work = access([
        const ProgramDutyAssignment(
          duty: ProgramStaffDuty.hotelDesk,
          pickupPointIds: {},
          hotelIds: {'one'},
          functionIds: {},
        ),
        dispatcher('a', 'one', later),
        ProgramDutyAssignment(
          duty: ProgramStaffDuty.transportDispatcher,
          pickupPointIds: {},
          hotelIds: {},
          functionIds: {},
          expiresAt: soon,
        ),
      ]);
      expect(programDispatchAccess(work, 'a', 'one', now: now).expiresAt, soon);
      expect(
        programDispatchAccess(work, 'a', 'one', now: soon).expiresAt,
        later,
      );
      expect(
        programDispatchAccess(work, 'b', 'two', now: soon).allowed,
        isFalse,
      );
    },
  );

  test('greeter access and expired dispatcher duties cannot open dispatch', () {
    final work = access([
      ProgramDutyAssignment(
        duty: ProgramStaffDuty.airportGreeter,
        pickupPointIds: {},
        hotelIds: {},
        functionIds: {},
        expiresAt: later,
      ),
      dispatcher('a', 'one', now),
    ]);
    expect(canReadProgramStation(work, 'a', dispatch: false, now: now), isTrue);
    expect(programDispatchAccess(work, 'a', 'one', now: now).allowed, isFalse);
  });
}
