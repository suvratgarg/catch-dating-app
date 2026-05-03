// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'match.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Match {

@JsonKey(includeToJson: false) String get id; String get user1Id; String get user2Id; String get runId;@TimestampConverter() DateTime get createdAt;@NullableTimestampConverter() DateTime? get lastMessageAt; String? get lastMessagePreview; String? get lastMessageSenderId; Map<String, int> get unreadCounts; MatchStatus get status; String? get blockedBy;@NullableTimestampConverter() DateTime? get blockedAt;
/// Create a copy of Match
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MatchCopyWith<Match> get copyWith => _$MatchCopyWithImpl<Match>(this as Match, _$identity);

  /// Serializes this Match to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Match&&(identical(other.id, id) || other.id == id)&&(identical(other.user1Id, user1Id) || other.user1Id == user1Id)&&(identical(other.user2Id, user2Id) || other.user2Id == user2Id)&&(identical(other.runId, runId) || other.runId == runId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessagePreview, lastMessagePreview) || other.lastMessagePreview == lastMessagePreview)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&const DeepCollectionEquality().equals(other.unreadCounts, unreadCounts)&&(identical(other.status, status) || other.status == status)&&(identical(other.blockedBy, blockedBy) || other.blockedBy == blockedBy)&&(identical(other.blockedAt, blockedAt) || other.blockedAt == blockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user1Id,user2Id,runId,createdAt,lastMessageAt,lastMessagePreview,lastMessageSenderId,const DeepCollectionEquality().hash(unreadCounts),status,blockedBy,blockedAt);

@override
String toString() {
  return 'Match(id: $id, user1Id: $user1Id, user2Id: $user2Id, runId: $runId, createdAt: $createdAt, lastMessageAt: $lastMessageAt, lastMessagePreview: $lastMessagePreview, lastMessageSenderId: $lastMessageSenderId, unreadCounts: $unreadCounts, status: $status, blockedBy: $blockedBy, blockedAt: $blockedAt)';
}


}

/// @nodoc
abstract mixin class $MatchCopyWith<$Res>  {
  factory $MatchCopyWith(Match value, $Res Function(Match) _then) = _$MatchCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String user1Id, String user2Id, String runId,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? lastMessageAt, String? lastMessagePreview, String? lastMessageSenderId, Map<String, int> unreadCounts, MatchStatus status, String? blockedBy,@NullableTimestampConverter() DateTime? blockedAt
});




}
/// @nodoc
class _$MatchCopyWithImpl<$Res>
    implements $MatchCopyWith<$Res> {
  _$MatchCopyWithImpl(this._self, this._then);

  final Match _self;
  final $Res Function(Match) _then;

/// Create a copy of Match
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? user1Id = null,Object? user2Id = null,Object? runId = null,Object? createdAt = null,Object? lastMessageAt = freezed,Object? lastMessagePreview = freezed,Object? lastMessageSenderId = freezed,Object? unreadCounts = null,Object? status = null,Object? blockedBy = freezed,Object? blockedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,user1Id: null == user1Id ? _self.user1Id : user1Id // ignore: cast_nullable_to_non_nullable
as String,user2Id: null == user2Id ? _self.user2Id : user2Id // ignore: cast_nullable_to_non_nullable
as String,runId: null == runId ? _self.runId : runId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessagePreview: freezed == lastMessagePreview ? _self.lastMessagePreview : lastMessagePreview // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,unreadCounts: null == unreadCounts ? _self.unreadCounts : unreadCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchStatus,blockedBy: freezed == blockedBy ? _self.blockedBy : blockedBy // ignore: cast_nullable_to_non_nullable
as String?,blockedAt: freezed == blockedAt ? _self.blockedAt : blockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [Match].
extension MatchPatterns on Match {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Match value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Match() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Match value)  $default,){
final _that = this;
switch (_that) {
case _Match():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Match value)?  $default,){
final _that = this;
switch (_that) {
case _Match() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String user1Id,  String user2Id,  String runId, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? lastMessageAt,  String? lastMessagePreview,  String? lastMessageSenderId,  Map<String, int> unreadCounts,  MatchStatus status,  String? blockedBy, @NullableTimestampConverter()  DateTime? blockedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Match() when $default != null:
return $default(_that.id,_that.user1Id,_that.user2Id,_that.runId,_that.createdAt,_that.lastMessageAt,_that.lastMessagePreview,_that.lastMessageSenderId,_that.unreadCounts,_that.status,_that.blockedBy,_that.blockedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String user1Id,  String user2Id,  String runId, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? lastMessageAt,  String? lastMessagePreview,  String? lastMessageSenderId,  Map<String, int> unreadCounts,  MatchStatus status,  String? blockedBy, @NullableTimestampConverter()  DateTime? blockedAt)  $default,) {final _that = this;
switch (_that) {
case _Match():
return $default(_that.id,_that.user1Id,_that.user2Id,_that.runId,_that.createdAt,_that.lastMessageAt,_that.lastMessagePreview,_that.lastMessageSenderId,_that.unreadCounts,_that.status,_that.blockedBy,_that.blockedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String user1Id,  String user2Id,  String runId, @TimestampConverter()  DateTime createdAt, @NullableTimestampConverter()  DateTime? lastMessageAt,  String? lastMessagePreview,  String? lastMessageSenderId,  Map<String, int> unreadCounts,  MatchStatus status,  String? blockedBy, @NullableTimestampConverter()  DateTime? blockedAt)?  $default,) {final _that = this;
switch (_that) {
case _Match() when $default != null:
return $default(_that.id,_that.user1Id,_that.user2Id,_that.runId,_that.createdAt,_that.lastMessageAt,_that.lastMessagePreview,_that.lastMessageSenderId,_that.unreadCounts,_that.status,_that.blockedBy,_that.blockedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Match extends Match {
  const _Match({@JsonKey(includeToJson: false) required this.id, required this.user1Id, required this.user2Id, required this.runId, @TimestampConverter() required this.createdAt, @NullableTimestampConverter() this.lastMessageAt, this.lastMessagePreview, this.lastMessageSenderId, final  Map<String, int> unreadCounts = const {}, this.status = MatchStatus.active, this.blockedBy, @NullableTimestampConverter() this.blockedAt}): _unreadCounts = unreadCounts,super._();
  factory _Match.fromJson(Map<String, dynamic> json) => _$MatchFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String user1Id;
@override final  String user2Id;
@override final  String runId;
@override@TimestampConverter() final  DateTime createdAt;
@override@NullableTimestampConverter() final  DateTime? lastMessageAt;
@override final  String? lastMessagePreview;
@override final  String? lastMessageSenderId;
 final  Map<String, int> _unreadCounts;
@override@JsonKey() Map<String, int> get unreadCounts {
  if (_unreadCounts is EqualUnmodifiableMapView) return _unreadCounts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_unreadCounts);
}

@override@JsonKey() final  MatchStatus status;
@override final  String? blockedBy;
@override@NullableTimestampConverter() final  DateTime? blockedAt;

/// Create a copy of Match
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MatchCopyWith<_Match> get copyWith => __$MatchCopyWithImpl<_Match>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Match&&(identical(other.id, id) || other.id == id)&&(identical(other.user1Id, user1Id) || other.user1Id == user1Id)&&(identical(other.user2Id, user2Id) || other.user2Id == user2Id)&&(identical(other.runId, runId) || other.runId == runId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.lastMessageAt, lastMessageAt) || other.lastMessageAt == lastMessageAt)&&(identical(other.lastMessagePreview, lastMessagePreview) || other.lastMessagePreview == lastMessagePreview)&&(identical(other.lastMessageSenderId, lastMessageSenderId) || other.lastMessageSenderId == lastMessageSenderId)&&const DeepCollectionEquality().equals(other._unreadCounts, _unreadCounts)&&(identical(other.status, status) || other.status == status)&&(identical(other.blockedBy, blockedBy) || other.blockedBy == blockedBy)&&(identical(other.blockedAt, blockedAt) || other.blockedAt == blockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,user1Id,user2Id,runId,createdAt,lastMessageAt,lastMessagePreview,lastMessageSenderId,const DeepCollectionEquality().hash(_unreadCounts),status,blockedBy,blockedAt);

@override
String toString() {
  return 'Match(id: $id, user1Id: $user1Id, user2Id: $user2Id, runId: $runId, createdAt: $createdAt, lastMessageAt: $lastMessageAt, lastMessagePreview: $lastMessagePreview, lastMessageSenderId: $lastMessageSenderId, unreadCounts: $unreadCounts, status: $status, blockedBy: $blockedBy, blockedAt: $blockedAt)';
}


}

/// @nodoc
abstract mixin class _$MatchCopyWith<$Res> implements $MatchCopyWith<$Res> {
  factory _$MatchCopyWith(_Match value, $Res Function(_Match) _then) = __$MatchCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String user1Id, String user2Id, String runId,@TimestampConverter() DateTime createdAt,@NullableTimestampConverter() DateTime? lastMessageAt, String? lastMessagePreview, String? lastMessageSenderId, Map<String, int> unreadCounts, MatchStatus status, String? blockedBy,@NullableTimestampConverter() DateTime? blockedAt
});




}
/// @nodoc
class __$MatchCopyWithImpl<$Res>
    implements _$MatchCopyWith<$Res> {
  __$MatchCopyWithImpl(this._self, this._then);

  final _Match _self;
  final $Res Function(_Match) _then;

/// Create a copy of Match
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? user1Id = null,Object? user2Id = null,Object? runId = null,Object? createdAt = null,Object? lastMessageAt = freezed,Object? lastMessagePreview = freezed,Object? lastMessageSenderId = freezed,Object? unreadCounts = null,Object? status = null,Object? blockedBy = freezed,Object? blockedAt = freezed,}) {
  return _then(_Match(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,user1Id: null == user1Id ? _self.user1Id : user1Id // ignore: cast_nullable_to_non_nullable
as String,user2Id: null == user2Id ? _self.user2Id : user2Id // ignore: cast_nullable_to_non_nullable
as String,runId: null == runId ? _self.runId : runId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,lastMessageAt: freezed == lastMessageAt ? _self.lastMessageAt : lastMessageAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastMessagePreview: freezed == lastMessagePreview ? _self.lastMessagePreview : lastMessagePreview // ignore: cast_nullable_to_non_nullable
as String?,lastMessageSenderId: freezed == lastMessageSenderId ? _self.lastMessageSenderId : lastMessageSenderId // ignore: cast_nullable_to_non_nullable
as String?,unreadCounts: null == unreadCounts ? _self._unreadCounts : unreadCounts // ignore: cast_nullable_to_non_nullable
as Map<String, int>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as MatchStatus,blockedBy: freezed == blockedBy ? _self.blockedBy : blockedBy // ignore: cast_nullable_to_non_nullable
as String?,blockedAt: freezed == blockedAt ? _self.blockedAt : blockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
