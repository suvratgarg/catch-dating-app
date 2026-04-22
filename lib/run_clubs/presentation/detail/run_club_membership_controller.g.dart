// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_club_membership_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RunClubMembershipController)
final runClubMembershipControllerProvider =
    RunClubMembershipControllerProvider._();

final class RunClubMembershipControllerProvider
    extends $NotifierProvider<RunClubMembershipController, void> {
  RunClubMembershipControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'runClubMembershipControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$runClubMembershipControllerHash();

  @$internal
  @override
  RunClubMembershipController create() => RunClubMembershipController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$runClubMembershipControllerHash() =>
    r'13ca2af8d0460e50f8c45f048de74f2a252f5d71';

abstract class _$RunClubMembershipController extends $Notifier<void> {
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
