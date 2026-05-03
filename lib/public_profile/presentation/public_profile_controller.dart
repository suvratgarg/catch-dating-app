import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'public_profile_controller.g.dart';

@riverpod
class PublicProfileController extends _$PublicProfileController {
  @override
  void build() {}

  Future<void> blockUser({required String targetUserId}) async {
    await ref
        .read(safetyRepositoryProvider)
        .blockUser(targetUserId: targetUserId, source: 'profile');
  }

  Future<void> reportUser({
    required String targetUserId,
    required String reasonCode,
  }) async {
    await ref.read(safetyRepositoryProvider).reportUser(
      targetUserId: targetUserId,
      source: 'profile',
      reasonCode: reasonCode,
    );
  }
}
