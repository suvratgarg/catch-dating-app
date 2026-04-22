import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_upload_controller.g.dart';

typedef PhotoUploadState = ({Set<int> loadingIndices, Object? uploadError});

@riverpod
class PhotoUploadController extends _$PhotoUploadController {
  Future<void> _pendingPhotoWrite = Future.value();

  @override
  PhotoUploadState build() => (loadingIndices: {}, uploadError: null);

  Future<void> pickAndUpload(int index) async {
    final repo = ref.read(imageUploadRepositoryProvider);
    final userProfileRepository = ref.read(userProfileRepositoryProvider);

    final photo = await repo.pickImage();
    if (photo == null || !ref.mounted) return;

    _markUploading(index);
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
      onError: (error, stackTrace) {},
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
