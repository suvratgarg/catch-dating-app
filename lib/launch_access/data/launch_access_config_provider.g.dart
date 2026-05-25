// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_access_config_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Reads launch-access rollout controls from the already initialized Remote
/// Config singleton.
///
/// This provider is intentionally not wired into routing yet. When the router
/// starts using it, the bundled default keeps the gate off unless Remote Config
/// explicitly enables it.

@ProviderFor(launchAccessConfig)
final launchAccessConfigProvider = LaunchAccessConfigProvider._();

/// Reads launch-access rollout controls from the already initialized Remote
/// Config singleton.
///
/// This provider is intentionally not wired into routing yet. When the router
/// starts using it, the bundled default keeps the gate off unless Remote Config
/// explicitly enables it.

final class LaunchAccessConfigProvider
    extends
        $FunctionalProvider<
          LaunchAccessConfig,
          LaunchAccessConfig,
          LaunchAccessConfig
        >
    with $Provider<LaunchAccessConfig> {
  /// Reads launch-access rollout controls from the already initialized Remote
  /// Config singleton.
  ///
  /// This provider is intentionally not wired into routing yet. When the router
  /// starts using it, the bundled default keeps the gate off unless Remote Config
  /// explicitly enables it.
  LaunchAccessConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'launchAccessConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$launchAccessConfigHash();

  @$internal
  @override
  $ProviderElement<LaunchAccessConfig> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  LaunchAccessConfig create(Ref ref) {
    return launchAccessConfig(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LaunchAccessConfig value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LaunchAccessConfig>(value),
    );
  }
}

String _$launchAccessConfigHash() =>
    r'95afdd610e7ce98880e3155d75395408f159fcd2';
