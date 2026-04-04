// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(appUserRepository)
final appUserRepositoryProvider = AppUserRepositoryProvider._();

final class AppUserRepositoryProvider
    extends
        $FunctionalProvider<
          AppUserRepository,
          AppUserRepository,
          AppUserRepository
        >
    with $Provider<AppUserRepository> {
  AppUserRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUserRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUserRepositoryHash();

  @$internal
  @override
  $ProviderElement<AppUserRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AppUserRepository create(Ref ref) {
    return appUserRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppUserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppUserRepository>(value),
    );
  }
}

String _$appUserRepositoryHash() => r'1ca846fe9350a525e5752e1d6c3eb23c2cb1fcc9';

@ProviderFor(appUserStream)
final appUserStreamProvider = AppUserStreamProvider._();

final class AppUserStreamProvider
    extends
        $FunctionalProvider<AsyncValue<AppUser?>, AppUser?, Stream<AppUser?>>
    with $FutureModifier<AppUser?>, $StreamProvider<AppUser?> {
  AppUserStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appUserStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appUserStreamHash();

  @$internal
  @override
  $StreamProviderElement<AppUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AppUser?> create(Ref ref) {
    return appUserStream(ref);
  }
}

String _$appUserStreamHash() => r'41b9edabd3890b23dd129c19b01399205228cd84';
