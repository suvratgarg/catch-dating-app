import 'package:flutter/widgets.dart';

abstract final class SettingsKeys {
  static const showOnMapSwitch = ValueKey('settings.showOnMap.switch');
  static const newCatchesSwitch = ValueKey('settings.newCatches.switch');
  static const messagesSwitch = ValueKey('settings.messages.switch');
  static const runRemindersSwitch = ValueKey('settings.runReminders.switch');
  static const runStatusUpdatesSwitch = ValueKey(
    'settings.runStatusUpdates.switch',
  );
  static const clubUpdatesSwitch = ValueKey('settings.clubUpdates.switch');
  static const weeklyDigestSwitch = ValueKey('settings.weeklyDigest.switch');
  static const reviewHistoryRow = ValueKey('settings.reviewHistory.row');
  static const paymentHistoryRow = ValueKey('settings.paymentHistory.row');
  static const eventPolicyLabRow = ValueKey('settings.eventPolicyLab.row');
  static const signOutRow = ValueKey('settings.signOut.row');
  static const deleteAccountRow = ValueKey('settings.deleteAccount.row');

  static Key unblockButton(String uid) => ValueKey('settings.unblock.$uid');
}
