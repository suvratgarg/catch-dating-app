import 'package:catch_dating_app/clubs/data/clubs_repository.dart';
import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/list/clubs_list_view_model.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClubsFilterRail extends ConsumerWidget {
  const ClubsFilterRail({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = CatchTokens.of(context);
    final city = ref.watch(selectedClubCityProvider);
    final clubs =
        ref.watch(watchClubsByLocationProvider(city.name)).asData?.value ??
        const <Club>[];
    final filters = ref.watch(clubBrowseFiltersProvider);
    final filterController = ref.read(clubBrowseFiltersProvider.notifier);
    final activityTags = _topFilterValues(
      clubs.expand((club) => club.tags),
      selected: filters.activityTag,
    );
    final areas = _topFilterValues(
      clubs.map((club) => club.area),
      selected: filters.area,
      limit: 5,
    );

    return SliverToBoxAdapter(
      child: ColoredBox(
        color: t.bg,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(
            CatchSpacing.s5,
            0,
            CatchSpacing.s5,
            CatchSpacing.s3,
          ),
          child: Row(
            children: [
              CatchChip(
                label: 'This week',
                active: filters.thisWeekOnly,
                icon: const Icon(Icons.event_available_outlined),
                onTap: filterController.toggleThisWeekOnly,
              ),
              gapW8,
              CatchChip(
                label: 'Rated 4.5+',
                active: filters.highRatedOnly,
                icon: const Icon(Icons.star_rounded),
                onTap: filterController.toggleHighRatedOnly,
              ),
              gapW8,
              CatchChip(
                label: 'Joined',
                active: filters.joinedOnly,
                icon: const Icon(Icons.check_circle_outline_rounded),
                onTap: filterController.toggleJoinedOnly,
              ),
              gapW8,
              CatchChip(
                label: 'Hosted',
                active: filters.hostedOnly,
                icon: const Icon(Icons.shield_outlined),
                onTap: filterController.toggleHostedOnly,
              ),
              for (final tag in activityTags) ...[
                gapW8,
                CatchChip(
                  label: _titleCase(tag),
                  active: _sameDisplayValue(filters.activityTag, tag),
                  icon: const Icon(Icons.local_fire_department_outlined),
                  onTap: () => filterController.toggleActivityTag(tag),
                ),
              ],
              for (final area in areas) ...[
                gapW8,
                CatchChip(
                  label: area,
                  active: _sameDisplayValue(filters.area, area),
                  icon: const Icon(Icons.location_on_outlined),
                  onTap: () => filterController.toggleArea(area),
                ),
              ],
              if (filters.hasActiveFilters) ...[
                gapW8,
                CatchChip(
                  label: 'Clear',
                  icon: const Icon(Icons.close_rounded),
                  onTap: filterController.clear,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

List<String> _topFilterValues(
  Iterable<String?> values, {
  String? selected,
  int limit = 4,
}) {
  final counts = <String, int>{};
  final labels = <String, String>{};

  for (final value in values) {
    final label = value?.trim();
    if (label == null || label.isEmpty) continue;
    final key = label.toLowerCase();
    counts[key] = (counts[key] ?? 0) + 1;
    labels.putIfAbsent(key, () => label);
  }

  final sortedKeys = counts.keys.toList()
    ..sort((a, b) {
      final countCompare = counts[b]!.compareTo(counts[a]!);
      if (countCompare != 0) return countCompare;
      return labels[a]!.compareTo(labels[b]!);
    });
  final result = sortedKeys.map((key) => labels[key]!).take(limit).toList();
  final selectedValue = selected?.trim();
  if (selectedValue != null &&
      selectedValue.isNotEmpty &&
      !result.any((value) => _sameDisplayValue(value, selectedValue))) {
    result.insert(0, selectedValue);
  }
  return result.take(limit).toList(growable: false);
}

bool _sameDisplayValue(String? left, String right) {
  return left?.trim().toLowerCase() == right.trim().toLowerCase();
}

String _titleCase(String value) {
  return value
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map((part) {
        if (part.length == 1) return part.toUpperCase();
        return '${part[0].toUpperCase()}${part.substring(1)}';
      })
      .join(' ');
}
