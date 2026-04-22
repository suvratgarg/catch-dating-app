import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_upload_repository.g.dart';

class ImageUploadRepository {
  ImageUploadRepository(this._storage, {ImagePicker? picker})
    : _picker = picker ?? ImagePicker();

  final FirebaseStorage _storage;
  final ImagePicker _picker;

  // ── Picking ───────────────────────────────────────────────────────────────

  Future<XFile?> pickImage({int imageQuality = 85}) => _picker.pickImage(
    source: ImageSource.gallery,
    imageQuality: imageQuality,
  );

  // ── Generic upload ────────────────────────────────────────────────────────

  /// Uploads [image] to [storagePath] and returns the download URL.
  ///
  /// The extension is derived from the file name and appended to [storagePath],
  /// so pass a path without an extension (e.g. `'users/abc/photos/0_1234'`).
  Future<String> upload({
    required String storagePath,
    required XFile image,
  }) async {
    final bytes = await image.readAsBytes();
    final ext = _ext(image.name);
    final contentType = ext == 'png' ? 'image/png' : 'image/jpeg';
    final ref = _storage.ref('$storagePath.$ext');
    await ref.putData(bytes, SettableMetadata(contentType: contentType));
    return ref.getDownloadURL();
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

  // ── Internal ──────────────────────────────────────────────────────────────

  static String _ext(String filename) {
    final dot = filename.lastIndexOf('.');
    return dot != -1 ? filename.substring(dot + 1).toLowerCase() : 'jpg';
  }
}

@Riverpod(keepAlive: true)
ImageUploadRepository imageUploadRepository(Ref ref) =>
    ImageUploadRepository(ref.watch(firebaseStorageProvider));
