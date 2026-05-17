import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/public_profile/data/public_profile_repository.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_keys.dart';
import 'package:catch_dating_app/safety/presentation/settings_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';
import '../test_pump_helpers.dart';

void main() {
  testWidgets('renders profile-backed settings and empty blocked state', (
    tester,
  ) async {
    final container = _settingsContainer(
      user: buildUser(phoneNumber: '+919876543210'),
      blockedUsers: const [],
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);

    expect(find.text('+91 9876543210'), findsOneWidget);
    expect(find.text('No blocked accounts'), findsOneWidget);
    expect(find.byKey(SettingsKeys.showOnMapSwitch), findsOneWidget);
    expect(find.byKey(SettingsKeys.weeklyDigestSwitch), findsOneWidget);
    expect(_topBarMaterial(tester).color, CatchTokens.sunsetLight.bg);
  });

  testWidgets('preference switches write through SettingsController', (
    tester,
  ) async {
    final userRepository = _FakeSettingsUserProfileRepository();
    final container = _settingsContainer(
      user: buildUser(uid: 'runner-1').copyWith(prefsWeeklyDigest: false),
      userRepository: userRepository,
      blockedUsers: const [],
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);
    await tester.tap(find.byKey(SettingsKeys.weeklyDigestSwitch));
    await pumpFeatureUi(tester);

    expect(userRepository.updatedUid, 'runner-1');
    expect(userRepository.updatedFields, {'prefsWeeklyDigest': true});
  });

  testWidgets('failed preference writes roll back optimistic switch state', (
    tester,
  ) async {
    final userRepository = _FakeSettingsUserProfileRepository(
      throwOnUpdate: true,
    );
    final container = _settingsContainer(
      user: buildUser(uid: 'runner-1').copyWith(prefsWeeklyDigest: false),
      userRepository: userRepository,
      blockedUsers: const [],
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);
    await tester.tap(find.byKey(SettingsKeys.weeklyDigestSwitch));
    await pumpFeatureUi(tester);

    final weeklyDigestSwitch = tester.widget<Switch>(
      find.byKey(SettingsKeys.weeklyDigestSwitch),
    );
    expect(weeklyDigestSwitch.value, isFalse);
    expect(find.text('update failed'), findsOneWidget);
  });

  testWidgets('blocked account rows use profile data and unblock controller', (
    tester,
  ) async {
    final safetyRepository = _FakeSettingsSafetyRepository();
    final container = _settingsContainer(
      user: buildUser(uid: 'runner-1'),
      safetyRepository: safetyRepository,
      blockedUsers: [
        BlockedUser(
          uid: 'blocked-1',
          source: 'chat',
          createdAt: DateTime(2026, 5, 1),
        ),
      ],
      publicProfiles: {
        'blocked-1': buildPublicProfile(uid: 'blocked-1', name: 'Riya'),
      },
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);

    expect(find.text('Riya'), findsOneWidget);
    expect(find.text('chat'), findsOneWidget);

    await tester.tap(find.byKey(SettingsKeys.unblockButton('blocked-1')));
    await pumpFeatureUi(tester);

    expect(safetyRepository.unblockedUserId, 'blocked-1');
    expect(find.text('Account unblocked.'), findsOneWidget);
  });

  testWidgets('account section owns profile history actions and sign out', (
    tester,
  ) async {
    final authRepository = _FakeSettingsAuthRepository();
    final container = _settingsContainer(
      user: buildUser(uid: 'runner-1'),
      blockedUsers: const [],
      authRepository: authRepository,
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);

    expect(find.byKey(SettingsKeys.reviewHistoryRow), findsOneWidget);
    expect(find.byKey(SettingsKeys.paymentHistoryRow), findsOneWidget);
    expect(find.byKey(SettingsKeys.eventPolicyLabRow), findsOneWidget);
    expect(find.byKey(SettingsKeys.eventSuccessLabRow), findsOneWidget);
    expect(find.byKey(SettingsKeys.signOutRow), findsOneWidget);

    await tester.tap(find.byKey(SettingsKeys.signOutRow));
    await pumpFeatureUi(tester);

    expect(authRepository.signOutCallCount, 1);
  });

  testWidgets('delete account confirmation delegates to controller', (
    tester,
  ) async {
    final safetyRepository = _FakeSettingsSafetyRepository();
    final container = _settingsContainer(
      user: buildUser(uid: 'runner-1'),
      safetyRepository: safetyRepository,
      blockedUsers: const [],
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);
    await tester.scrollUntilVisible(
      find.byKey(SettingsKeys.deleteAccountRow),
      300,
    );
    await tester.pump();
    await tester.tap(find.byKey(SettingsKeys.deleteAccountRow));
    await pumpFeatureUi(tester);

    expect(find.text('Delete account?'), findsOneWidget);

    await tester.tap(find.text('Delete'));
    await tester.pump();

    expect(safetyRepository.requestDeletionCallCount, 1);
  });
}

Material _topBarMaterial(WidgetTester tester) {
  return tester.widget<Material>(
    find
        .descendant(
          of: find.byType(CatchTopBar),
          matching: find.byType(Material),
        )
        .first,
  );
}

ProviderContainer _settingsContainer({
  required UserProfile user,
  required List<BlockedUser> blockedUsers,
  UserProfileRepository? userRepository,
  SafetyRepository? safetyRepository,
  AuthRepository? authRepository,
  Map<String, PublicProfile> publicProfiles = const {},
}) {
  final container = ProviderContainer(
    overrides: [
      uidProvider.overrideWith((ref) => Stream.value(user.uid)),
      authRepositoryProvider.overrideWithValue(
        authRepository ?? _FakeSettingsAuthRepository(),
      ),
      watchUserProfileProvider.overrideWith((ref) => Stream.value(user)),
      userProfileRepositoryProvider.overrideWith(
        (ref) => userRepository ?? _FakeSettingsUserProfileRepository(),
      ),
      safetyRepositoryProvider.overrideWith(
        (ref) => safetyRepository ?? _FakeSettingsSafetyRepository(),
      ),
      watchBlockedUsersProvider.overrideWith(
        (ref) => Stream.value(blockedUsers),
      ),
      for (final entry in publicProfiles.entries)
        watchPublicProfileProvider(
          entry.key,
        ).overrideWith((ref) => Stream.value(entry.value)),
    ],
  );
  return container;
}

Future<void> _pumpSettings(
  WidgetTester tester,
  ProviderContainer container,
) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(390, 1200);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.light,
        home: const _SettingsTestPrimer(child: SettingsScreen()),
      ),
    ),
  );
  await tester.pump();
  await tester.pump();
}

class _SettingsTestPrimer extends ConsumerWidget {
  const _SettingsTestPrimer({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(uidProvider);
    return child;
  }
}

class _FakeSettingsUserProfileRepository extends Fake
    implements UserProfileRepository {
  _FakeSettingsUserProfileRepository({this.throwOnUpdate = false});

  final bool throwOnUpdate;
  String? updatedUid;
  Map<String, dynamic>? updatedFields;

  @override
  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> fields,
    String action = 'update profile',
  }) async {
    if (throwOnUpdate) {
      throw Exception('update failed');
    }
    updatedUid = uid;
    updatedFields = Map<String, dynamic>.from(fields);
  }
}

class _FakeSettingsSafetyRepository extends Fake implements SafetyRepository {
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

class _FakeSettingsAuthRepository extends Fake implements AuthRepository {
  int signOutCallCount = 0;

  @override
  Future<void> signOut() async {
    signOutCallCount += 1;
  }
}
