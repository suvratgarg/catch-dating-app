// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_full_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dashboardNow)
final dashboardNowProvider = DashboardNowProvider._();

final class DashboardNowProvider
    extends $FunctionalProvider<DateTime, DateTime, DateTime>
    with $Provider<DateTime> {
  DashboardNowProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardNowProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardNowHash();

  @$internal
  @override
  $ProviderElement<DateTime> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DateTime create(Ref ref) {
    return dashboardNow(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DateTime value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DateTime>(value),
    );
  }
}

String _$dashboardNowHash() => r'91e11349a0f778936d9df6327401917812107880';

/// Combines signed-up events, attended events, and recommended events into a single
/// [DashboardFullViewModel] for the dashboard screen.

@ProviderFor(dashboardFullViewModel)
final dashboardFullViewModelProvider = DashboardFullViewModelFamily._();

/// Combines signed-up events, attended events, and recommended events into a single
/// [DashboardFullViewModel] for the dashboard screen.

final class DashboardFullViewModelProvider
    extends
        $FunctionalProvider<
          DashboardFullViewModel,
          DashboardFullViewModel,
          DashboardFullViewModel
        >
    with $Provider<DashboardFullViewModel> {
  /// Combines signed-up events, attended events, and recommended events into a single
  /// [DashboardFullViewModel] for the dashboard screen.
  DashboardFullViewModelProvider._({
    required DashboardFullViewModelFamily super.from,
    required ({
      List<Event> signedUpEvents,
      UserProfile user,
      String uid,
      List<String> followedClubIds,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'dashboardFullViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dashboardFullViewModelHash();

  @override
  String toString() {
    return r'dashboardFullViewModelProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $ProviderElement<DashboardFullViewModel> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DashboardFullViewModel create(Ref ref) {
    final argument =
        this.argument
            as ({
              List<Event> signedUpEvents,
              UserProfile user,
              String uid,
              List<String> followedClubIds,
            });
    return dashboardFullViewModel(
      ref,
      signedUpEvents: argument.signedUpEvents,
      user: argument.user,
      uid: argument.uid,
      followedClubIds: argument.followedClubIds,
    );
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardFullViewModel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardFullViewModel>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is DashboardFullViewModelProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dashboardFullViewModelHash() =>
    r'7b3d5b0fc2653abc4b3fa6b66b7927a17fc577b4';

/// Combines signed-up events, attended events, and recommended events into a single
/// [DashboardFullViewModel] for the dashboard screen.

final class DashboardFullViewModelFamily extends $Family
    with
        $FunctionalFamilyOverride<
          DashboardFullViewModel,
          ({
            List<Event> signedUpEvents,
            UserProfile user,
            String uid,
            List<String> followedClubIds,
          })
        > {
  DashboardFullViewModelFamily._()
    : super(
        retry: null,
        name: r'dashboardFullViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Combines signed-up events, attended events, and recommended events into a single
  /// [DashboardFullViewModel] for the dashboard screen.

  DashboardFullViewModelProvider call({
    required List<Event> signedUpEvents,
    required UserProfile user,
    required String uid,
    required List<String> followedClubIds,
  }) => DashboardFullViewModelProvider._(
    argument: (
      signedUpEvents: signedUpEvents,
      user: user,
      uid: uid,
      followedClubIds: followedClubIds,
    ),
    from: this,
  );

  @override
  String toString() => r'dashboardFullViewModelProvider';
}

/// Builds the route-level state for Dashboard Home.
///
/// The route widget should only switch over this state and compose the selected
/// sections; provider waves, retry targets, header copy, and empty/full
/// selection live here.

@ProviderFor(dashboardHomeScreenState)
final dashboardHomeScreenStateProvider = DashboardHomeScreenStateProvider._();

/// Builds the route-level state for Dashboard Home.
///
/// The route widget should only switch over this state and compose the selected
/// sections; provider waves, retry targets, header copy, and empty/full
/// selection live here.

final class DashboardHomeScreenStateProvider
    extends
        $FunctionalProvider<
          DashboardHomeScreenState,
          DashboardHomeScreenState,
          DashboardHomeScreenState
        >
    with $Provider<DashboardHomeScreenState> {
  /// Builds the route-level state for Dashboard Home.
  ///
  /// The route widget should only switch over this state and compose the selected
  /// sections; provider waves, retry targets, header copy, and empty/full
  /// selection live here.
  DashboardHomeScreenStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dashboardHomeScreenStateProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dashboardHomeScreenStateHash();

  @$internal
  @override
  $ProviderElement<DashboardHomeScreenState> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DashboardHomeScreenState create(Ref ref) {
    return dashboardHomeScreenState(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DashboardHomeScreenState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DashboardHomeScreenState>(value),
    );
  }
}

String _$dashboardHomeScreenStateHash() =>
    r'5339a856fbeb67b044df698deb20b757e0787a8a';
