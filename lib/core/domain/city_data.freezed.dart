// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'city_data.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CityData {

/// Machine name, e.g. `'mumbai'`, `'delhi'`, or lowercase kebab-case for
/// newer city regions. City names must stay globally unique.
 String get name;/// Human-readable label (e.g. `'Mumbai'`, `'New Delhi'`).
 String get label;/// Latitude for GPS-based nearest-city detection.
 double get latitude;/// Longitude for GPS-based nearest-city detection.
 double get longitude;/// ISO 3166-1 alpha-2 country code for market-specific behavior.
 String get countryIsoCode;/// Currency used for event price display and future provider routing.
 String get currencyCode;/// Local phone dial code used for contact/auth defaults in this market.
 String get dialCode;/// IANA timezone for event scheduling and future localized display.
 String get timeZone;
/// Create a copy of CityData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CityDataCopyWith<CityData> get copyWith => _$CityDataCopyWithImpl<CityData>(this as CityData, _$identity);

  /// Serializes this CityData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CityData&&(identical(other.name, name) || other.name == name)&&(identical(other.label, label) || other.label == label)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.countryIsoCode, countryIsoCode) || other.countryIsoCode == countryIsoCode)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.dialCode, dialCode) || other.dialCode == dialCode)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,label,latitude,longitude,countryIsoCode,currencyCode,dialCode,timeZone);

@override
String toString() {
  return 'CityData(name: $name, label: $label, latitude: $latitude, longitude: $longitude, countryIsoCode: $countryIsoCode, currencyCode: $currencyCode, dialCode: $dialCode, timeZone: $timeZone)';
}


}

/// @nodoc
abstract mixin class $CityDataCopyWith<$Res>  {
  factory $CityDataCopyWith(CityData value, $Res Function(CityData) _then) = _$CityDataCopyWithImpl;
@useResult
$Res call({
 String name, String label, double latitude, double longitude, String countryIsoCode, String currencyCode, String dialCode, String timeZone
});




}
/// @nodoc
class _$CityDataCopyWithImpl<$Res>
    implements $CityDataCopyWith<$Res> {
  _$CityDataCopyWithImpl(this._self, this._then);

  final CityData _self;
  final $Res Function(CityData) _then;

/// Create a copy of CityData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? label = null,Object? latitude = null,Object? longitude = null,Object? countryIsoCode = null,Object? currencyCode = null,Object? dialCode = null,Object? timeZone = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,countryIsoCode: null == countryIsoCode ? _self.countryIsoCode : countryIsoCode // ignore: cast_nullable_to_non_nullable
as String,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,dialCode: null == dialCode ? _self.dialCode : dialCode // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [CityData].
extension CityDataPatterns on CityData {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CityData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CityData() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CityData value)  $default,){
final _that = this;
switch (_that) {
case _CityData():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CityData value)?  $default,){
final _that = this;
switch (_that) {
case _CityData() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String label,  double latitude,  double longitude,  String countryIsoCode,  String currencyCode,  String dialCode,  String timeZone)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CityData() when $default != null:
return $default(_that.name,_that.label,_that.latitude,_that.longitude,_that.countryIsoCode,_that.currencyCode,_that.dialCode,_that.timeZone);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String label,  double latitude,  double longitude,  String countryIsoCode,  String currencyCode,  String dialCode,  String timeZone)  $default,) {final _that = this;
switch (_that) {
case _CityData():
return $default(_that.name,_that.label,_that.latitude,_that.longitude,_that.countryIsoCode,_that.currencyCode,_that.dialCode,_that.timeZone);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String label,  double latitude,  double longitude,  String countryIsoCode,  String currencyCode,  String dialCode,  String timeZone)?  $default,) {final _that = this;
switch (_that) {
case _CityData() when $default != null:
return $default(_that.name,_that.label,_that.latitude,_that.longitude,_that.countryIsoCode,_that.currencyCode,_that.dialCode,_that.timeZone);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CityData implements CityData {
  const _CityData({required this.name, required this.label, required this.latitude, required this.longitude, this.countryIsoCode = defaultCountryIsoCode, this.currencyCode = defaultCurrencyCode, this.dialCode = defaultCountryDialCode, this.timeZone = defaultTimeZone});
  factory _CityData.fromJson(Map<String, dynamic> json) => _$CityDataFromJson(json);

/// Machine name, e.g. `'mumbai'`, `'delhi'`, or lowercase kebab-case for
/// newer city regions. City names must stay globally unique.
@override final  String name;
/// Human-readable label (e.g. `'Mumbai'`, `'New Delhi'`).
@override final  String label;
/// Latitude for GPS-based nearest-city detection.
@override final  double latitude;
/// Longitude for GPS-based nearest-city detection.
@override final  double longitude;
/// ISO 3166-1 alpha-2 country code for market-specific behavior.
@override@JsonKey() final  String countryIsoCode;
/// Currency used for event price display and future provider routing.
@override@JsonKey() final  String currencyCode;
/// Local phone dial code used for contact/auth defaults in this market.
@override@JsonKey() final  String dialCode;
/// IANA timezone for event scheduling and future localized display.
@override@JsonKey() final  String timeZone;

/// Create a copy of CityData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CityDataCopyWith<_CityData> get copyWith => __$CityDataCopyWithImpl<_CityData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CityDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CityData&&(identical(other.name, name) || other.name == name)&&(identical(other.label, label) || other.label == label)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.countryIsoCode, countryIsoCode) || other.countryIsoCode == countryIsoCode)&&(identical(other.currencyCode, currencyCode) || other.currencyCode == currencyCode)&&(identical(other.dialCode, dialCode) || other.dialCode == dialCode)&&(identical(other.timeZone, timeZone) || other.timeZone == timeZone));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,label,latitude,longitude,countryIsoCode,currencyCode,dialCode,timeZone);

@override
String toString() {
  return 'CityData(name: $name, label: $label, latitude: $latitude, longitude: $longitude, countryIsoCode: $countryIsoCode, currencyCode: $currencyCode, dialCode: $dialCode, timeZone: $timeZone)';
}


}

/// @nodoc
abstract mixin class _$CityDataCopyWith<$Res> implements $CityDataCopyWith<$Res> {
  factory _$CityDataCopyWith(_CityData value, $Res Function(_CityData) _then) = __$CityDataCopyWithImpl;
@override @useResult
$Res call({
 String name, String label, double latitude, double longitude, String countryIsoCode, String currencyCode, String dialCode, String timeZone
});




}
/// @nodoc
class __$CityDataCopyWithImpl<$Res>
    implements _$CityDataCopyWith<$Res> {
  __$CityDataCopyWithImpl(this._self, this._then);

  final _CityData _self;
  final $Res Function(_CityData) _then;

/// Create a copy of CityData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? label = null,Object? latitude = null,Object? longitude = null,Object? countryIsoCode = null,Object? currencyCode = null,Object? dialCode = null,Object? timeZone = null,}) {
  return _then(_CityData(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,countryIsoCode: null == countryIsoCode ? _self.countryIsoCode : countryIsoCode // ignore: cast_nullable_to_non_nullable
as String,currencyCode: null == currencyCode ? _self.currencyCode : currencyCode // ignore: cast_nullable_to_non_nullable
as String,dialCode: null == dialCode ? _self.dialCode : dialCode // ignore: cast_nullable_to_non_nullable
as String,timeZone: null == timeZone ? _self.timeZone : timeZone // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
