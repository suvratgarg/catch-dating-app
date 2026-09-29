// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'program_workspace_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Organizer workspace mutations for the program screens. Widgets go through
/// this controller rather than reaching into repository providers directly.

@ProviderFor(ProgramWorkspaceController)
final programWorkspaceControllerProvider =
    ProgramWorkspaceControllerProvider._();

/// Organizer workspace mutations for the program screens. Widgets go through
/// this controller rather than reaching into repository providers directly.
final class ProgramWorkspaceControllerProvider
    extends $NotifierProvider<ProgramWorkspaceController, void> {
  /// Organizer workspace mutations for the program screens. Widgets go through
  /// this controller rather than reaching into repository providers directly.
  ProgramWorkspaceControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'programWorkspaceControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$programWorkspaceControllerHash();

  @$internal
  @override
  ProgramWorkspaceController create() => ProgramWorkspaceController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$programWorkspaceControllerHash() =>
    r'bd18acc265523b506acbbae6b50807dafd20ab58';

/// Organizer workspace mutations for the program screens. Widgets go through
/// this controller rather than reaching into repository providers directly.

abstract class _$ProgramWorkspaceController extends $Notifier<void> {
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
