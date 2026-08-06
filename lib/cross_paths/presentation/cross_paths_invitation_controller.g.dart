// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cross_paths_invitation_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CrossPathsInvitationController)
final crossPathsInvitationControllerProvider =
    CrossPathsInvitationControllerProvider._();

final class CrossPathsInvitationControllerProvider
    extends
        $AsyncNotifierProvider<
          CrossPathsInvitationController,
          CrossPathsInvitationReceipt?
        > {
  CrossPathsInvitationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'crossPathsInvitationControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$crossPathsInvitationControllerHash();

  @$internal
  @override
  CrossPathsInvitationController create() => CrossPathsInvitationController();
}

String _$crossPathsInvitationControllerHash() =>
    r'fd2d8aeebd4503ea78669921ef373e0614191d91';

abstract class _$CrossPathsInvitationController
    extends $AsyncNotifier<CrossPathsInvitationReceipt?> {
  FutureOr<CrossPathsInvitationReceipt?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<CrossPathsInvitationReceipt?>,
              CrossPathsInvitationReceipt?
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<CrossPathsInvitationReceipt?>,
                CrossPathsInvitationReceipt?
              >,
              AsyncValue<CrossPathsInvitationReceipt?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
