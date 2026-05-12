import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_upload_repository.g.dart';

enum ImageUploadPurpose { profilePhoto, runClubCover, chatImage }

class ImageUploadPolicy {
  const ImageUploadPolicy({
    required this.maxWidth,
    required this.maxHeight,
    required this.quality,
  });

  final double maxWidth;
  final double maxHeight;
  final int quality;
}

class ImageUploadRepository {
  ImageUploadRepository(this._storage, {ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  static const profilePhotoPolicy = ImageUploadPolicy(
    maxWidth: 1600,
    maxHeight: 2133,
    quality: 85,
  );
  static const runClubCoverPolicy = ImageUploadPolicy(
    maxWidth: 1800,
    maxHeight: 1200,
    quality: 82,
  );
  static const chatImagePolicy = ImageUploadPolicy(
    maxWidth: 1440,
    maxHeight: 1920,
    quality: 78,
  );

  final FirebaseStorage _storage;
  final ImagePicker _picker;

  // ── Picking ───────────────────────────────────────────────────────────────

  Future<XFile?> pickImage({
    ImageUploadPurpose purpose = ImageUploadPurpose.profilePhoto,
    int? imageQuality,
  }) {
    final policy = policyForPurpose(purpose);
    return _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: policy.maxWidth,
      maxHeight: policy.maxHeight,
      imageQuality: imageQuality ?? policy.quality,
      requestFullMetadata: false,
    );
  }

  // ── Generic upload ────────────────────────────────────────────────────────

  /// Uploads [image] to [storagePath] and returns the download URL.
  ///
  /// The extension is derived from the file name and appended to [storagePath],
  /// so pass a path without an extension (e.g. `'users/abc/photos/0_1234'`).
  Future<String> upload({
    required String storagePath,
    required XFile image,
  }) async {
    return withBackendErrorContext(
      () async {
        final bytes = await image.readAsBytes();
        final ext = _normalizedExt(image.name);
        final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
        final ref = _storage.ref('$storagePath.$ext');
        await ref.putData(bytes, SettableMetadata(contentType: contentType));
        return ref.getDownloadURL();
      },
      context: BackendErrorContext(
        service: BackendService.storage,
        action: 'upload image',
        resource: _resourceForStoragePath(storagePath),
      ),
    );
  }

  // ── Path helpers ──────────────────────────────────────────────────────────

  Future<String> uploadUserPhoto({
    required String uid,
    required int index,
    required XFile image,
  }) => upload(
    storagePath:
        'users/$uid/photos/${index}_${DateTime.now().millisecondsSinceEpoch}',
    image: image,
  );

  Future<String> uploadRunClubCover({
    required String clubId,
    required XFile image,
  }) => upload(storagePath: 'runClubs/$clubId/cover', image: image);

  Future<String> uploadChatImage({
    required String matchId,
    required String messageId,
    required XFile image,
  }) => upload(
    storagePath:
        'matches/$matchId/images/${messageId}_'
        '${DateTime.now().millisecondsSinceEpoch}',
    image: image,
  );

  // ── Internal ──────────────────────────────────────────────────────────────

  static ImageUploadPolicy policyForPurpose(ImageUploadPurpose purpose) {
    return switch (purpose) {
      ImageUploadPurpose.profilePhoto => profilePhotoPolicy,
      ImageUploadPurpose.runClubCover => runClubCoverPolicy,
      ImageUploadPurpose.chatImage => chatImagePolicy,
    };
  }

  static String _ext(String filename) {
    final dot = filename.lastIndexOf('.');
    return dot != -1 ? filename.substring(dot + 1).toLowerCase() : 'jpg';
  }

  static String _normalizedExt(String filename) =>
      _ext(filename) == 'png' ? 'png' : 'jpg';

  static String _resourceForStoragePath(String storagePath) {
    if (storagePath.startsWith('users/')) return 'profile_photos';
    if (storagePath.startsWith('runClubs/')) return 'run_club_covers';
    if (storagePath.startsWith('matches/')) return 'chat_images';
    return 'images';
  }
}

@riverpod
ImageUploadRepository imageUploadRepository(Ref ref) =>
    ImageUploadRepository(ref.watch(firebaseStorageProvider));
