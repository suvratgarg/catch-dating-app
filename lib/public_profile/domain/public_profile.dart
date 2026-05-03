import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
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

    // Location
    @JsonKey(unknownEnumValue: null) IndianCity? city,
    double? latitude,
    double? longitude,

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

    // Running identity
    @Default(300) int paceMinSecsPerKm,
    @Default(420) int paceMaxSecsPerKm,
    @Default([]) List<PreferredDistance> preferredDistances,
    @Default([]) List<RunReason> runningReasons,
  }) = _PublicProfile;

  factory PublicProfile.fromJson(Map<String, dynamic> json) =>
      _$PublicProfileFromJson(json);
}

/// Builds a [PublicProfile] from a [UserProfile], projecting only the fields
/// that are visible to other users.
///
/// This is still useful on the client for previews and tests, but the
/// persisted `publicProfiles/{uid}` document is owned by Cloud Functions.
PublicProfile publicProfileFromUserProfile(UserProfile user) => PublicProfile(
  uid: user.uid,
  name: user.name,
  age: user.age,
  bio: user.bio,
  gender: user.gender,
  photoUrls: user.photoUrls,
  city: user.city,
  latitude: user.latitude,
  longitude: user.longitude,
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
  paceMinSecsPerKm: user.paceMinSecsPerKm,
  paceMaxSecsPerKm: user.paceMaxSecsPerKm,
  preferredDistances: user.preferredDistances,
  runningReasons: user.runningReasons,
);
