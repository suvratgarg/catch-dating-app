import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_upload_controller.g.dart';

typedef PhotoUploadState = ({Set<int> loadingIndices, Object? uploadError});

@riverpod
class PhotoUploadController extends _$PhotoUploadController {
  Future<void> _pendingPhotoWrite = Future.value();
  bool _isPickingImage = false;

  @override
  PhotoUploadState build() => (loadingIndices: {}, uploadError: null);

  Future<void> pickAndUpload(int index) async {
    if (_isPickingImage || state.loadingIndices.contains(index)) return;

    final repo = ref.read(imageUploadRepositoryProvider);
    final userProfileRepository = ref.read(userProfileRepositoryProvider);

    _markUploading(index);

    final XFile? photo;
    try {
      photo = await _pickImage(repo);
    } catch (e) {
      if (!ref.mounted) return;
      _failUploading(index, e);
      return;
    }
    if (!ref.mounted) return;
    if (photo == null) {
      _finishUploading(index);
      return;
    }

    try {
      final uid = requireSignedInUid(ref, action: 'upload photos');
      final url = await repo.uploadUserPhoto(
        uid: uid,
        index: index,
        image: photo,
      );
      await _persistUploadedPhoto(
        userProfileRepository: userProfileRepository,
        uid: uid,
        index: index,
        url: url,
      );

      if (!ref.mounted) return;
      _finishUploading(index);
    } catch (e) {
      if (!ref.mounted) return;
      _failUploading(index, e);
    }
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

  void _failUploading(int index, Object error) {
    debugPrint('[ERROR] PhotoUploadController._failUploading($index): $error');
    state = (
      loadingIndices: state.loadingIndices.difference({index}),
      uploadError: error,
    );
  }

  Future<void> _persistUploadedPhoto({
    required UserProfileRepository userProfileRepository,
    required String uid,
    required int index,
    required String url,
  }) {
    return _serializePhotoWrite(() async {
      final latestUser = await userProfileRepository.fetchUserProfile(uid: uid);
      final updatedUrls = _replacePhotoUrlAtIndex(
        photoUrls: latestUser?.photoUrls ?? const [],
        index: index,
        url: url,
      );

      await userProfileRepository.updatePhotoUrls(
        uid: uid,
        photoUrls: updatedUrls,
      );
    });
  }

  Future<T> _serializePhotoWrite<T>(Future<T> Function() operation) {
    final nextWrite = _pendingPhotoWrite.then((_) => operation());
    _pendingPhotoWrite = nextWrite.then<void>(
      (_) {},
      onError: (Object error, StackTrace stack) {
        debugPrint('[ERROR] PhotoUploadController._serializePhotoWrite: $error\n$stack');
      },
    );
    return nextWrite;
  }

  static List<String> _replacePhotoUrlAtIndex({
    required List<String> photoUrls,
    required int index,
    required String url,
  }) {
    final updatedUrls = List<String>.from(photoUrls);
    if (index < updatedUrls.length) {
      updatedUrls[index] = url;
    } else {
      updatedUrls.add(url);
    }
    return updatedUrls;
  }
}
