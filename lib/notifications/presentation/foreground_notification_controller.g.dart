// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'foreground_notification_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ForegroundNotificationController)
final foregroundNotificationControllerProvider =
    ForegroundNotificationControllerProvider._();

final class ForegroundNotificationControllerProvider
    extends
        $NotifierProvider<
          ForegroundNotificationController,
          ForegroundNotification?
        > {
  ForegroundNotificationControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'foregroundNotificationControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$foregroundNotificationControllerHash();

  @$internal
  @override
  ForegroundNotificationController create() =>
      ForegroundNotificationController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ForegroundNotification? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ForegroundNotification?>(value),
    );
  }
}

String _$foregroundNotificationControllerHash() =>
    r'd1e2e8a4cacf14019813579a9bdbe939d173631a';

abstract class _$ForegroundNotificationController
    extends $Notifier<ForegroundNotification?> {
  ForegroundNotification? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<ForegroundNotification?, ForegroundNotification?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ForegroundNotification?, ForegroundNotification?>,
              ForegroundNotification?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
