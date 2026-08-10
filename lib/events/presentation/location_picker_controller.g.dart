// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_picker_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(locationPickerController)
final locationPickerControllerProvider = LocationPickerControllerProvider._();

final class LocationPickerControllerProvider
    extends
        $FunctionalProvider<
          LocationPickerController,
          LocationPickerController,
          LocationPickerController
        >
    with $Provider<LocationPickerController> {
  LocationPickerControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'locationPickerControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$locationPickerControllerHash();

  @$internal
  @override
  $ProviderElement<LocationPickerController> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LocationPickerController create(Ref ref) {
    return locationPickerController(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocationPickerController value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocationPickerController>(value),
    );
  }
}

String _$locationPickerControllerHash() =>
    r'f2064362734c2b6ef2f15c00adc95a59b2cd92bc';
