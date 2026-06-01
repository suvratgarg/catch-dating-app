import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
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
  final Set<String> _markingReadIds = <String>{};

  @override
  Widget build(BuildContext context) {
    final uidAsync = ref.watch(uidProvider);

    return Scaffold(
      appBar: const CatchTopBar(title: 'Notifications'),
      body: uidAsync.when(
        loading: () => const CatchLoadingIndicator(),
        error: (error, stackTrace) => const ActivitySignedOutState(),
        data: (uid) {
          if (uid == null) return const ActivitySignedOutState();

          final notificationsAsync = ref.watch(
            watchActivityNotificationsProvider(uid),
          );
          if (notificationsAsync.asData?.value case final notifications?) {
            _markUnreadAfterOpen(uid: uid, notifications: notifications);
          }

          return ListView(
            padding: CatchInsets.pageBodyRelaxedTight,
            children: [ActivitySection(uid: uid, showMarkAllReadAction: false)],
          );
        },
      ),
    );
  }

  void _markUnreadAfterOpen({
    required String uid,
    required List<ActivityNotification> notifications,
  }) {
    final unread = notifications
        .where(
          (notification) =>
              notification.isUnread &&
              !_markingReadIds.contains(notification.id),
        )
        .toList(growable: false);
    if (unread.isEmpty) return;

    _markingReadIds.addAll(unread.map((notification) => notification.id));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_markAllRead(uid: uid, notifications: unread));
    });
  }

  Future<void> _markAllRead({
    required String uid,
    required List<ActivityNotification> notifications,
  }) async {
    try {
      await ref
          .read(activityControllerProvider.notifier)
          .markAllRead(notifications: notifications, uid: uid);
    } catch (error, stackTrace) {
      _markingReadIds.removeAll(notifications.map((item) => item.id));
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
