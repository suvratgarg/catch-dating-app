// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'club_detail_view_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ClubDetailViewModel {

 Club get club; bool get isHost; bool get isMember; List<Event> get upcomingEvents; List<Review> get reviews; UserProfile? get userProfile; String? get uid; bool get isAuthenticated;
/// Create a copy of ClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ClubDetailViewModelCopyWith<ClubDetailViewModel> get copyWith => _$ClubDetailViewModelCopyWithImpl<ClubDetailViewModel>(this as ClubDetailViewModel, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ClubDetailViewModel&&(identical(other.club, club) || other.club == club)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&(identical(other.isMember, isMember) || other.isMember == isMember)&&const DeepCollectionEquality().equals(other.upcomingEvents, upcomingEvents)&&const DeepCollectionEquality().equals(other.reviews, reviews)&&(identical(other.userProfile, userProfile) || other.userProfile == userProfile)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.isAuthenticated, isAuthenticated) || other.isAuthenticated == isAuthenticated));
}


@override
int get hashCode => Object.hash(runtimeType,club,isHost,isMember,const DeepCollectionEquality().hash(upcomingEvents),const DeepCollectionEquality().hash(reviews),userProfile,uid,isAuthenticated);

@override
String toString() {
  return 'ClubDetailViewModel(club: $club, isHost: $isHost, isMember: $isMember, upcomingEvents: $upcomingEvents, reviews: $reviews, userProfile: $userProfile, uid: $uid, isAuthenticated: $isAuthenticated)';
}


}

/// @nodoc
abstract mixin class $ClubDetailViewModelCopyWith<$Res>  {
  factory $ClubDetailViewModelCopyWith(ClubDetailViewModel value, $Res Function(ClubDetailViewModel) _then) = _$ClubDetailViewModelCopyWithImpl;
@useResult
$Res call({
 Club club, bool isHost, bool isMember, List<Event> upcomingEvents, List<Review> reviews, UserProfile? userProfile, String? uid, bool isAuthenticated
});


$ClubCopyWith<$Res> get club;$UserProfileCopyWith<$Res>? get userProfile;

}
/// @nodoc
class _$ClubDetailViewModelCopyWithImpl<$Res>
    implements $ClubDetailViewModelCopyWith<$Res> {
  _$ClubDetailViewModelCopyWithImpl(this._self, this._then);

  final ClubDetailViewModel _self;
  final $Res Function(ClubDetailViewModel) _then;

/// Create a copy of ClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? club = null,Object? isHost = null,Object? isMember = null,Object? upcomingEvents = null,Object? reviews = null,Object? userProfile = freezed,Object? uid = freezed,Object? isAuthenticated = null,}) {
  return _then(_self.copyWith(
club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as Club,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,isMember: null == isMember ? _self.isMember : isMember // ignore: cast_nullable_to_non_nullable
as bool,upcomingEvents: null == upcomingEvents ? _self.upcomingEvents : upcomingEvents // ignore: cast_nullable_to_non_nullable
as List<Event>,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<Review>,userProfile: freezed == userProfile ? _self.userProfile : userProfile // ignore: cast_nullable_to_non_nullable
as UserProfile?,uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String?,isAuthenticated: null == isAuthenticated ? _self.isAuthenticated : isAuthenticated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClubCopyWith<$Res> get club {
  
  return $ClubCopyWith<$Res>(_self.club, (value) {
    return _then(_self.copyWith(club: value));
  });
}/// Create a copy of ClubDetailViewModel
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


/// Adds pattern-matching-related methods to [ClubDetailViewModel].
extension ClubDetailViewModelPatterns on ClubDetailViewModel {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ClubDetailViewModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ClubDetailViewModel() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ClubDetailViewModel value)  $default,){
final _that = this;
switch (_that) {
case _ClubDetailViewModel():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ClubDetailViewModel value)?  $default,){
final _that = this;
switch (_that) {
case _ClubDetailViewModel() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Club club,  bool isHost,  bool isMember,  List<Event> upcomingEvents,  List<Review> reviews,  UserProfile? userProfile,  String? uid,  bool isAuthenticated)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ClubDetailViewModel() when $default != null:
return $default(_that.club,_that.isHost,_that.isMember,_that.upcomingEvents,_that.reviews,_that.userProfile,_that.uid,_that.isAuthenticated);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Club club,  bool isHost,  bool isMember,  List<Event> upcomingEvents,  List<Review> reviews,  UserProfile? userProfile,  String? uid,  bool isAuthenticated)  $default,) {final _that = this;
switch (_that) {
case _ClubDetailViewModel():
return $default(_that.club,_that.isHost,_that.isMember,_that.upcomingEvents,_that.reviews,_that.userProfile,_that.uid,_that.isAuthenticated);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Club club,  bool isHost,  bool isMember,  List<Event> upcomingEvents,  List<Review> reviews,  UserProfile? userProfile,  String? uid,  bool isAuthenticated)?  $default,) {final _that = this;
switch (_that) {
case _ClubDetailViewModel() when $default != null:
return $default(_that.club,_that.isHost,_that.isMember,_that.upcomingEvents,_that.reviews,_that.userProfile,_that.uid,_that.isAuthenticated);case _:
  return null;

}
}

}

/// @nodoc


class _ClubDetailViewModel implements ClubDetailViewModel {
  const _ClubDetailViewModel({required this.club, required this.isHost, required this.isMember, required final  List<Event> upcomingEvents, required final  List<Review> reviews, required this.userProfile, required this.uid, required this.isAuthenticated}): _upcomingEvents = upcomingEvents,_reviews = reviews;
  

@override final  Club club;
@override final  bool isHost;
@override final  bool isMember;
 final  List<Event> _upcomingEvents;
@override List<Event> get upcomingEvents {
  if (_upcomingEvents is EqualUnmodifiableListView) return _upcomingEvents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_upcomingEvents);
}

 final  List<Review> _reviews;
@override List<Review> get reviews {
  if (_reviews is EqualUnmodifiableListView) return _reviews;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviews);
}

@override final  UserProfile? userProfile;
@override final  String? uid;
@override final  bool isAuthenticated;

/// Create a copy of ClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ClubDetailViewModelCopyWith<_ClubDetailViewModel> get copyWith => __$ClubDetailViewModelCopyWithImpl<_ClubDetailViewModel>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ClubDetailViewModel&&(identical(other.club, club) || other.club == club)&&(identical(other.isHost, isHost) || other.isHost == isHost)&&(identical(other.isMember, isMember) || other.isMember == isMember)&&const DeepCollectionEquality().equals(other._upcomingEvents, _upcomingEvents)&&const DeepCollectionEquality().equals(other._reviews, _reviews)&&(identical(other.userProfile, userProfile) || other.userProfile == userProfile)&&(identical(other.uid, uid) || other.uid == uid)&&(identical(other.isAuthenticated, isAuthenticated) || other.isAuthenticated == isAuthenticated));
}


@override
int get hashCode => Object.hash(runtimeType,club,isHost,isMember,const DeepCollectionEquality().hash(_upcomingEvents),const DeepCollectionEquality().hash(_reviews),userProfile,uid,isAuthenticated);

@override
String toString() {
  return 'ClubDetailViewModel(club: $club, isHost: $isHost, isMember: $isMember, upcomingEvents: $upcomingEvents, reviews: $reviews, userProfile: $userProfile, uid: $uid, isAuthenticated: $isAuthenticated)';
}


}

/// @nodoc
abstract mixin class _$ClubDetailViewModelCopyWith<$Res> implements $ClubDetailViewModelCopyWith<$Res> {
  factory _$ClubDetailViewModelCopyWith(_ClubDetailViewModel value, $Res Function(_ClubDetailViewModel) _then) = __$ClubDetailViewModelCopyWithImpl;
@override @useResult
$Res call({
 Club club, bool isHost, bool isMember, List<Event> upcomingEvents, List<Review> reviews, UserProfile? userProfile, String? uid, bool isAuthenticated
});


@override $ClubCopyWith<$Res> get club;@override $UserProfileCopyWith<$Res>? get userProfile;

}
/// @nodoc
class __$ClubDetailViewModelCopyWithImpl<$Res>
    implements _$ClubDetailViewModelCopyWith<$Res> {
  __$ClubDetailViewModelCopyWithImpl(this._self, this._then);

  final _ClubDetailViewModel _self;
  final $Res Function(_ClubDetailViewModel) _then;

/// Create a copy of ClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? club = null,Object? isHost = null,Object? isMember = null,Object? upcomingEvents = null,Object? reviews = null,Object? userProfile = freezed,Object? uid = freezed,Object? isAuthenticated = null,}) {
  return _then(_ClubDetailViewModel(
club: null == club ? _self.club : club // ignore: cast_nullable_to_non_nullable
as Club,isHost: null == isHost ? _self.isHost : isHost // ignore: cast_nullable_to_non_nullable
as bool,isMember: null == isMember ? _self.isMember : isMember // ignore: cast_nullable_to_non_nullable
as bool,upcomingEvents: null == upcomingEvents ? _self._upcomingEvents : upcomingEvents // ignore: cast_nullable_to_non_nullable
as List<Event>,reviews: null == reviews ? _self._reviews : reviews // ignore: cast_nullable_to_non_nullable
as List<Review>,userProfile: freezed == userProfile ? _self.userProfile : userProfile // ignore: cast_nullable_to_non_nullable
as UserProfile?,uid: freezed == uid ? _self.uid : uid // ignore: cast_nullable_to_non_nullable
as String?,isAuthenticated: null == isAuthenticated ? _self.isAuthenticated : isAuthenticated // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ClubDetailViewModel
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ClubCopyWith<$Res> get club {
  
  return $ClubCopyWith<$Res>(_self.club, (value) {
    return _then(_self.copyWith(club: value));
  });
}/// Create a copy of ClubDetailViewModel
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
