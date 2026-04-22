// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_upload_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PhotoUploadController)
final photoUploadControllerProvider = PhotoUploadControllerProvider._();

final class PhotoUploadControllerProvider
    extends $NotifierProvider<PhotoUploadController, PhotoUploadState> {
  PhotoUploadControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'photoUploadControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$photoUploadControllerHash();

  @$internal
  @override
  PhotoUploadController create() => PhotoUploadController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PhotoUploadState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PhotoUploadState>(value),
    );
  }
}

String _$photoUploadControllerHash() =>
    r'fe78b4235cfdd4d69e7cfbf70d8348c424f078bc';

abstract class _$PhotoUploadController extends $Notifier<PhotoUploadState> {
  PhotoUploadState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PhotoUploadState, PhotoUploadState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PhotoUploadState, PhotoUploadState>,
              PhotoUploadState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
