import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_controller.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final class SettingsAccountState {
  const SettingsAccountState({
    required this.profile,
    required this.preferences,
    required this.blockedAccounts,
    required this.mutations,
  });

  factory SettingsAccountState.fromAsync({
    required AsyncValue<UserProfile?> profile,
    required SettingsPreferenceValues preferences,
    required AsyncValue<List<BlockedUser>> blockedUsers,
    required AsyncValue<Map<String, PublicProfile>> blockedProfiles,
    required SettingsMutationState mutations,
  }) {
    return SettingsAccountState(
      profile: SettingsProfileState.fromAsync(profile),
      preferences: preferences,
      blockedAccounts: SettingsBlockedAccountsState.fromAsync(
        blockedUsers: blockedUsers,
        blockedProfiles: blockedProfiles,
      ),
      mutations: mutations,
    );
  }

  final SettingsProfileState profile;
  final SettingsPreferenceValues preferences;
  final SettingsBlockedAccountsState blockedAccounts;
  final SettingsMutationState mutations;
}

enum SettingsProfileStatus { loading, error, missing, loaded }

final class SettingsProfileState {
  const SettingsProfileState._({
    required this.status,
    required this.phoneNumber,
    required this.email,
    this.error,
  });

  factory SettingsProfileState.fromAsync(AsyncValue<UserProfile?> profile) {
    return switch (profile) {
      AsyncData(:final value) =>
        value == null
            ? const SettingsProfileState._(
                status: SettingsProfileStatus.missing,
                phoneNumber: 'Unavailable',
                email: 'Unavailable',
              )
            : SettingsProfileState._(
                status: SettingsProfileStatus.loaded,
                phoneNumber: _formatPhoneForDisplay(value.phoneNumber),
                email: _emailForDisplay(value.email),
              ),
      AsyncError(:final error) => SettingsProfileState._(
        status: SettingsProfileStatus.error,
        phoneNumber: 'Unavailable',
        email: 'Unavailable',
        error: error,
      ),
      _ => const SettingsProfileState._(
        status: SettingsProfileStatus.loading,
        phoneNumber: 'Loading',
        email: 'Loading',
      ),
    };
  }

  final SettingsProfileStatus status;
  final String phoneNumber;
  final String email;
  final Object? error;

  bool get isError => status == SettingsProfileStatus.error;
  bool get isMissing => status == SettingsProfileStatus.missing;
}

final class SettingsPreferenceValues {
  const SettingsPreferenceValues({
    required this.showOnMap,
    required this.newCatches,
    required this.messages,
    required this.eventReminders,
    required this.eventStatusUpdates,
    required this.clubUpdates,
    required this.weeklyDigest,
  });

  const SettingsPreferenceValues.defaults()
    : showOnMap = true,
      newCatches = true,
      messages = true,
      eventReminders = true,
      eventStatusUpdates = true,
      clubUpdates = true,
      weeklyDigest = false;

  factory SettingsPreferenceValues.fromProfile(UserProfile profile) {
    return SettingsPreferenceValues(
      showOnMap: profile.prefsShowOnMap,
      newCatches: profile.prefsNewCatches,
      messages: profile.prefsMessages,
      eventReminders: profile.prefsEventReminders,
      eventStatusUpdates: profile.prefsRunStatusUpdates,
      clubUpdates: profile.prefsClubUpdates,
      weeklyDigest: profile.prefsWeeklyDigest,
    );
  }

  final bool showOnMap;
  final bool newCatches;
  final bool messages;
  final bool eventReminders;
  final bool eventStatusUpdates;
  final bool clubUpdates;
  final bool weeklyDigest;

  bool valueFor(SettingsPreference preference) {
    return switch (preference) {
      SettingsPreference.showOnMap => showOnMap,
      SettingsPreference.newCatches => newCatches,
      SettingsPreference.messages => messages,
      SettingsPreference.eventReminders => eventReminders,
      SettingsPreference.eventStatusUpdates => eventStatusUpdates,
      SettingsPreference.clubUpdates => clubUpdates,
      SettingsPreference.weeklyDigest => weeklyDigest,
    };
  }

  SettingsPreferenceValues copyWithPreference(
    SettingsPreference preference,
    bool value,
  ) {
    return switch (preference) {
      SettingsPreference.showOnMap => SettingsPreferenceValues(
        showOnMap: value,
        newCatches: newCatches,
        messages: messages,
        eventReminders: eventReminders,
        eventStatusUpdates: eventStatusUpdates,
        clubUpdates: clubUpdates,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.newCatches => SettingsPreferenceValues(
        showOnMap: showOnMap,
        newCatches: value,
        messages: messages,
        eventReminders: eventReminders,
        eventStatusUpdates: eventStatusUpdates,
        clubUpdates: clubUpdates,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.messages => SettingsPreferenceValues(
        showOnMap: showOnMap,
        newCatches: newCatches,
        messages: value,
        eventReminders: eventReminders,
        eventStatusUpdates: eventStatusUpdates,
        clubUpdates: clubUpdates,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.eventReminders => SettingsPreferenceValues(
        showOnMap: showOnMap,
        newCatches: newCatches,
        messages: messages,
        eventReminders: value,
        eventStatusUpdates: eventStatusUpdates,
        clubUpdates: clubUpdates,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.eventStatusUpdates => SettingsPreferenceValues(
        showOnMap: showOnMap,
        newCatches: newCatches,
        messages: messages,
        eventReminders: eventReminders,
        eventStatusUpdates: value,
        clubUpdates: clubUpdates,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.clubUpdates => SettingsPreferenceValues(
        showOnMap: showOnMap,
        newCatches: newCatches,
        messages: messages,
        eventReminders: eventReminders,
        eventStatusUpdates: eventStatusUpdates,
        clubUpdates: value,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.weeklyDigest => SettingsPreferenceValues(
        showOnMap: showOnMap,
        newCatches: newCatches,
        messages: messages,
        eventReminders: eventReminders,
        eventStatusUpdates: eventStatusUpdates,
        clubUpdates: clubUpdates,
        weeklyDigest: value,
      ),
    };
  }
}

enum SettingsBlockedAccountsStatus { loading, error, empty, content }

final class SettingsBlockedAccountsState {
  const SettingsBlockedAccountsState._({
    required this.status,
    required this.rows,
    this.error,
  });

  factory SettingsBlockedAccountsState.fromAsync({
    required AsyncValue<List<BlockedUser>> blockedUsers,
    required AsyncValue<Map<String, PublicProfile>> blockedProfiles,
  }) {
    return switch (blockedUsers) {
      AsyncError(:final error) => SettingsBlockedAccountsState._(
        status: SettingsBlockedAccountsStatus.error,
        rows: const [],
        error: error,
      ),
      AsyncData(:final value) =>
        value.isEmpty
            ? const SettingsBlockedAccountsState._(
                status: SettingsBlockedAccountsStatus.empty,
                rows: [],
              )
            : switch (blockedProfiles) {
                // Surface profile lookup errors instead of silently falling
                // through to null profiles.
                AsyncError(:final error) => SettingsBlockedAccountsState._(
                  status: SettingsBlockedAccountsStatus.error,
                  rows: [],
                  error: error,
                ),
                _ => SettingsBlockedAccountsState._(
                  status: SettingsBlockedAccountsStatus.content,
                  rows: [
                    for (final blocked in value)
                      SettingsBlockedAccountRow.fromBlockedUser(
                        blocked,
                        profile:
                            blockedProfiles.asData?.value[blocked.uid],
                      ),
                  ],
                ),
              },
      _ => const SettingsBlockedAccountsState._(
        status: SettingsBlockedAccountsStatus.loading,
        rows: [],
      ),
    };
  }

  final SettingsBlockedAccountsStatus status;
  final List<SettingsBlockedAccountRow> rows;
  final Object? error;

  int? get count {
    return switch (status) {
      SettingsBlockedAccountsStatus.empty => 0,
      SettingsBlockedAccountsStatus.content => rows.length,
      _ => null,
    };
  }
}

final class SettingsBlockedAccountRow {
  const SettingsBlockedAccountRow({
    required this.uid,
    required this.name,
    required this.imageUrl,
    required this.metaLine,
    required this.seed,
  });

  factory SettingsBlockedAccountRow.fromBlockedUser(
    BlockedUser blockedUser, {
    PublicProfile? profile,
  }) {
    return SettingsBlockedAccountRow(
      uid: blockedUser.uid,
      name: profile?.name ?? 'Blocked account',
      imageUrl: profile?.primaryPhotoThumbnailUrl,
      metaLine: blockedUser.source,
      seed: blockedUser.uid,
    );
  }

  final String uid;
  final String name;
  final String? imageUrl;
  final String metaLine;
  final String seed;
}

final class SettingsMutationState {
  const SettingsMutationState({
    required this.savingPreference,
    required this.deletingAccount,
    required this.signingOut,
    required this.unblocking,
  });

  final bool savingPreference;
  final bool deletingAccount;
  final bool signingOut;
  final bool unblocking;
}

String _emailForDisplay(String email) {
  final trimmed = email.trim();
  return trimmed.isEmpty ? 'Not added' : trimmed;
}

String _formatPhoneForDisplay(String phoneNumber) {
  if (phoneNumber.isEmpty) return '';
  if (!phoneNumber.startsWith('+')) return phoneNumber;

  final sortedCodes = codes.toList()
    ..sort((a, b) => b['dial_code']!.length.compareTo(a['dial_code']!.length));
  for (final c in sortedCodes) {
    final dialCode = c['dial_code']!;
    if (phoneNumber.startsWith(dialCode)) {
      final national = phoneNumber.substring(dialCode.length);
      return '$dialCode $national';
    }
  }
  return phoneNumber;
}
