import 'package:catch_dating_app/profile/presentation/edit_profile_form_data.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

void main() {
  test('EditProfileFormData maps to and from UserProfile cleanly', () {
    final user =
        buildUser(
          uid: 'runner-42',
          name: 'Asha',
          email: 'asha@example.com',
        ).copyWith(
          bio: 'Morning runner and coffee person.',
          phoneNumber: '+919876543210',
          interestedInGenders: const [Gender.man, Gender.nonBinary],
          minAgePreference: 25,
          maxAgePreference: 34,
          height: 168,
          occupation: 'Designer',
          company: 'Catch',
          education: EducationLevel.masters,
          relationshipGoal: RelationshipGoal.relationship,
          drinking: DrinkingHabit.socially,
          smoking: SmokingHabit.never,
          workout: WorkoutFrequency.often,
          diet: DietaryPreference.vegetarian,
          children: ChildrenStatus.wantSomeday,
          religion: Religion.hindu,
          languages: const [Language.english, Language.hindi],
        );

    final formData = EditProfileFormData.fromUserProfile(user);
    final updatedUser = formData.applyTo(user.copyWith(name: 'Old name'));

    expect(updatedUser.name, 'Asha');
    expect(updatedUser.bio, 'Morning runner and coffee person.');
    expect(updatedUser.phoneNumber, '+919876543210');
    expect(updatedUser.interestedInGenders, [Gender.man, Gender.nonBinary]);
    expect(updatedUser.minAgePreference, 25);
    expect(updatedUser.maxAgePreference, 34);
    expect(updatedUser.height, 168);
    expect(updatedUser.occupation, 'Designer');
    expect(updatedUser.company, 'Catch');
    expect(updatedUser.education, EducationLevel.masters);
    expect(updatedUser.relationshipGoal, RelationshipGoal.relationship);
    expect(updatedUser.drinking, DrinkingHabit.socially);
    expect(updatedUser.smoking, SmokingHabit.never);
    expect(updatedUser.workout, WorkoutFrequency.often);
    expect(updatedUser.diet, DietaryPreference.vegetarian);
    expect(updatedUser.children, ChildrenStatus.wantSomeday);
    expect(updatedUser.religion, Religion.hindu);
    expect(updatedUser.languages, [Language.english, Language.hindi]);
  });
}
