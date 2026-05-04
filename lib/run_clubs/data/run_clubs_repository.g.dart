// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_clubs_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runClubsRepository)
final runClubsRepositoryProvider = RunClubsRepositoryProvider._();

final class RunClubsRepositoryProvider
    extends
        $FunctionalProvider<
          RunClubsRepository,
          RunClubsRepository,
          RunClubsRepository
        >
    with $Provider<RunClubsRepository> {
  RunClubsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runClubsRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runClubsRepositoryHash();

  @$internal
  @override
  $ProviderElement<RunClubsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RunClubsRepository create(Ref ref) {
    return runClubsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunClubsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunClubsRepository>(value),
    );
  }
}

String _$runClubsRepositoryHash() =>
    r'7395a02d56cab070c5d06bfe8038aaf99b9efb33';

@ProviderFor(watchRunClub)
final watchRunClubProvider = WatchRunClubFamily._();

final class WatchRunClubProvider
    extends
        $FunctionalProvider<AsyncValue<RunClub?>, RunClub?, Stream<RunClub?>>
    with $FutureModifier<RunClub?>, $StreamProvider<RunClub?> {
  WatchRunClubProvider._({
    required WatchRunClubFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchRunClubProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchRunClubHash();

  @override
  String toString() {
    return r'watchRunClubProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<RunClub?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<RunClub?> create(Ref ref) {
    final argument = this.argument as String;
    return watchRunClub(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRunClubProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRunClubHash() => r'4e99933db2bde6b76df713e198b53fb0bfeedcc8';

final class WatchRunClubFamily extends $Family
    with $FunctionalFamilyOverride<Stream<RunClub?>, String> {
  WatchRunClubFamily._()
    : super(
        retry: null,
        name: r'watchRunClubProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  WatchRunClubProvider call(String id) =>
      WatchRunClubProvider._(argument: id, from: this);

  @override
  String toString() => r'watchRunClubProvider';
}

@ProviderFor(watchRunClubsByLocation)
final watchRunClubsByLocationProvider = WatchRunClubsByLocationFamily._();

final class WatchRunClubsByLocationProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RunClub>>,
          List<RunClub>,
          Stream<List<RunClub>>
        >
    with $FutureModifier<List<RunClub>>, $StreamProvider<List<RunClub>> {
  WatchRunClubsByLocationProvider._({
    required WatchRunClubsByLocationFamily super.from,
    required IndianCity super.argument,
  }) : super(
         retry: null,
         name: r'watchRunClubsByLocationProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchRunClubsByLocationHash();

  @override
  String toString() {
    return r'watchRunClubsByLocationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RunClub>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RunClub>> create(Ref ref) {
    final argument = this.argument as IndianCity;
    return watchRunClubsByLocation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRunClubsByLocationProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRunClubsByLocationHash() =>
    r'75b450758b9efe04001f50ec875b80e526dfe155';

final class WatchRunClubsByLocationFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RunClub>>, IndianCity> {
  WatchRunClubsByLocationFamily._()
    : super(
        retry: null,
        name: r'watchRunClubsByLocationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  WatchRunClubsByLocationProvider call(IndianCity location) =>
      WatchRunClubsByLocationProvider._(argument: location, from: this);

  @override
  String toString() => r'watchRunClubsByLocationProvider';
}

@ProviderFor(watchRunClubsByLocationSortedByRating)
final watchRunClubsByLocationSortedByRatingProvider =
    WatchRunClubsByLocationSortedByRatingFamily._();

final class WatchRunClubsByLocationSortedByRatingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RunClub>>,
          List<RunClub>,
          Stream<List<RunClub>>
        >
    with $FutureModifier<List<RunClub>>, $StreamProvider<List<RunClub>> {
  WatchRunClubsByLocationSortedByRatingProvider._({
    required WatchRunClubsByLocationSortedByRatingFamily super.from,
    required IndianCity super.argument,
  }) : super(
         retry: null,
         name: r'watchRunClubsByLocationSortedByRatingProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$watchRunClubsByLocationSortedByRatingHash();

  @override
  String toString() {
    return r'watchRunClubsByLocationSortedByRatingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RunClub>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RunClub>> create(Ref ref) {
    final argument = this.argument as IndianCity;
    return watchRunClubsByLocationSortedByRating(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRunClubsByLocationSortedByRatingProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRunClubsByLocationSortedByRatingHash() =>
    r'1495365edafc0a53184dacc2754859a644c411d1';

final class WatchRunClubsByLocationSortedByRatingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RunClub>>, IndianCity> {
  WatchRunClubsByLocationSortedByRatingFamily._()
    : super(
        retry: null,
        name: r'watchRunClubsByLocationSortedByRatingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  WatchRunClubsByLocationSortedByRatingProvider call(IndianCity location) =>
      WatchRunClubsByLocationSortedByRatingProvider._(
        argument: location,
        from: this,
      );

  @override
  String toString() => r'watchRunClubsByLocationSortedByRatingProvider';
}

@ProviderFor(fetchRunClub)
final fetchRunClubProvider = FetchRunClubFamily._();

final class FetchRunClubProvider
    extends
        $FunctionalProvider<AsyncValue<RunClub?>, RunClub?, FutureOr<RunClub?>>
    with $FutureModifier<RunClub?>, $FutureProvider<RunClub?> {
  FetchRunClubProvider._({
    required FetchRunClubFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fetchRunClubProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchRunClubHash();

  @override
  String toString() {
    return r'fetchRunClubProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RunClub?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<RunClub?> create(Ref ref) {
    final argument = this.argument as String;
    return fetchRunClub(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchRunClubProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchRunClubHash() => r'f81158d26687b92c5266dd7a4c7dd2c9161fea0a';

final class FetchRunClubFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RunClub?>, String> {
  FetchRunClubFamily._()
    : super(
        retry: null,
        name: r'fetchRunClubProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FetchRunClubProvider call(String id) =>
      FetchRunClubProvider._(argument: id, from: this);

  @override
  String toString() => r'fetchRunClubProvider';
}
