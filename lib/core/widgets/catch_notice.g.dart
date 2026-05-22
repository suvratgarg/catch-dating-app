// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catch_notice.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(AppNoticeController)
final appNoticeControllerProvider = AppNoticeControllerProvider._();

final class AppNoticeControllerProvider
    extends $NotifierProvider<AppNoticeController, AppNoticeQueue> {
  AppNoticeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'appNoticeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$appNoticeControllerHash();

  @$internal
  @override
  AppNoticeController create() => AppNoticeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppNoticeQueue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppNoticeQueue>(value),
    );
  }
}

String _$appNoticeControllerHash() =>
    r'bf5dc9de316249b4ea560a139e43d92d8d9802d6';

abstract class _$AppNoticeController extends $Notifier<AppNoticeQueue> {
  AppNoticeQueue build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AppNoticeQueue, AppNoticeQueue>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppNoticeQueue, AppNoticeQueue>,
              AppNoticeQueue,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
