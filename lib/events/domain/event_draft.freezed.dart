// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventDraft {

 String get id; String get clubId; DateTime get savedAt;// Event Details step
 String? get distance; String? get capacity; String? get price; String? get description; String? get paceName;// Where step
 String? get meetingPoint; String? get locationDetails; double? get startingPointLat; double? get startingPointLng;// When step
 int? get selectedDateMillis; int? get selectedStartHour; int? get selectedStartMinute; int get durationMinutes;// Rules step
 String? get minAge; String? get maxAge; String? get maxMen; String? get maxWomen; String? get admissionPreset; String? get cancellationPolicy;
/// Create a copy of EventDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventDraftCopyWith<EventDraft> get copyWith => _$EventDraftCopyWithImpl<EventDraft>(this as EventDraft, _$identity);

  /// Serializes this EventDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.paceName, paceName) || other.paceName == paceName)&&(identical(other.meetingPoint, meetingPoint) || other.meetingPoint == meetingPoint)&&(identical(other.locationDetails, locationDetails) || other.locationDetails == locationDetails)&&(identical(other.startingPointLat, startingPointLat) || other.startingPointLat == startingPointLat)&&(identical(other.startingPointLng, startingPointLng) || other.startingPointLng == startingPointLng)&&(identical(other.selectedDateMillis, selectedDateMillis) || other.selectedDateMillis == selectedDateMillis)&&(identical(other.selectedStartHour, selectedStartHour) || other.selectedStartHour == selectedStartHour)&&(identical(other.selectedStartMinute, selectedStartMinute) || other.selectedStartMinute == selectedStartMinute)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.minAge, minAge) || other.minAge == minAge)&&(identical(other.maxAge, maxAge) || other.maxAge == maxAge)&&(identical(other.maxMen, maxMen) || other.maxMen == maxMen)&&(identical(other.maxWomen, maxWomen) || other.maxWomen == maxWomen)&&(identical(other.admissionPreset, admissionPreset) || other.admissionPreset == admissionPreset)&&(identical(other.cancellationPolicy, cancellationPolicy) || other.cancellationPolicy == cancellationPolicy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,clubId,savedAt,distance,capacity,price,description,paceName,meetingPoint,locationDetails,startingPointLat,startingPointLng,selectedDateMillis,selectedStartHour,selectedStartMinute,durationMinutes,minAge,maxAge,maxMen,maxWomen,admissionPreset,cancellationPolicy]);

@override
String toString() {
  return 'EventDraft(id: $id, clubId: $clubId, savedAt: $savedAt, distance: $distance, capacity: $capacity, price: $price, description: $description, paceName: $paceName, meetingPoint: $meetingPoint, locationDetails: $locationDetails, startingPointLat: $startingPointLat, startingPointLng: $startingPointLng, selectedDateMillis: $selectedDateMillis, selectedStartHour: $selectedStartHour, selectedStartMinute: $selectedStartMinute, durationMinutes: $durationMinutes, minAge: $minAge, maxAge: $maxAge, maxMen: $maxMen, maxWomen: $maxWomen, admissionPreset: $admissionPreset, cancellationPolicy: $cancellationPolicy)';
}


}

/// @nodoc
abstract mixin class $EventDraftCopyWith<$Res>  {
  factory $EventDraftCopyWith(EventDraft value, $Res Function(EventDraft) _then) = _$EventDraftCopyWithImpl;
@useResult
$Res call({
 String id, String clubId, DateTime savedAt, String? distance, String? capacity, String? price, String? description, String? paceName, String? meetingPoint, String? locationDetails, double? startingPointLat, double? startingPointLng, int? selectedDateMillis, int? selectedStartHour, int? selectedStartMinute, int durationMinutes, String? minAge, String? maxAge, String? maxMen, String? maxWomen, String? admissionPreset, String? cancellationPolicy
});




}
/// @nodoc
class _$EventDraftCopyWithImpl<$Res>
    implements $EventDraftCopyWith<$Res> {
  _$EventDraftCopyWithImpl(this._self, this._then);

  final EventDraft _self;
  final $Res Function(EventDraft) _then;

/// Create a copy of EventDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? clubId = null,Object? savedAt = null,Object? distance = freezed,Object? capacity = freezed,Object? price = freezed,Object? description = freezed,Object? paceName = freezed,Object? meetingPoint = freezed,Object? locationDetails = freezed,Object? startingPointLat = freezed,Object? startingPointLng = freezed,Object? selectedDateMillis = freezed,Object? selectedStartHour = freezed,Object? selectedStartMinute = freezed,Object? durationMinutes = null,Object? minAge = freezed,Object? maxAge = freezed,Object? maxMen = freezed,Object? maxWomen = freezed,Object? admissionPreset = freezed,Object? cancellationPolicy = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
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
as String?,admissionPreset: freezed == admissionPreset ? _self.admissionPreset : admissionPreset // ignore: cast_nullable_to_non_nullable
as String?,cancellationPolicy: freezed == cancellationPolicy ? _self.cancellationPolicy : cancellationPolicy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventDraft].
extension EventDraftPatterns on EventDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventDraft value)  $default,){
final _that = this;
switch (_that) {
case _EventDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventDraft value)?  $default,){
final _that = this;
switch (_that) {
case _EventDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String clubId,  DateTime savedAt,  String? distance,  String? capacity,  String? price,  String? description,  String? paceName,  String? meetingPoint,  String? locationDetails,  double? startingPointLat,  double? startingPointLng,  int? selectedDateMillis,  int? selectedStartHour,  int? selectedStartMinute,  int durationMinutes,  String? minAge,  String? maxAge,  String? maxMen,  String? maxWomen,  String? admissionPreset,  String? cancellationPolicy)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventDraft() when $default != null:
return $default(_that.id,_that.clubId,_that.savedAt,_that.distance,_that.capacity,_that.price,_that.description,_that.paceName,_that.meetingPoint,_that.locationDetails,_that.startingPointLat,_that.startingPointLng,_that.selectedDateMillis,_that.selectedStartHour,_that.selectedStartMinute,_that.durationMinutes,_that.minAge,_that.maxAge,_that.maxMen,_that.maxWomen,_that.admissionPreset,_that.cancellationPolicy);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String clubId,  DateTime savedAt,  String? distance,  String? capacity,  String? price,  String? description,  String? paceName,  String? meetingPoint,  String? locationDetails,  double? startingPointLat,  double? startingPointLng,  int? selectedDateMillis,  int? selectedStartHour,  int? selectedStartMinute,  int durationMinutes,  String? minAge,  String? maxAge,  String? maxMen,  String? maxWomen,  String? admissionPreset,  String? cancellationPolicy)  $default,) {final _that = this;
switch (_that) {
case _EventDraft():
return $default(_that.id,_that.clubId,_that.savedAt,_that.distance,_that.capacity,_that.price,_that.description,_that.paceName,_that.meetingPoint,_that.locationDetails,_that.startingPointLat,_that.startingPointLng,_that.selectedDateMillis,_that.selectedStartHour,_that.selectedStartMinute,_that.durationMinutes,_that.minAge,_that.maxAge,_that.maxMen,_that.maxWomen,_that.admissionPreset,_that.cancellationPolicy);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String clubId,  DateTime savedAt,  String? distance,  String? capacity,  String? price,  String? description,  String? paceName,  String? meetingPoint,  String? locationDetails,  double? startingPointLat,  double? startingPointLng,  int? selectedDateMillis,  int? selectedStartHour,  int? selectedStartMinute,  int durationMinutes,  String? minAge,  String? maxAge,  String? maxMen,  String? maxWomen,  String? admissionPreset,  String? cancellationPolicy)?  $default,) {final _that = this;
switch (_that) {
case _EventDraft() when $default != null:
return $default(_that.id,_that.clubId,_that.savedAt,_that.distance,_that.capacity,_that.price,_that.description,_that.paceName,_that.meetingPoint,_that.locationDetails,_that.startingPointLat,_that.startingPointLng,_that.selectedDateMillis,_that.selectedStartHour,_that.selectedStartMinute,_that.durationMinutes,_that.minAge,_that.maxAge,_that.maxMen,_that.maxWomen,_that.admissionPreset,_that.cancellationPolicy);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventDraft implements EventDraft {
  const _EventDraft({required this.id, required this.clubId, required this.savedAt, this.distance, this.capacity, this.price, this.description, this.paceName, this.meetingPoint, this.locationDetails, this.startingPointLat, this.startingPointLng, this.selectedDateMillis, this.selectedStartHour, this.selectedStartMinute, this.durationMinutes = CatchBusinessRules.eventDefaultDurationMinutes, this.minAge, this.maxAge, this.maxMen, this.maxWomen, this.admissionPreset, this.cancellationPolicy});
  factory _EventDraft.fromJson(Map<String, dynamic> json) => _$EventDraftFromJson(json);

@override final  String id;
@override final  String clubId;
@override final  DateTime savedAt;
// Event Details step
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
@override final  String? admissionPreset;
@override final  String? cancellationPolicy;

/// Create a copy of EventDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventDraftCopyWith<_EventDraft> get copyWith => __$EventDraftCopyWithImpl<_EventDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventDraft&&(identical(other.id, id) || other.id == id)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.distance, distance) || other.distance == distance)&&(identical(other.capacity, capacity) || other.capacity == capacity)&&(identical(other.price, price) || other.price == price)&&(identical(other.description, description) || other.description == description)&&(identical(other.paceName, paceName) || other.paceName == paceName)&&(identical(other.meetingPoint, meetingPoint) || other.meetingPoint == meetingPoint)&&(identical(other.locationDetails, locationDetails) || other.locationDetails == locationDetails)&&(identical(other.startingPointLat, startingPointLat) || other.startingPointLat == startingPointLat)&&(identical(other.startingPointLng, startingPointLng) || other.startingPointLng == startingPointLng)&&(identical(other.selectedDateMillis, selectedDateMillis) || other.selectedDateMillis == selectedDateMillis)&&(identical(other.selectedStartHour, selectedStartHour) || other.selectedStartHour == selectedStartHour)&&(identical(other.selectedStartMinute, selectedStartMinute) || other.selectedStartMinute == selectedStartMinute)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.minAge, minAge) || other.minAge == minAge)&&(identical(other.maxAge, maxAge) || other.maxAge == maxAge)&&(identical(other.maxMen, maxMen) || other.maxMen == maxMen)&&(identical(other.maxWomen, maxWomen) || other.maxWomen == maxWomen)&&(identical(other.admissionPreset, admissionPreset) || other.admissionPreset == admissionPreset)&&(identical(other.cancellationPolicy, cancellationPolicy) || other.cancellationPolicy == cancellationPolicy));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,clubId,savedAt,distance,capacity,price,description,paceName,meetingPoint,locationDetails,startingPointLat,startingPointLng,selectedDateMillis,selectedStartHour,selectedStartMinute,durationMinutes,minAge,maxAge,maxMen,maxWomen,admissionPreset,cancellationPolicy]);

@override
String toString() {
  return 'EventDraft(id: $id, clubId: $clubId, savedAt: $savedAt, distance: $distance, capacity: $capacity, price: $price, description: $description, paceName: $paceName, meetingPoint: $meetingPoint, locationDetails: $locationDetails, startingPointLat: $startingPointLat, startingPointLng: $startingPointLng, selectedDateMillis: $selectedDateMillis, selectedStartHour: $selectedStartHour, selectedStartMinute: $selectedStartMinute, durationMinutes: $durationMinutes, minAge: $minAge, maxAge: $maxAge, maxMen: $maxMen, maxWomen: $maxWomen, admissionPreset: $admissionPreset, cancellationPolicy: $cancellationPolicy)';
}


}

/// @nodoc
abstract mixin class _$EventDraftCopyWith<$Res> implements $EventDraftCopyWith<$Res> {
  factory _$EventDraftCopyWith(_EventDraft value, $Res Function(_EventDraft) _then) = __$EventDraftCopyWithImpl;
@override @useResult
$Res call({
 String id, String clubId, DateTime savedAt, String? distance, String? capacity, String? price, String? description, String? paceName, String? meetingPoint, String? locationDetails, double? startingPointLat, double? startingPointLng, int? selectedDateMillis, int? selectedStartHour, int? selectedStartMinute, int durationMinutes, String? minAge, String? maxAge, String? maxMen, String? maxWomen, String? admissionPreset, String? cancellationPolicy
});




}
/// @nodoc
class __$EventDraftCopyWithImpl<$Res>
    implements _$EventDraftCopyWith<$Res> {
  __$EventDraftCopyWithImpl(this._self, this._then);

  final _EventDraft _self;
  final $Res Function(_EventDraft) _then;

/// Create a copy of EventDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? clubId = null,Object? savedAt = null,Object? distance = freezed,Object? capacity = freezed,Object? price = freezed,Object? description = freezed,Object? paceName = freezed,Object? meetingPoint = freezed,Object? locationDetails = freezed,Object? startingPointLat = freezed,Object? startingPointLng = freezed,Object? selectedDateMillis = freezed,Object? selectedStartHour = freezed,Object? selectedStartMinute = freezed,Object? durationMinutes = null,Object? minAge = freezed,Object? maxAge = freezed,Object? maxMen = freezed,Object? maxWomen = freezed,Object? admissionPreset = freezed,Object? cancellationPolicy = freezed,}) {
  return _then(_EventDraft(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
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
as String?,admissionPreset: freezed == admissionPreset ? _self.admissionPreset : admissionPreset // ignore: cast_nullable_to_non_nullable
as String?,cancellationPolicy: freezed == cancellationPolicy ? _self.cancellationPolicy : cancellationPolicy // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
