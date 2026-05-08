// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_run_club_draft_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Owns local create-run-club draft persistence. The screen owns text
/// controllers and restoration because those are UI mechanics.

@ProviderFor(CreateRunClubDraftController)
final createRunClubDraftControllerProvider =
    CreateRunClubDraftControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Owns local create-run-club draft persistence. The screen owns text
/// controllers and restoration because those are UI mechanics.
final class CreateRunClubDraftControllerProvider
    extends $NotifierProvider<CreateRunClubDraftController, void> {
  /// **Pattern A: Action controller + static Mutations**
  ///
  /// Owns local create-run-club draft persistence. The screen owns text
  /// controllers and restoration because those are UI mechanics.
  CreateRunClubDraftControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createRunClubDraftControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createRunClubDraftControllerHash();

  @$internal
  @override
  CreateRunClubDraftController create() => CreateRunClubDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$createRunClubDraftControllerHash() =>
    r'618178e60010f2dd836b4f36ad370143dc8438c3';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns local create-run-club draft persistence. The screen owns text
/// controllers and restoration because those are UI mechanics.

abstract class _$CreateRunClubDraftController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
