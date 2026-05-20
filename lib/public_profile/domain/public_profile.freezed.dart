// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'public_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$PublicProfile {

@JsonKey(includeToJson: false) String get uid; String get name; int get age; Gender get gender; List<ProfilePromptAnswer> get profilePrompts; List<String> get photoUrls; List<String> get photoThumbnailUrls; List<PhotoPromptAnswer> get photoPrompts; List<ProfilePhoto> get profilePhotos;// Location
 String? get city;// Background
 int? get height; String? get occupation; String? get company;@JsonKey(unknownEnumValue: null) EducationLevel? get education;@JsonKey(unknownEnumValue: null) Religion? get religion; List<Language> get languages;// Intentions
@JsonKey(unknownEnumValue: null) RelationshipGoal? get relationshipGoal;// Lifestyle
@JsonKey(unknownEnumValue: null) DrinkingHabit? get drinking;@JsonKey(unknownEnumValue: null) SmokingHabit? get smoking;@JsonKey(unknownEnumValue: null) WorkoutFrequency? get workout;@JsonKey(unknownEnumValue: null) DietaryPreference? get diet;@JsonKey(unknownEnumValue: null) ChildrenStatus? get children;// Running identity
 int get paceMinSecsPerKm; int get paceMaxSecsPerKm; List<PreferredDistance> get preferredDistances; List<RunReason> get runningReasons; List<PreferredRunTime> get preferredRunTimes; int get runPreferencesVersion;
/// Create a copy of PublicProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PublicProfileCopyWith<PublicProfile> get copyWith => _$PublicProfileCopyWithImpl<PublicProfile>(this as PublicProfile, _$identity);

  /// Serializes this PublicProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PublicProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other.profilePrompts, profilePrompts)&&const DeepCollectionEquality().equals(other.photoUrls, photoUrls)&&const DeepCollectionEquality().equals(other.photoThumbnailUrls, photoThumbnailUrls)&&const DeepCollectionEquality().equals(other.photoPrompts, photoPrompts)&&const DeepCollectionEquality().equals(other.profilePhotos, profilePhotos)&&(identical(other.city, city) || other.city == city)&&(identical(other.height, height) || other.height == height)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.company, company) || other.company == company)&&(identical(other.education, education) || other.education == education)&&(identical(other.religion, religion) || other.religion == religion)&&const DeepCollectionEquality().equals(other.languages, languages)&&(identical(other.relationshipGoal, relationshipGoal) || other.relationshipGoal == relationshipGoal)&&(identical(other.drinking, drinking) || other.drinking == drinking)&&(identical(other.smoking, smoking) || other.smoking == smoking)&&(identical(other.workout, workout) || other.workout == workout)&&(identical(other.diet, diet) || other.diet == diet)&&(identical(other.children, children) || other.children == children)&&(identical(other.paceMinSecsPerKm, paceMinSecsPerKm) || other.paceMinSecsPerKm == paceMinSecsPerKm)&&(identical(other.paceMaxSecsPerKm, paceMaxSecsPerKm) || other.paceMaxSecsPerKm == paceMaxSecsPerKm)&&const DeepCollectionEquality().equals(other.preferredDistances, preferredDistances)&&const DeepCollectionEquality().equals(other.runningReasons, runningReasons)&&const DeepCollectionEquality().equals(other.preferredRunTimes, preferredRunTimes)&&(identical(other.runPreferencesVersion, runPreferencesVersion) || other.runPreferencesVersion == runPreferencesVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,name,age,gender,const DeepCollectionEquality().hash(profilePrompts),const DeepCollectionEquality().hash(photoUrls),const DeepCollectionEquality().hash(photoThumbnailUrls),const DeepCollectionEquality().hash(photoPrompts),const DeepCollectionEquality().hash(profilePhotos),city,height,occupation,company,education,religion,const DeepCollectionEquality().hash(languages),relationshipGoal,drinking,smoking,workout,diet,children,paceMinSecsPerKm,paceMaxSecsPerKm,const DeepCollectionEquality().hash(preferredDistances),const DeepCollectionEquality().hash(runningReasons),const DeepCollectionEquality().hash(preferredRunTimes),runPreferencesVersion]);

@override
String toString() {
  return 'PublicProfile(uid: $uid, name: $name, age: $age, gender: $gender, profilePrompts: $profilePrompts, photoUrls: $photoUrls, photoThumbnailUrls: $photoThumbnailUrls, photoPrompts: $photoPrompts, profilePhotos: $profilePhotos, city: $city, height: $height, occupation: $occupation, company: $company, education: $education, religion: $religion, languages: $languages, relationshipGoal: $relationshipGoal, drinking: $drinking, smoking: $smoking, workout: $workout, diet: $diet, children: $children, paceMinSecsPerKm: $paceMinSecsPerKm, paceMaxSecsPerKm: $paceMaxSecsPerKm, preferredDistances: $preferredDistances, runningReasons: $runningReasons, preferredRunTimes: $preferredRunTimes, runPreferencesVersion: $runPreferencesVersion)';
}


}

/// @nodoc
abstract mixin class $PublicProfileCopyWith<$Res>  {
  factory $PublicProfileCopyWith(PublicProfile value, $Res Function(PublicProfile) _then) = _$PublicProfileCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String uid, String name, int age, Gender gender, List<ProfilePromptAnswer> profilePrompts, List<String> photoUrls, List<String> photoThumbnailUrls, List<PhotoPromptAnswer> photoPrompts, List<ProfilePhoto> profilePhotos, String? city, int? height, String? occupation, String? company,@JsonKey(unknownEnumValue: null) EducationLevel? education,@JsonKey(unknownEnumValue: null) Religion? religion, List<Language> languages,@JsonKey(unknownEnumValue: null) RelationshipGoal? relationshipGoal,@JsonKey(unknownEnumValue: null) DrinkingHabit? drinking,@JsonKey(unknownEnumValue: null) SmokingHabit? smoking,@JsonKey(unknownEnumValue: null) WorkoutFrequency? workout,@JsonKey(unknownEnumValue: null) DietaryPreference? diet,@JsonKey(unknownEnumValue: null) ChildrenStatus? children, int paceMinSecsPerKm, int paceMaxSecsPerKm, List<PreferredDistance> preferredDistances, List<RunReason> runningReasons, List<PreferredRunTime> preferredRunTimes, int runPreferencesVersion
});




}
/// @nodoc
class _$PublicProfileCopyWithImpl<$Res>
    implements $PublicProfileCopyWith<$Res> {
  _$PublicProfileCopyWithImpl(this._self, this._then);

  final PublicProfile _self;
  final $Res Function(PublicProfile) _then;

/// Create a copy of PublicProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? uid = null,Object? name = null,Object? age = null,Object? gender = null,Object? profilePrompts = null,Object? photoUrls = null,Object? photoThumbnailUrls = null,Object? photoPrompts = null,Object? profilePhotos = null,Object? city = freezed,Object? height = freezed,Object? occupation = freezed,Object? company = freezed,Object? education = freezed,Object? religion = freezed,Object? languages = null,Object? relationshipGoal = freezed,Object? drinking = freezed,Object? smoking = freezed,Object? workout = freezed,Object? diet = freezed,Object? children = freezed,Object? paceMinSecsPerKm = null,Object? paceMaxSecsPerKm = null,Object? preferredDistances = null,Object? runningReasons = null,Object? preferredRunTimes = null,Object? runPreferencesVersion = null,}) {
  return _then(_self.copyWith(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,profilePrompts: null == profilePrompts ? _self.profilePrompts : profilePrompts // ignore: cast_nullable_to_non_nullable
as List<ProfilePromptAnswer>,photoUrls: null == photoUrls ? _self.photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,photoThumbnailUrls: null == photoThumbnailUrls ? _self.photoThumbnailUrls : photoThumbnailUrls // ignore: cast_nullable_to_non_nullable
as List<String>,photoPrompts: null == photoPrompts ? _self.photoPrompts : photoPrompts // ignore: cast_nullable_to_non_nullable
as List<PhotoPromptAnswer>,profilePhotos: null == profilePhotos ? _self.profilePhotos : profilePhotos // ignore: cast_nullable_to_non_nullable
as List<ProfilePhoto>,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
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
as List<RunReason>,preferredRunTimes: null == preferredRunTimes ? _self.preferredRunTimes : preferredRunTimes // ignore: cast_nullable_to_non_nullable
as List<PreferredRunTime>,runPreferencesVersion: null == runPreferencesVersion ? _self.runPreferencesVersion : runPreferencesVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PublicProfile].
extension PublicProfilePatterns on PublicProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PublicProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PublicProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PublicProfile value)  $default,){
final _that = this;
switch (_that) {
case _PublicProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PublicProfile value)?  $default,){
final _that = this;
switch (_that) {
case _PublicProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String uid,  String name,  int age,  Gender gender,  List<ProfilePromptAnswer> profilePrompts,  List<String> photoUrls,  List<String> photoThumbnailUrls,  List<PhotoPromptAnswer> photoPrompts,  List<ProfilePhoto> profilePhotos,  String? city,  int? height,  String? occupation,  String? company, @JsonKey(unknownEnumValue: null)  EducationLevel? education, @JsonKey(unknownEnumValue: null)  Religion? religion,  List<Language> languages, @JsonKey(unknownEnumValue: null)  RelationshipGoal? relationshipGoal, @JsonKey(unknownEnumValue: null)  DrinkingHabit? drinking, @JsonKey(unknownEnumValue: null)  SmokingHabit? smoking, @JsonKey(unknownEnumValue: null)  WorkoutFrequency? workout, @JsonKey(unknownEnumValue: null)  DietaryPreference? diet, @JsonKey(unknownEnumValue: null)  ChildrenStatus? children,  int paceMinSecsPerKm,  int paceMaxSecsPerKm,  List<PreferredDistance> preferredDistances,  List<RunReason> runningReasons,  List<PreferredRunTime> preferredRunTimes,  int runPreferencesVersion)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PublicProfile() when $default != null:
return $default(_that.uid,_that.name,_that.age,_that.gender,_that.profilePrompts,_that.photoUrls,_that.photoThumbnailUrls,_that.photoPrompts,_that.profilePhotos,_that.city,_that.height,_that.occupation,_that.company,_that.education,_that.religion,_that.languages,_that.relationshipGoal,_that.drinking,_that.smoking,_that.workout,_that.diet,_that.children,_that.paceMinSecsPerKm,_that.paceMaxSecsPerKm,_that.preferredDistances,_that.runningReasons,_that.preferredRunTimes,_that.runPreferencesVersion);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String uid,  String name,  int age,  Gender gender,  List<ProfilePromptAnswer> profilePrompts,  List<String> photoUrls,  List<String> photoThumbnailUrls,  List<PhotoPromptAnswer> photoPrompts,  List<ProfilePhoto> profilePhotos,  String? city,  int? height,  String? occupation,  String? company, @JsonKey(unknownEnumValue: null)  EducationLevel? education, @JsonKey(unknownEnumValue: null)  Religion? religion,  List<Language> languages, @JsonKey(unknownEnumValue: null)  RelationshipGoal? relationshipGoal, @JsonKey(unknownEnumValue: null)  DrinkingHabit? drinking, @JsonKey(unknownEnumValue: null)  SmokingHabit? smoking, @JsonKey(unknownEnumValue: null)  WorkoutFrequency? workout, @JsonKey(unknownEnumValue: null)  DietaryPreference? diet, @JsonKey(unknownEnumValue: null)  ChildrenStatus? children,  int paceMinSecsPerKm,  int paceMaxSecsPerKm,  List<PreferredDistance> preferredDistances,  List<RunReason> runningReasons,  List<PreferredRunTime> preferredRunTimes,  int runPreferencesVersion)  $default,) {final _that = this;
switch (_that) {
case _PublicProfile():
return $default(_that.uid,_that.name,_that.age,_that.gender,_that.profilePrompts,_that.photoUrls,_that.photoThumbnailUrls,_that.photoPrompts,_that.profilePhotos,_that.city,_that.height,_that.occupation,_that.company,_that.education,_that.religion,_that.languages,_that.relationshipGoal,_that.drinking,_that.smoking,_that.workout,_that.diet,_that.children,_that.paceMinSecsPerKm,_that.paceMaxSecsPerKm,_that.preferredDistances,_that.runningReasons,_that.preferredRunTimes,_that.runPreferencesVersion);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String uid,  String name,  int age,  Gender gender,  List<ProfilePromptAnswer> profilePrompts,  List<String> photoUrls,  List<String> photoThumbnailUrls,  List<PhotoPromptAnswer> photoPrompts,  List<ProfilePhoto> profilePhotos,  String? city,  int? height,  String? occupation,  String? company, @JsonKey(unknownEnumValue: null)  EducationLevel? education, @JsonKey(unknownEnumValue: null)  Religion? religion,  List<Language> languages, @JsonKey(unknownEnumValue: null)  RelationshipGoal? relationshipGoal, @JsonKey(unknownEnumValue: null)  DrinkingHabit? drinking, @JsonKey(unknownEnumValue: null)  SmokingHabit? smoking, @JsonKey(unknownEnumValue: null)  WorkoutFrequency? workout, @JsonKey(unknownEnumValue: null)  DietaryPreference? diet, @JsonKey(unknownEnumValue: null)  ChildrenStatus? children,  int paceMinSecsPerKm,  int paceMaxSecsPerKm,  List<PreferredDistance> preferredDistances,  List<RunReason> runningReasons,  List<PreferredRunTime> preferredRunTimes,  int runPreferencesVersion)?  $default,) {final _that = this;
switch (_that) {
case _PublicProfile() when $default != null:
return $default(_that.uid,_that.name,_that.age,_that.gender,_that.profilePrompts,_that.photoUrls,_that.photoThumbnailUrls,_that.photoPrompts,_that.profilePhotos,_that.city,_that.height,_that.occupation,_that.company,_that.education,_that.religion,_that.languages,_that.relationshipGoal,_that.drinking,_that.smoking,_that.workout,_that.diet,_that.children,_that.paceMinSecsPerKm,_that.paceMaxSecsPerKm,_that.preferredDistances,_that.runningReasons,_that.preferredRunTimes,_that.runPreferencesVersion);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PublicProfile implements PublicProfile {
  const _PublicProfile({@JsonKey(includeToJson: false) required this.uid, required this.name, required this.age, required this.gender, final  List<ProfilePromptAnswer> profilePrompts = const [], final  List<String> photoUrls = const [], final  List<String> photoThumbnailUrls = const [], final  List<PhotoPromptAnswer> photoPrompts = const [], final  List<ProfilePhoto> profilePhotos = const [], this.city, this.height, this.occupation, this.company, @JsonKey(unknownEnumValue: null) this.education, @JsonKey(unknownEnumValue: null) this.religion, final  List<Language> languages = const [], @JsonKey(unknownEnumValue: null) this.relationshipGoal, @JsonKey(unknownEnumValue: null) this.drinking, @JsonKey(unknownEnumValue: null) this.smoking, @JsonKey(unknownEnumValue: null) this.workout, @JsonKey(unknownEnumValue: null) this.diet, @JsonKey(unknownEnumValue: null) this.children, this.paceMinSecsPerKm = defaultPaceMinSecsPerKm, this.paceMaxSecsPerKm = defaultPaceMaxSecsPerKm, final  List<PreferredDistance> preferredDistances = const [], final  List<RunReason> runningReasons = const [], final  List<PreferredRunTime> preferredRunTimes = const [], this.runPreferencesVersion = 0}): _profilePrompts = profilePrompts,_photoUrls = photoUrls,_photoThumbnailUrls = photoThumbnailUrls,_photoPrompts = photoPrompts,_profilePhotos = profilePhotos,_languages = languages,_preferredDistances = preferredDistances,_runningReasons = runningReasons,_preferredRunTimes = preferredRunTimes;
  factory _PublicProfile.fromJson(Map<String, dynamic> json) => _$PublicProfileFromJson(json);

@override@JsonKey(includeToJson: false) final  String uid;
@override final  String name;
@override final  int age;
@override final  Gender gender;
 final  List<ProfilePromptAnswer> _profilePrompts;
@override@JsonKey() List<ProfilePromptAnswer> get profilePrompts {
  if (_profilePrompts is EqualUnmodifiableListView) return _profilePrompts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profilePrompts);
}

 final  List<String> _photoUrls;
@override@JsonKey() List<String> get photoUrls {
  if (_photoUrls is EqualUnmodifiableListView) return _photoUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoUrls);
}

 final  List<String> _photoThumbnailUrls;
@override@JsonKey() List<String> get photoThumbnailUrls {
  if (_photoThumbnailUrls is EqualUnmodifiableListView) return _photoThumbnailUrls;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoThumbnailUrls);
}

 final  List<PhotoPromptAnswer> _photoPrompts;
@override@JsonKey() List<PhotoPromptAnswer> get photoPrompts {
  if (_photoPrompts is EqualUnmodifiableListView) return _photoPrompts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_photoPrompts);
}

 final  List<ProfilePhoto> _profilePhotos;
@override@JsonKey() List<ProfilePhoto> get profilePhotos {
  if (_profilePhotos is EqualUnmodifiableListView) return _profilePhotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_profilePhotos);
}

// Location
@override final  String? city;
// Background
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

// Intentions
@override@JsonKey(unknownEnumValue: null) final  RelationshipGoal? relationshipGoal;
// Lifestyle
@override@JsonKey(unknownEnumValue: null) final  DrinkingHabit? drinking;
@override@JsonKey(unknownEnumValue: null) final  SmokingHabit? smoking;
@override@JsonKey(unknownEnumValue: null) final  WorkoutFrequency? workout;
@override@JsonKey(unknownEnumValue: null) final  DietaryPreference? diet;
@override@JsonKey(unknownEnumValue: null) final  ChildrenStatus? children;
// Running identity
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

 final  List<PreferredRunTime> _preferredRunTimes;
@override@JsonKey() List<PreferredRunTime> get preferredRunTimes {
  if (_preferredRunTimes is EqualUnmodifiableListView) return _preferredRunTimes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_preferredRunTimes);
}

@override@JsonKey() final  int runPreferencesVersion;

/// Create a copy of PublicProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PublicProfileCopyWith<_PublicProfile> get copyWith => __$PublicProfileCopyWithImpl<_PublicProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PublicProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PublicProfile&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.name, name) || other.name == name)&&(identical(other.age, age) || other.age == age)&&(identical(other.gender, gender) || other.gender == gender)&&const DeepCollectionEquality().equals(other._profilePrompts, _profilePrompts)&&const DeepCollectionEquality().equals(other._photoUrls, _photoUrls)&&const DeepCollectionEquality().equals(other._photoThumbnailUrls, _photoThumbnailUrls)&&const DeepCollectionEquality().equals(other._photoPrompts, _photoPrompts)&&const DeepCollectionEquality().equals(other._profilePhotos, _profilePhotos)&&(identical(other.city, city) || other.city == city)&&(identical(other.height, height) || other.height == height)&&(identical(other.occupation, occupation) || other.occupation == occupation)&&(identical(other.company, company) || other.company == company)&&(identical(other.education, education) || other.education == education)&&(identical(other.religion, religion) || other.religion == religion)&&const DeepCollectionEquality().equals(other._languages, _languages)&&(identical(other.relationshipGoal, relationshipGoal) || other.relationshipGoal == relationshipGoal)&&(identical(other.drinking, drinking) || other.drinking == drinking)&&(identical(other.smoking, smoking) || other.smoking == smoking)&&(identical(other.workout, workout) || other.workout == workout)&&(identical(other.diet, diet) || other.diet == diet)&&(identical(other.children, children) || other.children == children)&&(identical(other.paceMinSecsPerKm, paceMinSecsPerKm) || other.paceMinSecsPerKm == paceMinSecsPerKm)&&(identical(other.paceMaxSecsPerKm, paceMaxSecsPerKm) || other.paceMaxSecsPerKm == paceMaxSecsPerKm)&&const DeepCollectionEquality().equals(other._preferredDistances, _preferredDistances)&&const DeepCollectionEquality().equals(other._runningReasons, _runningReasons)&&const DeepCollectionEquality().equals(other._preferredRunTimes, _preferredRunTimes)&&(identical(other.runPreferencesVersion, runPreferencesVersion) || other.runPreferencesVersion == runPreferencesVersion));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,uid,name,age,gender,const DeepCollectionEquality().hash(_profilePrompts),const DeepCollectionEquality().hash(_photoUrls),const DeepCollectionEquality().hash(_photoThumbnailUrls),const DeepCollectionEquality().hash(_photoPrompts),const DeepCollectionEquality().hash(_profilePhotos),city,height,occupation,company,education,religion,const DeepCollectionEquality().hash(_languages),relationshipGoal,drinking,smoking,workout,diet,children,paceMinSecsPerKm,paceMaxSecsPerKm,const DeepCollectionEquality().hash(_preferredDistances),const DeepCollectionEquality().hash(_runningReasons),const DeepCollectionEquality().hash(_preferredRunTimes),runPreferencesVersion]);

@override
String toString() {
  return 'PublicProfile(uid: $uid, name: $name, age: $age, gender: $gender, profilePrompts: $profilePrompts, photoUrls: $photoUrls, photoThumbnailUrls: $photoThumbnailUrls, photoPrompts: $photoPrompts, profilePhotos: $profilePhotos, city: $city, height: $height, occupation: $occupation, company: $company, education: $education, religion: $religion, languages: $languages, relationshipGoal: $relationshipGoal, drinking: $drinking, smoking: $smoking, workout: $workout, diet: $diet, children: $children, paceMinSecsPerKm: $paceMinSecsPerKm, paceMaxSecsPerKm: $paceMaxSecsPerKm, preferredDistances: $preferredDistances, runningReasons: $runningReasons, preferredRunTimes: $preferredRunTimes, runPreferencesVersion: $runPreferencesVersion)';
}


}

/// @nodoc
abstract mixin class _$PublicProfileCopyWith<$Res> implements $PublicProfileCopyWith<$Res> {
  factory _$PublicProfileCopyWith(_PublicProfile value, $Res Function(_PublicProfile) _then) = __$PublicProfileCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String uid, String name, int age, Gender gender, List<ProfilePromptAnswer> profilePrompts, List<String> photoUrls, List<String> photoThumbnailUrls, List<PhotoPromptAnswer> photoPrompts, List<ProfilePhoto> profilePhotos, String? city, int? height, String? occupation, String? company,@JsonKey(unknownEnumValue: null) EducationLevel? education,@JsonKey(unknownEnumValue: null) Religion? religion, List<Language> languages,@JsonKey(unknownEnumValue: null) RelationshipGoal? relationshipGoal,@JsonKey(unknownEnumValue: null) DrinkingHabit? drinking,@JsonKey(unknownEnumValue: null) SmokingHabit? smoking,@JsonKey(unknownEnumValue: null) WorkoutFrequency? workout,@JsonKey(unknownEnumValue: null) DietaryPreference? diet,@JsonKey(unknownEnumValue: null) ChildrenStatus? children, int paceMinSecsPerKm, int paceMaxSecsPerKm, List<PreferredDistance> preferredDistances, List<RunReason> runningReasons, List<PreferredRunTime> preferredRunTimes, int runPreferencesVersion
});




}
/// @nodoc
class __$PublicProfileCopyWithImpl<$Res>
    implements _$PublicProfileCopyWith<$Res> {
  __$PublicProfileCopyWithImpl(this._self, this._then);

  final _PublicProfile _self;
  final $Res Function(_PublicProfile) _then;

/// Create a copy of PublicProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? uid = null,Object? name = null,Object? age = null,Object? gender = null,Object? profilePrompts = null,Object? photoUrls = null,Object? photoThumbnailUrls = null,Object? photoPrompts = null,Object? profilePhotos = null,Object? city = freezed,Object? height = freezed,Object? occupation = freezed,Object? company = freezed,Object? education = freezed,Object? religion = freezed,Object? languages = null,Object? relationshipGoal = freezed,Object? drinking = freezed,Object? smoking = freezed,Object? workout = freezed,Object? diet = freezed,Object? children = freezed,Object? paceMinSecsPerKm = null,Object? paceMaxSecsPerKm = null,Object? preferredDistances = null,Object? runningReasons = null,Object? preferredRunTimes = null,Object? runPreferencesVersion = null,}) {
  return _then(_PublicProfile(
uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,age: null == age ? _self.age : age // ignore: cast_nullable_to_non_nullable
as int,gender: null == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender,profilePrompts: null == profilePrompts ? _self._profilePrompts : profilePrompts // ignore: cast_nullable_to_non_nullable
as List<ProfilePromptAnswer>,photoUrls: null == photoUrls ? _self._photoUrls : photoUrls // ignore: cast_nullable_to_non_nullable
as List<String>,photoThumbnailUrls: null == photoThumbnailUrls ? _self._photoThumbnailUrls : photoThumbnailUrls // ignore: cast_nullable_to_non_nullable
as List<String>,photoPrompts: null == photoPrompts ? _self._photoPrompts : photoPrompts // ignore: cast_nullable_to_non_nullable
as List<PhotoPromptAnswer>,profilePhotos: null == profilePhotos ? _self._profilePhotos : profilePhotos // ignore: cast_nullable_to_non_nullable
as List<ProfilePhoto>,city: freezed == city ? _self.city : city // ignore: cast_nullable_to_non_nullable
as String?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
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
as List<RunReason>,preferredRunTimes: null == preferredRunTimes ? _self._preferredRunTimes : preferredRunTimes // ignore: cast_nullable_to_non_nullable
as List<PreferredRunTime>,runPreferencesVersion: null == runPreferencesVersion ? _self.runPreferencesVersion : runPreferencesVersion // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
