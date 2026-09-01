import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_section_layout.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_sheet.dart';
import 'package:catch_dating_app/hosts/events/presentation/host_event_entry_state.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/hosts/today/presentation/widgets/host_today_overview.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class HostTodayBody extends StatelessWidget {
  const HostTodayBody({
    super.key,
    required this.organizer,
    required this.state,
    required this.entryState,
    required this.now,
    required this.onRetry,
    required this.onEventEntrySelected,
    required this.onOpenEvent,
    required this.onOpenAttention,
    required this.onViewEvents,
    required this.onStartRehearsal,
  });

  final Club organizer;
  final HostTodayState state;
  final HostEventEntryState entryState;
  final DateTime now;
  final VoidCallback onRetry;
  final HostEventEntryCallback onEventEntrySelected;
  final ValueChanged<Event> onOpenEvent;
  final ValueChanged<HostAttentionItem> onOpenAttention;
  final VoidCallback onViewEvents;
  final VoidCallback onStartRehearsal;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      key: const ValueKey<String>('host-today-scroll-view'),
      slivers: [
        SliverToBoxAdapter(
          child: HostTodayHeader(
            onCreateEvent: () => _showEventEntrySheet(context),
          ),
        ),
        switch (state.status) {
          HostTodayStatus.loading => const SliverPadding(
            padding: CatchInsets.pageHorizontal,
            sliver: SliverToBoxAdapter(
              child: CatchSkeletonRows(
                leading: CatchSkeletonRowLeading.mediaTile,
                count: 4,
              ),
            ),
          ),
          HostTodayStatus.error => SliverPadding(
            padding: CatchInsets.pageHorizontal,
            sliver: SliverToBoxAdapter(
              child: CatchInlineErrorState.fromError(
                state.error!,
                context: AppErrorContext.event,
                onRetry: onRetry,
              ),
            ),
          ),
          HostTodayStatus.empty => CatchSliverEmptyState(
            icon: CatchIcons.eventBusy,
            title: context.l10n.hostTodayEmptyTitle,
            message: context.l10n.hostTodayEmptyBody,
            action: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CatchButton(
                  label: state.hasPastEvents
                      ? context.l10n.hostTodayViewAllEvents
                      : context.l10n.hostsHostEventsListLabelNewEvent,
                  size: CatchButtonSize.sm,
                  onPressed: state.hasPastEvents
                      ? onViewEvents
                      : () => _showEventEntrySheet(context),
                ),
                gapH8,
                CatchButton(
                  key: const ValueKey<String>(
                    'host-today-start-dress-rehearsal',
                  ),
                  label: context.l10n.hostEventRehearsalEntryTitle,
                  icon: Icon(CatchIcons.scienceOutlined, size: CatchIcon.sm),
                  variant: CatchButtonVariant.ghost,
                  size: CatchButtonSize.sm,
                  onPressed: onStartRehearsal,
                ),
              ],
            ),
          ),
          HostTodayStatus.content => SliverPadding(
            padding: CatchInsets.pageHorizontal,
            sliver: SliverList.list(
              children: [
                gapH20,
                HostTodayOverview(
                  state: state,
                  now: now,
                  onOpenEvent: onOpenEvent,
                  onOpenAttention: onOpenAttention,
                ),
                if (state.laterEvents.isNotEmpty) ...[
                  gapH24,
                  CatchSection.plain(
                    title: context.l10n.hostTodayLater,
                    titleColor: CatchTokens.of(context).ink3,
                    child: Column(
                      children: [
                        for (final data in state.laterEvents) ...[
                          HostTodayEventRow(
                            key: ValueKey<String>(
                              'host-today-event-${data.event.id}',
                            ),
                            data: data,
                            onPressed: () => onOpenEvent(data.event),
                          ),
                          gapH10,
                        ],
                      ],
                    ),
                  ),
                ],
                gapH12,
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    CatchButton(
                      key: const ValueKey<String>('host-today-view-events'),
                      label: context.l10n.hostTodayViewAllEvents,
                      variant: CatchButtonVariant.secondary,
                      size: CatchButtonSize.sm,
                      onPressed: onViewEvents,
                    ),
                    CatchButton(
                      key: const ValueKey<String>(
                        'host-today-start-dress-rehearsal',
                      ),
                      label: context.l10n.hostEventRehearsalEntryTitle,
                      icon: Icon(
                        CatchIcons.scienceOutlined,
                        size: CatchIcon.sm,
                      ),
                      variant: CatchButtonVariant.ghost,
                      size: CatchButtonSize.sm,
                      onPressed: onStartRehearsal,
                    ),
                  ],
                ),
              ],
            ),
          ),
        },
        const CatchSliverTerminalPadding(),
      ],
    );
  }

  Future<void> _showEventEntrySheet(BuildContext context) async {
    final intent = await showHostEventEntrySheet(
      context: context,
      state: entryState,
    );
    if (intent == null || !context.mounted) return;
    onEventEntrySelected(organizer, entryState, intent);
  }
}

class HostTodayHeader extends StatelessWidget {
  const HostTodayHeader({super.key, this.onCreateEvent});

  final VoidCallback? onCreateEvent;

  @override
  Widget build(BuildContext context) {
    final createEvent = onCreateEvent;
    return CatchScreenHeaderTitle.block(
      title: context.l10n.hostNavigationToday,
      actions: createEvent == null
          ? const []
          : [
              CatchTopBarPrimaryAction(
                key: const ValueKey<String>('host-today-create-event'),
                label: context.l10n.hostsHostEventsListLabelNewEvent,
                icon: CatchIcons.addRounded,
                onPressed: createEvent,
              ),
            ],
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
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, data.event.activityKind);

    return CatchSurface(
      borderColor: t.line,
      radius: CatchRadius.md,
      clipBehavior: Clip.antiAlias,
      onTap: onPressed,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 76),
        child: IntrinsicHeight(
          child: Row(
            children: [
              SizedBox(
                width: CatchSpacing.s1,
                child: ColoredBox(color: activity.accent),
              ),
              Padding(
                padding: CatchInsets.hostEventLifecycleDate,
                child: HostTodayEventDateBlock(
                  data: data,
                  accent: activity.accent,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: CatchInsets.contentVertical,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data.event.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.name(context, color: t.ink),
                      ),
                      gapH4,
                      Text(
                        data.metaLabel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: CatchTextStyles.monoLabelS(
                          context,
                          color: t.ink3,
                        ),
                      ),
                      gapH8,
                      ClipRRect(
                        borderRadius: BorderRadius.circular(CatchRadius.pill),
                        child: SizedBox(
                          height: CatchSpacing.s1,
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              ColoredBox(color: t.line2),
                              FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: data.fillRatio,
                                child: ColoredBox(color: activity.accent),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: CatchInsets.inlineHorizontalRelaxed,
                child: Icon(
                  CatchIcons.chevronRightRounded,
                  color: t.ink3,
                  size: CatchIcon.sm,
                ),
              ),
            ],
          ),
        ),
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
    final t = CatchTokens.of(context);
    final semanticLabel = data.isLive || data.isToday
        ? (data.isLive
              ? context.l10n.hostsHostEventsListTextLive
              : context.l10n.hostsHostEventsListTextToday)
        : '${data.dateLabel} ${data.monthLabel}';
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: CatchSpacing.s12,
        child: data.isLive || data.isToday
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(CatchIcons.eventLive, color: accent, size: CatchIcon.sm),
                  gapH3,
                  Text(
                    data.isLive
                        ? context.l10n.hostsHostEventsListTextLive
                        : context.l10n.hostsHostEventsListTextToday,
                    style: CatchTextStyles.monoLabelS(context, color: t.ink3),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.dateLabel,
                    style: CatchTextStyles.titleL(context, color: t.ink),
                  ),
                  gapH3,
                  Text(
                    data.monthLabel,
                    style: CatchTextStyles.monoLabelS(context, color: t.ink3),
                  ),
                ],
              ),
      ),
    );
  }
}
