import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/core/app_error_message.dart';
import 'package:catch_dating_app/core/responsive/responsive_builder.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_empty_state.dart';
import 'package:catch_dating_app/core/widgets/catch_error_state.dart';
import 'package:catch_dating_app/core/widgets/catch_screen_scaffold.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton_layouts.dart';
import 'package:catch_dating_app/core/widgets/catch_top_bar.dart';
import 'package:catch_dating_app/events/domain/event.dart';
import 'package:catch_dating_app/hosts/today/domain/host_attention_item.dart';
import 'package:catch_dating_app/hosts/today/presentation/host_today_state.dart';
import 'package:catch_dating_app/hosts/today/presentation/widgets/host_today_overview.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';

class HostTodayBody extends StatelessWidget {
  const HostTodayBody({
    super.key,
    required this.organizer,
    required this.state,
    required this.now,
    required this.onRetry,
    required this.onOpenEvent,
    required this.onOpenAttention,
    required this.onViewEvents,
    required this.onStartRehearsal,
  });

  final Club organizer;
  final HostTodayState state;
  final DateTime now;
  final VoidCallback onRetry;
  final ValueChanged<Event> onOpenEvent;
  final ValueChanged<HostAttentionItem> onOpenAttention;
  final VoidCallback onViewEvents;
  final VoidCallback onStartRehearsal;

  @override
  Widget build(BuildContext context) {
    return CatchRootScreenScaffold.standard(
      scrollKey: const ValueKey<String>('host-today-scroll-view'),
      header: HostTodayHeader(now: now),
      maxContentExtent: CatchLayout.hostTodayWorkspacePageMaxExtent,
      slivers: [
        switch (state.status) {
          HostTodayStatus.loading => const SliverToBoxAdapter(
            child: CatchSkeletonRows(
              leading: CatchSkeletonRowLeading.mediaTile,
              count: 4,
            ),
          ),
          HostTodayStatus.error => CatchSliverErrorState.fromError(
            state.error!,
            context: AppErrorContext.event,
            onRetry: onRetry,
          ),
          HostTodayStatus.empty => SliverToBoxAdapter(
            child: HostTodayQuietState(
              onViewEvents: onViewEvents,
              onStartRehearsal: onStartRehearsal,
            ),
          ),
          HostTodayStatus.content => SliverToBoxAdapter(
            child: HostTodayOverview(
              state: state,
              now: now,
              onRetry: onRetry,
              onOpenEvent: onOpenEvent,
              onOpenAttention: onOpenAttention,
              onViewEvents: onViewEvents,
              onStartRehearsal: onStartRehearsal,
            ),
          ),
        },
      ],
    );
  }
}

class HostTodayHeader extends StatelessWidget {
  const HostTodayHeader({super.key, this.now});

  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final date = now == null
        ? null
        : MaterialLocalizations.of(context).formatFullDate(now!);
    return ComponentResponsiveBuilder(
      breakpoint: CatchLayout.hostTodayTwoPaneBreakpoint,
      compact: (_) => CatchScreenHeaderTitle.block(
        title: context.l10n.hostNavigationToday,
        titleStyle: CatchTextStyles.eventTitle(context),
      ),
      expanded: (_) => CatchScreenHeaderTitle.block(
        title: context.l10n.hostNavigationToday,
        eyebrow: date,
        titleStyle: CatchTextStyles.eventTitle(context),
      ),
    );
  }
}

class HostTodayQuietState extends StatelessWidget {
  const HostTodayQuietState({
    super.key,
    required this.onViewEvents,
    required this.onStartRehearsal,
  });

  final VoidCallback onViewEvents;
  final VoidCallback onStartRehearsal;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: CatchLayout.maxContentWidth),
      child: Column(
        key: const ValueKey<String>('host-today-quiet-state'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchEmptyStateIcon(
            icon: CatchIcons.eventBusy,
            style: CatchEmptyStateIconStyle.bubble,
            size: CatchIcon.md,
            containerSize: CatchSpacing.s12,
          ),
          gapH20,
          Text(
            context.l10n.hostTodayEmptyTitle,
            style: CatchTextStyles.headlineS(context, color: t.ink),
          ),
          gapH8,
          Text(
            context.l10n.hostTodayEmptyBody,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH20,
          Wrap(
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
      ),
    );
  }
}
