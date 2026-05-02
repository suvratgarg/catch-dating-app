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

@JsonKey(includeToJson: false) String get id; String get name; String get description; IndianCity get location; String get area; String get hostUserId; String get hostName; String? get hostAvatarUrl;@TimestampConverter() DateTime get createdAt; String? get imageUrl; List<String> get tags; List<String> get memberUserIds; int get memberCount; double get rating; int get reviewCount;@TimestampConverter() DateTime? get nextRunAt; String? get nextRunLabel; String? get instagramHandle; String? get phoneNumber; String? get email;
/// Create a copy of RunClub
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunClubCopyWith<RunClub> get copyWith => _$RunClubCopyWithImpl<RunClub>(this as RunClub, _$identity);

  /// Serializes this RunClub to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunClub&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.area, area) || other.area == area)&&(identical(other.hostUserId, hostUserId) || other.hostUserId == hostUserId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.hostAvatarUrl, hostAvatarUrl) || other.hostAvatarUrl == hostAvatarUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.tags, tags)&&const DeepCollectionEquality().equals(other.memberUserIds, memberUserIds)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.nextRunAt, nextRunAt) || other.nextRunAt == nextRunAt)&&(identical(other.nextRunLabel, nextRunLabel) || other.nextRunLabel == nextRunLabel)&&(identical(other.instagramHandle, instagramHandle) || other.instagramHandle == instagramHandle)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,location,area,hostUserId,hostName,hostAvatarUrl,createdAt,imageUrl,const DeepCollectionEquality().hash(tags),const DeepCollectionEquality().hash(memberUserIds),memberCount,rating,reviewCount,nextRunAt,nextRunLabel,instagramHandle,phoneNumber,email]);

@override
String toString() {
  return 'RunClub(id: $id, name: $name, description: $description, location: $location, area: $area, hostUserId: $hostUserId, hostName: $hostName, hostAvatarUrl: $hostAvatarUrl, createdAt: $createdAt, imageUrl: $imageUrl, tags: $tags, memberUserIds: $memberUserIds, memberCount: $memberCount, rating: $rating, reviewCount: $reviewCount, nextRunAt: $nextRunAt, nextRunLabel: $nextRunLabel, instagramHandle: $instagramHandle, phoneNumber: $phoneNumber, email: $email)';
}


}

/// @nodoc
abstract mixin class $RunClubCopyWith<$Res>  {
  factory $RunClubCopyWith(RunClub value, $Res Function(RunClub) _then) = _$RunClubCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String description, IndianCity location, String area, String hostUserId, String hostName, String? hostAvatarUrl,@TimestampConverter() DateTime createdAt, String? imageUrl, List<String> tags, List<String> memberUserIds, int memberCount, double rating, int reviewCount,@TimestampConverter() DateTime? nextRunAt, String? nextRunLabel, String? instagramHandle, String? phoneNumber, String? email
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? location = null,Object? area = null,Object? hostUserId = null,Object? hostName = null,Object? hostAvatarUrl = freezed,Object? createdAt = null,Object? imageUrl = freezed,Object? tags = null,Object? memberUserIds = null,Object? memberCount = null,Object? rating = null,Object? reviewCount = null,Object? nextRunAt = freezed,Object? nextRunLabel = freezed,Object? instagramHandle = freezed,Object? phoneNumber = freezed,Object? email = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as IndianCity,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,hostUserId: null == hostUserId ? _self.hostUserId : hostUserId // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,hostAvatarUrl: freezed == hostAvatarUrl ? _self.hostAvatarUrl : hostAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,memberUserIds: null == memberUserIds ? _self.memberUserIds : memberUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,nextRunAt: freezed == nextRunAt ? _self.nextRunAt : nextRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextRunLabel: freezed == nextRunLabel ? _self.nextRunLabel : nextRunLabel // ignore: cast_nullable_to_non_nullable
as String?,instagramHandle: freezed == instagramHandle ? _self.instagramHandle : instagramHandle // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String description,  IndianCity location,  String area,  String hostUserId,  String hostName,  String? hostAvatarUrl, @TimestampConverter()  DateTime createdAt,  String? imageUrl,  List<String> tags,  List<String> memberUserIds,  int memberCount,  double rating,  int reviewCount, @TimestampConverter()  DateTime? nextRunAt,  String? nextRunLabel,  String? instagramHandle,  String? phoneNumber,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunClub() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.location,_that.area,_that.hostUserId,_that.hostName,_that.hostAvatarUrl,_that.createdAt,_that.imageUrl,_that.tags,_that.memberUserIds,_that.memberCount,_that.rating,_that.reviewCount,_that.nextRunAt,_that.nextRunLabel,_that.instagramHandle,_that.phoneNumber,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String description,  IndianCity location,  String area,  String hostUserId,  String hostName,  String? hostAvatarUrl, @TimestampConverter()  DateTime createdAt,  String? imageUrl,  List<String> tags,  List<String> memberUserIds,  int memberCount,  double rating,  int reviewCount, @TimestampConverter()  DateTime? nextRunAt,  String? nextRunLabel,  String? instagramHandle,  String? phoneNumber,  String? email)  $default,) {final _that = this;
switch (_that) {
case _RunClub():
return $default(_that.id,_that.name,_that.description,_that.location,_that.area,_that.hostUserId,_that.hostName,_that.hostAvatarUrl,_that.createdAt,_that.imageUrl,_that.tags,_that.memberUserIds,_that.memberCount,_that.rating,_that.reviewCount,_that.nextRunAt,_that.nextRunLabel,_that.instagramHandle,_that.phoneNumber,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String name,  String description,  IndianCity location,  String area,  String hostUserId,  String hostName,  String? hostAvatarUrl, @TimestampConverter()  DateTime createdAt,  String? imageUrl,  List<String> tags,  List<String> memberUserIds,  int memberCount,  double rating,  int reviewCount, @TimestampConverter()  DateTime? nextRunAt,  String? nextRunLabel,  String? instagramHandle,  String? phoneNumber,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _RunClub() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.location,_that.area,_that.hostUserId,_that.hostName,_that.hostAvatarUrl,_that.createdAt,_that.imageUrl,_that.tags,_that.memberUserIds,_that.memberCount,_that.rating,_that.reviewCount,_that.nextRunAt,_that.nextRunLabel,_that.instagramHandle,_that.phoneNumber,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RunClub implements RunClub {
  const _RunClub({@JsonKey(includeToJson: false) required this.id, required this.name, required this.description, required this.location, required this.area, required this.hostUserId, required this.hostName, this.hostAvatarUrl, @TimestampConverter() required this.createdAt, this.imageUrl, final  List<String> tags = const [], final  List<String> memberUserIds = const [], this.memberCount = 0, this.rating = 0.0, this.reviewCount = 0, @TimestampConverter() this.nextRunAt, this.nextRunLabel, this.instagramHandle, this.phoneNumber, this.email}): _tags = tags,_memberUserIds = memberUserIds;
  factory _RunClub.fromJson(Map<String, dynamic> json) => _$RunClubFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String name;
@override final  String description;
@override final  IndianCity location;
@override final  String area;
@override final  String hostUserId;
@override final  String hostName;
@override final  String? hostAvatarUrl;
@override@TimestampConverter() final  DateTime createdAt;
@override final  String? imageUrl;
 final  List<String> _tags;
@override@JsonKey() List<String> get tags {
  if (_tags is EqualUnmodifiableListView) return _tags;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_tags);
}

 final  List<String> _memberUserIds;
@override@JsonKey() List<String> get memberUserIds {
  if (_memberUserIds is EqualUnmodifiableListView) return _memberUserIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_memberUserIds);
}

@override@JsonKey() final  int memberCount;
@override@JsonKey() final  double rating;
@override@JsonKey() final  int reviewCount;
@override@TimestampConverter() final  DateTime? nextRunAt;
@override final  String? nextRunLabel;
@override final  String? instagramHandle;
@override final  String? phoneNumber;
@override final  String? email;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunClub&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.area, area) || other.area == area)&&(identical(other.hostUserId, hostUserId) || other.hostUserId == hostUserId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.hostAvatarUrl, hostAvatarUrl) || other.hostAvatarUrl == hostAvatarUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._tags, _tags)&&const DeepCollectionEquality().equals(other._memberUserIds, _memberUserIds)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.nextRunAt, nextRunAt) || other.nextRunAt == nextRunAt)&&(identical(other.nextRunLabel, nextRunLabel) || other.nextRunLabel == nextRunLabel)&&(identical(other.instagramHandle, instagramHandle) || other.instagramHandle == instagramHandle)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,location,area,hostUserId,hostName,hostAvatarUrl,createdAt,imageUrl,const DeepCollectionEquality().hash(_tags),const DeepCollectionEquality().hash(_memberUserIds),memberCount,rating,reviewCount,nextRunAt,nextRunLabel,instagramHandle,phoneNumber,email]);

@override
String toString() {
  return 'RunClub(id: $id, name: $name, description: $description, location: $location, area: $area, hostUserId: $hostUserId, hostName: $hostName, hostAvatarUrl: $hostAvatarUrl, createdAt: $createdAt, imageUrl: $imageUrl, tags: $tags, memberUserIds: $memberUserIds, memberCount: $memberCount, rating: $rating, reviewCount: $reviewCount, nextRunAt: $nextRunAt, nextRunLabel: $nextRunLabel, instagramHandle: $instagramHandle, phoneNumber: $phoneNumber, email: $email)';
}


}

/// @nodoc
abstract mixin class _$RunClubCopyWith<$Res> implements $RunClubCopyWith<$Res> {
  factory _$RunClubCopyWith(_RunClub value, $Res Function(_RunClub) _then) = __$RunClubCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String description, IndianCity location, String area, String hostUserId, String hostName, String? hostAvatarUrl,@TimestampConverter() DateTime createdAt, String? imageUrl, List<String> tags, List<String> memberUserIds, int memberCount, double rating, int reviewCount,@TimestampConverter() DateTime? nextRunAt, String? nextRunLabel, String? instagramHandle, String? phoneNumber, String? email
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? location = null,Object? area = null,Object? hostUserId = null,Object? hostName = null,Object? hostAvatarUrl = freezed,Object? createdAt = null,Object? imageUrl = freezed,Object? tags = null,Object? memberUserIds = null,Object? memberCount = null,Object? rating = null,Object? reviewCount = null,Object? nextRunAt = freezed,Object? nextRunLabel = freezed,Object? instagramHandle = freezed,Object? phoneNumber = freezed,Object? email = freezed,}) {
  return _then(_RunClub(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as IndianCity,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,hostUserId: null == hostUserId ? _self.hostUserId : hostUserId // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,hostAvatarUrl: freezed == hostAvatarUrl ? _self.hostAvatarUrl : hostAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,memberUserIds: null == memberUserIds ? _self._memberUserIds : memberUserIds // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,nextRunAt: freezed == nextRunAt ? _self.nextRunAt : nextRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextRunLabel: freezed == nextRunLabel ? _self.nextRunLabel : nextRunLabel // ignore: cast_nullable_to_non_nullable
as String?,instagramHandle: freezed == instagramHandle ? _self.instagramHandle : instagramHandle // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
