import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_field.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_tile.dart';
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
    required this.onViewEvents,
    required this.onStartRehearsal,
  });

  final HostTodayState state;
  final DateTime now;
  final VoidCallback onRetry;
  final ValueChanged<Event> onOpenEvent;
  final ValueChanged<HostAttentionItem> onOpenAttention;
  final VoidCallback onViewEvents;
  final VoidCallback onStartRehearsal;

  @override
  Widget build(BuildContext context) {
    final event = state.featuredEvent;
    final attentionVisible =
        state.attentionItems.isNotEmpty || state.attentionIssues.isNotEmpty;
    final taskCount = state.attentionItems
        .where((data) => data.item.eventId == event?.id)
        .length;
    final primary = _HostTodayPrimaryPane(
      state: state,
      event: event,
      taskCount: taskCount,
      now: now,
      onOpenEvent: onOpenEvent,
      onViewEvents: onViewEvents,
      onStartRehearsal: onStartRehearsal,
    );
    final attention = HostTodayAttentionSection(
      state: state,
      onRetry: onRetry,
      onOpenAttention: onOpenAttention,
    );

    return ComponentResponsiveBuilder(
      breakpoint: CatchLayout.hostTodayTwoPaneBreakpoint,
      compact: (_) => Column(
        key: const ValueKey<String>('host-today-compact-layout'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (event != null)
            HostTodayEventSpotlight(
              event: event,
              now: now,
              taskCount: taskCount,
              onPressed: () => onOpenEvent(event),
            ),
          if (event != null && attentionVisible) gapH28,
          if (attentionVisible) attention,
          if (event != null || attentionVisible) gapH28,
          _HostTodayHorizonAndActions(
            state: state,
            onOpenEvent: onOpenEvent,
            onViewEvents: onViewEvents,
            onStartRehearsal: onStartRehearsal,
          ),
        ],
      ),
      expanded: (_) => ComponentResponsiveBuilder(
        breakpoint: CatchLayout.hostTodayExpandedAttentionPaneBreakpoint,
        compact: (_) => _HostTodayWideLayout(
          primary: primary,
          attention: attention,
          attentionVisible: attentionVisible,
          attentionPaneWidth: CatchLayout.hostTodayAttentionPaneCompactWidth,
        ),
        expanded: (_) => _HostTodayWideLayout(
          primary: primary,
          attention: attention,
          attentionVisible: attentionVisible,
          attentionPaneWidth: CatchLayout.hostTodayAttentionPaneWidth,
        ),
      ),
    );
  }
}

class _HostTodayWideLayout extends StatelessWidget {
  const _HostTodayWideLayout({
    required this.primary,
    required this.attention,
    required this.attentionVisible,
    required this.attentionPaneWidth,
  });

  final Widget primary;
  final Widget attention;
  final bool attentionVisible;
  final double attentionPaneWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          maxWidth: CatchLayout.hostTodayWorkspaceMaxContentWidth,
        ),
        child: Row(
          key: const ValueKey<String>('host-today-wide-layout'),
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: KeyedSubtree(
                key: const ValueKey<String>('host-today-primary-pane'),
                child: primary,
              ),
            ),
            if (attentionVisible) ...[
              gapW24,
              CatchSurface(
                width: CatchStroke.hairline,
                height: CatchLayout.hostTodayWorkspaceRuleExtent,
                radius: CatchRadius.none,
                backgroundColor: CatchTokens.of(context).line,
                child: const SizedBox.shrink(),
              ),
              gapW24,
              SizedBox(
                key: const ValueKey<String>('host-today-attention-pane'),
                width: attentionPaneWidth,
                child: attention,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HostTodayPrimaryPane extends StatelessWidget {
  const _HostTodayPrimaryPane({
    required this.state,
    required this.event,
    required this.taskCount,
    required this.now,
    required this.onOpenEvent,
    required this.onViewEvents,
    required this.onStartRehearsal,
  });

  final HostTodayState state;
  final Event? event;
  final int taskCount;
  final DateTime now;
  final ValueChanged<Event> onOpenEvent;
  final VoidCallback onViewEvents;
  final VoidCallback onStartRehearsal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (event != null) ...[
          HostTodayEventSpotlight(
            event: event!,
            now: now,
            taskCount: taskCount,
            contained: false,
            onPressed: () => onOpenEvent(event!),
          ),
          gapH28,
        ],
        _HostTodayHorizonAndActions(
          state: state,
          onOpenEvent: onOpenEvent,
          onViewEvents: onViewEvents,
          onStartRehearsal: onStartRehearsal,
        ),
      ],
    );
  }
}

class _HostTodayHorizonAndActions extends StatelessWidget {
  const _HostTodayHorizonAndActions({
    required this.state,
    required this.onOpenEvent,
    required this.onViewEvents,
    required this.onStartRehearsal,
  });

  final HostTodayState state;
  final ValueChanged<Event> onOpenEvent;
  final VoidCallback onViewEvents;
  final VoidCallback onStartRehearsal;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (state.laterEvents.isNotEmpty)
          CatchSection.divided(
            title: context.l10n.hostTodayLater,
            children: [
              for (final data in state.laterEvents)
                HostTodayEventRow(
                  key: ValueKey<String>('host-today-event-${data.event.id}'),
                  data: data,
                  onPressed: () => onOpenEvent(data.event),
                ),
            ],
          ),
        if (state.laterEvents.isNotEmpty) gapH16,
        Wrap(
          alignment: WrapAlignment.center,
          spacing: CatchSpacing.s2,
          runSpacing: CatchSpacing.s2,
          children: [
            CatchButton(
              key: const ValueKey<String>('host-today-view-events'),
              label: context.l10n.hostTodayViewAllEvents,
              variant: CatchButtonVariant.ghost,
              size: CatchButtonSize.sm,
              onPressed: onViewEvents,
            ),
            CatchButton(
              key: const ValueKey<String>('host-today-start-dress-rehearsal'),
              label: context.l10n.hostEventRehearsalEntryTitle,
              icon: Icon(CatchIcons.scienceOutlined, size: CatchIcon.sm),
              variant: CatchButtonVariant.ghost,
              size: CatchButtonSize.sm,
              onPressed: onStartRehearsal,
            ),
          ],
        ),
      ],
    );
  }
}

class HostTodayAttentionSection extends StatelessWidget {
  const HostTodayAttentionSection({
    super.key,
    required this.state,
    required this.onRetry,
    required this.onOpenAttention,
  });

  final HostTodayState state;
  final VoidCallback onRetry;
  final ValueChanged<HostAttentionItem> onOpenAttention;

  @override
  Widget build(BuildContext context) {
    return Column(
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
        if (state.attentionItems.isNotEmpty)
          CatchSection.divided(
            title: context.l10n.hostsHostTodayTitleNeedsYou,
            count: state.attentionItems.length,
            children: [
              for (final data in state.attentionItems)
                HostTodayAttentionCard(
                  key: ValueKey<String>('host-today-attention-${data.item.id}'),
                  data: data,
                  onPrimary: () => onOpenAttention(data.item),
                ),
            ],
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
    this.contained = true,
  });

  final Event event;
  final DateTime now;
  final int taskCount;
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
          label: _eventStartLeadLabel(event, now),
          backgroundColor: activity.soft,
          foregroundColor: activity.deep,
          borderColor: Colors.transparent,
        ),
        gapH16,
        Text(
          _todayEventHeroTitle(event),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: CatchTextStyles.eventTitle(context, color: t.ink),
        ),
        gapH14,
        HostTodayEventMetadata(event: event),
        gapH20,
        Divider(height: CatchStroke.hairline, color: t.line),
        gapH20,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: HostTodayEventMetric(
                value: context.l10n.hostsHostTodayVisiblecopyTaskcount(
                  taskCount: taskCount,
                ),
                label: context.l10n.hostsHostTodayLabelNeedsYou,
                supporting: context.l10n.hostTodayTaskSummary,
                icon: CatchIcons.factCheckOutlined,
                accent: activity,
              ),
            ),
            gapW20,
            Expanded(
              child: HostTodayEventMetric(
                value: context.l10n.hostsHostTodayVisiblecopySignedupcount(
                  signedUpCount: event.signedUpCount,
                ),
                label: context.l10n.hostsHostTodayLabelGoing,
                supporting:
                    '${event.attendedCount} '
                    '${context.l10n.hostsHostTodayLabelWaiting}',
                icon: CatchIcons.groupsOutlined,
                accent: activity,
              ),
            ),
          ],
        ),
        gapH20,
        Divider(height: CatchStroke.hairline, color: t.line),
        gapH20,
        CatchButton(
          label: !event.startTime.isAfter(now) && event.endTime.isAfter(now)
              ? context.l10n.hostsHostTodayLabelOpenRunOfShow
              : context.l10n.hostsHostTodayLabelSetUpRun,
          fullWidth: true,
          shape: CatchButtonShape.rounded,
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
  const HostTodayEventMetadata({super.key, required this.event});

  final Event event;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final largeText = MediaQuery.textScalerOf(context).scale(1) >= 1.6;
    final metadataStyle = CatchTextStyles.monoLabel(context, color: t.ink2);
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
          style: CatchTextStyles.titleL(
            context,
            color: valueColor ?? accent?.deep ?? t.ink,
          ),
        ),
        gapH2,
        Text(label, style: CatchTextStyles.name(context, color: t.ink)),
        if (supporting != null) ...[
          gapH2,
          Text(
            supporting!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
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
          iconColor: accent!.deep,
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
    return CatchFieldLanes.single(
      child: CatchField.nav(
        title: data.title,
        body: data.body,
        emphasis: CatchFieldEmphasis.title,
        titleMaxLines: 2,
        leading: CatchIconTile(
          icon: data.icon,
          iconColor: t.ink2,
          backgroundColor: t.primarySoft,
          borderColor: t.line,
          size: CatchSpacing.s10,
          iconSize: CatchIcon.sm,
          radius: CatchRadius.pill,
        ),
        leadingExtent: CatchSpacing.s12,
        onTap: onPrimary,
      ),
    );
  }
}

class HostTodayEventRow extends StatelessWidget {
  const HostTodayEventRow({
    super.key,
    required this.data,
    required this.onPressed,
  });

  final HostTodayEventRowData data;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(context, data.event.activityKind);
    final dateLabel = data.isLive
        ? context.l10n.hostsHostEventsListTextLive
        : data.isToday
        ? context.l10n.hostsHostEventsListTextToday
        : '${EventFormatters.shortWeekday(data.event.startTime)} '
              '${data.event.startTime.day} ${data.monthLabel}';
    return CatchFieldLanes.single(
      child: CatchField.nav(
        title: data.event.title,
        body: data.event.locationName,
        emphasis: CatchFieldEmphasis.title,
        titleMaxLines: 2,
        bodyMaxLines: 1,
        valueText: '$dateLabel\n${EventFormatters.time(data.event.startTime)}',
        valueMaxLines: 2,
        leading: HostTodayEventDateBlock(data: data, accent: activity.deep),
        leadingExtent: CatchSpacing.s12,
        onTap: onPressed,
      ),
    );
  }
}

class HostTodayEventDateBlock extends StatelessWidget {
  const HostTodayEventDateBlock({
    super.key,
    required this.data,
    required this.accent,
  });

  final HostTodayEventRowData data;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final activity = ActivityPalette.resolve(context, data.event.activityKind);
    return CatchIconTile(
      icon: activity.glyph,
      iconColor: accent,
      backgroundColor: activity.soft,
      borderColor: Colors.transparent,
      size: CatchSpacing.s10,
      iconSize: CatchIcon.md,
      radius: CatchRadius.pill,
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
