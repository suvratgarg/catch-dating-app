import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
import 'package:catch_dating_app/core/widgets/catch_loading_indicator.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_text_button.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/dashboard/presentation/activity_controller.dart';
import 'package:catch_dating_app/events/data/event_repository.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/presentation/event_formatters.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
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
    return const Padding(
      padding: EdgeInsets.all(CatchSpacing.s5),
      child: CatchEmptyState(
        icon: Icons.notifications_none_rounded,
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
    final eventsAsync = ref.watch(watchSignedUpEventsProvider(uid));

    final isLoading = notificationsAsync.isLoading || eventsAsync.isLoading;
    final error = notificationsAsync.error ?? eventsAsync.error;
    final notifications =
        notificationsAsync.asData?.value ?? const <ActivityNotification>[];
    final events = eventsAsync.asData?.value ?? const <Event>[];
    final visibleNotifications = notifications
        .where((notification) => notification.isVisibleInActivity)
        .toList(growable: false);
    final notificationItems = _NotificationItem.fromNotifications(
      visibleNotifications,
    );
    final upcomingEvents = _upcomingEvents(events);

    final hasUnread = visibleNotifications.any(
      (notification) => notification.isUnread,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isLoading) ...[
          CatchSurface(
            padding: const EdgeInsets.all(CatchSpacing.s4),
            borderColor: t.line,
            child: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CatchLoadingIndicator(strokeWidth: 2),
                ),
                gapW10,
                const Expanded(
                  child: _ActivityStateLabel('Loading activity...'),
                ),
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
              ref.invalidate(watchSignedUpEventsProvider(uid));
            },
          ),
        ] else if (upcomingEvents.isEmpty && notificationItems.isEmpty) ...[
          if (showEmptyState)
            CatchEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No new activity',
              message:
                  'New catches, bookings, and event reminders will collect here.',
              iconStyle: CatchEmptyStateIconStyle.plain,
              iconSize: 34,
              titleStyle: CatchTextStyles.titleL(context),
              messageStyle: CatchTextStyles.supporting(context, color: t.ink2),
            ),
        ] else ...[
          if (upcomingEvents.isNotEmpty) ...[
            const SectionHeader(title: 'Upcoming events', heavy: true),
            for (final entry in upcomingEvents.indexed) ...[
              _UpcomingEventTile(event: entry.$2),
              if (entry.$1 != upcomingEvents.length - 1) gapH10,
            ],
            if (notificationItems.isNotEmpty) gapH24,
          ],
          if (notificationItems.isNotEmpty) ...[
            SectionHeader(
              title: 'Recent updates',
              heavy: true,
              trailing: showMarkAllReadAction && hasUnread
                  ? CatchTextButton(
                      label: 'Mark all read',
                      onPressed: () =>
                          _markAllRead(ref, visibleNotifications, context),
                    )
                  : null,
            ),
            for (final group in _groupItems(notificationItems)) ...[
              SectionHeader(
                title: group.label,
                padding: const EdgeInsets.only(top: 4, bottom: 8),
              ),
              for (final entry in group.items.indexed) ...[
                _NotificationTile(item: entry.$2),
                if (entry.$1 != group.items.length - 1) gapH10,
              ],
              gapH16,
            ],
          ],
        ],
      ],
    );
  }

  Future<void> _markAllRead(
    WidgetRef ref,
    List<ActivityNotification> notifications,
    BuildContext context,
  ) async {
    final container = ProviderScope.containerOf(context, listen: false);
    try {
      await ref
          .read(activityControllerProvider.notifier)
          .markAllRead(notifications: notifications, uid: uid);
    } catch (error, stackTrace) {
      container
          .read(errorLoggerProvider)
          .logAppException(
            normalizeBackendError(
              error,
              stackTrace: stackTrace,
              context: const BackendErrorContext(
                service: BackendService.local,
                action: 'mark activity read',
                resource: 'activity_section',
              ),
            ),
          );
      if (context.mounted) {
        showCatchErrorSnackBar(context, error);
      }
    }
  }
}

class _UpcomingEventTile extends StatelessWidget {
  const _UpcomingEventTile({required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      onTap: () => context.push(_eventRoute(event)),
      borderColor: t.line,
      backgroundColor: t.surface,
      padding: const EdgeInsets.all(CatchSpacing.s3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _EventDatePill(date: event.startTime),
          gapW12,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.locationName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.sectionTitle(context, color: t.ink),
                ),
                gapH4,
                Text(
                  '${EventFormatters.shortDate(event.startTime)} · '
                  '${event.compactTimeRangeLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                gapH8,
                Wrap(
                  spacing: CatchSpacing.s1,
                  runSpacing: CatchSpacing.s1,
                  children: [
                    CatchBadge(
                      label: event.distanceLabel,
                      tone: CatchBadgeTone.brand,
                    ),
                    CatchBadge(
                      label: event.pace.label,
                      tone: CatchBadgeTone.neutral,
                    ),
                  ],
                ),
              ],
            ),
          ),
          gapW8,
          Icon(Icons.chevron_right_rounded, size: 20, color: t.ink3),
        ],
      ),
    );
  }
}

class _EventDatePill extends StatelessWidget {
  const _EventDatePill({required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      width: 52,
      height: 58,
      radius: CatchRadius.md,
      backgroundColor: t.primarySoft.withValues(alpha: 0.64),
      borderColor: t.primary.withValues(alpha: 0.16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            EventFormatters.shortMonth(date).toUpperCase(),
            style: CatchTextStyles.labelS(context, color: t.primary),
          ),
          gapH2,
          Text(
            '${date.day}',
            style: CatchTextStyles.titleL(context, color: t.ink),
          ),
        ],
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = _NotificationVisual.from(item.type, t);

    return Semantics(
      button: item.route != null,
      label: '${item.title}. ${item.subtitle}',
      child: CatchSurface(
        onTap: item.route == null ? null : () => context.push(item.route!),
        borderColor: item.isUnread
            ? visual.accent.withValues(alpha: 0.34)
            : t.line,
        backgroundColor: item.isUnread
            ? visual.accent.withValues(alpha: 0.06)
            : t.surface,
        padding: const EdgeInsets.all(CatchSpacing.s3),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NotificationIconChip(visual: visual),
            gapW12,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style:
                              CatchTextStyles.sectionTitle(
                                context,
                                color: t.ink,
                              ).copyWith(
                                fontWeight: item.isUnread
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                        ),
                      ),
                      gapW8,
                      Text(
                        item.timeLabel,
                        style: CatchTextStyles.supporting(
                          context,
                          color: t.ink3,
                        ),
                      ),
                    ],
                  ),
                  gapH4,
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.supporting(context, color: t.ink2),
                  ),
                  gapH8,
                  Wrap(
                    spacing: CatchSpacing.s1,
                    runSpacing: CatchSpacing.s1,
                    children: [
                      CatchBadge(
                        label: visual.label,
                        tone: visual.badgeTone,
                        icon: visual.badgeIcon,
                      ),
                      if (item.isUnread)
                        const CatchBadge(
                          label: 'New',
                          tone: CatchBadgeTone.live,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (item.route != null) ...[
              gapW8,
              Icon(Icons.chevron_right_rounded, size: 20, color: t.ink3),
            ],
          ],
        ),
      ),
    );
  }
}

class _NotificationIconChip extends StatelessWidget {
  const _NotificationIconChip({required this.visual});

  final _NotificationVisual visual;

  @override
  Widget build(BuildContext context) {
    return CatchIconTile(
      icon: visual.icon,
      iconColor: visual.accent,
      backgroundColor: visual.background,
      borderColor: visual.border,
    );
  }
}

class _NotificationVisual {
  const _NotificationVisual({
    required this.icon,
    required this.label,
    required this.badgeTone,
    required this.accent,
    required this.background,
    required this.border,
    this.badgeIcon,
  });

  final IconData icon;
  final String label;
  final CatchBadgeTone badgeTone;
  final Color accent;
  final Color background;
  final Color border;
  final IconData? badgeIcon;

  static _NotificationVisual from(
    ActivityNotificationType type,
    CatchTokens t,
  ) {
    _NotificationVisual visual({
      required IconData icon,
      required String label,
      required CatchBadgeTone tone,
      required Color accent,
      IconData? badgeIcon,
      double backgroundAlpha = 0.11,
    }) {
      return _NotificationVisual(
        icon: icon,
        label: label,
        badgeTone: tone,
        accent: accent,
        background: accent.withValues(alpha: backgroundAlpha),
        border: accent.withValues(alpha: 0.14),
        badgeIcon: badgeIcon,
      );
    }

    return switch (type) {
      ActivityNotificationType.message => visual(
        icon: Icons.chat_bubble_outline_rounded,
        label: 'Message',
        tone: CatchBadgeTone.neutral,
        accent: t.ink2,
        badgeIcon: Icons.chat_bubble_outline_rounded,
      ),
      ActivityNotificationType.match => visual(
        icon: Icons.favorite_rounded,
        label: 'Catch',
        tone: CatchBadgeTone.brand,
        accent: t.primary,
        badgeIcon: Icons.favorite_rounded,
      ),
      ActivityNotificationType.eventReminder => visual(
        icon: Icons.notifications_active_outlined,
        label: 'Reminder',
        tone: CatchBadgeTone.live,
        accent: t.primary,
        badgeIcon: Icons.notifications_active_outlined,
      ),
      ActivityNotificationType.eventSignup => visual(
        icon: Icons.check_circle_outline_rounded,
        label: 'Booked',
        tone: CatchBadgeTone.success,
        accent: t.success,
        badgeIcon: Icons.check_rounded,
      ),
      ActivityNotificationType.waitlistPromotion => visual(
        icon: Icons.event_available_rounded,
        label: 'Waitlist',
        tone: CatchBadgeTone.warning,
        accent: t.warning,
        badgeIcon: Icons.schedule_rounded,
      ),
      ActivityNotificationType.eventCancelled => visual(
        icon: Icons.event_busy_rounded,
        label: 'Cancelled',
        tone: CatchBadgeTone.danger,
        accent: t.danger,
        badgeIcon: Icons.close_rounded,
      ),
      ActivityNotificationType.eventUpdated => visual(
        icon: Icons.update_rounded,
        label: 'Updated',
        tone: CatchBadgeTone.neutral,
        accent: t.accent,
        badgeIcon: Icons.update_rounded,
      ),
      ActivityNotificationType.clubUpdate => visual(
        icon: Icons.groups_rounded,
        label: 'Club',
        tone: CatchBadgeTone.neutral,
        accent: t.accent,
        badgeIcon: Icons.groups_rounded,
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

List<Event> _upcomingEvents(List<Event> events) {
  final now = DateTime.now();
  final upcoming =
      events.where((event) => event.isUpcomingAt(now)).toList(growable: false)
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
  return upcoming.take(3).toList(growable: false);
}

String _eventRoute(Event event) {
  return Routes.eventDetailScreen.path
      .replaceFirst(':clubId', event.clubId)
      .replaceFirst(':eventId', event.id);
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
