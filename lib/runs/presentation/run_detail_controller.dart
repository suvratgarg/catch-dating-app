import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'run_detail_controller.g.dart';

/// **Pattern A: Action controller + static Mutations**
///
/// Owns run-detail side effects that are not booking operations.
@riverpod
class RunDetailController extends _$RunDetailController {
  static final toggleSavedRunMutation = Mutation<bool>();

  @override
  void build() {}

  Future<bool> toggleSavedRun({
    required Run run,
    required UserProfile userProfile,
    required bool isSaved,
  }) async {
    final repository = ref.read(userProfileRepositoryProvider);
    if (isSaved) {
      await repository.unsaveRun(uid: userProfile.uid, runId: run.id);
      return false;
    }

    await repository.saveRun(uid: userProfile.uid, runId: run.id);
    return true;
  }
}
