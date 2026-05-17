// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_participation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RunParticipation {

@JsonKey(includeToJson: false) String get id; String get runId; String get runClubId; String get uid; RunParticipationStatus get status;@TimestampConverter() DateTime get createdAt;@TimestampConverter() DateTime get updatedAt;@NullableTimestampConverter() DateTime? get signedUpAt;@NullableTimestampConverter() DateTime? get waitlistedAt;@NullableTimestampConverter() DateTime? get attendedAt;@NullableTimestampConverter() DateTime? get cancelledAt;@NullableTimestampConverter() DateTime? get deletedAt;@JsonKey(unknownEnumValue: null) Gender? get genderAtSignup; String? get cohortAtSignup; String? get paymentId;
/// Create a copy of RunParticipation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunParticipationCopyWith<RunParticipation> get copyWith => _$RunParticipationCopyWithImpl<RunParticipation>(this as RunParticipation, _$identity);

  /// Serializes this RunParticipation to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunParticipation&&(identical(other.id, id) || other.id == id)&&(identical(other.runId, runId) || other.runId == runId)&&(identical(other.runClubId, runClubId) || other.runClubId == runClubId)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.signedUpAt, signedUpAt) || other.signedUpAt == signedUpAt)&&(identical(other.waitlistedAt, waitlistedAt) || other.waitlistedAt == waitlistedAt)&&(identical(other.attendedAt, attendedAt) || other.attendedAt == attendedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.genderAtSignup, genderAtSignup) || other.genderAtSignup == genderAtSignup)&&(identical(other.cohortAtSignup, cohortAtSignup) || other.cohortAtSignup == cohortAtSignup)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,runId,runClubId,uid,status,createdAt,updatedAt,signedUpAt,waitlistedAt,attendedAt,cancelledAt,deletedAt,genderAtSignup,cohortAtSignup,paymentId);

@override
String toString() {
  return 'RunParticipation(id: $id, runId: $runId, runClubId: $runClubId, uid: $uid, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, signedUpAt: $signedUpAt, waitlistedAt: $waitlistedAt, attendedAt: $attendedAt, cancelledAt: $cancelledAt, deletedAt: $deletedAt, genderAtSignup: $genderAtSignup, cohortAtSignup: $cohortAtSignup, paymentId: $paymentId)';
}


}

/// @nodoc
abstract mixin class $RunParticipationCopyWith<$Res>  {
  factory $RunParticipationCopyWith(RunParticipation value, $Res Function(RunParticipation) _then) = _$RunParticipationCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String runId, String runClubId, String uid, RunParticipationStatus status,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt,@NullableTimestampConverter() DateTime? signedUpAt,@NullableTimestampConverter() DateTime? waitlistedAt,@NullableTimestampConverter() DateTime? attendedAt,@NullableTimestampConverter() DateTime? cancelledAt,@NullableTimestampConverter() DateTime? deletedAt,@JsonKey(unknownEnumValue: null) Gender? genderAtSignup, String? cohortAtSignup, String? paymentId
});




}
/// @nodoc
class _$RunParticipationCopyWithImpl<$Res>
    implements $RunParticipationCopyWith<$Res> {
  _$RunParticipationCopyWithImpl(this._self, this._then);

  final RunParticipation _self;
  final $Res Function(RunParticipation) _then;

/// Create a copy of RunParticipation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? runId = null,Object? runClubId = null,Object? uid = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? signedUpAt = freezed,Object? waitlistedAt = freezed,Object? attendedAt = freezed,Object? cancelledAt = freezed,Object? deletedAt = freezed,Object? genderAtSignup = freezed,Object? cohortAtSignup = freezed,Object? paymentId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,runId: null == runId ? _self.runId : runId // ignore: cast_nullable_to_non_nullable
as String,runClubId: null == runClubId ? _self.runClubId : runClubId // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RunParticipationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,signedUpAt: freezed == signedUpAt ? _self.signedUpAt : signedUpAt // ignore: cast_nullable_to_non_nullable
as DateTime?,waitlistedAt: freezed == waitlistedAt ? _self.waitlistedAt : waitlistedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,attendedAt: freezed == attendedAt ? _self.attendedAt : attendedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,genderAtSignup: freezed == genderAtSignup ? _self.genderAtSignup : genderAtSignup // ignore: cast_nullable_to_non_nullable
as Gender?,cohortAtSignup: freezed == cohortAtSignup ? _self.cohortAtSignup : cohortAtSignup // ignore: cast_nullable_to_non_nullable
as String?,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RunParticipation].
extension RunParticipationPatterns on RunParticipation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunParticipation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunParticipation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunParticipation value)  $default,){
final _that = this;
switch (_that) {
case _RunParticipation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunParticipation value)?  $default,){
final _that = this;
switch (_that) {
case _RunParticipation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String runId,  String runClubId,  String uid,  RunParticipationStatus status, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @NullableTimestampConverter()  DateTime? signedUpAt, @NullableTimestampConverter()  DateTime? waitlistedAt, @NullableTimestampConverter()  DateTime? attendedAt, @NullableTimestampConverter()  DateTime? cancelledAt, @NullableTimestampConverter()  DateTime? deletedAt, @JsonKey(unknownEnumValue: null)  Gender? genderAtSignup,  String? cohortAtSignup,  String? paymentId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunParticipation() when $default != null:
return $default(_that.id,_that.runId,_that.runClubId,_that.uid,_that.status,_that.createdAt,_that.updatedAt,_that.signedUpAt,_that.waitlistedAt,_that.attendedAt,_that.cancelledAt,_that.deletedAt,_that.genderAtSignup,_that.cohortAtSignup,_that.paymentId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String runId,  String runClubId,  String uid,  RunParticipationStatus status, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @NullableTimestampConverter()  DateTime? signedUpAt, @NullableTimestampConverter()  DateTime? waitlistedAt, @NullableTimestampConverter()  DateTime? attendedAt, @NullableTimestampConverter()  DateTime? cancelledAt, @NullableTimestampConverter()  DateTime? deletedAt, @JsonKey(unknownEnumValue: null)  Gender? genderAtSignup,  String? cohortAtSignup,  String? paymentId)  $default,) {final _that = this;
switch (_that) {
case _RunParticipation():
return $default(_that.id,_that.runId,_that.runClubId,_that.uid,_that.status,_that.createdAt,_that.updatedAt,_that.signedUpAt,_that.waitlistedAt,_that.attendedAt,_that.cancelledAt,_that.deletedAt,_that.genderAtSignup,_that.cohortAtSignup,_that.paymentId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String runId,  String runClubId,  String uid,  RunParticipationStatus status, @TimestampConverter()  DateTime createdAt, @TimestampConverter()  DateTime updatedAt, @NullableTimestampConverter()  DateTime? signedUpAt, @NullableTimestampConverter()  DateTime? waitlistedAt, @NullableTimestampConverter()  DateTime? attendedAt, @NullableTimestampConverter()  DateTime? cancelledAt, @NullableTimestampConverter()  DateTime? deletedAt, @JsonKey(unknownEnumValue: null)  Gender? genderAtSignup,  String? cohortAtSignup,  String? paymentId)?  $default,) {final _that = this;
switch (_that) {
case _RunParticipation() when $default != null:
return $default(_that.id,_that.runId,_that.runClubId,_that.uid,_that.status,_that.createdAt,_that.updatedAt,_that.signedUpAt,_that.waitlistedAt,_that.attendedAt,_that.cancelledAt,_that.deletedAt,_that.genderAtSignup,_that.cohortAtSignup,_that.paymentId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RunParticipation implements RunParticipation {
  const _RunParticipation({@JsonKey(includeToJson: false) required this.id, required this.runId, required this.runClubId, required this.uid, required this.status, @TimestampConverter() required this.createdAt, @TimestampConverter() required this.updatedAt, @NullableTimestampConverter() this.signedUpAt, @NullableTimestampConverter() this.waitlistedAt, @NullableTimestampConverter() this.attendedAt, @NullableTimestampConverter() this.cancelledAt, @NullableTimestampConverter() this.deletedAt, @JsonKey(unknownEnumValue: null) this.genderAtSignup, this.cohortAtSignup, this.paymentId});
  factory _RunParticipation.fromJson(Map<String, dynamic> json) => _$RunParticipationFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String runId;
@override final  String runClubId;
@override final  String uid;
@override final  RunParticipationStatus status;
@override@TimestampConverter() final  DateTime createdAt;
@override@TimestampConverter() final  DateTime updatedAt;
@override@NullableTimestampConverter() final  DateTime? signedUpAt;
@override@NullableTimestampConverter() final  DateTime? waitlistedAt;
@override@NullableTimestampConverter() final  DateTime? attendedAt;
@override@NullableTimestampConverter() final  DateTime? cancelledAt;
@override@NullableTimestampConverter() final  DateTime? deletedAt;
@override@JsonKey(unknownEnumValue: null) final  Gender? genderAtSignup;
@override final  String? cohortAtSignup;
@override final  String? paymentId;

/// Create a copy of RunParticipation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunParticipationCopyWith<_RunParticipation> get copyWith => __$RunParticipationCopyWithImpl<_RunParticipation>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RunParticipationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunParticipation&&(identical(other.id, id) || other.id == id)&&(identical(other.runId, runId) || other.runId == runId)&&(identical(other.runClubId, runClubId) || other.runClubId == runClubId)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.signedUpAt, signedUpAt) || other.signedUpAt == signedUpAt)&&(identical(other.waitlistedAt, waitlistedAt) || other.waitlistedAt == waitlistedAt)&&(identical(other.attendedAt, attendedAt) || other.attendedAt == attendedAt)&&(identical(other.cancelledAt, cancelledAt) || other.cancelledAt == cancelledAt)&&(identical(other.deletedAt, deletedAt) || other.deletedAt == deletedAt)&&(identical(other.genderAtSignup, genderAtSignup) || other.genderAtSignup == genderAtSignup)&&(identical(other.cohortAtSignup, cohortAtSignup) || other.cohortAtSignup == cohortAtSignup)&&(identical(other.paymentId, paymentId) || other.paymentId == paymentId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,runId,runClubId,uid,status,createdAt,updatedAt,signedUpAt,waitlistedAt,attendedAt,cancelledAt,deletedAt,genderAtSignup,cohortAtSignup,paymentId);

@override
String toString() {
  return 'RunParticipation(id: $id, runId: $runId, runClubId: $runClubId, uid: $uid, status: $status, createdAt: $createdAt, updatedAt: $updatedAt, signedUpAt: $signedUpAt, waitlistedAt: $waitlistedAt, attendedAt: $attendedAt, cancelledAt: $cancelledAt, deletedAt: $deletedAt, genderAtSignup: $genderAtSignup, cohortAtSignup: $cohortAtSignup, paymentId: $paymentId)';
}


}

/// @nodoc
abstract mixin class _$RunParticipationCopyWith<$Res> implements $RunParticipationCopyWith<$Res> {
  factory _$RunParticipationCopyWith(_RunParticipation value, $Res Function(_RunParticipation) _then) = __$RunParticipationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String runId, String runClubId, String uid, RunParticipationStatus status,@TimestampConverter() DateTime createdAt,@TimestampConverter() DateTime updatedAt,@NullableTimestampConverter() DateTime? signedUpAt,@NullableTimestampConverter() DateTime? waitlistedAt,@NullableTimestampConverter() DateTime? attendedAt,@NullableTimestampConverter() DateTime? cancelledAt,@NullableTimestampConverter() DateTime? deletedAt,@JsonKey(unknownEnumValue: null) Gender? genderAtSignup, String? cohortAtSignup, String? paymentId
});




}
/// @nodoc
class __$RunParticipationCopyWithImpl<$Res>
    implements _$RunParticipationCopyWith<$Res> {
  __$RunParticipationCopyWithImpl(this._self, this._then);

  final _RunParticipation _self;
  final $Res Function(_RunParticipation) _then;

/// Create a copy of RunParticipation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? runId = null,Object? runClubId = null,Object? uid = null,Object? status = null,Object? createdAt = null,Object? updatedAt = null,Object? signedUpAt = freezed,Object? waitlistedAt = freezed,Object? attendedAt = freezed,Object? cancelledAt = freezed,Object? deletedAt = freezed,Object? genderAtSignup = freezed,Object? cohortAtSignup = freezed,Object? paymentId = freezed,}) {
  return _then(_RunParticipation(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,runId: null == runId ? _self.runId : runId // ignore: cast_nullable_to_non_nullable
as String,runClubId: null == runClubId ? _self.runClubId : runClubId // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as RunParticipationStatus,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,signedUpAt: freezed == signedUpAt ? _self.signedUpAt : signedUpAt // ignore: cast_nullable_to_non_nullable
as DateTime?,waitlistedAt: freezed == waitlistedAt ? _self.waitlistedAt : waitlistedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,attendedAt: freezed == attendedAt ? _self.attendedAt : attendedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,cancelledAt: freezed == cancelledAt ? _self.cancelledAt : cancelledAt // ignore: cast_nullable_to_non_nullable
as DateTime?,deletedAt: freezed == deletedAt ? _self.deletedAt : deletedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,genderAtSignup: freezed == genderAtSignup ? _self.genderAtSignup : genderAtSignup // ignore: cast_nullable_to_non_nullable
as Gender?,cohortAtSignup: freezed == cohortAtSignup ? _self.cohortAtSignup : cohortAtSignup // ignore: cast_nullable_to_non_nullable
as String?,paymentId: freezed == paymentId ? _self.paymentId : paymentId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
