// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_draft_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runDraftRepository)
final runDraftRepositoryProvider = RunDraftRepositoryProvider._();

final class RunDraftRepositoryProvider
    extends
        $FunctionalProvider<
          RunDraftRepository,
          RunDraftRepository,
          RunDraftRepository
        >
    with $Provider<RunDraftRepository> {
  RunDraftRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runDraftRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runDraftRepositoryHash();

  @$internal
  @override
  $ProviderElement<RunDraftRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RunDraftRepository create(Ref ref) {
    return runDraftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunDraftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunDraftRepository>(value),
    );
  }
}

String _$runDraftRepositoryHash() =>
    r'4bd07d3d0b04366803e48e403a5beaf9852bf1e2';

@ProviderFor(clubRunDrafts)
final clubRunDraftsProvider = ClubRunDraftsFamily._();

final class ClubRunDraftsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RunDraft>>,
          List<RunDraft>,
          FutureOr<List<RunDraft>>
        >
    with $FutureModifier<List<RunDraft>>, $FutureProvider<List<RunDraft>> {
  ClubRunDraftsProvider._({
    required ClubRunDraftsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'clubRunDraftsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$clubRunDraftsHash();

  @override
  String toString() {
    return r'clubRunDraftsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RunDraft>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RunDraft>> create(Ref ref) {
    final argument = this.argument as String;
    return clubRunDrafts(ref, runClubId: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ClubRunDraftsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$clubRunDraftsHash() => r'1cfeb51a2602c164be3eb7643cfffa1d194f943c';

final class ClubRunDraftsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RunDraft>>, String> {
  ClubRunDraftsFamily._()
    : super(
        retry: null,
        name: r'clubRunDraftsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClubRunDraftsProvider call({required String runClubId}) =>
      ClubRunDraftsProvider._(argument: runClubId, from: this);

  @override
  String toString() => r'clubRunDraftsProvider';
}
