// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'clubs_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(clubsRepository)
final clubsRepositoryProvider = ClubsRepositoryProvider._();

final class ClubsRepositoryProvider
    extends
        $FunctionalProvider<ClubsRepository, ClubsRepository, ClubsRepository>
    with $Provider<ClubsRepository> {
  ClubsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'clubsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$clubsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ClubsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ClubsRepository create(Ref ref) {
    return clubsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ClubsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ClubsRepository>(value),
    );
  }
}

String _$clubsRepositoryHash() => r'd5c0011e3ab9214aec9e91f81c5ff073ce0f3cca';

@ProviderFor(watchClub)
final watchClubProvider = WatchClubFamily._();

final class WatchClubProvider
    extends $FunctionalProvider<AsyncValue<Club?>, Club?, Stream<Club?>>
    with $FutureModifier<Club?>, $StreamProvider<Club?> {
  WatchClubProvider._({
    required WatchClubFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchClubProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchClubHash();

  @override
  String toString() {
    return r'watchClubProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<Club?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Club?> create(Ref ref) {
    final argument = this.argument as String;
    return watchClub(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchClubProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchClubHash() => r'595f1b7e4ea99cb75600b39d84baa61f5d680b0e';

final class WatchClubFamily extends $Family
    with $FunctionalFamilyOverride<Stream<Club?>, String> {
  WatchClubFamily._()
    : super(
        retry: null,
        name: r'watchClubProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchClubProvider call(String id) =>
      WatchClubProvider._(argument: id, from: this);

  @override
  String toString() => r'watchClubProvider';
}

@ProviderFor(watchClubsByLocation)
final watchClubsByLocationProvider = WatchClubsByLocationFamily._();

final class WatchClubsByLocationProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Club>>,
          List<Club>,
          Stream<List<Club>>
        >
    with $FutureModifier<List<Club>>, $StreamProvider<List<Club>> {
  WatchClubsByLocationProvider._({
    required WatchClubsByLocationFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchClubsByLocationProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchClubsByLocationHash();

  @override
  String toString() {
    return r'watchClubsByLocationProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Club>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Club>> create(Ref ref) {
    final argument = this.argument as String;
    return watchClubsByLocation(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchClubsByLocationProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchClubsByLocationHash() =>
    r'66d4bf98e32e589a19902448a858f99b5d0cf50e';

final class WatchClubsByLocationFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Club>>, String> {
  WatchClubsByLocationFamily._()
    : super(
        retry: null,
        name: r'watchClubsByLocationProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchClubsByLocationProvider call(String location) =>
      WatchClubsByLocationProvider._(argument: location, from: this);

  @override
  String toString() => r'watchClubsByLocationProvider';
}

@ProviderFor(watchClubsByLocationSortedByRating)
final watchClubsByLocationSortedByRatingProvider =
    WatchClubsByLocationSortedByRatingFamily._();

final class WatchClubsByLocationSortedByRatingProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Club>>,
          List<Club>,
          Stream<List<Club>>
        >
    with $FutureModifier<List<Club>>, $StreamProvider<List<Club>> {
  WatchClubsByLocationSortedByRatingProvider._({
    required WatchClubsByLocationSortedByRatingFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchClubsByLocationSortedByRatingProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() =>
      _$watchClubsByLocationSortedByRatingHash();

  @override
  String toString() {
    return r'watchClubsByLocationSortedByRatingProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Club>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Club>> create(Ref ref) {
    final argument = this.argument as String;
    return watchClubsByLocationSortedByRating(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchClubsByLocationSortedByRatingProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchClubsByLocationSortedByRatingHash() =>
    r'be5812eb9d8ab67139d5f0bef9b61069d2ef9077';

final class WatchClubsByLocationSortedByRatingFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Club>>, String> {
  WatchClubsByLocationSortedByRatingFamily._()
    : super(
        retry: null,
        name: r'watchClubsByLocationSortedByRatingProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchClubsByLocationSortedByRatingProvider call(String location) =>
      WatchClubsByLocationSortedByRatingProvider._(
        argument: location,
        from: this,
      );

  @override
  String toString() => r'watchClubsByLocationSortedByRatingProvider';
}

@ProviderFor(watchClubsHostedBy)
final watchClubsHostedByProvider = WatchClubsHostedByFamily._();

final class WatchClubsHostedByProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Club>>,
          List<Club>,
          Stream<List<Club>>
        >
    with $FutureModifier<List<Club>>, $StreamProvider<List<Club>> {
  WatchClubsHostedByProvider._({
    required WatchClubsHostedByFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchClubsHostedByProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchClubsHostedByHash();

  @override
  String toString() {
    return r'watchClubsHostedByProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Club>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Club>> create(Ref ref) {
    final argument = this.argument as String;
    return watchClubsHostedBy(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchClubsHostedByProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchClubsHostedByHash() =>
    r'a99997587b97bc0cbba213b5c4ff883a097becab';

final class WatchClubsHostedByFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Club>>, String> {
  WatchClubsHostedByFamily._()
    : super(
        retry: null,
        name: r'watchClubsHostedByProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchClubsHostedByProvider call(String uid) =>
      WatchClubsHostedByProvider._(argument: uid, from: this);

  @override
  String toString() => r'watchClubsHostedByProvider';
}

@ProviderFor(fetchClub)
final fetchClubProvider = FetchClubFamily._();

final class FetchClubProvider
    extends $FunctionalProvider<AsyncValue<Club?>, Club?, FutureOr<Club?>>
    with $FutureModifier<Club?>, $FutureProvider<Club?> {
  FetchClubProvider._({
    required FetchClubFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'fetchClubProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$fetchClubHash();

  @override
  String toString() {
    return r'fetchClubProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Club?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Club?> create(Ref ref) {
    final argument = this.argument as String;
    return fetchClub(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is FetchClubProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$fetchClubHash() => r'9df4647c451439dc88aa30593726b22930f65664';

final class FetchClubFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Club?>, String> {
  FetchClubFamily._()
    : super(
        retry: null,
        name: r'fetchClubProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  FetchClubProvider call(String id) =>
      FetchClubProvider._(argument: id, from: this);

  @override
  String toString() => r'fetchClubProvider';
}
