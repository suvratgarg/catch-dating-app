import 'package:catch_dating_app/auth/auth_repository.dart';
import 'package:catch_dating_app/imageUploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/runClubs/data/run_clubs_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'create_run_club_controller.g.dart';

@riverpod
class CreateRunClubController extends _$CreateRunClubController {
  static final submitMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> submit({
    required String name,
    required IndianCity location,
    required String description,
    XFile? coverImage,
  }) async {
    final uid = ref.read(uidProvider).asData?.value ?? '';
    final clubsRepo = ref.read(runClubsRepositoryProvider);
    final clubId = await clubsRepo.createRunClub(
      name: name,
      description: description,
      location: location,
      hostUserId: uid,
    );
    if (coverImage != null) {
      final imageUrl = await ref
          .read(imageUploadRepositoryProvider)
          .uploadRunClubCover(clubId: clubId, image: coverImage);
      await clubsRepo.updateImageUrl(clubId, imageUrl);
    }
  }
}
