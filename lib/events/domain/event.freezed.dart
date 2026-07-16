// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Event {

@JsonKey(includeToJson: false) String get id; String get clubId;@TimestampConverter() DateTime get startTime;@TimestampConverter() DateTime get endTime; String get meetingPoint;@JsonKey(includeIfNull: false) EventMeetingLocation? get meetingLocation; double? get startingPointLat; double? get startingPointLng; String? get locationDetails;@JsonKey(includeIfNull: false) String? get photoUrl; List<UploadedPhoto> get eventPhotos; EventFormatSnapshot get eventFormat; double get distanceKm; PaceLevel get pace; int get capacityLimit; String get description; int get priceInPaise; String get currency;@JsonKey(includeIfNull: false) int? get bookedCount;@JsonKey(includeIfNull: false) int? get checkedInCount;@JsonKey(includeIfNull: false) int? get waitlistedCount; EventLifecycleStatus get status;@NullableTimestampConverter() DateTime? get cancelledAt; String? get cancellationReason; EventConstraints get constraints;@JsonKey(includeIfNull: false) EventPolicyBundle? get eventPolicy; Map<String, int> get genderCounts; Map<String, int> get cohortCounts; Map<String, int> get waitlistedCohortCounts;
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventCopyWith<Event> get copyWith => _$EventCopyWithImpl<Event>(this as Event, _$identity);

  /// Serializes this Event to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Event&&(identical(other.id, id) || other.id == id)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.meetingPoint, meetingPoint) || other.meetingPoint == meetingPoint)&&(identical(other.meetingLocation, meetingLocation) || other.meetingLocation == meetingLocation)&&(identical(other.startingPointLat, startingPointLat) || other.startingPointLat == startingPointLat)&&(identical(other.startingPointLng, startingPointLng) || other.startingPointLng == startingPointLng)&&(identical(other.locationDetails, locationDetails) || other.locationDetails == locationDetails)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&const DeepCollectionEquality().equals(other.eventPhotos, eventPhotos)&&(identical(other.eventFormat, eventFormat) || other.eventFormat == eventFormat)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.pace, pace) || other.pace == pace)&&(identical(other.capacityLimit, capacityLimit) || other.capacityLimit == capacityLimit)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceInPaise, priceInPaise) || other.priceInPaise == priceInPaise)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.bookedCount, bookedCount) || other.bookedCount == bookedCount)&&(identical(other.checkedInCount, checkedInCount) || other.checkedInCount == checkedInCount)&&(identical(other.waitlistedCount, waitlistedCount) || other.waitlistedCount == waitlistedCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.constraints, constraints) || other.constraints == constraints)&&(identical(other.eventPolicy, eventPolicy) || other.eventPolicy == eventPolicy)&&const DeepCollectionEquality().equals(other.genderCounts, genderCounts)&&const DeepCollectionEquality().equals(other.cohortCounts, cohortCounts)&&const DeepCollectionEquality().equals(other.waitlistedCohortCounts, waitlistedCohortCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,clubId,startTime,endTime,meetingPoint,meetingLocation,startingPointLat,startingPointLng,locationDetails,photoUrl,const DeepCollectionEquality().hash(eventPhotos),eventFormat,distanceKm,pace,capacityLimit,description,priceInPaise,currency,bookedCount,checkedInCount,waitlistedCount,status,cancelledAt,cancellationReason,constraints,eventPolicy,const DeepCollectionEquality().hash(genderCounts),const DeepCollectionEquality().hash(cohortCounts),const DeepCollectionEquality().hash(waitlistedCohortCounts)]);

@override
String toString() {
  return 'Event(id: $id, clubId: $clubId, startTime: $startTime, endTime: $endTime, meetingPoint: $meetingPoint, meetingLocation: $meetingLocation, startingPointLat: $startingPointLat, startingPointLng: $startingPointLng, locationDetails: $locationDetails, photoUrl: $photoUrl, eventPhotos: $eventPhotos, eventFormat: $eventFormat, distanceKm: $distanceKm, pace: $pace, capacityLimit: $capacityLimit, description: $description, priceInPaise: $priceInPaise, currency: $currency, bookedCount: $bookedCount, checkedInCount: $checkedInCount, waitlistedCount: $waitlistedCount, status: $status, cancelledAt: $cancelledAt, cancellationReason: $cancellationReason, constraints: $constraints, eventPolicy: $eventPolicy, genderCounts: $genderCounts, cohortCounts: $cohortCounts, waitlistedCohortCounts: $waitlistedCohortCounts)';
}


}

/// @nodoc
abstract mixin class $EventCopyWith<$Res>  {
  factory $EventCopyWith(Event value, $Res Function(Event) _then) = _$EventCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String clubId,@TimestampConverter() DateTime startTime,@TimestampConverter() DateTime endTime, String meetingPoint,@JsonKey(includeIfNull: false) EventMeetingLocation? meetingLocation, double? startingPointLat, double? startingPointLng, String? locationDetails,@JsonKey(includeIfNull: false) String? photoUrl, List<UploadedPhoto> eventPhotos, EventFormatSnapshot eventFormat, double distanceKm, PaceLevel pace, int capacityLimit, String description, int priceInPaise, String currency,@JsonKey(includeIfNull: false) int? bookedCount,@JsonKey(includeIfNull: false) int? checkedInCount,@JsonKey(includeIfNull: false) int? waitlistedCount, EventLifecycleStatus status,@NullableTimestampConverter() DateTime? cancelledAt, String? cancellationReason, EventConstraints constraints,@JsonKey(includeIfNull: false) EventPolicyBundle? eventPolicy, Map<String, int> genderCounts, Map<String, int> cohortCounts, Map<String, int> waitlistedCohortCounts
});


$EventMeetingLocationCopyWith<$Res>? get meetingLocation;$EventConstraintsCopyWith<$Res> get constraints;

}
/// @nodoc
class _$EventCopyWithImpl<$Res>
    implements $EventCopyWith<$Res> {
  _$EventCopyWithImpl(this._self, this._then);

  final Event _self;
  final $Res Function(Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? clubId = null,Object? startTime = null,Object? endTime = null,Object? meetingPoint = null,Object? meetingLocation = freezed,Object? startingPointLat = freezed,Object? startingPointLng = freezed,Object? locationDetails = freezed,Object? photoUrl = freezed,Object? eventPhotos = null,Object? eventFormat = null,Object? distanceKm = null,Object? pace = null,Object? capacityLimit = null,Object? description = null,Object? priceInPaise = null,Object? currency = null,Object? bookedCount = freezed,Object? checkedInCount = freezed,Object? waitlistedCount = freezed,Object? status = null,Object? cancelledAt = freezed,Object? cancellationReason = freezed,Object? constraints = null,Object? eventPolicy = freezed,Object? genderCounts = null,Object? cohortCounts = null,Object? waitlistedCohortCounts = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,meetingPoint: null == meetingPoint ? _self.meetingPoint : meetingPoint // ignore: cast_nullable_to_non_nullable
as String,meetingLocation: freezed == meetingLocation ? _self.meetingLocation : meetingLocation // ignore: cast_nullable_to_non_nullable
as EventMeetingLocation?,startingPointLat: freezed == startingPointLat ? _self.startingPointLat : startingPointLat // ignore: cast_nullable_to_non_nullable
as double?,startingPointLng: freezed == startingPointLng ? _self.startingPointLng : startingPointLng // ignore: cast_nullable_to_non_nullable
as double?,locationDetails: freezed == locationDetails ? _self.locationDetails : locationDetails // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,eventPhotos: null == eventPhotos ? _self.eventPhotos : eventPhotos // ignore: cast_nullable_to_non_nullable
as List<UploadedPhoto>,eventFormat: null == eventFormat ? _self.eventFormat : eventFormat // ignore: cast_nullable_to_non_nullable
as EventFormatSnapshot,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,pace: null == pace ? _self.pace : pace // ignore: cast_nullable_to_non_nullable
as PaceLevel,capacityLimit: null == capacityLimit ? _self.capacityLimit : capacityLimit // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceInPaise: null == priceInPaise ? _self.priceInPaise : priceInPaise // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,bookedCount: freezed == bookedCount ? _self.bookedCount : bookedCount // ignore: cast_nullable_to_non_nullable
as int?,checkedInCount: freezed == checkedInCount ? _self.checkedInCount : checkedInCount // ignore: cast_nullable_to_non_nullable
as int?,waitlistedCount: freezed == waitlistedCount ? _self.waitlistedCount : waitlistedCount // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventLifecycleStatus,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,constraints: null == constraints ? _self.constraints : constraints // ignore: cast_nullable_to_non_nullable
as EventConstraints,eventPolicy: freezed == eventPolicy ? _self.eventPolicy : eventPolicy // ignore: cast_nullable_to_non_nullable
as EventPolicyBundle?,genderCounts: null == genderCounts ? _self.genderCounts : genderCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,cohortCounts: null == cohortCounts ? _self.cohortCounts : cohortCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,waitlistedCohortCounts: null == waitlistedCohortCounts ? _self.waitlistedCohortCounts : waitlistedCohortCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}
/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventMeetingLocationCopyWith<$Res>? get meetingLocation {
    if (_self.meetingLocation == null) {
    return null;
  }

  return $EventMeetingLocationCopyWith<$Res>(_self.meetingLocation!, (value) {
    return _then(_self.copyWith(meetingLocation: value));
  });
}/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventConstraintsCopyWith<$Res> get constraints {
  
  return $EventConstraintsCopyWith<$Res>(_self.constraints, (value) {
    return _then(_self.copyWith(constraints: value));
  });
}
}


/// Adds pattern-matching-related methods to [Event].
extension EventPatterns on Event {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Event value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Event value)  $default,){
final _that = this;
switch (_that) {
case _Event():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Event value)?  $default,){
final _that = this;
switch (_that) {
case _Event() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String clubId, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  String meetingPoint, @JsonKey(includeIfNull: false)  EventMeetingLocation? meetingLocation,  double? startingPointLat,  double? startingPointLng,  String? locationDetails, @JsonKey(includeIfNull: false)  String? photoUrl,  List<UploadedPhoto> eventPhotos,  EventFormatSnapshot eventFormat,  double distanceKm,  PaceLevel pace,  int capacityLimit,  String description,  int priceInPaise,  String currency, @JsonKey(includeIfNull: false)  int? bookedCount, @JsonKey(includeIfNull: false)  int? checkedInCount, @JsonKey(includeIfNull: false)  int? waitlistedCount,  EventLifecycleStatus status, @NullableTimestampConverter()  DateTime? cancelledAt,  String? cancellationReason,  EventConstraints constraints, @JsonKey(includeIfNull: false)  EventPolicyBundle? eventPolicy,  Map<String, int> genderCounts,  Map<String, int> cohortCounts,  Map<String, int> waitlistedCohortCounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.clubId,_that.startTime,_that.endTime,_that.meetingPoint,_that.meetingLocation,_that.startingPointLat,_that.startingPointLng,_that.locationDetails,_that.photoUrl,_that.eventPhotos,_that.eventFormat,_that.distanceKm,_that.pace,_that.capacityLimit,_that.description,_that.priceInPaise,_that.currency,_that.bookedCount,_that.checkedInCount,_that.waitlistedCount,_that.status,_that.cancelledAt,_that.cancellationReason,_that.constraints,_that.eventPolicy,_that.genderCounts,_that.cohortCounts,_that.waitlistedCohortCounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String clubId, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  String meetingPoint, @JsonKey(includeIfNull: false)  EventMeetingLocation? meetingLocation,  double? startingPointLat,  double? startingPointLng,  String? locationDetails, @JsonKey(includeIfNull: false)  String? photoUrl,  List<UploadedPhoto> eventPhotos,  EventFormatSnapshot eventFormat,  double distanceKm,  PaceLevel pace,  int capacityLimit,  String description,  int priceInPaise,  String currency, @JsonKey(includeIfNull: false)  int? bookedCount, @JsonKey(includeIfNull: false)  int? checkedInCount, @JsonKey(includeIfNull: false)  int? waitlistedCount,  EventLifecycleStatus status, @NullableTimestampConverter()  DateTime? cancelledAt,  String? cancellationReason,  EventConstraints constraints, @JsonKey(includeIfNull: false)  EventPolicyBundle? eventPolicy,  Map<String, int> genderCounts,  Map<String, int> cohortCounts,  Map<String, int> waitlistedCohortCounts)  $default,) {final _that = this;
switch (_that) {
case _Event():
return $default(_that.id,_that.clubId,_that.startTime,_that.endTime,_that.meetingPoint,_that.meetingLocation,_that.startingPointLat,_that.startingPointLng,_that.locationDetails,_that.photoUrl,_that.eventPhotos,_that.eventFormat,_that.distanceKm,_that.pace,_that.capacityLimit,_that.description,_that.priceInPaise,_that.currency,_that.bookedCount,_that.checkedInCount,_that.waitlistedCount,_that.status,_that.cancelledAt,_that.cancellationReason,_that.constraints,_that.eventPolicy,_that.genderCounts,_that.cohortCounts,_that.waitlistedCohortCounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String clubId, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  String meetingPoint, @JsonKey(includeIfNull: false)  EventMeetingLocation? meetingLocation,  double? startingPointLat,  double? startingPointLng,  String? locationDetails, @JsonKey(includeIfNull: false)  String? photoUrl,  List<UploadedPhoto> eventPhotos,  EventFormatSnapshot eventFormat,  double distanceKm,  PaceLevel pace,  int capacityLimit,  String description,  int priceInPaise,  String currency, @JsonKey(includeIfNull: false)  int? bookedCount, @JsonKey(includeIfNull: false)  int? checkedInCount, @JsonKey(includeIfNull: false)  int? waitlistedCount,  EventLifecycleStatus status, @NullableTimestampConverter()  DateTime? cancelledAt,  String? cancellationReason,  EventConstraints constraints, @JsonKey(includeIfNull: false)  EventPolicyBundle? eventPolicy,  Map<String, int> genderCounts,  Map<String, int> cohortCounts,  Map<String, int> waitlistedCohortCounts)?  $default,) {final _that = this;
switch (_that) {
case _Event() when $default != null:
return $default(_that.id,_that.clubId,_that.startTime,_that.endTime,_that.meetingPoint,_that.meetingLocation,_that.startingPointLat,_that.startingPointLng,_that.locationDetails,_that.photoUrl,_that.eventPhotos,_that.eventFormat,_that.distanceKm,_that.pace,_that.capacityLimit,_that.description,_that.priceInPaise,_that.currency,_that.bookedCount,_that.checkedInCount,_that.waitlistedCount,_that.status,_that.cancelledAt,_that.cancellationReason,_that.constraints,_that.eventPolicy,_that.genderCounts,_that.cohortCounts,_that.waitlistedCohortCounts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Event extends Event {
  const _Event({@JsonKey(includeToJson: false) required this.id, required this.clubId, @TimestampConverter() required this.startTime, @TimestampConverter() required this.endTime, required this.meetingPoint, @JsonKey(includeIfNull: false) this.meetingLocation, this.startingPointLat, this.startingPointLng, this.locationDetails, @JsonKey(includeIfNull: false) this.photoUrl, final  List<UploadedPhoto> eventPhotos = const [], this.eventFormat = const EventFormatSnapshot.socialRun(), required this.distanceKm, required this.pace, required this.capacityLimit, required this.description, required this.priceInPaise, this.currency = defaultCurrencyCode, @JsonKey(includeIfNull: false) this.bookedCount, @JsonKey(includeIfNull: false) this.checkedInCount, @JsonKey(includeIfNull: false) this.waitlistedCount, this.status = EventLifecycleStatus.active, @NullableTimestampConverter() this.cancelledAt, this.cancellationReason, this.constraints = const EventConstraints(), @JsonKey(includeIfNull: false) this.eventPolicy, final  Map<String, int> genderCounts = const {}, final  Map<String, int> cohortCounts = const {}, final  Map<String, int> waitlistedCohortCounts = const {}}): _eventPhotos = eventPhotos,_genderCounts = genderCounts,_cohortCounts = cohortCounts,_waitlistedCohortCounts = waitlistedCohortCounts,super._();
  factory _Event.fromJson(Map<String, dynamic> json) => _$EventFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String clubId;
@override@TimestampConverter() final  DateTime startTime;
@override@TimestampConverter() final  DateTime endTime;
@override final  String meetingPoint;
@override@JsonKey(includeIfNull: false) final  EventMeetingLocation? meetingLocation;
@override final  double? startingPointLat;
@override final  double? startingPointLng;
@override final  String? locationDetails;
@override@JsonKey(includeIfNull: false) final  String? photoUrl;
 final  List<UploadedPhoto> _eventPhotos;
@override@JsonKey() List<UploadedPhoto> get eventPhotos {
  if (_eventPhotos is EqualUnmodifiableListView) return _eventPhotos;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_eventPhotos);
}

@override@JsonKey() final  EventFormatSnapshot eventFormat;
@override final  double distanceKm;
@override final  PaceLevel pace;
@override final  int capacityLimit;
@override final  String description;
@override final  int priceInPaise;
@override@JsonKey() final  String currency;
@override@JsonKey(includeIfNull: false) final  int? bookedCount;
@override@JsonKey(includeIfNull: false) final  int? checkedInCount;
@override@JsonKey(includeIfNull: false) final  int? waitlistedCount;
@override@JsonKey() final  EventLifecycleStatus status;
@override@NullableTimestampConverter() final  DateTime? cancelledAt;
@override final  String? cancellationReason;
@override@JsonKey() final  EventConstraints constraints;
@override@JsonKey(includeIfNull: false) final  EventPolicyBundle? eventPolicy;
 final  Map<String, int> _genderCounts;
@override@JsonKey() Map<String, int> get genderCounts {
  if (_genderCounts is EqualUnmodifiableMapView) return _genderCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_genderCounts);
}

 final  Map<String, int> _cohortCounts;
@override@JsonKey() Map<String, int> get cohortCounts {
  if (_cohortCounts is EqualUnmodifiableMapView) return _cohortCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_cohortCounts);
}

 final  Map<String, int> _waitlistedCohortCounts;
@override@JsonKey() Map<String, int> get waitlistedCohortCounts {
  if (_waitlistedCohortCounts is EqualUnmodifiableMapView) return _waitlistedCohortCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_waitlistedCohortCounts);
}


/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventCopyWith<_Event> get copyWith => __$EventCopyWithImpl<_Event>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Event&&(identical(other.id, id) || other.id == id)&&(identical(other.clubId, clubId) || other.clubId == clubId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.meetingPoint, meetingPoint) || other.meetingPoint == meetingPoint)&&(identical(other.meetingLocation, meetingLocation) || other.meetingLocation == meetingLocation)&&(identical(other.startingPointLat, startingPointLat) || other.startingPointLat == startingPointLat)&&(identical(other.startingPointLng, startingPointLng) || other.startingPointLng == startingPointLng)&&(identical(other.locationDetails, locationDetails) || other.locationDetails == locationDetails)&&(identical(other.photoUrl, photoUrl) || other.photoUrl == photoUrl)&&const DeepCollectionEquality().equals(other._eventPhotos, _eventPhotos)&&(identical(other.eventFormat, eventFormat) || other.eventFormat == eventFormat)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.pace, pace) || other.pace == pace)&&(identical(other.capacityLimit, capacityLimit) || other.capacityLimit == capacityLimit)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceInPaise, priceInPaise) || other.priceInPaise == priceInPaise)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.bookedCount, bookedCount) || other.bookedCount == bookedCount)&&(identical(other.checkedInCount, checkedInCount) || other.checkedInCount == checkedInCount)&&(identical(other.waitlistedCount, waitlistedCount) || other.waitlistedCount == waitlistedCount)&&(identical(other.status, status) || other.status == status)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.cancellationReason, cancellationReason) || other.cancellationReason == cancellationReason)&&(identical(other.constraints, constraints) || other.constraints == constraints)&&(identical(other.eventPolicy, eventPolicy) || other.eventPolicy == eventPolicy)&&const DeepCollectionEquality().equals(other._genderCounts, _genderCounts)&&const DeepCollectionEquality().equals(other._cohortCounts, _cohortCounts)&&const DeepCollectionEquality().equals(other._waitlistedCohortCounts, _waitlistedCohortCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,clubId,startTime,endTime,meetingPoint,meetingLocation,startingPointLat,startingPointLng,locationDetails,photoUrl,const DeepCollectionEquality().hash(_eventPhotos),eventFormat,distanceKm,pace,capacityLimit,description,priceInPaise,currency,bookedCount,checkedInCount,waitlistedCount,status,cancelledAt,cancellationReason,constraints,eventPolicy,const DeepCollectionEquality().hash(_genderCounts),const DeepCollectionEquality().hash(_cohortCounts),const DeepCollectionEquality().hash(_waitlistedCohortCounts)]);

@override
String toString() {
  return 'Event(id: $id, clubId: $clubId, startTime: $startTime, endTime: $endTime, meetingPoint: $meetingPoint, meetingLocation: $meetingLocation, startingPointLat: $startingPointLat, startingPointLng: $startingPointLng, locationDetails: $locationDetails, photoUrl: $photoUrl, eventPhotos: $eventPhotos, eventFormat: $eventFormat, distanceKm: $distanceKm, pace: $pace, capacityLimit: $capacityLimit, description: $description, priceInPaise: $priceInPaise, currency: $currency, bookedCount: $bookedCount, checkedInCount: $checkedInCount, waitlistedCount: $waitlistedCount, status: $status, cancelledAt: $cancelledAt, cancellationReason: $cancellationReason, constraints: $constraints, eventPolicy: $eventPolicy, genderCounts: $genderCounts, cohortCounts: $cohortCounts, waitlistedCohortCounts: $waitlistedCohortCounts)';
}


}

/// @nodoc
abstract mixin class _$EventCopyWith<$Res> implements $EventCopyWith<$Res> {
  factory _$EventCopyWith(_Event value, $Res Function(_Event) _then) = __$EventCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String clubId,@TimestampConverter() DateTime startTime,@TimestampConverter() DateTime endTime, String meetingPoint,@JsonKey(includeIfNull: false) EventMeetingLocation? meetingLocation, double? startingPointLat, double? startingPointLng, String? locationDetails,@JsonKey(includeIfNull: false) String? photoUrl, List<UploadedPhoto> eventPhotos, EventFormatSnapshot eventFormat, double distanceKm, PaceLevel pace, int capacityLimit, String description, int priceInPaise, String currency,@JsonKey(includeIfNull: false) int? bookedCount,@JsonKey(includeIfNull: false) int? checkedInCount,@JsonKey(includeIfNull: false) int? waitlistedCount, EventLifecycleStatus status,@NullableTimestampConverter() DateTime? cancelledAt, String? cancellationReason, EventConstraints constraints,@JsonKey(includeIfNull: false) EventPolicyBundle? eventPolicy, Map<String, int> genderCounts, Map<String, int> cohortCounts, Map<String, int> waitlistedCohortCounts
});


@override $EventMeetingLocationCopyWith<$Res>? get meetingLocation;@override $EventConstraintsCopyWith<$Res> get constraints;

}
/// @nodoc
class __$EventCopyWithImpl<$Res>
    implements _$EventCopyWith<$Res> {
  __$EventCopyWithImpl(this._self, this._then);

  final _Event _self;
  final $Res Function(_Event) _then;

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? clubId = null,Object? startTime = null,Object? endTime = null,Object? meetingPoint = null,Object? meetingLocation = freezed,Object? startingPointLat = freezed,Object? startingPointLng = freezed,Object? locationDetails = freezed,Object? photoUrl = freezed,Object? eventPhotos = null,Object? eventFormat = null,Object? distanceKm = null,Object? pace = null,Object? capacityLimit = null,Object? description = null,Object? priceInPaise = null,Object? currency = null,Object? bookedCount = freezed,Object? checkedInCount = freezed,Object? waitlistedCount = freezed,Object? status = null,Object? cancelledAt = freezed,Object? cancellationReason = freezed,Object? constraints = null,Object? eventPolicy = freezed,Object? genderCounts = null,Object? cohortCounts = null,Object? waitlistedCohortCounts = null,}) {
  return _then(_Event(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,clubId: null == clubId ? _self.clubId : clubId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,meetingPoint: null == meetingPoint ? _self.meetingPoint : meetingPoint // ignore: cast_nullable_to_non_nullable
as String,meetingLocation: freezed == meetingLocation ? _self.meetingLocation : meetingLocation // ignore: cast_nullable_to_non_nullable
as EventMeetingLocation?,startingPointLat: freezed == startingPointLat ? _self.startingPointLat : startingPointLat // ignore: cast_nullable_to_non_nullable
as double?,startingPointLng: freezed == startingPointLng ? _self.startingPointLng : startingPointLng // ignore: cast_nullable_to_non_nullable
as double?,locationDetails: freezed == locationDetails ? _self.locationDetails : locationDetails // ignore: cast_nullable_to_non_nullable
as String?,photoUrl: freezed == photoUrl ? _self.photoUrl : photoUrl // ignore: cast_nullable_to_non_nullable
as String?,eventPhotos: null == eventPhotos ? _self._eventPhotos : eventPhotos // ignore: cast_nullable_to_non_nullable
as List<UploadedPhoto>,eventFormat: null == eventFormat ? _self.eventFormat : eventFormat // ignore: cast_nullable_to_non_nullable
as EventFormatSnapshot,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,pace: null == pace ? _self.pace : pace // ignore: cast_nullable_to_non_nullable
as PaceLevel,capacityLimit: null == capacityLimit ? _self.capacityLimit : capacityLimit // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceInPaise: null == priceInPaise ? _self.priceInPaise : priceInPaise // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,bookedCount: freezed == bookedCount ? _self.bookedCount : bookedCount // ignore: cast_nullable_to_non_nullable
as int?,checkedInCount: freezed == checkedInCount ? _self.checkedInCount : checkedInCount // ignore: cast_nullable_to_non_nullable
as int?,waitlistedCount: freezed == waitlistedCount ? _self.waitlistedCount : waitlistedCount // ignore: cast_nullable_to_non_nullable
as int?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EventLifecycleStatus,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancellationReason: freezed == cancellationReason ? _self.cancellationReason : cancellationReason // ignore: cast_nullable_to_non_nullable
as String?,constraints: null == constraints ? _self.constraints : constraints // ignore: cast_nullable_to_non_nullable
as EventConstraints,eventPolicy: freezed == eventPolicy ? _self.eventPolicy : eventPolicy // ignore: cast_nullable_to_non_nullable
as EventPolicyBundle?,genderCounts: null == genderCounts ? _self._genderCounts : genderCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,cohortCounts: null == cohortCounts ? _self._cohortCounts : cohortCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,waitlistedCohortCounts: null == waitlistedCohortCounts ? _self._waitlistedCohortCounts : waitlistedCohortCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventMeetingLocationCopyWith<$Res>? get meetingLocation {
    if (_self.meetingLocation == null) {
    return null;
  }

  return $EventMeetingLocationCopyWith<$Res>(_self.meetingLocation!, (value) {
    return _then(_self.copyWith(meetingLocation: value));
  });
}/// Create a copy of Event
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EventConstraintsCopyWith<$Res> get constraints {
  
  return $EventConstraintsCopyWith<$Res>(_self.constraints, (value) {
    return _then(_self.copyWith(constraints: value));
  });
}
}

// dart format on
