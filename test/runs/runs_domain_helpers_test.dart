import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:catch_dating_app/runs/domain/pace_level_theme.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/domain/run_constraints.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RunConstraints.maxForGender', () {
    const constraints = RunConstraints(maxMen: 8, maxWomen: 10);

    test('returns the configured cap for men', () {
      expect(constraints.maxForGender(Gender.man), 8);
    });

    test('returns the configured cap for women', () {
      expect(constraints.maxForGender(Gender.woman), 10);
    });

    test('returns null for uncapped genders', () {
      expect(constraints.maxForGender(Gender.nonBinary), isNull);
      expect(constraints.maxForGender(Gender.other), isNull);
    });
  });

  group('RunConstraints display helpers', () {
    test('detects whether a run has requirements', () {
      expect(const RunConstraints().hasRequirements, isFalse);
      expect(const RunConstraints(minAge: 21).hasRequirements, isTrue);
    });

    test('builds requirement labels for each supported case', () {
      expect(
        const RunConstraints(
          minAge: 21,
          maxAge: 35,
          maxMen: 8,
          maxWomen: 10,
        ).requirementLabels,
        ['Age 21–35', 'Max 8 men', 'Max 10 women'],
      );
      expect(const RunConstraints(minAge: 21).requirementLabels, ['21+ years']);
      expect(const RunConstraints(maxAge: 35).requirementLabels, [
        'Up to 35 years',
      ]);
    });
  });

  group('Run derived helpers', () {
    test('exposes spots remaining and requirement presence', () {
      final run = Run(
        id: 'run-1',
        runClubId: 'club-1',
        startTime: DateTime.now().add(const Duration(hours: 1)),
        endTime: DateTime.now().add(const Duration(hours: 2)),
        meetingPoint: 'Carter Road',
        distanceKm: 5,
        pace: PaceLevel.easy,
        capacityLimit: 2,
        description: 'A run',
        priceInPaise: 0,
        signedUpUserIds: const ['runner-1', 'runner-2', 'runner-3'],
        constraints: const RunConstraints(minAge: 21),
      );

      expect(run.spotsRemaining, 0);
      expect(run.hasRequirements, isTrue);
    });
  });

  group('PaceLevel.colors', () {
    test('maps every pace to a distinct semantic palette', () {
      expect(PaceLevel.easy.colors.bg, const Color(0xFFDCFCE7));
      expect(PaceLevel.easy.colors.fg, const Color(0xFF166534));
      expect(PaceLevel.moderate.colors.bg, const Color(0xFFDBEAFE));
      expect(PaceLevel.moderate.colors.fg, const Color(0xFF1E40AF));
      expect(PaceLevel.fast.colors.bg, const Color(0xFFFEF3C7));
      expect(PaceLevel.fast.colors.fg, const Color(0xFF92400E));
      expect(PaceLevel.competitive.colors.bg, const Color(0xFFFFE4E6));
      expect(PaceLevel.competitive.colors.fg, const Color(0xFF9F1239));
    });
  });
}
