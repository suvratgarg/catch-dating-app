// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_club_draft.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RunClubDraft {

 DateTime get savedAt; String? get name; String? get area; String? get description; IndianCity? get location; String? get instagramHandle; String? get phoneNumber; String? get email;
/// Create a copy of RunClubDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunClubDraftCopyWith<RunClubDraft> get copyWith => _$RunClubDraftCopyWithImpl<RunClubDraft>(this as RunClubDraft, _$identity);

  /// Serializes this RunClubDraft to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunClubDraft&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.name, name) || other.name == name)&&(identical(other.area, area) || other.area == area)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.instagramHandle, instagramHandle) || other.instagramHandle == instagramHandle)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,savedAt,name,area,description,location,instagramHandle,phoneNumber,email);

@override
String toString() {
  return 'RunClubDraft(savedAt: $savedAt, name: $name, area: $area, description: $description, location: $location, instagramHandle: $instagramHandle, phoneNumber: $phoneNumber, email: $email)';
}


}

/// @nodoc
abstract mixin class $RunClubDraftCopyWith<$Res>  {
  factory $RunClubDraftCopyWith(RunClubDraft value, $Res Function(RunClubDraft) _then) = _$RunClubDraftCopyWithImpl;
@useResult
$Res call({
 DateTime savedAt, String? name, String? area, String? description, IndianCity? location, String? instagramHandle, String? phoneNumber, String? email
});




}
/// @nodoc
class _$RunClubDraftCopyWithImpl<$Res>
    implements $RunClubDraftCopyWith<$Res> {
  _$RunClubDraftCopyWithImpl(this._self, this._then);

  final RunClubDraft _self;
  final $Res Function(RunClubDraft) _then;

/// Create a copy of RunClubDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? savedAt = null,Object? name = freezed,Object? area = freezed,Object? description = freezed,Object? location = freezed,Object? instagramHandle = freezed,Object? phoneNumber = freezed,Object? email = freezed,}) {
  return _then(_self.copyWith(
savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as IndianCity?,instagramHandle: freezed == instagramHandle ? _self.instagramHandle : instagramHandle // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RunClubDraft].
extension RunClubDraftPatterns on RunClubDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunClubDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunClubDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunClubDraft value)  $default,){
final _that = this;
switch (_that) {
case _RunClubDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunClubDraft value)?  $default,){
final _that = this;
switch (_that) {
case _RunClubDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( DateTime savedAt,  String? name,  String? area,  String? description,  IndianCity? location,  String? instagramHandle,  String? phoneNumber,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunClubDraft() when $default != null:
return $default(_that.savedAt,_that.name,_that.area,_that.description,_that.location,_that.instagramHandle,_that.phoneNumber,_that.email);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( DateTime savedAt,  String? name,  String? area,  String? description,  IndianCity? location,  String? instagramHandle,  String? phoneNumber,  String? email)  $default,) {final _that = this;
switch (_that) {
case _RunClubDraft():
return $default(_that.savedAt,_that.name,_that.area,_that.description,_that.location,_that.instagramHandle,_that.phoneNumber,_that.email);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( DateTime savedAt,  String? name,  String? area,  String? description,  IndianCity? location,  String? instagramHandle,  String? phoneNumber,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _RunClubDraft() when $default != null:
return $default(_that.savedAt,_that.name,_that.area,_that.description,_that.location,_that.instagramHandle,_that.phoneNumber,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RunClubDraft implements RunClubDraft {
  const _RunClubDraft({required this.savedAt, this.name, this.area, this.description, this.location, this.instagramHandle, this.phoneNumber, this.email});
  factory _RunClubDraft.fromJson(Map<String, dynamic> json) => _$RunClubDraftFromJson(json);

@override final  DateTime savedAt;
@override final  String? name;
@override final  String? area;
@override final  String? description;
@override final  IndianCity? location;
@override final  String? instagramHandle;
@override final  String? phoneNumber;
@override final  String? email;

/// Create a copy of RunClubDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunClubDraftCopyWith<_RunClubDraft> get copyWith => __$RunClubDraftCopyWithImpl<_RunClubDraft>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RunClubDraftToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunClubDraft&&(identical(other.savedAt, savedAt) || other.savedAt == savedAt)&&(identical(other.name, name) || other.name == name)&&(identical(other.area, area) || other.area == area)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.instagramHandle, instagramHandle) || other.instagramHandle == instagramHandle)&&(identical(other.phoneNumber, phoneNumber) || other.phoneNumber == phoneNumber)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,savedAt,name,area,description,location,instagramHandle,phoneNumber,email);

@override
String toString() {
  return 'RunClubDraft(savedAt: $savedAt, name: $name, area: $area, description: $description, location: $location, instagramHandle: $instagramHandle, phoneNumber: $phoneNumber, email: $email)';
}


}

/// @nodoc
abstract mixin class _$RunClubDraftCopyWith<$Res> implements $RunClubDraftCopyWith<$Res> {
  factory _$RunClubDraftCopyWith(_RunClubDraft value, $Res Function(_RunClubDraft) _then) = __$RunClubDraftCopyWithImpl;
@override @useResult
$Res call({
 DateTime savedAt, String? name, String? area, String? description, IndianCity? location, String? instagramHandle, String? phoneNumber, String? email
});




}
/// @nodoc
class __$RunClubDraftCopyWithImpl<$Res>
    implements _$RunClubDraftCopyWith<$Res> {
  __$RunClubDraftCopyWithImpl(this._self, this._then);

  final _RunClubDraft _self;
  final $Res Function(_RunClubDraft) _then;

/// Create a copy of RunClubDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? savedAt = null,Object? name = freezed,Object? area = freezed,Object? description = freezed,Object? location = freezed,Object? instagramHandle = freezed,Object? phoneNumber = freezed,Object? email = freezed,}) {
  return _then(_RunClubDraft(
savedAt: null == savedAt ? _self.savedAt : savedAt // ignore: cast_nullable_to_non_nullable
as DateTime,name: freezed == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String?,area: freezed == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as IndianCity?,instagramHandle: freezed == instagramHandle ? _self.instagramHandle : instagramHandle // ignore: cast_nullable_to_non_nullable
as String?,phoneNumber: freezed == phoneNumber ? _self.phoneNumber : phoneNumber // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
