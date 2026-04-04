// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'swipe.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Swipe {

 String get swiperId; String get targetId; String get runId; SwipeDirection get direction;@TimestampConverter() DateTime get createdAt;
/// Create a copy of Swipe
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SwipeCopyWith<Swipe> get copyWith => _$SwipeCopyWithImpl<Swipe>(this as Swipe, _$identity);

  /// Serializes this Swipe to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Swipe&&(identical(other.swiperId, swiperId) || other.swiperId == swiperId)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.runId, runId) || other.runId == runId)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,swiperId,targetId,runId,direction,createdAt);

@override
String toString() {
  return 'Swipe(swiperId: $swiperId, targetId: $targetId, runId: $runId, direction: $direction, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $SwipeCopyWith<$Res>  {
  factory $SwipeCopyWith(Swipe value, $Res Function(Swipe) _then) = _$SwipeCopyWithImpl;
@useResult
$Res call({
 String swiperId, String targetId, String runId, SwipeDirection direction,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class _$SwipeCopyWithImpl<$Res>
    implements $SwipeCopyWith<$Res> {
  _$SwipeCopyWithImpl(this._self, this._then);

  final Swipe _self;
  final $Res Function(Swipe) _then;

/// Create a copy of Swipe
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? swiperId = null,Object? targetId = null,Object? runId = null,Object? direction = null,Object? createdAt = null,}) {
  return _then(_self.copyWith(
swiperId: null == swiperId ? _self.swiperId : swiperId // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,runId: null == runId ? _self.runId : runId // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as SwipeDirection,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Swipe].
extension SwipePatterns on Swipe {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Swipe value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Swipe() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Swipe value)  $default,){
final _that = this;
switch (_that) {
case _Swipe():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Swipe value)?  $default,){
final _that = this;
switch (_that) {
case _Swipe() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String swiperId,  String targetId,  String runId,  SwipeDirection direction, @TimestampConverter()  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Swipe() when $default != null:
return $default(_that.swiperId,_that.targetId,_that.runId,_that.direction,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String swiperId,  String targetId,  String runId,  SwipeDirection direction, @TimestampConverter()  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _Swipe():
return $default(_that.swiperId,_that.targetId,_that.runId,_that.direction,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String swiperId,  String targetId,  String runId,  SwipeDirection direction, @TimestampConverter()  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _Swipe() when $default != null:
return $default(_that.swiperId,_that.targetId,_that.runId,_that.direction,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Swipe implements Swipe {
  const _Swipe({required this.swiperId, required this.targetId, required this.runId, required this.direction, @TimestampConverter() required this.createdAt});
  factory _Swipe.fromJson(Map<String, dynamic> json) => _$SwipeFromJson(json);

@override final  String swiperId;
@override final  String targetId;
@override final  String runId;
@override final  SwipeDirection direction;
@override@TimestampConverter() final  DateTime createdAt;

/// Create a copy of Swipe
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SwipeCopyWith<_Swipe> get copyWith => __$SwipeCopyWithImpl<_Swipe>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SwipeToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Swipe&&(identical(other.swiperId, swiperId) || other.swiperId == swiperId)&&(identical(other.targetId, targetId) || other.targetId == targetId)&&(identical(other.runId, runId) || other.runId == runId)&&(identical(other.direction, direction) || other.direction == direction)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,swiperId,targetId,runId,direction,createdAt);

@override
String toString() {
  return 'Swipe(swiperId: $swiperId, targetId: $targetId, runId: $runId, direction: $direction, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$SwipeCopyWith<$Res> implements $SwipeCopyWith<$Res> {
  factory _$SwipeCopyWith(_Swipe value, $Res Function(_Swipe) _then) = __$SwipeCopyWithImpl;
@override @useResult
$Res call({
 String swiperId, String targetId, String runId, SwipeDirection direction,@TimestampConverter() DateTime createdAt
});




}
/// @nodoc
class __$SwipeCopyWithImpl<$Res>
    implements _$SwipeCopyWith<$Res> {
  __$SwipeCopyWithImpl(this._self, this._then);

  final _Swipe _self;
  final $Res Function(_Swipe) _then;

/// Create a copy of Swipe
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? swiperId = null,Object? targetId = null,Object? runId = null,Object? direction = null,Object? createdAt = null,}) {
  return _then(_Swipe(
swiperId: null == swiperId ? _self.swiperId : swiperId // ignore: cast_nullable_to_non_nullable
as String,targetId: null == targetId ? _self.targetId : targetId // ignore: cast_nullable_to_non_nullable
as String,runId: null == runId ? _self.runId : runId // ignore: cast_nullable_to_non_nullable
as String,direction: null == direction ? _self.direction : direction // ignore: cast_nullable_to_non_nullable
as SwipeDirection,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
