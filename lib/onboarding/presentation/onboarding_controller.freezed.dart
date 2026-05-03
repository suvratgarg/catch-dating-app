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
mixin _$OnboardingData implements DiagnosticableTreeMixin {

 OnboardingStep get step; bool get phoneVerified; String? get verificationId; OnboardingProfileDraft get profileDraft;
/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OnboardingDataCopyWith<OnboardingData> get copyWith => _$OnboardingDataCopyWithImpl<OnboardingData>(this as OnboardingData, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'OnboardingData'))
    ..add(DiagnosticsProperty('step', step))..add(DiagnosticsProperty('phoneVerified', phoneVerified))..add(DiagnosticsProperty('verificationId', verificationId))..add(DiagnosticsProperty('profileDraft', profileDraft));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnboardingData&&(identical(other.step, step) || other.step == step)&&(identical(other.phoneVerified, phoneVerified) || other.phoneVerified == phoneVerified)&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId)&&(identical(other.profileDraft, profileDraft) || other.profileDraft == profileDraft));
}


@override
int get hashCode => Object.hash(runtimeType,step,phoneVerified,verificationId,profileDraft);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'OnboardingData(step: $step, phoneVerified: $phoneVerified, verificationId: $verificationId, profileDraft: $profileDraft)';
}


}

/// @nodoc
abstract mixin class $OnboardingDataCopyWith<$Res>  {
  factory $OnboardingDataCopyWith(OnboardingData value, $Res Function(OnboardingData) _then) = _$OnboardingDataCopyWithImpl;
@useResult
$Res call({
 OnboardingStep step, bool phoneVerified, String? verificationId, OnboardingProfileDraft profileDraft
});


$OnboardingProfileDraftCopyWith<$Res> get profileDraft;

}
/// @nodoc
class _$OnboardingDataCopyWithImpl<$Res>
    implements $OnboardingDataCopyWith<$Res> {
  _$OnboardingDataCopyWithImpl(this._self, this._then);

  final OnboardingData _self;
  final $Res Function(OnboardingData) _then;

/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? step = null,Object? phoneVerified = null,Object? verificationId = freezed,Object? profileDraft = null,}) {
  return _then(_self.copyWith(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as OnboardingStep,phoneVerified: null == phoneVerified ? _self.phoneVerified : phoneVerified // ignore: cast_nullable_to_non_nullable
as bool,verificationId: freezed == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String?,profileDraft: null == profileDraft ? _self.profileDraft : profileDraft // ignore: cast_nullable_to_non_nullable
as OnboardingProfileDraft,
  ));
}
/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OnboardingProfileDraftCopyWith<$Res> get profileDraft {
  
  return $OnboardingProfileDraftCopyWith<$Res>(_self.profileDraft, (value) {
    return _then(_self.copyWith(profileDraft: value));
  });
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( OnboardingStep step,  bool phoneVerified,  String? verificationId,  OnboardingProfileDraft profileDraft)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
return $default(_that.step,_that.phoneVerified,_that.verificationId,_that.profileDraft);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( OnboardingStep step,  bool phoneVerified,  String? verificationId,  OnboardingProfileDraft profileDraft)  $default,) {final _that = this;
switch (_that) {
case _OnboardingData():
return $default(_that.step,_that.phoneVerified,_that.verificationId,_that.profileDraft);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( OnboardingStep step,  bool phoneVerified,  String? verificationId,  OnboardingProfileDraft profileDraft)?  $default,) {final _that = this;
switch (_that) {
case _OnboardingData() when $default != null:
return $default(_that.step,_that.phoneVerified,_that.verificationId,_that.profileDraft);case _:
  return null;

}
}

}

/// @nodoc


class _OnboardingData extends OnboardingData with DiagnosticableTreeMixin {
  const _OnboardingData({this.step = OnboardingStep.welcome, this.phoneVerified = false, this.verificationId, this.profileDraft = const OnboardingProfileDraft()}): super._();
  

@override@JsonKey() final  OnboardingStep step;
@override@JsonKey() final  bool phoneVerified;
@override final  String? verificationId;
@override@JsonKey() final  OnboardingProfileDraft profileDraft;

/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OnboardingDataCopyWith<_OnboardingData> get copyWith => __$OnboardingDataCopyWithImpl<_OnboardingData>(this, _$identity);


@override
void debugFillProperties(DiagnosticPropertiesBuilder properties) {
  properties
    ..add(DiagnosticsProperty('type', 'OnboardingData'))
    ..add(DiagnosticsProperty('step', step))..add(DiagnosticsProperty('phoneVerified', phoneVerified))..add(DiagnosticsProperty('verificationId', verificationId))..add(DiagnosticsProperty('profileDraft', profileDraft));
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OnboardingData&&(identical(other.step, step) || other.step == step)&&(identical(other.phoneVerified, phoneVerified) || other.phoneVerified == phoneVerified)&&(identical(other.verificationId, verificationId) || other.verificationId == verificationId)&&(identical(other.profileDraft, profileDraft) || other.profileDraft == profileDraft));
}


@override
int get hashCode => Object.hash(runtimeType,step,phoneVerified,verificationId,profileDraft);

@override
String toString({ DiagnosticLevel minLevel = DiagnosticLevel.info }) {
  return 'OnboardingData(step: $step, phoneVerified: $phoneVerified, verificationId: $verificationId, profileDraft: $profileDraft)';
}


}

/// @nodoc
abstract mixin class _$OnboardingDataCopyWith<$Res> implements $OnboardingDataCopyWith<$Res> {
  factory _$OnboardingDataCopyWith(_OnboardingData value, $Res Function(_OnboardingData) _then) = __$OnboardingDataCopyWithImpl;
@override @useResult
$Res call({
 OnboardingStep step, bool phoneVerified, String? verificationId, OnboardingProfileDraft profileDraft
});


@override $OnboardingProfileDraftCopyWith<$Res> get profileDraft;

}
/// @nodoc
class __$OnboardingDataCopyWithImpl<$Res>
    implements _$OnboardingDataCopyWith<$Res> {
  __$OnboardingDataCopyWithImpl(this._self, this._then);

  final _OnboardingData _self;
  final $Res Function(_OnboardingData) _then;

/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? step = null,Object? phoneVerified = null,Object? verificationId = freezed,Object? profileDraft = null,}) {
  return _then(_OnboardingData(
step: null == step ? _self.step : step // ignore: cast_nullable_to_non_nullable
as OnboardingStep,phoneVerified: null == phoneVerified ? _self.phoneVerified : phoneVerified // ignore: cast_nullable_to_non_nullable
as bool,verificationId: freezed == verificationId ? _self.verificationId : verificationId // ignore: cast_nullable_to_non_nullable
as String?,profileDraft: null == profileDraft ? _self.profileDraft : profileDraft // ignore: cast_nullable_to_non_nullable
as OnboardingProfileDraft,
  ));
}

/// Create a copy of OnboardingData
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$OnboardingProfileDraftCopyWith<$Res> get profileDraft {
  
  return $OnboardingProfileDraftCopyWith<$Res>(_self.profileDraft, (value) {
    return _then(_self.copyWith(profileDraft: value));
  });
}
}

// dart format on
