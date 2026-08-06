// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_cross_paths_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// One opaque identifier for the lifetime of a mounted Explore session.
///
/// It intentionally auto-disposes with the Explore enrichment graph. The
/// server hashes this value before storage and enforces the two-person cap.

@ProviderFor(crossPathsExploreSessionId)
final crossPathsExploreSessionIdProvider =
    CrossPathsExploreSessionIdProvider._();

/// One opaque identifier for the lifetime of a mounted Explore session.
///
/// It intentionally auto-disposes with the Explore enrichment graph. The
/// server hashes this value before storage and enforces the two-person cap.

final class CrossPathsExploreSessionIdProvider
    extends $FunctionalProvider<String, String, String>
    with $Provider<String> {
  /// One opaque identifier for the lifetime of a mounted Explore session.
  ///
  /// It intentionally auto-disposes with the Explore enrichment graph. The
  /// server hashes this value before storage and enforces the two-person cap.
  CrossPathsExploreSessionIdProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crossPathsExploreSessionIdProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crossPathsExploreSessionIdHash();

  @$internal
  @override
  $ProviderElement<String> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  String create(Ref ref) {
    return crossPathsExploreSessionId(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$crossPathsExploreSessionIdHash() =>
    r'528c742aa74883f9c07fb73d16299462edfaf4aa';

/// Optional, failure-isolated enrichment for the default Explore list.
///
/// The primary event feed never waits on this provider. Signed-out viewers,
/// active search, disabled rollout configuration, and an unavailable event
/// set all resolve to an empty list without invoking the callable.

@ProviderFor(exploreCrossPathsSuggestions)
final exploreCrossPathsSuggestionsProvider =
    ExploreCrossPathsSuggestionsProvider._();

/// Optional, failure-isolated enrichment for the default Explore list.
///
/// The primary event feed never waits on this provider. Signed-out viewers,
/// active search, disabled rollout configuration, and an unavailable event
/// set all resolve to an empty list without invoking the callable.

final class ExploreCrossPathsSuggestionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<CrossPathsSuggestion>>,
          List<CrossPathsSuggestion>,
          FutureOr<List<CrossPathsSuggestion>>
        >
    with
        $FutureModifier<List<CrossPathsSuggestion>>,
        $FutureProvider<List<CrossPathsSuggestion>> {
  /// Optional, failure-isolated enrichment for the default Explore list.
  ///
  /// The primary event feed never waits on this provider. Signed-out viewers,
  /// active search, disabled rollout configuration, and an unavailable event
  /// set all resolve to an empty list without invoking the callable.
  ExploreCrossPathsSuggestionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreCrossPathsSuggestionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreCrossPathsSuggestionsHash();

  @$internal
  @override
  $FutureProviderElement<List<CrossPathsSuggestion>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<CrossPathsSuggestion>> create(Ref ref) {
    return exploreCrossPathsSuggestions(ref);
  }
}

String _$exploreCrossPathsSuggestionsHash() =>
    r'065e9b0d3e013414b8a5b114f741f24d1dec74c9';
