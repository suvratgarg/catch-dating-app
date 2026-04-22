// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_club_detail_controller.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RunClubDetailViewModel {

 RunClub get runClub; bool get isHost; bool get isMember; List<Run> get upcomingRuns; List<Run> get allRuns; List<Review> get reviews; AppUser? get appUser; String? get uid;
/// Create a copy of RunClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RunClubDetailViewModelCopyWith<RunClubDetailViewModel> get copyWith => _$RunClubDetailViewModelCopyWithImpl<RunClubDetailViewModel>(this as RunClubDetailViewModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunClubDetailViewModel&&(identical(other.runClub, runClub) || other.runClub == runClub)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&(identical(other.isMember, isMember) || other.isMember == isMember)&&const DeepCollectionEquality().equals(other.upcomingRuns, upcomingRuns)&&const DeepCollectionEquality().equals(other.allRuns, allRuns)&&const DeepCollectionEquality().equals(other.reviews, reviews)&&(identical(other.appUser, appUser) || other.appUser == appUser)&&(identical(other.uid, uid) || other.uid == uid));
}


@override
int get hashCode => Object.hash(runtimeType,runClub,isHost,isMember,const DeepCollectionEquality().hash(upcomingRuns),const DeepCollectionEquality().hash(allRuns),const DeepCollectionEquality().hash(reviews),appUser,uid);

@override
String toString() {
  return 'RunClubDetailViewModel(runClub: $runClub, isHost: $isHost, isMember: $isMember, upcomingRuns: $upcomingRuns, allRuns: $allRuns, reviews: $reviews, appUser: $appUser, uid: $uid)';
}


}

/// @nodoc
abstract mixin class $RunClubDetailViewModelCopyWith<$Res>  {
  factory $RunClubDetailViewModelCopyWith(RunClubDetailViewModel value, $Res Function(RunClubDetailViewModel) _then) = _$RunClubDetailViewModelCopyWithImpl;
@useResult
$Res call({
 RunClub runClub, bool isHost, bool isMember, List<Run> upcomingRuns, List<Run> allRuns, List<Review> reviews, AppUser? appUser, String? uid
});


$RunClubCopyWith<$Res> get runClub;$AppUserCopyWith<$Res>? get appUser;

}
/// @nodoc
class _$RunClubDetailViewModelCopyWithImpl<$Res>
    implements $RunClubDetailViewModelCopyWith<$Res> {
  _$RunClubDetailViewModelCopyWithImpl(this._self, this._then);

  final RunClubDetailViewModel _self;
  final $Res Function(RunClubDetailViewModel) _then;

/// Create a copy of RunClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? runClub = null,Object? isHost = null,Object? isMember = null,Object? upcomingRuns = null,Object? allRuns = null,Object? reviews = null,Object? appUser = freezed,Object? uid = freezed,}) {
  return _then(_self.copyWith(
runClub: null == runClub ? _self.runClub : runClub // ignore: cast_nullable_to_non_nullable
as RunClub,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,isMember: null == isMember ? _self.isMember : isMember // ignore: cast_nullable_to_non_nullable
as bool,upcomingRuns: null == upcomingRuns ? _self.upcomingRuns : upcomingRuns // ignore: cast_nullable_to_non_nullable
as List<Run>,allRuns: null == allRuns ? _self.allRuns : allRuns // ignore: cast_nullable_to_non_nullable
as List<Run>,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<Review>,appUser: freezed == appUser ? _self.appUser : appUser // ignore: cast_nullable_to_non_nullable
as AppUser?,uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of RunClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RunClubCopyWith<$Res> get runClub {
  
  return $RunClubCopyWith<$Res>(_self.runClub, (value) {
    return _then(_self.copyWith(runClub: value));
  });
}/// Create a copy of RunClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res>? get appUser {
    if (_self.appUser == null) {
    return null;
  }

  return $AppUserCopyWith<$Res>(_self.appUser!, (value) {
    return _then(_self.copyWith(appUser: value));
  });
}
}


/// Adds pattern-matching-related methods to [RunClubDetailViewModel].
extension RunClubDetailViewModelPatterns on RunClubDetailViewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RunClubDetailViewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RunClubDetailViewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RunClubDetailViewModel value)  $default,){
final _that = this;
switch (_that) {
case _RunClubDetailViewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RunClubDetailViewModel value)?  $default,){
final _that = this;
switch (_that) {
case _RunClubDetailViewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( RunClub runClub,  bool isHost,  bool isMember,  List<Run> upcomingRuns,  List<Run> allRuns,  List<Review> reviews,  AppUser? appUser,  String? uid)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RunClubDetailViewModel() when $default != null:
return $default(_that.runClub,_that.isHost,_that.isMember,_that.upcomingRuns,_that.allRuns,_that.reviews,_that.appUser,_that.uid);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( RunClub runClub,  bool isHost,  bool isMember,  List<Run> upcomingRuns,  List<Run> allRuns,  List<Review> reviews,  AppUser? appUser,  String? uid)  $default,) {final _that = this;
switch (_that) {
case _RunClubDetailViewModel():
return $default(_that.runClub,_that.isHost,_that.isMember,_that.upcomingRuns,_that.allRuns,_that.reviews,_that.appUser,_that.uid);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( RunClub runClub,  bool isHost,  bool isMember,  List<Run> upcomingRuns,  List<Run> allRuns,  List<Review> reviews,  AppUser? appUser,  String? uid)?  $default,) {final _that = this;
switch (_that) {
case _RunClubDetailViewModel() when $default != null:
return $default(_that.runClub,_that.isHost,_that.isMember,_that.upcomingRuns,_that.allRuns,_that.reviews,_that.appUser,_that.uid);case _:
  return null;

}
}

}

/// @nodoc


class _RunClubDetailViewModel implements RunClubDetailViewModel {
  const _RunClubDetailViewModel({required this.runClub, required this.isHost, required this.isMember, required final  List<Run> upcomingRuns, required final  List<Run> allRuns, required final  List<Review> reviews, required this.appUser, required this.uid}): _upcomingRuns = upcomingRuns,_allRuns = allRuns,_reviews = reviews;
  

@override final  RunClub runClub;
@override final  bool isHost;
@override final  bool isMember;
 final  List<Run> _upcomingRuns;
@override List<Run> get upcomingRuns {
  if (_upcomingRuns is EqualUnmodifiableListView) return _upcomingRuns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upcomingRuns);
}

 final  List<Run> _allRuns;
@override List<Run> get allRuns {
  if (_allRuns is EqualUnmodifiableListView) return _allRuns;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allRuns);
}

 final  List<Review> _reviews;
@override List<Review> get reviews {
  if (_reviews is EqualUnmodifiableListView) return _reviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviews);
}

@override final  AppUser? appUser;
@override final  String? uid;

/// Create a copy of RunClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RunClubDetailViewModelCopyWith<_RunClubDetailViewModel> get copyWith => __$RunClubDetailViewModelCopyWithImpl<_RunClubDetailViewModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RunClubDetailViewModel&&(identical(other.runClub, runClub) || other.runClub == runClub)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&(identical(other.isMember, isMember) || other.isMember == isMember)&&const DeepCollectionEquality().equals(other._upcomingRuns, _upcomingRuns)&&const DeepCollectionEquality().equals(other._allRuns, _allRuns)&&const DeepCollectionEquality().equals(other._reviews, _reviews)&&(identical(other.appUser, appUser) || other.appUser == appUser)&&(identical(other.uid, uid) || other.uid == uid));
}


@override
int get hashCode => Object.hash(runtimeType,runClub,isHost,isMember,const DeepCollectionEquality().hash(_upcomingRuns),const DeepCollectionEquality().hash(_allRuns),const DeepCollectionEquality().hash(_reviews),appUser,uid);

@override
String toString() {
  return 'RunClubDetailViewModel(runClub: $runClub, isHost: $isHost, isMember: $isMember, upcomingRuns: $upcomingRuns, allRuns: $allRuns, reviews: $reviews, appUser: $appUser, uid: $uid)';
}


}

/// @nodoc
abstract mixin class _$RunClubDetailViewModelCopyWith<$Res> implements $RunClubDetailViewModelCopyWith<$Res> {
  factory _$RunClubDetailViewModelCopyWith(_RunClubDetailViewModel value, $Res Function(_RunClubDetailViewModel) _then) = __$RunClubDetailViewModelCopyWithImpl;
@override @useResult
$Res call({
 RunClub runClub, bool isHost, bool isMember, List<Run> upcomingRuns, List<Run> allRuns, List<Review> reviews, AppUser? appUser, String? uid
});


@override $RunClubCopyWith<$Res> get runClub;@override $AppUserCopyWith<$Res>? get appUser;

}
/// @nodoc
class __$RunClubDetailViewModelCopyWithImpl<$Res>
    implements _$RunClubDetailViewModelCopyWith<$Res> {
  __$RunClubDetailViewModelCopyWithImpl(this._self, this._then);

  final _RunClubDetailViewModel _self;
  final $Res Function(_RunClubDetailViewModel) _then;

/// Create a copy of RunClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? runClub = null,Object? isHost = null,Object? isMember = null,Object? upcomingRuns = null,Object? allRuns = null,Object? reviews = null,Object? appUser = freezed,Object? uid = freezed,}) {
  return _then(_RunClubDetailViewModel(
runClub: null == runClub ? _self.runClub : runClub // ignore: cast_nullable_to_non_nullable
as RunClub,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,isMember: null == isMember ? _self.isMember : isMember // ignore: cast_nullable_to_non_nullable
as bool,upcomingRuns: null == upcomingRuns ? _self._upcomingRuns : upcomingRuns // ignore: cast_nullable_to_non_nullable
as List<Run>,allRuns: null == allRuns ? _self._allRuns : allRuns // ignore: cast_nullable_to_non_nullable
as List<Run>,reviews: null == reviews ? _self._reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<Review>,appUser: freezed == appUser ? _self.appUser : appUser // ignore: cast_nullable_to_non_nullable
as AppUser?,uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of RunClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$RunClubCopyWith<$Res> get runClub {
  
  return $RunClubCopyWith<$Res>(_self.runClub, (value) {
    return _then(_self.copyWith(runClub: value));
  });
}/// Create a copy of RunClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$AppUserCopyWith<$Res>? get appUser {
    if (_self.appUser == null) {
    return null;
  }

  return $AppUserCopyWith<$Res>(_self.appUser!, (value) {
    return _then(_self.copyWith(appUser: value));
  });
}
}

// dart format on
