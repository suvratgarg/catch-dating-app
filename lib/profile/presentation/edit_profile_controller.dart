import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/app_user/domain/app_user.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'edit_profile_controller.g.dart';

@riverpod
class EditProfileController extends _$EditProfileController {
  static final submitMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> submit({
    required String name,
    required DateTime dateOfBirth,
    required String bio,
    required Gender gender,
    required SexualOrientation sexualOrientation,
    required String phoneNumber,
    required List<Gender> interestedInGenders,
    required int minAgePreference,
    required int maxAgePreference,
    int? height,
    String? occupation,
    String? company,
    EducationLevel? education,
    RelationshipGoal? relationshipGoal,
    DrinkingHabit? drinking,
    SmokingHabit? smoking,
    WorkoutFrequency? workout,
    DietaryPreference? diet,
    ChildrenStatus? children,
    Religion? religion,
    List<Language> languages = const [],
  }) async {
    final current = ref.read(appUserStreamProvider).asData?.value;
    if (current == null) {
      throw StateError('User profile not loaded. Please try again.');
    }
    await ref.read(appUserRepositoryProvider).setAppUser(
      appUser: current.copyWith(
        name: name,
        dateOfBirth: dateOfBirth,
        bio: bio,
        gender: gender,
        sexualOrientation: sexualOrientation,
        phoneNumber: phoneNumber,
        interestedInGenders: interestedInGenders,
        minAgePreference: minAgePreference,
        maxAgePreference: maxAgePreference,
        height: height,
        occupation: occupation,
        company: company,
        education: education,
        relationshipGoal: relationshipGoal,
        drinking: drinking,
        smoking: smoking,
        workout: workout,
        diet: diet,
        children: children,
        religion: religion,
        languages: languages,
      ),
    );
  }
}
