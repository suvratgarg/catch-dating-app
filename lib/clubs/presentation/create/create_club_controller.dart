import 'dart:typed_data';

import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/domain/club_host_defaults.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_club_controller.g.dart';

class PickedClubCover {
  const PickedClubCover({required this.image, required this.bytes});

  final XFile image;
  final Uint8List bytes;
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
  }) async {
    final uid = requireSignedInUid(ref, action: 'create a club');

    if (existingClub != null) {
      if (existingClub.hostUserId != uid) {
        throw StateError('Only the host can edit this club.');
      }

      var imageUrl = existingClub.imageUrl;
      if (coverImage != null) {
        imageUrl = await ref
            .read(imageUploadRepositoryProvider)
            .uploadClubCover(clubId: existingClub.id, image: coverImage);
      }

      final clubsRepo = ref.read(clubsRepositoryProvider);
      final fields = <String, dynamic>{
        'name': name,
        'description': description,
        'location': location,
        'area': area,
        'imageUrl': imageUrl,
        'hostDefaults': hostDefaults.toJson(),
      };
      if (instagramHandle != null) fields['instagramHandle'] = instagramHandle;
      if (phoneNumber != null) fields['phoneNumber'] = phoneNumber;
      if (email != null) fields['email'] = email;
      await clubsRepo.updateClub(clubId: existingClub.id, fields: fields);
      return;
    }

    final clubsRepo = ref.read(clubsRepositoryProvider);
    String? clubId;
    String? imageUrl;

    if (coverImage != null) {
      clubId = clubsRepo.generateId();
      imageUrl = await ref
          .read(imageUploadRepositoryProvider)
          .uploadClubCover(clubId: clubId, image: coverImage);
    }

    await clubsRepo.createClub(
      clubId: clubId,
      name: name,
      description: description,
      location: location,
      area: area,
      imageUrl: imageUrl,
      instagramHandle: instagramHandle,
      phoneNumber: phoneNumber,
      email: email,
      hostDefaults: hostDefaults,
    );
  }
}
