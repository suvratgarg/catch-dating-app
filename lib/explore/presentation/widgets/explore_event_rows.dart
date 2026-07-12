import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_section_header.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/events/shared/event_detail_route_transition.dart';
import 'package:catch_dating_app/events/shared/event_tiles/event_tiles.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_event_support_widgets.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_synthetic_visual_fill.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

typedef ExploreEventSelected =
    void Function(ExploreEventItem item, String source);

class ExploreFeedEventRow extends StatelessWidget {
  const ExploreFeedEventRow({
    super.key,
    required this.item,
    this.onEventSelected,
    this.analyticsSource = 'mixed_row',
    this.stripPosition = EventDateRailCardStripPosition.single,
  });

  final ExploreEventItem item;
  final ExploreEventSelected? onEventSelected;
  final String analyticsSource;
  final EventDateRailCardStripPosition stripPosition;

  @override
  Widget build(BuildContext context) {
    final event = item.event;
    final state = ExploreEventRowState.from(item, l10n: context.l10n);
    final heroTag = isSyntheticExploreItem(item)
        ? null
        : eventTicketHeroTag(event.id, analyticsSource);
    return EventDateRailCard(
      event: event,
      kicker: state.kicker,
      supportingLabel: state.supportingLabel,
      priceLabel: state.priceLabel,
      capacityLabel: state.capacityLabel,
      statusLabel: state.statusLabel,
      stripPosition: stripPosition,
      heroTag: heroTag,
      onTap: isSyntheticExploreItem(item)
          ? null
          : () => onEventSelected?.call(item, analyticsSource),
    );
  }
}

class ExploreExternalEventRow extends StatelessWidget {
  const ExploreExternalEventRow({
    super.key,
    required this.item,
    this.onExternalEventOpened,
  });

  final ExploreExternalEventItem item;
  final ValueChanged<ExploreExternalEventItem>? onExternalEventOpened;

  @override
  Widget build(BuildContext context) {
    final event = item.event;
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(event.activityKind, context: context);
    final state = ExploreExternalEventRowState.from(item, l10n: context.l10n);
    return CatchSurface(
      radius: CatchRadius.md,
      borderColor: t.line2,
      elevation: CatchSurfaceElevation.card,
      padding: CatchInsets.content,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              EventActivityStamp(
                visual: visual,
                size: 26,
                iconSize: CatchIcon.sm,
              ),
              gapW8,
              Expanded(
                child: ExploreMonoLabel(state.sourceLabel, color: t.ink3),
              ),
              gapW8,
              EventStatusPill(label: state.statusLabel, color: visual.accent),
            ],
          ),
          gapH8,
          Text(
            event.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.eventDisplay(
              context,
              size: 25,
              height: 1.02,
            ),
          ),
          gapH4,
          Text(
            state.supportingLabel,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
          gapH10,
          Row(
            children: [
              EventClockMark(
                accent: visual.accent,
                time: TimeOfDay.fromDateTime(event.startTime),
                size: 17,
              ),
              gapW8,
              Expanded(
                child: Text(
                  state.timePriceLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.mono(context, color: t.ink2),
                ),
              ),
              gapW12,
              CatchButton(
                label: state.actionLabel,
                icon: Icon(CatchIcons.arrowUpRight, size: CatchIcon.sm),
                size: CatchButtonSize.sm,
                variant: CatchButtonVariant.secondary,
                onPressed: !state.hasExternalLink
                    ? null
                    : () => onExternalEventOpened?.call(item),
                semanticsLabel: state.actionSemanticsLabel,
              ),
            ],
          ),
          gapH8,
          ExploreMonoLabel(state.readOnlySupplyLabel, color: t.ink3),
        ],
      ),
    );
  }
}

class ThisWeekRecommendationsSection extends StatelessWidget {
  const ThisWeekRecommendationsSection({
    super.key,
    required this.items,
    this.onEventSelected,
  });

  final List<ExploreEventItem> items;
  final ExploreEventSelected? onEventSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        ExploreMonoLabel(
          context.l10n.exploreExploreEventRowsVisiblecopyComingUpLength(
            length: items.length,
          ),
          color: CatchTokens.of(context).ink3,
        ),
        gapH2,
        CatchSectionHeader(
          title: context.l10n.exploreExploreEventRowsTitleThisWeek,
          padding: EdgeInsets.zero,
          titleStyle: CatchTextStyles.clubDisplay(
            context,
            size: 38,
            height: 0.92,
          ),
        ),
        gapH12,
        for (var index = 0; index < items.length; index += 1) ...[
          ExploreFeedEventRow(
            item: items[index],
            onEventSelected: onEventSelected,
            analyticsSource: 'this_week',
            stripPosition: eventDateRailCardStripPositionFor(
              index,
              items.length,
            ),
          ),
        ],
      ],
    );
  }
}
