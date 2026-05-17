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

@ProviderFor(dashboardRecommendedEvents)
final dashboardRecommendedEventsProvider = DashboardRecommendedEventsFamily._();

/// **Pattern D: View-model provider**
///
/// Keeps dashboard recommendation fetching behind generated Riverpod so this
/// presentation provider follows the same declaration style as the rest of the
/// app.

final class DashboardRecommendedEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<DashboardEventRecommendationCandidate>>,
          List<DashboardEventRecommendationCandidate>,
          FutureOr<List<DashboardEventRecommendationCandidate>>
        >
    with
        $FutureModifier<List<DashboardEventRecommendationCandidate>>,
        $FutureProvider<List<DashboardEventRecommendationCandidate>> {
  /// **Pattern D: View-model provider**
  ///
  /// Keeps dashboard recommendation fetching behind generated Riverpod so this
  /// presentation provider follows the same declaration style as the rest of the
  /// app.
  DashboardRecommendedEventsProvider._({
    required DashboardRecommendedEventsFamily super.from,
    required DashboardRecommendationsQuery super.argument,
  }) : super(
         retry: null,
         name: r'dashboardRecommendedEventsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$dashboardRecommendedEventsHash();

  @override
  String toString() {
    return r'dashboardRecommendedEventsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<DashboardEventRecommendationCandidate>>
  $createElement($ProviderPointer pointer) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<DashboardEventRecommendationCandidate>> create(Ref ref) {
    final argument = this.argument as DashboardRecommendationsQuery;
    return dashboardRecommendedEvents(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is DashboardRecommendedEventsProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$dashboardRecommendedEventsHash() =>
    r'd858bc8d9e7c0419beecf30717490a8fb84d478f';

/// **Pattern D: View-model provider**
///
/// Keeps dashboard recommendation fetching behind generated Riverpod so this
/// presentation provider follows the same declaration style as the rest of the
/// app.

final class DashboardRecommendedEventsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<DashboardEventRecommendationCandidate>>,
          DashboardRecommendationsQuery
        > {
  DashboardRecommendedEventsFamily._()
    : super(
        retry: null,
        name: r'dashboardRecommendedEventsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// **Pattern D: View-model provider**
  ///
  /// Keeps dashboard recommendation fetching behind generated Riverpod so this
  /// presentation provider follows the same declaration style as the rest of the
  /// app.

  DashboardRecommendedEventsProvider call(
    DashboardRecommendationsQuery query,
  ) => DashboardRecommendedEventsProvider._(argument: query, from: this);

  @override
  String toString() => r'dashboardRecommendedEventsProvider';
}
