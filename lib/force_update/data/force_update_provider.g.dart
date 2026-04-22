// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'force_update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current app version string (e.g. "1.2.3") from the platform.

@ProviderFor(currentAppVersion)
final currentAppVersionProvider = CurrentAppVersionProvider._();

/// The current app version string (e.g. "1.2.3") from the platform.

final class CurrentAppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The current app version string (e.g. "1.2.3") from the platform.
  CurrentAppVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAppVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAppVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return currentAppVersion(ref);
  }
}

String _$currentAppVersionHash() => r'828a55b7464459763068499a4896ac2c649f002c';

/// True when the running version is below the remote [minVersion].
///
/// Returns false while either value is loading so the UI is never blocked
/// by a transient loading state.

@ProviderFor(forceUpdateRequired)
final forceUpdateRequiredProvider = ForceUpdateRequiredProvider._();

/// True when the running version is below the remote [minVersion].
///
/// Returns false while either value is loading so the UI is never blocked
/// by a transient loading state.

final class ForceUpdateRequiredProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// True when the running version is below the remote [minVersion].
  ///
  /// Returns false while either value is loading so the UI is never blocked
  /// by a transient loading state.
  ForceUpdateRequiredProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'forceUpdateRequiredProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$forceUpdateRequiredHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return forceUpdateRequired(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$forceUpdateRequiredHash() =>
    r'8cd79ca331422bd969aa358d16e839092a318c48';
