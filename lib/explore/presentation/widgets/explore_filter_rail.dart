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
  final VoidCallback? onToggleHighRatedOnly;
  final ValueChanged<String>? onToggleActivityTag;
  final ValueChanged<String>? onToggleArea;
  final VoidCallback? onClearFilters;

  static const double _optionGap = CatchSpacing.s3;

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

    return ColoredBox(
      color: backgroundColor ?? t.bg,
      child: Padding(
        padding: CatchInsets.screenControlRail,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: t.line)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final option in _timeOptions) ...[
                        if (option != _timeOptions.first)
                          const SizedBox(width: _optionGap),
                        ExploreRailLabel(
                          label: option.label,
                          selected: option.value == filters.timeFilter,
                          onTap: () => onTimeFilterSelected?.call(option.value),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              gapW12,
              ExploreFilterGlyphButton(
                key: const ValueKey('explore-filter-button'),
                activeCount: railState.activeCount,
                semanticLabel: railState.filterButtonSemanticLabel,
                onTap: () => _showExploreFilterSheet(context),
              ),
            ],
          ),
        ),
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
        onToggleHighRatedOnly: onToggleHighRatedOnly,
        onToggleActivityTag: onToggleActivityTag,
        onToggleArea: onToggleArea,
        onClearFilters: onClearFilters,
      ),
    );
  }
}

class ExploreRailLabel extends StatelessWidget {
  const ExploreRailLabel({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final foreground = selected ? t.ink : t.ink3;

    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: AnimatedContainer(
          duration: CatchMotion.fast,
          curve: CatchMotion.standardCurve,
          padding: EdgeInsets.only(
            bottom: selected ? CatchSpacing.micro10 : CatchSpacing.s3,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? t.ink : Colors.transparent,
                width: CatchSpacing.micro3,
              ),
            ),
          ),
          child: Text(
            label,
            maxLines: 1,
            softWrap: false,
            style: CatchTextStyles.labelL(context, color: foreground),
            textAlign: TextAlign.start,
          ),
        ),
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
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(CatchRadius.pill),
          child: SizedBox(
            width: CatchLayout.iconButtonSize,
            height: CatchLayout.browseHeaderSearchExtent,
            child: CatchIconBadge(
              label: '$activeCount',
              isLabelVisible: activeCount > 0,
              backgroundColor: t.ink,
              foregroundColor: t.surface,
              child: Icon(
                CatchIcons.tuneRounded,
                color: t.ink,
                size: CatchIcon.md,
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
    this.onToggleHighRatedOnly,
    this.onToggleActivityTag,
    this.onToggleArea,
    this.onClearFilters,
  });

  final ExploreFilterSelection filters;
  final ExploreFilterSheetState? state;
  final ValueChanged<ExploreDistanceFilter>? onDistanceFilterSelected;
  final VoidCallback? onToggleJoinedOnly;
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
