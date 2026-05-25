import 'dart:typed_data';

import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/clubs/domain/update_club_patch.dart';
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

class PickedClubCover extends PickedClubImage {
  const PickedClubCover({required super.image, required super.bytes});
}

class PickedClubProfileImage extends PickedClubImage {
  const PickedClubProfileImage({required super.image, required super.bytes});
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

  Future<PickedClubCover?> pickCoverImage({int imageQuality = 85}) async {
    final image = await ref
        .read(imageUploadRepositoryProvider)
        .pickImage(
          purpose: ImageUploadPurpose.clubCover,
          imageQuality: imageQuality,
        );
    if (image == null) {
      return null;
    }

    return PickedClubCover(image: image, bytes: await image.readAsBytes());
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
    XFile? coverImage,
    String? instagramHandle,
    String? phoneNumber,
    String? email,
    ClubHostDefaults hostDefaults = const ClubHostDefaults(),
    XFile? profileImage,
  }) async {
    final uid = requireSignedInUid(ref, action: 'create a club');

    if (existingClub != null) {
      if (!existingClub.isHostedBy(uid)) {
        throw StateError('Only a club host can edit this club.');
      }

      var imageUrl = existingClub.imageUrl;
      var profileImageUrl = existingClub.profileImageUrl;
      String? uploadedImageUrl;
      String? uploadedProfileImageUrl;
      if (coverImage != null) {
        imageUrl = await ref
            .read(imageUploadRepositoryProvider)
            .uploadClubCover(clubId: existingClub.id, image: coverImage);
        uploadedImageUrl = imageUrl;
      }
      if (profileImage != null) {
        profileImageUrl = await ref
            .read(imageUploadRepositoryProvider)
            .uploadClubProfileImage(
              clubId: existingClub.id,
              image: profileImage,
            );
        uploadedProfileImageUrl = profileImageUrl;
      }

      final clubsRepo = ref.read(clubsRepositoryProvider);
      if (!existingClub.isOwnedBy(uid)) {
        if (uploadedImageUrl == null && uploadedProfileImageUrl == null) {
          throw StateError('Only the club owner can edit club details.');
        }
        await clubsRepo.updateClub(
          clubId: existingClub.id,
          patch: UpdateClubPatch(
            imageUrl: uploadedImageUrl,
            profileImageUrl: uploadedProfileImageUrl,
          ),
        );
        return;
      }

      await clubsRepo.updateClub(
        clubId: existingClub.id,
        patch: UpdateClubPatch(
          name: name,
          description: description,
          location: location,
          area: area,
          imageUrl: imageUrl,
          profileImageUrl: profileImageUrl,
          hostDefaults: hostDefaults,
          instagramHandle: instagramHandle,
          phoneNumber: phoneNumber,
          email: email,
        ),
      );
      return;
    }

    final clubsRepo = ref.read(clubsRepositoryProvider);
    final reservedClubId = coverImage != null || profileImage != null
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

    String? uploadedCover;
    String? uploadedProfile;
    if (coverImage != null) {
      uploadedCover = await ref
          .read(imageUploadRepositoryProvider)
          .uploadClubCover(clubId: createdClubId, image: coverImage);
    }
    if (profileImage != null) {
      uploadedProfile = await ref
          .read(imageUploadRepositoryProvider)
          .uploadClubProfileImage(clubId: createdClubId, image: profileImage);
    }
    if (uploadedCover != null || uploadedProfile != null) {
      await clubsRepo.updateClub(
        clubId: createdClubId,
        patch: UpdateClubPatch(
          imageUrl: uploadedCover,
          profileImageUrl: uploadedProfile,
        ),
      );
    }
  }
}
