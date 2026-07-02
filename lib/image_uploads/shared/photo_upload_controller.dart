import 'dart:typed_data';

import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/image_uploads/domain/photo_upload_state.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo.dart';
import 'package:catch_dating_app/user_profile/domain/profile_photo_policy.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_upload_controller.g.dart';

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
@riverpod
class PhotoUploadController extends _$PhotoUploadController {
  static final uploadPhotoMutation = Mutation<void>();

  Future<void> _pendingPhotoWrite = Future.value();
  bool _isPickingImage = false;

  @override
  PhotoUploadState build() => (loadingIndices: {}, uploadError: null);

  Future<void> pickAndUpload(int index) async {
    RangeError.checkValueInInterval(
      index,
      0,
      maximumProfilePhotoCount - 1,
      'index',
    );
    if (_isPickingImage || state.loadingIndices.contains(index)) return;

    final repo = ref.read(imageUploadRepositoryProvider);
    final userProfileRepository = ref.read(userProfileRepositoryProvider);

    _markUploading(index);

    final XFile? photo;
    try {
      photo = await _pickImage(repo);
    } catch (e, st) {
      if (!ref.mounted) return;
      _failUploading(index, e, st);
      return;
    }
    if (!ref.mounted) return;
    if (photo == null) {
      _finishUploading(index);
      return;
    }

    try {
      final uid = requireSignedInUid(ref, action: 'upload photos');
      final upload = await repo.uploadUserProfilePhoto(
        uid: uid,
        index: index,
        image: photo,
      );
      await _persistUploadedPhoto(
        userProfileRepository: userProfileRepository,
        uid: uid,
        index: index,
        upload: upload,
      );

      if (!ref.mounted) return;
      _finishUploading(index);
    } catch (e, st) {
      if (!ref.mounted) return;
      _failUploading(index, e, st);
    }
  }

  Future<XFile?> pickPhoto() async {
    if (_isPickingImage) return null;
    return _pickImage(ref.read(imageUploadRepositoryProvider));
  }

  Future<void> savePhoto({
    required int index,
    Uint8List? imageBytes,
    PhotoPromptAnswer? prompt,
  }) async {
    RangeError.checkValueInInterval(
      index,
      0,
      maximumProfilePhotoCount - 1,
      'index',
    );
    if (imageBytes == null) {
      await _persistPhotoPrompt(index: index, prompt: prompt);
      return;
    }
    final image = XFile.fromData(
      imageBytes,
      name:
          'profile_photo_${index}_${DateTime.now().millisecondsSinceEpoch}.png',
      mimeType: 'image/png',
    );

    if (state.loadingIndices.contains(index)) return;
    _markUploading(index);
    try {
      final uid = requireSignedInUid(ref, action: 'upload photos');
      final upload = await ref
          .read(imageUploadRepositoryProvider)
          .uploadUserProfilePhoto(uid: uid, index: index, image: image);
      await _persistUploadedPhoto(
        userProfileRepository: ref.read(userProfileRepositoryProvider),
        uid: uid,
        index: index,
        upload: upload,
        prompt: prompt,
      );

      if (!ref.mounted) return;
      _finishUploading(index);
    } catch (e, st) {
      if (!ref.mounted) return;
      _failUploading(index, e, st);
    }
  }

  Future<void> deletePhoto(int index) {
    RangeError.checkValueInInterval(
      index,
      0,
      maximumProfilePhotoCount - 1,
      'index',
    );
    return _serializePhotoWrite(() async {
      final uid = requireSignedInUid(ref, action: 'delete profile photo');
      final userProfileRepository = ref.read(userProfileRepositoryProvider);
      final latestUser = await userProfileRepository.fetchUserProfile(uid: uid);
      if (latestUser == null) throw const DocumentNotFoundException('users');
      final basePhotos = latestUser.effectiveProfilePhotos;
      if (latestUser.profileComplete &&
          basePhotos.length <= minimumProfilePhotoCount) {
        throw StateError(
          'Keep at least $minimumProfilePhotoCount profile photos.',
        );
      }
      final updatedPhotos = removeProfilePhotoAtPosition(
        profilePhotos: basePhotos,
        position: index,
      );
      await userProfileRepository.updateProfilePhotos(
        uid: uid,
        profilePhotos: updatedPhotos,
      );
    });
  }

  Future<void> reorderPhoto({required int fromIndex, required int toIndex}) {
    RangeError.checkValueInInterval(
      fromIndex,
      0,
      maximumProfilePhotoCount - 1,
      'fromIndex',
    );
    RangeError.checkValueInInterval(
      toIndex,
      0,
      maximumProfilePhotoCount - 1,
      'toIndex',
    );
    return _serializePhotoWrite(() async {
      final uid = requireSignedInUid(ref, action: 'reorder profile photos');
      final userProfileRepository = ref.read(userProfileRepositoryProvider);
      final latestUser = await userProfileRepository.fetchUserProfile(uid: uid);
      if (latestUser == null) throw const DocumentNotFoundException('users');
      final updatedPhotos = reorderProfilePhoto(
        profilePhotos: latestUser.effectiveProfilePhotos,
        fromPosition: fromIndex,
        toPosition: toIndex,
      );
      await userProfileRepository.updateProfilePhotos(
        uid: uid,
        profilePhotos: updatedPhotos,
      );
    });
  }

  Future<XFile?> _pickImage(ImageUploadRepository repo) async {
    _isPickingImage = true;
    try {
      return await repo.pickImage();
    } finally {
      _isPickingImage = false;
    }
  }

  void _markUploading(int index) {
    state = (
      loadingIndices: {...state.loadingIndices, index},
      uploadError: null,
    );
  }

  void _finishUploading(int index) {
    state = (
      loadingIndices: state.loadingIndices.difference({index}),
      uploadError: null,
    );
  }

  void _failUploading(int index, Object error, [StackTrace? st]) {
    ref
        .read(errorLoggerProvider)
        .logAppException(
          normalizeBackendError(
            error,
            stackTrace: st,
            context: const BackendErrorContext(
              service: BackendService.local,
              action: 'upload profile photo',
              resource: 'photo_upload_controller',
            ),
          ),
        );
    state = (
      loadingIndices: state.loadingIndices.difference({index}),
      uploadError: error,
    );
  }

  Future<void> _persistUploadedPhoto({
    required UserProfileRepository userProfileRepository,
    required String uid,
    required int index,
    required UploadedImage upload,
    PhotoPromptAnswer? prompt,
  }) {
    return _serializePhotoWrite(() async {
      final latestUser = await userProfileRepository.fetchUserProfile(uid: uid);
      if (latestUser == null) throw const DocumentNotFoundException('users');
      final basePhotos = latestUser.effectiveProfilePhotos;
      final existingPrompt = basePhotos
          .where((photo) => photo.position == index)
          .firstOrNull
          ?.prompt;
      final uploadedPhoto = ProfilePhoto.uploaded(
        position: index,
        url: upload.url,
        storagePath: upload.storagePath,
        prompt: prompt ?? existingPrompt,
      );
      final replacedPhotos = replaceProfilePhotoAtPosition(
        profilePhotos: basePhotos,
        position: index,
        photo: uploadedPhoto,
      );
      final updatedPhotos = ensureUniquePhotoPrompts(
        replacedPhotos,
        preferredPosition: index,
      );

      await userProfileRepository.updateProfilePhotos(
        uid: uid,
        profilePhotos: updatedPhotos,
      );
    });
  }

  Future<void> _persistPhotoPrompt({
    required int index,
    required PhotoPromptAnswer? prompt,
  }) {
    return _serializePhotoWrite(() async {
      final uid = requireSignedInUid(ref, action: 'update photo prompt');
      final userProfileRepository = ref.read(userProfileRepositoryProvider);
      final latestUser = await userProfileRepository.fetchUserProfile(uid: uid);
      if (latestUser == null) throw const DocumentNotFoundException('users');
      final updatedPhotos = replaceProfilePhotoPromptAtPosition(
        profilePhotos: latestUser.effectiveProfilePhotos,
        position: index,
        prompt: prompt,
      );
      await userProfileRepository.updateProfilePhotos(
        uid: uid,
        profilePhotos: updatedPhotos,
      );
    });
  }

  Future<T> _serializePhotoWrite<T>(Future<T> Function() operation) {
    final nextWrite = _pendingPhotoWrite.then((_) => operation());
    _pendingPhotoWrite = nextWrite.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {
        ref
            .read(errorLoggerProvider)
            .logAppException(
              normalizeBackendError(
                error,
                stackTrace: stack,
                context: const BackendErrorContext(
                  service: BackendService.local,
                  action: 'serialize photo write',
                  resource: 'photo_upload_controller',
                ),
              ),
            );
      },
    );
    return nextWrite;
  }
}
