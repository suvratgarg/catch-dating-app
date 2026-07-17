import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_status_dot.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

const int _activityPreviewCount = 5;

class ExploreEventTypeBrowseGrid extends StatefulWidget {
  const ExploreEventTypeBrowseGrid({
    super.key,
    this.items = const [],
    this.activeActivityTag,
    this.onCategoryTap,
  });

  final List<ExploreEventItem> items;
  final String? activeActivityTag;
  final ValueChanged<ActivityKind>? onCategoryTap;

  @override
  State<ExploreEventTypeBrowseGrid> createState() =>
      _ExploreEventTypeBrowseGridState();
}

class _ExploreEventTypeBrowseGridState
    extends State<ExploreEventTypeBrowseGrid> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return EventTypeBrowseContent(
      items: widget.items,
      activeActivityTag: widget.activeActivityTag,
      expanded: _expanded,
      onCategoryTap: widget.onCategoryTap ?? (_) {},
      onExpand: () => setState(() => _expanded = true),
    );
  }
}

class EventTypeBrowseContent extends StatelessWidget {
  const EventTypeBrowseContent({
    super.key,
    required this.items,
    required this.activeActivityTag,
    required this.expanded,
    required this.onCategoryTap,
    required this.onExpand,
  });

  final List<ExploreEventItem> items;
  final String? activeActivityTag;
  final bool expanded;
  final ValueChanged<ActivityKind> onCategoryTap;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final entries = _rankedActivityEntries(items);
    if (entries.isEmpty) return const SizedBox.shrink();

    final visibleEntries = expanded
        ? entries
        : entries.take(_activityPreviewCount).toList(growable: false);
    final remainingCount = entries.length - visibleEntries.length;
    final slots = [
      for (final entry in visibleEntries) ActivitySlot.entry(entry),
      if (!expanded && remainingCount > 0) ActivitySlot.more(remainingCount),
    ];

    return Padding(
      padding: CatchInsets.eventTypeBrowseIndex,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.exploreExploreEventTypeBrowseGridTextByActivity,
            style: CatchTextStyles.kicker(context),
          ),
          gapH16,
          ActivityTypeRows(
            slots: slots,
            activeActivityTag: activeActivityTag,
            onCategoryTap: onCategoryTap,
            onExpand: onExpand,
          ),
        ],
      ),
    );
  }
}

class ActivityTypeRows extends StatelessWidget {
  const ActivityTypeRows({
    super.key,
    required this.slots,
    required this.activeActivityTag,
    required this.onCategoryTap,
    required this.onExpand,
  });

  final List<ActivitySlot> slots;
  final String? activeActivityTag;
  final ValueChanged<ActivityKind> onCategoryTap;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns =
            constraints.maxWidth >=
                ComponentBreakpoints.eventTypeGridTwoColumnBreakpoint
            ? 2
            : 1;
        if (columns == 1) {
          return Column(
            children: [
              for (final slot in slots)
                ActivitySlotView(
                  slot: slot,
                  activeActivityTag: activeActivityTag,
                  onCategoryTap: onCategoryTap,
                  onExpand: onExpand,
                ),
            ],
          );
        }

        final rowCount = (slots.length / columns).ceil();
        return Column(
          children: [
            for (var row = 0; row < rowCount; row += 1)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ActivitySlotView(
                      slot: slots[row * columns],
                      activeActivityTag: activeActivityTag,
                      onCategoryTap: onCategoryTap,
                      onExpand: onExpand,
                    ),
                  ),
                  gapW24,
                  Expanded(
                    child: row * columns + 1 < slots.length
                        ? ActivitySlotView(
                            slot: slots[row * columns + 1],
                            activeActivityTag: activeActivityTag,
                            onCategoryTap: onCategoryTap,
                            onExpand: onExpand,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }
}

class ActivitySlotView extends StatelessWidget {
  const ActivitySlotView({
    super.key,
    required this.slot,
    required this.activeActivityTag,
    required this.onCategoryTap,
    required this.onExpand,
  });

  final ActivitySlot slot;
  final String? activeActivityTag;
  final ValueChanged<ActivityKind> onCategoryTap;
  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    final entry = slot.entry;
    if (entry == null) {
      return MoreActivityTypesRow(
        remainingCount: slot.remainingCount,
        onTap: onExpand,
      );
    }
    return ActivityTypeRow(
      entry: entry,
      active: _matchesActiveTag(activeActivityTag, entry.activityKind),
      onTap: () => onCategoryTap(entry.activityKind),
    );
  }
}

class ActivityTypeRow extends StatelessWidget {
  const ActivityTypeRow({
    super.key,
    required this.entry,
    required this.active,
    required this.onTap,
  });

  final ActivityEntry entry;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(entry.activityKind, context: context);
    final foreground = active ? visual.deep : t.ink;
    return Semantics(
      button: true,
      selected: active,
      label: context.l10n.exploreExploreEventTypeBrowseGridLabelLabelCountlabel(
        label: visual.label,
        countLabel: _countLabel(entry.count),
      ),
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.line)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: CatchLayout.eventTypeIndexRowHeight,
            ),
            child: Row(
              children: [
                CatchStatusDot(
                  color: visual.accent,
                  size: CatchLayout.eventTypeIndexDotSize,
                ),
                gapW16,
                Expanded(
                  child: Text(
                    visual.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.titleL(context, color: foreground),
                  ),
                ),
                gapW12,
                Text(
                  context.l10n.exploreExploreEventTypeBrowseGridTextCount(
                    count: entry.count,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: CatchTextStyles.titleL(context, color: t.ink2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MoreActivityTypesRow extends StatelessWidget {
  const MoreActivityTypesRow({
    super.key,
    required this.remainingCount,
    required this.onTap,
  });

  final int remainingCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final label = context.l10n
        .exploreExploreEventTypeBrowseGridLabelRemainingcountMoreTypes(
          remainingCount: remainingCount,
        );
    return Semantics(
      button: true,
      label: context.l10n
          .exploreExploreEventTypeBrowseGridLabelShowRemainingcountMoreActivity(
            remainingCount: remainingCount,
          ),
      child: InkWell(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.line)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: CatchLayout.eventTypeIndexRowHeight,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: CatchTextStyles.kicker(context, color: t.ink3),
                  ),
                ),
                gapW12,
                Icon(
                  CatchIcons.forwardArrow,
                  size: CatchIcon.sm,
                  color: t.ink3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class EventTypeBrowseSkeleton extends StatelessWidget {
  const EventTypeBrowseSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.eventTypeBrowseSkeleton,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.eventTypeSkeletonTextWidth),
          gapH16,
          CatchSkeleton.card(height: CatchLayout.eventTypeIndexRowHeight),
          gapH12,
          CatchSkeleton.card(height: CatchLayout.eventTypeIndexRowHeight),
        ],
      ),
    );
  }
}

List<ActivityEntry> _rankedActivityEntries(List<ExploreEventItem> items) {
  final counts = <ActivityKind, int>{};
  final firstSeen = <ActivityKind, int>{};
  for (var index = 0; index < items.length; index += 1) {
    final item = items[index];
    firstSeen.putIfAbsent(item.event.activityKind, () => index);
    counts.update(
      item.event.activityKind,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }

  final entries = [
    for (final entry in counts.entries)
      ActivityEntry(
        activityKind: entry.key,
        count: entry.value,
        firstSeenIndex: firstSeen[entry.key] ?? items.length,
      ),
  ];
  entries.sort((a, b) {
    final countOrder = b.count.compareTo(a.count);
    if (countOrder != 0) return countOrder;

    final firstSeenOrder = a.firstSeenIndex.compareTo(b.firstSeenIndex);
    if (firstSeenOrder != 0) return firstSeenOrder;

    return a.activityKind.label.compareTo(b.activityKind.label);
  });
  return entries;
}

String _countLabel(int count) {
  return switch (count) {
    0 => 'No events',
    1 => '1 event',
    _ => '$count events',
  };
}

bool _matchesActiveTag(String? tag, ActivityKind kind) {
  final normalized = tag?.trim().toLowerCase();
  return normalized == kind.name.toLowerCase() ||
      normalized == kind.label.toLowerCase();
}

class ActivityEntry {
  const ActivityEntry({
    required this.activityKind,
    required this.count,
    required this.firstSeenIndex,
  });

  final ActivityKind activityKind;
  final int count;
  final int firstSeenIndex;
}

class ActivitySlot {
  const ActivitySlot.entry(this.entry) : remainingCount = 0;

  const ActivitySlot.more(this.remainingCount) : entry = null;

  final ActivityEntry? entry;
  final int remainingCount;
}
