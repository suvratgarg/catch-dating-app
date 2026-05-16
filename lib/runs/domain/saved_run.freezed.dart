// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'saved_run.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SavedRun {

@JsonKey(includeToJson: false) String get id; String get uid; String get runId;@TimestampConverter() DateTime get savedAt;
/// Create a copy of SavedRun
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SavedRunCopyWith<SavedRun> get copyWith => _$SavedRunCopyWithImpl<SavedRun>(this as SavedRun, _$identity);

  /// Serializes this SavedRun to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SavedRun&&(identical(other.id, id) || other.id == id)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.runId, runId) || other.runId == runId)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uid,runId,savedAt);

@override
String toString() {
  return 'SavedRun(id: $id, uid: $uid, runId: $runId, savedAt: $savedAt)';
}


}

/// @nodoc
abstract mixin class $SavedRunCopyWith<$Res>  {
  factory $SavedRunCopyWith(SavedRun value, $Res Function(SavedRun) _then) = _$SavedRunCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String uid, String runId,@TimestampConverter() DateTime savedAt
});




}
/// @nodoc
class _$SavedRunCopyWithImpl<$Res>
    implements $SavedRunCopyWith<$Res> {
  _$SavedRunCopyWithImpl(this._self, this._then);

  final SavedRun _self;
  final $Res Function(SavedRun) _then;

/// Create a copy of SavedRun
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? uid = null,Object? runId = null,Object? savedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,runId: null == runId ? _self.runId : runId // ignore: cast_nullable_to_non_nullable
as String,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [SavedRun].
extension SavedRunPatterns on SavedRun {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SavedRun value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SavedRun() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SavedRun value)  $default,){
final _that = this;
switch (_that) {
case _SavedRun():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SavedRun value)?  $default,){
final _that = this;
switch (_that) {
case _SavedRun() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String uid,  String runId, @TimestampConverter()  DateTime savedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SavedRun() when $default != null:
return $default(_that.id,_that.uid,_that.runId,_that.savedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String uid,  String runId, @TimestampConverter()  DateTime savedAt)  $default,) {final _that = this;
switch (_that) {
case _SavedRun():
return $default(_that.id,_that.uid,_that.runId,_that.savedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String uid,  String runId, @TimestampConverter()  DateTime savedAt)?  $default,) {final _that = this;
switch (_that) {
case _SavedRun() when $default != null:
return $default(_that.id,_that.uid,_that.runId,_that.savedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SavedRun implements SavedRun {
  const _SavedRun({@JsonKey(includeToJson: false) required this.id, required this.uid, required this.runId, @TimestampConverter() required this.savedAt});
  factory _SavedRun.fromJson(Map<String, dynamic> json) => _$SavedRunFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String uid;
@override final  String runId;
@override@TimestampConverter() final  DateTime savedAt;

/// Create a copy of SavedRun
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SavedRunCopyWith<_SavedRun> get copyWith => __$SavedRunCopyWithImpl<_SavedRun>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SavedRunToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SavedRun&&(identical(other.id, id) || other.id == id)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.runId, runId) || other.runId == runId)&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,uid,runId,savedAt);

@override
String toString() {
  return 'SavedRun(id: $id, uid: $uid, runId: $runId, savedAt: $savedAt)';
}


}

/// @nodoc
abstract mixin class _$SavedRunCopyWith<$Res> implements $SavedRunCopyWith<$Res> {
  factory _$SavedRunCopyWith(_SavedRun value, $Res Function(_SavedRun) _then) = __$SavedRunCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String uid, String runId,@TimestampConverter() DateTime savedAt
});




}
/// @nodoc
class __$SavedRunCopyWithImpl<$Res>
    implements _$SavedRunCopyWith<$Res> {
  __$SavedRunCopyWithImpl(this._self, this._then);

  final _SavedRun _self;
  final $Res Function(_SavedRun) _then;

/// Create a copy of SavedRun
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? uid = null,Object? runId = null,Object? savedAt = null,}) {
  return _then(_SavedRun(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,uid: null == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String,runId: null == runId ? _self.runId : runId // ignore: cast_nullable_to_non_nullable
as String,savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
