// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'launch_access_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LaunchAccessController)
final launchAccessControllerProvider = LaunchAccessControllerProvider._();

final class LaunchAccessControllerProvider
    extends
        $NotifierProvider<
          LaunchAccessController,
          LaunchAccessApplicationDraft
        > {
  LaunchAccessControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'launchAccessControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$launchAccessControllerHash();

  @$internal
  @override
  LaunchAccessController create() => LaunchAccessController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LaunchAccessApplicationDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LaunchAccessApplicationDraft>(value),
    );
  }
}

String _$launchAccessControllerHash() =>
    r'6446fe40a6ab2774cd13d48802d7c6eb0fb13470';

abstract class _$LaunchAccessController
    extends $Notifier<LaunchAccessApplicationDraft> {
  LaunchAccessApplicationDraft build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<LaunchAccessApplicationDraft, LaunchAccessApplicationDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                LaunchAccessApplicationDraft,
                LaunchAccessApplicationDraft
              >,
              LaunchAccessApplicationDraft,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
