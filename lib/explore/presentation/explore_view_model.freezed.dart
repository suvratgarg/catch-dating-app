// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'explore_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExploreViewModel {

 List<Club> get joinedClubs; List<Club> get allClubs; Set<String> get joinedClubIds;
/// Create a copy of ExploreViewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExploreViewModelCopyWith<ExploreViewModel> get copyWith => _$ExploreViewModelCopyWithImpl<ExploreViewModel>(this as ExploreViewModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExploreViewModel&&const DeepCollectionEquality().equals(other.joinedClubs, joinedClubs)&&const DeepCollectionEquality().equals(other.allClubs, allClubs)&&const DeepCollectionEquality().equals(other.joinedClubIds, joinedClubIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(joinedClubs),const DeepCollectionEquality().hash(allClubs),const DeepCollectionEquality().hash(joinedClubIds));

@override
String toString() {
  return 'ExploreViewModel(joinedClubs: $joinedClubs, allClubs: $allClubs, joinedClubIds: $joinedClubIds)';
}


}

/// @nodoc
abstract mixin class $ExploreViewModelCopyWith<$Res>  {
  factory $ExploreViewModelCopyWith(ExploreViewModel value, $Res Function(ExploreViewModel) _then) = _$ExploreViewModelCopyWithImpl;
@useResult
$Res call({
 List<Club> joinedClubs, List<Club> allClubs, Set<String> joinedClubIds
});




}
/// @nodoc
class _$ExploreViewModelCopyWithImpl<$Res>
    implements $ExploreViewModelCopyWith<$Res> {
  _$ExploreViewModelCopyWithImpl(this._self, this._then);

  final ExploreViewModel _self;
  final $Res Function(ExploreViewModel) _then;

/// Create a copy of ExploreViewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? joinedClubs = null,Object? allClubs = null,Object? joinedClubIds = null,}) {
  return _then(_self.copyWith(
joinedClubs: null == joinedClubs ? _self.joinedClubs : joinedClubs // ignore: cast_nullable_to_non_nullable
as List<Club>,allClubs: null == allClubs ? _self.allClubs : allClubs // ignore: cast_nullable_to_non_nullable
as List<Club>,joinedClubIds: null == joinedClubIds ? _self.joinedClubIds : joinedClubIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [ExploreViewModel].
extension ExploreViewModelPatterns on ExploreViewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExploreViewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExploreViewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExploreViewModel value)  $default,){
final _that = this;
switch (_that) {
case _ExploreViewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExploreViewModel value)?  $default,){
final _that = this;
switch (_that) {
case _ExploreViewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Club> joinedClubs,  List<Club> allClubs,  Set<String> joinedClubIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExploreViewModel() when $default != null:
return $default(_that.joinedClubs,_that.allClubs,_that.joinedClubIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Club> joinedClubs,  List<Club> allClubs,  Set<String> joinedClubIds)  $default,) {final _that = this;
switch (_that) {
case _ExploreViewModel():
return $default(_that.joinedClubs,_that.allClubs,_that.joinedClubIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Club> joinedClubs,  List<Club> allClubs,  Set<String> joinedClubIds)?  $default,) {final _that = this;
switch (_that) {
case _ExploreViewModel() when $default != null:
return $default(_that.joinedClubs,_that.allClubs,_that.joinedClubIds);case _:
  return null;

}
}

}

/// @nodoc


class _ExploreViewModel extends ExploreViewModel {
  const _ExploreViewModel({required final  List<Club> joinedClubs, required final  List<Club> allClubs, final  Set<String> joinedClubIds = const {}}): _joinedClubs = joinedClubs,_allClubs = allClubs,_joinedClubIds = joinedClubIds,super._();
  

 final  List<Club> _joinedClubs;
@override List<Club> get joinedClubs {
  if (_joinedClubs is EqualUnmodifiableListView) return _joinedClubs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_joinedClubs);
}

 final  List<Club> _allClubs;
@override List<Club> get allClubs {
  if (_allClubs is EqualUnmodifiableListView) return _allClubs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allClubs);
}

 final  Set<String> _joinedClubIds;
@override@JsonKey() Set<String> get joinedClubIds {
  if (_joinedClubIds is EqualUnmodifiableSetView) return _joinedClubIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_joinedClubIds);
}


/// Create a copy of ExploreViewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExploreViewModelCopyWith<_ExploreViewModel> get copyWith => __$ExploreViewModelCopyWithImpl<_ExploreViewModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExploreViewModel&&const DeepCollectionEquality().equals(other._joinedClubs, _joinedClubs)&&const DeepCollectionEquality().equals(other._allClubs, _allClubs)&&const DeepCollectionEquality().equals(other._joinedClubIds, _joinedClubIds));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_joinedClubs),const DeepCollectionEquality().hash(_allClubs),const DeepCollectionEquality().hash(_joinedClubIds));

@override
String toString() {
  return 'ExploreViewModel(joinedClubs: $joinedClubs, allClubs: $allClubs, joinedClubIds: $joinedClubIds)';
}


}

/// @nodoc
abstract mixin class _$ExploreViewModelCopyWith<$Res> implements $ExploreViewModelCopyWith<$Res> {
  factory _$ExploreViewModelCopyWith(_ExploreViewModel value, $Res Function(_ExploreViewModel) _then) = __$ExploreViewModelCopyWithImpl;
@override @useResult
$Res call({
 List<Club> joinedClubs, List<Club> allClubs, Set<String> joinedClubIds
});




}
/// @nodoc
class __$ExploreViewModelCopyWithImpl<$Res>
    implements _$ExploreViewModelCopyWith<$Res> {
  __$ExploreViewModelCopyWithImpl(this._self, this._then);

  final _ExploreViewModel _self;
  final $Res Function(_ExploreViewModel) _then;

/// Create a copy of ExploreViewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? joinedClubs = null,Object? allClubs = null,Object? joinedClubIds = null,}) {
  return _then(_ExploreViewModel(
joinedClubs: null == joinedClubs ? _self._joinedClubs : joinedClubs // ignore: cast_nullable_to_non_nullable
as List<Club>,allClubs: null == allClubs ? _self._allClubs : allClubs // ignore: cast_nullable_to_non_nullable
as List<Club>,joinedClubIds: null == joinedClubIds ? _self._joinedClubIds : joinedClubIds // ignore: cast_nullable_to_non_nullable
as Set<String>,
  ));
}


}

// dart format on
