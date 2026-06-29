import 'dart:typed_data';

import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_club_controller.g.dart';

class PickedClubImage {
  const PickedClubImage({required this.image, required this.bytes});

  final XFile image;
  final Uint8List bytes;
}

class PickedClubPhoto extends PickedClubImage {
  const PickedClubPhoto({required super.image, required super.bytes});
}

class PickedClubProfileImage extends PickedClubImage {
  const PickedClubProfileImage({required super.image, required super.bytes});
}

sealed class ClubPhotoInput {
  const ClubPhotoInput();
}

final class ExistingClubPhotoInput extends ClubPhotoInput {
  const ExistingClubPhotoInput(this.photo);

  final UploadedPhoto photo;
}

final class NewClubPhotoInput extends ClubPhotoInput {
  const NewClubPhotoInput(this.image);

  final XFile image;
}

/// **Pattern A: Action controller + static Mutations**
///
/// Handles create and edit club submission. [submitMutation] tracks the
/// lifecycle of the async submit operation. The UI watches
/// `ref.watch(createClubControllerProvider.submitMutation)`.
@riverpod
class CreateClubController extends _$CreateClubController {
  static final submitMutation = Mutation<void>();

  @override
  void build() {}

  Future<List<PickedClubPhoto>> pickClubPhotos({
    int imageQuality = 85,
    int limit = 6,
  }) async {
    final images = await ref
        .read(imageUploadRepositoryProvider)
        .pickImages(
          purpose: ImageUploadPurpose.clubPhoto,
          imageQuality: imageQuality,
          limit: limit,
        );
    return [
      for (final image in images)
        PickedClubPhoto(image: image, bytes: await image.readAsBytes()),
    ];
  }

  Future<PickedClubProfileImage?> pickProfileImage({
    int imageQuality = 85,
  }) async {
    final image = await ref
        .read(imageUploadRepositoryProvider)
        .pickImage(
          purpose: ImageUploadPurpose.clubProfileImage,
          imageQuality: imageQuality,
        );
    if (image == null) {
      return null;
    }

    return PickedClubProfileImage(
      image: image,
      bytes: await image.readAsBytes(),
    );
  }

  Future<void> submit({
    required String name,
    required String location,
    required String area,
    required String description,
    Club? existingClub,
    List<ClubPhotoInput>? clubPhotoInputs,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
    ClubHostDefaults hostDefaults = const ClubHostDefaults(),
    XFile? profileImage,
  }) async {
    final uid = requireSignedInUid(ref, action: 'create a club');

    if (existingClub != null) {
      if (!existingClub.isHostedBy(uid)) {
        throw const BackendOperationException(
          code: 'unauthorized',
          message: 'Only a club host can edit this club.',
          context: BackendErrorContext(
            service: BackendService.local,
            action: 'edit club',
          ),
        );
      }

      var imageUrl = existingClub.imageUrl;
      var profileImageUrl = existingClub.profileImageUrl;
      var clubPhotos = existingClub.clubPhotos;
      var logoPhoto = existingClub.logoPhoto;
      var clubPhotosChanged = false;
      var logoChanged = false;
      final selectedClubPhotoInputs = clubPhotoInputs;
      if (selectedClubPhotoInputs != null) {
        clubPhotos = await _resolveClubPhotoInputs(
          uid: uid,
          clubId: existingClub.id,
          inputs: selectedClubPhotoInputs,
        );
        imageUrl = _primaryPhotoUrl(clubPhotos);
        clubPhotosChanged = true;
      }
      if (profileImage != null) {
        final upload = await ref
            .read(imageUploadRepositoryProvider)
            .uploadClubLogo(
              uid: uid,
              clubId: existingClub.id,
              image: profileImage,
            );
        logoPhoto = UploadedPhoto.fromUpload(
          url: upload.url,
          storagePath: upload.storagePath,
          position: 0,
        );
        profileImageUrl = logoPhoto.thumbnailOrUrl;
        logoChanged = true;
      }

      final clubsRepo = ref.read(clubsRepositoryProvider);
      if (!existingClub.isOwnedBy(uid)) {
        if (!clubPhotosChanged && !logoChanged) {
          throw const BackendOperationException(
            code: 'unauthorized',
            message: 'Only the club owner can edit club details.',
            context: BackendErrorContext(
              service: BackendService.local,
              action: 'edit club details',
            ),
          );
        }
        final patch = <String, Object?>{};
        if (clubPhotosChanged) {
          patch['imageUrl'] = imageUrl;
          patch['clubPhotos'] = clubPhotos
              .map((photo) => photo.toJson())
              .toList(growable: false);
        }
        if (logoChanged) {
          patch['profileImageUrl'] = profileImageUrl;
          patch['logoPhoto'] = logoPhoto?.toJson();
        }
        await clubsRepo.updateClub(
          clubId: existingClub.id,
          patch: UpdateClubPatch.raw(patch),
        );
        return;
      }

      await clubsRepo.updateClub(
        clubId: existingClub.id,
        patch: UpdateClubPatch.raw({
          'name': name,
          'description': description,
          'location': location,
          'area': area,
          'imageUrl': imageUrl,
          'profileImageUrl': profileImageUrl,
          'clubPhotos': clubPhotos
              .map((photo) => photo.toJson())
              .toList(growable: false),
          'logoPhoto': logoPhoto?.toJson(),
          'hostDefaults': hostDefaults.toJson(),
          'instagramHandle': instagramHandle,
          'phoneNumber': phoneNumber,
          'email': email,
        }),
      );
      return;
    }

    final clubsRepo = ref.read(clubsRepositoryProvider);
    final selectedClubPhotoInputs = clubPhotoInputs ?? const <ClubPhotoInput>[];
    final reservedClubId =
        selectedClubPhotoInputs.isNotEmpty || profileImage != null
        ? clubsRepo.generateId()
        : null;
    final createdClubId = await clubsRepo.createClub(
      clubId: reservedClubId,
      name: name,
      description: description,
      location: location,
      area: area,
      instagramHandle: instagramHandle,
      phoneNumber: phoneNumber,
      email: email,
      hostDefaults: hostDefaults,
    );

    String? uploadedPrimaryPhoto;
    String? uploadedProfile;
    var clubPhotos = <UploadedPhoto>[];
    UploadedPhoto? logoPhoto;
    if (selectedClubPhotoInputs.isNotEmpty) {
      clubPhotos = await _resolveClubPhotoInputs(
        uid: uid,
        clubId: createdClubId,
        inputs: selectedClubPhotoInputs,
      );
      uploadedPrimaryPhoto = _primaryPhotoUrl(clubPhotos);
    }
    if (profileImage != null) {
      final upload = await ref
          .read(imageUploadRepositoryProvider)
          .uploadClubLogo(uid: uid, clubId: createdClubId, image: profileImage);
      logoPhoto = UploadedPhoto.fromUpload(
        url: upload.url,
        storagePath: upload.storagePath,
        position: 0,
      );
      uploadedProfile = logoPhoto.url;
    }
    if (uploadedPrimaryPhoto != null || uploadedProfile != null) {
      final patch = <String, Object?>{};
      if (uploadedPrimaryPhoto != null) {
        patch['imageUrl'] = uploadedPrimaryPhoto;
        patch['clubPhotos'] = clubPhotos
            .map((photo) => photo.toJson())
            .toList(growable: false);
      }
      if (uploadedProfile != null) {
        patch['profileImageUrl'] = uploadedProfile;
        patch['logoPhoto'] = logoPhoto?.toJson();
      }
      await clubsRepo.updateClub(
        clubId: createdClubId,
        patch: UpdateClubPatch.raw(patch),
      );
    }
  }

  Future<List<UploadedPhoto>> _resolveClubPhotoInputs({
    required String uid,
    required String clubId,
    required List<ClubPhotoInput> inputs,
  }) async {
    final photos = <UploadedPhoto>[];
    for (final indexedInput in inputs.indexed) {
      final position = indexedInput.$1;
      switch (indexedInput.$2) {
        case ExistingClubPhotoInput(:final photo):
          photos.add(
            photo.copyWith(position: position, updatedAt: DateTime.now()),
          );
        case NewClubPhotoInput(:final image):
          final upload = await ref
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

String? _primaryPhotoUrl(List<UploadedPhoto> photos) =>
    photos.isEmpty ? null : photos.first.url;
