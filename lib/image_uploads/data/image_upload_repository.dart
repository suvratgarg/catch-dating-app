import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_upload_repository.g.dart';

enum ImageUploadPurpose {
  profilePhoto,
  clubCover,
  clubProfileImage,
  eventPhoto,
  chatImage,
}

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

class _StorageUploadContract {
  const _StorageUploadContract({
    required this.resource,
    required this.maxBytes,
    required this.contentTypePattern,
  });

  final String resource;
  final int maxBytes;
  final String contentTypePattern;

  bool allowsContentType(String contentType) {
    return RegExp('^$contentTypePattern\$').hasMatch(contentType);
  }
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
  static const clubProfileImagePolicy = ImageUploadPolicy(
    maxWidth: 1024,
    maxHeight: 1024,
    quality: 85,
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

  static const _profilePhotosContract = _StorageUploadContract(
    resource: 'profile_photos',
    maxBytes: 8388608,
    contentTypePattern: 'image/.*',
  );
  static const _clubImagesContract = _StorageUploadContract(
    resource: 'club_images',
    maxBytes: 8388608,
    contentTypePattern: 'image/.*',
  );
  static const _eventImagesContract = _StorageUploadContract(
    resource: 'event_images',
    maxBytes: 8388608,
    contentTypePattern: 'image/.*',
  );
  static const _matchChatImagesContract = _StorageUploadContract(
    resource: 'match_chat_images',
    maxBytes: 8388608,
    contentTypePattern: 'image/.*',
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
        final contentType = _contentTypeForExt(ext);
        _assertUploadConformsToStorageContract(
          storagePath: storagePath,
          byteLength: bytes.length,
          reportedContentType: image.mimeType,
          effectiveContentType: contentType,
        );
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

  Future<String> uploadClubProfileImage({
    required String clubId,
    required XFile image,
  }) => upload(storagePath: 'clubs/$clubId/profile', image: image);

  Future<String> uploadEventPhoto({
    required String clubId,
    required String eventId,
    required XFile image,
  }) => upload(
    storagePath:
        'clubs/$clubId/events/$eventId/photo_'
        '${DateTime.now().millisecondsSinceEpoch}',
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
      ImageUploadPurpose.clubProfileImage => clubProfileImagePolicy,
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

  static String _contentTypeForExt(String ext) =>
      ext == 'png' ? 'image/png' : 'image/jpeg';

  static void _assertUploadConformsToStorageContract({
    required String storagePath,
    required int byteLength,
    required String? reportedContentType,
    required String effectiveContentType,
  }) {
    final contract = _contractForStoragePath(storagePath);
    if (contract == null) return;

    final context = BackendErrorContext(
      service: BackendService.storage,
      action: 'upload image',
      resource: contract.resource,
    );
    if (byteLength > contract.maxBytes) {
      throw StorageUploadPreflightException(
        constraint: 'max-bytes',
        message:
            'That image is too large. Please choose an image under '
            '${_formatBytes(contract.maxBytes)}.',
        debugMessage:
            'Storage upload was $byteLength bytes; max is '
            '${contract.maxBytes} bytes for ${contract.resource}.',
        context: context,
      );
    }

    final sourceContentType = reportedContentType?.trim();
    final contentType = sourceContentType == null || sourceContentType.isEmpty
        ? effectiveContentType
        : sourceContentType;
    if (!contract.allowsContentType(contentType)) {
      throw StorageUploadPreflightException(
        constraint: 'content-type',
        message: 'Please choose an image file.',
        debugMessage:
            'Storage upload content type "$contentType" did not match '
            '${contract.contentTypePattern} for ${contract.resource}.',
        context: context,
      );
    }
  }

  static String _resourceForStoragePath(String storagePath) {
    final contract = _contractForStoragePath(storagePath);
    if (contract != null) return contract.resource;
    return 'images';
  }

  static _StorageUploadContract? _contractForStoragePath(String storagePath) {
    if (storagePath.startsWith('users/') && storagePath.contains('/photos/')) {
      return _profilePhotosContract;
    }
    final storageName = storagePath.split('/').last;
    if (storagePath.startsWith('clubs/') &&
        storagePath.contains('/events/') &&
        storageName.isNotEmpty) {
      return _eventImagesContract;
    }
    if (storagePath.startsWith('clubs/')) return _clubImagesContract;
    if (storagePath.startsWith('matches/') &&
        storagePath.contains('/images/')) {
      return _matchChatImagesContract;
    }
    return null;
  }
}

String _formatBytes(int bytes) {
  final mb = bytes / (1024 * 1024);
  if (mb == mb.roundToDouble()) return '${mb.toInt()} MB';
  return '${mb.toStringAsFixed(1)} MB';
}

@riverpod
ImageUploadRepository imageUploadRepository(Ref ref) =>
    ImageUploadRepository(ref.watch(firebaseStorageProvider));
