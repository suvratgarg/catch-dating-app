import 'package:catch_dating_app/app_user/domain/app_user.dart';

class EditProfileFormData {
  const EditProfileFormData({
    required this.name,
    required this.dateOfBirth,
    required this.bio,
    required this.gender,
    required this.sexualOrientation,
    required this.phoneNumber,
    required this.interestedInGenders,
    required this.minAgePreference,
    required this.maxAgePreference,
    this.height,
    this.occupation,
    this.company,
    this.education,
    this.relationshipGoal,
    this.drinking,
    this.smoking,
    this.workout,
    this.diet,
    this.children,
    this.religion,
    this.languages = const [],
  });

  factory EditProfileFormData.fromAppUser(AppUser user) => EditProfileFormData(
    name: user.name,
    dateOfBirth: user.dateOfBirth,
    bio: user.bio,
    gender: user.gender,
    sexualOrientation: user.sexualOrientation,
    phoneNumber: user.phoneNumber,
    interestedInGenders: user.interestedInGenders,
    minAgePreference: user.minAgePreference,
    maxAgePreference: user.maxAgePreference,
    height: user.height,
    occupation: user.occupation,
    company: user.company,
    education: user.education,
    relationshipGoal: user.relationshipGoal,
    drinking: user.drinking,
    smoking: user.smoking,
    workout: user.workout,
    diet: user.diet,
    children: user.children,
    religion: user.religion,
    languages: user.languages,
  );

  final String name;
  final DateTime dateOfBirth;
  final String bio;
  final Gender gender;
  final SexualOrientation sexualOrientation;
  final String phoneNumber;
  final List<Gender> interestedInGenders;
  final int minAgePreference;
  final int maxAgePreference;
  final int? height;
  final String? occupation;
  final String? company;
  final EducationLevel? education;
  final RelationshipGoal? relationshipGoal;
  final DrinkingHabit? drinking;
  final SmokingHabit? smoking;
  final WorkoutFrequency? workout;
  final DietaryPreference? diet;
  final ChildrenStatus? children;
  final Religion? religion;
  final List<Language> languages;

  AppUser applyTo(AppUser user) => user.copyWith(
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
  );
}
