import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/riverpod_ui/catch_localized_error_state.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/events/domain/event_formatters.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/hosts/today/presentation/widgets/host_today_event_spotlight.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

export 'host_today_event_spotlight.dart';

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
      taskCountIsComplete: state.attentionCountIsComplete,
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

    return CatchViewport.atWidth(
      breakpoint: CatchLayout.hostTodayTwoPaneBreakpoint,
      compactBuilder: (_) => Column(
        key: const ValueKey<String>('host-today-compact-layout'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (event != null)
            CatchSection.content(
              child: HostTodayEventSpotlight(
                event: event,
                now: now,
                taskCount: taskCount,
                taskCountIsComplete: state.attentionCountIsComplete,
                onPressed: () => onOpenEvent(event),
              ),
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
      expandedBuilder: (_) => CatchViewport.atWidth(
        breakpoint: CatchLayout.hostTodayExpandedAttentionPaneBreakpoint,
        compactBuilder: (_) => _HostTodayWideLayout(
          primary: primary,
          attention: attention,
          attentionVisible: attentionVisible,
          attentionPaneWidth: CatchLayout.hostTodayAttentionPaneCompactWidth,
        ),
        expandedBuilder: (_) => _HostTodayWideLayout(
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
    required this.taskCountIsComplete,
    required this.now,
    required this.onOpenEvent,
    required this.onViewEvents,
    required this.onStartRehearsal,
  });

  final HostTodayState state;
  final Event? event;
  final int taskCount;
  final bool taskCountIsComplete;
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
          CatchSection.content(
            child: HostTodayEventSpotlight(
              event: event!,
              now: now,
              taskCount: taskCount,
              taskCountIsComplete: state.attentionCountIsComplete,
              contained: false,
              onPressed: () => onOpenEvent(event!),
            ),
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
          CatchSection.rows(
            title: context.l10n.hostTodayLater,
            entries: [
              for (final data in state.laterEvents)
                CatchField.navigate(
                  key: ValueKey<String>('host-today-event-${data.event.id}'),
                  content: hostTodayEventLayout(context, data),
                  onActivate: () => onOpenEvent(data.event),
                ),
            ],
          ),
        if (state.laterEvents.isNotEmpty) gapH16,
        CatchSection.content(
          child: Wrap(
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
                leading: Icon(CatchIcons.scienceOutlined, size: CatchIcon.sm),
                variant: CatchButtonVariant.ghost,
                size: CatchButtonSize.sm,
                onPressed: onStartRehearsal,
              ),
            ],
          ),
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
          CatchSection.content(
            child: CatchLocalizedErrorState(
              issue.error,
              context: AppErrorContext.event,
              onRetry: onRetry,
              mode: CatchErrorStateMode.inline,
            ),
          ),
          gapH12,
        ],
        if (state.attentionItems.isNotEmpty)
          CatchSection.rows(
            title: context.l10n.hostsHostTodayTitleNeedsYou,
            count: state.attentionCountIsComplete
                ? state.attentionItems.length
                : null,
            entries: [
              for (final data in state.attentionItems)
                CatchField.navigate(
                  key: ValueKey<String>('host-today-attention-${data.item.id}'),
                  content: CatchRecordLayout(
                    title: data.title,
                    icon: data.icon,
                    description: data.body,
                  ),
                  onActivate: () => onOpenAttention(data.item),
                ),
            ],
          ),
      ],
    );
  }
}

CatchRecordLayout hostTodayEventLayout(
  BuildContext context,
  HostTodayEventRowData data,
) {
  final activity = ActivityPalette.resolve(context, data.event.activityKind);
  return CatchRecordLayout(
    title: data.event.title,
    icon: activity.glyph,
    color: activity.deep,
    metadata:
        '${MaterialLocalizations.of(context).formatMediumDate(data.event.startTime)} · ${EventFormatters.time(data.event.startTime)}',
    description: data.event.locationName,
  );
}
