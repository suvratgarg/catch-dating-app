import 'package:flutter/widgets.dart';

abstract final class SettingsKeys {
  static const showOnMapSwitch = ValueKey('settings.showOnMap.switch');
  static const newCatchesSwitch = ValueKey('settings.newCatches.switch');
  static const runRemindersSwitch = ValueKey('settings.runReminders.switch');
  static const weeklyDigestSwitch = ValueKey('settings.weeklyDigest.switch');
  static const deleteAccountRow = ValueKey('settings.deleteAccount.row');

  static Key unblockButton(String uid) => ValueKey('settings.unblock.$uid');
}
