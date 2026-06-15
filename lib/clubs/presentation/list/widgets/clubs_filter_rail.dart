import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_bottom_sheet.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_count_pill.dart';
import 'package:catch_dating_app/core/widgets/catch_option_group.dart';
import 'package:catch_dating_app/core/widgets/select_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Explore scope + filter rail.
///
/// Mirrors the handoff `OptionGroup`: the primary time scope stays visible as
/// underline tabs while secondary filters move behind the trailing CountPill.
class ClubsFilterRail extends ConsumerWidget {
  const ClubsFilterRail({super.key, this.backgroundColor});

  final Color? backgroundColor;

  static const List<CatchOption<ExploreTimeFilter>> _timeOptions = [
    CatchOption(value: ExploreTimeFilter.tonight, label: 'Tonight'),
    CatchOption(value: ExploreTimeFilter.weekend, label: 'Weekend'),
    CatchOption(value: ExploreTimeFilter.thisWeek, label: 'This week'),
    CatchOption(value: ExploreTimeFilter.anytime, label: 'Anytime'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final filters = ref.watch(clubBrowseFiltersProvider);
    final filterController = ref.read(clubBrowseFiltersProvider.notifier);
    final activeCount = _activeFilterCount(filters);

    return ColoredBox(
      color: backgroundColor ?? t.bg,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          CatchSpacing.s4,
          CatchSpacing.s5,
          0,
        ),
        child: CatchOptionGroup<ExploreTimeFilter>(
          options: _timeOptions,
          selected: filters.timeFilter,
          onChanged: filterController.setTimeFilter,
          trailing: CatchCountPill(
            key: const ValueKey('explore-filter-pill'),
            icon: CatchIcons.tune,
            badge: activeCount == 0 ? null : '$activeCount',
            onPressed: () => _showExploreFilterSheet(context),
            semanticLabel: activeCount == 0
                ? 'Open explore filters'
                : 'Open explore filters, $activeCount active',
          ),
        ),
      ),
    );
  }
}

class _ExploreFilterSheet extends ConsumerWidget {
  const _ExploreFilterSheet();

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
    final filters = ref.watch(clubBrowseFiltersProvider);
    final controller = ref.read(clubBrowseFiltersProvider.notifier);
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
                SelectChip(
                  label: _distanceFilterLabel(distanceFilter),
                  active: filters.distanceFilter == distanceFilter,
                  onTap: () => controller.setDistanceFilter(distanceFilter),
                ),
            ],
          ),
          gapH20,
          Text('CLUBS', style: CatchTextStyles.kicker(context, color: t.ink2)),
          gapH12,
          SelectChip(
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
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _ExploreFilterSheet(),
  );
}

int _activeFilterCount(ClubBrowseFilterSelection filters) {
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
