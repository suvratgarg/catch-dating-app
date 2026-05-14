// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dashboard_recommendations_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern D: View-model provider**
///
/// Keeps dashboard recommendation fetching behind generated Riverpod so this
/// presentation provider follows the same declaration style as the rest of the
/// app.

@ProviderFor(dashboardRecommendedRuns)
final dashboardRecommendedRunsProvider = DashboardRecommendedRunsFamily._();

/// **Pattern D: View-model provider**
///
/// Keeps dashboard recommendation fetching behind generated Riverpod so this
/// presentation provider follows the same declaration style as the rest of the
/// app.

final class DashboardRecommendedRunsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DashboardRunRecommendationCandidate>>,
          List<DashboardRunRecommendationCandidate>,
          FutureOr<List<DashboardRunRecommendationCandidate>>
        >
    with
        $FutureModifier<List<DashboardRunRecommendationCandidate>>,
        $FutureProvider<List<DashboardRunRecommendationCandidate>> {
  /// **Pattern D: View-model provider**
  ///
  /// Keeps dashboard recommendation fetching behind generated Riverpod so this
  /// presentation provider follows the same declaration style as the rest of the
  /// app.
  DashboardRecommendedRunsProvider._({
    required DashboardRecommendedRunsFamily super.from,
    required DashboardRecommendationsQuery super.argument,
  }) : super(
         retry: null,
         name: r'dashboardRecommendedRunsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dashboardRecommendedRunsHash();

  @override
  String toString() {
    return r'dashboardRecommendedRunsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DashboardRunRecommendationCandidate>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DashboardRunRecommendationCandidate>> create(Ref ref) {
    final argument = this.argument as DashboardRecommendationsQuery;
    return dashboardRecommendedRuns(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DashboardRecommendedRunsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dashboardRecommendedRunsHash() =>
    r'67132b8a08386e1938ddbe3abf4927e431854fcb';

/// **Pattern D: View-model provider**
///
/// Keeps dashboard recommendation fetching behind generated Riverpod so this
/// presentation provider follows the same declaration style as the rest of the
/// app.

final class DashboardRecommendedRunsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<DashboardRunRecommendationCandidate>>,
          DashboardRecommendationsQuery
        > {
  DashboardRecommendedRunsFamily._()
    : super(
        retry: null,
        name: r'dashboardRecommendedRunsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// **Pattern D: View-model provider**
  ///
  /// Keeps dashboard recommendation fetching behind generated Riverpod so this
  /// presentation provider follows the same declaration style as the rest of the
  /// app.

  DashboardRecommendedRunsProvider call(DashboardRecommendationsQuery query) =>
      DashboardRecommendedRunsProvider._(argument: query, from: this);

  @override
  String toString() => r'dashboardRecommendedRunsProvider';
}
