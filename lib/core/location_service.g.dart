// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LocationInitializer)
final locationInitializerProvider = LocationInitializerProvider._();

final class LocationInitializerProvider
    extends $AsyncNotifierProvider<LocationInitializer, void> {
  LocationInitializerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationInitializerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationInitializerHash();

  @$internal
  @override
  LocationInitializer create() => LocationInitializer();
}

String _$locationInitializerHash() =>
    r'aa08fe6ae0b88936be96fa219360264f5acebf36';

abstract class _$LocationInitializer extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
