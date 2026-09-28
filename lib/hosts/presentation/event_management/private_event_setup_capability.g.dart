// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_event_setup_capability.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Read-only release capability seam; overrides belong to local fixtures.
// keepalive: The flag is shared across routes and refreshed on app resume.

@ProviderFor(privateEventSetupCapability)
final privateEventSetupAvailableProvider =
    PrivateEventSetupCapabilityProvider._();

/// Read-only release capability seam; overrides belong to local fixtures.
// keepalive: The flag is shared across routes and refreshed on app resume.

final class PrivateEventSetupCapabilityProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Read-only release capability seam; overrides belong to local fixtures.
  // keepalive: The flag is shared across routes and refreshed on app resume.
  PrivateEventSetupCapabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'privateEventSetupAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$privateEventSetupCapabilityHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return privateEventSetupCapability(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$privateEventSetupCapabilityHash() =>
    r'ec043c2ae294c07083f91a7b934b1fc09bea3041';

@ProviderFor(progressiveEventDefaultsCapability)
final progressiveEventDefaultsAvailableProvider =
    ProgressiveEventDefaultsCapabilityProvider._();

final class ProgressiveEventDefaultsCapabilityProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  ProgressiveEventDefaultsCapabilityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'progressiveEventDefaultsAvailableProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$progressiveEventDefaultsCapabilityHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return progressiveEventDefaultsCapability(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$progressiveEventDefaultsCapabilityHash() =>
    r'318f85254b4f7274c440658e070fb45bf36f7b5c';
