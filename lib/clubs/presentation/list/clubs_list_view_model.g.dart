// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clubs_list_view_model.dart';

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

@ProviderFor(SelectedClubCity)
final selectedClubCityProvider = SelectedClubCityProvider._();

/// **KeepAlive notifier with internal flag**
///
/// Holds the currently selected city for club browsing. Uses an
/// internal `_userSelected` flag so GPS auto-detection never overrides a
/// manual user pick. [keepAlive] is true so the city survives tab switches.
final class SelectedClubCityProvider
    extends $NotifierProvider<SelectedClubCity, CityData> {
  /// **KeepAlive notifier with internal flag**
  ///
  /// Holds the currently selected city for club browsing. Uses an
  /// internal `_userSelected` flag so GPS auto-detection never overrides a
  /// manual user pick. [keepAlive] is true so the city survives tab switches.
  SelectedClubCityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedClubCityProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedClubCityHash();

  @$internal
  @override
  SelectedClubCity create() => SelectedClubCity();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CityData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CityData>(value),
    );
  }
}

String _$selectedClubCityHash() => r'b07d8dddb07727c5dc0d23addc444111275dfa52';

/// **KeepAlive notifier with internal flag**
///
/// Holds the currently selected city for club browsing. Uses an
/// internal `_userSelected` flag so GPS auto-detection never overrides a
/// manual user pick. [keepAlive] is true so the city survives tab switches.

abstract class _$SelectedClubCity extends $Notifier<CityData> {
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

@ProviderFor(SelectedClubCityWasUserSelected)
final selectedClubCityWasUserSelectedProvider =
    SelectedClubCityWasUserSelectedProvider._();

final class SelectedClubCityWasUserSelectedProvider
    extends $NotifierProvider<SelectedClubCityWasUserSelected, bool> {
  SelectedClubCityWasUserSelectedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'selectedClubCityWasUserSelectedProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$selectedClubCityWasUserSelectedHash();

  @$internal
  @override
  SelectedClubCityWasUserSelected create() => SelectedClubCityWasUserSelected();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$selectedClubCityWasUserSelectedHash() =>
    r'56d712603b6be38f3f6285edc66e4b72225d9455';

abstract class _$SelectedClubCityWasUserSelected extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
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

@ProviderFor(ClubSearchQuery)
final clubSearchQueryProvider = ClubSearchQueryProvider._();

/// **KeepAlive notifier — simple string state**
///
/// Holds the current search query text. [keepAlive] ensures the query
/// survives tab switches so the user's search isn't lost while browsing.
final class ClubSearchQueryProvider
    extends $NotifierProvider<ClubSearchQuery, String> {
  /// **KeepAlive notifier — simple string state**
  ///
  /// Holds the current search query text. [keepAlive] ensures the query
  /// survives tab switches so the user's search isn't lost while browsing.
  ClubSearchQueryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubSearchQueryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubSearchQueryHash();

  @$internal
  @override
  ClubSearchQuery create() => ClubSearchQuery();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$clubSearchQueryHash() => r'a5dcc73e1c7abde5097b7ee2869d57537ee026ab';

/// **KeepAlive notifier — simple string state**
///
/// Holds the current search query text. [keepAlive] ensures the query
/// survives tab switches so the user's search isn't lost while browsing.

abstract class _$ClubSearchQuery extends $Notifier<String> {
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

@ProviderFor(ClubBrowseFilters)
final clubBrowseFiltersProvider = ClubBrowseFiltersProvider._();

final class ClubBrowseFiltersProvider
    extends $NotifierProvider<ClubBrowseFilters, ClubBrowseFilterSelection> {
  ClubBrowseFiltersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubBrowseFiltersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubBrowseFiltersHash();

  @$internal
  @override
  ClubBrowseFilters create() => ClubBrowseFilters();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClubBrowseFilterSelection value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClubBrowseFilterSelection>(value),
    );
  }
}

String _$clubBrowseFiltersHash() => r'76ddd38471b74267ac66c65d008817bb5709a1f1';

abstract class _$ClubBrowseFilters
    extends $Notifier<ClubBrowseFilterSelection> {
  ClubBrowseFilterSelection build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<ClubBrowseFilterSelection, ClubBrowseFilterSelection>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ClubBrowseFilterSelection, ClubBrowseFilterSelection>,
              ClubBrowseFilterSelection,
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

@ProviderFor(filteredClubs)
final filteredClubsProvider = FilteredClubsProvider._();

/// Algolia swap point: replace this provider's body to use a remote search
/// index. The VM and screen are not affected.
///
/// **Pattern D variant:** Combines location-filtered clubs with client-side
/// search to produce a filtered list for the UI.

final class FilteredClubsProvider
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
  FilteredClubsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredClubsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredClubsHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<List<Club>>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<List<Club>> create(Ref ref) {
    return filteredClubs(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<Club>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<List<Club>>>(value),
    );
  }
}

String _$filteredClubsHash() => r'3fca1a07d18bf9c4448c344aca625e9129d74edd';

/// **Pattern D: View-model provider**
///
/// Combines the signed-in user, membership edges, and filtered club streams into
/// a
/// [ClubsListViewModel] that partitions clubs into joined and discover
/// lists for the UI.

@ProviderFor(clubsListViewModel)
final clubsListViewModelProvider = ClubsListViewModelProvider._();

/// **Pattern D: View-model provider**
///
/// Combines the signed-in user, membership edges, and filtered club streams into
/// a
/// [ClubsListViewModel] that partitions clubs into joined and discover
/// lists for the UI.

final class ClubsListViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<ClubsListViewModel>,
          AsyncValue<ClubsListViewModel>,
          AsyncValue<ClubsListViewModel>
        >
    with $Provider<AsyncValue<ClubsListViewModel>> {
  /// **Pattern D: View-model provider**
  ///
  /// Combines the signed-in user, membership edges, and filtered club streams into
  /// a
  /// [ClubsListViewModel] that partitions clubs into joined and discover
  /// lists for the UI.
  ClubsListViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubsListViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubsListViewModelHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<ClubsListViewModel>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  AsyncValue<ClubsListViewModel> create(Ref ref) {
    return clubsListViewModel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<ClubsListViewModel> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<ClubsListViewModel>>(
        value,
      ),
    );
  }
}

String _$clubsListViewModelHash() =>
    r'77c1c31e3798d6542606b539a9900a437fea45eb';

/// **Pattern D: View-model provider**
///
/// Derives the create-club affordance from the server-owned hosted-club query.
/// The callable enforces the one-club invariant; this provider keeps the list
/// UI from offering a creation path after a host already has a club.

@ProviderFor(canCreateClub)
final canCreateClubProvider = CanCreateClubProvider._();

/// **Pattern D: View-model provider**
///
/// Derives the create-club affordance from the server-owned hosted-club query.
/// The callable enforces the one-club invariant; this provider keeps the list
/// UI from offering a creation path after a host already has a club.

final class CanCreateClubProvider
    extends
        $FunctionalProvider<
          AsyncValue<bool>,
          AsyncValue<bool>,
          AsyncValue<bool>
        >
    with $Provider<AsyncValue<bool>> {
  /// **Pattern D: View-model provider**
  ///
  /// Derives the create-club affordance from the server-owned hosted-club query.
  /// The callable enforces the one-club invariant; this provider keeps the list
  /// UI from offering a creation path after a host already has a club.
  CanCreateClubProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'canCreateClubProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$canCreateClubHash();

  @$internal
  @override
  $ProviderElement<AsyncValue<bool>> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AsyncValue<bool> create(Ref ref) {
    return canCreateClub(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<bool> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AsyncValue<bool>>(value),
    );
  }
}

String _$canCreateClubHash() => r'2ee88d3f7f0ed39d0ac07f94f95e1b9742d86e9c';
