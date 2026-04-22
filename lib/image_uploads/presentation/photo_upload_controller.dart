import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'photo_upload_controller.g.dart';

typedef PhotoUploadState = ({Set<int> loadingIndices, Object? uploadError});

@riverpod
class PhotoUploadController extends _$PhotoUploadController {
  @override
  PhotoUploadState build() => (loadingIndices: {}, uploadError: null);

  Future<void> pickAndUpload(int index) async {
    final repo = ref.read(imageUploadRepositoryProvider);

    final photo = await repo.pickImage();
    if (photo == null) return;

    state = (loadingIndices: {...state.loadingIndices, index}, uploadError: null);
    try {
      final uid = ref.read(uidProvider).asData?.value;
      if (uid == null || uid.isEmpty) {
        throw StateError('Must be signed in to upload photos.');
      }
      final currentUrls = List<String>.from(
        ref.read(appUserStreamProvider).asData?.value?.photoUrls ?? [],
      );

      final url = await repo.uploadUserPhoto(uid: uid, index: index, image: photo);

      if (index < currentUrls.length) {
        currentUrls[index] = url;
      } else {
        currentUrls.add(url);
      }

      await ref
          .read(appUserRepositoryProvider)
          .updatePhotoUrls(uid: uid, photoUrls: currentUrls);

      state = (
        loadingIndices: state.loadingIndices.difference({index}),
        uploadError: null,
      );
    } catch (e) {
      state = (
        loadingIndices: state.loadingIndices.difference({index}),
        uploadError: e,
      );
    }
  }
}
