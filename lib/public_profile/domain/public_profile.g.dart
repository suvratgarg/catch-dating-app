// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PublicProfile _$PublicProfileFromJson(
  Map<String, dynamic> json,
) => _PublicProfile(
  uid: json['uid'] as String,
  name: json['name'] as String,
  age: (json['age'] as num).toInt(),
  bio: json['bio'] as String,
  gender: $enumDecode(_$GenderEnumMap, json['gender']),
  photoUrls:
      (json['photoUrls'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  city: $enumDecodeNullable(_$IndianCityEnumMap, json['city']),
  latitude: (json['latitude'] as num?)?.toDouble(),
  longitude: (json['longitude'] as num?)?.toDouble(),
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
);

Map<String, dynamic> _$PublicProfileToJson(
  _PublicProfile instance,
) => <String, dynamic>{
  'name': instance.name,
  'age': instance.age,
  'bio': instance.bio,
  'gender': _$GenderEnumMap[instance.gender]!,
  'photoUrls': instance.photoUrls,
  'city': _$IndianCityEnumMap[instance.city],
  'latitude': instance.latitude,
  'longitude': instance.longitude,
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
};

const _$GenderEnumMap = {
  Gender.man: 'man',
  Gender.woman: 'woman',
  Gender.nonBinary: 'nonBinary',
  Gender.other: 'other',
};

const _$IndianCityEnumMap = {
  IndianCity.mumbai: 'mumbai',
  IndianCity.delhi: 'delhi',
  IndianCity.bangalore: 'bangalore',
  IndianCity.hyderabad: 'hyderabad',
  IndianCity.chennai: 'chennai',
  IndianCity.kolkata: 'kolkata',
  IndianCity.pune: 'pune',
  IndianCity.ahmedabad: 'ahmedabad',
  IndianCity.indore: 'indore',
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
