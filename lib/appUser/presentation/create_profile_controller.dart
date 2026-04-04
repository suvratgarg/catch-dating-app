import 'package:catch_dating_app/appUser/data/app_user_repository.dart';
import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_profile_controller.g.dart';

@riverpod
class CreateProfileController extends _$CreateProfileController {
  static final submitMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> submit({
    required String email,
    required String name,
    required DateTime dateOfBirth,
    required String bio,
    required Gender gender,
    required SexualOrientation sexualOrientation,
    required String phoneNumber,
    // Optional profile fields
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
    final uid = ref.read(uidProvider).asData?.value ?? '';
    await ref.read(appUserRepositoryProvider).setAppUser(
      appUser: AppUser(
        uid: uid,
        email: email,
        name: name,
        dateOfBirth: dateOfBirth,
        bio: bio,
        gender: gender,
        sexualOrientation: sexualOrientation,
        phoneNumber: phoneNumber,
        profileComplete: false,
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
