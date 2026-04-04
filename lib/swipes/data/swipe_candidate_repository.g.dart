// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'swipe_candidate_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(swipeCandidateRepository)
final swipeCandidateRepositoryProvider = SwipeCandidateRepositoryProvider._();

final class SwipeCandidateRepositoryProvider
    extends
        $FunctionalProvider<
          SwipeCandidateRepository,
          SwipeCandidateRepository,
          SwipeCandidateRepository
        >
    with $Provider<SwipeCandidateRepository> {
  SwipeCandidateRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'swipeCandidateRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$swipeCandidateRepositoryHash();

  @$internal
  @override
  $ProviderElement<SwipeCandidateRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SwipeCandidateRepository create(Ref ref) {
    return swipeCandidateRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SwipeCandidateRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SwipeCandidateRepository>(value),
    );
  }
}

String _$swipeCandidateRepositoryHash() =>
    r'1637bb1ec57325a3036b21b52e50ad3140866c42';
