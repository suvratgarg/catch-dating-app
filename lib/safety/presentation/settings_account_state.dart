import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/safety/data/safety_repository.dart';
import 'package:catch_dating_app/safety/presentation/settings_controller.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:country_code_picker/country_code_picker.dart';

final class SettingsAccountState {
  const SettingsAccountState({
    required this.profile,
    required this.preferences,
    required this.blockedAccounts,
    required this.mutations,
  });

  final SettingsProfileState profile;
  final SettingsPreferenceValues preferences;
  final SettingsBlockedAccountsState blockedAccounts;
  final SettingsMutationState mutations;
}

enum SettingsProfileStatus { loading, error, missing, loaded }

final class SettingsProfileState {
  const SettingsProfileState({
    required this.status,
    required this.phoneNumber,
    required this.email,
    this.error,
  });

  final SettingsProfileStatus status;
  final String phoneNumber;
  final String email;
  final Object? error;

  bool get isError => status == SettingsProfileStatus.error;
  bool get isMissing => status == SettingsProfileStatus.missing;
}

final class SettingsPreferenceValues {
  const SettingsPreferenceValues({
    required this.showInCrossPaths,
    required this.showOnMap,
    required this.newCatches,
    required this.messages,
    required this.eventReminders,
    required this.eventStatusUpdates,
    required this.clubUpdates,
    required this.weeklyDigest,
  });

  const SettingsPreferenceValues.defaults()
    : showInCrossPaths = false,
      showOnMap = true,
      newCatches = true,
      messages = true,
      eventReminders = true,
      eventStatusUpdates = true,
      clubUpdates = true,
      weeklyDigest = false;

  factory SettingsPreferenceValues.fromProfile(UserProfile profile) {
    return SettingsPreferenceValues(
      showInCrossPaths: profile.prefsShowInCrossPaths,
      showOnMap: profile.prefsShowOnMap,
      newCatches: profile.prefsNewCatches,
      messages: profile.prefsMessages,
      eventReminders: profile.prefsEventReminders,
      eventStatusUpdates: profile.prefsRunStatusUpdates,
      clubUpdates: profile.prefsClubUpdates,
      weeklyDigest: profile.prefsWeeklyDigest,
    );
  }

  final bool showInCrossPaths;
  final bool showOnMap;
  final bool newCatches;
  final bool messages;
  final bool eventReminders;
  final bool eventStatusUpdates;
  final bool clubUpdates;
  final bool weeklyDigest;

  bool valueFor(SettingsPreference preference) {
    return switch (preference) {
      SettingsPreference.showInCrossPaths => showInCrossPaths,
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
      SettingsPreference.showInCrossPaths => SettingsPreferenceValues(
        showInCrossPaths: value,
        showOnMap: showOnMap,
        newCatches: newCatches,
        messages: messages,
        eventReminders: eventReminders,
        eventStatusUpdates: eventStatusUpdates,
        clubUpdates: clubUpdates,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.showOnMap => SettingsPreferenceValues(
        showInCrossPaths: showInCrossPaths,
        showOnMap: value,
        newCatches: newCatches,
        messages: messages,
        eventReminders: eventReminders,
        eventStatusUpdates: eventStatusUpdates,
        clubUpdates: clubUpdates,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.newCatches => SettingsPreferenceValues(
        showInCrossPaths: showInCrossPaths,
        showOnMap: showOnMap,
        newCatches: value,
        messages: messages,
        eventReminders: eventReminders,
        eventStatusUpdates: eventStatusUpdates,
        clubUpdates: clubUpdates,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.messages => SettingsPreferenceValues(
        showInCrossPaths: showInCrossPaths,
        showOnMap: showOnMap,
        newCatches: newCatches,
        messages: value,
        eventReminders: eventReminders,
        eventStatusUpdates: eventStatusUpdates,
        clubUpdates: clubUpdates,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.eventReminders => SettingsPreferenceValues(
        showInCrossPaths: showInCrossPaths,
        showOnMap: showOnMap,
        newCatches: newCatches,
        messages: messages,
        eventReminders: value,
        eventStatusUpdates: eventStatusUpdates,
        clubUpdates: clubUpdates,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.eventStatusUpdates => SettingsPreferenceValues(
        showInCrossPaths: showInCrossPaths,
        showOnMap: showOnMap,
        newCatches: newCatches,
        messages: messages,
        eventReminders: eventReminders,
        eventStatusUpdates: value,
        clubUpdates: clubUpdates,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.clubUpdates => SettingsPreferenceValues(
        showInCrossPaths: showInCrossPaths,
        showOnMap: showOnMap,
        newCatches: newCatches,
        messages: messages,
        eventReminders: eventReminders,
        eventStatusUpdates: eventStatusUpdates,
        clubUpdates: value,
        weeklyDigest: weeklyDigest,
      ),
      SettingsPreference.weeklyDigest => SettingsPreferenceValues(
        showInCrossPaths: showInCrossPaths,
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
  const SettingsBlockedAccountsState({
    required this.status,
    required this.rows,
    this.error,
  });

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

  bool get operationPending =>
      savingPreference || deletingAccount || signingOut || unblocking;
}

String settingsEmailForDisplay(String email) {
  final trimmed = email.trim();
  return trimmed.isEmpty ? 'Not added' : trimmed;
}

String settingsFormatPhoneForDisplay(String phoneNumber) {
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
