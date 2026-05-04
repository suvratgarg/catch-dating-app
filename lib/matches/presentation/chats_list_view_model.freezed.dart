// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chats_list_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ChatsListViewModel {

 List<Match> get newMatches; List<Match> get conversations;
/// Create a copy of ChatsListViewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChatsListViewModelCopyWith<ChatsListViewModel> get copyWith => _$ChatsListViewModelCopyWithImpl<ChatsListViewModel>(this as ChatsListViewModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChatsListViewModel&&const DeepCollectionEquality().equals(other.newMatches, newMatches)&&const DeepCollectionEquality().equals(other.conversations, conversations));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(newMatches),const DeepCollectionEquality().hash(conversations));

@override
String toString() {
  return 'ChatsListViewModel(newMatches: $newMatches, conversations: $conversations)';
}


}

/// @nodoc
abstract mixin class $ChatsListViewModelCopyWith<$Res>  {
  factory $ChatsListViewModelCopyWith(ChatsListViewModel value, $Res Function(ChatsListViewModel) _then) = _$ChatsListViewModelCopyWithImpl;
@useResult
$Res call({
 List<Match> newMatches, List<Match> conversations
});




}
/// @nodoc
class _$ChatsListViewModelCopyWithImpl<$Res>
    implements $ChatsListViewModelCopyWith<$Res> {
  _$ChatsListViewModelCopyWithImpl(this._self, this._then);

  final ChatsListViewModel _self;
  final $Res Function(ChatsListViewModel) _then;

/// Create a copy of ChatsListViewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? newMatches = null,Object? conversations = null,}) {
  return _then(_self.copyWith(
newMatches: null == newMatches ? _self.newMatches : newMatches // ignore: cast_nullable_to_non_nullable
as List<Match>,conversations: null == conversations ? _self.conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<Match>,
  ));
}

}


/// Adds pattern-matching-related methods to [ChatsListViewModel].
extension ChatsListViewModelPatterns on ChatsListViewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ChatsListViewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ChatsListViewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ChatsListViewModel value)  $default,){
final _that = this;
switch (_that) {
case _ChatsListViewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ChatsListViewModel value)?  $default,){
final _that = this;
switch (_that) {
case _ChatsListViewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Match> newMatches,  List<Match> conversations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ChatsListViewModel() when $default != null:
return $default(_that.newMatches,_that.conversations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Match> newMatches,  List<Match> conversations)  $default,) {final _that = this;
switch (_that) {
case _ChatsListViewModel():
return $default(_that.newMatches,_that.conversations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Match> newMatches,  List<Match> conversations)?  $default,) {final _that = this;
switch (_that) {
case _ChatsListViewModel() when $default != null:
return $default(_that.newMatches,_that.conversations);case _:
  return null;

}
}

}

/// @nodoc


class _ChatsListViewModel extends ChatsListViewModel {
  const _ChatsListViewModel({required final  List<Match> newMatches, required final  List<Match> conversations}): _newMatches = newMatches,_conversations = conversations,super._();
  

 final  List<Match> _newMatches;
@override List<Match> get newMatches {
  if (_newMatches is EqualUnmodifiableListView) return _newMatches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_newMatches);
}

 final  List<Match> _conversations;
@override List<Match> get conversations {
  if (_conversations is EqualUnmodifiableListView) return _conversations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_conversations);
}


/// Create a copy of ChatsListViewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ChatsListViewModelCopyWith<_ChatsListViewModel> get copyWith => __$ChatsListViewModelCopyWithImpl<_ChatsListViewModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ChatsListViewModel&&const DeepCollectionEquality().equals(other._newMatches, _newMatches)&&const DeepCollectionEquality().equals(other._conversations, _conversations));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_newMatches),const DeepCollectionEquality().hash(_conversations));

@override
String toString() {
  return 'ChatsListViewModel(newMatches: $newMatches, conversations: $conversations)';
}


}

/// @nodoc
abstract mixin class _$ChatsListViewModelCopyWith<$Res> implements $ChatsListViewModelCopyWith<$Res> {
  factory _$ChatsListViewModelCopyWith(_ChatsListViewModel value, $Res Function(_ChatsListViewModel) _then) = __$ChatsListViewModelCopyWithImpl;
@override @useResult
$Res call({
 List<Match> newMatches, List<Match> conversations
});




}
/// @nodoc
class __$ChatsListViewModelCopyWithImpl<$Res>
    implements _$ChatsListViewModelCopyWith<$Res> {
  __$ChatsListViewModelCopyWithImpl(this._self, this._then);

  final _ChatsListViewModel _self;
  final $Res Function(_ChatsListViewModel) _then;

/// Create a copy of ChatsListViewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? newMatches = null,Object? conversations = null,}) {
  return _then(_ChatsListViewModel(
newMatches: null == newMatches ? _self._newMatches : newMatches // ignore: cast_nullable_to_non_nullable
as List<Match>,conversations: null == conversations ? _self._conversations : conversations // ignore: cast_nullable_to_non_nullable
as List<Match>,
  ));
}


}

// dart format on
