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

/// The current platform build number from pubspec/native metadata.

@ProviderFor(currentAppBuildNumber)
final currentAppBuildNumberProvider = CurrentAppBuildNumberProvider._();

/// The current platform build number from pubspec/native metadata.

final class CurrentAppBuildNumberProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// The current platform build number from pubspec/native metadata.
  CurrentAppBuildNumberProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'currentAppBuildNumberProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$currentAppBuildNumberHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return currentAppBuildNumber(ref);
  }
}

String _$currentAppBuildNumberHash() =>
    r'ca3e12c8273c3278997504fbbc66314a8bd77f4d';

/// True when the running version is below the remote [minVersion].
///
/// Loading and error states are surfaced to the app shell so the app does not
/// silently continue when the compatibility check cannot complete.

@ProviderFor(forceUpdateRequired)
final forceUpdateRequiredProvider = ForceUpdateRequiredProvider._();

/// True when the running version is below the remote [minVersion].
///
/// Loading and error states are surfaced to the app shell so the app does not
/// silently continue when the compatibility check cannot complete.

final class ForceUpdateRequiredProvider
    extends
        $FunctionalProvider<
          AsyncValue<bool>,
          AsyncValue<bool>,
          AsyncValue<bool>
        >
    with $Provider<AsyncValue<bool>> {
  /// True when the running version is below the remote [minVersion].
  ///
  /// Loading and error states are surfaced to the app shell so the app does not
  /// silently continue when the compatibility check cannot complete.
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
  $ProviderElement<AsyncValue<bool>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<bool> create(Ref ref) {
    return forceUpdateRequired(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<bool>>(value),
    );
  }
}

String _$forceUpdateRequiredHash() =>
    r'8a5d798620bf01c2c1b3b54330e1d799254fd6a6';
