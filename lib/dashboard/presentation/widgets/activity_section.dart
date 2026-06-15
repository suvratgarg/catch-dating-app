import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/notifications/data/activity_notification_repository.dart';
import 'package:catch_dating_app/notifications/domain/activity_notification.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
        surface: false,
        iconStyle: CatchEmptyStateIconStyle.plain,
      ),
    );
  }
}

class ActivitySection extends ConsumerWidget {
  const ActivitySection({
    super.key,
    required this.uid,
    this.showEmptyState = true,
    this.showMarkAllReadAction = true,
  });

  final String uid;
  final bool showEmptyState;
  final bool showMarkAllReadAction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final notificationsAsync = ref.watch(
      watchActivityNotificationsProvider(uid),
    );

    final isLoading = notificationsAsync.isLoading;
    final error = notificationsAsync.error;
    final notifications =
        notificationsAsync.asData?.value ?? const <ActivityNotification>[];
    final visibleNotifications = notifications
        .where((notification) => notification.isVisibleInActivity)
        .toList(growable: false);
    final notificationItems = _NotificationItem.fromNotifications(
      visibleNotifications,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading) ...[
          CatchSurface(
            padding: CatchInsets.content,
            borderColor: t.line,
            child: const Row(
              children: [
                SizedBox(
                  width: CatchLayout.activityLoadingIndicatorExtent,
                  height: CatchLayout.activityLoadingIndicatorExtent,
                  child: CatchLoadingIndicator(strokeWidth: 2),
                ),
                gapW10,
                Expanded(child: _ActivityStateLabel('Loading activity...')),
              ],
            ),
          ),
        ] else if (error != null) ...[
          CatchInlineErrorState(
            title: 'Activity unavailable',
            message: 'Could not load activity.',
            compact: true,
            onRetry: () {
              ref.invalidate(watchActivityNotificationsProvider(uid));
            },
          ),
        ] else if (notificationItems.isEmpty) ...[
          if (showEmptyState)
            CatchEmptyState(
              icon: CatchIcons.notificationsNoneRounded,
              title: 'No new activity',
              message:
                  'New catches, bookings, and event reminders will collect here.',
              iconStyle: CatchEmptyStateIconStyle.plain,
              iconSize: CatchIcon.emptyState,
              titleStyle: CatchTextStyles.titleL(context),
              messageStyle: CatchTextStyles.supporting(context, color: t.ink2),
            ),
        ] else ...[
          _NotificationDayGroups(groups: _groupItems(notificationItems)),
        ],
      ],
    );
  }
}

class _NotificationDayGroups extends StatelessWidget {
  const _NotificationDayGroups({required this.groups});

  final List<_ActivityGroup> groups;

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
                    _NotificationGroup(items: groupEntry.$2.items),
                  ],
                ),
              ),
            ),
          ),
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
    final titleColor = unread ? t.ink : t.ink2;
    final timeColor = unread ? t.primary : t.ink3;
    final row = Padding(
      padding: CatchInsets.contentVerticalMedium,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: CatchIcon.md,
            child: Icon(visual.icon, color: visual.accent, size: CatchIcon.md),
          ),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.infoRowTitle(
                          context,
                          color: titleColor,
                        ),
                      ),
                    ),
                    gapW8,
                    Text(
                      time.toUpperCase(),
                      style: CatchTextStyles.monoLabelS(
                        context,
                        color: timeColor,
                      ),
                    ),
                  ],
                ),
                if (body.isNotEmpty) ...[
                  gapH3,
                  Text(
                    body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );

    return Semantics(
      button: onTap != null,
      label: body.isEmpty ? title : '$title. $body',
      child: Stack(
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
          if (onTap == null) row else InkWell(onTap: onTap, child: row),
        ],
      ),
    );
  }
}

class _NotificationGroup extends StatelessWidget {
  const _NotificationGroup({required this.items});

  final List<_NotificationItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final entry in items.indexed)
          NotificationRow(
            type: entry.$2.type,
            title: entry.$2.title,
            time: entry.$2.timeLabel,
            body: entry.$2.subtitle,
            unread: entry.$2.isUnread,
            divider: entry.$1 > 0,
            onTap: entry.$2.route == null
                ? null
                : () => context.push(entry.$2.route!),
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

class _ActivityGroup {
  const _ActivityGroup({required this.label, required this.items});

  final String label;
  final List<_NotificationItem> items;
}

class _NotificationItem {
  const _NotificationItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.timeLabel,
    required this.isUnread,
    this.route,
  });

  final ActivityNotificationType type;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final String timeLabel;
  final bool isUnread;
  final String? route;

  static List<_NotificationItem> fromNotifications(
    Iterable<ActivityNotification> notifications,
  ) {
    final now = DateTime.now();
    final items =
        notifications
            .where((notification) => notification.isVisibleInActivity)
            .map(
              (notification) =>
                  _NotificationItem.fromNotification(notification, now),
            )
            .toList(growable: false)
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  factory _NotificationItem.fromNotification(
    ActivityNotification notification,
    DateTime now,
  ) {
    return _NotificationItem(
      type: notification.type,
      title: notification.title,
      subtitle: notification.body,
      createdAt: notification.createdAt,
      route: _notificationRoute(notification),
      timeLabel: _relativeTime(notification.createdAt, now),
      isUnread: notification.isUnread,
    );
  }

  static String? _notificationRoute(ActivityNotification notification) {
    if (notification.matchId case final matchId?) {
      return Routes.chatScreen.path.replaceFirst(':matchId', matchId);
    }
    if (notification.eventId case final eventId?
        when notification.clubId != null) {
      return Routes.eventDetailScreen.path
          .replaceFirst(':clubId', notification.clubId!)
          .replaceFirst(':eventId', eventId);
    }
    if (notification.clubId case final clubId?) {
      return Routes.clubDetailScreen.path.replaceFirst(':clubId', clubId);
    }
    return null;
  }

  static String _relativeTime(DateTime time, DateTime now) {
    final difference = now.difference(time);
    if (difference.inMinutes < 1) return 'Now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }
}

List<_ActivityGroup> _groupItems(List<_NotificationItem> items) {
  final now = DateTime.now();
  final today = <_NotificationItem>[];
  final yesterday = <_NotificationItem>[];
  final thisWeek = <_NotificationItem>[];
  final earlier = <_NotificationItem>[];
  final weekAgo = now.subtract(const Duration(days: 7));

  for (final item in items) {
    if (DateUtils.isSameDay(item.createdAt, now)) {
      today.add(item);
    } else if (DateUtils.isSameDay(
      item.createdAt,
      now.subtract(const Duration(days: 1)),
    )) {
      yesterday.add(item);
    } else if (item.createdAt.isAfter(weekAgo)) {
      thisWeek.add(item);
    } else {
      earlier.add(item);
    }
  }

  return [
    if (today.isNotEmpty) _ActivityGroup(label: 'Today', items: today),
    if (yesterday.isNotEmpty)
      _ActivityGroup(label: 'Yesterday', items: yesterday),
    if (thisWeek.isNotEmpty)
      _ActivityGroup(label: 'This week', items: thisWeek),
    if (earlier.isNotEmpty) _ActivityGroup(label: 'Earlier', items: earlier),
  ];
}

class _ActivityStateLabel extends StatelessWidget {
  const _ActivityStateLabel(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Text(
      message,
      style: CatchTextStyles.supporting(context, color: t.ink2),
    );
  }
}
