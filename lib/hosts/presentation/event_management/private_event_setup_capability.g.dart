// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'private_event_setup_capability.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Read-only release capability seam; overrides belong to local fixtures.

@ProviderFor(privateEventSetupCapability)
final privateEventSetupAvailableProvider =
    PrivateEventSetupCapabilityProvider._();

/// Read-only release capability seam; overrides belong to local fixtures.

final class PrivateEventSetupCapabilityProvider
    extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Read-only release capability seam; overrides belong to local fixtures.
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
    r'd911235e9d2d6cb9639e0d730c3e17c645d8d527';
