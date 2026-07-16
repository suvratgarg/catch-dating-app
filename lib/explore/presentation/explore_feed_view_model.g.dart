// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_feed_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(exploreViewerCohortId)
final exploreViewerCohortIdProvider = ExploreViewerCohortIdProvider._();

final class ExploreViewerCohortIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<String?>,
          AsyncValue<String?>,
          AsyncValue<String?>
        >
    with $Provider<AsyncValue<String?>> {
  ExploreViewerCohortIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreViewerCohortIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreViewerCohortIdHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<String?>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<String?> create(Ref ref) {
    return exploreViewerCohortId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<String?> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<String?>>(value),
    );
  }
}

String _$exploreViewerCohortIdHash() =>
    r'6836f1992c7ab636cfe78817bc28ffe4b1b45823';

@ProviderFor(exploreFeedViewModel)
final exploreFeedViewModelProvider = ExploreFeedViewModelProvider._();

final class ExploreFeedViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExploreFeedViewModel>,
          AsyncValue<ExploreFeedViewModel>,
          AsyncValue<ExploreFeedViewModel>
        >
    with $Provider<AsyncValue<ExploreFeedViewModel>> {
  ExploreFeedViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreFeedViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreFeedViewModelHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<ExploreFeedViewModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<ExploreFeedViewModel> create(Ref ref) {
    return exploreFeedViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ExploreFeedViewModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ExploreFeedViewModel>>(
        value,
      ),
    );
  }
}

String _$exploreFeedViewModelHash() =>
    r'e26301d010ea90000aa073cd2c83e6f98678a74c';

@ProviderFor(exploreRecommendations)
final exploreRecommendationsProvider = ExploreRecommendationsProvider._();

final class ExploreRecommendationsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ExploreEventRecommendation>>,
          AsyncValue<List<ExploreEventRecommendation>>,
          AsyncValue<List<ExploreEventRecommendation>>
        >
    with $Provider<AsyncValue<List<ExploreEventRecommendation>>> {
  ExploreRecommendationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreRecommendationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreRecommendationsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<ExploreEventRecommendation>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<ExploreEventRecommendation>> create(Ref ref) {
    return exploreRecommendations(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(
    AsyncValue<List<ExploreEventRecommendation>> value,
  ) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<ExploreEventRecommendation>>>(
            value,
          ),
    );
  }
}

String _$exploreRecommendationsHash() =>
    r'a9102dea96e5510ac59d36c6bef388025ed7d57a';
