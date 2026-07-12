import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/external_links.dart';
import 'package:catch_dating_app/core/schema_contracts/generated/callable_request_dtos.g.dart'
    show UpdateUserProfilePatch;
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/public_profile/data/public_profiles_lookup.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_keys.dart';
import 'package:catch_dating_app/safety/presentation/settings_screen.dart';
import 'package:catch_dating_app/user_profile/data/user_profile_repository.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:url_launcher/url_launcher.dart';

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
    expect(_topBarMaterial(tester).color, CatchTokens.editorialLight.bg);
  });

  testWidgets('settings rows align to the section text lane', (tester) async {
    final container = _settingsContainer(
      user: buildUser(phoneNumber: '+919876543210'),
      blockedUsers: const [],
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);

    final sectionLeft = tester.getTopLeft(find.text('ACCOUNT')).dx;
    final rowTextLeft = tester.getTopLeft(find.text('Phone number')).dx;

    expect(
      rowTextLeft - sectionLeft,
      moreOrLessEquals(CatchFieldRow.textLaneInset, epsilon: 0.5),
    );
  });

  testWidgets('renders profile provider loading state without blank rows', (
    tester,
  ) async {
    final container = _settingsContainer(
      user: buildUser(),
      profileStream: const Stream.empty(),
      blockedUsers: const [],
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);

    expect(find.text('Loading'), findsNWidgets(2));
    expect(find.text('No blocked accounts'), findsOneWidget);
  });

  testWidgets('renders blocked accounts row skeleton while loading', (
    tester,
  ) async {
    final container = _settingsContainer(
      user: buildUser(),
      blockedUsers: const [],
      blockedUsersStream: const Stream.empty(),
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);

    expect(find.byType(CatchSkeleton), findsWidgets);
    expect(find.text('No blocked accounts'), findsNothing);
  });

  testWidgets('renders profile provider errors through inline error state', (
    tester,
  ) async {
    final container = _settingsContainer(
      user: buildUser(),
      profileStream: Stream.error(StateError('profile failed')),
      blockedUsers: const [],
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);

    expect(find.text('Unavailable'), findsNWidgets(2));
    expect(find.bySubtype<CatchInlineErrorState>(), findsOneWidget);
  });

  testWidgets('preference switches write through SettingsController', (
    tester,
  ) async {
    final userRepository = _FakeSettingsUserProfileRepository();
    final container = _settingsContainer(
      user: buildUser().copyWith(prefsWeeklyDigest: false),
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
      user: buildUser().copyWith(prefsWeeklyDigest: false),
      userRepository: userRepository,
      blockedUsers: const [],
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);
    await tester.tap(find.byKey(SettingsKeys.weeklyDigestSwitch));
    await pumpFeatureUi(tester);

    final weeklyDigestField = tester.widget<CatchField>(
      find.byKey(SettingsKeys.weeklyDigestSwitch),
    );
    expect(weeklyDigestField.toggled, isFalse);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
  });

  testWidgets('blocked account rows use profile data and unblock controller', (
    tester,
  ) async {
    final safetyRepository = _FakeSettingsSafetyRepository();
    final container = _settingsContainer(
      user: buildUser(),
      safetyRepository: safetyRepository,
      blockedUsers: [
        BlockedUser(
          uid: 'blocked-1',
          source: 'chat',
          createdAt: DateTime(2026, 5),
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

    await tester.scrollUntilVisible(
      find.byKey(SettingsKeys.unblockButton('blocked-1')),
      240,
    );
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
      user: buildUser(),
      blockedUsers: const [],
      authRepository: authRepository,
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);

    expect(find.byKey(SettingsKeys.reviewHistoryRow), findsOneWidget);
    expect(find.byKey(SettingsKeys.paymentHistoryRow), findsOneWidget);
    expect(find.byKey(SettingsKeys.hostAppRow), findsOneWidget);
    expect(find.byKey(SettingsKeys.eventPolicyLabRow), findsOneWidget);
    expect(find.byKey(SettingsKeys.eventSuccessLabRow), findsOneWidget);
    expect(find.byKey(SettingsKeys.eventSuccessManualQaRow), findsOneWidget);
    expect(find.byKey(SettingsKeys.signOutRow), findsOneWidget);

    await tester.ensureVisible(find.byKey(SettingsKeys.signOutRow));
    await tester.pump();
    await tester.tap(find.byKey(SettingsKeys.signOutRow));
    await pumpFeatureUi(tester);

    expect(authRepository.signOutCallCount, 1);
  });

  testWidgets('host app row opens the central handoff link', (tester) async {
    Uri? launchedUri;
    LaunchMode? launchMode;
    final container = _settingsContainer(
      user: buildUser(),
      blockedUsers: const [],
      externalUrlLauncher: (uri, {mode = LaunchMode.platformDefault}) async {
        launchedUri = uri;
        launchMode = mode;
        return true;
      },
    );
    addTearDown(container.dispose);

    await _pumpSettings(tester, container);
    await tester.tap(find.byKey(SettingsKeys.hostAppRow));
    await pumpFeatureUi(tester);

    expect(launchedUri, Uri.parse('https://catchdates.com/host'));
    expect(launchMode, LaunchMode.externalApplication);
  });

  testWidgets('delete account confirmation delegates to controller', (
    tester,
  ) async {
    final safetyRepository = _FakeSettingsSafetyRepository();
    final container = _settingsContainer(
      user: buildUser(),
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
  Stream<List<BlockedUser>>? blockedUsersStream,
  Stream<UserProfile?>? profileStream,
  UserProfileRepository? userRepository,
  SafetyRepository? safetyRepository,
  AuthRepository? authRepository,
  ExternalUrlLauncher? externalUrlLauncher,
  Map<String, PublicProfile> publicProfiles = const {},
}) {
  final container = ProviderContainer(
    overrides: [
      uidProvider.overrideWith((ref) => Stream.value(user.uid)),
      authRepositoryProvider.overrideWithValue(
        authRepository ?? _FakeSettingsAuthRepository(),
      ),
      if (externalUrlLauncher != null)
        externalUrlLauncherProvider.overrideWithValue(externalUrlLauncher),
      watchUserProfileProvider.overrideWith(
        (ref) => profileStream ?? Stream.value(user),
      ),
      userProfileRepositoryProvider.overrideWith(
        (ref) => userRepository ?? _FakeSettingsUserProfileRepository(),
      ),
      safetyRepositoryProvider.overrideWith(
        (ref) => safetyRepository ?? _FakeSettingsSafetyRepository(),
      ),
      watchBlockedUsersProvider.overrideWith(
        (ref) => blockedUsersStream ?? Stream.value(blockedUsers),
      ),
      publicProfilesByIdsProvider(
        PublicProfilesQuery(blockedUsers.map((blocked) => blocked.uid)),
      ).overrideWith((ref) async => publicProfiles),
    ],
  );
  return container;
}

Future<void> _pumpSettings(
  WidgetTester tester,
  ProviderContainer container,
) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = const Size(390, 1400);
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
    required UpdateUserProfilePatch patch,
    String action = 'update profile',
  }) async {
    if (throwOnUpdate) {
      throw Exception('update failed');
    }
    updatedUid = uid;
    updatedFields = Map<String, dynamic>.from(patch.toFieldsJson());
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
