import 'dart:math' as math;
import 'dart:typed_data';

import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as image_lib;
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_upload_repository.g.dart';

enum ImageUploadPurpose {
  profilePhoto,
  clubCover,
  clubPhoto,
  clubProfileImage,
  clubLogo,
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

class _PreparedUpload {
  const _PreparedUpload({
    required this.bytes,
    required this.extension,
    required this.contentType,
  });

  final Uint8List bytes;
  final String extension;
  final String contentType;
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
  static const _hostedMediaContract = _StorageUploadContract(
    resource: 'hosted_media',
    maxBytes: 8388608,
    contentTypePattern: 'image/.*',
  );
  static const _clubPhotosContract = _StorageUploadContract(
    resource: 'club_photos',
    maxBytes: 8388608,
    contentTypePattern: 'image/.*',
  );
  static const _clubLogoImagesContract = _StorageUploadContract(
    resource: 'club_logo_images',
    maxBytes: 8388608,
    contentTypePattern: 'image/.*',
  );
  static const _eventPhotosContract = _StorageUploadContract(
    resource: 'event_photos',
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

  Future<List<XFile>> pickImages({
    ImageUploadPurpose purpose = ImageUploadPurpose.profilePhoto,
    int? imageQuality,
    int? limit,
  }) {
    final policy = policyForPurpose(purpose);
    return _picker.pickMultiImage(
      maxWidth: policy.maxWidth,
      maxHeight: policy.maxHeight,
      imageQuality: imageQuality ?? policy.quality,
      limit: limit,
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
    ImageUploadPurpose purpose = ImageUploadPurpose.profilePhoto,
  }) async => (await uploadWithMetadata(
    storagePath: storagePath,
    image: image,
    purpose: purpose,
  )).url;

  /// Uploads [image] and returns both the download URL and final Storage path.
  Future<UploadedImage> uploadWithMetadata({
    required String storagePath,
    required XFile image,
    ImageUploadPurpose purpose = ImageUploadPurpose.profilePhoto,
  }) async {
    return withBackendErrorContext(
      () async {
        final prepared = await _prepareUpload(image: image, purpose: purpose);
        _assertUploadConformsToStorageContract(
          storagePath: storagePath,
          byteLength: prepared.bytes.length,
          reportedContentType: image.mimeType,
          effectiveContentType: prepared.contentType,
        );
        final finalStoragePath = '$storagePath.${prepared.extension}';
        final ref = _storage.ref(finalStoragePath);
        await ref.putData(
          prepared.bytes,
          SettableMetadata(contentType: prepared.contentType),
        );
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

  Future<UploadedImage> uploadClubPhoto({
    String? uid,
    required String clubId,
    required int position,
    required XFile image,
  }) {
    final millis = DateTime.now().millisecondsSinceEpoch;
    return uploadWithMetadata(
      storagePath: 'clubs/$clubId/photos/${position}_$millis',
      image: image,
      purpose: ImageUploadPurpose.clubPhoto,
    );
  }

  Future<String> uploadClubCover({
    required String uid,
    required String clubId,
    required XFile image,
  }) async {
    final upload = await uploadClubPhoto(
      uid: uid,
      clubId: clubId,
      position: 0,
      image: image,
    );
    return upload.url;
  }

  Future<UploadedImage> uploadClubLogo({
    String? uid,
    required String clubId,
    required XFile image,
  }) {
    final millis = DateTime.now().millisecondsSinceEpoch;
    return uploadWithMetadata(
      storagePath: 'clubs/$clubId/logo/$millis',
      image: image,
      purpose: ImageUploadPurpose.clubLogo,
    );
  }

  Future<String> uploadClubProfileImage({
    required String uid,
    required String clubId,
    required XFile image,
  }) async {
    final upload = await uploadClubLogo(uid: uid, clubId: clubId, image: image);
    return upload.url;
  }

  Future<String> uploadEventPhoto({
    String? uid,
    String? clubId,
    required String eventId,
    int position = 0,
    required XFile image,
  }) {
    final millis = DateTime.now().millisecondsSinceEpoch;
    return upload(
      storagePath: 'events/$eventId/photos/${position}_$millis',
      image: image,
      purpose: ImageUploadPurpose.eventPhoto,
    );
  }

  Future<UploadedImage> uploadEventPhotoWithMetadata({
    required String eventId,
    required int position,
    required XFile image,
  }) {
    final millis = DateTime.now().millisecondsSinceEpoch;
    return uploadWithMetadata(
      storagePath: 'events/$eventId/photos/${position}_$millis',
      image: image,
      purpose: ImageUploadPurpose.eventPhoto,
    );
  }

  Future<String> uploadChatImage({
    required String matchId,
    required String messageId,
    required XFile image,
  }) => upload(
    storagePath:
        'matches/$matchId/images/${messageId}_'
        '${DateTime.now().millisecondsSinceEpoch}',
    image: image,
    purpose: ImageUploadPurpose.chatImage,
  );

  // ── Internal ──────────────────────────────────────────────────────────────

  static ImageUploadPolicy policyForPurpose(ImageUploadPurpose purpose) {
    return switch (purpose) {
      ImageUploadPurpose.profilePhoto => profilePhotoPolicy,
      ImageUploadPurpose.clubCover => clubCoverPolicy,
      ImageUploadPurpose.clubPhoto => clubCoverPolicy,
      ImageUploadPurpose.clubProfileImage => clubProfileImagePolicy,
      ImageUploadPurpose.clubLogo => clubProfileImagePolicy,
      ImageUploadPurpose.eventPhoto => eventPhotoPolicy,
      ImageUploadPurpose.chatImage => chatImagePolicy,
    };
  }

  static Future<_PreparedUpload> _prepareUpload({
    required XFile image,
    required ImageUploadPurpose purpose,
  }) async {
    final originalBytes = await image.readAsBytes();
    final originalExt = _normalizedExt(image.name);
    final compressedBytes = _compressedImageBytes(
      originalBytes,
      policy: policyForPurpose(purpose),
    );
    if (compressedBytes == null) {
      return _PreparedUpload(
        bytes: originalBytes,
        extension: originalExt,
        contentType: _contentTypeForExt(originalExt),
      );
    }
    return _PreparedUpload(
      bytes: compressedBytes,
      extension: 'jpg',
      contentType: 'image/jpeg',
    );
  }

  static Uint8List? _compressedImageBytes(
    Uint8List bytes, {
    required ImageUploadPolicy policy,
  }) {
    try {
      final decoded = image_lib.decodeImage(bytes);
      if (decoded == null) return null;
      var normalized = image_lib.bakeOrientation(decoded);
      final scale = math.min(
        policy.maxWidth / normalized.width,
        policy.maxHeight / normalized.height,
      );
      if (scale < 1) {
        normalized = image_lib.copyResize(
          normalized,
          width: math.max(1, (normalized.width * scale).round()),
          height: math.max(1, (normalized.height * scale).round()),
          interpolation: image_lib.Interpolation.average,
        );
      }
      return Uint8List.fromList(
        image_lib.encodeJpg(normalized, quality: policy.quality),
      );
    } on Object {
      return null;
    }
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
    if (storagePath.startsWith('users/') &&
        storagePath.contains('/hostedMedia/')) {
      return _hostedMediaContract;
    }
    if (storagePath.startsWith('clubs/') && storagePath.contains('/photos/')) {
      return _clubPhotosContract;
    }
    if (storagePath.startsWith('clubs/') && storagePath.contains('/logo/')) {
      return _clubLogoImagesContract;
    }
    if (storagePath.startsWith('events/') && storagePath.contains('/photos/')) {
      return _eventPhotosContract;
    }
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
