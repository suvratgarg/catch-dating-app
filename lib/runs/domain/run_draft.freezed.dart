// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RunDraft {

 String get id; String get runClubId; DateTime get savedAt;// Run Details step
 String? get distance; String? get capacity; String? get price; String? get description; String? get paceName;// Where step
 String? get meetingPoint; String? get locationDetails; double? get startingPointLat; double? get startingPointLng;// When step
 int? get selectedDateMillis; int? get selectedStartHour; int? get selectedStartMinute; int get durationMinutes;// Rules step
 String? get minAge; String? get maxAge; String? get maxMen; String? get maxWomen;
/// Create a copy of RunDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunDraftCopyWith<RunDraft> get copyWith => _$RunDraftCopyWithImpl<RunDraft>(this as RunDraft, _$identity);

  /// Serializes this RunDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.runClubId, runClubId) || other.runClubId == runClubId)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.paceName, paceName) || other.paceName == paceName)&&(identical(other.meetingPoint, meetingPoint) || other.meetingPoint == meetingPoint)&&(identical(other.locationDetails, locationDetails) || other.locationDetails == locationDetails)&&(identical(other.startingPointLat, startingPointLat) || other.startingPointLat == startingPointLat)&&(identical(other.startingPointLng, startingPointLng) || other.startingPointLng == startingPointLng)&&(identical(other.selectedDateMillis, selectedDateMillis) || other.selectedDateMillis == selectedDateMillis)&&(identical(other.selectedStartHour, selectedStartHour) || other.selectedStartHour == selectedStartHour)&&(identical(other.selectedStartMinute, selectedStartMinute) || other.selectedStartMinute == selectedStartMinute)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.minAge, minAge) || other.minAge == minAge)&&(identical(other.maxAge, maxAge) || other.maxAge == maxAge)&&(identical(other.maxMen, maxMen) || other.maxMen == maxMen)&&(identical(other.maxWomen, maxWomen) || other.maxWomen == maxWomen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,runClubId,savedAt,distance,capacity,price,description,paceName,meetingPoint,locationDetails,startingPointLat,startingPointLng,selectedDateMillis,selectedStartHour,selectedStartMinute,durationMinutes,minAge,maxAge,maxMen,maxWomen]);

@override
String toString() {
  return 'RunDraft(id: $id, runClubId: $runClubId, savedAt: $savedAt, distance: $distance, capacity: $capacity, price: $price, description: $description, paceName: $paceName, meetingPoint: $meetingPoint, locationDetails: $locationDetails, startingPointLat: $startingPointLat, startingPointLng: $startingPointLng, selectedDateMillis: $selectedDateMillis, selectedStartHour: $selectedStartHour, selectedStartMinute: $selectedStartMinute, durationMinutes: $durationMinutes, minAge: $minAge, maxAge: $maxAge, maxMen: $maxMen, maxWomen: $maxWomen)';
}


}

/// @nodoc
abstract mixin class $RunDraftCopyWith<$Res>  {
  factory $RunDraftCopyWith(RunDraft value, $Res Function(RunDraft) _then) = _$RunDraftCopyWithImpl;
@useResult
$Res call({
 String id, String runClubId, DateTime savedAt, String? distance, String? capacity, String? price, String? description, String? paceName, String? meetingPoint, String? locationDetails, double? startingPointLat, double? startingPointLng, int? selectedDateMillis, int? selectedStartHour, int? selectedStartMinute, int durationMinutes, String? minAge, String? maxAge, String? maxMen, String? maxWomen
});




}
/// @nodoc
class _$RunDraftCopyWithImpl<$Res>
    implements $RunDraftCopyWith<$Res> {
  _$RunDraftCopyWithImpl(this._self, this._then);

  final RunDraft _self;
  final $Res Function(RunDraft) _then;

/// Create a copy of RunDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? runClubId = null,Object? savedAt = null,Object? distance = freezed,Object? capacity = freezed,Object? price = freezed,Object? description = freezed,Object? paceName = freezed,Object? meetingPoint = freezed,Object? locationDetails = freezed,Object? startingPointLat = freezed,Object? startingPointLng = freezed,Object? selectedDateMillis = freezed,Object? selectedStartHour = freezed,Object? selectedStartMinute = freezed,Object? durationMinutes = null,Object? minAge = freezed,Object? maxAge = freezed,Object? maxMen = freezed,Object? maxWomen = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,runClubId: null == runClubId ? _self.runClubId : runClubId // ignore: cast_nullable_to_non_nullable
as String,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as String?,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,paceName: freezed == paceName ? _self.paceName : paceName // ignore: cast_nullable_to_non_nullable
as String?,meetingPoint: freezed == meetingPoint ? _self.meetingPoint : meetingPoint // ignore: cast_nullable_to_non_nullable
as String?,locationDetails: freezed == locationDetails ? _self.locationDetails : locationDetails // ignore: cast_nullable_to_non_nullable
as String?,startingPointLat: freezed == startingPointLat ? _self.startingPointLat : startingPointLat // ignore: cast_nullable_to_non_nullable
as double?,startingPointLng: freezed == startingPointLng ? _self.startingPointLng : startingPointLng // ignore: cast_nullable_to_non_nullable
as double?,selectedDateMillis: freezed == selectedDateMillis ? _self.selectedDateMillis : selectedDateMillis // ignore: cast_nullable_to_non_nullable
as int?,selectedStartHour: freezed == selectedStartHour ? _self.selectedStartHour : selectedStartHour // ignore: cast_nullable_to_non_nullable
as int?,selectedStartMinute: freezed == selectedStartMinute ? _self.selectedStartMinute : selectedStartMinute // ignore: cast_nullable_to_non_nullable
as int?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,minAge: freezed == minAge ? _self.minAge : minAge // ignore: cast_nullable_to_non_nullable
as String?,maxAge: freezed == maxAge ? _self.maxAge : maxAge // ignore: cast_nullable_to_non_nullable
as String?,maxMen: freezed == maxMen ? _self.maxMen : maxMen // ignore: cast_nullable_to_non_nullable
as String?,maxWomen: freezed == maxWomen ? _self.maxWomen : maxWomen // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RunDraft].
extension RunDraftPatterns on RunDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunDraft value)  $default,){
final _that = this;
switch (_that) {
case _RunDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunDraft value)?  $default,){
final _that = this;
switch (_that) {
case _RunDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String runClubId,  DateTime savedAt,  String? distance,  String? capacity,  String? price,  String? description,  String? paceName,  String? meetingPoint,  String? locationDetails,  double? startingPointLat,  double? startingPointLng,  int? selectedDateMillis,  int? selectedStartHour,  int? selectedStartMinute,  int durationMinutes,  String? minAge,  String? maxAge,  String? maxMen,  String? maxWomen)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunDraft() when $default != null:
return $default(_that.id,_that.runClubId,_that.savedAt,_that.distance,_that.capacity,_that.price,_that.description,_that.paceName,_that.meetingPoint,_that.locationDetails,_that.startingPointLat,_that.startingPointLng,_that.selectedDateMillis,_that.selectedStartHour,_that.selectedStartMinute,_that.durationMinutes,_that.minAge,_that.maxAge,_that.maxMen,_that.maxWomen);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String runClubId,  DateTime savedAt,  String? distance,  String? capacity,  String? price,  String? description,  String? paceName,  String? meetingPoint,  String? locationDetails,  double? startingPointLat,  double? startingPointLng,  int? selectedDateMillis,  int? selectedStartHour,  int? selectedStartMinute,  int durationMinutes,  String? minAge,  String? maxAge,  String? maxMen,  String? maxWomen)  $default,) {final _that = this;
switch (_that) {
case _RunDraft():
return $default(_that.id,_that.runClubId,_that.savedAt,_that.distance,_that.capacity,_that.price,_that.description,_that.paceName,_that.meetingPoint,_that.locationDetails,_that.startingPointLat,_that.startingPointLng,_that.selectedDateMillis,_that.selectedStartHour,_that.selectedStartMinute,_that.durationMinutes,_that.minAge,_that.maxAge,_that.maxMen,_that.maxWomen);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String runClubId,  DateTime savedAt,  String? distance,  String? capacity,  String? price,  String? description,  String? paceName,  String? meetingPoint,  String? locationDetails,  double? startingPointLat,  double? startingPointLng,  int? selectedDateMillis,  int? selectedStartHour,  int? selectedStartMinute,  int durationMinutes,  String? minAge,  String? maxAge,  String? maxMen,  String? maxWomen)?  $default,) {final _that = this;
switch (_that) {
case _RunDraft() when $default != null:
return $default(_that.id,_that.runClubId,_that.savedAt,_that.distance,_that.capacity,_that.price,_that.description,_that.paceName,_that.meetingPoint,_that.locationDetails,_that.startingPointLat,_that.startingPointLng,_that.selectedDateMillis,_that.selectedStartHour,_that.selectedStartMinute,_that.durationMinutes,_that.minAge,_that.maxAge,_that.maxMen,_that.maxWomen);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RunDraft implements RunDraft {
  const _RunDraft({required this.id, required this.runClubId, required this.savedAt, this.distance, this.capacity, this.price, this.description, this.paceName, this.meetingPoint, this.locationDetails, this.startingPointLat, this.startingPointLng, this.selectedDateMillis, this.selectedStartHour, this.selectedStartMinute, this.durationMinutes = 60, this.minAge, this.maxAge, this.maxMen, this.maxWomen});
  factory _RunDraft.fromJson(Map<String, dynamic> json) => _$RunDraftFromJson(json);

@override final  String id;
@override final  String runClubId;
@override final  DateTime savedAt;
// Run Details step
@override final  String? distance;
@override final  String? capacity;
@override final  String? price;
@override final  String? description;
@override final  String? paceName;
// Where step
@override final  String? meetingPoint;
@override final  String? locationDetails;
@override final  double? startingPointLat;
@override final  double? startingPointLng;
// When step
@override final  int? selectedDateMillis;
@override final  int? selectedStartHour;
@override final  int? selectedStartMinute;
@override@JsonKey() final  int durationMinutes;
// Rules step
@override final  String? minAge;
@override final  String? maxAge;
@override final  String? maxMen;
@override final  String? maxWomen;

/// Create a copy of RunDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunDraftCopyWith<_RunDraft> get copyWith => __$RunDraftCopyWithImpl<_RunDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RunDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.runClubId, runClubId) || other.runClubId == runClubId)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.paceName, paceName) || other.paceName == paceName)&&(identical(other.meetingPoint, meetingPoint) || other.meetingPoint == meetingPoint)&&(identical(other.locationDetails, locationDetails) || other.locationDetails == locationDetails)&&(identical(other.startingPointLat, startingPointLat) || other.startingPointLat == startingPointLat)&&(identical(other.startingPointLng, startingPointLng) || other.startingPointLng == startingPointLng)&&(identical(other.selectedDateMillis, selectedDateMillis) || other.selectedDateMillis == selectedDateMillis)&&(identical(other.selectedStartHour, selectedStartHour) || other.selectedStartHour == selectedStartHour)&&(identical(other.selectedStartMinute, selectedStartMinute) || other.selectedStartMinute == selectedStartMinute)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.minAge, minAge) || other.minAge == minAge)&&(identical(other.maxAge, maxAge) || other.maxAge == maxAge)&&(identical(other.maxMen, maxMen) || other.maxMen == maxMen)&&(identical(other.maxWomen, maxWomen) || other.maxWomen == maxWomen));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,runClubId,savedAt,distance,capacity,price,description,paceName,meetingPoint,locationDetails,startingPointLat,startingPointLng,selectedDateMillis,selectedStartHour,selectedStartMinute,durationMinutes,minAge,maxAge,maxMen,maxWomen]);

@override
String toString() {
  return 'RunDraft(id: $id, runClubId: $runClubId, savedAt: $savedAt, distance: $distance, capacity: $capacity, price: $price, description: $description, paceName: $paceName, meetingPoint: $meetingPoint, locationDetails: $locationDetails, startingPointLat: $startingPointLat, startingPointLng: $startingPointLng, selectedDateMillis: $selectedDateMillis, selectedStartHour: $selectedStartHour, selectedStartMinute: $selectedStartMinute, durationMinutes: $durationMinutes, minAge: $minAge, maxAge: $maxAge, maxMen: $maxMen, maxWomen: $maxWomen)';
}


}

/// @nodoc
abstract mixin class _$RunDraftCopyWith<$Res> implements $RunDraftCopyWith<$Res> {
  factory _$RunDraftCopyWith(_RunDraft value, $Res Function(_RunDraft) _then) = __$RunDraftCopyWithImpl;
@override @useResult
$Res call({
 String id, String runClubId, DateTime savedAt, String? distance, String? capacity, String? price, String? description, String? paceName, String? meetingPoint, String? locationDetails, double? startingPointLat, double? startingPointLng, int? selectedDateMillis, int? selectedStartHour, int? selectedStartMinute, int durationMinutes, String? minAge, String? maxAge, String? maxMen, String? maxWomen
});




}
/// @nodoc
class __$RunDraftCopyWithImpl<$Res>
    implements _$RunDraftCopyWith<$Res> {
  __$RunDraftCopyWithImpl(this._self, this._then);

  final _RunDraft _self;
  final $Res Function(_RunDraft) _then;

/// Create a copy of RunDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? runClubId = null,Object? savedAt = null,Object? distance = freezed,Object? capacity = freezed,Object? price = freezed,Object? description = freezed,Object? paceName = freezed,Object? meetingPoint = freezed,Object? locationDetails = freezed,Object? startingPointLat = freezed,Object? startingPointLng = freezed,Object? selectedDateMillis = freezed,Object? selectedStartHour = freezed,Object? selectedStartMinute = freezed,Object? durationMinutes = null,Object? minAge = freezed,Object? maxAge = freezed,Object? maxMen = freezed,Object? maxWomen = freezed,}) {
  return _then(_RunDraft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,runClubId: null == runClubId ? _self.runClubId : runClubId // ignore: cast_nullable_to_non_nullable
as String,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,distance: freezed == distance ? _self.distance : distance // ignore: cast_nullable_to_non_nullable
as String?,capacity: freezed == capacity ? _self.capacity : capacity // ignore: cast_nullable_to_non_nullable
as String?,price: freezed == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,paceName: freezed == paceName ? _self.paceName : paceName // ignore: cast_nullable_to_non_nullable
as String?,meetingPoint: freezed == meetingPoint ? _self.meetingPoint : meetingPoint // ignore: cast_nullable_to_non_nullable
as String?,locationDetails: freezed == locationDetails ? _self.locationDetails : locationDetails // ignore: cast_nullable_to_non_nullable
as String?,startingPointLat: freezed == startingPointLat ? _self.startingPointLat : startingPointLat // ignore: cast_nullable_to_non_nullable
as double?,startingPointLng: freezed == startingPointLng ? _self.startingPointLng : startingPointLng // ignore: cast_nullable_to_non_nullable
as double?,selectedDateMillis: freezed == selectedDateMillis ? _self.selectedDateMillis : selectedDateMillis // ignore: cast_nullable_to_non_nullable
as int?,selectedStartHour: freezed == selectedStartHour ? _self.selectedStartHour : selectedStartHour // ignore: cast_nullable_to_non_nullable
as int?,selectedStartMinute: freezed == selectedStartMinute ? _self.selectedStartMinute : selectedStartMinute // ignore: cast_nullable_to_non_nullable
as int?,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as int,minAge: freezed == minAge ? _self.minAge : minAge // ignore: cast_nullable_to_non_nullable
as String?,maxAge: freezed == maxAge ? _self.maxAge : maxAge // ignore: cast_nullable_to_non_nullable
as String?,maxMen: freezed == maxMen ? _self.maxMen : maxMen // ignore: cast_nullable_to_non_nullable
as String?,maxWomen: freezed == maxWomen ? _self.maxWomen : maxWomen // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
