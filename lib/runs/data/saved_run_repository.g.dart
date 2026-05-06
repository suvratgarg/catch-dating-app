// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_run_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(savedRunRepository)
final savedRunRepositoryProvider = SavedRunRepositoryProvider._();

final class SavedRunRepositoryProvider
    extends
        $FunctionalProvider<
          SavedRunRepository,
          SavedRunRepository,
          SavedRunRepository
        >
    with $Provider<SavedRunRepository> {
  SavedRunRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedRunRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedRunRepositoryHash();

  @$internal
  @override
  $ProviderElement<SavedRunRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SavedRunRepository create(Ref ref) {
    return savedRunRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SavedRunRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SavedRunRepository>(value),
    );
  }
}

String _$savedRunRepositoryHash() =>
    r'e1fe6dfbfc41f1b0741af9dcbd9eca5738a00c2e';

@ProviderFor(watchSavedRunsForUser)
final watchSavedRunsForUserProvider = WatchSavedRunsForUserFamily._();

final class WatchSavedRunsForUserProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<SavedRun>>,
          List<SavedRun>,
          Stream<List<SavedRun>>
        >
    with $FutureModifier<List<SavedRun>>, $StreamProvider<List<SavedRun>> {
  WatchSavedRunsForUserProvider._({
    required WatchSavedRunsForUserFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'watchSavedRunsForUserProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchSavedRunsForUserHash();

  @override
  String toString() {
    return r'watchSavedRunsForUserProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<SavedRun>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<SavedRun>> create(Ref ref) {
    final argument = this.argument as String;
    return watchSavedRunsForUser(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchSavedRunsForUserProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchSavedRunsForUserHash() =>
    r'40b30bbd4209d07d00179544cb51a9c55dafdf27';

final class WatchSavedRunsForUserFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<SavedRun>>, String> {
  WatchSavedRunsForUserFamily._()
    : super(
        retry: null,
        name: r'watchSavedRunsForUserProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchSavedRunsForUserProvider call(String uid) =>
      WatchSavedRunsForUserProvider._(argument: uid, from: this);

  @override
  String toString() => r'watchSavedRunsForUserProvider';
}

@ProviderFor(watchSavedRun)
final watchSavedRunProvider = WatchSavedRunFamily._();

final class WatchSavedRunProvider
    extends
        $FunctionalProvider<AsyncValue<SavedRun?>, SavedRun?, Stream<SavedRun?>>
    with $FutureModifier<SavedRun?>, $StreamProvider<SavedRun?> {
  WatchSavedRunProvider._({
    required WatchSavedRunFamily super.from,
    required (String, String) super.argument,
  }) : super(
         retry: null,
         name: r'watchSavedRunProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$watchSavedRunHash();

  @override
  String toString() {
    return r'watchSavedRunProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<SavedRun?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<SavedRun?> create(Ref ref) {
    final argument = this.argument as (String, String);
    return watchSavedRun(ref, argument.$1, argument.$2);
  }

  @override
  bool operator ==(Object other) {
    return other is WatchSavedRunProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$watchSavedRunHash() => r'95947aa70dc1fbe301621fab645064548349a017';

final class WatchSavedRunFamily extends $Family
    with $FunctionalFamilyOverride<Stream<SavedRun?>, (String, String)> {
  WatchSavedRunFamily._()
    : super(
        retry: null,
        name: r'watchSavedRunProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WatchSavedRunProvider call(String uid, String runId) =>
      WatchSavedRunProvider._(argument: (uid, runId), from: this);

  @override
  String toString() => r'watchSavedRunProvider';
}
