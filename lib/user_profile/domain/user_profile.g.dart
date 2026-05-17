// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => _UserProfile(
  uid: json['uid'] as String,
  name: json['name'] as String,
  firstName: json['firstName'] as String? ?? '',
  lastName: json['lastName'] as String? ?? '',
  displayName: json['displayName'] as String? ?? '',
  dateOfBirth: const TimestampConverter().fromJson(
    json['dateOfBirth'] as Timestamp,
  ),
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  phoneNumber: json['phoneNumber'] as String,
  profileComplete: json['profileComplete'] as bool,
  email: json['email'] as String? ?? '',
  instagramHandle: json['instagramHandle'] as String?,
  profilePrompts:
      (json['profilePrompts'] as List<dynamic>?)
          ?.map((e) => ProfilePromptAnswer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  photoThumbnailUrls:
      (json['photoThumbnailUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      const [],
  photoPrompts:
      (json['photoPrompts'] as List<dynamic>?)
          ?.map((e) => PhotoPromptAnswer.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  profilePhotos:
      (json['profilePhotos'] as List<dynamic>?)
          ?.map((e) => ProfilePhoto.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  city: json['city'] as String?,
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
  interestedInGenders:
      (json['interestedInGenders'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$GenderEnumMap, e))
          .toList() ??
      const [],
  minAgePreference: (json['minAgePreference'] as num?)?.toInt() ?? 18,
  maxAgePreference:
      (json['maxAgePreference'] as num?)?.toInt() ?? maximumPreferredMatchAge,
  height: (json['height'] as num?)?.toInt(),
  occupation: json['occupation'] as String?,
  company: json['company'] as String?,
  education: $enumDecodeNullable(_$EducationLevelEnumMap, json['education']),
  religion: $enumDecodeNullable(_$ReligionEnumMap, json['religion']),
  languages:
      (json['languages'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$LanguageEnumMap, e))
          .toList() ??
      const [],
  relationshipGoal: $enumDecodeNullable(
    _$RelationshipGoalEnumMap,
    json['relationshipGoal'],
  ),
  drinking: $enumDecodeNullable(_$DrinkingHabitEnumMap, json['drinking']),
  smoking: $enumDecodeNullable(_$SmokingHabitEnumMap, json['smoking']),
  workout: $enumDecodeNullable(_$WorkoutFrequencyEnumMap, json['workout']),
  diet: $enumDecodeNullable(_$DietaryPreferenceEnumMap, json['diet']),
  children: $enumDecodeNullable(_$ChildrenStatusEnumMap, json['children']),
  paceMinSecsPerKm: (json['paceMinSecsPerKm'] as num?)?.toInt() ?? 300,
  paceMaxSecsPerKm: (json['paceMaxSecsPerKm'] as num?)?.toInt() ?? 420,
  preferredDistances:
      (json['preferredDistances'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$PreferredDistanceEnumMap, e))
          .toList() ??
      const [],
  runningReasons:
      (json['runningReasons'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$RunReasonEnumMap, e))
          .toList() ??
      const [],
  preferredRunTimes:
      (json['preferredRunTimes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$PreferredRunTimeEnumMap, e))
          .toList() ??
      const [],
  prefsNewCatches: json['prefsNewCatches'] as bool? ?? true,
  prefsMessages: json['prefsMessages'] as bool? ?? true,
  prefsRunReminders: json['prefsRunReminders'] as bool? ?? true,
  prefsRunStatusUpdates: json['prefsRunStatusUpdates'] as bool? ?? true,
  prefsClubUpdates: json['prefsClubUpdates'] as bool? ?? true,
  prefsWeeklyDigest: json['prefsWeeklyDigest'] as bool? ?? false,
  prefsShowOnMap: json['prefsShowOnMap'] as bool? ?? true,
);

Map<String, dynamic> _$UserProfileToJson(
  _UserProfile instance,
) => <String, dynamic>{
  'name': instance.name,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'displayName': instance.displayName,
  'dateOfBirth': const TimestampConverter().toJson(instance.dateOfBirth),
  'gender': _$GenderEnumMap[instance.gender]!,
  'phoneNumber': instance.phoneNumber,
  'profileComplete': instance.profileComplete,
  'email': instance.email,
  'instagramHandle': instance.instagramHandle,
  'profilePrompts': instance.profilePrompts.map((e) => e.toJson()).toList(),
  'photoUrls': instance.photoUrls,
  'photoThumbnailUrls': instance.photoThumbnailUrls,
  'photoPrompts': instance.photoPrompts.map((e) => e.toJson()).toList(),
  'profilePhotos': instance.profilePhotos.map((e) => e.toJson()).toList(),
  'city': instance.city,
  'latitude': instance.latitude,
  'longitude': instance.longitude,
  'interestedInGenders': instance.interestedInGenders
      .map((e) => _$GenderEnumMap[e]!)
      .toList(),
  'minAgePreference': instance.minAgePreference,
  'maxAgePreference': instance.maxAgePreference,
  'height': instance.height,
  'occupation': instance.occupation,
  'company': instance.company,
  'education': _$EducationLevelEnumMap[instance.education],
  'religion': _$ReligionEnumMap[instance.religion],
  'languages': instance.languages.map((e) => _$LanguageEnumMap[e]!).toList(),
  'relationshipGoal': _$RelationshipGoalEnumMap[instance.relationshipGoal],
  'drinking': _$DrinkingHabitEnumMap[instance.drinking],
  'smoking': _$SmokingHabitEnumMap[instance.smoking],
  'workout': _$WorkoutFrequencyEnumMap[instance.workout],
  'diet': _$DietaryPreferenceEnumMap[instance.diet],
  'children': _$ChildrenStatusEnumMap[instance.children],
  'paceMinSecsPerKm': instance.paceMinSecsPerKm,
  'paceMaxSecsPerKm': instance.paceMaxSecsPerKm,
  'preferredDistances': instance.preferredDistances
      .map((e) => _$PreferredDistanceEnumMap[e]!)
      .toList(),
  'runningReasons': instance.runningReasons
      .map((e) => _$RunReasonEnumMap[e]!)
      .toList(),
  'preferredRunTimes': instance.preferredRunTimes
      .map((e) => _$PreferredRunTimeEnumMap[e]!)
      .toList(),
  'prefsNewCatches': instance.prefsNewCatches,
  'prefsMessages': instance.prefsMessages,
  'prefsRunReminders': instance.prefsRunReminders,
  'prefsRunStatusUpdates': instance.prefsRunStatusUpdates,
  'prefsClubUpdates': instance.prefsClubUpdates,
  'prefsWeeklyDigest': instance.prefsWeeklyDigest,
  'prefsShowOnMap': instance.prefsShowOnMap,
};

const _$GenderEnumMap = {
  Gender.man: 'man',
  Gender.woman: 'woman',
  Gender.nonBinary: 'nonBinary',
  Gender.other: 'other',
};

const _$EducationLevelEnumMap = {
  EducationLevel.highSchool: 'highSchool',
  EducationLevel.someCollege: 'someCollege',
  EducationLevel.bachelors: 'bachelors',
  EducationLevel.masters: 'masters',
  EducationLevel.phd: 'phd',
  EducationLevel.tradeSchool: 'tradeSchool',
  EducationLevel.other: 'other',
};

const _$ReligionEnumMap = {
  Religion.hindu: 'hindu',
  Religion.muslim: 'muslim',
  Religion.christian: 'christian',
  Religion.sikh: 'sikh',
  Religion.jain: 'jain',
  Religion.buddhist: 'buddhist',
  Religion.other: 'other',
  Religion.nonReligious: 'nonReligious',
};

const _$LanguageEnumMap = {
  Language.english: 'english',
  Language.hindi: 'hindi',
  Language.marathi: 'marathi',
  Language.tamil: 'tamil',
  Language.telugu: 'telugu',
  Language.kannada: 'kannada',
  Language.bengali: 'bengali',
  Language.gujarati: 'gujarati',
  Language.punjabi: 'punjabi',
  Language.malayalam: 'malayalam',
  Language.odia: 'odia',
  Language.other: 'other',
};

const _$RelationshipGoalEnumMap = {
  RelationshipGoal.relationship: 'relationship',
  RelationshipGoal.casual: 'casual',
  RelationshipGoal.marriage: 'marriage',
  RelationshipGoal.friendship: 'friendship',
  RelationshipGoal.unsure: 'unsure',
};

const _$DrinkingHabitEnumMap = {
  DrinkingHabit.never: 'never',
  DrinkingHabit.socially: 'socially',
  DrinkingHabit.often: 'often',
};

const _$SmokingHabitEnumMap = {
  SmokingHabit.never: 'never',
  SmokingHabit.occasionally: 'occasionally',
  SmokingHabit.often: 'often',
};

const _$WorkoutFrequencyEnumMap = {
  WorkoutFrequency.never: 'never',
  WorkoutFrequency.sometimes: 'sometimes',
  WorkoutFrequency.often: 'often',
  WorkoutFrequency.everyday: 'everyday',
};

const _$DietaryPreferenceEnumMap = {
  DietaryPreference.omnivore: 'omnivore',
  DietaryPreference.vegetarian: 'vegetarian',
  DietaryPreference.vegan: 'vegan',
  DietaryPreference.jain: 'jain',
  DietaryPreference.other: 'other',
};

const _$ChildrenStatusEnumMap = {
  ChildrenStatus.dontHave: 'dontHave',
  ChildrenStatus.haveWantMore: 'haveWantMore',
  ChildrenStatus.haveNoMore: 'haveNoMore',
  ChildrenStatus.wantSomeday: 'wantSomeday',
  ChildrenStatus.dontWant: 'dontWant',
};

const _$PreferredDistanceEnumMap = {
  PreferredDistance.fiveK: 'fiveK',
  PreferredDistance.tenK: 'tenK',
  PreferredDistance.halfMarathon: 'halfMarathon',
  PreferredDistance.marathon: 'marathon',
};

const _$RunReasonEnumMap = {
  RunReason.fitness: 'fitness',
  RunReason.community: 'community',
  RunReason.mindfulness: 'mindfulness',
  RunReason.challenge: 'challenge',
  RunReason.weightLoss: 'weightLoss',
  RunReason.raceTraining: 'raceTraining',
  RunReason.social: 'social',
};

const _$PreferredRunTimeEnumMap = {
  PreferredRunTime.earlyMorning: 'earlyMorning',
  PreferredRunTime.morning: 'morning',
  PreferredRunTime.afternoon: 'afternoon',
  PreferredRunTime.evening: 'evening',
  PreferredRunTime.night: 'night',
};
