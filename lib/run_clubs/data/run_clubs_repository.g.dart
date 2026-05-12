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
        isAutoDispose: false,
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
    r'0cc8b04d8acc76a673fa9f8284cdee111f734c05';

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
         isAutoDispose: true,
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

String _$watchRunClubHash() => r'35ef4fcd777bd25ea3019208ec95d7c8abe2cb76';

final class WatchRunClubFamily extends $Family
    with $FunctionalFamilyOverride<Stream<RunClub?>, String> {
  WatchRunClubFamily._()
    : super(
        retry: null,
        name: r'watchRunClubProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
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
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchRunClubsByLocationProvider',
         isAutoDispose: true,
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
    final argument = this.argument as String;
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
    r'6795e813526e50b9341ade467ca6d6ca639f75fd';

final class WatchRunClubsByLocationFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RunClub>>, String> {
  WatchRunClubsByLocationFamily._()
    : super(
        retry: null,
        name: r'watchRunClubsByLocationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchRunClubsByLocationProvider call(String location) =>
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
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchRunClubsByLocationSortedByRatingProvider',
         isAutoDispose: true,
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
    final argument = this.argument as String;
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
    r'f9ad37e9287799546717ebacc0eef21dc29f4c9d';

final class WatchRunClubsByLocationSortedByRatingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RunClub>>, String> {
  WatchRunClubsByLocationSortedByRatingFamily._()
    : super(
        retry: null,
        name: r'watchRunClubsByLocationSortedByRatingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchRunClubsByLocationSortedByRatingProvider call(String location) =>
      WatchRunClubsByLocationSortedByRatingProvider._(
        argument: location,
        from: this,
      );

  @override
  String toString() => r'watchRunClubsByLocationSortedByRatingProvider';
}

@ProviderFor(watchRunClubsHostedBy)
final watchRunClubsHostedByProvider = WatchRunClubsHostedByFamily._();

final class WatchRunClubsHostedByProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RunClub>>,
          List<RunClub>,
          Stream<List<RunClub>>
        >
    with $FutureModifier<List<RunClub>>, $StreamProvider<List<RunClub>> {
  WatchRunClubsHostedByProvider._({
    required WatchRunClubsHostedByFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchRunClubsHostedByProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchRunClubsHostedByHash();

  @override
  String toString() {
    return r'watchRunClubsHostedByProvider'
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
    final argument = this.argument as String;
    return watchRunClubsHostedBy(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchRunClubsHostedByProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchRunClubsHostedByHash() =>
    r'4f0a926f7e3c3ef1d34a592ee72ed0cda8e71220';

final class WatchRunClubsHostedByFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RunClub>>, String> {
  WatchRunClubsHostedByFamily._()
    : super(
        retry: null,
        name: r'watchRunClubsHostedByProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchRunClubsHostedByProvider call(String uid) =>
      WatchRunClubsHostedByProvider._(argument: uid, from: this);

  @override
  String toString() => r'watchRunClubsHostedByProvider';
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
