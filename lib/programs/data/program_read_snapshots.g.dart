// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_read_snapshots.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(programReadSnapshotStore)
final programReadSnapshotStoreProvider = ProgramReadSnapshotStoreProvider._();

final class ProgramReadSnapshotStoreProvider
    extends
        $FunctionalProvider<
          ProgramReadSnapshotStore,
          ProgramReadSnapshotStore,
          ProgramReadSnapshotStore
        >
    with $Provider<ProgramReadSnapshotStore> {
  ProgramReadSnapshotStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programReadSnapshotStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programReadSnapshotStoreHash();

  @$internal
  @override
  $ProviderElement<ProgramReadSnapshotStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProgramReadSnapshotStore create(Ref ref) {
    return programReadSnapshotStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProgramReadSnapshotStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProgramReadSnapshotStore>(value),
    );
  }
}

String _$programReadSnapshotStoreHash() =>
    r'be56da9fcab5847c70368ef10b187215d30dfbe1';
