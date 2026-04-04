// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_photos_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(UploadPhotosController)
final uploadPhotosControllerProvider = UploadPhotosControllerProvider._();

final class UploadPhotosControllerProvider
    extends $NotifierProvider<UploadPhotosController, void> {
  UploadPhotosControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'uploadPhotosControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$uploadPhotosControllerHash();

  @$internal
  @override
  UploadPhotosController create() => UploadPhotosController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$uploadPhotosControllerHash() =>
    r'9a2a5c5542c3f58c0d569d13cf02e5599da9d2e8';

abstract class _$UploadPhotosController extends $Notifier<void> {
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
