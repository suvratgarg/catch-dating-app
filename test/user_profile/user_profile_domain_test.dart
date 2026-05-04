import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  UserProfile buildUser({required DateTime dateOfBirth}) => UserProfile(
    uid: 'user-1',
    name: 'Runner',
    dateOfBirth: dateOfBirth,
    gender: Gender.man,
    phoneNumber: '+910000000000',
    profileComplete: true,
    interestedInGenders: const [Gender.woman],
  );

  group('UserProfile.age', () {
    test('#21 birthday earlier this year — full year counted', () {
      final now = DateTime.now();
      // DOB = Jan 1, (now.year - 30). Birthday has already passed this year.
      final dob = DateTime(now.year - 30, 1, 1);
      final user = buildUser(dateOfBirth: dob);
      expect(user.age, 30);
    });

    test('#22 birthday later this year — one year subtracted', () {
      final now = DateTime.now();
      // DOB = Dec 31, (now.year - 30). Birthday not yet reached.
      final dob = DateTime(now.year - 30, 12, 31);
      final user = buildUser(dateOfBirth: dob);
      // If today is before Dec 31, age is still 29.
      final expectedAge = now.isBefore(DateTime(now.year, 12, 31)) ? 29 : 30;
      expect(user.age, expectedAge);
    });

    test('#23 exact birthday today — age is exact integer', () {
      final now = DateTime.now();
      // DOB on today's month/day, 25 years ago.
      final dob = DateTime(now.year - 25, now.month, now.day);
      final user = buildUser(dateOfBirth: dob);
      expect(user.age, 25);
    });
  });

  test('toJson omits uid because Firestore stores it in the document path', () {
    final user = buildUser(dateOfBirth: DateTime(1995, 6, 15));

    expect(user.toJson().containsKey('uid'), isFalse);
  });
}
