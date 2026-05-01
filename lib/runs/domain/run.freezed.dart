// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Run {

@JsonKey(includeToJson: false) String get id; String get runClubId;@TimestampConverter() DateTime get startTime;@TimestampConverter() DateTime get endTime; String get meetingPoint; double? get startingPointLat; double? get startingPointLng; String? get locationDetails; double get distanceKm; PaceLevel get pace; int get capacityLimit; String get description; int get priceInPaise; List<String> get signedUpUserIds; List<String> get attendedUserIds; List<String> get waitlistUserIds;@JsonKey(toJson: _runConstraintsToJson) RunConstraints get constraints;// Denormalized gender counts maintained atomically by Cloud Functions.
// Keys are Gender enum names: 'man', 'woman', 'nonBinary', 'other'.
 Map<String, int> get genderCounts;
/// Create a copy of Run
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunCopyWith<Run> get copyWith => _$RunCopyWithImpl<Run>(this as Run, _$identity);

  /// Serializes this Run to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Run&&(identical(other.id, id) || other.id == id)&&(identical(other.runClubId, runClubId) || other.runClubId == runClubId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.meetingPoint, meetingPoint) || other.meetingPoint == meetingPoint)&&(identical(other.startingPointLat, startingPointLat) || other.startingPointLat == startingPointLat)&&(identical(other.startingPointLng, startingPointLng) || other.startingPointLng == startingPointLng)&&(identical(other.locationDetails, locationDetails) || other.locationDetails == locationDetails)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.pace, pace) || other.pace == pace)&&(identical(other.capacityLimit, capacityLimit) || other.capacityLimit == capacityLimit)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceInPaise, priceInPaise) || other.priceInPaise == priceInPaise)&&const DeepCollectionEquality().equals(other.signedUpUserIds, signedUpUserIds)&&const DeepCollectionEquality().equals(other.attendedUserIds, attendedUserIds)&&const DeepCollectionEquality().equals(other.waitlistUserIds, waitlistUserIds)&&(identical(other.constraints, constraints) || other.constraints == constraints)&&const DeepCollectionEquality().equals(other.genderCounts, genderCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,runClubId,startTime,endTime,meetingPoint,startingPointLat,startingPointLng,locationDetails,distanceKm,pace,capacityLimit,description,priceInPaise,const DeepCollectionEquality().hash(signedUpUserIds),const DeepCollectionEquality().hash(attendedUserIds),const DeepCollectionEquality().hash(waitlistUserIds),constraints,const DeepCollectionEquality().hash(genderCounts));

@override
String toString() {
  return 'Run(id: $id, runClubId: $runClubId, startTime: $startTime, endTime: $endTime, meetingPoint: $meetingPoint, startingPointLat: $startingPointLat, startingPointLng: $startingPointLng, locationDetails: $locationDetails, distanceKm: $distanceKm, pace: $pace, capacityLimit: $capacityLimit, description: $description, priceInPaise: $priceInPaise, signedUpUserIds: $signedUpUserIds, attendedUserIds: $attendedUserIds, waitlistUserIds: $waitlistUserIds, constraints: $constraints, genderCounts: $genderCounts)';
}


}

/// @nodoc
abstract mixin class $RunCopyWith<$Res>  {
  factory $RunCopyWith(Run value, $Res Function(Run) _then) = _$RunCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String runClubId,@TimestampConverter() DateTime startTime,@TimestampConverter() DateTime endTime, String meetingPoint, double? startingPointLat, double? startingPointLng, String? locationDetails, double distanceKm, PaceLevel pace, int capacityLimit, String description, int priceInPaise, List<String> signedUpUserIds, List<String> attendedUserIds, List<String> waitlistUserIds,@JsonKey(toJson: _runConstraintsToJson) RunConstraints constraints, Map<String, int> genderCounts
});


$RunConstraintsCopyWith<$Res> get constraints;

}
/// @nodoc
class _$RunCopyWithImpl<$Res>
    implements $RunCopyWith<$Res> {
  _$RunCopyWithImpl(this._self, this._then);

  final Run _self;
  final $Res Function(Run) _then;

/// Create a copy of Run
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? runClubId = null,Object? startTime = null,Object? endTime = null,Object? meetingPoint = null,Object? startingPointLat = freezed,Object? startingPointLng = freezed,Object? locationDetails = freezed,Object? distanceKm = null,Object? pace = null,Object? capacityLimit = null,Object? description = null,Object? priceInPaise = null,Object? signedUpUserIds = null,Object? attendedUserIds = null,Object? waitlistUserIds = null,Object? constraints = null,Object? genderCounts = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,runClubId: null == runClubId ? _self.runClubId : runClubId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,meetingPoint: null == meetingPoint ? _self.meetingPoint : meetingPoint // ignore: cast_nullable_to_non_nullable
as String,startingPointLat: freezed == startingPointLat ? _self.startingPointLat : startingPointLat // ignore: cast_nullable_to_non_nullable
as double?,startingPointLng: freezed == startingPointLng ? _self.startingPointLng : startingPointLng // ignore: cast_nullable_to_non_nullable
as double?,locationDetails: freezed == locationDetails ? _self.locationDetails : locationDetails // ignore: cast_nullable_to_non_nullable
as String?,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,pace: null == pace ? _self.pace : pace // ignore: cast_nullable_to_non_nullable
as PaceLevel,capacityLimit: null == capacityLimit ? _self.capacityLimit : capacityLimit // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceInPaise: null == priceInPaise ? _self.priceInPaise : priceInPaise // ignore: cast_nullable_to_non_nullable
as int,signedUpUserIds: null == signedUpUserIds ? _self.signedUpUserIds : signedUpUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,attendedUserIds: null == attendedUserIds ? _self.attendedUserIds : attendedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,waitlistUserIds: null == waitlistUserIds ? _self.waitlistUserIds : waitlistUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,constraints: null == constraints ? _self.constraints : constraints // ignore: cast_nullable_to_non_nullable
as RunConstraints,genderCounts: null == genderCounts ? _self.genderCounts : genderCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}
/// Create a copy of Run
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RunConstraintsCopyWith<$Res> get constraints {
  
  return $RunConstraintsCopyWith<$Res>(_self.constraints, (value) {
    return _then(_self.copyWith(constraints: value));
  });
}
}


/// Adds pattern-matching-related methods to [Run].
extension RunPatterns on Run {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Run value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Run() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Run value)  $default,){
final _that = this;
switch (_that) {
case _Run():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Run value)?  $default,){
final _that = this;
switch (_that) {
case _Run() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String runClubId, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  String meetingPoint,  double? startingPointLat,  double? startingPointLng,  String? locationDetails,  double distanceKm,  PaceLevel pace,  int capacityLimit,  String description,  int priceInPaise,  List<String> signedUpUserIds,  List<String> attendedUserIds,  List<String> waitlistUserIds, @JsonKey(toJson: _runConstraintsToJson)  RunConstraints constraints,  Map<String, int> genderCounts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Run() when $default != null:
return $default(_that.id,_that.runClubId,_that.startTime,_that.endTime,_that.meetingPoint,_that.startingPointLat,_that.startingPointLng,_that.locationDetails,_that.distanceKm,_that.pace,_that.capacityLimit,_that.description,_that.priceInPaise,_that.signedUpUserIds,_that.attendedUserIds,_that.waitlistUserIds,_that.constraints,_that.genderCounts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String runClubId, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  String meetingPoint,  double? startingPointLat,  double? startingPointLng,  String? locationDetails,  double distanceKm,  PaceLevel pace,  int capacityLimit,  String description,  int priceInPaise,  List<String> signedUpUserIds,  List<String> attendedUserIds,  List<String> waitlistUserIds, @JsonKey(toJson: _runConstraintsToJson)  RunConstraints constraints,  Map<String, int> genderCounts)  $default,) {final _that = this;
switch (_that) {
case _Run():
return $default(_that.id,_that.runClubId,_that.startTime,_that.endTime,_that.meetingPoint,_that.startingPointLat,_that.startingPointLng,_that.locationDetails,_that.distanceKm,_that.pace,_that.capacityLimit,_that.description,_that.priceInPaise,_that.signedUpUserIds,_that.attendedUserIds,_that.waitlistUserIds,_that.constraints,_that.genderCounts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String runClubId, @TimestampConverter()  DateTime startTime, @TimestampConverter()  DateTime endTime,  String meetingPoint,  double? startingPointLat,  double? startingPointLng,  String? locationDetails,  double distanceKm,  PaceLevel pace,  int capacityLimit,  String description,  int priceInPaise,  List<String> signedUpUserIds,  List<String> attendedUserIds,  List<String> waitlistUserIds, @JsonKey(toJson: _runConstraintsToJson)  RunConstraints constraints,  Map<String, int> genderCounts)?  $default,) {final _that = this;
switch (_that) {
case _Run() when $default != null:
return $default(_that.id,_that.runClubId,_that.startTime,_that.endTime,_that.meetingPoint,_that.startingPointLat,_that.startingPointLng,_that.locationDetails,_that.distanceKm,_that.pace,_that.capacityLimit,_that.description,_that.priceInPaise,_that.signedUpUserIds,_that.attendedUserIds,_that.waitlistUserIds,_that.constraints,_that.genderCounts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Run extends Run {
  const _Run({@JsonKey(includeToJson: false) required this.id, required this.runClubId, @TimestampConverter() required this.startTime, @TimestampConverter() required this.endTime, required this.meetingPoint, this.startingPointLat, this.startingPointLng, this.locationDetails, required this.distanceKm, required this.pace, required this.capacityLimit, required this.description, required this.priceInPaise, final  List<String> signedUpUserIds = const [], final  List<String> attendedUserIds = const [], final  List<String> waitlistUserIds = const [], @JsonKey(toJson: _runConstraintsToJson) this.constraints = const RunConstraints(), final  Map<String, int> genderCounts = const {}}): _signedUpUserIds = signedUpUserIds,_attendedUserIds = attendedUserIds,_waitlistUserIds = waitlistUserIds,_genderCounts = genderCounts,super._();
  factory _Run.fromJson(Map<String, dynamic> json) => _$RunFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String runClubId;
@override@TimestampConverter() final  DateTime startTime;
@override@TimestampConverter() final  DateTime endTime;
@override final  String meetingPoint;
@override final  double? startingPointLat;
@override final  double? startingPointLng;
@override final  String? locationDetails;
@override final  double distanceKm;
@override final  PaceLevel pace;
@override final  int capacityLimit;
@override final  String description;
@override final  int priceInPaise;
 final  List<String> _signedUpUserIds;
@override@JsonKey() List<String> get signedUpUserIds {
  if (_signedUpUserIds is EqualUnmodifiableListView) return _signedUpUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_signedUpUserIds);
}

 final  List<String> _attendedUserIds;
@override@JsonKey() List<String> get attendedUserIds {
  if (_attendedUserIds is EqualUnmodifiableListView) return _attendedUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_attendedUserIds);
}

 final  List<String> _waitlistUserIds;
@override@JsonKey() List<String> get waitlistUserIds {
  if (_waitlistUserIds is EqualUnmodifiableListView) return _waitlistUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_waitlistUserIds);
}

@override@JsonKey(toJson: _runConstraintsToJson) final  RunConstraints constraints;
// Denormalized gender counts maintained atomically by Cloud Functions.
// Keys are Gender enum names: 'man', 'woman', 'nonBinary', 'other'.
 final  Map<String, int> _genderCounts;
// Denormalized gender counts maintained atomically by Cloud Functions.
// Keys are Gender enum names: 'man', 'woman', 'nonBinary', 'other'.
@override@JsonKey() Map<String, int> get genderCounts {
  if (_genderCounts is EqualUnmodifiableMapView) return _genderCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_genderCounts);
}


/// Create a copy of Run
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunCopyWith<_Run> get copyWith => __$RunCopyWithImpl<_Run>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RunToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Run&&(identical(other.id, id) || other.id == id)&&(identical(other.runClubId, runClubId) || other.runClubId == runClubId)&&(identical(other.startTime, startTime) || other.startTime == startTime)&&(identical(other.endTime, endTime) || other.endTime == endTime)&&(identical(other.meetingPoint, meetingPoint) || other.meetingPoint == meetingPoint)&&(identical(other.startingPointLat, startingPointLat) || other.startingPointLat == startingPointLat)&&(identical(other.startingPointLng, startingPointLng) || other.startingPointLng == startingPointLng)&&(identical(other.locationDetails, locationDetails) || other.locationDetails == locationDetails)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.pace, pace) || other.pace == pace)&&(identical(other.capacityLimit, capacityLimit) || other.capacityLimit == capacityLimit)&&(identical(other.description, description) || other.description == description)&&(identical(other.priceInPaise, priceInPaise) || other.priceInPaise == priceInPaise)&&const DeepCollectionEquality().equals(other._signedUpUserIds, _signedUpUserIds)&&const DeepCollectionEquality().equals(other._attendedUserIds, _attendedUserIds)&&const DeepCollectionEquality().equals(other._waitlistUserIds, _waitlistUserIds)&&(identical(other.constraints, constraints) || other.constraints == constraints)&&const DeepCollectionEquality().equals(other._genderCounts, _genderCounts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,runClubId,startTime,endTime,meetingPoint,startingPointLat,startingPointLng,locationDetails,distanceKm,pace,capacityLimit,description,priceInPaise,const DeepCollectionEquality().hash(_signedUpUserIds),const DeepCollectionEquality().hash(_attendedUserIds),const DeepCollectionEquality().hash(_waitlistUserIds),constraints,const DeepCollectionEquality().hash(_genderCounts));

@override
String toString() {
  return 'Run(id: $id, runClubId: $runClubId, startTime: $startTime, endTime: $endTime, meetingPoint: $meetingPoint, startingPointLat: $startingPointLat, startingPointLng: $startingPointLng, locationDetails: $locationDetails, distanceKm: $distanceKm, pace: $pace, capacityLimit: $capacityLimit, description: $description, priceInPaise: $priceInPaise, signedUpUserIds: $signedUpUserIds, attendedUserIds: $attendedUserIds, waitlistUserIds: $waitlistUserIds, constraints: $constraints, genderCounts: $genderCounts)';
}


}

/// @nodoc
abstract mixin class _$RunCopyWith<$Res> implements $RunCopyWith<$Res> {
  factory _$RunCopyWith(_Run value, $Res Function(_Run) _then) = __$RunCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String runClubId,@TimestampConverter() DateTime startTime,@TimestampConverter() DateTime endTime, String meetingPoint, double? startingPointLat, double? startingPointLng, String? locationDetails, double distanceKm, PaceLevel pace, int capacityLimit, String description, int priceInPaise, List<String> signedUpUserIds, List<String> attendedUserIds, List<String> waitlistUserIds,@JsonKey(toJson: _runConstraintsToJson) RunConstraints constraints, Map<String, int> genderCounts
});


@override $RunConstraintsCopyWith<$Res> get constraints;

}
/// @nodoc
class __$RunCopyWithImpl<$Res>
    implements _$RunCopyWith<$Res> {
  __$RunCopyWithImpl(this._self, this._then);

  final _Run _self;
  final $Res Function(_Run) _then;

/// Create a copy of Run
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? runClubId = null,Object? startTime = null,Object? endTime = null,Object? meetingPoint = null,Object? startingPointLat = freezed,Object? startingPointLng = freezed,Object? locationDetails = freezed,Object? distanceKm = null,Object? pace = null,Object? capacityLimit = null,Object? description = null,Object? priceInPaise = null,Object? signedUpUserIds = null,Object? attendedUserIds = null,Object? waitlistUserIds = null,Object? constraints = null,Object? genderCounts = null,}) {
  return _then(_Run(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,runClubId: null == runClubId ? _self.runClubId : runClubId // ignore: cast_nullable_to_non_nullable
as String,startTime: null == startTime ? _self.startTime : startTime // ignore: cast_nullable_to_non_nullable
as DateTime,endTime: null == endTime ? _self.endTime : endTime // ignore: cast_nullable_to_non_nullable
as DateTime,meetingPoint: null == meetingPoint ? _self.meetingPoint : meetingPoint // ignore: cast_nullable_to_non_nullable
as String,startingPointLat: freezed == startingPointLat ? _self.startingPointLat : startingPointLat // ignore: cast_nullable_to_non_nullable
as double?,startingPointLng: freezed == startingPointLng ? _self.startingPointLng : startingPointLng // ignore: cast_nullable_to_non_nullable
as double?,locationDetails: freezed == locationDetails ? _self.locationDetails : locationDetails // ignore: cast_nullable_to_non_nullable
as String?,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,pace: null == pace ? _self.pace : pace // ignore: cast_nullable_to_non_nullable
as PaceLevel,capacityLimit: null == capacityLimit ? _self.capacityLimit : capacityLimit // ignore: cast_nullable_to_non_nullable
as int,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,priceInPaise: null == priceInPaise ? _self.priceInPaise : priceInPaise // ignore: cast_nullable_to_non_nullable
as int,signedUpUserIds: null == signedUpUserIds ? _self._signedUpUserIds : signedUpUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,attendedUserIds: null == attendedUserIds ? _self._attendedUserIds : attendedUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,waitlistUserIds: null == waitlistUserIds ? _self._waitlistUserIds : waitlistUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,constraints: null == constraints ? _self.constraints : constraints // ignore: cast_nullable_to_non_nullable
as RunConstraints,genderCounts: null == genderCounts ? _self._genderCounts : genderCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,
  ));
}

/// Create a copy of Run
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RunConstraintsCopyWith<$Res> get constraints {
  
  return $RunConstraintsCopyWith<$Res>(_self.constraints, (value) {
    return _then(_self.copyWith(constraints: value));
  });
}
}

// dart format on
