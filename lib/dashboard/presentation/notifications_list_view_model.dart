import 'package:catch_dating_app/dashboard/presentation/notifications_list_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

NotificationsListState buildNotificationsListState({
  required AsyncValue<String?> uid,
  required AsyncValue<List<ActivityNotification>>? notifications,
  required DateTime now,
  required AppLocalizations l10n,
  bool markAllReadPending = false,
}) {
  if (uid.isLoading && !uid.hasValue) {
    return const NotificationsAccessLoading();
  }

  if (uid.hasError && !uid.hasValue) {
    return NotificationsAccessError(error: uid.error!);
  }

  final userId = uid.asData?.value;
  if (userId == null) {
    return const NotificationsSignedOut();
  }

  final notificationsAsync = notifications;
  if (notificationsAsync == null ||
      (notificationsAsync.isLoading && !notificationsAsync.hasValue)) {
    return NotificationsActivityLoading(uid: userId);
  }

  final error = notificationsAsync.error;
  if (error != null && !notificationsAsync.hasValue) {
    return NotificationsActivityError(uid: userId, error: error);
  }

  final visibleNotifications =
      (notificationsAsync.asData?.value ?? const <ActivityNotification>[])
          .where((notification) => notification.isVisibleInActivity)
          .toList(growable: false);
  if (visibleNotifications.isEmpty) {
    return NotificationsEmpty(uid: userId);
  }

  return NotificationsContent(
    uid: userId,
    visibleNotifications: visibleNotifications,
    groups: groupNotificationRows(
      notificationRowsFromNotifications(
        visibleNotifications,
        now: now,
        l10n: l10n,
      ),
      now: now,
      l10n: l10n,
    ),
    markAllReadPending: markAllReadPending,
  );
}
