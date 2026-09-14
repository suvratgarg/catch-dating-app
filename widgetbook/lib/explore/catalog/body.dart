import 'package:catch_dating_app/explore/presentation/explore_feed_view_model.dart';
import 'package:catch_dating_app/explore/presentation/explore_view_model.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_body.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'preview.dart';
import 'scope.dart';

@widgetbook.UseCase(
  name: 'Body sliver states',
  type: ExploreList,
  path: '[Explore]/Sections',
)
Widget exploreBodyStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'buildExploreBodySlivers',
    catalogId: 'section.explore.body_slivers',
    children: [
      WidgetbookPageStateCard(
        label: 'mixed body',
        child: WidgetbookExploreSliverFrame(
          child: WidgetbookExploreScope(
            child: const _ExploreBodySliverPreview(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'List sliver states',
  type: ExploreList,
  path: '[Explore]/Sections',
)
Widget exploreListStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ExploreList',
    catalogId: 'section.explore.list',
    children: [
      WidgetbookPageStateCard(
        label: 'provider-backed list',
        child: WidgetbookExploreSliverFrame(
          child: WidgetbookExploreScope(
            child: CustomScrollView(slivers: [ExploreList()]),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'empty search',
        child: WidgetbookExploreSliverFrame(
          height: WidgetbookPreviewLayout.sliverPreviewHeight,
          child: WidgetbookExploreScope(
            searchQuery: 'silent supper cycling crew',
            viewModel: const AsyncData(
              ExploreViewModel(joinedClubs: [], allClubs: []),
            ),
            child: CustomScrollView(slivers: [ExploreList()]),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'List empty state',
  type: ExploreListEmptyState,
  path: '[Explore]/Sections',
)
Widget exploreListEmptyStateStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ExploreListEmptyState',
    catalogId: 'section.explore.list.empty_state',
    children: [
      WidgetbookPageStateCard(
        label: 'city empty',
        child: WidgetbookExploreDeviceFrame(
          height: WidgetbookPreviewLayout.profileSectionPreviewHeight,
          child: WidgetbookExploreScope(
            child: const ExploreListEmptyState(
              cityLabel: 'Mumbai',
              hasSearch: false,
              filters: ExploreFilterSelection(),
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'search empty',
        child: WidgetbookExploreDeviceFrame(
          height: WidgetbookPreviewLayout.profileSectionPreviewHeight,
          child: WidgetbookExploreScope(
            child: const ExploreListEmptyState(
              cityLabel: 'Mumbai',
              hasSearch: true,
              filters: ExploreFilterSelection(),
            ),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'search and filters empty',
        child: WidgetbookExploreDeviceFrame(
          height: WidgetbookPreviewLayout.profileSectionPreviewHeight,
          child: WidgetbookExploreScope(
            child: const ExploreListEmptyState(
              cityLabel: 'Mumbai',
              hasSearch: true,
              filters: ExploreFilterSelection(
                distanceFilter: ExploreDistanceFilter.threeKm,
                activityTag: 'dinner',
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

class _ExploreBodySliverPreview extends ConsumerWidget {
  const _ExploreBodySliverPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filters = ref.watch(exploreFiltersProvider);
    return CustomScrollView(
      slivers: buildExploreBodySlivers(
        context: context,
        feedAsync: ref.watch(exploreFeedViewModelProvider),
        clubsViewModel: ExploreViewModel.partition(
          clubs: widgetbookExploreClubs,
          joinedClubIds: widgetbookExploreJoinedClubIds,
        ),
        filters: filters,
        searchQuery: ref.watch(exploreSearchQueryProvider).trim(),
        onRetryFeed: () => ref.invalidate(exploreFeedViewModelProvider),
        onClearSearch: () =>
            ref.read(exploreSearchQueryProvider.notifier).clear(),
        onClearFilters: () => ref.read(exploreFiltersProvider.notifier).clear(),
        onSetTimeFilter: (filter) =>
            ref.read(exploreFiltersProvider.notifier).setTimeFilter(filter),
        onActivitySelected: (activityKind) => ref
            .read(exploreFiltersProvider.notifier)
            .toggleActivityTag(activityKind.name),
        onEventSelected: (_, _) {},
        onExternalEventOpened: (_) {},
        includeJoinedClubsRail: true,
        includeClubDirectory: true,
        pinnedExploreDayHeaders: false,
      ),
    );
  }
}
