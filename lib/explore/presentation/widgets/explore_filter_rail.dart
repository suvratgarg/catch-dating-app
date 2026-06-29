import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/catch_select_chip.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Explore scope + filter rail.
///
/// Mirrors the handoff `OptionGroup`: the primary time scope stays visible as
/// underline tabs while secondary filters move behind a right-aligned glyph.
class ExploreFilterRail extends ConsumerWidget {
  const ExploreFilterRail({super.key, this.backgroundColor});

  final Color? backgroundColor;

  static const double _optionGap = CatchSpacing.s3;

  static const List<CatchOption<ExploreTimeFilter>> _timeOptions = [
    CatchOption(value: ExploreTimeFilter.tonight, label: 'Tonight'),
    CatchOption(value: ExploreTimeFilter.weekend, label: 'Weekend'),
    CatchOption(value: ExploreTimeFilter.thisWeek, label: 'This week'),
    CatchOption(value: ExploreTimeFilter.anytime, label: 'Anytime'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final filters = ref.watch(exploreFiltersProvider);
    final filterController = ref.read(exploreFiltersProvider.notifier);
    final activeCount = _activeFilterCount(filters);

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
                          onTap: () =>
                              filterController.setTimeFilter(option.value),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              gapW12,
              ExploreFilterGlyphButton(
                key: const ValueKey('explore-filter-button'),
                activeCount: activeCount,
                onTap: () => _showExploreFilterSheet(context),
              ),
            ],
          ),
        ),
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
    required this.onTap,
  });

  final int activeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final semanticLabel = activeCount == 0
        ? 'Open explore filters'
        : 'Open explore filters, $activeCount active';

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

class ExploreFilterSheet extends ConsumerWidget {
  const ExploreFilterSheet({super.key});

  static const List<ExploreDistanceFilter> _distanceFilters = [
    ExploreDistanceFilter.any,
    ExploreDistanceFilter.oneKm,
    ExploreDistanceFilter.threeKm,
    ExploreDistanceFilter.fiveKm,
    ExploreDistanceFilter.tenKm,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final filters = ref.watch(exploreFiltersProvider);
    final controller = ref.read(exploreFiltersProvider.notifier);
    final activeCount = _activeFilterCount(filters);

    return CatchBottomSheetScaffold(
      title: 'Explore filters',
      subtitle: 'Narrow the map and feed without changing your time scope.',
      action: Row(
        children: [
          if (activeCount > 0) ...[
            Expanded(
              child: CatchButton(
                label: 'Clear',
                variant: CatchButtonVariant.secondary,
                onPressed: controller.clear,
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
              for (final distanceFilter in _distanceFilters)
                CatchSelectChip(
                  label: _distanceFilterLabel(distanceFilter),
                  active: filters.distanceFilter == distanceFilter,
                  onTap: () => controller.setDistanceFilter(distanceFilter),
                ),
            ],
          ),
          gapH20,
          Text('CLUBS', style: CatchTextStyles.kicker(context, color: t.ink2)),
          gapH12,
          CatchSelectChip(
            label: 'Joined clubs',
            active: filters.joinedOnly,
            onTap: controller.toggleJoinedOnly,
          ),
        ],
      ),
    );
  }
}

Future<void> _showExploreFilterSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const ExploreFilterSheet(),
  );
}

int _activeFilterCount(ExploreFilterSelection filters) {
  var count = 0;
  if (filters.timeFilter != defaultExploreTimeFilter) count += 1;
  if (filters.distanceFilter != ExploreDistanceFilter.any) count += 1;
  if (filters.highRatedOnly) count += 1;
  if (filters.joinedOnly) count += 1;
  if (filters.activityTag != null) count += 1;
  if (filters.area != null) count += 1;
  return count;
}

String _distanceFilterLabel(ExploreDistanceFilter filter) {
  return switch (filter) {
    ExploreDistanceFilter.any => 'Any',
    ExploreDistanceFilter.oneKm => '1 km',
    ExploreDistanceFilter.threeKm => '3 km',
    ExploreDistanceFilter.fiveKm => '5 km',
    ExploreDistanceFilter.tenKm => '10 km',
  };
}
