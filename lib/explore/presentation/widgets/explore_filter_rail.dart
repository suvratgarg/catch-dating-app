import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/explore/presentation/explore_filter_logic.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:flutter/material.dart';

/// Explore scope + filter rail.
///
/// Mirrors the handoff `OptionGroup`: the primary time scope stays visible as
/// underline tabs while secondary filters move behind a right-aligned glyph.
class ExploreFilterRail extends StatelessWidget {
  const ExploreFilterRail({
    super.key,
    this.filters = const ExploreFilterSelection(),
    this.state,
    this.sheetState,
    this.onTimeFilterSelected,
    this.onDistanceFilterSelected,
    this.onToggleJoinedOnly,
    this.onToggleFollowingOnly,
    this.onToggleHighRatedOnly,
    this.onToggleActivityTag,
    this.onToggleArea,
    this.onClearFilters,
    this.backgroundColor,
  });

  final Color? backgroundColor;
  final ExploreFilterSelection filters;
  final ExploreFilterRailState? state;
  final ExploreFilterSheetState? sheetState;
  final ValueChanged<ExploreTimeFilter>? onTimeFilterSelected;
  final ValueChanged<ExploreDistanceFilter>? onDistanceFilterSelected;
  final VoidCallback? onToggleJoinedOnly;
  final VoidCallback? onToggleFollowingOnly;
  final VoidCallback? onToggleHighRatedOnly;
  final ValueChanged<String>? onToggleActivityTag;
  final ValueChanged<String>? onToggleArea;
  final VoidCallback? onClearFilters;

  static const List<CatchOption<ExploreTimeFilter>> _timeOptions = [
    CatchOption(value: ExploreTimeFilter.tonight, label: 'Tonight'),
    CatchOption(value: ExploreTimeFilter.weekend, label: 'Weekend'),
    CatchOption(value: ExploreTimeFilter.thisWeek, label: 'This week'),
    CatchOption(value: ExploreTimeFilter.anytime, label: 'Anytime'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final railState = state ?? ExploreFilterRailState.from(filters);

    return CatchTabRail<ExploreTimeFilter>(
      selected: filters.timeFilter,
      onChanged: onTimeFilterSelected,
      options: _timeOptions,
      scrollable: true,
      backgroundColor: backgroundColor ?? t.bg,
      trailing: ExploreFilterGlyphButton(
        key: const ValueKey('explore-filter-button'),
        activeCount: railState.activeCount,
        semanticLabel: railState.filterButtonSemanticLabel,
        onTap: () => _showExploreFilterSheet(context),
      ),
    );
  }

  Future<void> _showExploreFilterSheet(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExploreFilterSheet(
        filters: filters,
        state: sheetState,
        onDistanceFilterSelected: onDistanceFilterSelected,
        onToggleJoinedOnly: onToggleJoinedOnly,
        onToggleFollowingOnly: onToggleFollowingOnly,
        onToggleHighRatedOnly: onToggleHighRatedOnly,
        onToggleActivityTag: onToggleActivityTag,
        onToggleArea: onToggleArea,
        onClearFilters: onClearFilters,
      ),
    );
  }
}

class ExploreFilterGlyphButton extends StatelessWidget {
  const ExploreFilterGlyphButton({
    super.key,
    required this.activeCount,
    required this.semanticLabel,
    required this.onTap,
  });

  final int activeCount;
  final String semanticLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return Tooltip(
      message: semanticLabel,
      child: Semantics(
        button: true,
        label: semanticLabel,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(CatchRadius.pill),
            child: CatchIconBadge(
              label: '$activeCount',
              isLabelVisible: activeCount > 0,
              backgroundColor: t.ink,
              foregroundColor: t.surface,
              offset: const Offset(-4, 4),
              child: SizedBox.square(
                dimension: CatchLayout.iconButtonNavSize,
                child: Center(
                  child: Icon(
                    CatchIcons.tuneRounded,
                    color: t.ink,
                    size: CatchIcon.md,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ExploreFilterSheet extends StatelessWidget {
  const ExploreFilterSheet({
    super.key,
    this.filters = const ExploreFilterSelection(),
    this.state,
    this.onDistanceFilterSelected,
    this.onToggleJoinedOnly,
    this.onToggleFollowingOnly,
    this.onToggleHighRatedOnly,
    this.onToggleActivityTag,
    this.onToggleArea,
    this.onClearFilters,
  });

  final ExploreFilterSelection filters;
  final ExploreFilterSheetState? state;
  final ValueChanged<ExploreDistanceFilter>? onDistanceFilterSelected;
  final VoidCallback? onToggleJoinedOnly;
  final VoidCallback? onToggleFollowingOnly;
  final VoidCallback? onToggleHighRatedOnly;
  final ValueChanged<String>? onToggleActivityTag;
  final ValueChanged<String>? onToggleArea;
  final VoidCallback? onClearFilters;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final sheetState =
        state ??
        ExploreFilterSheetState.from(filters: filters, sourceClubs: const []);

    return CatchBottomSheetScaffold(
      title: 'Explore filters',
      subtitle: 'Narrow the map and feed without changing your time scope.',
      action: Row(
        children: [
          if (sheetState.activeCount > 0) ...[
            Expanded(
              child: CatchButton(
                label: 'Clear',
                variant: CatchButtonVariant.secondary,
                onPressed: onClearFilters,
              ),
            ),
            gapW8,
          ],
          Expanded(
            child: CatchButton(
              label: 'Done',
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.56,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'DISTANCE',
                style: CatchTextStyles.kicker(context, color: t.ink2),
              ),
              gapH12,
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  for (final option in sheetState.distanceOptions)
                    CatchSelectChip(
                      label: option.label,
                      active: filters.distanceFilter == option.value,
                      onTap: () => onDistanceFilterSelected?.call(option.value),
                    ),
                ],
              ),
              gapH20,
              Text(
                'CLUBS',
                style: CatchTextStyles.kicker(context, color: t.ink2),
              ),
              gapH12,
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  CatchSelectChip(
                    label: 'Joined clubs',
                    active: filters.joinedOnly,
                    onTap: onToggleJoinedOnly,
                  ),
                  CatchSelectChip(
                    label: 'Following',
                    active: filters.followingOnly,
                    onTap: onToggleFollowingOnly,
                  ),
                  CatchSelectChip(
                    label: 'Rated 4.5+',
                    active: filters.highRatedOnly,
                    onTap: onToggleHighRatedOnly,
                  ),
                ],
              ),
              gapH20,
              Text(
                'ACTIVITY',
                style: CatchTextStyles.kicker(context, color: t.ink2),
              ),
              gapH12,
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  for (final kind in primaryBrowseActivityKinds)
                    CatchSelectChip(
                      label: kind.label,
                      active: _activityFilterActive(filters.activityTag, kind),
                      onTap: () => onToggleActivityTag?.call(kind.name),
                    ),
                ],
              ),
              if (sheetState.areaOptions.isNotEmpty) ...[
                gapH20,
                Text(
                  'AREA',
                  style: CatchTextStyles.kicker(context, color: t.ink2),
                ),
                gapH12,
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    for (final area in sheetState.areaOptions)
                      CatchSelectChip(
                        label: area,
                        active: exploreFilterValuesMatch(filters.area, area),
                        onTap: () => onToggleArea?.call(area),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

bool _activityFilterActive(String? selected, ActivityKind kind) {
  return exploreFilterValuesMatch(selected, kind.name) ||
      exploreFilterValuesMatch(selected, kind.label);
}
