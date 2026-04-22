// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_clubs_list_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RunClubsListController)
final runClubsListControllerProvider = RunClubsListControllerProvider._();

final class RunClubsListControllerProvider
    extends $NotifierProvider<RunClubsListController, void> {
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
    r'052be7e13a0c28c2001dc91b43f4a59fc186411e';

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
