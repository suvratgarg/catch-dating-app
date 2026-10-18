// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_event_preferences_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(privateEventPreferencesDependencies)
final privateEventPreferencesDependenciesProvider =
    PrivateEventPreferencesDependenciesProvider._();

final class PrivateEventPreferencesDependenciesProvider
    extends
        $FunctionalProvider<
          PrivateEventPreferencesDependencies,
          PrivateEventPreferencesDependencies,
          PrivateEventPreferencesDependencies
        >
    with $Provider<PrivateEventPreferencesDependencies> {
  PrivateEventPreferencesDependenciesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'privateEventPreferencesDependenciesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$privateEventPreferencesDependenciesHash();

  @$internal
  @override
  $ProviderElement<PrivateEventPreferencesDependencies> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PrivateEventPreferencesDependencies create(Ref ref) {
    return privateEventPreferencesDependencies(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PrivateEventPreferencesDependencies value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PrivateEventPreferencesDependencies>(
        value,
      ),
    );
  }
}

String _$privateEventPreferencesDependenciesHash() =>
    r'acb3a9c23a467cb7188d8f18c356581ee4f51ad9';

@ProviderFor(PrivateEventPreferencesController)
final privateEventPreferencesControllerProvider =
    PrivateEventPreferencesControllerFamily._();

final class PrivateEventPreferencesControllerProvider
    extends
        $NotifierProvider<
          PrivateEventPreferencesController,
          EventPreferencesEditorState
        > {
  PrivateEventPreferencesControllerProvider._({
    required PrivateEventPreferencesControllerFamily super.from,
    required EventEditorScope super.argument,
  }) : super(
         retry: null,
         name: r'privateEventPreferencesControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$privateEventPreferencesControllerHash();

  @override
  String toString() {
    return r'privateEventPreferencesControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  PrivateEventPreferencesController create() =>
      PrivateEventPreferencesController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventPreferencesEditorState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventPreferencesEditorState>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is PrivateEventPreferencesControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$privateEventPreferencesControllerHash() =>
    r'84f4f1d1d2e474b48c0ce51c5757303fd2658dd5';

final class PrivateEventPreferencesControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          PrivateEventPreferencesController,
          EventPreferencesEditorState,
          EventPreferencesEditorState,
          EventPreferencesEditorState,
          EventEditorScope
        > {
  PrivateEventPreferencesControllerFamily._()
    : super(
        retry: null,
        name: r'privateEventPreferencesControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PrivateEventPreferencesControllerProvider call(EventEditorScope scope) =>
      PrivateEventPreferencesControllerProvider._(argument: scope, from: this);

  @override
  String toString() => r'privateEventPreferencesControllerProvider';
}

abstract class _$PrivateEventPreferencesController
    extends $Notifier<EventPreferencesEditorState> {
  late final _$args = ref.$arg as EventEditorScope;
  EventEditorScope get scope => _$args;

  EventPreferencesEditorState build(EventEditorScope scope);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<EventPreferencesEditorState, EventPreferencesEditorState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                EventPreferencesEditorState,
                EventPreferencesEditorState
              >,
              EventPreferencesEditorState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
