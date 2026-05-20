// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Club {

@JsonKey(includeToJson: false) String get id; String get name; String get description; String get location; String get area; String get hostUserId; String get hostName; String? get hostAvatarUrl;@TimestampConverter() DateTime get createdAt; String? get imageUrl; List<String> get tags; int get memberCount; double get rating; int get reviewCount;@TimestampConverter() DateTime? get nextEventAt; String? get nextEventLabel; String? get instagramHandle; String? get phoneNumber; String? get email; ClubLifecycleStatus get status; bool get archived;@TimestampConverter() DateTime? get archivedAt; String? get archiveReason; ClubHostDefaults get hostDefaults;
/// Create a copy of Club
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubCopyWith<Club> get copyWith => _$ClubCopyWithImpl<Club>(this as Club, _$identity);

  /// Serializes this Club to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Club&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.area, area) || other.area == area)&&(identical(other.hostUserId, hostUserId) || other.hostUserId == hostUserId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.hostAvatarUrl, hostAvatarUrl) || other.hostAvatarUrl == hostAvatarUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other.tags, tags)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.nextEventAt, nextEventAt) || other.nextEventAt == nextEventAt)&&(identical(other.nextEventLabel, nextEventLabel) || other.nextEventLabel == nextEventLabel)&&(identical(other.instagramHandle, instagramHandle) || other.instagramHandle == instagramHandle)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.status, status) || other.status == status)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archiveReason, archiveReason) || other.archiveReason == archiveReason)&&(identical(other.hostDefaults, hostDefaults) || other.hostDefaults == hostDefaults));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,location,area,hostUserId,hostName,hostAvatarUrl,createdAt,imageUrl,const DeepCollectionEquality().hash(tags),memberCount,rating,reviewCount,nextEventAt,nextEventLabel,instagramHandle,phoneNumber,email,status,archived,archivedAt,archiveReason,hostDefaults]);

@override
String toString() {
  return 'Club(id: $id, name: $name, description: $description, location: $location, area: $area, hostUserId: $hostUserId, hostName: $hostName, hostAvatarUrl: $hostAvatarUrl, createdAt: $createdAt, imageUrl: $imageUrl, tags: $tags, memberCount: $memberCount, rating: $rating, reviewCount: $reviewCount, nextEventAt: $nextEventAt, nextEventLabel: $nextEventLabel, instagramHandle: $instagramHandle, phoneNumber: $phoneNumber, email: $email, status: $status, archived: $archived, archivedAt: $archivedAt, archiveReason: $archiveReason, hostDefaults: $hostDefaults)';
}


}

/// @nodoc
abstract mixin class $ClubCopyWith<$Res>  {
  factory $ClubCopyWith(Club value, $Res Function(Club) _then) = _$ClubCopyWithImpl;
@useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String description, String location, String area, String hostUserId, String hostName, String? hostAvatarUrl,@TimestampConverter() DateTime createdAt, String? imageUrl, List<String> tags, int memberCount, double rating, int reviewCount,@TimestampConverter() DateTime? nextEventAt, String? nextEventLabel, String? instagramHandle, String? phoneNumber, String? email, ClubLifecycleStatus status, bool archived,@TimestampConverter() DateTime? archivedAt, String? archiveReason, ClubHostDefaults hostDefaults
});


$ClubHostDefaultsCopyWith<$Res> get hostDefaults;

}
/// @nodoc
class _$ClubCopyWithImpl<$Res>
    implements $ClubCopyWith<$Res> {
  _$ClubCopyWithImpl(this._self, this._then);

  final Club _self;
  final $Res Function(Club) _then;

/// Create a copy of Club
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = null,Object? location = null,Object? area = null,Object? hostUserId = null,Object? hostName = null,Object? hostAvatarUrl = freezed,Object? createdAt = null,Object? imageUrl = freezed,Object? tags = null,Object? memberCount = null,Object? rating = null,Object? reviewCount = null,Object? nextEventAt = freezed,Object? nextEventLabel = freezed,Object? instagramHandle = freezed,Object? phoneNumber = freezed,Object? email = freezed,Object? status = null,Object? archived = null,Object? archivedAt = freezed,Object? archiveReason = freezed,Object? hostDefaults = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,hostUserId: null == hostUserId ? _self.hostUserId : hostUserId // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,hostAvatarUrl: freezed == hostAvatarUrl ? _self.hostAvatarUrl : hostAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self.tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,nextEventAt: freezed == nextEventAt ? _self.nextEventAt : nextEventAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextEventLabel: freezed == nextEventLabel ? _self.nextEventLabel : nextEventLabel // ignore: cast_nullable_to_non_nullable
as String?,instagramHandle: freezed == instagramHandle ? _self.instagramHandle : instagramHandle // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ClubLifecycleStatus,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archiveReason: freezed == archiveReason ? _self.archiveReason : archiveReason // ignore: cast_nullable_to_non_nullable
as String?,hostDefaults: null == hostDefaults ? _self.hostDefaults : hostDefaults // ignore: cast_nullable_to_non_nullable
as ClubHostDefaults,
  ));
}
/// Create a copy of Club
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClubHostDefaultsCopyWith<$Res> get hostDefaults {

  return $ClubHostDefaultsCopyWith<$Res>(_self.hostDefaults, (value) {
    return _then(_self.copyWith(hostDefaults: value));
  });
}
}


/// Adds pattern-matching-related methods to [Club].
extension ClubPatterns on Club {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Club value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Club() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Club value)  $default,){
final _that = this;
switch (_that) {
case _Club():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Club value)?  $default,){
final _that = this;
switch (_that) {
case _Club() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String description,  String location,  String area,  String hostUserId,  String hostName,  String? hostAvatarUrl, @TimestampConverter()  DateTime createdAt,  String? imageUrl,  List<String> tags,  int memberCount,  double rating,  int reviewCount, @TimestampConverter()  DateTime? nextEventAt,  String? nextEventLabel,  String? instagramHandle,  String? phoneNumber,  String? email,  ClubLifecycleStatus status,  bool archived, @TimestampConverter()  DateTime? archivedAt,  String? archiveReason,  ClubHostDefaults hostDefaults)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Club() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.location,_that.area,_that.hostUserId,_that.hostName,_that.hostAvatarUrl,_that.createdAt,_that.imageUrl,_that.tags,_that.memberCount,_that.rating,_that.reviewCount,_that.nextEventAt,_that.nextEventLabel,_that.instagramHandle,_that.phoneNumber,_that.email,_that.status,_that.archived,_that.archivedAt,_that.archiveReason,_that.hostDefaults);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(includeToJson: false)  String id,  String name,  String description,  String location,  String area,  String hostUserId,  String hostName,  String? hostAvatarUrl, @TimestampConverter()  DateTime createdAt,  String? imageUrl,  List<String> tags,  int memberCount,  double rating,  int reviewCount, @TimestampConverter()  DateTime? nextEventAt,  String? nextEventLabel,  String? instagramHandle,  String? phoneNumber,  String? email,  ClubLifecycleStatus status,  bool archived, @TimestampConverter()  DateTime? archivedAt,  String? archiveReason,  ClubHostDefaults hostDefaults)  $default,) {final _that = this;
switch (_that) {
case _Club():
return $default(_that.id,_that.name,_that.description,_that.location,_that.area,_that.hostUserId,_that.hostName,_that.hostAvatarUrl,_that.createdAt,_that.imageUrl,_that.tags,_that.memberCount,_that.rating,_that.reviewCount,_that.nextEventAt,_that.nextEventLabel,_that.instagramHandle,_that.phoneNumber,_that.email,_that.status,_that.archived,_that.archivedAt,_that.archiveReason,_that.hostDefaults);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(includeToJson: false)  String id,  String name,  String description,  String location,  String area,  String hostUserId,  String hostName,  String? hostAvatarUrl, @TimestampConverter()  DateTime createdAt,  String? imageUrl,  List<String> tags,  int memberCount,  double rating,  int reviewCount, @TimestampConverter()  DateTime? nextEventAt,  String? nextEventLabel,  String? instagramHandle,  String? phoneNumber,  String? email,  ClubLifecycleStatus status,  bool archived, @TimestampConverter()  DateTime? archivedAt,  String? archiveReason,  ClubHostDefaults hostDefaults)?  $default,) {final _that = this;
switch (_that) {
case _Club() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.location,_that.area,_that.hostUserId,_that.hostName,_that.hostAvatarUrl,_that.createdAt,_that.imageUrl,_that.tags,_that.memberCount,_that.rating,_that.reviewCount,_that.nextEventAt,_that.nextEventLabel,_that.instagramHandle,_that.phoneNumber,_that.email,_that.status,_that.archived,_that.archivedAt,_that.archiveReason,_that.hostDefaults);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Club implements Club {
  const _Club({@JsonKey(includeToJson: false) required this.id, required this.name, required this.description, required this.location, required this.area, required this.hostUserId, required this.hostName, this.hostAvatarUrl, @TimestampConverter() required this.createdAt, this.imageUrl, final  List<String> tags = const [], this.memberCount = 0, this.rating = 0.0, this.reviewCount = 0, @TimestampConverter() this.nextEventAt, this.nextEventLabel, this.instagramHandle, this.phoneNumber, this.email, this.status = ClubLifecycleStatus.active, this.archived = false, @TimestampConverter() this.archivedAt, this.archiveReason, this.hostDefaults = const ClubHostDefaults()}): _tags = tags;
  factory _Club.fromJson(Map<String, dynamic> json) => _$ClubFromJson(json);

@override@JsonKey(includeToJson: false) final  String id;
@override final  String name;
@override final  String description;
@override final  String location;
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

@override@JsonKey() final  int memberCount;
@override@JsonKey() final  double rating;
@override@JsonKey() final  int reviewCount;
@override@TimestampConverter() final  DateTime? nextEventAt;
@override final  String? nextEventLabel;
@override final  String? instagramHandle;
@override final  String? phoneNumber;
@override final  String? email;
@override@JsonKey() final  ClubLifecycleStatus status;
@override@JsonKey() final  bool archived;
@override@TimestampConverter() final  DateTime? archivedAt;
@override final  String? archiveReason;
@override@JsonKey() final  ClubHostDefaults hostDefaults;

/// Create a copy of Club
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubCopyWith<_Club> get copyWith => __$ClubCopyWithImpl<_Club>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ClubToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Club&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.area, area) || other.area == area)&&(identical(other.hostUserId, hostUserId) || other.hostUserId == hostUserId)&&(identical(other.hostName, hostName) || other.hostName == hostName)&&(identical(other.hostAvatarUrl, hostAvatarUrl) || other.hostAvatarUrl == hostAvatarUrl)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&const DeepCollectionEquality().equals(other._tags, _tags)&&(identical(other.memberCount, memberCount) || other.memberCount == memberCount)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.reviewCount, reviewCount) || other.reviewCount == reviewCount)&&(identical(other.nextEventAt, nextEventAt) || other.nextEventAt == nextEventAt)&&(identical(other.nextEventLabel, nextEventLabel) || other.nextEventLabel == nextEventLabel)&&(identical(other.instagramHandle, instagramHandle) || other.instagramHandle == instagramHandle)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email)&&(identical(other.status, status) || other.status == status)&&(identical(other.archived, archived) || other.archived == archived)&&(identical(other.archivedAt, archivedAt) || other.archivedAt == archivedAt)&&(identical(other.archiveReason, archiveReason) || other.archiveReason == archiveReason)&&(identical(other.hostDefaults, hostDefaults) || other.hostDefaults == hostDefaults));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,name,description,location,area,hostUserId,hostName,hostAvatarUrl,createdAt,imageUrl,const DeepCollectionEquality().hash(_tags),memberCount,rating,reviewCount,nextEventAt,nextEventLabel,instagramHandle,phoneNumber,email,status,archived,archivedAt,archiveReason,hostDefaults]);

@override
String toString() {
  return 'Club(id: $id, name: $name, description: $description, location: $location, area: $area, hostUserId: $hostUserId, hostName: $hostName, hostAvatarUrl: $hostAvatarUrl, createdAt: $createdAt, imageUrl: $imageUrl, tags: $tags, memberCount: $memberCount, rating: $rating, reviewCount: $reviewCount, nextEventAt: $nextEventAt, nextEventLabel: $nextEventLabel, instagramHandle: $instagramHandle, phoneNumber: $phoneNumber, email: $email, status: $status, archived: $archived, archivedAt: $archivedAt, archiveReason: $archiveReason, hostDefaults: $hostDefaults)';
}


}

/// @nodoc
abstract mixin class _$ClubCopyWith<$Res> implements $ClubCopyWith<$Res> {
  factory _$ClubCopyWith(_Club value, $Res Function(_Club) _then) = __$ClubCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(includeToJson: false) String id, String name, String description, String location, String area, String hostUserId, String hostName, String? hostAvatarUrl,@TimestampConverter() DateTime createdAt, String? imageUrl, List<String> tags, int memberCount, double rating, int reviewCount,@TimestampConverter() DateTime? nextEventAt, String? nextEventLabel, String? instagramHandle, String? phoneNumber, String? email, ClubLifecycleStatus status, bool archived,@TimestampConverter() DateTime? archivedAt, String? archiveReason, ClubHostDefaults hostDefaults
});


@override $ClubHostDefaultsCopyWith<$Res> get hostDefaults;

}
/// @nodoc
class __$ClubCopyWithImpl<$Res>
    implements _$ClubCopyWith<$Res> {
  __$ClubCopyWithImpl(this._self, this._then);

  final _Club _self;
  final $Res Function(_Club) _then;

/// Create a copy of Club
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = null,Object? location = null,Object? area = null,Object? hostUserId = null,Object? hostName = null,Object? hostAvatarUrl = freezed,Object? createdAt = null,Object? imageUrl = freezed,Object? tags = null,Object? memberCount = null,Object? rating = null,Object? reviewCount = null,Object? nextEventAt = freezed,Object? nextEventLabel = freezed,Object? instagramHandle = freezed,Object? phoneNumber = freezed,Object? email = freezed,Object? status = null,Object? archived = null,Object? archivedAt = freezed,Object? archiveReason = freezed,Object? hostDefaults = null,}) {
  return _then(_Club(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String,hostUserId: null == hostUserId ? _self.hostUserId : hostUserId // ignore: cast_nullable_to_non_nullable
as String,hostName: null == hostName ? _self.hostName : hostName // ignore: cast_nullable_to_non_nullable
as String,hostAvatarUrl: freezed == hostAvatarUrl ? _self.hostAvatarUrl : hostAvatarUrl // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,imageUrl: freezed == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String?,tags: null == tags ? _self._tags : tags // ignore: cast_nullable_to_non_nullable
as List<String>,memberCount: null == memberCount ? _self.memberCount : memberCount // ignore: cast_nullable_to_non_nullable
as int,rating: null == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double,reviewCount: null == reviewCount ? _self.reviewCount : reviewCount // ignore: cast_nullable_to_non_nullable
as int,nextEventAt: freezed == nextEventAt ? _self.nextEventAt : nextEventAt // ignore: cast_nullable_to_non_nullable
as DateTime?,nextEventLabel: freezed == nextEventLabel ? _self.nextEventLabel : nextEventLabel // ignore: cast_nullable_to_non_nullable
as String?,instagramHandle: freezed == instagramHandle ? _self.instagramHandle : instagramHandle // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ClubLifecycleStatus,archived: null == archived ? _self.archived : archived // ignore: cast_nullable_to_non_nullable
as bool,archivedAt: freezed == archivedAt ? _self.archivedAt : archivedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,archiveReason: freezed == archiveReason ? _self.archiveReason : archiveReason // ignore: cast_nullable_to_non_nullable
as String?,hostDefaults: null == hostDefaults ? _self.hostDefaults : hostDefaults // ignore: cast_nullable_to_non_nullable
as ClubHostDefaults,
  ));
}

/// Create a copy of Club
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClubHostDefaultsCopyWith<$Res> get hostDefaults {

  return $ClubHostDefaultsCopyWith<$Res>(_self.hostDefaults, (value) {
    return _then(_self.copyWith(hostDefaults: value));
  });
}
}

// dart format on
