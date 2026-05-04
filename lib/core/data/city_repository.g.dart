// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'city_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// List of supported cities, fetched once and cached for the app lifetime.
///
/// Returns the Firestore-backed list or the 9 hardcoded defaults.

@ProviderFor(cityList)
final cityListProvider = CityListProvider._();

/// List of supported cities, fetched once and cached for the app lifetime.
///
/// Returns the Firestore-backed list or the 9 hardcoded defaults.

final class CityListProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CityData>>,
          List<CityData>,
          FutureOr<List<CityData>>
        >
    with $FutureModifier<List<CityData>>, $FutureProvider<List<CityData>> {
  /// List of supported cities, fetched once and cached for the app lifetime.
  ///
  /// Returns the Firestore-backed list or the 9 hardcoded defaults.
  CityListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'cityListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$cityListHash();

  @$internal
  @override
  $FutureProviderElement<List<CityData>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CityData>> create(Ref ref) {
    return cityList(ref);
  }
}

String _$cityListHash() => r'8986843d8ad8feaeffb921b23b82adcb80c80dc3';
