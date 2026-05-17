import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_upload_repository.g.dart';

enum ImageUploadPurpose { profilePhoto, clubCover, eventPhoto, chatImage }

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

class UploadedImage {
  const UploadedImage({required this.url, required this.storagePath});

  final String url;
  final String storagePath;
}

class ImageUploadRepository {
  ImageUploadRepository(this._storage, {ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  static const profilePhotoPolicy = ImageUploadPolicy(
    maxWidth: 1600,
    maxHeight: 2133,
    quality: 85,
  );
  static const clubCoverPolicy = ImageUploadPolicy(
    maxWidth: 1800,
    maxHeight: 1200,
    quality: 82,
  );
  static const eventPhotoPolicy = ImageUploadPolicy(
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
  }) async =>
      (await uploadWithMetadata(storagePath: storagePath, image: image)).url;

  /// Uploads [image] and returns both the download URL and final Storage path.
  Future<UploadedImage> uploadWithMetadata({
    required String storagePath,
    required XFile image,
  }) async {
    return withBackendErrorContext(
      () async {
        final bytes = await image.readAsBytes();
        final ext = _normalizedExt(image.name);
        final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
        final finalStoragePath = '$storagePath.$ext';
        final ref = _storage.ref(finalStoragePath);
        await ref.putData(bytes, SettableMetadata(contentType: contentType));
        final url = await ref.getDownloadURL();
        return UploadedImage(url: url, storagePath: finalStoragePath);
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

  Future<UploadedImage> uploadUserProfilePhoto({
    required String uid,
    required int index,
    required XFile image,
  }) {
    final millis = DateTime.now().millisecondsSinceEpoch;
    return uploadWithMetadata(
      storagePath: 'users/$uid/photos/${index}_$millis',
      image: image,
    );
  }

  Future<String> uploadClubCover({
    required String clubId,
    required XFile image,
  }) => upload(storagePath: 'clubs/$clubId/cover', image: image);

  Future<String> uploadEventPhoto({
    required String clubId,
    required String eventId,
    required XFile image,
  }) => upload(
    storagePath: 'clubs/$clubId/run_${eventId}_photo',
    image: image,
  );

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
      ImageUploadPurpose.clubCover => clubCoverPolicy,
      ImageUploadPurpose.eventPhoto => eventPhotoPolicy,
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
    final storageName = storagePath.split('/').last;
    if (storagePath.startsWith('clubs/') &&
        storageName.startsWith('run_') &&
        storageName.endsWith('_photo')) {
      return 'event_photos';
    }
    if (storagePath.startsWith('clubs/')) return 'club_covers';
    if (storagePath.startsWith('matches/')) return 'chat_images';
    return 'images';
  }
}

@riverpod
ImageUploadRepository imageUploadRepository(Ref ref) =>
    ImageUploadRepository(ref.watch(firebaseStorageProvider));
