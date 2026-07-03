import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/dashboard/presentation/notification_route_util.dart';
import 'package:catch_dating_app/dashboard/presentation/notifications_list_state.dart';
import 'package:catch_dating_app/dashboard/presentation/notifications_list_view_model.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ActivitySignedOutState extends StatelessWidget {
  const ActivitySignedOutState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.contentRelaxed,
      child: CatchEmptyState(
        icon: CatchIcons.notificationsNoneRounded,
        title: 'No activity yet',
        message: 'Sign in and book an event to start seeing updates here.',
      ),
    );
  }
}

class ActivitySection extends ConsumerWidget {
  const ActivitySection({
    super.key,
    required this.uid,
    this.state,
    this.showEmptyState = true,
    this.showMarkAllReadAction = true,
    this.onRetry,
    this.onOpenRoute,
  });

  const ActivitySection.fromState({
    super.key,
    required this.state,
    this.showEmptyState = true,
    this.onRetry,
    this.onOpenRoute,
  }) : uid = null,
       showMarkAllReadAction = false;

  final String? uid;
  final NotificationsListState? state;
  final bool showEmptyState;
  final bool showMarkAllReadAction;
  final VoidCallback? onRetry;
  final ValueChanged<String>? onOpenRoute;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final sectionState =
        state ??
        buildNotificationsListState(
          uid: AsyncData(uid!),
          notifications: ref.watch(watchActivityNotificationsProvider(uid!)),
          now: DateTime.now(),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (sectionState is NotificationsActivityLoading ||
            sectionState is NotificationsAccessLoading) ...[
          const ActivitySectionSkeleton(count: 2),
        ] else if (sectionState is NotificationsActivityError) ...[
          if (sectionState.error case final error?)
            CatchInlineErrorState.fromError(
              error,
              context: AppErrorContext.dashboard,
              compact: true,
              onRetry:
                  onRetry ??
                  (uid == null
                      ? null
                      : () {
                          ref.invalidate(
                            watchActivityNotificationsProvider(uid!),
                          );
                        }),
            )
          else
            CatchInlineErrorState(
              title: 'Activity unavailable',
              message: 'Could not load activity.',
              compact: true,
              onRetry:
                  onRetry ??
                  (uid == null
                      ? null
                      : () {
                          ref.invalidate(
                            watchActivityNotificationsProvider(uid!),
                          );
                        }),
            ),
        ] else if (sectionState is NotificationsEmpty ||
            sectionState is NotificationsSignedOut) ...[
          if (showEmptyState)
            CatchEmptyState(
              icon: CatchIcons.notificationsNoneRounded,
              title: 'No new activity',
              message:
                  'New catches, bookings, and event reminders will collect here.',
              iconSize: CatchIcon.emptyState,
              titleStyle: CatchTextStyles.titleL(context),
              messageStyle: CatchTextStyles.supporting(context, color: t.ink2),
            ),
        ] else if (sectionState is NotificationsContent) ...[
          NotificationDayGroups(
            groups: sectionState.groups,
            onOpenRoute: onOpenRoute,
          ),
        ] else ...[
          const SizedBox.shrink(),
        ],
      ],
    );
  }
}

class NotificationDayGroups extends StatelessWidget {
  const NotificationDayGroups({
    super.key,
    required this.groups,
    this.onOpenRoute,
  });

  final List<NotificationDayGroup> groups;
  final ValueChanged<String>? onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final groupEntry in groups.indexed)
          Padding(
            padding: EdgeInsets.only(
              top: groupEntry.$1 == 0 ? 0 : CatchSpacing.s2,
            ),
            child: DecoratedBox(
              decoration: BoxDecoration(
                border: groupEntry.$1 == 0
                    ? const Border()
                    : Border(top: BorderSide(color: t.line)),
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: groupEntry.$1 == 0 ? 0 : CatchSpacing.micro18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      groupEntry.$2.label.toUpperCase(),
                      style: CatchTextStyles.kicker(context, color: t.ink2),
                    ),
                    gapH8,
                    NotificationGroupWidget(
                      rows: groupEntry.$2.rows,
                      onOpenRoute: onOpenRoute,
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class ActivitySectionSkeleton extends StatelessWidget {
  const ActivitySectionSkeleton({super.key, this.count = 4});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchSkeleton.text(width: CatchLayout.skeletonTextMetaLabelWidth),
        gapH8,
        for (var i = 0; i < count; i++) NotificationRowSkeleton(divider: i > 0),
      ],
    );
  }
}

class NotificationRowSkeleton extends StatelessWidget {
  const NotificationRowSkeleton({super.key, required this.divider});

  final bool divider;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final row = Padding(
      padding: CatchInsets.contentVerticalMedium,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.box(
            width: CatchIcon.md,
            height: CatchIcon.md,
            radius: CatchRadius.sm,
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: CatchSkeleton.text()),
                    gapW8,
                    CatchSkeleton.text(
                      width: CatchLayout.skeletonTextTimeWidth,
                    ),
                  ],
                ),
                gapH6,
                CatchSkeleton.textBlock(lines: 2),
              ],
            ),
          ),
        ],
      ),
    );

    return Stack(
      children: [
        if (divider)
          Positioned(
            top: 0,
            left: CatchIcon.md + CatchSpacing.s3,
            right: 0,
            child: Divider(
              height: 1,
              color: t.line.withValues(alpha: CatchOpacity.subtleBorder),
            ),
          ),
        row,
      ],
    );
  }
}

class NotificationRow extends StatelessWidget {
  const NotificationRow({
    super.key,
    this.type = ActivityNotificationType.eventReminder,
    this.title = '',
    this.time = '',
    this.body = '',
    this.unread = false,
    this.divider = false,
    this.onTap,
  });

  final ActivityNotificationType type;
  final String title;
  final String time;
  final String body;
  final bool unread;
  final bool divider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = _NotificationVisual.from(type, t);
    final timeColor = unread ? t.primary : t.ink3;
    final timeLabel = time.trim().toUpperCase();

    return Semantics(
      button: onTap != null,
      label: body.isEmpty ? title : '$title. $body',
      child: CatchField.nav(
        icon: visual.icon,
        iconColor: visual.accent,
        title: title,
        body: body,
        titleMaxLines: 2,
        emphasis: CatchFieldEmphasis.title,
        showChevron: false,
        divider: divider,
        action: timeLabel.isEmpty
            ? null
            : Text(
                timeLabel,
                style: CatchTextStyles.monoLabelS(context, color: timeColor),
              ),
        onTap: onTap,
      ),
    );
  }
}

class NotificationGroupWidget extends StatelessWidget {
  const NotificationGroupWidget({
    super.key,
    required this.rows,
    this.onOpenRoute,
  });

  final List<NotificationRowDisplay> rows;
  final ValueChanged<String>? onOpenRoute;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in rows.indexed)
          NotificationRow(
            type: entry.$2.type,
            title: entry.$2.title,
            time: entry.$2.timeLabel,
            body: entry.$2.subtitle,
            unread: entry.$2.isUnread,
            divider: entry.$1 > 0,
            onTap: entry.$2.route == null
                ? null
                : () =>
                      (onOpenRoute ??
                      (route) => openNotificationRoute(context, route))(
                        entry.$2.route!,
                      ),
          ),
      ],
    );
  }
}

class _NotificationVisual {
  const _NotificationVisual({required this.icon, required this.accent});

  final IconData icon;
  final Color accent;

  static _NotificationVisual from(
    ActivityNotificationType type,
    CatchTokens t,
  ) {
    _NotificationVisual visual({
      required IconData icon,
      required Color accent,
    }) {
      return _NotificationVisual(icon: icon, accent: accent);
    }

    return switch (type) {
      ActivityNotificationType.message => visual(
        icon: CatchIcons.chatBubbleOutlineRounded,
        accent: t.ink2,
      ),
      ActivityNotificationType.match => visual(
        icon: CatchIcons.favoriteRounded,
        accent: t.primary,
      ),
      ActivityNotificationType.eventReminder => visual(
        icon: CatchIcons.notificationsNoneRounded,
        accent: t.primary,
      ),
      ActivityNotificationType.eventSignup => visual(
        icon: CatchIcons.checkCircleOutlineRounded,
        accent: t.success,
      ),
      ActivityNotificationType.waitlistPromotion => visual(
        icon: CatchIcons.scheduleRounded,
        accent: t.warning,
      ),
      ActivityNotificationType.eventCancelled => visual(
        icon: CatchIcons.eventBusyRounded,
        accent: t.danger,
      ),
      ActivityNotificationType.eventUpdated => visual(
        icon: CatchIcons.updateRounded,
        accent: t.ink2,
      ),
      ActivityNotificationType.clubUpdate => visual(
        icon: CatchIcons.groupsRounded,
        accent: t.ink2,
      ),
    };
  }
}
