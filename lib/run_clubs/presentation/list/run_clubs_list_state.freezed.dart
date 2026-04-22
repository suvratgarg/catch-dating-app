// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_clubs_list_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RunClubsListViewModel {

 List<RunClub> get joinedClubs; List<RunClub> get discoverClubs;
/// Create a copy of RunClubsListViewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunClubsListViewModelCopyWith<RunClubsListViewModel> get copyWith => _$RunClubsListViewModelCopyWithImpl<RunClubsListViewModel>(this as RunClubsListViewModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunClubsListViewModel&&const DeepCollectionEquality().equals(other.joinedClubs, joinedClubs)&&const DeepCollectionEquality().equals(other.discoverClubs, discoverClubs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(joinedClubs),const DeepCollectionEquality().hash(discoverClubs));

@override
String toString() {
  return 'RunClubsListViewModel(joinedClubs: $joinedClubs, discoverClubs: $discoverClubs)';
}


}

/// @nodoc
abstract mixin class $RunClubsListViewModelCopyWith<$Res>  {
  factory $RunClubsListViewModelCopyWith(RunClubsListViewModel value, $Res Function(RunClubsListViewModel) _then) = _$RunClubsListViewModelCopyWithImpl;
@useResult
$Res call({
 List<RunClub> joinedClubs, List<RunClub> discoverClubs
});




}
/// @nodoc
class _$RunClubsListViewModelCopyWithImpl<$Res>
    implements $RunClubsListViewModelCopyWith<$Res> {
  _$RunClubsListViewModelCopyWithImpl(this._self, this._then);

  final RunClubsListViewModel _self;
  final $Res Function(RunClubsListViewModel) _then;

/// Create a copy of RunClubsListViewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? joinedClubs = null,Object? discoverClubs = null,}) {
  return _then(_self.copyWith(
joinedClubs: null == joinedClubs ? _self.joinedClubs : joinedClubs // ignore: cast_nullable_to_non_nullable
as List<RunClub>,discoverClubs: null == discoverClubs ? _self.discoverClubs : discoverClubs // ignore: cast_nullable_to_non_nullable
as List<RunClub>,
  ));
}

}


/// Adds pattern-matching-related methods to [RunClubsListViewModel].
extension RunClubsListViewModelPatterns on RunClubsListViewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunClubsListViewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunClubsListViewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunClubsListViewModel value)  $default,){
final _that = this;
switch (_that) {
case _RunClubsListViewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunClubsListViewModel value)?  $default,){
final _that = this;
switch (_that) {
case _RunClubsListViewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RunClub> joinedClubs,  List<RunClub> discoverClubs)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunClubsListViewModel() when $default != null:
return $default(_that.joinedClubs,_that.discoverClubs);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RunClub> joinedClubs,  List<RunClub> discoverClubs)  $default,) {final _that = this;
switch (_that) {
case _RunClubsListViewModel():
return $default(_that.joinedClubs,_that.discoverClubs);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RunClub> joinedClubs,  List<RunClub> discoverClubs)?  $default,) {final _that = this;
switch (_that) {
case _RunClubsListViewModel() when $default != null:
return $default(_that.joinedClubs,_that.discoverClubs);case _:
  return null;

}
}

}

/// @nodoc


class _RunClubsListViewModel extends RunClubsListViewModel {
  const _RunClubsListViewModel({required final  List<RunClub> joinedClubs, required final  List<RunClub> discoverClubs}): _joinedClubs = joinedClubs,_discoverClubs = discoverClubs,super._();
  

 final  List<RunClub> _joinedClubs;
@override List<RunClub> get joinedClubs {
  if (_joinedClubs is EqualUnmodifiableListView) return _joinedClubs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_joinedClubs);
}

 final  List<RunClub> _discoverClubs;
@override List<RunClub> get discoverClubs {
  if (_discoverClubs is EqualUnmodifiableListView) return _discoverClubs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_discoverClubs);
}


/// Create a copy of RunClubsListViewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunClubsListViewModelCopyWith<_RunClubsListViewModel> get copyWith => __$RunClubsListViewModelCopyWithImpl<_RunClubsListViewModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunClubsListViewModel&&const DeepCollectionEquality().equals(other._joinedClubs, _joinedClubs)&&const DeepCollectionEquality().equals(other._discoverClubs, _discoverClubs));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_joinedClubs),const DeepCollectionEquality().hash(_discoverClubs));

@override
String toString() {
  return 'RunClubsListViewModel(joinedClubs: $joinedClubs, discoverClubs: $discoverClubs)';
}


}

/// @nodoc
abstract mixin class _$RunClubsListViewModelCopyWith<$Res> implements $RunClubsListViewModelCopyWith<$Res> {
  factory _$RunClubsListViewModelCopyWith(_RunClubsListViewModel value, $Res Function(_RunClubsListViewModel) _then) = __$RunClubsListViewModelCopyWithImpl;
@override @useResult
$Res call({
 List<RunClub> joinedClubs, List<RunClub> discoverClubs
});




}
/// @nodoc
class __$RunClubsListViewModelCopyWithImpl<$Res>
    implements _$RunClubsListViewModelCopyWith<$Res> {
  __$RunClubsListViewModelCopyWithImpl(this._self, this._then);

  final _RunClubsListViewModel _self;
  final $Res Function(_RunClubsListViewModel) _then;

/// Create a copy of RunClubsListViewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? joinedClubs = null,Object? discoverClubs = null,}) {
  return _then(_RunClubsListViewModel(
joinedClubs: null == joinedClubs ? _self._joinedClubs : joinedClubs // ignore: cast_nullable_to_non_nullable
as List<RunClub>,discoverClubs: null == discoverClubs ? _self._discoverClubs : discoverClubs // ignore: cast_nullable_to_non_nullable
as List<RunClub>,
  ));
}


}

// dart format on
