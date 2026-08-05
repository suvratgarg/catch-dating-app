// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cross_paths_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(crossPathsRepository)
final crossPathsRepositoryProvider = CrossPathsRepositoryProvider._();

final class CrossPathsRepositoryProvider
    extends
        $FunctionalProvider<
          CrossPathsRepository,
          CrossPathsRepository,
          CrossPathsRepository
        >
    with $Provider<CrossPathsRepository> {
  CrossPathsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crossPathsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crossPathsRepositoryHash();

  @$internal
  @override
  $ProviderElement<CrossPathsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CrossPathsRepository create(Ref ref) {
    return crossPathsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CrossPathsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CrossPathsRepository>(value),
    );
  }
}

String _$crossPathsRepositoryHash() =>
    r'551e8ce1b7e0965301a673ba36ca48badadba4a8';

@ProviderFor(watchCrossPathsEventConsent)
final watchCrossPathsEventConsentProvider =
    WatchCrossPathsEventConsentFamily._();

final class WatchCrossPathsEventConsentProvider
    extends
        $FunctionalProvider<
          AsyncValue<CrossPathsEventConsent?>,
          CrossPathsEventConsent?,
          Stream<CrossPathsEventConsent?>
        >
    with
        $FutureModifier<CrossPathsEventConsent?>,
        $StreamProvider<CrossPathsEventConsent?> {
  WatchCrossPathsEventConsentProvider._({
    required WatchCrossPathsEventConsentFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'watchCrossPathsEventConsentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchCrossPathsEventConsentHash();

  @override
  String toString() {
    return r'watchCrossPathsEventConsentProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<CrossPathsEventConsent?> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<CrossPathsEventConsent?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return watchCrossPathsEventConsent(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchCrossPathsEventConsentProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchCrossPathsEventConsentHash() =>
    r'2d053504b038f8294cc95dadb6d156a625ec0a7e';

final class WatchCrossPathsEventConsentFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<CrossPathsEventConsent?>,
          (String, String)
        > {
  WatchCrossPathsEventConsentFamily._()
    : super(
        retry: null,
        name: r'watchCrossPathsEventConsentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchCrossPathsEventConsentProvider call(String eventId, String uid) =>
      WatchCrossPathsEventConsentProvider._(
        argument: (eventId, uid),
        from: this,
      );

  @override
  String toString() => r'watchCrossPathsEventConsentProvider';
}
