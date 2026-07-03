import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_account_state.dart';
import 'package:catch_dating_app/safety/presentation/settings_account_view_model.dart';
import 'package:catch_dating_app/safety/presentation/settings_controller.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';

void main() {
  test('maps loaded profile and blocked-account rows into display state', () {
    final user = buildUser(phoneNumber: '+919876543210');
    final blockedUsers = [
      BlockedUser(
        uid: 'blocked-1',
        source: 'chat',
        createdAt: DateTime(2026, 6, 22),
      ),
      BlockedUser(
        uid: 'blocked-2',
        source: 'profile',
        createdAt: DateTime(2026, 6, 21),
      ),
    ];

    final state = buildSettingsAccountState(
      profile: AsyncData<UserProfile?>(user),
      preferences: SettingsPreferenceValues.fromProfile(user),
      blockedUsers: AsyncData(blockedUsers),
      blockedProfiles: const AsyncData({
        'blocked-1': PublicProfile(
          uid: 'blocked-1',
          name: 'Riya',
          age: 30,
          gender: Gender.woman,
        ),
      }),
      mutations: const SettingsMutationState(
        savingPreference: false,
        deletingAccount: false,
        signingOut: false,
        unblocking: false,
      ),
    );

    expect(state.profile.phoneNumber, '+91 9876543210');
    expect(state.profile.email, 'runner@example.com');
    expect(state.blockedAccounts.count, 2);
    expect(state.blockedAccounts.rows.first.name, 'Riya');
    expect(state.blockedAccounts.rows.last.name, 'Blocked account');
  });

  test('keeps preference updates isolated to the selected field', () {
    const preferences = SettingsPreferenceValues.defaults();

    final updated = preferences.copyWithPreference(
      SettingsPreference.weeklyDigest,
      true,
    );

    expect(updated.weeklyDigest, isTrue);
    expect(updated.newCatches, preferences.newCatches);
    expect(updated.showOnMap, preferences.showOnMap);
  });

  test('models profile provider loading, error, and missing states', () {
    final error = StateError('profile failed');

    expect(
      buildSettingsProfileState(const AsyncLoading<UserProfile?>()).status,
      SettingsProfileStatus.loading,
    );
    expect(
      buildSettingsProfileState(
        AsyncError<UserProfile?>(error, StackTrace.empty),
      ).error,
      error,
    );
    expect(
      buildSettingsProfileState(const AsyncData<UserProfile?>(null)).status,
      SettingsProfileStatus.missing,
    );
  });
}
