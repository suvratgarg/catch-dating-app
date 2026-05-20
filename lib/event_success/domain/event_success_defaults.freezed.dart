// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'event_success_defaults.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$EventSuccessDefaults {

 bool get enabled; String get playbookId; List<String> get selectedModuleIds; String get hostGoal; bool get privateCrushEnabled; bool get contextualOpenersEnabled; String? get attendeePrompt;
/// Create a copy of EventSuccessDefaults
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EventSuccessDefaultsCopyWith<EventSuccessDefaults> get copyWith => _$EventSuccessDefaultsCopyWithImpl<EventSuccessDefaults>(this as EventSuccessDefaults, _$identity);

  /// Serializes this EventSuccessDefaults to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EventSuccessDefaults&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.playbookId, playbookId) || other.playbookId == playbookId)&&const DeepCollectionEquality().equals(other.selectedModuleIds, selectedModuleIds)&&(identical(other.hostGoal, hostGoal) || other.hostGoal == hostGoal)&&(identical(other.privateCrushEnabled, privateCrushEnabled) || other.privateCrushEnabled == privateCrushEnabled)&&(identical(other.contextualOpenersEnabled, contextualOpenersEnabled) || other.contextualOpenersEnabled == contextualOpenersEnabled)&&(identical(other.attendeePrompt, attendeePrompt) || other.attendeePrompt == attendeePrompt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,playbookId,const DeepCollectionEquality().hash(selectedModuleIds),hostGoal,privateCrushEnabled,contextualOpenersEnabled,attendeePrompt);

@override
String toString() {
  return 'EventSuccessDefaults(enabled: $enabled, playbookId: $playbookId, selectedModuleIds: $selectedModuleIds, hostGoal: $hostGoal, privateCrushEnabled: $privateCrushEnabled, contextualOpenersEnabled: $contextualOpenersEnabled, attendeePrompt: $attendeePrompt)';
}


}

/// @nodoc
abstract mixin class $EventSuccessDefaultsCopyWith<$Res>  {
  factory $EventSuccessDefaultsCopyWith(EventSuccessDefaults value, $Res Function(EventSuccessDefaults) _then) = _$EventSuccessDefaultsCopyWithImpl;
@useResult
$Res call({
 bool enabled, String playbookId, List<String> selectedModuleIds, String hostGoal, bool privateCrushEnabled, bool contextualOpenersEnabled, String? attendeePrompt
});




}
/// @nodoc
class _$EventSuccessDefaultsCopyWithImpl<$Res>
    implements $EventSuccessDefaultsCopyWith<$Res> {
  _$EventSuccessDefaultsCopyWithImpl(this._self, this._then);

  final EventSuccessDefaults _self;
  final $Res Function(EventSuccessDefaults) _then;

/// Create a copy of EventSuccessDefaults
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? enabled = null,Object? playbookId = null,Object? selectedModuleIds = null,Object? hostGoal = null,Object? privateCrushEnabled = null,Object? contextualOpenersEnabled = null,Object? attendeePrompt = freezed,}) {
  return _then(_self.copyWith(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,playbookId: null == playbookId ? _self.playbookId : playbookId // ignore: cast_nullable_to_non_nullable
as String,selectedModuleIds: null == selectedModuleIds ? _self.selectedModuleIds : selectedModuleIds // ignore: cast_nullable_to_non_nullable
as List<String>,hostGoal: null == hostGoal ? _self.hostGoal : hostGoal // ignore: cast_nullable_to_non_nullable
as String,privateCrushEnabled: null == privateCrushEnabled ? _self.privateCrushEnabled : privateCrushEnabled // ignore: cast_nullable_to_non_nullable
as bool,contextualOpenersEnabled: null == contextualOpenersEnabled ? _self.contextualOpenersEnabled : contextualOpenersEnabled // ignore: cast_nullable_to_non_nullable
as bool,attendeePrompt: freezed == attendeePrompt ? _self.attendeePrompt : attendeePrompt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [EventSuccessDefaults].
extension EventSuccessDefaultsPatterns on EventSuccessDefaults {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EventSuccessDefaults value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EventSuccessDefaults() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EventSuccessDefaults value)  $default,){
final _that = this;
switch (_that) {
case _EventSuccessDefaults():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EventSuccessDefaults value)?  $default,){
final _that = this;
switch (_that) {
case _EventSuccessDefaults() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool enabled,  String playbookId,  List<String> selectedModuleIds,  String hostGoal,  bool privateCrushEnabled,  bool contextualOpenersEnabled,  String? attendeePrompt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EventSuccessDefaults() when $default != null:
return $default(_that.enabled,_that.playbookId,_that.selectedModuleIds,_that.hostGoal,_that.privateCrushEnabled,_that.contextualOpenersEnabled,_that.attendeePrompt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool enabled,  String playbookId,  List<String> selectedModuleIds,  String hostGoal,  bool privateCrushEnabled,  bool contextualOpenersEnabled,  String? attendeePrompt)  $default,) {final _that = this;
switch (_that) {
case _EventSuccessDefaults():
return $default(_that.enabled,_that.playbookId,_that.selectedModuleIds,_that.hostGoal,_that.privateCrushEnabled,_that.contextualOpenersEnabled,_that.attendeePrompt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool enabled,  String playbookId,  List<String> selectedModuleIds,  String hostGoal,  bool privateCrushEnabled,  bool contextualOpenersEnabled,  String? attendeePrompt)?  $default,) {final _that = this;
switch (_that) {
case _EventSuccessDefaults() when $default != null:
return $default(_that.enabled,_that.playbookId,_that.selectedModuleIds,_that.hostGoal,_that.privateCrushEnabled,_that.contextualOpenersEnabled,_that.attendeePrompt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EventSuccessDefaults extends EventSuccessDefaults {
  const _EventSuccessDefaults({this.enabled = false, this.playbookId = 'socialRun', final  List<String> selectedModuleIds = const <String>[], this.hostGoal = 'Help attendees meet at least two new people.', this.privateCrushEnabled = true, this.contextualOpenersEnabled = true, this.attendeePrompt}): _selectedModuleIds = selectedModuleIds,super._();
  factory _EventSuccessDefaults.fromJson(Map<String, dynamic> json) => _$EventSuccessDefaultsFromJson(json);

@override@JsonKey() final  bool enabled;
@override@JsonKey() final  String playbookId;
 final  List<String> _selectedModuleIds;
@override@JsonKey() List<String> get selectedModuleIds {
  if (_selectedModuleIds is EqualUnmodifiableListView) return _selectedModuleIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_selectedModuleIds);
}

@override@JsonKey() final  String hostGoal;
@override@JsonKey() final  bool privateCrushEnabled;
@override@JsonKey() final  bool contextualOpenersEnabled;
@override final  String? attendeePrompt;

/// Create a copy of EventSuccessDefaults
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EventSuccessDefaultsCopyWith<_EventSuccessDefaults> get copyWith => __$EventSuccessDefaultsCopyWithImpl<_EventSuccessDefaults>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EventSuccessDefaultsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EventSuccessDefaults&&(identical(other.enabled, enabled) || other.enabled == enabled)&&(identical(other.playbookId, playbookId) || other.playbookId == playbookId)&&const DeepCollectionEquality().equals(other._selectedModuleIds, _selectedModuleIds)&&(identical(other.hostGoal, hostGoal) || other.hostGoal == hostGoal)&&(identical(other.privateCrushEnabled, privateCrushEnabled) || other.privateCrushEnabled == privateCrushEnabled)&&(identical(other.contextualOpenersEnabled, contextualOpenersEnabled) || other.contextualOpenersEnabled == contextualOpenersEnabled)&&(identical(other.attendeePrompt, attendeePrompt) || other.attendeePrompt == attendeePrompt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,enabled,playbookId,const DeepCollectionEquality().hash(_selectedModuleIds),hostGoal,privateCrushEnabled,contextualOpenersEnabled,attendeePrompt);

@override
String toString() {
  return 'EventSuccessDefaults(enabled: $enabled, playbookId: $playbookId, selectedModuleIds: $selectedModuleIds, hostGoal: $hostGoal, privateCrushEnabled: $privateCrushEnabled, contextualOpenersEnabled: $contextualOpenersEnabled, attendeePrompt: $attendeePrompt)';
}


}

/// @nodoc
abstract mixin class _$EventSuccessDefaultsCopyWith<$Res> implements $EventSuccessDefaultsCopyWith<$Res> {
  factory _$EventSuccessDefaultsCopyWith(_EventSuccessDefaults value, $Res Function(_EventSuccessDefaults) _then) = __$EventSuccessDefaultsCopyWithImpl;
@override @useResult
$Res call({
 bool enabled, String playbookId, List<String> selectedModuleIds, String hostGoal, bool privateCrushEnabled, bool contextualOpenersEnabled, String? attendeePrompt
});




}
/// @nodoc
class __$EventSuccessDefaultsCopyWithImpl<$Res>
    implements _$EventSuccessDefaultsCopyWith<$Res> {
  __$EventSuccessDefaultsCopyWithImpl(this._self, this._then);

  final _EventSuccessDefaults _self;
  final $Res Function(_EventSuccessDefaults) _then;

/// Create a copy of EventSuccessDefaults
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? enabled = null,Object? playbookId = null,Object? selectedModuleIds = null,Object? hostGoal = null,Object? privateCrushEnabled = null,Object? contextualOpenersEnabled = null,Object? attendeePrompt = freezed,}) {
  return _then(_EventSuccessDefaults(
enabled: null == enabled ? _self.enabled : enabled // ignore: cast_nullable_to_non_nullable
as bool,playbookId: null == playbookId ? _self.playbookId : playbookId // ignore: cast_nullable_to_non_nullable
as String,selectedModuleIds: null == selectedModuleIds ? _self._selectedModuleIds : selectedModuleIds // ignore: cast_nullable_to_non_nullable
as List<String>,hostGoal: null == hostGoal ? _self.hostGoal : hostGoal // ignore: cast_nullable_to_non_nullable
as String,privateCrushEnabled: null == privateCrushEnabled ? _self.privateCrushEnabled : privateCrushEnabled // ignore: cast_nullable_to_non_nullable
as bool,contextualOpenersEnabled: null == contextualOpenersEnabled ? _self.contextualOpenersEnabled : contextualOpenersEnabled // ignore: cast_nullable_to_non_nullable
as bool,attendeePrompt: freezed == attendeePrompt ? _self.attendeePrompt : attendeePrompt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
