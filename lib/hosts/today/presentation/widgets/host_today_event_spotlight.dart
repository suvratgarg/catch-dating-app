import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/hosts/domain/host_events_policy.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class HostTodayEventSpotlight extends StatelessWidget {
  const HostTodayEventSpotlight({
    super.key,
    required this.event,
    required this.now,
    required this.taskCount,
    this.taskCountIsComplete = true,
    required this.onPressed,
    this.contained = true,
  });

  final Event event;
  final DateTime now;
  final int taskCount;
  final bool taskCountIsComplete;
  final VoidCallback onPressed;
  final bool contained;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, event.activityKind);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchBadge.functional(
          label: _eventStartLeadLabel(context, event, now),
          backgroundColor: activity.soft,
          foregroundColor: t.ink,
          borderColor: Colors.transparent,
        ),
        gapH16,
        Text(
          event.title,
          style: CatchTextStyles.eventTitle(context, color: t.ink),
        ),
        gapH14,
        HostTodayEventMetadata(event: event, now: now),
        gapH20,
        const CatchDivider.section(),
        gapH20,
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HostTodayEventMetric(
              value: taskCountIsComplete
                  ? context.l10n.hostsHostTodayVisiblecopyTaskcount(
                      taskCount: taskCount,
                    )
                  : taskCount > 0
                  ? context.l10n.hostTodayTaskCountPartial(count: taskCount)
                  : '—',
              label: context.l10n.hostsHostTodayLabelNeedsYou,
              supporting: taskCountIsComplete
                  ? context.l10n.hostTodayTaskSummary
                  : context.l10n.hostTodayTaskCoverageIncomplete,
              icon: CatchIcons.factCheckOutlined,
              accent: activity,
            ),
            gapH20,
            HostTodayEventMetric(
              value: context.l10n.hostsHostTodayVisiblecopySignedupcount(
                signedUpCount: event.signedUpCount,
              ),
              label: context.l10n.hostsHostTodayLabelGoing,
              supporting: context.l10n.hostTodayCheckedIn(
                count: event.attendedCount,
              ),
              icon: CatchIcons.groupsOutlined,
              accent: activity,
            ),
          ],
        ),
        gapH20,
        const CatchDivider.section(),
        gapH20,
        CatchButton(
          label: !event.startTime.isAfter(now) && event.endTime.isAfter(now)
              ? context.l10n.hostsHostTodayLabelOpenRunOfShow
              : context.l10n.hostsHostTodayLabelSetUpRun,
          fullWidth: true,
          mode: CatchButtonMode.rounded,
          backgroundColor: activity.deep,
          foregroundColor: CatchTokens.editorialWhite,
          borderColor: Colors.transparent,
          onPressed: onPressed,
        ),
      ],
    );
    if (!contained) return content;
    return CatchSurface(
      borderColor: t.line,
      backgroundColor: t.surface,
      borderRadius: BorderRadius.circular(CatchRadius.md),
      clipBehavior: Clip.antiAlias,
      padding: CatchInsets.contentRelaxed,
      child: content,
    );
  }
}

class HostTodayEventMetadata extends StatelessWidget {
  const HostTodayEventMetadata({
    super.key,
    required this.event,
    required this.now,
  });

  final Event event;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.6;
    final metadataStyle = CatchTextStyles.supporting(context, color: t.ink2);
    final time = Text(
      context.l10n.hostsHostTodayTextEventdaylabelTime(
        eventDayLabel: _eventDayLabel(context, event, now),
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
    this.supporting,
    this.icon,
    this.accent,
    this.valueColor,
  });

  final String value;
  final String label;
  final String? supporting;
  final IconData? icon;
  final CatchActivity? accent;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final metric = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: CatchTextStyles.titleL(context, color: valueColor ?? t.ink),
        ),
        gapH2,
        Text(label, style: CatchTextStyles.name(context, color: t.ink)),
        if (supporting != null) ...[
          gapH2,
          Text(
            supporting!,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
      ],
    );
    if (icon == null || accent == null) return metric;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CatchIconTile(
          icon: icon!,
          iconColor: t.ink,
          backgroundColor: accent!.soft,
          borderColor: Colors.transparent,
          size: CatchSpacing.s12,
          iconSize: CatchIcon.md,
          radius: CatchRadius.pill,
        ),
        gapW12,
        Expanded(child: metric),
      ],
    );
  }
}

String _eventDayLabel(BuildContext context, Event event, DateTime now) {
  if (DateUtils.isSameDay(event.startTime, now) && event.startTime.hour >= 17) {
    return context.l10n.hostTodayTonight;
  }
  return MaterialLocalizations.of(context).formatMediumDate(event.startTime);
}

String _eventStartLeadLabel(BuildContext context, Event event, DateTime now) {
  final l10n = context.l10n;
  if (!event.startTime.isAfter(now) && event.endTime.isAfter(now)) {
    return l10n.hostTodayLiveNow;
  }
  final lead = event.startTime.difference(now);
  if (!lead.isNegative && lead < hostEventsImminentEventLeadTime) {
    return l10n.hostTodayStartsInMinutes(minutes: lead.inMinutes.clamp(1, 59));
  }
  if (DateUtils.isSameDay(event.startTime, now) && !lead.isNegative) {
    return l10n.hostTodayStartsInHours(
      hours: lead.inHours,
      minutes: lead.inMinutes.remainder(60),
    );
  }
  return l10n.hostTodayStartsOn(
    date: MaterialLocalizations.of(context).formatMediumDate(event.startTime),
    time: EventFormatters.time(event.startTime),
  );
}
