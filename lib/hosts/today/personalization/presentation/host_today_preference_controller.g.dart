// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'host_today_preference_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(hostTodayPreference)
final hostTodayPreferenceProvider = HostTodayPreferenceFamily._();

final class HostTodayPreferenceProvider
    extends
        $FunctionalProvider<
          AsyncValue<HostTodayPreference>,
          HostTodayPreference,
          FutureOr<HostTodayPreference>
        >
    with
        $FutureModifier<HostTodayPreference>,
        $FutureProvider<HostTodayPreference> {
  HostTodayPreferenceProvider._({
    required HostTodayPreferenceFamily super.from,
    required HostTodayPreferenceScope super.argument,
  }) : super(
         retry: null,
         name: r'hostTodayPreferenceProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostTodayPreferenceHash();

  @override
  String toString() {
    return r'hostTodayPreferenceProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<HostTodayPreference> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HostTodayPreference> create(Ref ref) {
    final argument = this.argument as HostTodayPreferenceScope;
    return hostTodayPreference(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is HostTodayPreferenceProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostTodayPreferenceHash() =>
    r'a7c104e51856fb039eaf2de20eae577b65bb7a5e';

final class HostTodayPreferenceFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<HostTodayPreference>,
          HostTodayPreferenceScope
        > {
  HostTodayPreferenceFamily._()
    : super(
        retry: null,
        name: r'hostTodayPreferenceProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostTodayPreferenceProvider call(HostTodayPreferenceScope scope) =>
      HostTodayPreferenceProvider._(argument: scope, from: this);

  @override
  String toString() => r'hostTodayPreferenceProvider';
}

@ProviderFor(HostTodayPreferenceController)
final hostTodayPreferenceControllerProvider =
    HostTodayPreferenceControllerFamily._();

final class HostTodayPreferenceControllerProvider
    extends $NotifierProvider<HostTodayPreferenceController, void> {
  HostTodayPreferenceControllerProvider._({
    required HostTodayPreferenceControllerFamily super.from,
    required HostTodayPreferenceScope super.argument,
  }) : super(
         retry: null,
         name: r'hostTodayPreferenceControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$hostTodayPreferenceControllerHash();

  @override
  String toString() {
    return r'hostTodayPreferenceControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  HostTodayPreferenceController create() => HostTodayPreferenceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is HostTodayPreferenceControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$hostTodayPreferenceControllerHash() =>
    r'655fbc99e81bceaa6435525bdd0237bd531bc6fa';

final class HostTodayPreferenceControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          HostTodayPreferenceController,
          void,
          void,
          void,
          HostTodayPreferenceScope
        > {
  HostTodayPreferenceControllerFamily._()
    : super(
        retry: null,
        name: r'hostTodayPreferenceControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  HostTodayPreferenceControllerProvider call(HostTodayPreferenceScope scope) =>
      HostTodayPreferenceControllerProvider._(argument: scope, from: this);

  @override
  String toString() => r'hostTodayPreferenceControllerProvider';
}

abstract class _$HostTodayPreferenceController extends $Notifier<void> {
  late final _$args = ref.$arg as HostTodayPreferenceScope;
  HostTodayPreferenceScope get scope => _$args;

  void build(HostTodayPreferenceScope scope);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
