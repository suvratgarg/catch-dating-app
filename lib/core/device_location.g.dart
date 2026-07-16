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

String _$deviceLocationHash() => r'1b70b4a19f6bd285d44c43af9a1a125e7db6cb01';

abstract class _$DeviceLocation extends $AsyncNotifier<LocationCoordinate?> {
  FutureOr<LocationCoordinate?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
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
    return element.handleCreate(ref, build);
  }
}
