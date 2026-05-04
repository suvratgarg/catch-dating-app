// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_full_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Combines signed-up runs, attended runs, and recommended runs into a single
/// [DashboardFullViewModel] for the dashboard screen.

@ProviderFor(dashboardFullViewModel)
final dashboardFullViewModelProvider = DashboardFullViewModelFamily._();

/// Combines signed-up runs, attended runs, and recommended runs into a single
/// [DashboardFullViewModel] for the dashboard screen.

final class DashboardFullViewModelProvider
    extends
        $FunctionalProvider<
          DashboardFullViewModel,
          DashboardFullViewModel,
          DashboardFullViewModel
        >
    with $Provider<DashboardFullViewModel> {
  /// Combines signed-up runs, attended runs, and recommended runs into a single
  /// [DashboardFullViewModel] for the dashboard screen.
  DashboardFullViewModelProvider._({
    required DashboardFullViewModelFamily super.from,
    required ({
      List<Run> signedUpRuns,
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
              List<Run> signedUpRuns,
              String uid,
              List<String> followedClubIds,
            });
    return dashboardFullViewModel(
      ref,
      signedUpRuns: argument.signedUpRuns,
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
    r'c252b3ef5f52b60f8d7a0e1dc6cc922e97ed605a';

/// Combines signed-up runs, attended runs, and recommended runs into a single
/// [DashboardFullViewModel] for the dashboard screen.

final class DashboardFullViewModelFamily extends $Family
    with
        $FunctionalFamilyOverride<
          DashboardFullViewModel,
          ({List<Run> signedUpRuns, String uid, List<String> followedClubIds})
        > {
  DashboardFullViewModelFamily._()
    : super(
        retry: null,
        name: r'dashboardFullViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Combines signed-up runs, attended runs, and recommended runs into a single
  /// [DashboardFullViewModel] for the dashboard screen.

  DashboardFullViewModelProvider call({
    required List<Run> signedUpRuns,
    required String uid,
    required List<String> followedClubIds,
  }) => DashboardFullViewModelProvider._(
    argument: (
      signedUpRuns: signedUpRuns,
      uid: uid,
      followedClubIds: followedClubIds,
    ),
    from: this,
  );

  @override
  String toString() => r'dashboardFullViewModelProvider';
}
