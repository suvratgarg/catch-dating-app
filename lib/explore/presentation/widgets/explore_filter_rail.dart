import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:catch_dating_app/core/widgets/catch_icon_button.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_tab_rail.dart';
import 'package:catch_dating_app/core/widgets/event_activity_visuals.dart';
import 'package:catch_dating_app/explore/presentation/explore_filter_logic.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
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
    this.dateStripState,
    this.sheetState,
    this.onTimeFilterSelected,
    this.onDistanceFilterSelected,
    this.onToggleJoinedOnly,
    this.onToggleHighRatedOnly,
    this.onToggleActivityTag,
    this.onToggleArea,
    this.onClearFilters,
    this.onOpenFilters,
    this.backgroundColor,
    this.showJoinedOnly = true,
  });

  final Color? backgroundColor;
  final ExploreFilterSelection filters;
  final ExploreFilterRailState? state;
  final ExploreDateStripState? dateStripState;
  final ExploreFilterSheetState? sheetState;
  final ValueChanged<ExploreTimeFilter>? onTimeFilterSelected;
  final ValueChanged<ExploreDistanceFilter>? onDistanceFilterSelected;
  final VoidCallback? onToggleJoinedOnly;
  final VoidCallback? onToggleHighRatedOnly;
  final ValueChanged<String>? onToggleActivityTag;
  final ValueChanged<String>? onToggleArea;
  final VoidCallback? onClearFilters;
  final VoidCallback? onOpenFilters;
  final bool showJoinedOnly;

  static List<CatchOption<ExploreTimeFilter>> _timeOptions(
    ExploreDateStripState state,
  ) => [
    for (final option in state.options)
      CatchOption(value: option.value, label: option.label),
  ];

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final railState =
        state ?? ExploreFilterRailState.from(filters, l10n: context.l10n);
    final effectiveDateStripState =
        dateStripState ??
        ExploreDateStripState.from(viewModel: null, l10n: context.l10n);
    final appliedFilters = _appliedFilterChips(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CatchTabRail<ExploreTimeFilter>(
          selected: filters.timeFilter,
          onChanged: onTimeFilterSelected,
          options: _timeOptions(effectiveDateStripState),
          scrollable: true,
          backgroundColor: backgroundColor ?? t.bg,
          trailing: CatchIconButton.counted(
            key: const ValueKey('explore-filter-button'),
            icon: CatchIcons.tuneRounded,
            count: railState.activeCount,
            variant: CatchIconButtonVariant.plain,
            tooltip: railState.filterButtonSemanticLabel,
            onTap: onOpenFilters ?? () => _showExploreFilterSheet(context),
          ),
        ),
        if (appliedFilters.isNotEmpty)
          SingleChildScrollView(
            key: const ValueKey('explore-applied-filter-row'),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s5,
              CatchSpacing.s2,
              CatchSpacing.s5,
              CatchSpacing.s2,
            ),
            child: Row(spacing: CatchSpacing.s2, children: appliedFilters),
          ),
      ],
    );
  }

  List<Widget> _appliedFilterChips(BuildContext context) {
    final chips = <Widget>[];
    if (filters.distanceFilter != ExploreDistanceFilter.any) {
      final option = exploreDistanceFilterOptions(
        context.l10n,
      ).firstWhere((candidate) => candidate.value == filters.distanceFilter);
      chips.add(
        CatchChip.removable(
          key: const ValueKey('explore-applied-distance'),
          label: context.l10n.exploreExploreFilterRailAppliedDistance(
            distance: option.label,
          ),
          onRemove: () =>
              onDistanceFilterSelected?.call(ExploreDistanceFilter.any),
          enabled: onDistanceFilterSelected != null,
        ),
      );
    }
    if (showJoinedOnly && filters.joinedOnly) {
      chips.add(
        CatchChip.removable(
          key: const ValueKey('explore-applied-joined'),
          label: context.l10n.exploreExploreFilterRailLabelJoinedClubs,
          onRemove: () => onToggleJoinedOnly?.call(),
          enabled: onToggleJoinedOnly != null,
        ),
      );
    }
    if (filters.highRatedOnly) {
      chips.add(
        CatchChip.removable(
          key: const ValueKey('explore-applied-rating'),
          label: context.l10n.exploreExploreFilterRailLabelRated45,
          onRemove: () => onToggleHighRatedOnly?.call(),
          enabled: onToggleHighRatedOnly != null,
        ),
      );
    }
    final activityTag = filters.activityTag;
    if (activityTag != null) {
      chips.add(
        CatchChip.removable(
          key: const ValueKey('explore-applied-activity'),
          label: _activityFilterLabel(activityTag),
          onRemove: () => onToggleActivityTag?.call(activityTag),
          enabled: onToggleActivityTag != null,
        ),
      );
    }
    final area = filters.area;
    if (area != null) {
      chips.add(
        CatchChip.removable(
          key: const ValueKey('explore-applied-area'),
          label: area,
          onRemove: () => onToggleArea?.call(area),
          enabled: onToggleArea != null,
        ),
      );
    }
    return chips;
  }

  String _activityFilterLabel(String selected) {
    for (final kind in primaryBrowseActivityKinds) {
      if (_activityFilterActive(selected, kind)) return kind.label;
    }
    return selected;
  }

  Future<void> _showExploreFilterSheet(BuildContext context) {
    return showCatchBottomSheet<void>(
      context: context,
      builder: (_) => ExploreFilterSheet(
        filters: filters,
        state: sheetState,
        onDistanceFilterSelected: onDistanceFilterSelected,
        onToggleJoinedOnly: onToggleJoinedOnly,
        onToggleHighRatedOnly: onToggleHighRatedOnly,
        onToggleActivityTag: onToggleActivityTag,
        onToggleArea: onToggleArea,
        onClearFilters: onClearFilters,
        showJoinedOnly: showJoinedOnly,
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
    this.onToggleHighRatedOnly,
    this.onToggleActivityTag,
    this.onToggleArea,
    this.onClearFilters,
    this.showJoinedOnly = true,
  });

  final ExploreFilterSelection filters;
  final ExploreFilterSheetState? state;
  final ValueChanged<ExploreDistanceFilter>? onDistanceFilterSelected;
  final VoidCallback? onToggleJoinedOnly;
  final VoidCallback? onToggleHighRatedOnly;
  final ValueChanged<String>? onToggleActivityTag;
  final ValueChanged<String>? onToggleArea;
  final VoidCallback? onClearFilters;
  final bool showJoinedOnly;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final sheetState =
        state ??
        ExploreFilterSheetState.from(
          filters: filters,
          sourceClubs: const [],
          l10n: context.l10n,
        );

    return CatchBottomSheetScaffold(
      title: context.l10n.exploreExploreFilterRailTitleExploreFilters,
      subtitle: context.l10n.exploreExploreFilterRailSubtitleNarrowTheMapAnd,
      action: Row(
        children: [
          if (sheetState.activeCount > 0) ...[
            Expanded(
              child: CatchButton(
                label: context.l10n.exploreExploreFilterRailLabelClear,
                variant: CatchButtonVariant.secondary,
                onPressed: onClearFilters,
              ),
            ),
            gapW8,
          ],
          Expanded(
            child: CatchButton(
              label: sheetState.actionLabel,
              isLoading: sheetState.actionLoading,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.sizeOf(context).height *
              CatchLayout.sheetMaxHeightFraction,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.l10n.exploreExploreFilterRailTextDistanceEventsOnly,
                style: CatchTextStyles.kicker(context, color: t.ink2),
              ),
              gapH12,
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  for (final option in sheetState.distanceOptions)
                    CatchChip.selectable(
                      label: option.label,
                      selected: filters.distanceFilter == option.value,
                      enabled: onDistanceFilterSelected != null,
                      onChanged: (_) =>
                          onDistanceFilterSelected?.call(option.value),
                    ),
                ],
              ),
              gapH20,
              Text(
                context.l10n.exploreExploreFilterRailTextClubs,
                style: CatchTextStyles.kicker(context, color: t.ink2),
              ),
              gapH12,
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  if (showJoinedOnly)
                    CatchChip.selectable(
                      key: const ValueKey('explore-filter-joined'),
                      label:
                          context.l10n.exploreExploreFilterRailLabelJoinedClubs,
                      selected: filters.joinedOnly,
                      enabled: onToggleJoinedOnly != null,
                      onChanged: (_) => onToggleJoinedOnly?.call(),
                    ),
                  CatchChip.selectable(
                    label: context.l10n.exploreExploreFilterRailLabelRated45,
                    selected: filters.highRatedOnly,
                    enabled: onToggleHighRatedOnly != null,
                    onChanged: (_) => onToggleHighRatedOnly?.call(),
                  ),
                ],
              ),
              gapH20,
              Text(
                context.l10n.exploreExploreFilterRailTextActivity,
                style: CatchTextStyles.kicker(context, color: t.ink2),
              ),
              gapH12,
              Wrap(
                spacing: CatchSpacing.s2,
                runSpacing: CatchSpacing.s2,
                children: [
                  for (final kind in primaryBrowseActivityKinds)
                    CatchChip.selectable(
                      label: kind.label,
                      selected: _activityFilterActive(
                        filters.activityTag,
                        kind,
                      ),
                      enabled: onToggleActivityTag != null,
                      onChanged: (_) => onToggleActivityTag?.call(kind.name),
                    ),
                ],
              ),
              if (sheetState.areaOptions.isNotEmpty) ...[
                gapH20,
                Text(
                  context.l10n.exploreExploreFilterRailTextArea,
                  style: CatchTextStyles.kicker(context, color: t.ink2),
                ),
                gapH12,
                Wrap(
                  spacing: CatchSpacing.s2,
                  runSpacing: CatchSpacing.s2,
                  children: [
                    for (final area in sheetState.areaOptions)
                      CatchChip.selectable(
                        label: area,
                        selected: exploreFilterValuesMatch(filters.area, area),
                        enabled: onToggleArea != null,
                        onChanged: (_) => onToggleArea?.call(area),
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
