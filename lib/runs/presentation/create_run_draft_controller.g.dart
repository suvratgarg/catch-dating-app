// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_run_draft_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Owns create-run draft persistence. The create-run screen still owns form
/// field controllers and draft restoration because those are UI mechanics.

@ProviderFor(CreateRunDraftController)
final createRunDraftControllerProvider = CreateRunDraftControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Owns create-run draft persistence. The create-run screen still owns form
/// field controllers and draft restoration because those are UI mechanics.
final class CreateRunDraftControllerProvider
    extends $NotifierProvider<CreateRunDraftController, void> {
  /// **Pattern A: Action controller + static Mutations**
  ///
  /// Owns create-run draft persistence. The create-run screen still owns form
  /// field controllers and draft restoration because those are UI mechanics.
  CreateRunDraftControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createRunDraftControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createRunDraftControllerHash();

  @$internal
  @override
  CreateRunDraftController create() => CreateRunDraftController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$createRunDraftControllerHash() =>
    r'85d0cd0c9cbef9d82fdf7e0160f39c6e98fb035b';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns create-run draft persistence. The create-run screen still owns form
/// field controllers and draft restoration because those are UI mechanics.

abstract class _$CreateRunDraftController extends $Notifier<void> {
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
