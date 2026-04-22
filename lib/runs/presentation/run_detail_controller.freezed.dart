// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_detail_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RunDetailViewModel {

 Run get run; AppUser get appUser; List<Review> get reviews;
/// Create a copy of RunDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunDetailViewModelCopyWith<RunDetailViewModel> get copyWith => _$RunDetailViewModelCopyWithImpl<RunDetailViewModel>(this as RunDetailViewModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunDetailViewModel&&(identical(other.run, run) || other.run == run)&&(identical(other.appUser, appUser) || other.appUser == appUser)&&const DeepCollectionEquality().equals(other.reviews, reviews));
}


@override
int get hashCode => Object.hash(runtimeType,run,appUser,const DeepCollectionEquality().hash(reviews));

@override
String toString() {
  return 'RunDetailViewModel(run: $run, appUser: $appUser, reviews: $reviews)';
}


}

/// @nodoc
abstract mixin class $RunDetailViewModelCopyWith<$Res>  {
  factory $RunDetailViewModelCopyWith(RunDetailViewModel value, $Res Function(RunDetailViewModel) _then) = _$RunDetailViewModelCopyWithImpl;
@useResult
$Res call({
 Run run, AppUser appUser, List<Review> reviews
});


$RunCopyWith<$Res> get run;$AppUserCopyWith<$Res> get appUser;

}
/// @nodoc
class _$RunDetailViewModelCopyWithImpl<$Res>
    implements $RunDetailViewModelCopyWith<$Res> {
  _$RunDetailViewModelCopyWithImpl(this._self, this._then);

  final RunDetailViewModel _self;
  final $Res Function(RunDetailViewModel) _then;

/// Create a copy of RunDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? run = null,Object? appUser = null,Object? reviews = null,}) {
  return _then(_self.copyWith(
run: null == run ? _self.run : run // ignore: cast_nullable_to_non_nullable
as Run,appUser: null == appUser ? _self.appUser : appUser // ignore: cast_nullable_to_non_nullable
as AppUser,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<Review>,
  ));
}
/// Create a copy of RunDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RunCopyWith<$Res> get run {
  
  return $RunCopyWith<$Res>(_self.run, (value) {
    return _then(_self.copyWith(run: value));
  });
}/// Create a copy of RunDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res> get appUser {
  
  return $AppUserCopyWith<$Res>(_self.appUser, (value) {
    return _then(_self.copyWith(appUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [RunDetailViewModel].
extension RunDetailViewModelPatterns on RunDetailViewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunDetailViewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunDetailViewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunDetailViewModel value)  $default,){
final _that = this;
switch (_that) {
case _RunDetailViewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunDetailViewModel value)?  $default,){
final _that = this;
switch (_that) {
case _RunDetailViewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Run run,  AppUser appUser,  List<Review> reviews)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunDetailViewModel() when $default != null:
return $default(_that.run,_that.appUser,_that.reviews);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Run run,  AppUser appUser,  List<Review> reviews)  $default,) {final _that = this;
switch (_that) {
case _RunDetailViewModel():
return $default(_that.run,_that.appUser,_that.reviews);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Run run,  AppUser appUser,  List<Review> reviews)?  $default,) {final _that = this;
switch (_that) {
case _RunDetailViewModel() when $default != null:
return $default(_that.run,_that.appUser,_that.reviews);case _:
  return null;

}
}

}

/// @nodoc


class _RunDetailViewModel implements RunDetailViewModel {
  const _RunDetailViewModel({required this.run, required this.appUser, required final  List<Review> reviews}): _reviews = reviews;
  

@override final  Run run;
@override final  AppUser appUser;
 final  List<Review> _reviews;
@override List<Review> get reviews {
  if (_reviews is EqualUnmodifiableListView) return _reviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviews);
}


/// Create a copy of RunDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunDetailViewModelCopyWith<_RunDetailViewModel> get copyWith => __$RunDetailViewModelCopyWithImpl<_RunDetailViewModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunDetailViewModel&&(identical(other.run, run) || other.run == run)&&(identical(other.appUser, appUser) || other.appUser == appUser)&&const DeepCollectionEquality().equals(other._reviews, _reviews));
}


@override
int get hashCode => Object.hash(runtimeType,run,appUser,const DeepCollectionEquality().hash(_reviews));

@override
String toString() {
  return 'RunDetailViewModel(run: $run, appUser: $appUser, reviews: $reviews)';
}


}

/// @nodoc
abstract mixin class _$RunDetailViewModelCopyWith<$Res> implements $RunDetailViewModelCopyWith<$Res> {
  factory _$RunDetailViewModelCopyWith(_RunDetailViewModel value, $Res Function(_RunDetailViewModel) _then) = __$RunDetailViewModelCopyWithImpl;
@override @useResult
$Res call({
 Run run, AppUser appUser, List<Review> reviews
});


@override $RunCopyWith<$Res> get run;@override $AppUserCopyWith<$Res> get appUser;

}
/// @nodoc
class __$RunDetailViewModelCopyWithImpl<$Res>
    implements _$RunDetailViewModelCopyWith<$Res> {
  __$RunDetailViewModelCopyWithImpl(this._self, this._then);

  final _RunDetailViewModel _self;
  final $Res Function(_RunDetailViewModel) _then;

/// Create a copy of RunDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? run = null,Object? appUser = null,Object? reviews = null,}) {
  return _then(_RunDetailViewModel(
run: null == run ? _self.run : run // ignore: cast_nullable_to_non_nullable
as Run,appUser: null == appUser ? _self.appUser : appUser // ignore: cast_nullable_to_non_nullable
as AppUser,reviews: null == reviews ? _self._reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<Review>,
  ));
}

/// Create a copy of RunDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RunCopyWith<$Res> get run {
  
  return $RunCopyWith<$Res>(_self.run, (value) {
    return _then(_self.copyWith(run: value));
  });
}/// Create a copy of RunDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res> get appUser {
  
  return $AppUserCopyWith<$Res>(_self.appUser, (value) {
    return _then(_self.copyWith(appUser: value));
  });
}
}

// dart format on
