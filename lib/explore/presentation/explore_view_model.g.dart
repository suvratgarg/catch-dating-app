// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'explore_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **KeepAlive notifier with internal flag**
///
/// Holds the currently selected city for club browsing. Uses an
/// internal `_userSelected` flag so GPS auto-detection never overrides a
/// manual user pick. [keepAlive] is true so the city survives tab switches.

@ProviderFor(SelectedExploreCity)
final selectedExploreCityProvider = SelectedExploreCityProvider._();

/// **KeepAlive notifier with internal flag**
///
/// Holds the currently selected city for club browsing. Uses an
/// internal `_userSelected` flag so GPS auto-detection never overrides a
/// manual user pick. [keepAlive] is true so the city survives tab switches.
final class SelectedExploreCityProvider
    extends $NotifierProvider<SelectedExploreCity, CityData> {
  /// **KeepAlive notifier with internal flag**
  ///
  /// Holds the currently selected city for club browsing. Uses an
  /// internal `_userSelected` flag so GPS auto-detection never overrides a
  /// manual user pick. [keepAlive] is true so the city survives tab switches.
  SelectedExploreCityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedExploreCityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedExploreCityHash();

  @$internal
  @override
  SelectedExploreCity create() => SelectedExploreCity();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CityData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CityData>(value),
    );
  }
}

String _$selectedExploreCityHash() =>
    r'e9296874c56fdcb595f08354e139a15081e1e4db';

/// **KeepAlive notifier with internal flag**
///
/// Holds the currently selected city for club browsing. Uses an
/// internal `_userSelected` flag so GPS auto-detection never overrides a
/// manual user pick. [keepAlive] is true so the city survives tab switches.

abstract class _$SelectedExploreCity extends $Notifier<CityData> {
  CityData build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CityData, CityData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CityData, CityData>,
              CityData,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(SelectedExploreCityWasUserSelected)
final selectedExploreCityWasUserSelectedProvider =
    SelectedExploreCityWasUserSelectedProvider._();

final class SelectedExploreCityWasUserSelectedProvider
    extends $NotifierProvider<SelectedExploreCityWasUserSelected, bool> {
  SelectedExploreCityWasUserSelectedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedExploreCityWasUserSelectedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$selectedExploreCityWasUserSelectedHash();

  @$internal
  @override
  SelectedExploreCityWasUserSelected create() =>
      SelectedExploreCityWasUserSelected();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$selectedExploreCityWasUserSelectedHash() =>
    r'40ae2f1de86c574c928e12765109bf863a1c83cc';

abstract class _$SelectedExploreCityWasUserSelected extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// **KeepAlive notifier — simple string state**
///
/// Holds the current search query text. [keepAlive] ensures the query
/// survives tab switches so the user's search isn't lost while browsing.

@ProviderFor(ExploreSearchQuery)
final exploreSearchQueryProvider = ExploreSearchQueryProvider._();

/// **KeepAlive notifier — simple string state**
///
/// Holds the current search query text. [keepAlive] ensures the query
/// survives tab switches so the user's search isn't lost while browsing.
final class ExploreSearchQueryProvider
    extends $NotifierProvider<ExploreSearchQuery, String> {
  /// **KeepAlive notifier — simple string state**
  ///
  /// Holds the current search query text. [keepAlive] ensures the query
  /// survives tab switches so the user's search isn't lost while browsing.
  ExploreSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreSearchQueryHash();

  @$internal
  @override
  ExploreSearchQuery create() => ExploreSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$exploreSearchQueryHash() =>
    r'c0e1950d6fde1fcdaccda0e59bb4388fd3563519';

/// **KeepAlive notifier — simple string state**
///
/// Holds the current search query text. [keepAlive] ensures the query
/// survives tab switches so the user's search isn't lost while browsing.

abstract class _$ExploreSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ExploreFilters)
final exploreFiltersProvider = ExploreFiltersProvider._();

final class ExploreFiltersProvider
    extends $NotifierProvider<ExploreFilters, ExploreFilterSelection> {
  ExploreFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreFiltersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreFiltersHash();

  @$internal
  @override
  ExploreFilters create() => ExploreFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ExploreFilterSelection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ExploreFilterSelection>(value),
    );
  }
}

String _$exploreFiltersHash() => r'eecbc04f0291a16be14582f554d3bc3fcef46544';

abstract class _$ExploreFilters extends $Notifier<ExploreFilterSelection> {
  ExploreFilterSelection build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ExploreFilterSelection, ExploreFilterSelection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ExploreFilterSelection, ExploreFilterSelection>,
              ExploreFilterSelection,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Algolia swap point: replace this provider's body to use a remote search
/// index. The VM and screen are not affected.
///
/// **Pattern D variant:** Combines location-filtered clubs with client-side
/// search to produce a filtered list for the UI.

@ProviderFor(exploreSourceClubs)
final exploreSourceClubsProvider = ExploreSourceClubsProvider._();

/// Algolia swap point: replace this provider's body to use a remote search
/// index. The VM and screen are not affected.
///
/// **Pattern D variant:** Combines location-filtered clubs with client-side
/// search to produce a filtered list for the UI.

final class ExploreSourceClubsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Club>>,
          AsyncValue<List<Club>>,
          AsyncValue<List<Club>>
        >
    with $Provider<AsyncValue<List<Club>>> {
  /// Algolia swap point: replace this provider's body to use a remote search
  /// index. The VM and screen are not affected.
  ///
  /// **Pattern D variant:** Combines location-filtered clubs with client-side
  /// search to produce a filtered list for the UI.
  ExploreSourceClubsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreSourceClubsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreSourceClubsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Club>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Club>> create(Ref ref) {
    return exploreSourceClubs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Club>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Club>>>(value),
    );
  }
}

String _$exploreSourceClubsHash() =>
    r'7c5ebe089f29b4b957ffa669b2d6b67e4564687a';

@ProviderFor(filteredExploreClubs)
final filteredExploreClubsProvider = FilteredExploreClubsProvider._();

final class FilteredExploreClubsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Club>>,
          AsyncValue<List<Club>>,
          AsyncValue<List<Club>>
        >
    with $Provider<AsyncValue<List<Club>>> {
  FilteredExploreClubsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredExploreClubsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredExploreClubsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Club>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Club>> create(Ref ref) {
    return filteredExploreClubs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Club>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Club>>>(value),
    );
  }
}

String _$filteredExploreClubsHash() =>
    r'80b04ddd99bfd7ed6c475d18bd431ed6889ca26f';

/// **Pattern D: View-model provider**
///
/// Combines the signed-in user, membership edges, and filtered club streams into
/// a
/// [ExploreViewModel] that partitions clubs into joined and discover
/// lists for the UI.

@ProviderFor(exploreViewModel)
final exploreViewModelProvider = ExploreViewModelProvider._();

/// **Pattern D: View-model provider**
///
/// Combines the signed-in user, membership edges, and filtered club streams into
/// a
/// [ExploreViewModel] that partitions clubs into joined and discover
/// lists for the UI.

final class ExploreViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<ExploreViewModel>,
          AsyncValue<ExploreViewModel>,
          AsyncValue<ExploreViewModel>
        >
    with $Provider<AsyncValue<ExploreViewModel>> {
  /// **Pattern D: View-model provider**
  ///
  /// Combines the signed-in user, membership edges, and filtered club streams into
  /// a
  /// [ExploreViewModel] that partitions clubs into joined and discover
  /// lists for the UI.
  ExploreViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'exploreViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$exploreViewModelHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<ExploreViewModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<ExploreViewModel> create(Ref ref) {
    return exploreViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ExploreViewModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ExploreViewModel>>(value),
    );
  }
}

String _$exploreViewModelHash() => r'9980a2e3114dfeeffaca1b5b2c9ca2e16ce4aa10';
