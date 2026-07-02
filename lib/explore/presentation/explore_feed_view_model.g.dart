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
    r'9ab4d2ff555c2562d1467383577c589a76dcca72';
