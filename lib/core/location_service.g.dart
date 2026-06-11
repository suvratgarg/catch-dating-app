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
    r'6e88ec1d0692d29558f7818538993558889353c4';

abstract class _$LocationInitializer extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
