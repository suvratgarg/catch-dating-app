// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'public_profile_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(publicProfileRepository)
final publicProfileRepositoryProvider = PublicProfileRepositoryProvider._();

final class PublicProfileRepositoryProvider
    extends
        $FunctionalProvider<
          PublicProfileRepository,
          PublicProfileRepository,
          PublicProfileRepository
        >
    with $Provider<PublicProfileRepository> {
  PublicProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publicProfileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publicProfileRepositoryHash();

  @$internal
  @override
  $ProviderElement<PublicProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PublicProfileRepository create(Ref ref) {
    return publicProfileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PublicProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PublicProfileRepository>(value),
    );
  }
}

String _$publicProfileRepositoryHash() =>
    r'76a3733fbfdc6ab8288eaeccfd8e087a9a32cb01';

@ProviderFor(publicProfile)
final publicProfileProvider = PublicProfileFamily._();

final class PublicProfileProvider
    extends
        $FunctionalProvider<
          AsyncValue<PublicProfile?>,
          PublicProfile?,
          Stream<PublicProfile?>
        >
    with $FutureModifier<PublicProfile?>, $StreamProvider<PublicProfile?> {
  PublicProfileProvider._({
    required PublicProfileFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'publicProfileProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$publicProfileHash();

  @override
  String toString() {
    return r'publicProfileProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<PublicProfile?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<PublicProfile?> create(Ref ref) {
    final argument = this.argument as String;
    return publicProfile(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PublicProfileProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$publicProfileHash() => r'3269b75a4655e7d52a1830df8cf9570c05478479';

final class PublicProfileFamily extends $Family
    with $FunctionalFamilyOverride<Stream<PublicProfile?>, String> {
  PublicProfileFamily._()
    : super(
        retry: null,
        name: r'publicProfileProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PublicProfileProvider call(String uid) =>
      PublicProfileProvider._(argument: uid, from: this);

  @override
  String toString() => r'publicProfileProvider';
}
