import 'package:catch_dating_app/explore/presentation/explore_screen.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_events_section.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_list.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Skeleton list states',
  type: ExploreSkeletonList,
  path: '[Explore]/Sections',
)
Widget exploreSkeletonListStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ExploreSkeletonList',
    catalogId: 'section.explore.skeleton_list',
    children: [
      WidgetbookPageStateCard(
        label: 'route loading stack',
        child: const WidgetbookExploreDeviceFrame(
          height: WidgetbookPreviewLayout.profileSectionPreviewHeight,
          child: SingleChildScrollView(
            padding: CatchInsets.pageBody,
            child: ExploreSkeletonList(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Directory skeleton list',
  type: ClubDirectorySkeletonList,
  path: '[Explore]/Sections',
)
Widget clubDirectorySkeletonListStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubDirectorySkeletonList',
    catalogId: 'section.explore.list.directory_skeleton_list',
    children: [
      WidgetbookPageStateCard(
        label: 'loading stack',
        child: const WidgetbookExploreDeviceFrame(
          height: WidgetbookPreviewLayout.celebrationViewportHeight,
          child: SingleChildScrollView(
            padding: CatchInsets.pageBody,
            child: ClubDirectorySkeletonList(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Directory skeleton card',
  type: ClubDirectorySkeletonCard,
  path: '[Explore]/Sections',
)
Widget clubDirectorySkeletonCardStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubDirectorySkeletonCard',
    catalogId: 'section.explore.list.directory_skeleton_card',
    children: [
      WidgetbookPageStateCard(
        label: 'single card',
        child: const WidgetbookExploreDeviceFrame(
          height: WidgetbookPreviewLayout.profileSectionPreviewHeight,
          child: Padding(
            padding: CatchInsets.pageBody,
            child: ClubDirectorySkeletonCard(),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Loading sliver states',
  type: ExploreEventsLoadingSliver,
  path: '[Explore]/Sections',
)
Widget exploreEventsLoadingSliverStates(BuildContext context) {
  return const WidgetbookScrollCatalogFrame(
    title: 'ExploreEventsLoadingSliver',
    catalogId: 'section.explore.feed.loading',
    children: [
      WidgetbookPageStateCard(
        label: 'bounded skeleton',
        child: WidgetbookExploreSliverFrame(
          height: WidgetbookPreviewLayout.tallNarrowPanelHeight,
          child: CustomScrollView(slivers: [ExploreEventsLoadingSliver()]),
        ),
      ),
    ],
  );
}
