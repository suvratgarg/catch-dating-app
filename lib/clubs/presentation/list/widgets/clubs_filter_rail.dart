import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Single-row time + distance filter rail.
///
/// The rail is deliberately short: time chips (the primary scope) followed by
/// a compact distance chip set, a "Joined" toggle, and a contextual Clear.
/// Activity tag and area chips were removed from this rail — they crowded
/// the row and pushed the more important time/distance filters off screen.
/// Bring them back through the search field or a future "More filters" sheet
/// when the use-case justifies it.
class ClubsFilterRail extends ConsumerWidget {
  const ClubsFilterRail({super.key, this.backgroundColor});

  final Color? backgroundColor;

  static const List<ExploreTimeFilter> _timeFilters = [
    ExploreTimeFilter.tonight,
    ExploreTimeFilter.tomorrow,
    ExploreTimeFilter.weekend,
    ExploreTimeFilter.thisWeek,
    ExploreTimeFilter.anytime,
  ];

  static const List<ExploreDistanceFilter> _distanceFilters = [
    ExploreDistanceFilter.oneKm,
    ExploreDistanceFilter.threeKm,
    ExploreDistanceFilter.fiveKm,
    ExploreDistanceFilter.tenKm,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final filters = ref.watch(clubBrowseFiltersProvider);
    final filterController = ref.read(clubBrowseFiltersProvider.notifier);

    return ColoredBox(
      color: backgroundColor ?? t.bg,
      child: SingleChildScrollView(
        key: const ValueKey('explore-filter-rail-scroll-view'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(
          CatchSpacing.s5,
          CatchSpacing.micro2,
          CatchSpacing.s5,
          CatchSpacing.s3,
        ),
        child: Row(
          children: [
            for (final timeFilter in _timeFilters) ...[
              CatchChip(
                label: _timeFilterLabel(timeFilter),
                active: filters.timeFilter == timeFilter,
                icon: Icon(_timeFilterIcon(timeFilter)),
                onTap: () => filterController.toggleTimeFilter(timeFilter),
              ),
              gapW8,
            ],
            _RailDivider(color: t.line2),
            gapW8,
            for (final distanceFilter in _distanceFilters) ...[
              CatchChip(
                label: _distanceFilterLabel(distanceFilter),
                active: filters.distanceFilter == distanceFilter,
                icon: Icon(CatchIcons.nearMeOutlined),
                onTap: () =>
                    filterController.toggleDistanceFilter(distanceFilter),
              ),
              gapW8,
            ],
            _RailDivider(color: t.line2),
            gapW8,
            CatchChip(
              label: 'Joined',
              active: filters.joinedOnly,
              icon: Icon(CatchIcons.joined),
              onTap: filterController.toggleJoinedOnly,
            ),
            if (filters.hasActiveFilters) ...[
              gapW8,
              CatchChip(
                label: 'Clear',
                icon: Icon(CatchIcons.clear),
                onTap: filterController.clear,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RailDivider extends StatelessWidget {
  const _RailDivider({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 22, color: color);
  }
}

String _distanceFilterLabel(ExploreDistanceFilter filter) {
  return switch (filter) {
    ExploreDistanceFilter.any => 'Any distance',
    ExploreDistanceFilter.oneKm => '1 km',
    ExploreDistanceFilter.threeKm => '3 km',
    ExploreDistanceFilter.fiveKm => '5 km',
    ExploreDistanceFilter.tenKm => '10 km',
  };
}

String _timeFilterLabel(ExploreTimeFilter filter) {
  return switch (filter) {
    ExploreTimeFilter.anytime => 'Anytime',
    ExploreTimeFilter.tonight => 'Tonight',
    ExploreTimeFilter.tomorrow => 'Tomorrow',
    ExploreTimeFilter.weekend => 'Weekend',
    ExploreTimeFilter.thisWeek => 'This week',
  };
}

IconData _timeFilterIcon(ExploreTimeFilter filter) {
  return switch (filter) {
    ExploreTimeFilter.anytime => CatchIcons.anytime,
    ExploreTimeFilter.tonight => CatchIcons.tonight,
    ExploreTimeFilter.tomorrow => CatchIcons.tomorrow,
    ExploreTimeFilter.weekend => CatchIcons.weekend,
    ExploreTimeFilter.thisWeek => CatchIcons.thisWeek,
  };
}
