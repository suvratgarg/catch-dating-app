// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_version_config.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppVersionConfig {

 String get minVersion; String get storeUrlAndroid; String get storeUrlIos;
/// Create a copy of AppVersionConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppVersionConfigCopyWith<AppVersionConfig> get copyWith => _$AppVersionConfigCopyWithImpl<AppVersionConfig>(this as AppVersionConfig, _$identity);

  /// Serializes this AppVersionConfig to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppVersionConfig&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&(identical(other.storeUrlAndroid, storeUrlAndroid) || other.storeUrlAndroid == storeUrlAndroid)&&(identical(other.storeUrlIos, storeUrlIos) || other.storeUrlIos == storeUrlIos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minVersion,storeUrlAndroid,storeUrlIos);

@override
String toString() {
  return 'AppVersionConfig(minVersion: $minVersion, storeUrlAndroid: $storeUrlAndroid, storeUrlIos: $storeUrlIos)';
}


}

/// @nodoc
abstract mixin class $AppVersionConfigCopyWith<$Res>  {
  factory $AppVersionConfigCopyWith(AppVersionConfig value, $Res Function(AppVersionConfig) _then) = _$AppVersionConfigCopyWithImpl;
@useResult
$Res call({
 String minVersion, String storeUrlAndroid, String storeUrlIos
});




}
/// @nodoc
class _$AppVersionConfigCopyWithImpl<$Res>
    implements $AppVersionConfigCopyWith<$Res> {
  _$AppVersionConfigCopyWithImpl(this._self, this._then);

  final AppVersionConfig _self;
  final $Res Function(AppVersionConfig) _then;

/// Create a copy of AppVersionConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? minVersion = null,Object? storeUrlAndroid = null,Object? storeUrlIos = null,}) {
  return _then(_self.copyWith(
minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,storeUrlAndroid: null == storeUrlAndroid ? _self.storeUrlAndroid : storeUrlAndroid // ignore: cast_nullable_to_non_nullable
as String,storeUrlIos: null == storeUrlIos ? _self.storeUrlIos : storeUrlIos // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [AppVersionConfig].
extension AppVersionConfigPatterns on AppVersionConfig {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppVersionConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppVersionConfig() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppVersionConfig value)  $default,){
final _that = this;
switch (_that) {
case _AppVersionConfig():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppVersionConfig value)?  $default,){
final _that = this;
switch (_that) {
case _AppVersionConfig() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String minVersion,  String storeUrlAndroid,  String storeUrlIos)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppVersionConfig() when $default != null:
return $default(_that.minVersion,_that.storeUrlAndroid,_that.storeUrlIos);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String minVersion,  String storeUrlAndroid,  String storeUrlIos)  $default,) {final _that = this;
switch (_that) {
case _AppVersionConfig():
return $default(_that.minVersion,_that.storeUrlAndroid,_that.storeUrlIos);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String minVersion,  String storeUrlAndroid,  String storeUrlIos)?  $default,) {final _that = this;
switch (_that) {
case _AppVersionConfig() when $default != null:
return $default(_that.minVersion,_that.storeUrlAndroid,_that.storeUrlIos);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppVersionConfig implements AppVersionConfig {
  const _AppVersionConfig({this.minVersion = '0.0.0', this.storeUrlAndroid = '', this.storeUrlIos = ''});
  factory _AppVersionConfig.fromJson(Map<String, dynamic> json) => _$AppVersionConfigFromJson(json);

@override@JsonKey() final  String minVersion;
@override@JsonKey() final  String storeUrlAndroid;
@override@JsonKey() final  String storeUrlIos;

/// Create a copy of AppVersionConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppVersionConfigCopyWith<_AppVersionConfig> get copyWith => __$AppVersionConfigCopyWithImpl<_AppVersionConfig>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppVersionConfigToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppVersionConfig&&(identical(other.minVersion, minVersion) || other.minVersion == minVersion)&&(identical(other.storeUrlAndroid, storeUrlAndroid) || other.storeUrlAndroid == storeUrlAndroid)&&(identical(other.storeUrlIos, storeUrlIos) || other.storeUrlIos == storeUrlIos));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,minVersion,storeUrlAndroid,storeUrlIos);

@override
String toString() {
  return 'AppVersionConfig(minVersion: $minVersion, storeUrlAndroid: $storeUrlAndroid, storeUrlIos: $storeUrlIos)';
}


}

/// @nodoc
abstract mixin class _$AppVersionConfigCopyWith<$Res> implements $AppVersionConfigCopyWith<$Res> {
  factory _$AppVersionConfigCopyWith(_AppVersionConfig value, $Res Function(_AppVersionConfig) _then) = __$AppVersionConfigCopyWithImpl;
@override @useResult
$Res call({
 String minVersion, String storeUrlAndroid, String storeUrlIos
});




}
/// @nodoc
class __$AppVersionConfigCopyWithImpl<$Res>
    implements _$AppVersionConfigCopyWith<$Res> {
  __$AppVersionConfigCopyWithImpl(this._self, this._then);

  final _AppVersionConfig _self;
  final $Res Function(_AppVersionConfig) _then;

/// Create a copy of AppVersionConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? minVersion = null,Object? storeUrlAndroid = null,Object? storeUrlIos = null,}) {
  return _then(_AppVersionConfig(
minVersion: null == minVersion ? _self.minVersion : minVersion // ignore: cast_nullable_to_non_nullable
as String,storeUrlAndroid: null == storeUrlAndroid ? _self.storeUrlAndroid : storeUrlAndroid // ignore: cast_nullable_to_non_nullable
as String,storeUrlIos: null == storeUrlIos ? _self.storeUrlIos : storeUrlIos // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
