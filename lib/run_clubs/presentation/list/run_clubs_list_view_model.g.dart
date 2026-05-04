// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_clubs_list_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **KeepAlive notifier with internal flag**
///
/// Holds the currently selected city for run club browsing. Uses an
/// internal `_userSelected` flag so GPS auto-detection never overrides a
/// manual user pick. [keepAlive] is true so the city survives tab switches.

@ProviderFor(SelectedRunClubCity)
final selectedRunClubCityProvider = SelectedRunClubCityProvider._();

/// **KeepAlive notifier with internal flag**
///
/// Holds the currently selected city for run club browsing. Uses an
/// internal `_userSelected` flag so GPS auto-detection never overrides a
/// manual user pick. [keepAlive] is true so the city survives tab switches.
final class SelectedRunClubCityProvider
    extends $NotifierProvider<SelectedRunClubCity, CityData> {
  /// **KeepAlive notifier with internal flag**
  ///
  /// Holds the currently selected city for run club browsing. Uses an
  /// internal `_userSelected` flag so GPS auto-detection never overrides a
  /// manual user pick. [keepAlive] is true so the city survives tab switches.
  SelectedRunClubCityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedRunClubCityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedRunClubCityHash();

  @$internal
  @override
  SelectedRunClubCity create() => SelectedRunClubCity();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CityData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CityData>(value),
    );
  }
}

String _$selectedRunClubCityHash() =>
    r'9af3076ff297f9b027eadd19b6db6a2f95cee475';

/// **KeepAlive notifier with internal flag**
///
/// Holds the currently selected city for run club browsing. Uses an
/// internal `_userSelected` flag so GPS auto-detection never overrides a
/// manual user pick. [keepAlive] is true so the city survives tab switches.

abstract class _$SelectedRunClubCity extends $Notifier<CityData> {
  CityData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<CityData, CityData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CityData, CityData>,
              CityData,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// **KeepAlive notifier — simple string state**
///
/// Holds the current search query text. [keepAlive] ensures the query
/// survives tab switches so the user's search isn't lost while browsing.

@ProviderFor(RunClubSearchQuery)
final runClubSearchQueryProvider = RunClubSearchQueryProvider._();

/// **KeepAlive notifier — simple string state**
///
/// Holds the current search query text. [keepAlive] ensures the query
/// survives tab switches so the user's search isn't lost while browsing.
final class RunClubSearchQueryProvider
    extends $NotifierProvider<RunClubSearchQuery, String> {
  /// **KeepAlive notifier — simple string state**
  ///
  /// Holds the current search query text. [keepAlive] ensures the query
  /// survives tab switches so the user's search isn't lost while browsing.
  RunClubSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runClubSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runClubSearchQueryHash();

  @$internal
  @override
  RunClubSearchQuery create() => RunClubSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$runClubSearchQueryHash() =>
    r'64a158e60f6baec7ce721df41fae9b9cf14c4fac';

/// **KeepAlive notifier — simple string state**
///
/// Holds the current search query text. [keepAlive] ensures the query
/// survives tab switches so the user's search isn't lost while browsing.

abstract class _$RunClubSearchQuery extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<String, String>,
              String,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Algolia swap point: replace this provider's body to use a remote search
/// index. The VM and screen are not affected.
///
/// **Pattern D variant:** Combines location-filtered clubs with client-side
/// search to produce a filtered list for the UI.

@ProviderFor(filteredRunClubs)
final filteredRunClubsProvider = FilteredRunClubsProvider._();

/// Algolia swap point: replace this provider's body to use a remote search
/// index. The VM and screen are not affected.
///
/// **Pattern D variant:** Combines location-filtered clubs with client-side
/// search to produce a filtered list for the UI.

final class FilteredRunClubsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RunClub>>,
          AsyncValue<List<RunClub>>,
          AsyncValue<List<RunClub>>
        >
    with $Provider<AsyncValue<List<RunClub>>> {
  /// Algolia swap point: replace this provider's body to use a remote search
  /// index. The VM and screen are not affected.
  ///
  /// **Pattern D variant:** Combines location-filtered clubs with client-side
  /// search to produce a filtered list for the UI.
  FilteredRunClubsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredRunClubsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredRunClubsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<RunClub>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<RunClub>> create(Ref ref) {
    return filteredRunClubs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<RunClub>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<RunClub>>>(value),
    );
  }
}

String _$filteredRunClubsHash() => r'fa2dc7dc25481dceba433fd984e5c1f9d218fd93';

/// **Pattern D: Pure computed provider combining multiple async streams**
///
/// Combines the user profile and filtered clubs streams into a
/// [RunClubsListViewModel] that partitions clubs into joined and discover
/// lists for the UI.

@ProviderFor(runClubsListViewModel)
final runClubsListViewModelProvider = RunClubsListViewModelProvider._();

/// **Pattern D: Pure computed provider combining multiple async streams**
///
/// Combines the user profile and filtered clubs streams into a
/// [RunClubsListViewModel] that partitions clubs into joined and discover
/// lists for the UI.

final class RunClubsListViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunClubsListViewModel>,
          AsyncValue<RunClubsListViewModel>,
          AsyncValue<RunClubsListViewModel>
        >
    with $Provider<AsyncValue<RunClubsListViewModel>> {
  /// **Pattern D: Pure computed provider combining multiple async streams**
  ///
  /// Combines the user profile and filtered clubs streams into a
  /// [RunClubsListViewModel] that partitions clubs into joined and discover
  /// lists for the UI.
  RunClubsListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runClubsListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runClubsListViewModelHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<RunClubsListViewModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<RunClubsListViewModel> create(Ref ref) {
    return runClubsListViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<RunClubsListViewModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<RunClubsListViewModel>>(
        value,
      ),
    );
  }
}

String _$runClubsListViewModelHash() =>
    r'63d5ff670791aac54c06263f0d9e6f6fb4894bf4';
