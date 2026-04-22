// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_clubs_list_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(SelectedRunClubCity)
final selectedRunClubCityProvider = SelectedRunClubCityProvider._();

final class SelectedRunClubCityProvider
    extends $NotifierProvider<SelectedRunClubCity, IndianCity> {
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
  Override overrideWithValue(IndianCity value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IndianCity>(value),
    );
  }
}

String _$selectedRunClubCityHash() =>
    r'356ea2a54be8c716c7ee9b3274b3ca7c75b75f73';

abstract class _$SelectedRunClubCity extends $Notifier<IndianCity> {
  IndianCity build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<IndianCity, IndianCity>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<IndianCity, IndianCity>,
              IndianCity,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(RunClubSearchQuery)
final runClubSearchQueryProvider = RunClubSearchQueryProvider._();

final class RunClubSearchQueryProvider
    extends $NotifierProvider<RunClubSearchQuery, String> {
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

@ProviderFor(filteredRunClubs)
final filteredRunClubsProvider = FilteredRunClubsProvider._();

/// Algolia swap point: replace this provider's body to use a remote search
/// index. The VM and screen are not affected.

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

String _$filteredRunClubsHash() => r'8460f2e5083fe3b5945204d9f60095c03006c768';

@ProviderFor(runClubsListViewModel)
final runClubsListViewModelProvider = RunClubsListViewModelProvider._();

final class RunClubsListViewModelProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunClubsListViewModel>,
          AsyncValue<RunClubsListViewModel>,
          AsyncValue<RunClubsListViewModel>
        >
    with $Provider<AsyncValue<RunClubsListViewModel>> {
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
    r'1dacc7068936f1142bc4e7168e1330064c06562d';
