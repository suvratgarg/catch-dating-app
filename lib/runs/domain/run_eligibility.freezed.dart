// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'run_eligibility.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$RunEligibility {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunEligibility);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RunEligibility()';
}


}

/// @nodoc
class $RunEligibilityCopyWith<$Res>  {
$RunEligibilityCopyWith(RunEligibility _, $Res Function(RunEligibility) __);
}


/// Adds pattern-matching-related methods to [RunEligibility].
extension RunEligibilityPatterns on RunEligibility {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Eligible value)?  eligible,TResult Function( AlreadySignedUp value)?  alreadySignedUp,TResult Function( OnWaitlist value)?  onWaitlist,TResult Function( Attended value)?  attended,TResult Function( RunPast value)?  runPast,TResult Function( RunFull value)?  runFull,TResult Function( GenderCapacityReached value)?  genderCapacityReached,TResult Function( AgeTooYoung value)?  ageTooYoung,TResult Function( AgeTooOld value)?  ageTooOld,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Eligible() when eligible != null:
return eligible(_that);case AlreadySignedUp() when alreadySignedUp != null:
return alreadySignedUp(_that);case OnWaitlist() when onWaitlist != null:
return onWaitlist(_that);case Attended() when attended != null:
return attended(_that);case RunPast() when runPast != null:
return runPast(_that);case RunFull() when runFull != null:
return runFull(_that);case GenderCapacityReached() when genderCapacityReached != null:
return genderCapacityReached(_that);case AgeTooYoung() when ageTooYoung != null:
return ageTooYoung(_that);case AgeTooOld() when ageTooOld != null:
return ageTooOld(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Eligible value)  eligible,required TResult Function( AlreadySignedUp value)  alreadySignedUp,required TResult Function( OnWaitlist value)  onWaitlist,required TResult Function( Attended value)  attended,required TResult Function( RunPast value)  runPast,required TResult Function( RunFull value)  runFull,required TResult Function( GenderCapacityReached value)  genderCapacityReached,required TResult Function( AgeTooYoung value)  ageTooYoung,required TResult Function( AgeTooOld value)  ageTooOld,}){
final _that = this;
switch (_that) {
case Eligible():
return eligible(_that);case AlreadySignedUp():
return alreadySignedUp(_that);case OnWaitlist():
return onWaitlist(_that);case Attended():
return attended(_that);case RunPast():
return runPast(_that);case RunFull():
return runFull(_that);case GenderCapacityReached():
return genderCapacityReached(_that);case AgeTooYoung():
return ageTooYoung(_that);case AgeTooOld():
return ageTooOld(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Eligible value)?  eligible,TResult? Function( AlreadySignedUp value)?  alreadySignedUp,TResult? Function( OnWaitlist value)?  onWaitlist,TResult? Function( Attended value)?  attended,TResult? Function( RunPast value)?  runPast,TResult? Function( RunFull value)?  runFull,TResult? Function( GenderCapacityReached value)?  genderCapacityReached,TResult? Function( AgeTooYoung value)?  ageTooYoung,TResult? Function( AgeTooOld value)?  ageTooOld,}){
final _that = this;
switch (_that) {
case Eligible() when eligible != null:
return eligible(_that);case AlreadySignedUp() when alreadySignedUp != null:
return alreadySignedUp(_that);case OnWaitlist() when onWaitlist != null:
return onWaitlist(_that);case Attended() when attended != null:
return attended(_that);case RunPast() when runPast != null:
return runPast(_that);case RunFull() when runFull != null:
return runFull(_that);case GenderCapacityReached() when genderCapacityReached != null:
return genderCapacityReached(_that);case AgeTooYoung() when ageTooYoung != null:
return ageTooYoung(_that);case AgeTooOld() when ageTooOld != null:
return ageTooOld(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  eligible,TResult Function()?  alreadySignedUp,TResult Function()?  onWaitlist,TResult Function()?  attended,TResult Function()?  runPast,TResult Function()?  runFull,TResult Function()?  genderCapacityReached,TResult Function( int minAge)?  ageTooYoung,TResult Function( int maxAge)?  ageTooOld,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Eligible() when eligible != null:
return eligible();case AlreadySignedUp() when alreadySignedUp != null:
return alreadySignedUp();case OnWaitlist() when onWaitlist != null:
return onWaitlist();case Attended() when attended != null:
return attended();case RunPast() when runPast != null:
return runPast();case RunFull() when runFull != null:
return runFull();case GenderCapacityReached() when genderCapacityReached != null:
return genderCapacityReached();case AgeTooYoung() when ageTooYoung != null:
return ageTooYoung(_that.minAge);case AgeTooOld() when ageTooOld != null:
return ageTooOld(_that.maxAge);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  eligible,required TResult Function()  alreadySignedUp,required TResult Function()  onWaitlist,required TResult Function()  attended,required TResult Function()  runPast,required TResult Function()  runFull,required TResult Function()  genderCapacityReached,required TResult Function( int minAge)  ageTooYoung,required TResult Function( int maxAge)  ageTooOld,}) {final _that = this;
switch (_that) {
case Eligible():
return eligible();case AlreadySignedUp():
return alreadySignedUp();case OnWaitlist():
return onWaitlist();case Attended():
return attended();case RunPast():
return runPast();case RunFull():
return runFull();case GenderCapacityReached():
return genderCapacityReached();case AgeTooYoung():
return ageTooYoung(_that.minAge);case AgeTooOld():
return ageTooOld(_that.maxAge);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  eligible,TResult? Function()?  alreadySignedUp,TResult? Function()?  onWaitlist,TResult? Function()?  attended,TResult? Function()?  runPast,TResult? Function()?  runFull,TResult? Function()?  genderCapacityReached,TResult? Function( int minAge)?  ageTooYoung,TResult? Function( int maxAge)?  ageTooOld,}) {final _that = this;
switch (_that) {
case Eligible() when eligible != null:
return eligible();case AlreadySignedUp() when alreadySignedUp != null:
return alreadySignedUp();case OnWaitlist() when onWaitlist != null:
return onWaitlist();case Attended() when attended != null:
return attended();case RunPast() when runPast != null:
return runPast();case RunFull() when runFull != null:
return runFull();case GenderCapacityReached() when genderCapacityReached != null:
return genderCapacityReached();case AgeTooYoung() when ageTooYoung != null:
return ageTooYoung(_that.minAge);case AgeTooOld() when ageTooOld != null:
return ageTooOld(_that.maxAge);case _:
  return null;

}
}

}

/// @nodoc


class Eligible implements RunEligibility {
  const Eligible();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Eligible);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RunEligibility.eligible()';
}


}




/// @nodoc


class AlreadySignedUp implements RunEligibility {
  const AlreadySignedUp();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AlreadySignedUp);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RunEligibility.alreadySignedUp()';
}


}




/// @nodoc


class OnWaitlist implements RunEligibility {
  const OnWaitlist();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OnWaitlist);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RunEligibility.onWaitlist()';
}


}




/// @nodoc


class Attended implements RunEligibility {
  const Attended();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Attended);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RunEligibility.attended()';
}


}




/// @nodoc


class RunPast implements RunEligibility {
  const RunPast();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunPast);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RunEligibility.runPast()';
}


}




/// @nodoc


class RunFull implements RunEligibility {
  const RunFull();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RunFull);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RunEligibility.runFull()';
}


}




/// @nodoc


class GenderCapacityReached implements RunEligibility {
  const GenderCapacityReached();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GenderCapacityReached);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'RunEligibility.genderCapacityReached()';
}


}




/// @nodoc


class AgeTooYoung implements RunEligibility {
  const AgeTooYoung(this.minAge);
  

 final  int minAge;

/// Create a copy of RunEligibility
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgeTooYoungCopyWith<AgeTooYoung> get copyWith => _$AgeTooYoungCopyWithImpl<AgeTooYoung>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgeTooYoung&&(identical(other.minAge, minAge) || other.minAge == minAge));
}


@override
int get hashCode => Object.hash(runtimeType,minAge);

@override
String toString() {
  return 'RunEligibility.ageTooYoung(minAge: $minAge)';
}


}

/// @nodoc
abstract mixin class $AgeTooYoungCopyWith<$Res> implements $RunEligibilityCopyWith<$Res> {
  factory $AgeTooYoungCopyWith(AgeTooYoung value, $Res Function(AgeTooYoung) _then) = _$AgeTooYoungCopyWithImpl;
@useResult
$Res call({
 int minAge
});




}
/// @nodoc
class _$AgeTooYoungCopyWithImpl<$Res>
    implements $AgeTooYoungCopyWith<$Res> {
  _$AgeTooYoungCopyWithImpl(this._self, this._then);

  final AgeTooYoung _self;
  final $Res Function(AgeTooYoung) _then;

/// Create a copy of RunEligibility
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? minAge = null,}) {
  return _then(AgeTooYoung(
null == minAge ? _self.minAge : minAge // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class AgeTooOld implements RunEligibility {
  const AgeTooOld(this.maxAge);
  

 final  int maxAge;

/// Create a copy of RunEligibility
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AgeTooOldCopyWith<AgeTooOld> get copyWith => _$AgeTooOldCopyWithImpl<AgeTooOld>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AgeTooOld&&(identical(other.maxAge, maxAge) || other.maxAge == maxAge));
}


@override
int get hashCode => Object.hash(runtimeType,maxAge);

@override
String toString() {
  return 'RunEligibility.ageTooOld(maxAge: $maxAge)';
}


}

/// @nodoc
abstract mixin class $AgeTooOldCopyWith<$Res> implements $RunEligibilityCopyWith<$Res> {
  factory $AgeTooOldCopyWith(AgeTooOld value, $Res Function(AgeTooOld) _then) = _$AgeTooOldCopyWithImpl;
@useResult
$Res call({
 int maxAge
});




}
/// @nodoc
class _$AgeTooOldCopyWithImpl<$Res>
    implements $AgeTooOldCopyWith<$Res> {
  _$AgeTooOldCopyWithImpl(this._self, this._then);

  final AgeTooOld _self;
  final $Res Function(AgeTooOld) _then;

/// Create a copy of RunEligibility
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? maxAge = null,}) {
  return _then(AgeTooOld(
null == maxAge ? _self.maxAge : maxAge // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
