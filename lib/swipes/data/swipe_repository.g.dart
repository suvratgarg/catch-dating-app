// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(swipeRepository)
final swipeRepositoryProvider = SwipeRepositoryProvider._();

final class SwipeRepositoryProvider
    extends
        $FunctionalProvider<SwipeRepository, SwipeRepository, SwipeRepository>
    with $Provider<SwipeRepository> {
  SwipeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'swipeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$swipeRepositoryHash();

  @$internal
  @override
  $ProviderElement<SwipeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SwipeRepository create(Ref ref) {
    return swipeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SwipeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SwipeRepository>(value),
    );
  }
}

String _$swipeRepositoryHash() => r'6c880204c19a719bd35307c5a0d31cc532cc321a';
