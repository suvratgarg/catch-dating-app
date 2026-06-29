import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_controller.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../auth/auth_test_helpers.dart';

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

  test('watchBlockedUsersProvider auto-disposes settings listeners', () async {
    final blockedUsers = [
      BlockedUser(
        uid: 'blocked-1',
        source: 'settings',
        createdAt: DateTime(2026, 5, 6),
      ),
    ];
    final cancelCompleter = Completer<void>();
    final blockedUsersController = StreamController<List<BlockedUser>>(
      onCancel: () {
        if (!cancelCompleter.isCompleted) cancelCompleter.complete();
      },
    );
    addTearDown(() async {
      if (!cancelCompleter.isCompleted) await blockedUsersController.close();
    });
    final safetyRepository = _FakeSafetyRepository(
      blockedUsersStream: blockedUsersController.stream,
    );
    final container = ProviderContainer(
      overrides: [
        uidProvider.overrideWith((ref) => Stream.value('runner-1')),
        safetyRepositoryProvider.overrideWith((ref) => safetyRepository),
      ],
    );
    addTearDown(container.dispose);
    await _primeUidProvider(container);

    final subscription = container.listen(watchBlockedUsersProvider, (_, _) {});

    blockedUsersController.add(blockedUsers);
    await container.pump();
    expect(subscription.read().value, blockedUsers);

    subscription.close();
    await container.pump();

    await expectLater(cancelCompleter.future, completes);
  });
}

class _SettingsUserProfileRepository extends Fake
    implements UserProfileRepository {
  String? updatedUid;
  Map<String, dynamic>? updatedFields;

  @override
  Future<void> updateUserProfile({
    required String uid,
    required UpdateUserProfilePatch patch,
    String action = 'update_profile',
  }) async {
    updatedUid = uid;
    updatedFields = Map<String, dynamic>.from(patch.toFieldsJson());
  }
}

class _FakeSafetyRepository extends Fake implements SafetyRepository {
  _FakeSafetyRepository({this.blockedUsersStream});

  final Stream<List<BlockedUser>>? blockedUsersStream;
  int requestDeletionCallCount = 0;
  String? unblockedUserId;

  @override
  Stream<List<BlockedUser>> watchBlockedUsers({required String uid}) =>
      blockedUsersStream ?? const Stream.empty();

  @override
  Future<void> requestAccountDeletion() async {
    requestDeletionCallCount += 1;
  }

  @override
  Future<void> unblockUser({required String targetUserId}) async {
    unblockedUserId = targetUserId;
  }
}
