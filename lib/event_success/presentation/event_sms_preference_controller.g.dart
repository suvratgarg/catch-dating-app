// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_sms_preference_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One participant's explicit SMS choice; reads and retries never enroll them.

@ProviderFor(EventSmsPreferenceController)
final eventSmsPreferenceControllerProvider =
    EventSmsPreferenceControllerFamily._();

/// One participant's explicit SMS choice; reads and retries never enroll them.
final class EventSmsPreferenceControllerProvider
    extends
        $NotifierProvider<
          EventSmsPreferenceController,
          EventSmsPreferenceState
        > {
  /// One participant's explicit SMS choice; reads and retries never enroll them.
  EventSmsPreferenceControllerProvider._({
    required EventSmsPreferenceControllerFamily super.from,
    required EventSmsPreferenceScope super.argument,
  }) : super(
         retry: null,
         name: r'eventSmsPreferenceControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventSmsPreferenceControllerHash();

  @override
  String toString() {
    return r'eventSmsPreferenceControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EventSmsPreferenceController create() => EventSmsPreferenceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventSmsPreferenceState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventSmsPreferenceState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is EventSmsPreferenceControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventSmsPreferenceControllerHash() =>
    r'42868318cf8ddb168d97343d435894db249276e9';

/// One participant's explicit SMS choice; reads and retries never enroll them.

final class EventSmsPreferenceControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          EventSmsPreferenceController,
          EventSmsPreferenceState,
          EventSmsPreferenceState,
          EventSmsPreferenceState,
          EventSmsPreferenceScope
        > {
  EventSmsPreferenceControllerFamily._()
    : super(
        retry: null,
        name: r'eventSmsPreferenceControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// One participant's explicit SMS choice; reads and retries never enroll them.

  EventSmsPreferenceControllerProvider call(EventSmsPreferenceScope scope) =>
      EventSmsPreferenceControllerProvider._(argument: scope, from: this);

  @override
  String toString() => r'eventSmsPreferenceControllerProvider';
}

/// One participant's explicit SMS choice; reads and retries never enroll them.

abstract class _$EventSmsPreferenceController
    extends $Notifier<EventSmsPreferenceState> {
  late final _$args = ref.$arg as EventSmsPreferenceScope;
  EventSmsPreferenceScope get scope => _$args;

  EventSmsPreferenceState build(EventSmsPreferenceScope scope);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<EventSmsPreferenceState, EventSmsPreferenceState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EventSmsPreferenceState, EventSmsPreferenceState>,
              EventSmsPreferenceState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
