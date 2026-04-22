import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:catch_dating_app/runs/domain/run_eligibility.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // ── helpers ────────────────────────────────────────────────────────────────

  /// A future run with capacity, no sign-ups, no constraints — always Eligible.
  Run buildRun({
    DateTime? startTime,
    int capacityLimit = 20,
    List<String> signedUpUserIds = const [],
    List<String> attendedUserIds = const [],
    List<String> waitlistUserIds = const [],
    RunConstraints constraints = const RunConstraints(),
    Map<String, int> genderCounts = const {},
  }) {
    final start = startTime ?? DateTime.now().add(const Duration(hours: 2));
    return Run(
      id: 'run-1',
      runClubId: 'club-1',
      startTime: start,
      endTime: start.add(const Duration(hours: 1)),
      meetingPoint: 'Start line',
      distanceKm: 5.0,
      pace: PaceLevel.easy,
      capacityLimit: capacityLimit,
      description: '',
      priceInPaise: 0,
      signedUpUserIds: signedUpUserIds,
      attendedUserIds: attendedUserIds,
      waitlistUserIds: waitlistUserIds,
      constraints: constraints,
      genderCounts: genderCounts,
    );
  }

  AppUser buildUser({
    String uid = 'user-1',
    int birthYear = 1990, // ~35 y/o — well within any reasonable constraint
    Gender gender = Gender.man,
  }) {
    return AppUser(
      uid: uid,
      name: 'Test Runner',
      dateOfBirth: DateTime(birthYear, 6, 15),
      gender: gender,
      sexualOrientation: SexualOrientation.straight,
      phoneNumber: '+910000000000',
      profileComplete: true,
      interestedInGenders: const [Gender.woman],
    );
  }

  // ── #11: Attended ──────────────────────────────────────────────────────────

  test('#11 eligibilityFor returns Attended when uid in attendedUserIds', () {
    final user = buildUser();
    final run = buildRun(attendedUserIds: [user.uid]);
    expect(run.eligibilityFor(user), isA<Attended>());
  });

  // ── #12: AlreadySignedUp ──────────────────────────────────────────────────

  test('#12 eligibilityFor returns AlreadySignedUp when signed up, not attended', () {
    final user = buildUser();
    final run = buildRun(signedUpUserIds: [user.uid]);
    expect(run.eligibilityFor(user), isA<AlreadySignedUp>());
  });

  // ── #13: RunPast ──────────────────────────────────────────────────────────

  test('#13 eligibilityFor returns RunPast for a past run the user never signed up for', () {
    final user = buildUser();
    final run = buildRun(
      startTime: DateTime.now().subtract(const Duration(hours: 2)),
    );
    expect(run.eligibilityFor(user), isA<RunPast>());
  });

  // ── #14: OnWaitlist ───────────────────────────────────────────────────────

  test('#14 eligibilityFor returns OnWaitlist when on waitlist (future, not full)', () {
    final user = buildUser();
    final run = buildRun(waitlistUserIds: [user.uid]);
    expect(run.eligibilityFor(user), isA<OnWaitlist>());
  });

  // ── #15: AgeTooYoung ─────────────────────────────────────────────────────

  test('#15 eligibilityFor returns AgeTooYoung when user age < minAge', () {
    // User born 5 years ago → age ~5; minAge = 18
    final user = buildUser(birthYear: DateTime.now().year - 5);
    final run = buildRun(
      constraints: const RunConstraints(minAge: 18, maxAge: 99),
    );
    final result = run.eligibilityFor(user);
    expect(result, isA<AgeTooYoung>());
    expect((result as AgeTooYoung).minAge, 18);
  });

  // ── #16: AgeTooOld ───────────────────────────────────────────────────────

  test('#16 eligibilityFor returns AgeTooOld when user age > maxAge', () {
    // User born 60 years ago → age ~60; maxAge = 40
    final user = buildUser(birthYear: DateTime.now().year - 60);
    final run = buildRun(
      constraints: const RunConstraints(minAge: 0, maxAge: 40),
    );
    final result = run.eligibilityFor(user);
    expect(result, isA<AgeTooOld>());
    expect((result as AgeTooOld).maxAge, 40);
  });

  // ── #17: GenderCapacityReached ────────────────────────────────────────────

  test('#17 eligibilityFor returns GenderCapacityReached when gender slot is full', () {
    final user = buildUser(gender: Gender.man);
    final run = buildRun(
      constraints: const RunConstraints(maxMen: 2),
      genderCounts: {'man': 2}, // at cap
    );
    expect(run.eligibilityFor(user), isA<GenderCapacityReached>());
  });

  test('eligible when gender count is below cap', () {
    final user = buildUser(gender: Gender.man);
    final run = buildRun(
      constraints: const RunConstraints(maxMen: 5),
      genderCounts: {'man': 4},
    );
    expect(run.eligibilityFor(user), isA<Eligible>());
  });

  // ── #18: RunFull ──────────────────────────────────────────────────────────

  test('#18 eligibilityFor returns RunFull when at capacity (user meets all criteria)', () {
    final user = buildUser();
    final run = buildRun(
      capacityLimit: 2,
      signedUpUserIds: ['other-1', 'other-2'],
    );
    expect(run.eligibilityFor(user), isA<RunFull>());
  });

  // ── #19: Eligible ─────────────────────────────────────────────────────────

  test('#19 eligibilityFor returns Eligible for a future, non-full, qualifying run', () {
    final user = buildUser();
    final run = buildRun(); // all defaults: future, 20 capacity, 0 sign-ups
    expect(run.eligibilityFor(user), isA<Eligible>());
  });

  // ── #20: statusFor maps every eligibility to RunSignUpStatus ─────────────

  group('#20 statusFor', () {
    test('Attended → RunSignUpStatus.attended', () {
      final user = buildUser();
      final run = buildRun(attendedUserIds: [user.uid]);
      expect(run.statusFor(user), RunSignUpStatus.attended);
    });

    test('AlreadySignedUp → RunSignUpStatus.signedUp', () {
      final user = buildUser();
      final run = buildRun(signedUpUserIds: [user.uid]);
      expect(run.statusFor(user), RunSignUpStatus.signedUp);
    });

    test('RunPast → RunSignUpStatus.past', () {
      final user = buildUser();
      final run = buildRun(
        startTime: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(run.statusFor(user), RunSignUpStatus.past);
    });

    test('OnWaitlist → RunSignUpStatus.waitlisted', () {
      final user = buildUser();
      final run = buildRun(waitlistUserIds: [user.uid]);
      expect(run.statusFor(user), RunSignUpStatus.waitlisted);
    });

    test('RunFull → RunSignUpStatus.full', () {
      final user = buildUser();
      final run = buildRun(
        capacityLimit: 1,
        signedUpUserIds: ['other-1'],
      );
      expect(run.statusFor(user), RunSignUpStatus.full);
    });

    test('Eligible → RunSignUpStatus.eligible', () {
      final user = buildUser();
      final run = buildRun();
      expect(run.statusFor(user), RunSignUpStatus.eligible);
    });

    test('GenderCapacityReached → RunSignUpStatus.ineligible', () {
      final user = buildUser(gender: Gender.man);
      final run = buildRun(
        constraints: const RunConstraints(maxMen: 1),
        genderCounts: {'man': 1},
      );
      expect(run.statusFor(user), RunSignUpStatus.ineligible);
    });
  });
}
