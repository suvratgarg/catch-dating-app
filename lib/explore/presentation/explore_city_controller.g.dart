// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_city_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Owns Explore city auto-selection policy.
///
/// Profile city is authoritative. Device location is only a fallback when the
/// profile city is absent or unsupported, and neither path overrides a manual
/// city pick because [SelectedExploreCity.autoSelectCity] preserves that guard.

@ProviderFor(ExploreCityController)
final exploreCityControllerProvider = ExploreCityControllerProvider._();

/// Owns Explore city auto-selection policy.
///
/// Profile city is authoritative. Device location is only a fallback when the
/// profile city is absent or unsupported, and neither path overrides a manual
/// city pick because [SelectedExploreCity.autoSelectCity] preserves that guard.
final class ExploreCityControllerProvider
    extends $NotifierProvider<ExploreCityController, void> {
  /// Owns Explore city auto-selection policy.
  ///
  /// Profile city is authoritative. Device location is only a fallback when the
  /// profile city is absent or unsupported, and neither path overrides a manual
  /// city pick because [SelectedExploreCity.autoSelectCity] preserves that guard.
  ExploreCityControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreCityControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreCityControllerHash();

  @$internal
  @override
  ExploreCityController create() => ExploreCityController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$exploreCityControllerHash() =>
    r'edbdae3a4cb81a4bd603537a87cb9d18b0e4acfb';

/// Owns Explore city auto-selection policy.
///
/// Profile city is authoritative. Device location is only a fallback when the
/// profile city is absent or unsupported, and neither path overrides a manual
/// city pick because [SelectedExploreCity.autoSelectCity] preserves that guard.

abstract class _$ExploreCityController extends $Notifier<void> {
  void build();
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
    return element.handleCreate(ref, build);
  }
}
