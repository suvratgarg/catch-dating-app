import 'package:catch_dating_app/app_user/data/app_user_repository.dart';
import 'package:catch_dating_app/core/indian_city.dart';
import 'package:catch_dating_app/image_uploads/data/image_upload_repository.dart';
import 'package:catch_dating_app/run_clubs/data/run_clubs_repository.dart';
import 'package:catch_dating_app/run_clubs/presentation/shared/run_clubs_controller_utils.dart';
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
    required String area,
    required String description,
    XFile? coverImage,
  }) async {
    final uid = requireSignedInUid(ref, action: 'create a club');
    final appUser = ref.read(appUserStreamProvider).asData?.value;
    if (appUser == null) {
      throw StateError('User profile not loaded. Please try again.');
    }
    final hostName = appUser.name;
    final hostAvatarUrl = appUser.photoUrls.firstOrNull;

    final clubsRepo = ref.read(runClubsRepositoryProvider);
    String? clubId;
    String? imageUrl;

    if (coverImage != null) {
      clubId = clubsRepo.generateId();
      imageUrl = await ref
          .read(imageUploadRepositoryProvider)
          .uploadRunClubCover(clubId: clubId, image: coverImage);
    }

    await clubsRepo.createRunClub(
      clubId: clubId,
      name: name,
      description: description,
      location: location,
      area: area,
      hostUserId: uid,
      hostName: hostName,
      hostAvatarUrl: hostAvatarUrl,
      imageUrl: imageUrl,
    );
  }
}
