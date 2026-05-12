// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_club_draft_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(runClubDraftRepository)
final runClubDraftRepositoryProvider = RunClubDraftRepositoryProvider._();

final class RunClubDraftRepositoryProvider
    extends
        $FunctionalProvider<
          RunClubDraftRepository,
          RunClubDraftRepository,
          RunClubDraftRepository
        >
    with $Provider<RunClubDraftRepository> {
  RunClubDraftRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runClubDraftRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runClubDraftRepositoryHash();

  @$internal
  @override
  $ProviderElement<RunClubDraftRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RunClubDraftRepository create(Ref ref) {
    return runClubDraftRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RunClubDraftRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RunClubDraftRepository>(value),
    );
  }
}

String _$runClubDraftRepositoryHash() =>
    r'6a53f725e325a1e3f88c794751927335291fdfd9';

@ProviderFor(runClubDraft)
final runClubDraftProvider = RunClubDraftProvider._();

final class RunClubDraftProvider
    extends
        $FunctionalProvider<
          AsyncValue<RunClubDraft?>,
          RunClubDraft?,
          FutureOr<RunClubDraft?>
        >
    with $FutureModifier<RunClubDraft?>, $FutureProvider<RunClubDraft?> {
  RunClubDraftProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runClubDraftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runClubDraftHash();

  @$internal
  @override
  $FutureProviderElement<RunClubDraft?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RunClubDraft?> create(Ref ref) {
    return runClubDraft(ref);
  }
}

String _$runClubDraftHash() => r'9b9e47caaee004a9e3e6af8494914d99036e4f1b';
