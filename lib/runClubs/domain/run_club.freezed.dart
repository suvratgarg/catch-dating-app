// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_club.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RunClub {

@JsonKey(includeToJson: false) String get id; String get name; String get description; IndianCity get location; String get hostUserId;@TimestampConverter() DateTime get createdAt; String? get imageUrl; List<String> get memberUserIds; double get rating; int get reviewCount;
/// Create a copy of RunClub
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunClubCopyWith<RunClub> get copyWith => _$RunClubCopyWithImpl<RunClub>(this as RunClub, _$identity);

  /// Serializes this RunClub to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunClub&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.hostUserId, hostUserId) || other.hostUserId == hostUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.memberUserIds, memberUserIds)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,location,hostUserId,createdAt,imageUrl,const DeepCollectionEquality().hash(memberUserIds),rating,reviewCount);

@override
String toString() {
  return 'RunClub(id: $id, name: $name, description: $description, location: $location, hostUserId: $hostUserId, createdAt: $createdAt, imageUrl: $imageUrl, memberUserIds: $memberUserIds, rating: $rating, reviewCount: $reviewCount)';
}


}

/// @nodoc
abstract mixin class $RunClubCopyWith<$Res>  {
  factory $RunClubCopyWith(RunClub value, $Res Function(RunClub) _then) = _$RunClubCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String description, IndianCity location, String hostUserId,@TimestampConverter() DateTime createdAt, String? imageUrl, List<String> memberUserIds, double rating, int reviewCount
});




}
/// @nodoc
class _$RunClubCopyWithImpl<$Res>
    implements $RunClubCopyWith<$Res> {
  _$RunClubCopyWithImpl(this._self, this._then);

  final RunClub _self;
  final $Res Function(RunClub) _then;

/// Create a copy of RunClub
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? location = null,Object? hostUserId = null,Object? createdAt = null,Object? imageUrl = freezed,Object? memberUserIds = null,Object? rating = null,Object? reviewCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as IndianCity,hostUserId: null == hostUserId ? _self.hostUserId : hostUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,memberUserIds: null == memberUserIds ? _self.memberUserIds : memberUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [RunClub].
extension RunClubPatterns on RunClub {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunClub value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunClub() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunClub value)  $default,){
final _that = this;
switch (_that) {
case _RunClub():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunClub value)?  $default,){
final _that = this;
switch (_that) {
case _RunClub() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String description,  IndianCity location,  String hostUserId, @TimestampConverter()  DateTime createdAt,  String? imageUrl,  List<String> memberUserIds,  double rating,  int reviewCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunClub() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.location,_that.hostUserId,_that.createdAt,_that.imageUrl,_that.memberUserIds,_that.rating,_that.reviewCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String description,  IndianCity location,  String hostUserId, @TimestampConverter()  DateTime createdAt,  String? imageUrl,  List<String> memberUserIds,  double rating,  int reviewCount)  $default,) {final _that = this;
switch (_that) {
case _RunClub():
return $default(_that.id,_that.name,_that.description,_that.location,_that.hostUserId,_that.createdAt,_that.imageUrl,_that.memberUserIds,_that.rating,_that.reviewCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String name,  String description,  IndianCity location,  String hostUserId, @TimestampConverter()  DateTime createdAt,  String? imageUrl,  List<String> memberUserIds,  double rating,  int reviewCount)?  $default,) {final _that = this;
switch (_that) {
case _RunClub() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.location,_that.hostUserId,_that.createdAt,_that.imageUrl,_that.memberUserIds,_that.rating,_that.reviewCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RunClub implements RunClub {
  const _RunClub({@JsonKey(includeToJson: false) required this.id, required this.name, required this.description, required this.location, required this.hostUserId, @TimestampConverter() required this.createdAt, this.imageUrl, final  List<String> memberUserIds = const [], this.rating = 0.0, this.reviewCount = 0}): _memberUserIds = memberUserIds;
  factory _RunClub.fromJson(Map<String, dynamic> json) => _$RunClubFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String name;
@override final  String description;
@override final  IndianCity location;
@override final  String hostUserId;
@override@TimestampConverter() final  DateTime createdAt;
@override final  String? imageUrl;
 final  List<String> _memberUserIds;
@override@JsonKey() List<String> get memberUserIds {
  if (_memberUserIds is EqualUnmodifiableListView) return _memberUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberUserIds);
}

@override@JsonKey() final  double rating;
@override@JsonKey() final  int reviewCount;

/// Create a copy of RunClub
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunClubCopyWith<_RunClub> get copyWith => __$RunClubCopyWithImpl<_RunClub>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RunClubToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunClub&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.hostUserId, hostUserId) || other.hostUserId == hostUserId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._memberUserIds, _memberUserIds)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,location,hostUserId,createdAt,imageUrl,const DeepCollectionEquality().hash(_memberUserIds),rating,reviewCount);

@override
String toString() {
  return 'RunClub(id: $id, name: $name, description: $description, location: $location, hostUserId: $hostUserId, createdAt: $createdAt, imageUrl: $imageUrl, memberUserIds: $memberUserIds, rating: $rating, reviewCount: $reviewCount)';
}


}

/// @nodoc
abstract mixin class _$RunClubCopyWith<$Res> implements $RunClubCopyWith<$Res> {
  factory _$RunClubCopyWith(_RunClub value, $Res Function(_RunClub) _then) = __$RunClubCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String description, IndianCity location, String hostUserId,@TimestampConverter() DateTime createdAt, String? imageUrl, List<String> memberUserIds, double rating, int reviewCount
});




}
/// @nodoc
class __$RunClubCopyWithImpl<$Res>
    implements _$RunClubCopyWith<$Res> {
  __$RunClubCopyWithImpl(this._self, this._then);

  final _RunClub _self;
  final $Res Function(_RunClub) _then;

/// Create a copy of RunClub
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? location = null,Object? hostUserId = null,Object? createdAt = null,Object? imageUrl = freezed,Object? memberUserIds = null,Object? rating = null,Object? reviewCount = null,}) {
  return _then(_RunClub(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as IndianCity,hostUserId: null == hostUserId ? _self.hostUserId : hostUserId // ignore: cast_nullable_to_non_nullable
as String,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,memberUserIds: null == memberUserIds ? _self._memberUserIds : memberUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
