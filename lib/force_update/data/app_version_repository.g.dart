// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_version_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appVersionRepository)
final appVersionRepositoryProvider = AppVersionRepositoryProvider._();

final class AppVersionRepositoryProvider
    extends
        $FunctionalProvider<
          AppVersionRepository,
          AppVersionRepository,
          AppVersionRepository
        >
    with $Provider<AppVersionRepository> {
  AppVersionRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appVersionRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appVersionRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppVersionRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppVersionRepository create(Ref ref) {
    return appVersionRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppVersionRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppVersionRepository>(value),
    );
  }
}

String _$appVersionRepositoryHash() =>
    r'ea17d3a8d30b061d92e5492a5ab36e10b58dac6e';

@ProviderFor(watchAppVersionConfig)
final watchAppVersionConfigProvider = WatchAppVersionConfigProvider._();

final class WatchAppVersionConfigProvider
    extends
        $FunctionalProvider<
          AsyncValue<AppVersionConfig>,
          AppVersionConfig,
          Stream<AppVersionConfig>
        >
    with $FutureModifier<AppVersionConfig>, $StreamProvider<AppVersionConfig> {
  WatchAppVersionConfigProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'watchAppVersionConfigProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$watchAppVersionConfigHash();

  @$internal
  @override
  $StreamProviderElement<AppVersionConfig> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AppVersionConfig> create(Ref ref) {
    return watchAppVersionConfig(ref);
  }
}

String _$watchAppVersionConfigHash() =>
    r'6f15bf2b652b09897b12252768c0430bb322977b';
