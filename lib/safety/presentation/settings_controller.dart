import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

enum SettingsPreference {
  showOnMap('prefsShowOnMap'),
  newCatches('prefsNewCatches'),
  runReminders('prefsRunReminders'),
  weeklyDigest('prefsWeeklyDigest');

  const SettingsPreference(this.fieldName);

  final String fieldName;
}

/// **Pattern A: Action controller + static Mutations**
///
/// Owns settings writes so the settings screen stays focused on local toggles,
/// confirmation UI, and rendering.
@riverpod
class SettingsController extends _$SettingsController {
  static final savePreferenceMutation = Mutation<void>();
  static final requestAccountDeletionMutation = Mutation<void>();
  static final unblockUserMutation = Mutation<void>();

  @override
  void build() {}

  Future<void> savePreference({
    required SettingsPreference preference,
    required bool value,
  }) async {
    final uid = requireSignedInUid(ref, action: 'save settings');
    await ref
        .read(userProfileRepositoryProvider)
        .updateUserProfile(uid: uid, fields: {preference.fieldName: value});
  }

  Future<void> requestAccountDeletion() async {
    await ref.read(safetyRepositoryProvider).requestAccountDeletion();
    ref.read(authSessionControllerProvider.notifier).clearLocalFlowState();
  }

  Future<void> unblockUser({required String targetUserId}) {
    return ref
        .read(safetyRepositoryProvider)
        .unblockUser(targetUserId: targetUserId);
  }
}
