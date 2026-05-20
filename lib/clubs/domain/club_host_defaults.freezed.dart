// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_host_defaults.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ClubHostDefaults {

 EventPolicyDefaults get eventPolicy; EventSuccessDefaults get eventSuccess;
/// Create a copy of ClubHostDefaults
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubHostDefaultsCopyWith<ClubHostDefaults> get copyWith => _$ClubHostDefaultsCopyWithImpl<ClubHostDefaults>(this as ClubHostDefaults, _$identity);

  /// Serializes this ClubHostDefaults to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubHostDefaults&&(identical(other.eventPolicy, eventPolicy) || other.eventPolicy == eventPolicy)&&(identical(other.eventSuccess, eventSuccess) || other.eventSuccess == eventSuccess));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventPolicy,eventSuccess);

@override
String toString() {
  return 'ClubHostDefaults(eventPolicy: $eventPolicy, eventSuccess: $eventSuccess)';
}


}

/// @nodoc
abstract mixin class $ClubHostDefaultsCopyWith<$Res>  {
  factory $ClubHostDefaultsCopyWith(ClubHostDefaults value, $Res Function(ClubHostDefaults) _then) = _$ClubHostDefaultsCopyWithImpl;
@useResult
$Res call({
 EventPolicyDefaults eventPolicy, EventSuccessDefaults eventSuccess
});


$EventPolicyDefaultsCopyWith<$Res> get eventPolicy;$EventSuccessDefaultsCopyWith<$Res> get eventSuccess;

}
/// @nodoc
class _$ClubHostDefaultsCopyWithImpl<$Res>
    implements $ClubHostDefaultsCopyWith<$Res> {
  _$ClubHostDefaultsCopyWithImpl(this._self, this._then);

  final ClubHostDefaults _self;
  final $Res Function(ClubHostDefaults) _then;

/// Create a copy of ClubHostDefaults
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? eventPolicy = null,Object? eventSuccess = null,}) {
  return _then(_self.copyWith(
eventPolicy: null == eventPolicy ? _self.eventPolicy : eventPolicy // ignore: cast_nullable_to_non_nullable
as EventPolicyDefaults,eventSuccess: null == eventSuccess ? _self.eventSuccess : eventSuccess // ignore: cast_nullable_to_non_nullable
as EventSuccessDefaults,
  ));
}
/// Create a copy of ClubHostDefaults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventPolicyDefaultsCopyWith<$Res> get eventPolicy {
  
  return $EventPolicyDefaultsCopyWith<$Res>(_self.eventPolicy, (value) {
    return _then(_self.copyWith(eventPolicy: value));
  });
}/// Create a copy of ClubHostDefaults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventSuccessDefaultsCopyWith<$Res> get eventSuccess {
  
  return $EventSuccessDefaultsCopyWith<$Res>(_self.eventSuccess, (value) {
    return _then(_self.copyWith(eventSuccess: value));
  });
}
}


/// Adds pattern-matching-related methods to [ClubHostDefaults].
extension ClubHostDefaultsPatterns on ClubHostDefaults {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubHostDefaults value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubHostDefaults() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubHostDefaults value)  $default,){
final _that = this;
switch (_that) {
case _ClubHostDefaults():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubHostDefaults value)?  $default,){
final _that = this;
switch (_that) {
case _ClubHostDefaults() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EventPolicyDefaults eventPolicy,  EventSuccessDefaults eventSuccess)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubHostDefaults() when $default != null:
return $default(_that.eventPolicy,_that.eventSuccess);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EventPolicyDefaults eventPolicy,  EventSuccessDefaults eventSuccess)  $default,) {final _that = this;
switch (_that) {
case _ClubHostDefaults():
return $default(_that.eventPolicy,_that.eventSuccess);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EventPolicyDefaults eventPolicy,  EventSuccessDefaults eventSuccess)?  $default,) {final _that = this;
switch (_that) {
case _ClubHostDefaults() when $default != null:
return $default(_that.eventPolicy,_that.eventSuccess);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ClubHostDefaults implements ClubHostDefaults {
  const _ClubHostDefaults({this.eventPolicy = const EventPolicyDefaults(), this.eventSuccess = const EventSuccessDefaults()});
  factory _ClubHostDefaults.fromJson(Map<String, dynamic> json) => _$ClubHostDefaultsFromJson(json);

@override@JsonKey() final  EventPolicyDefaults eventPolicy;
@override@JsonKey() final  EventSuccessDefaults eventSuccess;

/// Create a copy of ClubHostDefaults
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubHostDefaultsCopyWith<_ClubHostDefaults> get copyWith => __$ClubHostDefaultsCopyWithImpl<_ClubHostDefaults>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClubHostDefaultsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubHostDefaults&&(identical(other.eventPolicy, eventPolicy) || other.eventPolicy == eventPolicy)&&(identical(other.eventSuccess, eventSuccess) || other.eventSuccess == eventSuccess));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,eventPolicy,eventSuccess);

@override
String toString() {
  return 'ClubHostDefaults(eventPolicy: $eventPolicy, eventSuccess: $eventSuccess)';
}


}

/// @nodoc
abstract mixin class _$ClubHostDefaultsCopyWith<$Res> implements $ClubHostDefaultsCopyWith<$Res> {
  factory _$ClubHostDefaultsCopyWith(_ClubHostDefaults value, $Res Function(_ClubHostDefaults) _then) = __$ClubHostDefaultsCopyWithImpl;
@override @useResult
$Res call({
 EventPolicyDefaults eventPolicy, EventSuccessDefaults eventSuccess
});


@override $EventPolicyDefaultsCopyWith<$Res> get eventPolicy;@override $EventSuccessDefaultsCopyWith<$Res> get eventSuccess;

}
/// @nodoc
class __$ClubHostDefaultsCopyWithImpl<$Res>
    implements _$ClubHostDefaultsCopyWith<$Res> {
  __$ClubHostDefaultsCopyWithImpl(this._self, this._then);

  final _ClubHostDefaults _self;
  final $Res Function(_ClubHostDefaults) _then;

/// Create a copy of ClubHostDefaults
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? eventPolicy = null,Object? eventSuccess = null,}) {
  return _then(_ClubHostDefaults(
eventPolicy: null == eventPolicy ? _self.eventPolicy : eventPolicy // ignore: cast_nullable_to_non_nullable
as EventPolicyDefaults,eventSuccess: null == eventSuccess ? _self.eventSuccess : eventSuccess // ignore: cast_nullable_to_non_nullable
as EventSuccessDefaults,
  ));
}

/// Create a copy of ClubHostDefaults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventPolicyDefaultsCopyWith<$Res> get eventPolicy {
  
  return $EventPolicyDefaultsCopyWith<$Res>(_self.eventPolicy, (value) {
    return _then(_self.copyWith(eventPolicy: value));
  });
}/// Create a copy of ClubHostDefaults
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventSuccessDefaultsCopyWith<$Res> get eventSuccess {
  
  return $EventSuccessDefaultsCopyWith<$Res>(_self.eventSuccess, (value) {
    return _then(_self.copyWith(eventSuccess: value));
  });
}
}

// dart format on
