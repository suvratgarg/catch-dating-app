// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'onboarding_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OnboardingData {

 int get step; String get phoneNumber; String? get verificationId; String get firstName; String get lastName; DateTime? get dateOfBirth; Gender? get gender; SexualOrientation? get sexualOrientation; List<Gender> get interestedInGenders;
/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingDataCopyWith<OnboardingData> get copyWith => _$OnboardingDataCopyWithImpl<OnboardingData>(this as OnboardingData, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingData&&(identical(other.step, step) || other.step == step)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.sexualOrientation, sexualOrientation) || other.sexualOrientation == sexualOrientation)&&const DeepCollectionEquality().equals(other.interestedInGenders, interestedInGenders));
}


@override
int get hashCode => Object.hash(runtimeType,step,phoneNumber,verificationId,firstName,lastName,dateOfBirth,gender,sexualOrientation,const DeepCollectionEquality().hash(interestedInGenders));

@override
String toString() {
  return 'OnboardingData(step: $step, phoneNumber: $phoneNumber, verificationId: $verificationId, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, gender: $gender, sexualOrientation: $sexualOrientation, interestedInGenders: $interestedInGenders)';
}


}

/// @nodoc
abstract mixin class $OnboardingDataCopyWith<$Res>  {
  factory $OnboardingDataCopyWith(OnboardingData value, $Res Function(OnboardingData) _then) = _$OnboardingDataCopyWithImpl;
@useResult
$Res call({
 int step, String phoneNumber, String? verificationId, String firstName, String lastName, DateTime? dateOfBirth, Gender? gender, SexualOrientation? sexualOrientation, List<Gender> interestedInGenders
});




}
/// @nodoc
class _$OnboardingDataCopyWithImpl<$Res>
    implements $OnboardingDataCopyWith<$Res> {
  _$OnboardingDataCopyWithImpl(this._self, this._then);

  final OnboardingData _self;
  final $Res Function(OnboardingData) _then;

/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? phoneNumber = null,Object? verificationId = freezed,Object? firstName = null,Object? lastName = null,Object? dateOfBirth = freezed,Object? gender = freezed,Object? sexualOrientation = freezed,Object? interestedInGenders = null,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,verificationId: freezed == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String?,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,sexualOrientation: freezed == sexualOrientation ? _self.sexualOrientation : sexualOrientation // ignore: cast_nullable_to_non_nullable
as SexualOrientation?,interestedInGenders: null == interestedInGenders ? _self.interestedInGenders : interestedInGenders // ignore: cast_nullable_to_non_nullable
as List<Gender>,
  ));
}

}


/// Adds pattern-matching-related methods to [OnboardingData].
extension OnboardingDataPatterns on OnboardingData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OnboardingData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OnboardingData value)  $default,){
final _that = this;
switch (_that) {
case _OnboardingData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OnboardingData value)?  $default,){
final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int step,  String phoneNumber,  String? verificationId,  String firstName,  String lastName,  DateTime? dateOfBirth,  Gender? gender,  SexualOrientation? sexualOrientation,  List<Gender> interestedInGenders)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
return $default(_that.step,_that.phoneNumber,_that.verificationId,_that.firstName,_that.lastName,_that.dateOfBirth,_that.gender,_that.sexualOrientation,_that.interestedInGenders);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int step,  String phoneNumber,  String? verificationId,  String firstName,  String lastName,  DateTime? dateOfBirth,  Gender? gender,  SexualOrientation? sexualOrientation,  List<Gender> interestedInGenders)  $default,) {final _that = this;
switch (_that) {
case _OnboardingData():
return $default(_that.step,_that.phoneNumber,_that.verificationId,_that.firstName,_that.lastName,_that.dateOfBirth,_that.gender,_that.sexualOrientation,_that.interestedInGenders);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int step,  String phoneNumber,  String? verificationId,  String firstName,  String lastName,  DateTime? dateOfBirth,  Gender? gender,  SexualOrientation? sexualOrientation,  List<Gender> interestedInGenders)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
return $default(_that.step,_that.phoneNumber,_that.verificationId,_that.firstName,_that.lastName,_that.dateOfBirth,_that.gender,_that.sexualOrientation,_that.interestedInGenders);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingData implements OnboardingData {
  const _OnboardingData({this.step = 0, this.phoneNumber = '', this.verificationId, this.firstName = '', this.lastName = '', this.dateOfBirth, this.gender, this.sexualOrientation, final  List<Gender> interestedInGenders = const []}): _interestedInGenders = interestedInGenders;
  

@override@JsonKey() final  int step;
@override@JsonKey() final  String phoneNumber;
@override final  String? verificationId;
@override@JsonKey() final  String firstName;
@override@JsonKey() final  String lastName;
@override final  DateTime? dateOfBirth;
@override final  Gender? gender;
@override final  SexualOrientation? sexualOrientation;
 final  List<Gender> _interestedInGenders;
@override@JsonKey() List<Gender> get interestedInGenders {
  if (_interestedInGenders is EqualUnmodifiableListView) return _interestedInGenders;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_interestedInGenders);
}


/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingDataCopyWith<_OnboardingData> get copyWith => __$OnboardingDataCopyWithImpl<_OnboardingData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingData&&(identical(other.step, step) || other.step == step)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.gender, gender) || other.gender == gender)&&(identical(other.sexualOrientation, sexualOrientation) || other.sexualOrientation == sexualOrientation)&&const DeepCollectionEquality().equals(other._interestedInGenders, _interestedInGenders));
}


@override
int get hashCode => Object.hash(runtimeType,step,phoneNumber,verificationId,firstName,lastName,dateOfBirth,gender,sexualOrientation,const DeepCollectionEquality().hash(_interestedInGenders));

@override
String toString() {
  return 'OnboardingData(step: $step, phoneNumber: $phoneNumber, verificationId: $verificationId, firstName: $firstName, lastName: $lastName, dateOfBirth: $dateOfBirth, gender: $gender, sexualOrientation: $sexualOrientation, interestedInGenders: $interestedInGenders)';
}


}

/// @nodoc
abstract mixin class _$OnboardingDataCopyWith<$Res> implements $OnboardingDataCopyWith<$Res> {
  factory _$OnboardingDataCopyWith(_OnboardingData value, $Res Function(_OnboardingData) _then) = __$OnboardingDataCopyWithImpl;
@override @useResult
$Res call({
 int step, String phoneNumber, String? verificationId, String firstName, String lastName, DateTime? dateOfBirth, Gender? gender, SexualOrientation? sexualOrientation, List<Gender> interestedInGenders
});




}
/// @nodoc
class __$OnboardingDataCopyWithImpl<$Res>
    implements _$OnboardingDataCopyWith<$Res> {
  __$OnboardingDataCopyWithImpl(this._self, this._then);

  final _OnboardingData _self;
  final $Res Function(_OnboardingData) _then;

/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? phoneNumber = null,Object? verificationId = freezed,Object? firstName = null,Object? lastName = null,Object? dateOfBirth = freezed,Object? gender = freezed,Object? sexualOrientation = freezed,Object? interestedInGenders = null,}) {
  return _then(_OnboardingData(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as int,phoneNumber: null == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String,verificationId: freezed == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String?,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: null == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as DateTime?,gender: freezed == gender ? _self.gender : gender // ignore: cast_nullable_to_non_nullable
as Gender?,sexualOrientation: freezed == sexualOrientation ? _self.sexualOrientation : sexualOrientation // ignore: cast_nullable_to_non_nullable
as SexualOrientation?,interestedInGenders: null == interestedInGenders ? _self._interestedInGenders : interestedInGenders // ignore: cast_nullable_to_non_nullable
as List<Gender>,
  ));
}


}

// dart format on
