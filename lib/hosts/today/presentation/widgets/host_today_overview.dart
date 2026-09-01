import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/hosts/domain/host_events_policy.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class HostTodayOverview extends StatelessWidget {
  const HostTodayOverview({
    super.key,
    required this.state,
    required this.now,
    required this.onRetry,
    required this.onOpenEvent,
    required this.onOpenAttention,
  });

  final HostTodayState state;
  final DateTime now;
  final VoidCallback onRetry;
  final ValueChanged<Event> onOpenEvent;
  final ValueChanged<HostAttentionItem> onOpenAttention;

  @override
  Widget build(BuildContext context) {
    final event = state.featuredEvent;
    final attentionItems = state.attentionItems;
    final heroTaskCount = attentionItems
        .where((data) => data.item.eventId == event?.id)
        .length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (event != null) ...[
          HostTodayEventSpotlight(
            event: event,
            now: now,
            taskCount: heroTaskCount,
            onPressed: () => onOpenEvent(event),
          ),
          gapH24,
        ],
        CatchSection.plain(
          title: context.l10n.hostsHostTodayTitleNeedsYou,
          count: attentionItems.isEmpty ? null : attentionItems.length,
          titleColor: CatchTokens.of(context).ink3,
          child: attentionItems.isEmpty && state.attentionIssues.isEmpty
              ? Text(
                  context.l10n.hostsHostTodayTextNothingNeedsYouRight,
                  style: CatchTextStyles.supporting(context),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final issue in state.attentionIssues) ...[
                      CatchInlineErrorState.fromError(
                        issue.error,
                        context: AppErrorContext.event,
                        onRetry: onRetry,
                      ),
                      gapH12,
                    ],
                    for (final data in attentionItems) ...[
                      HostTodayAttentionCard(
                        data: data,
                        onPrimary: () => onOpenAttention(data.item),
                      ),
                      gapH12,
                    ],
                  ],
                ),
        ),
      ],
    );
  }
}

class HostTodayEventSpotlight extends StatelessWidget {
  const HostTodayEventSpotlight({
    super.key,
    required this.event,
    required this.now,
    required this.taskCount,
    required this.onPressed,
  });

  final Event event;
  final DateTime now;
  final int taskCount;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(context, event.activityKind);

    return CatchSurface(
      borderRadius: BorderRadius.circular(CatchRadius.lg),
      clipBehavior: Clip.antiAlias,
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [activity.deep, CatchTokens.editorialBlack],
      ),
      padding: CatchInsets.contentRelaxed,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchBadge.onDark(label: _eventStartLeadLabel(event, now)),
          gapH16,
          Text(
            _todayEventHeroTitle(event),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.headlineS(
              context,
              color: CatchTokens.editorialWhite,
            ),
          ),
          gapH14,
          HostTodayEventMetadata(event: event),
          gapH16,
          Divider(
            height: CatchStroke.hairline,
            color: CatchTokens.editorialWhite.withValues(
              alpha: CatchOpacity.darkHeroDivider,
            ),
          ),
          gapH14,
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.end,
            spacing: CatchSpacing.s5,
            runSpacing: CatchSpacing.s3,
            children: [
              HostTodayEventMetric(
                value: context.l10n.hostsHostTodayVisiblecopySignedupcount(
                  signedUpCount: event.signedUpCount,
                ),
                label: context.l10n.hostsHostTodayLabelGoing,
              ),
              HostTodayEventMetric(
                value: context.l10n.hostsHostTodayVisiblecopyWaitlistcount(
                  waitlistCount: event.waitlistCount,
                ),
                label: context.l10n.hostsHostTodayLabelWaiting,
              ),
              HostTodayEventMetric(
                value: context.l10n.hostsHostTodayVisiblecopyTaskcount(
                  taskCount: taskCount,
                ),
                label: context.l10n.hostsHostTodayLabelNeedsYou,
                valueColor: activity.accent,
              ),
            ],
          ),
          gapH20,
          CatchButton(
            label: !event.startTime.isAfter(now) && event.endTime.isAfter(now)
                ? context.l10n.hostsHostTodayLabelOpenRunOfShow
                : context.l10n.hostsHostTodayLabelSetUpRun,
            fullWidth: true,
            backgroundColor: activity.accent,
            foregroundColor: CatchTokens.editorialWhite,
            borderColor: Colors.transparent,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

class HostTodayEventMetadata extends StatelessWidget {
  const HostTodayEventMetadata({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.6;
    final metadataStyle = CatchTextStyles.supporting(
      context,
      color: CatchTokens.editorialWhite.withValues(
        alpha: CatchOpacity.onDarkMuted,
      ),
    );
    final time = Text(
      context.l10n.hostsHostTodayTextEventdaylabelTime(
        eventDayLabel: _eventDayLabel(event),
        time: EventFormatters.time(event.startTime),
      ),
      maxLines: largeText ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      style: metadataStyle,
    );
    final location = Text(
      event.locationName,
      maxLines: largeText ? 2 : 1,
      overflow: TextOverflow.ellipsis,
      textAlign: largeText ? TextAlign.start : TextAlign.right,
      style: metadataStyle,
    );
    if (largeText) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [time, gapH4, location],
      );
    }
    return Row(
      children: [
        Expanded(child: time),
        gapW12,
        Expanded(child: location),
      ],
    );
  }
}

class HostTodayEventMetric extends StatelessWidget {
  const HostTodayEventMetric({
    super.key,
    required this.value,
    required this.label,
    this.valueColor,
  });

  final String value;
  final String label;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: CatchTextStyles.titleL(
            context,
            color: valueColor ?? CatchTokens.editorialWhite,
          ),
        ),
        gapH2,
        Text(
          label,
          style: CatchTextStyles.monoLabel(
            context,
            color: CatchTokens.editorialWhite.withValues(
              alpha: CatchOpacity.onDarkMuted,
            ),
          ),
        ),
      ],
    );
  }
}

class HostTodayAttentionCard extends StatelessWidget {
  const HostTodayAttentionCard({
    super.key,
    required this.data,
    required this.onPrimary,
  });

  final HostTodayAttentionData data;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return CatchSurface(
      borderColor: t.line,
      backgroundColor: t.surface,
      padding: CatchInsets.content,
      onTap: onPrimary,
      child: Row(
        children: [
          SizedBox(
            width: CatchSpacing.s9,
            height: CatchSpacing.s9,
            child: ColoredBox(
              color: t.primarySoft,
              child: Icon(data.icon, color: t.ink2, size: CatchIcon.md),
            ),
          ),
          gapW14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.fieldRowTitle(context, color: t.ink),
                ),
                gapH4,
                Text(
                  data.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
              ],
            ),
          ),
          gapW12,
          CatchButton(
            label: data.primaryActionLabel.toUpperCase(),
            size: CatchButtonSize.sm,
            accentColor: t.danger,
            onPressed: onPrimary,
          ),
        ],
      ),
    );
  }
}

String _eventDayLabel(Event event) {
  if (event.startTime.hour >= 17) return 'Tonight';
  return EventFormatters.longWeekday(event.startTime);
}

String _todayEventHeroTitle(Event event) {
  final weekday = EventFormatters.longWeekday(event.startTime);
  final period = event.startTime.hour < 12
      ? 'Morning'
      : event.startTime.hour < 17
      ? 'Afternoon'
      : 'Evening';
  final prefix = '$weekday $period ';
  if (event.title.startsWith(prefix)) {
    return '$weekday ${event.title.substring(prefix.length)}';
  }
  return event.title;
}

String _eventStartLeadLabel(Event event, DateTime now) {
  if (!event.startTime.isAfter(now) && event.endTime.isAfter(now)) {
    return 'LIVE NOW';
  }

  final lead = event.startTime.difference(now);
  if (!lead.isNegative && lead < hostEventsImminentEventLeadTime) {
    final minutes = lead.inMinutes.clamp(1, 59);
    return 'STARTS IN $minutes MIN';
  }
  if (DateUtils.isSameDay(event.startTime, now) && !lead.isNegative) {
    final hours = lead.inHours;
    final minutes = lead.inMinutes.remainder(60);
    return minutes == 0
        ? 'STARTS IN ${hours}H'
        : 'STARTS IN ${hours}H ${minutes}M';
  }

  final tomorrow = DateUtils.dateOnly(now).add(const Duration(days: 1));
  final prefix = DateUtils.isSameDay(event.startTime, tomorrow)
      ? 'TOMORROW'
      : EventFormatters.shortWeekday(event.startTime).toUpperCase();
  return 'STARTS $prefix · ${EventFormatters.time(event.startTime).toUpperCase()}';
}
