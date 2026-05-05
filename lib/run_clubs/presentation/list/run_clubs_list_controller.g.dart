// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_clubs_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern A: Action controller + static Mutations**
///
/// Handles the join-club action from the club list screen.
/// [joinMutation] tracks the async join lifecycle so the list tile can
/// show a loading indicator while the operation is in flight.

@ProviderFor(RunClubsListController)
final runClubsListControllerProvider = RunClubsListControllerProvider._();

/// **Pattern A: Action controller + static Mutations**
///
/// Handles the join-club action from the club list screen.
/// [joinMutation] tracks the async join lifecycle so the list tile can
/// show a loading indicator while the operation is in flight.
final class RunClubsListControllerProvider
    extends $NotifierProvider<RunClubsListController, void> {
  /// **Pattern A: Action controller + static Mutations**
  ///
  /// Handles the join-club action from the club list screen.
  /// [joinMutation] tracks the async join lifecycle so the list tile can
  /// show a loading indicator while the operation is in flight.
  RunClubsListControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runClubsListControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runClubsListControllerHash();

  @$internal
  @override
  RunClubsListController create() => RunClubsListController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$runClubsListControllerHash() =>
    r'fe5e73ce7f7a26a6823152b774e4440143c16505';

/// **Pattern A: Action controller + static Mutations**
///
/// Handles the join-club action from the club list screen.
/// [joinMutation] tracks the async join lifecycle so the list tile can
/// show a loading indicator while the operation is in flight.

abstract class _$RunClubsListController extends $Notifier<void> {
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
