import 'package:catch_dating_app/appUser/domain/app_user.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'public_profile.freezed.dart';
part 'public_profile.g.dart';

@freezed
abstract class PublicProfile with _$PublicProfile {
  const factory PublicProfile({
    @JsonKey(includeToJson: false) required String uid,
    required String name,
    required int age,
    required String bio,
    required Gender gender,
    @Default([]) List<String> photoUrls,

    // Background
    int? height,
    String? occupation,
    String? company,
    @JsonKey(unknownEnumValue: null) EducationLevel? education,
    @JsonKey(unknownEnumValue: null) Religion? religion,
    @Default([]) List<Language> languages,

    // Intentions
    @JsonKey(unknownEnumValue: null) RelationshipGoal? relationshipGoal,

    // Lifestyle
    @JsonKey(unknownEnumValue: null) DrinkingHabit? drinking,
    @JsonKey(unknownEnumValue: null) SmokingHabit? smoking,
    @JsonKey(unknownEnumValue: null) WorkoutFrequency? workout,
    @JsonKey(unknownEnumValue: null) DietaryPreference? diet,
    @JsonKey(unknownEnumValue: null) ChildrenStatus? children,
  }) = _PublicProfile;

  factory PublicProfile.fromJson(Map<String, dynamic> json) =>
      _$PublicProfileFromJson(json);
}

/// Builds a [PublicProfile] from an [AppUser], projecting only the fields
/// that are visible to other users. Call this whenever the app user's profile
/// is created or edited to keep the two documents in sync.
PublicProfile publicProfileFromAppUser(AppUser user) => PublicProfile(
      uid: user.uid,
      name: user.name,
      age: user.age,
      bio: user.bio,
      gender: user.gender,
      photoUrls: user.photoUrls,
      height: user.height,
      occupation: user.occupation,
      company: user.company,
      education: user.education,
      religion: user.religion,
      languages: user.languages,
      relationshipGoal: user.relationshipGoal,
      drinking: user.drinking,
      smoking: user.smoking,
      workout: user.workout,
      diet: user.diet,
      children: user.children,
    );
