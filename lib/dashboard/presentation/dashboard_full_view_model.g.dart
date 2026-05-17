// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_full_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
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
    r'129fdf40dc4fc526290c9c848b72167dca516e60';

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
