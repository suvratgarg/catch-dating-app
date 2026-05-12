// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'photo_upload_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// **Pattern B: State controller with record state + Mutation**
///
/// Tracks per-index upload loading state via a Dart record
/// `({Set<int> loadingIndices, Object? uploadError})` and serializes
/// Firestore writes through a `_pendingPhotoWrite` chain to prevent races.
/// [uploadPhotoMutation] gives the UI a standard Mutation lifecycle hook
/// for the overall upload operation.
///
/// **When to use this pattern:** Multi-slot upload UIs where individual
/// slots have independent loading states and writes must be serialized to
/// avoid Firestore document races.

@ProviderFor(PhotoUploadController)
final photoUploadControllerProvider = PhotoUploadControllerProvider._();

/// **Pattern B: State controller with record state + Mutation**
///
/// Tracks per-index upload loading state via a Dart record
/// `({Set<int> loadingIndices, Object? uploadError})` and serializes
/// Firestore writes through a `_pendingPhotoWrite` chain to prevent races.
/// [uploadPhotoMutation] gives the UI a standard Mutation lifecycle hook
/// for the overall upload operation.
///
/// **When to use this pattern:** Multi-slot upload UIs where individual
/// slots have independent loading states and writes must be serialized to
/// avoid Firestore document races.
final class PhotoUploadControllerProvider
    extends $NotifierProvider<PhotoUploadController, PhotoUploadState> {
  /// **Pattern B: State controller with record state + Mutation**
  ///
  /// Tracks per-index upload loading state via a Dart record
  /// `({Set<int> loadingIndices, Object? uploadError})` and serializes
  /// Firestore writes through a `_pendingPhotoWrite` chain to prevent races.
  /// [uploadPhotoMutation] gives the UI a standard Mutation lifecycle hook
  /// for the overall upload operation.
  ///
  /// **When to use this pattern:** Multi-slot upload UIs where individual
  /// slots have independent loading states and writes must be serialized to
  /// avoid Firestore document races.
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
    r'0d6142fc3bc3944b797d96b3cdb5f775889bef98';

/// **Pattern B: State controller with record state + Mutation**
///
/// Tracks per-index upload loading state via a Dart record
/// `({Set<int> loadingIndices, Object? uploadError})` and serializes
/// Firestore writes through a `_pendingPhotoWrite` chain to prevent races.
/// [uploadPhotoMutation] gives the UI a standard Mutation lifecycle hook
/// for the overall upload operation.
///
/// **When to use this pattern:** Multi-slot upload UIs where individual
/// slots have independent loading states and writes must be serialized to
/// avoid Firestore document races.

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
