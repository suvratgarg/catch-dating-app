import 'dart:typed_data';

import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'host_club_edit_controller.g.dart';

@riverpod
HostClubEditActions hostClubEditController(Ref ref) =>
    HostClubEditController(ref);

abstract interface class HostClubEditActions {
  Future<void> updateClub({
    required String clubId,
    required UpdateClubPatch patch,
  });

  Future<List<HostPickedClubPhoto>> pickClubPhotos({required int limit});

  Future<HostPickedClubLogo?> pickClubLogo();

  Future<void> updateClubMedia({
    required Club club,
    List<HostClubMediaInput>? photoInputs,
    HostPickedClubLogo? logo,
  });
}

class HostPickedClubPhoto {
  const HostPickedClubPhoto({required this.image, required this.bytes});

  final XFile image;
  final Uint8List bytes;
}

class HostPickedClubLogo {
  const HostPickedClubLogo({required this.image, required this.bytes});

  final XFile image;
  final Uint8List bytes;
}

sealed class HostClubMediaInput {
  const HostClubMediaInput();
}

final class HostExistingClubPhotoInput extends HostClubMediaInput {
  const HostExistingClubPhotoInput(this.photo);

  final UploadedPhoto photo;
}

final class HostNewClubPhotoInput extends HostClubMediaInput {
  const HostNewClubPhotoInput(this.image);

  final XFile image;
}

class HostClubEditController implements HostClubEditActions {
  const HostClubEditController(this._ref);

  static final updateClubMutation = Mutation<void>();
  static final updateMediaMutation = Mutation<void>();

  final Ref _ref;

  @override
  Future<void> updateClub({
    required String clubId,
    required UpdateClubPatch patch,
  }) async {
    requireSignedInUid(_ref, action: 'edit this club');
    if (patch.isEmpty) return;
    await _ref
        .read(clubsRepositoryProvider)
        .updateClub(clubId: clubId, patch: patch);
  }

  @override
  Future<List<HostPickedClubPhoto>> pickClubPhotos({required int limit}) async {
    final images = await _ref
        .read(imageUploadRepositoryProvider)
        .pickImages(
          purpose: ImageUploadPurpose.clubPhoto,
          imageQuality: 85,
          limit: limit,
        );
    return [
      for (final image in images)
        HostPickedClubPhoto(image: image, bytes: await image.readAsBytes()),
    ];
  }

  @override
  Future<HostPickedClubLogo?> pickClubLogo() async {
    final image = await _ref
        .read(imageUploadRepositoryProvider)
        .pickImage(
          purpose: ImageUploadPurpose.clubProfileImage,
          imageQuality: 85,
        );
    if (image == null) return null;
    return HostPickedClubLogo(image: image, bytes: await image.readAsBytes());
  }

  @override
  Future<void> updateClubMedia({
    required Club club,
    List<HostClubMediaInput>? photoInputs,
    HostPickedClubLogo? logo,
  }) async {
    final uid = requireSignedInUid(_ref, action: 'edit this club media');
    if (!club.isHostedBy(uid)) {
      throw const BackendOperationException(
        code: 'club-host-edit-required',
        message: 'Only a club host can edit this club media.',
        context: BackendErrorContext(
          service: BackendService.local,
          action: 'edit club media',
        ),
      );
    }

    final patch = <String, Object?>{};
    if (photoInputs != null) {
      final photos = await _resolvePhotoInputs(
        uid: uid,
        clubId: club.id,
        inputs: photoInputs,
      );
      patch['imageUrl'] = photos.isEmpty ? null : photos.first.url;
      patch['clubPhotos'] = photos
          .map((photo) => photo.toJson())
          .toList(growable: false);
    }
    if (logo != null) {
      final upload = await _ref
          .read(imageUploadRepositoryProvider)
          .uploadClubLogo(uid: uid, clubId: club.id, image: logo.image);
      final logoPhoto = UploadedPhoto.fromUpload(
        url: upload.url,
        storagePath: upload.storagePath,
        position: 0,
      );
      patch['profileImageUrl'] = logoPhoto.thumbnailOrUrl;
      patch['logoPhoto'] = logoPhoto.toJson();
    }
    if (patch.isEmpty) return;
    await _ref
        .read(clubsRepositoryProvider)
        .updateClub(clubId: club.id, patch: UpdateClubPatch.raw(patch));
  }

  Future<List<UploadedPhoto>> _resolvePhotoInputs({
    required String uid,
    required String clubId,
    required List<HostClubMediaInput> inputs,
  }) async {
    final photos = <UploadedPhoto>[];
    for (final indexedInput in inputs.indexed) {
      final position = indexedInput.$1;
      switch (indexedInput.$2) {
        case HostExistingClubPhotoInput(:final photo):
          photos.add(
            photo.copyWith(position: position, updatedAt: DateTime.now()),
          );
        case HostNewClubPhotoInput(:final image):
          final upload = await _ref
              .read(imageUploadRepositoryProvider)
              .uploadClubPhoto(
                uid: uid,
                clubId: clubId,
                position: position,
                image: image,
              );
          photos.add(
            UploadedPhoto.fromUpload(
              url: upload.url,
              storagePath: upload.storagePath,
              position: position,
            ),
          );
      }
    }
    return photos;
  }
}
