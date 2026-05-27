import 'dart:math' as math;

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/clubs/presentation/list/explore_feed_view_model.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreEventTypeBrowseGrid extends ConsumerWidget {
  const ExploreEventTypeBrowseGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feedAsync = ref.watch(exploreFeedViewModelProvider);
    final filters = ref.watch(clubBrowseFiltersProvider);
    return switch (feedAsync) {
      AsyncLoading() => const _EventTypeBrowseSkeleton(),
      AsyncError() => const SizedBox.shrink(),
      AsyncData(:final value) => _EventTypeBrowseContent(
        items: value.items,
        activeActivityTag: filters.activityTag,
        onCategoryTap: (activityKind) => ref
            .read(clubBrowseFiltersProvider.notifier)
            .toggleActivityTag(activityKind.name),
      ),
    };
  }
}

class _EventTypeBrowseContent extends StatelessWidget {
  const _EventTypeBrowseContent({
    required this.items,
    required this.activeActivityTag,
    required this.onCategoryTap,
  });

  final List<ExploreEventItem> items;
  final String? activeActivityTag;
  final ValueChanged<ActivityKind> onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final counts = _countsByKind(items);
    final t = CatchTokens.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s5,
        CatchSpacing.s5,
        CatchSpacing.s16 + CatchSpacing.s5,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Browse by event type',
                  style: CatchTextStyles.titleL(context),
                ),
              ),
              if (activeActivityTag != null) ...[
                gapW8,
                Text(
                  'Filtered',
                  style: CatchTextStyles.labelL(context, color: t.primary),
                ),
              ],
            ],
          ),
          gapH12,
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 360 ? 2 : 1;
              const spacing = CatchSpacing.s3;
              final rawTileWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              final tileWidth = math.min(rawTileWidth, 340.0);
              final tileHeight = columns >= 2
                  ? CatchSpacing.s9 * 2
                  : CatchSpacing.s11 * 2;
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final activityKind in primaryBrowseActivityKinds)
                    SizedBox(
                      width: tileWidth,
                      height: tileHeight,
                      child: _EventTypeTile(
                        activityKind: activityKind,
                        count: counts[activityKind] ?? 0,
                        active: _matchesActiveTag(
                          activeActivityTag,
                          activityKind,
                        ),
                        onTap: () => onCategoryTap(activityKind),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EventTypeTile extends StatelessWidget {
  const _EventTypeTile({
    required this.activityKind,
    required this.count,
    required this.active,
    required this.onTap,
  });

  final ActivityKind activityKind;
  final int count;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = eventActivityVisual(activityKind);
    return Semantics(
      button: true,
      selected: active,
      label: visual.label,
      child: CatchSurface(
        onTap: onTap,
        radius: CatchRadius.md,
        borderColor: active ? visual.accent : t.line2,
        backgroundColor: active
            ? visual.soft.withValues(alpha: 0.62)
            : t.surface,
        elevation: CatchSurfaceElevation.card,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: -30,
              right: -28,
              child: _EventTypeColorCue(visual: visual, active: active),
            ),
            Positioned(
              right: CatchSpacing.s4,
              top: 0,
              bottom: 0,
              child: Icon(
                active ? CatchIcons.checkRounded : CatchIcons.forwardArrow,
                size: active ? 16 : 14,
                color: visual.deep.withValues(alpha: active ? 0.88 : 0.66),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                CatchSpacing.s4,
                CatchSpacing.s3,
                CatchSpacing.s7,
                CatchSpacing.s3,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    visual.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.getFont(
                      'Instrument Serif',
                      fontSize: 26,
                      fontStyle: FontStyle.italic,
                      height: 0.98,
                      letterSpacing: 0,
                      color: t.ink,
                    ),
                  ),
                  gapH2,
                  Text(
                    _countLabel(count).toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.ibmPlexMono(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      color: t.ink3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTypeColorCue extends StatelessWidget {
  const _EventTypeColorCue({required this.visual, required this.active});

  final EventActivityVisualSpec visual;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: active ? 102 : 92,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              visual.accent.withValues(alpha: active ? 1.0 : 0.92),
              visual.deep.withValues(alpha: active ? 0.7 : 0.58),
              Colors.transparent,
            ],
            stops: const [0, 0.52, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: visual.accent.withValues(alpha: active ? 0.34 : 0.26),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTypeBrowseSkeleton extends StatelessWidget {
  const _EventTypeBrowseSkeleton();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        CatchSpacing.s5,
        CatchSpacing.s5,
        CatchSpacing.s5,
        CatchSpacing.s4,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: 172),
          gapH12,
          CatchSkeleton.card(height: 120),
        ],
      ),
    );
  }
}

Map<ActivityKind, int> _countsByKind(List<ExploreEventItem> items) {
  final counts = <ActivityKind, int>{};
  for (final item in items) {
    counts.update(
      item.event.activityKind,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
  }
  return counts;
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
