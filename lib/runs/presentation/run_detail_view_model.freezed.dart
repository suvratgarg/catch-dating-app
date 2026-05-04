// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_detail_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RunDetailViewModel {

 Run get run; UserProfile? get userProfile; List<Review> get reviews; bool get isAuthenticated;
/// Create a copy of RunDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunDetailViewModelCopyWith<RunDetailViewModel> get copyWith => _$RunDetailViewModelCopyWithImpl<RunDetailViewModel>(this as RunDetailViewModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunDetailViewModel&&(identical(other.run, run) || other.run == run)&&(identical(other.userProfile, userProfile) || other.userProfile == userProfile)&&const DeepCollectionEquality().equals(other.reviews, reviews)&&(identical(other.isAuthenticated, isAuthenticated) || other.isAuthenticated == isAuthenticated));
}


@override
int get hashCode => Object.hash(runtimeType,run,userProfile,const DeepCollectionEquality().hash(reviews),isAuthenticated);

@override
String toString() {
  return 'RunDetailViewModel(run: $run, userProfile: $userProfile, reviews: $reviews, isAuthenticated: $isAuthenticated)';
}


}

/// @nodoc
abstract mixin class $RunDetailViewModelCopyWith<$Res>  {
  factory $RunDetailViewModelCopyWith(RunDetailViewModel value, $Res Function(RunDetailViewModel) _then) = _$RunDetailViewModelCopyWithImpl;
@useResult
$Res call({
 Run run, UserProfile? userProfile, List<Review> reviews, bool isAuthenticated
});


$RunCopyWith<$Res> get run;$UserProfileCopyWith<$Res>? get userProfile;

}
/// @nodoc
class _$RunDetailViewModelCopyWithImpl<$Res>
    implements $RunDetailViewModelCopyWith<$Res> {
  _$RunDetailViewModelCopyWithImpl(this._self, this._then);

  final RunDetailViewModel _self;
  final $Res Function(RunDetailViewModel) _then;

/// Create a copy of RunDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? run = null,Object? userProfile = freezed,Object? reviews = null,Object? isAuthenticated = null,}) {
  return _then(_self.copyWith(
run: null == run ? _self.run : run // ignore: cast_nullable_to_non_nullable
as Run,userProfile: freezed == userProfile ? _self.userProfile : userProfile // ignore: cast_nullable_to_non_nullable
as UserProfile?,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<Review>,isAuthenticated: null == isAuthenticated ? _self.isAuthenticated : isAuthenticated // ignore: cast_nullable_to_non_nullable
as bool,
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
$UserProfileCopyWith<$Res>? get userProfile {
    if (_self.userProfile == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.userProfile!, (value) {
    return _then(_self.copyWith(userProfile: value));
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Run run,  UserProfile? userProfile,  List<Review> reviews,  bool isAuthenticated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunDetailViewModel() when $default != null:
return $default(_that.run,_that.userProfile,_that.reviews,_that.isAuthenticated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Run run,  UserProfile? userProfile,  List<Review> reviews,  bool isAuthenticated)  $default,) {final _that = this;
switch (_that) {
case _RunDetailViewModel():
return $default(_that.run,_that.userProfile,_that.reviews,_that.isAuthenticated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Run run,  UserProfile? userProfile,  List<Review> reviews,  bool isAuthenticated)?  $default,) {final _that = this;
switch (_that) {
case _RunDetailViewModel() when $default != null:
return $default(_that.run,_that.userProfile,_that.reviews,_that.isAuthenticated);case _:
  return null;

}
}

}

/// @nodoc


class _RunDetailViewModel implements RunDetailViewModel {
  const _RunDetailViewModel({required this.run, required this.userProfile, required final  List<Review> reviews, required this.isAuthenticated}): _reviews = reviews;
  

@override final  Run run;
@override final  UserProfile? userProfile;
 final  List<Review> _reviews;
@override List<Review> get reviews {
  if (_reviews is EqualUnmodifiableListView) return _reviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviews);
}

@override final  bool isAuthenticated;

/// Create a copy of RunDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunDetailViewModelCopyWith<_RunDetailViewModel> get copyWith => __$RunDetailViewModelCopyWithImpl<_RunDetailViewModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunDetailViewModel&&(identical(other.run, run) || other.run == run)&&(identical(other.userProfile, userProfile) || other.userProfile == userProfile)&&const DeepCollectionEquality().equals(other._reviews, _reviews)&&(identical(other.isAuthenticated, isAuthenticated) || other.isAuthenticated == isAuthenticated));
}


@override
int get hashCode => Object.hash(runtimeType,run,userProfile,const DeepCollectionEquality().hash(_reviews),isAuthenticated);

@override
String toString() {
  return 'RunDetailViewModel(run: $run, userProfile: $userProfile, reviews: $reviews, isAuthenticated: $isAuthenticated)';
}


}

/// @nodoc
abstract mixin class _$RunDetailViewModelCopyWith<$Res> implements $RunDetailViewModelCopyWith<$Res> {
  factory _$RunDetailViewModelCopyWith(_RunDetailViewModel value, $Res Function(_RunDetailViewModel) _then) = __$RunDetailViewModelCopyWithImpl;
@override @useResult
$Res call({
 Run run, UserProfile? userProfile, List<Review> reviews, bool isAuthenticated
});


@override $RunCopyWith<$Res> get run;@override $UserProfileCopyWith<$Res>? get userProfile;

}
/// @nodoc
class __$RunDetailViewModelCopyWithImpl<$Res>
    implements _$RunDetailViewModelCopyWith<$Res> {
  __$RunDetailViewModelCopyWithImpl(this._self, this._then);

  final _RunDetailViewModel _self;
  final $Res Function(_RunDetailViewModel) _then;

/// Create a copy of RunDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? run = null,Object? userProfile = freezed,Object? reviews = null,Object? isAuthenticated = null,}) {
  return _then(_RunDetailViewModel(
run: null == run ? _self.run : run // ignore: cast_nullable_to_non_nullable
as Run,userProfile: freezed == userProfile ? _self.userProfile : userProfile // ignore: cast_nullable_to_non_nullable
as UserProfile?,reviews: null == reviews ? _self._reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<Review>,isAuthenticated: null == isAuthenticated ? _self.isAuthenticated : isAuthenticated // ignore: cast_nullable_to_non_nullable
as bool,
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
$UserProfileCopyWith<$Res>? get userProfile {
    if (_self.userProfile == null) {
    return null;
  }

  return $UserProfileCopyWith<$Res>(_self.userProfile!, (value) {
    return _then(_self.copyWith(userProfile: value));
  });
}
}

// dart format on
