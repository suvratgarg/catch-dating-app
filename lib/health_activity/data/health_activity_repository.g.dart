// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_activity_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(healthActivityRepository)
final healthActivityRepositoryProvider = HealthActivityRepositoryProvider._();

final class HealthActivityRepositoryProvider
    extends
        $FunctionalProvider<
          HealthActivityRepository,
          HealthActivityRepository,
          HealthActivityRepository
        >
    with $Provider<HealthActivityRepository> {
  HealthActivityRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'healthActivityRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$healthActivityRepositoryHash();

  @$internal
  @override
  $ProviderElement<HealthActivityRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  HealthActivityRepository create(Ref ref) {
    return healthActivityRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HealthActivityRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HealthActivityRepository>(value),
    );
  }
}

String _$healthActivityRepositoryHash() =>
    r'43618d3b17dd71c0ebc74924f62e79411be00522';

@ProviderFor(weeklyRunningActivity)
final weeklyRunningActivityProvider = WeeklyRunningActivityProvider._();

final class WeeklyRunningActivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<WeeklyRunningActivitySnapshot>,
          WeeklyRunningActivitySnapshot,
          FutureOr<WeeklyRunningActivitySnapshot>
        >
    with
        $FutureModifier<WeeklyRunningActivitySnapshot>,
        $FutureProvider<WeeklyRunningActivitySnapshot> {
  WeeklyRunningActivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weeklyRunningActivityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weeklyRunningActivityHash();

  @$internal
  @override
  $FutureProviderElement<WeeklyRunningActivitySnapshot> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<WeeklyRunningActivitySnapshot> create(Ref ref) {
    return weeklyRunningActivity(ref);
  }
}

String _$weeklyRunningActivityHash() =>
    r'a81f72847c44089b8e071b0f01a760e2d02a696d';
