import 'package:catch_dating_app/app_user/domain/profile_validation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('profile_validation', () {
    test('calculateAge handles birthdays before and after today', () {
      final today = DateTime(2026, 4, 22);

      expect(calculateAge(DateTime(1996, 4, 22), today: today), 30);
      expect(calculateAge(DateTime(1996, 4, 23), today: today), 29);
    });

    test('uses calendar arithmetic for the latest allowed date of birth', () {
      final today = DateTime(2026, 4, 22, 17, 30);

      expect(latestAllowedDateOfBirth(today: today), DateTime(2008, 4, 22));
      expect(isAtLeastAge(DateTime(2008, 4, 22), today: today), isTrue);
      expect(isAtLeastAge(DateTime(2008, 4, 23), today: today), isFalse);
    });

    test('normalizes reversed and out-of-range age preferences', () {
      expect(
        normalizeAgePreferenceRange(minAgePreference: 40, maxAgePreference: 20),
        (minAge: 20, maxAge: 40),
      );
      expect(
        normalizeAgePreferenceRange(
          minAgePreference: 12,
          maxAgePreference: 120,
        ),
        (minAge: 18, maxAge: 99),
      );
    });

    test('validates age preference inputs for bounds and ordering', () {
      expect(
        validateAgePreferenceInput('120', otherValue: '', isMinimumField: true),
        'Enter an age between 18 and 99',
      );
      expect(
        validateAgePreferenceInput(
          '40',
          otherValue: '20',
          isMinimumField: true,
        ),
        'Min age must be less than or equal to max age',
      );
      expect(
        validateAgePreferenceInput(
          '20',
          otherValue: '40',
          isMinimumField: false,
        ),
        'Max age must be greater than or equal to min age',
      );
    });
  });
}
