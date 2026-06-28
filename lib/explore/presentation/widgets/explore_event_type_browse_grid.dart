import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/responsive/component_breakpoints.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const int _activityPreviewCount = 5;

class ExploreEventTypeBrowseGrid extends ConsumerStatefulWidget {
  const ExploreEventTypeBrowseGrid({super.key});

  @override
  ConsumerState<ExploreEventTypeBrowseGrid> createState() =>
      _ExploreEventTypeBrowseGridState();
}

class _ExploreEventTypeBrowseGridState
    extends ConsumerState<ExploreEventTypeBrowseGrid> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final feedAsync = ref.watch(exploreFeedViewModelProvider);
    final filters = ref.watch(exploreFiltersProvider);
    return switch (feedAsync) {
      AsyncLoading() => _buildEventTypeBrowseSkeleton(),
      AsyncError() => const SizedBox.shrink(),
      AsyncData(:final value) => _buildEventTypeBrowseContent(
        context,
        items: value.items,
        activeActivityTag: filters.activityTag,
        expanded: _expanded,
        onCategoryTap: (activityKind) => ref
            .read(exploreFiltersProvider.notifier)
            .toggleActivityTag(activityKind.name),
        onExpand: () => setState(() => _expanded = true),
      ),
    };
  }
}

Widget _buildEventTypeBrowseContent(
  BuildContext context, {
  required List<ExploreEventItem> items,
  required String? activeActivityTag,
  required bool expanded,
  required ValueChanged<ActivityKind> onCategoryTap,
  required VoidCallback onExpand,
}) {
  final entries = _rankedActivityEntries(items);
  if (entries.isEmpty) return const SizedBox.shrink();

  final visibleEntries = expanded
      ? entries
      : entries.take(_activityPreviewCount).toList(growable: false);
  final remainingCount = entries.length - visibleEntries.length;
  final slots = [
    for (final entry in visibleEntries) _ActivitySlot.entry(entry),
    if (!expanded && remainingCount > 0) _ActivitySlot.more(remainingCount),
  ];

  return Padding(
    padding: CatchInsets.eventTypeBrowseIndex,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('BY ACTIVITY', style: CatchTextStyles.kicker(context)),
        gapH16,
        _buildActivityTypeRows(
          slots: slots,
          activeActivityTag: activeActivityTag,
          onCategoryTap: onCategoryTap,
          onExpand: onExpand,
        ),
      ],
    ),
  );
}

Widget _buildActivityTypeRows({
  required List<_ActivitySlot> slots,
  required String? activeActivityTag,
  required ValueChanged<ActivityKind> onCategoryTap,
  required VoidCallback onExpand,
}) {
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
              _buildActivitySlotView(
                context,
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
                  child: _buildActivitySlotView(
                    context,
                    slot: slots[row * columns],
                    activeActivityTag: activeActivityTag,
                    onCategoryTap: onCategoryTap,
                    onExpand: onExpand,
                  ),
                ),
                gapW24,
                Expanded(
                  child: row * columns + 1 < slots.length
                      ? _buildActivitySlotView(
                          context,
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

Widget _buildActivitySlotView(
  BuildContext context, {
  required _ActivitySlot slot,
  required String? activeActivityTag,
  required ValueChanged<ActivityKind> onCategoryTap,
  required VoidCallback onExpand,
}) {
  final entry = slot.entry;
  if (entry == null) {
    return _buildMoreActivityTypesRow(
      context,
      remainingCount: slot.remainingCount,
      onTap: onExpand,
    );
  }
  return _buildActivityTypeRow(
    context,
    entry: entry,
    active: _matchesActiveTag(activeActivityTag, entry.activityKind),
    onTap: () => onCategoryTap(entry.activityKind),
  );
}

Widget _buildActivityTypeRow(
  BuildContext context, {
  required _ActivityEntry entry,
  required bool active,
  required VoidCallback onTap,
}) {
  final t = CatchTokens.of(context);
  final visual = eventActivityVisual(entry.activityKind, context: context);
  final foreground = active ? visual.deep : t.ink;
  return Semantics(
    button: true,
    selected: active,
    label: '${visual.label}, ${_countLabel(entry.count)}',
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
              _buildActivityDot(color: visual.accent),
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
                '${entry.count}',
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

Widget _buildMoreActivityTypesRow(
  BuildContext context, {
  required int remainingCount,
  required VoidCallback onTap,
}) {
  final t = CatchTokens.of(context);
  final label = '+ $remainingCount MORE TYPES';
  return Semantics(
    button: true,
    label: 'Show $remainingCount more activity types',
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
              Icon(CatchIcons.forwardArrow, size: CatchIcon.sm, color: t.ink3),
            ],
          ),
        ),
      ),
    ),
  );
}

Widget _buildActivityDot({required Color color}) {
  return CatchSurface(
    width: CatchLayout.eventTypeIndexDotSize,
    height: CatchLayout.eventTypeIndexDotSize,
    radius: CatchRadius.pill,
    borderWidth: 0,
    backgroundColor: color,
    child: const SizedBox.shrink(),
  );
}

Widget _buildEventTypeBrowseSkeleton() {
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

List<_ActivityEntry> _rankedActivityEntries(List<ExploreEventItem> items) {
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
      _ActivityEntry(
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

class _ActivityEntry {
  const _ActivityEntry({
    required this.activityKind,
    required this.count,
    required this.firstSeenIndex,
  });

  final ActivityKind activityKind;
  final int count;
  final int firstSeenIndex;
}

class _ActivitySlot {
  const _ActivitySlot.entry(this.entry) : remainingCount = 0;

  const _ActivitySlot.more(this.remainingCount) : entry = null;

  final _ActivityEntry? entry;
  final int remainingCount;
}
