import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_skeleton.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Loading body states',
  type: ClubDetailLoadingBody,
  path: '[Club Detail]/Sections',
)
Widget clubDetailLoadingBodyStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubDetailLoadingBody',
    catalogId: 'screen.club.detail.loading_body',
    children: const [
      WidgetbookPageStateCard(
        label: 'skeleton',
        child: WidgetbookClubDeviceFrame(child: ClubDetailLoadingBody()),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hero skeleton states',
  type: ClubHeroLoadingSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubHeroLoadingSkeletonStates(BuildContext context) {
  return const WidgetbookScrollCatalogFrame(
    title: 'ClubHeroLoadingSkeleton',
    catalogId: 'loading.club.detail.hero',
    children: [
      WidgetbookPageStateCard(
        label: 'default',
        child: WidgetbookClubDeviceFrame(
          height: WidgetbookPreviewLayout.routeViewportHeight,
          child: ClubHeroLoadingSkeleton(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Stats skeleton states',
  type: ClubStatsLoadingSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubStatsLoadingSkeletonStates(BuildContext context) {
  return const WidgetbookScrollCatalogFrame(
    title: 'ClubStatsLoadingSkeleton',
    catalogId: 'loading.club.detail.stats',
    children: [
      WidgetbookPageStateCard(
        label: 'four metrics',
        child: ClubStatsLoadingSkeleton(),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Stat skeleton states',
  type: ClubStatLoadingSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubStatLoadingSkeletonStates(BuildContext context) {
  return const WidgetbookScrollCatalogFrame(
    title: 'ClubStatLoadingSkeleton',
    catalogId: 'loading.club.detail.stat',
    children: [
      WidgetbookPageStateCard(
        label: 'value and label',
        child: ClubStatLoadingSkeleton(),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Stats divider skeleton states',
  type: ClubStatsDividerSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubStatsDividerSkeletonStates(BuildContext context) {
  return const WidgetbookScrollCatalogFrame(
    title: 'ClubStatsDividerSkeleton',
    catalogId: 'loading.club.detail.stats_divider',
    children: [
      WidgetbookPageStateCard(
        label: 'hairline',
        child: SizedBox(
          height: WidgetbookPreviewLayout.skeletonListItemHeight,
          child: Center(child: ClubStatsDividerSkeleton()),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host skeleton states',
  type: ClubHostLoadingSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubHostLoadingSkeletonStates(BuildContext context) {
  return const WidgetbookScrollCatalogFrame(
    title: 'ClubHostLoadingSkeleton',
    catalogId: 'loading.club.detail.host',
    children: [
      WidgetbookPageStateCard(
        label: 'host row',
        child: ClubHostLoadingSkeleton(),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Text skeleton states',
  type: ClubTextLoadingSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubTextLoadingSkeletonStates(BuildContext context) {
  return const WidgetbookScrollCatalogFrame(
    title: 'ClubTextLoadingSkeleton',
    catalogId: 'loading.club.detail.text',
    children: [
      WidgetbookPageStateCard(
        label: 'three lines',
        child: ClubTextLoadingSkeleton(lines: 3),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Tag skeleton states',
  type: CatchSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubTagLoadingSkeletonStates(BuildContext context) {
  return const WidgetbookScrollCatalogFrame(
    title: 'CatchSkeleton',
    catalogId: 'loading.club.detail.tags',
    children: [
      WidgetbookPageStateCard(
        label: 'three chips',
        child: CatchSkeleton.chips(height: CatchSpacing.s8),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Schedule skeleton states',
  type: ClubScheduleLoadingSkeleton,
  path: '[Club Detail]/Loading',
)
Widget clubScheduleLoadingSkeletonStates(BuildContext context) {
  return const WidgetbookScrollCatalogFrame(
    title: 'ClubScheduleLoadingSkeleton',
    catalogId: 'loading.club.detail.schedule',
    children: [
      WidgetbookPageStateCard(
        label: 'two cards',
        child: ClubScheduleLoadingSkeleton(),
      ),
    ],
  );
}
