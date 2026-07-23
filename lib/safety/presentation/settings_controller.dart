import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/auth/require_signed_in_uid.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'settings_controller.g.dart';

enum SettingsPreference {
  showOnMap('prefsShowOnMap'),
  newCatches('prefsNewCatches'),
  messages('prefsMessages'),
  eventReminders('prefsEventReminders'),
  eventStatusUpdates('prefsRunStatusUpdates'),
  clubUpdates('prefsClubUpdates'),
  weeklyDigest('prefsWeeklyDigest');

  const SettingsPreference(this.fieldName);

  final String fieldName;

  /// Builds a typed profile patch toggling this preference. Each preference
  /// maps to exactly one boolean field on `users/{uid}` — the switch keeps the
  /// preference → field mapping explicit and compile-checked.
  UpdateUserProfilePatch patch(bool value) {
    return switch (this) {
      SettingsPreference.showOnMap => UpdateUserProfilePatch(
        prefsShowOnMap: value,
      ),
      SettingsPreference.newCatches => UpdateUserProfilePatch(
        prefsNewCatches: value,
      ),
      SettingsPreference.messages => UpdateUserProfilePatch(
        prefsMessages: value,
      ),
      SettingsPreference.eventReminders => UpdateUserProfilePatch(
        prefsEventReminders: value,
      ),
      SettingsPreference.eventStatusUpdates => UpdateUserProfilePatch(
        prefsRunStatusUpdates: value,
      ),
      SettingsPreference.clubUpdates => UpdateUserProfilePatch(
        prefsClubUpdates: value,
      ),
      SettingsPreference.weeklyDigest => UpdateUserProfilePatch(
        prefsWeeklyDigest: value,
      ),
    };
  }
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

  Future<void>? _operationInFlight;

  @override
  void build() {}

  Future<void> savePreference({
    required SettingsPreference preference,
    required bool value,
  }) {
    return _trackOperation(
      () => _savePreference(preference: preference, value: value),
    );
  }

  Future<void> _savePreference({
    required SettingsPreference preference,
    required bool value,
  }) async {
    final uid = requireSignedInUid(ref, action: 'save settings');
    await ref
        .read(userProfileRepositoryProvider)
        .updateUserProfile(uid: uid, patch: preference.patch(value));
  }

  Future<void> requestAccountDeletion() {
    return _trackOperation(_requestAccountDeletion);
  }

  Future<void> _requestAccountDeletion() async {
    await ref.read(safetyRepositoryProvider).requestAccountDeletion();
    ref.read(authSessionControllerProvider.notifier).clearLocalFlowState();
  }

  Future<void> unblockUser({required String targetUserId}) {
    return _trackOperation(
      () => ref
          .read(safetyRepositoryProvider)
          .unblockUser(targetUserId: targetUserId),
    );
  }

  Future<void> _trackOperation(Future<void> Function() operation) {
    final active = _operationInFlight;
    if (active != null) return active;

    final future = Future<void>.sync(operation);
    _operationInFlight = future;
    future.then<void>(
      (_) => _clearOperation(future),
      onError: (Object _, StackTrace _) => _clearOperation(future),
    );
    return future;
  }

  void _clearOperation(Future<void> operation) {
    if (identical(_operationInFlight, operation)) {
      _operationInFlight = null;
    }
  }
}
