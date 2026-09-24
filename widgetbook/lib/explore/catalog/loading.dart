import 'package:catch_dating_app/explore/presentation/widgets/explore_events_section.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_feed_skeleton.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Skeleton list states',
  type: ExploreFeedSkeleton,
  path: '[Explore]/Sections',
)
Widget exploreSkeletonListStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ExploreFeedSkeleton',
    catalogId: 'section.explore.skeleton_list',
    children: [
      WidgetbookPageStateCard(
        label: 'route loading stack',
        child: const WidgetbookExploreDeviceFrame(
          height: WidgetbookPreviewLayout.profileSectionPreviewHeight,
          child: SingleChildScrollView(
            padding: CatchInsets.pageBody,
            child: ExploreFeedSkeleton(),
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
