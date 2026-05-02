// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

// Core (required at sign-up)
@JsonKey(includeToJson: false) String get uid; String get name;@TimestampConverter() DateTime get dateOfBirth; Gender get gender; SexualOrientation get sexualOrientation; String get phoneNumber; bool get profileComplete;// Optional profile/contact field. Authentication is phone-only.
 String get email; String get bio;// Photos
 List<String> get photoUrls;// Location
@JsonKey(unknownEnumValue: null) IndianCity? get city;// Matching preferences
 List<String> get joinedRunClubIds; List<String> get savedRunIds; List<Gender> get interestedInGenders; int get minAgePreference; int get maxAgePreference;// Background (optional)
 int? get height; String? get occupation; String? get company;@JsonKey(unknownEnumValue: null) EducationLevel? get education;@JsonKey(unknownEnumValue: null) Religion? get religion; List<Language> get languages;// Intentions (optional)
@JsonKey(unknownEnumValue: null) RelationshipGoal? get relationshipGoal;// Lifestyle (optional)
@JsonKey(unknownEnumValue: null) DrinkingHabit? get drinking;@JsonKey(unknownEnumValue: null) SmokingHabit? get smoking;@JsonKey(unknownEnumValue: null) WorkoutFrequency? get workout;@JsonKey(unknownEnumValue: null) DietaryPreference? get diet;@JsonKey(unknownEnumValue: null) ChildrenStatus? get children;// Running preferences (set during onboarding)
 int get paceMinSecsPerKm; int get paceMaxSecsPerKm; List<PreferredDistance> get preferredDistances; List<RunReason> get runningReasons;// Notification / discovery preferences
 bool get prefsNewCatches; bool get prefsRunReminders; bool get prefsWeeklyDigest; bool get prefsShowOnMap;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.sexualOrientation, sexualOrientation) || other.sexualOrientation == sexualOrientation)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.profileComplete, profileComplete) || other.profileComplete == profileComplete)&&(identical(other.email, email) || other.email == email)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other.photoUrls, photoUrls)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other.joinedRunClubIds, joinedRunClubIds)&&const DeepCollectionEquality().equals(other.savedRunIds, savedRunIds)&&const DeepCollectionEquality().equals(other.interestedInGenders, interestedInGenders)&&(identical(other.minAgePreference, minAgePreference) || other.minAgePreference == minAgePreference)&&(identical(other.maxAgePreference, maxAgePreference) || other.maxAgePreference == maxAgePreference)&&(identical(other.height, height) || other.height == height)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.company, company) || other.company == company)&&(identical(other.education, education) || other.education == education)&&(identical(other.religion, religion) || other.religion == religion)&&const DeepCollectionEquality().equals(other.languages, languages)&&(identical(other.relationshipGoal, relationshipGoal) || other.relationshipGoal == relationshipGoal)&&(identical(other.drinking, drinking) || other.drinking == drinking)&&(identical(other.smoking, smoking) || other.smoking == smoking)&&(identical(other.workout, workout) || other.workout == workout)&&(identical(other.diet, diet) || other.diet == diet)&&(identical(other.children, children) || other.children == children)&&(identical(other.paceMinSecsPerKm, paceMinSecsPerKm) || other.paceMinSecsPerKm == paceMinSecsPerKm)&&(identical(other.paceMaxSecsPerKm, paceMaxSecsPerKm) || other.paceMaxSecsPerKm == paceMaxSecsPerKm)&&const DeepCollectionEquality().equals(other.preferredDistances, preferredDistances)&&const DeepCollectionEquality().equals(other.runningReasons, runningReasons)&&(identical(other.prefsNewCatches, prefsNewCatches) || other.prefsNewCatches == prefsNewCatches)&&(identical(other.prefsRunReminders, prefsRunReminders) || other.prefsRunReminders == prefsRunReminders)&&(identical(other.prefsWeeklyDigest, prefsWeeklyDigest) || other.prefsWeeklyDigest == prefsWeeklyDigest)&&(identical(other.prefsShowOnMap, prefsShowOnMap) || other.prefsShowOnMap == prefsShowOnMap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,name,dateOfBirth,gender,sexualOrientation,phoneNumber,profileComplete,email,bio,const DeepCollectionEquality().hash(photoUrls),city,const DeepCollectionEquality().hash(joinedRunClubIds),const DeepCollectionEquality().hash(savedRunIds),const DeepCollectionEquality().hash(interestedInGenders),minAgePreference,maxAgePreference,height,occupation,company,education,religion,const DeepCollectionEquality().hash(languages),relationshipGoal,drinking,smoking,workout,diet,children,paceMinSecsPerKm,paceMaxSecsPerKm,const DeepCollectionEquality().hash(preferredDistances),const DeepCollectionEquality().hash(runningReasons),prefsNewCatches,prefsRunReminders,prefsWeeklyDigest,prefsShowOnMap]);

@override
String toString() {
  return 'UserProfile(uid: $uid, name: $name, dateOfBirth: $dateOfBirth, gender: $gender, sexualOrientation: $sexualOrientation, phoneNumber: $phoneNumber, profileComplete: $profileComplete, email: $email, bio: $bio, photoUrls: $photoUrls, city: $city, joinedRunClubIds: $joinedRunClubIds, savedRunIds: $savedRunIds, interestedInGenders: $interestedInGenders, minAgePreference: $minAgePreference, maxAgePreference: $maxAgePreference, height: $height, occupation: $occupation, company: $company, education: $education, religion: $religion, languages: $languages, relationshipGoal: $relationshipGoal, drinking: $drinking, smoking: $smoking, workout: $workout, diet: $diet, children: $children, paceMinSecsPerKm: $paceMinSecsPerKm, paceMaxSecsPerKm: $paceMaxSecsPerKm, preferredDistances: $preferredDistances, runningReasons: $runningReasons, prefsNewCatches: $prefsNewCatches, prefsRunReminders: $prefsRunReminders, prefsWeeklyDigest: $prefsWeeklyDigest, prefsShowOnMap: $prefsShowOnMap)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String uid, String name,@TimestampConverter() DateTime dateOfBirth, Gender gender, SexualOrientation sexualOrientation, String phoneNumber, bool profileComplete, String email, String bio, List<String> photoUrls,@JsonKey(unknownEnumValue: null) IndianCity? city, List<String> joinedRunClubIds, List<String> savedRunIds, List<Gender> interestedInGenders, int minAgePreference, int maxAgePreference, int? height, String? occupation, String? company,@JsonKey(unknownEnumValue: null) EducationLevel? education,@JsonKey(unknownEnumValue: null) Religion? religion, List<Language> languages,@JsonKey(unknownEnumValue: null) RelationshipGoal? relationshipGoal,@JsonKey(unknownEnumValue: null) DrinkingHabit? drinking,@JsonKey(unknownEnumValue: null) SmokingHabit? smoking,@JsonKey(unknownEnumValue: null) WorkoutFrequency? workout,@JsonKey(unknownEnumValue: null) DietaryPreference? diet,@JsonKey(unknownEnumValue: null) ChildrenStatus? children, int paceMinSecsPerKm, int paceMaxSecsPerKm, List<PreferredDistance> preferredDistances, List<RunReason> runningReasons, bool prefsNewCatches, bool prefsRunReminders, bool prefsWeeklyDigest, bool prefsShowOnMap
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? name = null,Object? dateOfBirth = null,Object? gender = null,Object? sexualOrientation = null,Object? phoneNumber = null,Object? profileComplete = null,Object? email = null,Object? bio = null,Object? photoUrls = null,Object? city = freezed,Object? joinedRunClubIds = null,Object? savedRunIds = null,Object? interestedInGenders = null,Object? minAgePreference = null,Object? maxAgePreference = null,Object? height = freezed,Object? occupation = freezed,Object? company = freezed,Object? education = freezed,Object? religion = freezed,Object? languages = null,Object? relationshipGoal = freezed,Object? drinking = freezed,Object? smoking = freezed,Object? workout = freezed,Object? diet = freezed,Object? children = freezed,Object? paceMinSecsPerKm = null,Object? paceMaxSecsPerKm = null,Object? preferredDistances = null,Object? runningReasons = null,Object? prefsNewCatches = null,Object? prefsRunReminders = null,Object? prefsWeeklyDigest = null,Object? prefsShowOnMap = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,sexualOrientation: null == sexualOrientation ? _self.sexualOrientation : sexualOrientation // ignore: cast_nullable_to_non_nullable
as SexualOrientation,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,profileComplete: null == profileComplete ? _self.profileComplete : profileComplete // ignore: cast_nullable_to_non_nullable
as bool,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,photoUrls: null == photoUrls ? _self.photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as IndianCity?,joinedRunClubIds: null == joinedRunClubIds ? _self.joinedRunClubIds : joinedRunClubIds // ignore: cast_nullable_to_non_nullable
as List<String>,savedRunIds: null == savedRunIds ? _self.savedRunIds : savedRunIds // ignore: cast_nullable_to_non_nullable
as List<String>,interestedInGenders: null == interestedInGenders ? _self.interestedInGenders : interestedInGenders // ignore: cast_nullable_to_non_nullable
as List<Gender>,minAgePreference: null == minAgePreference ? _self.minAgePreference : minAgePreference // ignore: cast_nullable_to_non_nullable
as int,maxAgePreference: null == maxAgePreference ? _self.maxAgePreference : maxAgePreference // ignore: cast_nullable_to_non_nullable
as int,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,occupation: freezed == occupation ? _self.occupation : occupation // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,education: freezed == education ? _self.education : education // ignore: cast_nullable_to_non_nullable
as EducationLevel?,religion: freezed == religion ? _self.religion : religion // ignore: cast_nullable_to_non_nullable
as Religion?,languages: null == languages ? _self.languages : languages // ignore: cast_nullable_to_non_nullable
as List<Language>,relationshipGoal: freezed == relationshipGoal ? _self.relationshipGoal : relationshipGoal // ignore: cast_nullable_to_non_nullable
as RelationshipGoal?,drinking: freezed == drinking ? _self.drinking : drinking // ignore: cast_nullable_to_non_nullable
as DrinkingHabit?,smoking: freezed == smoking ? _self.smoking : smoking // ignore: cast_nullable_to_non_nullable
as SmokingHabit?,workout: freezed == workout ? _self.workout : workout // ignore: cast_nullable_to_non_nullable
as WorkoutFrequency?,diet: freezed == diet ? _self.diet : diet // ignore: cast_nullable_to_non_nullable
as DietaryPreference?,children: freezed == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as ChildrenStatus?,paceMinSecsPerKm: null == paceMinSecsPerKm ? _self.paceMinSecsPerKm : paceMinSecsPerKm // ignore: cast_nullable_to_non_nullable
as int,paceMaxSecsPerKm: null == paceMaxSecsPerKm ? _self.paceMaxSecsPerKm : paceMaxSecsPerKm // ignore: cast_nullable_to_non_nullable
as int,preferredDistances: null == preferredDistances ? _self.preferredDistances : preferredDistances // ignore: cast_nullable_to_non_nullable
as List<PreferredDistance>,runningReasons: null == runningReasons ? _self.runningReasons : runningReasons // ignore: cast_nullable_to_non_nullable
as List<RunReason>,prefsNewCatches: null == prefsNewCatches ? _self.prefsNewCatches : prefsNewCatches // ignore: cast_nullable_to_non_nullable
as bool,prefsRunReminders: null == prefsRunReminders ? _self.prefsRunReminders : prefsRunReminders // ignore: cast_nullable_to_non_nullable
as bool,prefsWeeklyDigest: null == prefsWeeklyDigest ? _self.prefsWeeklyDigest : prefsWeeklyDigest // ignore: cast_nullable_to_non_nullable
as bool,prefsShowOnMap: null == prefsShowOnMap ? _self.prefsShowOnMap : prefsShowOnMap // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String uid,  String name, @TimestampConverter()  DateTime dateOfBirth,  Gender gender,  SexualOrientation sexualOrientation,  String phoneNumber,  bool profileComplete,  String email,  String bio,  List<String> photoUrls, @JsonKey(unknownEnumValue: null)  IndianCity? city,  List<String> joinedRunClubIds,  List<String> savedRunIds,  List<Gender> interestedInGenders,  int minAgePreference,  int maxAgePreference,  int? height,  String? occupation,  String? company, @JsonKey(unknownEnumValue: null)  EducationLevel? education, @JsonKey(unknownEnumValue: null)  Religion? religion,  List<Language> languages, @JsonKey(unknownEnumValue: null)  RelationshipGoal? relationshipGoal, @JsonKey(unknownEnumValue: null)  DrinkingHabit? drinking, @JsonKey(unknownEnumValue: null)  SmokingHabit? smoking, @JsonKey(unknownEnumValue: null)  WorkoutFrequency? workout, @JsonKey(unknownEnumValue: null)  DietaryPreference? diet, @JsonKey(unknownEnumValue: null)  ChildrenStatus? children,  int paceMinSecsPerKm,  int paceMaxSecsPerKm,  List<PreferredDistance> preferredDistances,  List<RunReason> runningReasons,  bool prefsNewCatches,  bool prefsRunReminders,  bool prefsWeeklyDigest,  bool prefsShowOnMap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.uid,_that.name,_that.dateOfBirth,_that.gender,_that.sexualOrientation,_that.phoneNumber,_that.profileComplete,_that.email,_that.bio,_that.photoUrls,_that.city,_that.joinedRunClubIds,_that.savedRunIds,_that.interestedInGenders,_that.minAgePreference,_that.maxAgePreference,_that.height,_that.occupation,_that.company,_that.education,_that.religion,_that.languages,_that.relationshipGoal,_that.drinking,_that.smoking,_that.workout,_that.diet,_that.children,_that.paceMinSecsPerKm,_that.paceMaxSecsPerKm,_that.preferredDistances,_that.runningReasons,_that.prefsNewCatches,_that.prefsRunReminders,_that.prefsWeeklyDigest,_that.prefsShowOnMap);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String uid,  String name, @TimestampConverter()  DateTime dateOfBirth,  Gender gender,  SexualOrientation sexualOrientation,  String phoneNumber,  bool profileComplete,  String email,  String bio,  List<String> photoUrls, @JsonKey(unknownEnumValue: null)  IndianCity? city,  List<String> joinedRunClubIds,  List<String> savedRunIds,  List<Gender> interestedInGenders,  int minAgePreference,  int maxAgePreference,  int? height,  String? occupation,  String? company, @JsonKey(unknownEnumValue: null)  EducationLevel? education, @JsonKey(unknownEnumValue: null)  Religion? religion,  List<Language> languages, @JsonKey(unknownEnumValue: null)  RelationshipGoal? relationshipGoal, @JsonKey(unknownEnumValue: null)  DrinkingHabit? drinking, @JsonKey(unknownEnumValue: null)  SmokingHabit? smoking, @JsonKey(unknownEnumValue: null)  WorkoutFrequency? workout, @JsonKey(unknownEnumValue: null)  DietaryPreference? diet, @JsonKey(unknownEnumValue: null)  ChildrenStatus? children,  int paceMinSecsPerKm,  int paceMaxSecsPerKm,  List<PreferredDistance> preferredDistances,  List<RunReason> runningReasons,  bool prefsNewCatches,  bool prefsRunReminders,  bool prefsWeeklyDigest,  bool prefsShowOnMap)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.uid,_that.name,_that.dateOfBirth,_that.gender,_that.sexualOrientation,_that.phoneNumber,_that.profileComplete,_that.email,_that.bio,_that.photoUrls,_that.city,_that.joinedRunClubIds,_that.savedRunIds,_that.interestedInGenders,_that.minAgePreference,_that.maxAgePreference,_that.height,_that.occupation,_that.company,_that.education,_that.religion,_that.languages,_that.relationshipGoal,_that.drinking,_that.smoking,_that.workout,_that.diet,_that.children,_that.paceMinSecsPerKm,_that.paceMaxSecsPerKm,_that.preferredDistances,_that.runningReasons,_that.prefsNewCatches,_that.prefsRunReminders,_that.prefsWeeklyDigest,_that.prefsShowOnMap);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String uid,  String name, @TimestampConverter()  DateTime dateOfBirth,  Gender gender,  SexualOrientation sexualOrientation,  String phoneNumber,  bool profileComplete,  String email,  String bio,  List<String> photoUrls, @JsonKey(unknownEnumValue: null)  IndianCity? city,  List<String> joinedRunClubIds,  List<String> savedRunIds,  List<Gender> interestedInGenders,  int minAgePreference,  int maxAgePreference,  int? height,  String? occupation,  String? company, @JsonKey(unknownEnumValue: null)  EducationLevel? education, @JsonKey(unknownEnumValue: null)  Religion? religion,  List<Language> languages, @JsonKey(unknownEnumValue: null)  RelationshipGoal? relationshipGoal, @JsonKey(unknownEnumValue: null)  DrinkingHabit? drinking, @JsonKey(unknownEnumValue: null)  SmokingHabit? smoking, @JsonKey(unknownEnumValue: null)  WorkoutFrequency? workout, @JsonKey(unknownEnumValue: null)  DietaryPreference? diet, @JsonKey(unknownEnumValue: null)  ChildrenStatus? children,  int paceMinSecsPerKm,  int paceMaxSecsPerKm,  List<PreferredDistance> preferredDistances,  List<RunReason> runningReasons,  bool prefsNewCatches,  bool prefsRunReminders,  bool prefsWeeklyDigest,  bool prefsShowOnMap)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.uid,_that.name,_that.dateOfBirth,_that.gender,_that.sexualOrientation,_that.phoneNumber,_that.profileComplete,_that.email,_that.bio,_that.photoUrls,_that.city,_that.joinedRunClubIds,_that.savedRunIds,_that.interestedInGenders,_that.minAgePreference,_that.maxAgePreference,_that.height,_that.occupation,_that.company,_that.education,_that.religion,_that.languages,_that.relationshipGoal,_that.drinking,_that.smoking,_that.workout,_that.diet,_that.children,_that.paceMinSecsPerKm,_that.paceMaxSecsPerKm,_that.preferredDistances,_that.runningReasons,_that.prefsNewCatches,_that.prefsRunReminders,_that.prefsWeeklyDigest,_that.prefsShowOnMap);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile extends UserProfile {
  const _UserProfile({@JsonKey(includeToJson: false) required this.uid, required this.name, @TimestampConverter() required this.dateOfBirth, required this.gender, required this.sexualOrientation, required this.phoneNumber, required this.profileComplete, this.email = '', this.bio = '', final  List<String> photoUrls = const [], @JsonKey(unknownEnumValue: null) this.city, final  List<String> joinedRunClubIds = const [], final  List<String> savedRunIds = const [], final  List<Gender> interestedInGenders = const [], this.minAgePreference = 18, this.maxAgePreference = 99, this.height, this.occupation, this.company, @JsonKey(unknownEnumValue: null) this.education, @JsonKey(unknownEnumValue: null) this.religion, final  List<Language> languages = const [], @JsonKey(unknownEnumValue: null) this.relationshipGoal, @JsonKey(unknownEnumValue: null) this.drinking, @JsonKey(unknownEnumValue: null) this.smoking, @JsonKey(unknownEnumValue: null) this.workout, @JsonKey(unknownEnumValue: null) this.diet, @JsonKey(unknownEnumValue: null) this.children, this.paceMinSecsPerKm = 300, this.paceMaxSecsPerKm = 420, final  List<PreferredDistance> preferredDistances = const [], final  List<RunReason> runningReasons = const [], this.prefsNewCatches = true, this.prefsRunReminders = true, this.prefsWeeklyDigest = false, this.prefsShowOnMap = true}): _photoUrls = photoUrls,_joinedRunClubIds = joinedRunClubIds,_savedRunIds = savedRunIds,_interestedInGenders = interestedInGenders,_languages = languages,_preferredDistances = preferredDistances,_runningReasons = runningReasons,super._();
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

// Core (required at sign-up)
@override@JsonKey(includeToJson: false) final  String uid;
@override final  String name;
@override@TimestampConverter() final  DateTime dateOfBirth;
@override final  Gender gender;
@override final  SexualOrientation sexualOrientation;
@override final  String phoneNumber;
@override final  bool profileComplete;
// Optional profile/contact field. Authentication is phone-only.
@override@JsonKey() final  String email;
@override@JsonKey() final  String bio;
// Photos
 final  List<String> _photoUrls;
// Photos
@override@JsonKey() List<String> get photoUrls {
  if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoUrls);
}

// Location
@override@JsonKey(unknownEnumValue: null) final  IndianCity? city;
// Matching preferences
 final  List<String> _joinedRunClubIds;
// Matching preferences
@override@JsonKey() List<String> get joinedRunClubIds {
  if (_joinedRunClubIds is EqualUnmodifiableListView) return _joinedRunClubIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_joinedRunClubIds);
}

 final  List<String> _savedRunIds;
@override@JsonKey() List<String> get savedRunIds {
  if (_savedRunIds is EqualUnmodifiableListView) return _savedRunIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_savedRunIds);
}

 final  List<Gender> _interestedInGenders;
@override@JsonKey() List<Gender> get interestedInGenders {
  if (_interestedInGenders is EqualUnmodifiableListView) return _interestedInGenders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interestedInGenders);
}

@override@JsonKey() final  int minAgePreference;
@override@JsonKey() final  int maxAgePreference;
// Background (optional)
@override final  int? height;
@override final  String? occupation;
@override final  String? company;
@override@JsonKey(unknownEnumValue: null) final  EducationLevel? education;
@override@JsonKey(unknownEnumValue: null) final  Religion? religion;
 final  List<Language> _languages;
@override@JsonKey() List<Language> get languages {
  if (_languages is EqualUnmodifiableListView) return _languages;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_languages);
}

// Intentions (optional)
@override@JsonKey(unknownEnumValue: null) final  RelationshipGoal? relationshipGoal;
// Lifestyle (optional)
@override@JsonKey(unknownEnumValue: null) final  DrinkingHabit? drinking;
@override@JsonKey(unknownEnumValue: null) final  SmokingHabit? smoking;
@override@JsonKey(unknownEnumValue: null) final  WorkoutFrequency? workout;
@override@JsonKey(unknownEnumValue: null) final  DietaryPreference? diet;
@override@JsonKey(unknownEnumValue: null) final  ChildrenStatus? children;
// Running preferences (set during onboarding)
@override@JsonKey() final  int paceMinSecsPerKm;
@override@JsonKey() final  int paceMaxSecsPerKm;
 final  List<PreferredDistance> _preferredDistances;
@override@JsonKey() List<PreferredDistance> get preferredDistances {
  if (_preferredDistances is EqualUnmodifiableListView) return _preferredDistances;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredDistances);
}

 final  List<RunReason> _runningReasons;
@override@JsonKey() List<RunReason> get runningReasons {
  if (_runningReasons is EqualUnmodifiableListView) return _runningReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_runningReasons);
}

// Notification / discovery preferences
@override@JsonKey() final  bool prefsNewCatches;
@override@JsonKey() final  bool prefsRunReminders;
@override@JsonKey() final  bool prefsWeeklyDigest;
@override@JsonKey() final  bool prefsShowOnMap;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.sexualOrientation, sexualOrientation) || other.sexualOrientation == sexualOrientation)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.profileComplete, profileComplete) || other.profileComplete == profileComplete)&&(identical(other.email, email) || other.email == email)&&(identical(other.bio, bio) || other.bio == bio)&&const DeepCollectionEquality().equals(other._photoUrls, _photoUrls)&&(identical(other.city, city) || other.city == city)&&const DeepCollectionEquality().equals(other._joinedRunClubIds, _joinedRunClubIds)&&const DeepCollectionEquality().equals(other._savedRunIds, _savedRunIds)&&const DeepCollectionEquality().equals(other._interestedInGenders, _interestedInGenders)&&(identical(other.minAgePreference, minAgePreference) || other.minAgePreference == minAgePreference)&&(identical(other.maxAgePreference, maxAgePreference) || other.maxAgePreference == maxAgePreference)&&(identical(other.height, height) || other.height == height)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.company, company) || other.company == company)&&(identical(other.education, education) || other.education == education)&&(identical(other.religion, religion) || other.religion == religion)&&const DeepCollectionEquality().equals(other._languages, _languages)&&(identical(other.relationshipGoal, relationshipGoal) || other.relationshipGoal == relationshipGoal)&&(identical(other.drinking, drinking) || other.drinking == drinking)&&(identical(other.smoking, smoking) || other.smoking == smoking)&&(identical(other.workout, workout) || other.workout == workout)&&(identical(other.diet, diet) || other.diet == diet)&&(identical(other.children, children) || other.children == children)&&(identical(other.paceMinSecsPerKm, paceMinSecsPerKm) || other.paceMinSecsPerKm == paceMinSecsPerKm)&&(identical(other.paceMaxSecsPerKm, paceMaxSecsPerKm) || other.paceMaxSecsPerKm == paceMaxSecsPerKm)&&const DeepCollectionEquality().equals(other._preferredDistances, _preferredDistances)&&const DeepCollectionEquality().equals(other._runningReasons, _runningReasons)&&(identical(other.prefsNewCatches, prefsNewCatches) || other.prefsNewCatches == prefsNewCatches)&&(identical(other.prefsRunReminders, prefsRunReminders) || other.prefsRunReminders == prefsRunReminders)&&(identical(other.prefsWeeklyDigest, prefsWeeklyDigest) || other.prefsWeeklyDigest == prefsWeeklyDigest)&&(identical(other.prefsShowOnMap, prefsShowOnMap) || other.prefsShowOnMap == prefsShowOnMap));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,name,dateOfBirth,gender,sexualOrientation,phoneNumber,profileComplete,email,bio,const DeepCollectionEquality().hash(_photoUrls),city,const DeepCollectionEquality().hash(_joinedRunClubIds),const DeepCollectionEquality().hash(_savedRunIds),const DeepCollectionEquality().hash(_interestedInGenders),minAgePreference,maxAgePreference,height,occupation,company,education,religion,const DeepCollectionEquality().hash(_languages),relationshipGoal,drinking,smoking,workout,diet,children,paceMinSecsPerKm,paceMaxSecsPerKm,const DeepCollectionEquality().hash(_preferredDistances),const DeepCollectionEquality().hash(_runningReasons),prefsNewCatches,prefsRunReminders,prefsWeeklyDigest,prefsShowOnMap]);

@override
String toString() {
  return 'UserProfile(uid: $uid, name: $name, dateOfBirth: $dateOfBirth, gender: $gender, sexualOrientation: $sexualOrientation, phoneNumber: $phoneNumber, profileComplete: $profileComplete, email: $email, bio: $bio, photoUrls: $photoUrls, city: $city, joinedRunClubIds: $joinedRunClubIds, savedRunIds: $savedRunIds, interestedInGenders: $interestedInGenders, minAgePreference: $minAgePreference, maxAgePreference: $maxAgePreference, height: $height, occupation: $occupation, company: $company, education: $education, religion: $religion, languages: $languages, relationshipGoal: $relationshipGoal, drinking: $drinking, smoking: $smoking, workout: $workout, diet: $diet, children: $children, paceMinSecsPerKm: $paceMinSecsPerKm, paceMaxSecsPerKm: $paceMaxSecsPerKm, preferredDistances: $preferredDistances, runningReasons: $runningReasons, prefsNewCatches: $prefsNewCatches, prefsRunReminders: $prefsRunReminders, prefsWeeklyDigest: $prefsWeeklyDigest, prefsShowOnMap: $prefsShowOnMap)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String uid, String name,@TimestampConverter() DateTime dateOfBirth, Gender gender, SexualOrientation sexualOrientation, String phoneNumber, bool profileComplete, String email, String bio, List<String> photoUrls,@JsonKey(unknownEnumValue: null) IndianCity? city, List<String> joinedRunClubIds, List<String> savedRunIds, List<Gender> interestedInGenders, int minAgePreference, int maxAgePreference, int? height, String? occupation, String? company,@JsonKey(unknownEnumValue: null) EducationLevel? education,@JsonKey(unknownEnumValue: null) Religion? religion, List<Language> languages,@JsonKey(unknownEnumValue: null) RelationshipGoal? relationshipGoal,@JsonKey(unknownEnumValue: null) DrinkingHabit? drinking,@JsonKey(unknownEnumValue: null) SmokingHabit? smoking,@JsonKey(unknownEnumValue: null) WorkoutFrequency? workout,@JsonKey(unknownEnumValue: null) DietaryPreference? diet,@JsonKey(unknownEnumValue: null) ChildrenStatus? children, int paceMinSecsPerKm, int paceMaxSecsPerKm, List<PreferredDistance> preferredDistances, List<RunReason> runningReasons, bool prefsNewCatches, bool prefsRunReminders, bool prefsWeeklyDigest, bool prefsShowOnMap
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? name = null,Object? dateOfBirth = null,Object? gender = null,Object? sexualOrientation = null,Object? phoneNumber = null,Object? profileComplete = null,Object? email = null,Object? bio = null,Object? photoUrls = null,Object? city = freezed,Object? joinedRunClubIds = null,Object? savedRunIds = null,Object? interestedInGenders = null,Object? minAgePreference = null,Object? maxAgePreference = null,Object? height = freezed,Object? occupation = freezed,Object? company = freezed,Object? education = freezed,Object? religion = freezed,Object? languages = null,Object? relationshipGoal = freezed,Object? drinking = freezed,Object? smoking = freezed,Object? workout = freezed,Object? diet = freezed,Object? children = freezed,Object? paceMinSecsPerKm = null,Object? paceMaxSecsPerKm = null,Object? preferredDistances = null,Object? runningReasons = null,Object? prefsNewCatches = null,Object? prefsRunReminders = null,Object? prefsWeeklyDigest = null,Object? prefsShowOnMap = null,}) {
  return _then(_UserProfile(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,sexualOrientation: null == sexualOrientation ? _self.sexualOrientation : sexualOrientation // ignore: cast_nullable_to_non_nullable
as SexualOrientation,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,profileComplete: null == profileComplete ? _self.profileComplete : profileComplete // ignore: cast_nullable_to_non_nullable
as bool,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,photoUrls: null == photoUrls ? _self._photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as IndianCity?,joinedRunClubIds: null == joinedRunClubIds ? _self._joinedRunClubIds : joinedRunClubIds // ignore: cast_nullable_to_non_nullable
as List<String>,savedRunIds: null == savedRunIds ? _self._savedRunIds : savedRunIds // ignore: cast_nullable_to_non_nullable
as List<String>,interestedInGenders: null == interestedInGenders ? _self._interestedInGenders : interestedInGenders // ignore: cast_nullable_to_non_nullable
as List<Gender>,minAgePreference: null == minAgePreference ? _self.minAgePreference : minAgePreference // ignore: cast_nullable_to_non_nullable
as int,maxAgePreference: null == maxAgePreference ? _self.maxAgePreference : maxAgePreference // ignore: cast_nullable_to_non_nullable
as int,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,occupation: freezed == occupation ? _self.occupation : occupation // ignore: cast_nullable_to_non_nullable
as String?,company: freezed == company ? _self.company : company // ignore: cast_nullable_to_non_nullable
as String?,education: freezed == education ? _self.education : education // ignore: cast_nullable_to_non_nullable
as EducationLevel?,religion: freezed == religion ? _self.religion : religion // ignore: cast_nullable_to_non_nullable
as Religion?,languages: null == languages ? _self._languages : languages // ignore: cast_nullable_to_non_nullable
as List<Language>,relationshipGoal: freezed == relationshipGoal ? _self.relationshipGoal : relationshipGoal // ignore: cast_nullable_to_non_nullable
as RelationshipGoal?,drinking: freezed == drinking ? _self.drinking : drinking // ignore: cast_nullable_to_non_nullable
as DrinkingHabit?,smoking: freezed == smoking ? _self.smoking : smoking // ignore: cast_nullable_to_non_nullable
as SmokingHabit?,workout: freezed == workout ? _self.workout : workout // ignore: cast_nullable_to_non_nullable
as WorkoutFrequency?,diet: freezed == diet ? _self.diet : diet // ignore: cast_nullable_to_non_nullable
as DietaryPreference?,children: freezed == children ? _self.children : children // ignore: cast_nullable_to_non_nullable
as ChildrenStatus?,paceMinSecsPerKm: null == paceMinSecsPerKm ? _self.paceMinSecsPerKm : paceMinSecsPerKm // ignore: cast_nullable_to_non_nullable
as int,paceMaxSecsPerKm: null == paceMaxSecsPerKm ? _self.paceMaxSecsPerKm : paceMaxSecsPerKm // ignore: cast_nullable_to_non_nullable
as int,preferredDistances: null == preferredDistances ? _self._preferredDistances : preferredDistances // ignore: cast_nullable_to_non_nullable
as List<PreferredDistance>,runningReasons: null == runningReasons ? _self._runningReasons : runningReasons // ignore: cast_nullable_to_non_nullable
as List<RunReason>,prefsNewCatches: null == prefsNewCatches ? _self.prefsNewCatches : prefsNewCatches // ignore: cast_nullable_to_non_nullable
as bool,prefsRunReminders: null == prefsRunReminders ? _self.prefsRunReminders : prefsRunReminders // ignore: cast_nullable_to_non_nullable
as bool,prefsWeeklyDigest: null == prefsWeeklyDigest ? _self.prefsWeeklyDigest : prefsWeeklyDigest // ignore: cast_nullable_to_non_nullable
as bool,prefsShowOnMap: null == prefsShowOnMap ? _self.prefsShowOnMap : prefsShowOnMap // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
