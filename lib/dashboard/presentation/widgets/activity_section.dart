import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_snackbar.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
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
    final items = _ActivityItem.fromData(
      notifications: notifications,
      events: events,
    );

    final hasUnread = notifications.any(
      (notification) => notification.isUnread,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showMarkAllReadAction && hasUnread && items.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerRight,
            child: CatchTextButton(
              label: 'Mark all read',
              onPressed: () => _markAllRead(ref, notifications, context),
            ),
          ),
          gapH8,
        ],
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
        ] else if (items.isEmpty) ...[
          if (showEmptyState)
            CatchEmptyState(
              icon: Icons.notifications_none_rounded,
              title: 'No new activity',
              message:
                  'New catches, bookings, and event reminders will collect here.',
              iconStyle: CatchEmptyStateIconStyle.plain,
              iconSize: 34,
              titleStyle: CatchTextStyles.titleL(context),
              messageStyle: CatchTextStyles.bodyS(context, color: t.ink2),
            ),
        ] else ...[
          Divider(color: t.line, height: 1),
          gapH18,
          for (final group in _groupItems(items)) ...[
            SectionHeader(title: group.label),
            gapH8,
            for (final entry in group.items.indexed) ...[
              _ActivityTile(
                item: entry.$2,
                isFirst: entry.$1 == 0,
                isLast: entry.$1 == group.items.length - 1,
              ),
              if (entry.$2 != group.items.last) Divider(color: t.line),
            ],
            gapH18,
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

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.item,
    required this.isFirst,
    required this.isLast,
  });

  final _ActivityItem item;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Semantics(
      button: item.route != null,
      label: '${item.title}. ${item.subtitle}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            final route = item.route;
            if (route != null) context.push(route);
          },
          borderRadius: BorderRadius.circular(CatchRadius.md),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ActivityTimelineMarker(
                  icon: item.icon,
                  isPrimary: item.isPrimary,
                  isFirst: isFirst,
                  isLast: isLast,
                ),
                gapW12,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.title,
                        style: CatchTextStyles.bodyM(context, color: t.ink)
                            .copyWith(
                              fontWeight: item.isPrimary
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                      ),
                      gapH4,
                      Text(
                        item.subtitle,
                        style: CatchTextStyles.bodyS(context, color: t.ink2),
                      ),
                    ],
                  ),
                ),
                gapW8,
                Text(
                  item.timeLabel,
                  style: CatchTextStyles.bodyS(context, color: t.ink3),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActivityTimelineMarker extends StatelessWidget {
  const _ActivityTimelineMarker({
    required this.icon,
    required this.isPrimary,
    required this.isFirst,
    required this.isLast,
  });

  final IconData icon;
  final bool isPrimary;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return SizedBox(
      width: 46,
      height: 56,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: isFirst ? 23 : 0,
            bottom: isLast ? 33 : 0,
            child: Container(width: 2, color: t.line),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: isPrimary ? t.primary : t.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isPrimary ? t.primaryInk : t.primary,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityStateLabel extends StatelessWidget {
  const _ActivityStateLabel(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Text(message, style: CatchTextStyles.bodyS(context, color: t.ink2));
  }
}

class _ActivityGroup {
  const _ActivityGroup({required this.label, required this.items});

  final String label;
  final List<_ActivityItem> items;
}

class _ActivityItem {
  const _ActivityItem({
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.icon,
    required this.timeLabel,
    this.route,
    this.isPrimary = false,
  });

  final String title;
  final String subtitle;
  final DateTime createdAt;
  final IconData icon;
  final String timeLabel;
  final String? route;
  final bool isPrimary;

  static List<_ActivityItem> fromData({
    required List<ActivityNotification> notifications,
    required List<Event> events,
  }) {
    final now = DateTime.now();
    final items = <_ActivityItem>[];

    for (final notification in notifications) {
      items.add(_ActivityItem.fromNotification(notification, now));
    }

    final durableReminderEventIds = notifications
        .where(
          (notification) =>
              notification.type == ActivityNotificationType.eventReminder,
        )
        .map((notification) => notification.eventId)
        .whereType<String>()
        .toSet();

    for (final event
        in events
            .where(
              (event) =>
                  event.startTime.isAfter(now) &&
                  !durableReminderEventIds.contains(event.id),
            )
            .take(3)) {
      final reminderAt = event.startTime.subtract(const Duration(minutes: 15));
      items.add(
        _ActivityItem(
          title: _eventReminderTitle(event.startTime, now),
          subtitle:
              '${event.meetingPoint} · ${EventFormatters.distanceKm(event.distanceKm)} · ${event.pace.label}',
          createdAt: reminderAt,
          icon: Icons.directions_run_rounded,
          route: Routes.eventDetailScreen.path
              .replaceFirst(':clubId', event.clubId)
              .replaceFirst(':eventId', event.id),
          timeLabel: EventFormatters.shortDate(event.startTime),
        ),
      );
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  factory _ActivityItem.fromNotification(
    ActivityNotification notification,
    DateTime now,
  ) {
    return _ActivityItem(
      title: notification.title,
      subtitle: notification.body,
      createdAt: notification.createdAt,
      icon: _notificationIcon(notification.type),
      route: _notificationRoute(notification),
      timeLabel: _relativeTime(notification.createdAt, now),
      isPrimary: notification.isUnread,
    );
  }

  static IconData _notificationIcon(ActivityNotificationType type) {
    return switch (type) {
      ActivityNotificationType.message => Icons.chat_bubble_outline_rounded,
      ActivityNotificationType.match => Icons.favorite_rounded,
      ActivityNotificationType.eventReminder ||
      ActivityNotificationType.eventSignup ||
      ActivityNotificationType.waitlistPromotion ||
      ActivityNotificationType.eventCancelled ||
      ActivityNotificationType.eventUpdated => Icons.directions_run_rounded,
      ActivityNotificationType.clubUpdate => Icons.groups_rounded,
    };
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

  static String _eventReminderTitle(DateTime startTime, DateTime now) {
    final minutes = startTime.difference(now).inMinutes;
    if (minutes <= 60) return 'Your event starts soon';
    if (DateUtils.isSameDay(startTime, now)) return 'Event later today';
    return 'Upcoming event';
  }

  static String _relativeTime(DateTime time, DateTime now) {
    final difference = now.difference(time);
    if (difference.inMinutes < 1) return 'Now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m';
    if (difference.inHours < 24) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }
}

List<_ActivityGroup> _groupItems(List<_ActivityItem> items) {
  final now = DateTime.now();
  final today = <_ActivityItem>[];
  final yesterday = <_ActivityItem>[];
  final upcoming = <_ActivityItem>[];
  final earlier = <_ActivityItem>[];

  for (final item in items) {
    if (item.createdAt.isAfter(now)) {
      upcoming.add(item);
    } else if (DateUtils.isSameDay(item.createdAt, now)) {
      today.add(item);
    } else if (DateUtils.isSameDay(
      item.createdAt,
      now.subtract(const Duration(days: 1)),
    )) {
      yesterday.add(item);
    } else {
      earlier.add(item);
    }
  }

  return [
    if (today.isNotEmpty) _ActivityGroup(label: 'Today', items: today),
    if (upcoming.isNotEmpty) _ActivityGroup(label: 'Upcoming', items: upcoming),
    if (yesterday.isNotEmpty)
      _ActivityGroup(label: 'Yesterday', items: yesterday),
    if (earlier.isNotEmpty) _ActivityGroup(label: 'This week', items: earlier),
  ];
}
