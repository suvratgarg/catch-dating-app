// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'match_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(matchRepository)
final matchRepositoryProvider = MatchRepositoryProvider._();

final class MatchRepositoryProvider
    extends
        $FunctionalProvider<MatchRepository, MatchRepository, MatchRepository>
    with $Provider<MatchRepository> {
  MatchRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'matchRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$matchRepositoryHash();

  @$internal
  @override
  $ProviderElement<MatchRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MatchRepository create(Ref ref) {
    return matchRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MatchRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MatchRepository>(value),
    );
  }
}

String _$matchRepositoryHash() => r'9907af557432ac8e51f83fa9e128fe925e7518b0';

@ProviderFor(matchesForUser)
final matchesForUserProvider = MatchesForUserFamily._();

final class MatchesForUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Match>>,
          List<Match>,
          Stream<List<Match>>
        >
    with $FutureModifier<List<Match>>, $StreamProvider<List<Match>> {
  MatchesForUserProvider._({
    required MatchesForUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'matchesForUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$matchesForUserHash();

  @override
  String toString() {
    return r'matchesForUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<Match>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Match>> create(Ref ref) {
    final argument = this.argument as String;
    return matchesForUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MatchesForUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$matchesForUserHash() => r'265881936bfd22d0e5337d8341ff9d884bdb716e';

final class MatchesForUserFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<Match>>, String> {
  MatchesForUserFamily._()
    : super(
        retry: null,
        name: r'matchesForUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MatchesForUserProvider call(String uid) =>
      MatchesForUserProvider._(argument: uid, from: this);

  @override
  String toString() => r'matchesForUserProvider';
}

@ProviderFor(totalUnreadCount)
final totalUnreadCountProvider = TotalUnreadCountFamily._();

final class TotalUnreadCountProvider extends $FunctionalProvider<int, int, int>
    with $Provider<int> {
  TotalUnreadCountProvider._({
    required TotalUnreadCountFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'totalUnreadCountProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$totalUnreadCountHash();

  @override
  String toString() {
    return r'totalUnreadCountProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $ProviderElement<int> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  int create(Ref ref) {
    final argument = this.argument as String;
    return totalUnreadCount(ref, argument);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TotalUnreadCountProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$totalUnreadCountHash() => r'3920e412c5f407a81907cd92c0b63559c55e2e7d';

final class TotalUnreadCountFamily extends $Family
    with $FunctionalFamilyOverride<int, String> {
  TotalUnreadCountFamily._()
    : super(
        retry: null,
        name: r'totalUnreadCountProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TotalUnreadCountProvider call(String uid) =>
      TotalUnreadCountProvider._(argument: uid, from: this);

  @override
  String toString() => r'totalUnreadCountProvider';
}
