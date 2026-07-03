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
        isAutoDispose: true,
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
    r'864094c0487be7a8140d98eb12428578da429056';

abstract class _$LaunchAccessController
    extends $Notifier<LaunchAccessApplicationDraft> {
  LaunchAccessApplicationDraft build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
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
    return element.handleCreate(ref, build);
  }
}
