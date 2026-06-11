// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_club_draft_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Owns local create-club draft persistence. The screen owns text
/// controllers and restoration because those are UI mechanics.

@ProviderFor(CreateClubDraftController)
final createClubDraftControllerProvider = CreateClubDraftControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Owns local create-club draft persistence. The screen owns text
/// controllers and restoration because those are UI mechanics.
final class CreateClubDraftControllerProvider
    extends $NotifierProvider<CreateClubDraftController, void> {
  /// **Pattern A: Action controller + static Mutations**
  ///
  /// Owns local create-club draft persistence. The screen owns text
  /// controllers and restoration because those are UI mechanics.
  CreateClubDraftControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createClubDraftControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createClubDraftControllerHash();

  @$internal
  @override
  CreateClubDraftController create() => CreateClubDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$createClubDraftControllerHash() =>
    r'5428374e56c3f1be5dbc05c6adc1332c4715bb30';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns local create-club draft persistence. The screen owns text
/// controllers and restoration because those are UI mechanics.

abstract class _$CreateClubDraftController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
