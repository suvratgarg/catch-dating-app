import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_controller.dart';
import 'package:catch_dating_app/dashboard/presentation/widgets/activity_section.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final uidAsync = ref.watch(uidProvider);
    final uid = uidAsync.asData?.value;
    final visibleNotifications = uid == null
        ? const <ActivityNotification>[]
        : ref
                  .watch(watchActivityNotificationsProvider(uid))
                  .asData
                  ?.value
                  .where((notification) => notification.isVisibleInActivity)
                  .toList(growable: false) ??
              const <ActivityNotification>[];
    final hasUnread = visibleNotifications.any(
      (notification) => notification.isUnread,
    );

    return Scaffold(
      backgroundColor: t.bg,
      appBar: CatchTopBar(
        title: 'Activity',
        actions: [
          if (uid != null && hasUnread)
            CatchTextButton(
              label: 'Mark all read',
              onPressed: () => unawaited(
                _markAllRead(uid: uid, notifications: visibleNotifications),
              ),
            ),
        ],
      ),
      body: uidAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (error, stackTrace) => const ActivitySignedOutState(),
        data: (uid) {
          if (uid == null) return const ActivitySignedOutState();

          return ListView(
            padding: CatchInsets.pageBodyUnderHeader,
            children: [ActivitySection(uid: uid, showMarkAllReadAction: false)],
          );
        },
      ),
    );
  }

  Future<void> _markAllRead({
    required String uid,
    required List<ActivityNotification> notifications,
  }) async {
    final unread = notifications
        .where((notification) => notification.isUnread)
        .toList(growable: false);
    if (unread.isEmpty) return;
    try {
      await ref
          .read(activityControllerProvider.notifier)
          .markAllRead(notifications: unread, uid: uid);
    } catch (error, stackTrace) {
      ref
          .read(errorLoggerProvider)
          .logAppException(
            normalizeBackendError(
              error,
              stackTrace: stackTrace,
              context: const BackendErrorContext(
                service: BackendService.local,
                action: 'mark notifications read',
                resource: 'activity_screen',
              ),
            ),
          );
      if (mounted) showCatchErrorSnackBar(context, error);
    }
  }
}
