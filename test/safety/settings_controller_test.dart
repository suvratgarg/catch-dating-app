import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_controller.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/auth_test_helpers.dart';
import '../runs/runs_test_helpers.dart';

Future<void> _primeUidProvider(ProviderContainer container) async {
  final uidSubscription = container.listen(
    uidProvider,
    (_, _) {},
    fireImmediately: true,
  );
  addTearDown(uidSubscription.close);
  await container.pump();
}

void main() {
  test('savePreference writes the selected settings field', () async {
    final userRepository = _SettingsUserProfileRepository();
    final container = ProviderContainer(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        userProfileRepositoryProvider.overrideWith((ref) => userRepository),
      ],
    );
    addTearDown(container.dispose);
    await _primeUidProvider(container);

    await container
        .read(settingsControllerProvider.notifier)
        .savePreference(
          preference: SettingsPreference.weeklyDigest,
          value: true,
        );

    expect(userRepository.updatedUid, 'runner-1');
    expect(userRepository.updatedFields, {'prefsWeeklyDigest': true});
  });

  test('unblockUser delegates to SafetyRepository', () async {
    final safetyRepository = _FakeSafetyRepository();
    final container = ProviderContainer(
      overrides: [
        safetyRepositoryProvider.overrideWith((ref) => safetyRepository),
      ],
    );
    addTearDown(container.dispose);

    await container
        .read(settingsControllerProvider.notifier)
        .unblockUser(targetUserId: 'blocked-1');

    expect(safetyRepository.unblockedUserId, 'blocked-1');
  });

  test(
    'requestAccountDeletion clears local flow state after repository call',
    () async {
      final safetyRepository = _FakeSafetyRepository();
      final authRepository = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(authRepository),
          safetyRepositoryProvider.overrideWith((ref) => safetyRepository),
        ],
      );
      addTearDown(authRepository.dispose);
      addTearDown(container.dispose);

      await container
          .read(settingsControllerProvider.notifier)
          .requestAccountDeletion();

      expect(safetyRepository.requestDeletionCallCount, 1);
    },
  );
}

class _SettingsUserProfileRepository extends FakeUserProfileRepository {
  String? updatedUid;
  Map<String, dynamic>? updatedFields;

  @override
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> fields,
  }) async {
    updatedUid = uid;
    updatedFields = fields;
  }
}

class _FakeSafetyRepository extends Fake implements SafetyRepository {
  int requestDeletionCallCount = 0;
  String? unblockedUserId;

  @override
  Future<void> requestAccountDeletion() async {
    requestDeletionCallCount += 1;
  }

  @override
  Future<void> unblockUser({required String targetUserId}) async {
    unblockedUserId = targetUserId;
  }
}
