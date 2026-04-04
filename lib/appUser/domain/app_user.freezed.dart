// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_user.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppUser {

// Core (required at sign-up)
 String get uid; String get email; String get name;@TimestampConverter() DateTime get dateOfBirth; String get bio; Gender get gender; SexualOrientation get sexualOrientation; String get phoneNumber; bool get profileComplete;// Photos
 List<String> get photoUrls;// Matching preferences
 List<String> get followedRunClubIds; List<Gender> get interestedInGenders; int get minAgePreference; int get maxAgePreference;// Background (optional)
 int? get height; String? get occupation; String? get company;@JsonKey(unknownEnumValue: null) EducationLevel? get education;@JsonKey(unknownEnumValue: null) Religion? get religion; List<Language> get languages;// Intentions (optional)
@JsonKey(unknownEnumValue: null) RelationshipGoal? get relationshipGoal;// Lifestyle (optional)
@JsonKey(unknownEnumValue: null) DrinkingHabit? get drinking;@JsonKey(unknownEnumValue: null) SmokingHabit? get smoking;@JsonKey(unknownEnumValue: null) WorkoutFrequency? get workout;@JsonKey(unknownEnumValue: null) DietaryPreference? get diet;@JsonKey(unknownEnumValue: null) ChildrenStatus? get children;
/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppUserCopyWith<AppUser> get copyWith => _$AppUserCopyWithImpl<AppUser>(this as AppUser, _$identity);

  /// Serializes this AppUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.sexualOrientation, sexualOrientation) || other.sexualOrientation == sexualOrientation)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.profileComplete, profileComplete) || other.profileComplete == profileComplete)&&const DeepCollectionEquality().equals(other.photoUrls, photoUrls)&&const DeepCollectionEquality().equals(other.followedRunClubIds, followedRunClubIds)&&const DeepCollectionEquality().equals(other.interestedInGenders, interestedInGenders)&&(identical(other.minAgePreference, minAgePreference) || other.minAgePreference == minAgePreference)&&(identical(other.maxAgePreference, maxAgePreference) || other.maxAgePreference == maxAgePreference)&&(identical(other.height, height) || other.height == height)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.company, company) || other.company == company)&&(identical(other.education, education) || other.education == education)&&(identical(other.religion, religion) || other.religion == religion)&&const DeepCollectionEquality().equals(other.languages, languages)&&(identical(other.relationshipGoal, relationshipGoal) || other.relationshipGoal == relationshipGoal)&&(identical(other.drinking, drinking) || other.drinking == drinking)&&(identical(other.smoking, smoking) || other.smoking == smoking)&&(identical(other.workout, workout) || other.workout == workout)&&(identical(other.diet, diet) || other.diet == diet)&&(identical(other.children, children) || other.children == children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,name,dateOfBirth,bio,gender,sexualOrientation,phoneNumber,profileComplete,const DeepCollectionEquality().hash(photoUrls),const DeepCollectionEquality().hash(followedRunClubIds),const DeepCollectionEquality().hash(interestedInGenders),minAgePreference,maxAgePreference,height,occupation,company,education,religion,const DeepCollectionEquality().hash(languages),relationshipGoal,drinking,smoking,workout,diet,children]);

@override
String toString() {
  return 'AppUser(uid: $uid, email: $email, name: $name, dateOfBirth: $dateOfBirth, bio: $bio, gender: $gender, sexualOrientation: $sexualOrientation, phoneNumber: $phoneNumber, profileComplete: $profileComplete, photoUrls: $photoUrls, followedRunClubIds: $followedRunClubIds, interestedInGenders: $interestedInGenders, minAgePreference: $minAgePreference, maxAgePreference: $maxAgePreference, height: $height, occupation: $occupation, company: $company, education: $education, religion: $religion, languages: $languages, relationshipGoal: $relationshipGoal, drinking: $drinking, smoking: $smoking, workout: $workout, diet: $diet, children: $children)';
}


}

/// @nodoc
abstract mixin class $AppUserCopyWith<$Res>  {
  factory $AppUserCopyWith(AppUser value, $Res Function(AppUser) _then) = _$AppUserCopyWithImpl;
@useResult
$Res call({
 String uid, String email, String name,@TimestampConverter() DateTime dateOfBirth, String bio, Gender gender, SexualOrientation sexualOrientation, String phoneNumber, bool profileComplete, List<String> photoUrls, List<String> followedRunClubIds, List<Gender> interestedInGenders, int minAgePreference, int maxAgePreference, int? height, String? occupation, String? company,@JsonKey(unknownEnumValue: null) EducationLevel? education,@JsonKey(unknownEnumValue: null) Religion? religion, List<Language> languages,@JsonKey(unknownEnumValue: null) RelationshipGoal? relationshipGoal,@JsonKey(unknownEnumValue: null) DrinkingHabit? drinking,@JsonKey(unknownEnumValue: null) SmokingHabit? smoking,@JsonKey(unknownEnumValue: null) WorkoutFrequency? workout,@JsonKey(unknownEnumValue: null) DietaryPreference? diet,@JsonKey(unknownEnumValue: null) ChildrenStatus? children
});




}
/// @nodoc
class _$AppUserCopyWithImpl<$Res>
    implements $AppUserCopyWith<$Res> {
  _$AppUserCopyWithImpl(this._self, this._then);

  final AppUser _self;
  final $Res Function(AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? email = null,Object? name = null,Object? dateOfBirth = null,Object? bio = null,Object? gender = null,Object? sexualOrientation = null,Object? phoneNumber = null,Object? profileComplete = null,Object? photoUrls = null,Object? followedRunClubIds = null,Object? interestedInGenders = null,Object? minAgePreference = null,Object? maxAgePreference = null,Object? height = freezed,Object? occupation = freezed,Object? company = freezed,Object? education = freezed,Object? religion = freezed,Object? languages = null,Object? relationshipGoal = freezed,Object? drinking = freezed,Object? smoking = freezed,Object? workout = freezed,Object? diet = freezed,Object? children = freezed,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,sexualOrientation: null == sexualOrientation ? _self.sexualOrientation : sexualOrientation // ignore: cast_nullable_to_non_nullable
as SexualOrientation,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,profileComplete: null == profileComplete ? _self.profileComplete : profileComplete // ignore: cast_nullable_to_non_nullable
as bool,photoUrls: null == photoUrls ? _self.photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,followedRunClubIds: null == followedRunClubIds ? _self.followedRunClubIds : followedRunClubIds // ignore: cast_nullable_to_non_nullable
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
as ChildrenStatus?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppUser].
extension AppUserPatterns on AppUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppUser value)  $default,){
final _that = this;
switch (_that) {
case _AppUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppUser value)?  $default,){
final _that = this;
switch (_that) {
case _AppUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String uid,  String email,  String name, @TimestampConverter()  DateTime dateOfBirth,  String bio,  Gender gender,  SexualOrientation sexualOrientation,  String phoneNumber,  bool profileComplete,  List<String> photoUrls,  List<String> followedRunClubIds,  List<Gender> interestedInGenders,  int minAgePreference,  int maxAgePreference,  int? height,  String? occupation,  String? company, @JsonKey(unknownEnumValue: null)  EducationLevel? education, @JsonKey(unknownEnumValue: null)  Religion? religion,  List<Language> languages, @JsonKey(unknownEnumValue: null)  RelationshipGoal? relationshipGoal, @JsonKey(unknownEnumValue: null)  DrinkingHabit? drinking, @JsonKey(unknownEnumValue: null)  SmokingHabit? smoking, @JsonKey(unknownEnumValue: null)  WorkoutFrequency? workout, @JsonKey(unknownEnumValue: null)  DietaryPreference? diet, @JsonKey(unknownEnumValue: null)  ChildrenStatus? children)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.email,_that.name,_that.dateOfBirth,_that.bio,_that.gender,_that.sexualOrientation,_that.phoneNumber,_that.profileComplete,_that.photoUrls,_that.followedRunClubIds,_that.interestedInGenders,_that.minAgePreference,_that.maxAgePreference,_that.height,_that.occupation,_that.company,_that.education,_that.religion,_that.languages,_that.relationshipGoal,_that.drinking,_that.smoking,_that.workout,_that.diet,_that.children);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String uid,  String email,  String name, @TimestampConverter()  DateTime dateOfBirth,  String bio,  Gender gender,  SexualOrientation sexualOrientation,  String phoneNumber,  bool profileComplete,  List<String> photoUrls,  List<String> followedRunClubIds,  List<Gender> interestedInGenders,  int minAgePreference,  int maxAgePreference,  int? height,  String? occupation,  String? company, @JsonKey(unknownEnumValue: null)  EducationLevel? education, @JsonKey(unknownEnumValue: null)  Religion? religion,  List<Language> languages, @JsonKey(unknownEnumValue: null)  RelationshipGoal? relationshipGoal, @JsonKey(unknownEnumValue: null)  DrinkingHabit? drinking, @JsonKey(unknownEnumValue: null)  SmokingHabit? smoking, @JsonKey(unknownEnumValue: null)  WorkoutFrequency? workout, @JsonKey(unknownEnumValue: null)  DietaryPreference? diet, @JsonKey(unknownEnumValue: null)  ChildrenStatus? children)  $default,) {final _that = this;
switch (_that) {
case _AppUser():
return $default(_that.uid,_that.email,_that.name,_that.dateOfBirth,_that.bio,_that.gender,_that.sexualOrientation,_that.phoneNumber,_that.profileComplete,_that.photoUrls,_that.followedRunClubIds,_that.interestedInGenders,_that.minAgePreference,_that.maxAgePreference,_that.height,_that.occupation,_that.company,_that.education,_that.religion,_that.languages,_that.relationshipGoal,_that.drinking,_that.smoking,_that.workout,_that.diet,_that.children);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String uid,  String email,  String name, @TimestampConverter()  DateTime dateOfBirth,  String bio,  Gender gender,  SexualOrientation sexualOrientation,  String phoneNumber,  bool profileComplete,  List<String> photoUrls,  List<String> followedRunClubIds,  List<Gender> interestedInGenders,  int minAgePreference,  int maxAgePreference,  int? height,  String? occupation,  String? company, @JsonKey(unknownEnumValue: null)  EducationLevel? education, @JsonKey(unknownEnumValue: null)  Religion? religion,  List<Language> languages, @JsonKey(unknownEnumValue: null)  RelationshipGoal? relationshipGoal, @JsonKey(unknownEnumValue: null)  DrinkingHabit? drinking, @JsonKey(unknownEnumValue: null)  SmokingHabit? smoking, @JsonKey(unknownEnumValue: null)  WorkoutFrequency? workout, @JsonKey(unknownEnumValue: null)  DietaryPreference? diet, @JsonKey(unknownEnumValue: null)  ChildrenStatus? children)?  $default,) {final _that = this;
switch (_that) {
case _AppUser() when $default != null:
return $default(_that.uid,_that.email,_that.name,_that.dateOfBirth,_that.bio,_that.gender,_that.sexualOrientation,_that.phoneNumber,_that.profileComplete,_that.photoUrls,_that.followedRunClubIds,_that.interestedInGenders,_that.minAgePreference,_that.maxAgePreference,_that.height,_that.occupation,_that.company,_that.education,_that.religion,_that.languages,_that.relationshipGoal,_that.drinking,_that.smoking,_that.workout,_that.diet,_that.children);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppUser extends AppUser {
  const _AppUser({required this.uid, required this.email, required this.name, @TimestampConverter() required this.dateOfBirth, required this.bio, required this.gender, required this.sexualOrientation, required this.phoneNumber, required this.profileComplete, final  List<String> photoUrls = const [], final  List<String> followedRunClubIds = const [], final  List<Gender> interestedInGenders = const [], this.minAgePreference = 18, this.maxAgePreference = 99, this.height, this.occupation, this.company, @JsonKey(unknownEnumValue: null) this.education, @JsonKey(unknownEnumValue: null) this.religion, final  List<Language> languages = const [], @JsonKey(unknownEnumValue: null) this.relationshipGoal, @JsonKey(unknownEnumValue: null) this.drinking, @JsonKey(unknownEnumValue: null) this.smoking, @JsonKey(unknownEnumValue: null) this.workout, @JsonKey(unknownEnumValue: null) this.diet, @JsonKey(unknownEnumValue: null) this.children}): _photoUrls = photoUrls,_followedRunClubIds = followedRunClubIds,_interestedInGenders = interestedInGenders,_languages = languages,super._();
  factory _AppUser.fromJson(Map<String, dynamic> json) => _$AppUserFromJson(json);

// Core (required at sign-up)
@override final  String uid;
@override final  String email;
@override final  String name;
@override@TimestampConverter() final  DateTime dateOfBirth;
@override final  String bio;
@override final  Gender gender;
@override final  SexualOrientation sexualOrientation;
@override final  String phoneNumber;
@override final  bool profileComplete;
// Photos
 final  List<String> _photoUrls;
// Photos
@override@JsonKey() List<String> get photoUrls {
  if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoUrls);
}

// Matching preferences
 final  List<String> _followedRunClubIds;
// Matching preferences
@override@JsonKey() List<String> get followedRunClubIds {
  if (_followedRunClubIds is EqualUnmodifiableListView) return _followedRunClubIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_followedRunClubIds);
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

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppUserCopyWith<_AppUser> get copyWith => __$AppUserCopyWithImpl<_AppUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppUser&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.email, email) || other.email == email)&&(identical(other.name, name) || other.name == name)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.bio, bio) || other.bio == bio)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.sexualOrientation, sexualOrientation) || other.sexualOrientation == sexualOrientation)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.profileComplete, profileComplete) || other.profileComplete == profileComplete)&&const DeepCollectionEquality().equals(other._photoUrls, _photoUrls)&&const DeepCollectionEquality().equals(other._followedRunClubIds, _followedRunClubIds)&&const DeepCollectionEquality().equals(other._interestedInGenders, _interestedInGenders)&&(identical(other.minAgePreference, minAgePreference) || other.minAgePreference == minAgePreference)&&(identical(other.maxAgePreference, maxAgePreference) || other.maxAgePreference == maxAgePreference)&&(identical(other.height, height) || other.height == height)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.company, company) || other.company == company)&&(identical(other.education, education) || other.education == education)&&(identical(other.religion, religion) || other.religion == religion)&&const DeepCollectionEquality().equals(other._languages, _languages)&&(identical(other.relationshipGoal, relationshipGoal) || other.relationshipGoal == relationshipGoal)&&(identical(other.drinking, drinking) || other.drinking == drinking)&&(identical(other.smoking, smoking) || other.smoking == smoking)&&(identical(other.workout, workout) || other.workout == workout)&&(identical(other.diet, diet) || other.diet == diet)&&(identical(other.children, children) || other.children == children));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,email,name,dateOfBirth,bio,gender,sexualOrientation,phoneNumber,profileComplete,const DeepCollectionEquality().hash(_photoUrls),const DeepCollectionEquality().hash(_followedRunClubIds),const DeepCollectionEquality().hash(_interestedInGenders),minAgePreference,maxAgePreference,height,occupation,company,education,religion,const DeepCollectionEquality().hash(_languages),relationshipGoal,drinking,smoking,workout,diet,children]);

@override
String toString() {
  return 'AppUser(uid: $uid, email: $email, name: $name, dateOfBirth: $dateOfBirth, bio: $bio, gender: $gender, sexualOrientation: $sexualOrientation, phoneNumber: $phoneNumber, profileComplete: $profileComplete, photoUrls: $photoUrls, followedRunClubIds: $followedRunClubIds, interestedInGenders: $interestedInGenders, minAgePreference: $minAgePreference, maxAgePreference: $maxAgePreference, height: $height, occupation: $occupation, company: $company, education: $education, religion: $religion, languages: $languages, relationshipGoal: $relationshipGoal, drinking: $drinking, smoking: $smoking, workout: $workout, diet: $diet, children: $children)';
}


}

/// @nodoc
abstract mixin class _$AppUserCopyWith<$Res> implements $AppUserCopyWith<$Res> {
  factory _$AppUserCopyWith(_AppUser value, $Res Function(_AppUser) _then) = __$AppUserCopyWithImpl;
@override @useResult
$Res call({
 String uid, String email, String name,@TimestampConverter() DateTime dateOfBirth, String bio, Gender gender, SexualOrientation sexualOrientation, String phoneNumber, bool profileComplete, List<String> photoUrls, List<String> followedRunClubIds, List<Gender> interestedInGenders, int minAgePreference, int maxAgePreference, int? height, String? occupation, String? company,@JsonKey(unknownEnumValue: null) EducationLevel? education,@JsonKey(unknownEnumValue: null) Religion? religion, List<Language> languages,@JsonKey(unknownEnumValue: null) RelationshipGoal? relationshipGoal,@JsonKey(unknownEnumValue: null) DrinkingHabit? drinking,@JsonKey(unknownEnumValue: null) SmokingHabit? smoking,@JsonKey(unknownEnumValue: null) WorkoutFrequency? workout,@JsonKey(unknownEnumValue: null) DietaryPreference? diet,@JsonKey(unknownEnumValue: null) ChildrenStatus? children
});




}
/// @nodoc
class __$AppUserCopyWithImpl<$Res>
    implements _$AppUserCopyWith<$Res> {
  __$AppUserCopyWithImpl(this._self, this._then);

  final _AppUser _self;
  final $Res Function(_AppUser) _then;

/// Create a copy of AppUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? email = null,Object? name = null,Object? dateOfBirth = null,Object? bio = null,Object? gender = null,Object? sexualOrientation = null,Object? phoneNumber = null,Object? profileComplete = null,Object? photoUrls = null,Object? followedRunClubIds = null,Object? interestedInGenders = null,Object? minAgePreference = null,Object? maxAgePreference = null,Object? height = freezed,Object? occupation = freezed,Object? company = freezed,Object? education = freezed,Object? religion = freezed,Object? languages = null,Object? relationshipGoal = freezed,Object? drinking = freezed,Object? smoking = freezed,Object? workout = freezed,Object? diet = freezed,Object? children = freezed,}) {
  return _then(_AppUser(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,email: null == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: null == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime,bio: null == bio ? _self.bio : bio // ignore: cast_nullable_to_non_nullable
as String,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,sexualOrientation: null == sexualOrientation ? _self.sexualOrientation : sexualOrientation // ignore: cast_nullable_to_non_nullable
as SexualOrientation,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,profileComplete: null == profileComplete ? _self.profileComplete : profileComplete // ignore: cast_nullable_to_non_nullable
as bool,photoUrls: null == photoUrls ? _self._photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,followedRunClubIds: null == followedRunClubIds ? _self._followedRunClubIds : followedRunClubIds // ignore: cast_nullable_to_non_nullable
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
as ChildrenStatus?,
  ));
}


}

// dart format on
