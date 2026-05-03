import 'package:catch_dating_app/constants/app_sizes.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/section_header.dart';
import 'package:catch_dating_app/matches/data/match_repository.dart';
import 'package:catch_dating_app/matches/domain/match.dart';
import 'package:catch_dating_app/routing/go_router.dart';
import 'package:catch_dating_app/runs/data/run_repository.dart';
import 'package:catch_dating_app/runs/domain/run.dart';
import 'package:catch_dating_app/runs/presentation/run_formatters.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ActivitySection extends ConsumerWidget {
  const ActivitySection({
    super.key,
    required this.uid,
    this.showEmptyState = true,
  });

  final String uid;
  final bool showEmptyState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final matchesAsync = ref.watch(matchesForUserProvider(uid));
    final runsAsync = ref.watch(signedUpRunsProvider(uid));

    final isLoading = matchesAsync.isLoading || runsAsync.isLoading;
    final error = matchesAsync.error ?? runsAsync.error;
    final matches = matchesAsync.asData?.value ?? const <Match>[];
    final runs = runsAsync.asData?.value ?? const <Run>[];
    final items = _ActivityItem.fromData(
      uid: uid,
      matches: matches,
      runs: runs,
    );

    final hasUnread = matches.any((match) => (match.unreadCounts[uid] ?? 0) > 0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasUnread && items.isNotEmpty) ...[
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => _markAllRead(ref, matches, context),
              child: Text(
                'Mark all read',
                style: CatchTextStyles.bodyM(context, color: t.primary),
              ),
            ),
          ),
          gapH8,
        ],
        if (isLoading) ...[
          CatchSurface(
            padding: const EdgeInsets.all(Sizes.p16),
            borderColor: t.line,
            child: Row(
              children: [
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                gapW10,
                const Expanded(
                  child: _ActivityStateLabel('Loading activity...'),
                ),
              ],
            ),
          ),
        ] else if (error != null) ...[
          CatchSurface(
            padding: const EdgeInsets.all(Sizes.p16),
            borderColor: t.line,
            child: Row(
              children: [
                Icon(Icons.error_outline_rounded, color: t.primary, size: 18),
                gapW10,
                const Expanded(
                  child: _ActivityStateLabel('Could not load activity'),
                ),
              ],
            ),
          ),
        ] else if (items.isEmpty) ...[
          if (showEmptyState)
            _ActivityMessage(
              icon: Icons.notifications_none_rounded,
              title: 'No new activity',
              body:
                  'New catches, messages, and run reminders will collect here.',
              tokens: t,
            ),
        ] else ...[
          Divider(color: t.line, height: 1),
          gapH18,
          for (final group in _groupItems(items)) ...[
            SectionHeader(title: group.label),
            gapH8,
            for (final item in group.items) ...[
              _ActivityTile(item: item, tokens: t),
              if (item != group.items.last) Divider(color: t.line),
            ],
            gapH18,
          ],
        ],
      ],
    );
  }

  Future<void> _markAllRead(
    WidgetRef ref,
    List<Match> matches,
    BuildContext context,
  ) async {
    final repository = ref.read(matchRepositoryProvider);
    for (final match in matches) {
      if ((match.unreadCounts[uid] ?? 0) > 0) {
        try {
          await repository.resetUnread(matchId: match.id, uid: uid);
        } catch (error, stack) {
          debugPrint('[ERROR] ActivitySection resetUnread: $error\n$stack');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to mark messages as read.'),
              ),
            );
          }
          return;
        }
      }
    }
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item, required this.tokens});

  final _ActivityItem item;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Material(
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
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: item.isPrimary ? tokens.primary : tokens.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  item.icon,
                  color: item.isPrimary ? tokens.primaryInk : tokens.primary,
                  size: 21,
                ),
              ),
              gapW12,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: CatchTextStyles.bodyM(context, color: tokens.ink)
                          .copyWith(
                            fontWeight: item.isPrimary
                                ? FontWeight.w800
                                : FontWeight.w600,
                          ),
                    ),
                    gapH4,
                    Text(
                      item.subtitle,
                      style: CatchTextStyles.bodyS(context, color: tokens.ink2),
                    ),
                  ],
                ),
              ),
              gapW8,
              Text(
                item.timeLabel,
                style: CatchTextStyles.bodyS(context, color: tokens.ink3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityMessage extends StatelessWidget {
  const _ActivityMessage({
    required this.icon,
    required this.title,
    required this.body,
    required this.tokens,
  });

  final IconData icon;
  final String title;
  final String body;
  final CatchTokens tokens;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(Sizes.p20),
      decoration: BoxDecoration(
        color: tokens.surface,
        borderRadius: BorderRadius.circular(CatchRadius.lg),
        border: Border.all(color: tokens.line),
      ),
      child: Column(
        children: [
          Icon(icon, color: tokens.primary, size: 34),
          gapH12,
          Text(title, style: CatchTextStyles.titleL(context)),
          gapH6,
          Text(
            body,
            textAlign: TextAlign.center,
            style: CatchTextStyles.bodyS(context, color: tokens.ink2),
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
    required String uid,
    required List<Match> matches,
    required List<Run> runs,
  }) {
    final now = DateTime.now();
    final items = <_ActivityItem>[];

    for (final match in matches) {
      final unread = match.unreadCounts[uid] ?? 0;
      final activityAt = match.lastMessageAt ?? match.createdAt;
      items.add(
        _ActivityItem(
          title: unread > 0
              ? '$unread unread ${unread == 1 ? 'message' : 'messages'}'
              : "It's a catch",
          subtitle: match.lastMessagePreview?.isNotEmpty == true
              ? match.lastMessagePreview!
              : 'You matched after a shared run.',
          createdAt: activityAt,
          icon: unread > 0
              ? Icons.chat_bubble_outline_rounded
              : Icons.favorite_rounded,
          route: Routes.chatScreen.path.replaceFirst(':matchId', match.id),
          timeLabel: _relativeTime(activityAt, now),
          isPrimary: unread > 0,
        ),
      );
    }

    for (final run in runs.where((run) => run.startTime.isAfter(now)).take(3)) {
      final reminderAt = run.startTime.subtract(const Duration(minutes: 15));
      items.add(
        _ActivityItem(
          title: _runReminderTitle(run.startTime, now),
          subtitle:
              '${run.meetingPoint} · ${RunFormatters.distanceKm(run.distanceKm)} · ${run.pace.label}',
          createdAt: reminderAt,
          icon: Icons.directions_run_rounded,
          route: Routes.runDetailScreen.path
              .replaceFirst(':runClubId', run.runClubId)
              .replaceFirst(':runId', run.id),
          timeLabel: RunFormatters.shortDate(run.startTime),
        ),
      );
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static String _runReminderTitle(DateTime startTime, DateTime now) {
    final minutes = startTime.difference(now).inMinutes;
    if (minutes <= 60) return 'Your run starts soon';
    if (DateUtils.isSameDay(startTime, now)) return 'Run later today';
    return 'Upcoming run';
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
    if (upcoming.isNotEmpty)
      _ActivityGroup(label: 'Upcoming', items: upcoming),
    if (yesterday.isNotEmpty)
      _ActivityGroup(label: 'Yesterday', items: yesterday),
    if (earlier.isNotEmpty)
      _ActivityGroup(label: 'This week', items: earlier),
  ];
}
