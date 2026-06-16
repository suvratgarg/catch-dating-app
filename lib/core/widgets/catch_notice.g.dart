// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catch_notice.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(CatchNoticeController)
final catchNoticeControllerProvider = CatchNoticeControllerProvider._();

final class CatchNoticeControllerProvider
    extends $NotifierProvider<CatchNoticeController, CatchNoticeQueue> {
  CatchNoticeControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catchNoticeControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catchNoticeControllerHash();

  @$internal
  @override
  CatchNoticeController create() => CatchNoticeController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatchNoticeQueue value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatchNoticeQueue>(value),
    );
  }
}

String _$catchNoticeControllerHash() =>
    r'ba920e9854a371ee413a433a299e9659273a967a';

abstract class _$CatchNoticeController extends $Notifier<CatchNoticeQueue> {
  CatchNoticeQueue build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<CatchNoticeQueue, CatchNoticeQueue>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<CatchNoticeQueue, CatchNoticeQueue>,
              CatchNoticeQueue,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
