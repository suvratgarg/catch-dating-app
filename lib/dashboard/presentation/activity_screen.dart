import 'dart:async';

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_async_value_view.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_controller.dart';
import 'package:catch_dating_app/dashboard/presentation/notification_route_util.dart';
import 'package:catch_dating_app/dashboard/presentation/notifications_list_state.dart';
import 'package:catch_dating_app/dashboard/presentation/notifications_list_view_model.dart';
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
    final notificationsAsync = uid == null
        ? null
        : ref.watch(watchActivityNotificationsProvider(uid));
    final markAllReadMutation = ref.watch(
      ActivityController.markAllReadMutation,
    );
    final state = buildNotificationsListState(
      uid: uidAsync,
      notifications: notificationsAsync,
      now: DateTime.now(),
      markAllReadPending: markAllReadMutation.isPending,
    );

    return Scaffold(
      backgroundColor: t.bg,
      appBar: CatchTopBar(
        title: 'Activity',
        actions: [
          if (state.showMarkAllReadAction)
            CatchTextButton(
              label: state.markAllReadLabel,
              onPressed: state.canMarkAllRead
                  ? () => unawaited(
                      _markAllRead(
                        uid: state.uid!,
                        notifications: state.unreadNotifications,
                      ),
                    )
                  : null,
            ),
        ],
      ),
      body: CatchAsyncValueView<String?>(
        value: uidAsync,
        loadingBuilder: (_) => const ActivityScreenLoading(),
        errorBuilder: (_, _, _) => const ActivitySignedOutState(),
        builder: (context, uid) {
          if (uid == null) return const ActivitySignedOutState();
          return CatchAsyncValueView<List<ActivityNotification>>(
            value:
                notificationsAsync ??
                const AsyncLoading<List<ActivityNotification>>(),
            loadingBuilder: (_) => const ActivityScreenLoading(),
            errorBuilder: (context, error, _) => ActivityScreenBody(
              state: NotificationsActivityError(uid: uid, error: error),
              onRetry: () =>
                  ref.invalidate(watchActivityNotificationsProvider(uid)),
              onOpenRoute: _openNotificationRoute,
            ),
            builder: (context, _) => ActivityScreenBody(
              state: state,
              onRetry: state.uid == null
                  ? null
                  : () {
                      ref.invalidate(
                        watchActivityNotificationsProvider(state.uid!),
                      );
                    },
              onOpenRoute: _openNotificationRoute,
            ),
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
      await ActivityController.markAllReadMutation.run(
        ref,
        (tx) async => tx
            .get(activityControllerProvider.notifier)
            .markAllRead(notifications: unread, uid: uid),
      );
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

  void _openNotificationRoute(String route) {
    openNotificationRoute(context, route);
  }
}

class ActivityScreenLoading extends StatelessWidget {
  const ActivityScreenLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: CatchInsets.pageBodyUnderHeader,
      children: const [ActivitySectionSkeleton()],
    );
  }
}

class ActivityScreenBody extends StatelessWidget {
  const ActivityScreenBody({
    super.key,
    required this.state,
    this.onRetry,
    required this.onOpenRoute,
  });

  final NotificationsListState state;
  final VoidCallback? onRetry;
  final ValueChanged<String> onOpenRoute;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: CatchInsets.pageBodyUnderHeader,
      children: [
        ActivitySection.fromState(
          state: state,
          onRetry: onRetry,
          onOpenRoute: onOpenRoute,
        ),
      ],
    );
  }
}
