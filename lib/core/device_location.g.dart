// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_location.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(DeviceLocation)
final deviceLocationProvider = DeviceLocationProvider._();

final class DeviceLocationProvider
    extends $AsyncNotifierProvider<DeviceLocation, LocationCoordinate?> {
  DeviceLocationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceLocationProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceLocationHash();

  @$internal
  @override
  DeviceLocation create() => DeviceLocation();
}

String _$deviceLocationHash() => r'8f514caa3b43b7c9cc43964e8ad8a6134f61a9bf';

abstract class _$DeviceLocation extends $AsyncNotifier<LocationCoordinate?> {
  FutureOr<LocationCoordinate?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<LocationCoordinate?>, LocationCoordinate?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<LocationCoordinate?>, LocationCoordinate?>,
              AsyncValue<LocationCoordinate?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
