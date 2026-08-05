// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cross_paths_feature_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(crossPathsFeatureConfig)
final crossPathsFeatureConfigProvider = CrossPathsFeatureConfigProvider._();

final class CrossPathsFeatureConfigProvider
    extends
        $FunctionalProvider<
          CrossPathsFeatureConfig,
          CrossPathsFeatureConfig,
          CrossPathsFeatureConfig
        >
    with $Provider<CrossPathsFeatureConfig> {
  CrossPathsFeatureConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crossPathsFeatureConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crossPathsFeatureConfigHash();

  @$internal
  @override
  $ProviderElement<CrossPathsFeatureConfig> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CrossPathsFeatureConfig create(Ref ref) {
    return crossPathsFeatureConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrossPathsFeatureConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrossPathsFeatureConfig>(value),
    );
  }
}

String _$crossPathsFeatureConfigHash() =>
    r'e2f93a5f5d91484d1c4a2d4f3f5bd5937eec52bf';
