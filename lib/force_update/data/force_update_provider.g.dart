// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'force_update_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// The current app version and build number from the platform.

@ProviderFor(appPackageInfo)
final appPackageInfoProvider = AppPackageInfoProvider._();

/// The current app version and build number from the platform.

final class AppPackageInfoProvider
    extends
        $FunctionalProvider<
          AsyncValue<({String buildNumber, String version})>,
          ({String buildNumber, String version}),
          FutureOr<({String buildNumber, String version})>
        >
    with
        $FutureModifier<({String buildNumber, String version})>,
        $FutureProvider<({String buildNumber, String version})> {
  /// The current app version and build number from the platform.
  AppPackageInfoProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appPackageInfoProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appPackageInfoHash();

  @$internal
  @override
  $FutureProviderElement<({String buildNumber, String version})> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<({String buildNumber, String version})> create(Ref ref) {
    return appPackageInfo(ref);
  }
}

String _$appPackageInfoHash() => r'5951c12936e1cf5f3d3daf309d4c60d1159c2791';

/// True when the running version is below the remote minimum.
///
/// Loading and error states are surfaced to the app shell so the app does not
/// silently continue when the compatibility check cannot complete.

@ProviderFor(forceUpdateRequired)
final forceUpdateRequiredProvider = ForceUpdateRequiredProvider._();

/// True when the running version is below the remote minimum.
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
  /// True when the running version is below the remote minimum.
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
    r'0c415fd42fccb7463c50ec0072d7c7ecb597481f';
