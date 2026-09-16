import 'package:catch_dating_app/clubs/presentation/detail/club_detail_read_only_preview.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_body.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'preview.dart';
import 'scope.dart';

@widgetbook.UseCase(
  name: 'Body composition',
  type: ClubDetailBody,
  path: '[Club Detail]/Sections',
)
Widget clubDetailBodyComposition(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubDetailBody',
    catalogId: 'screen.club.detail.sections.body',
    children: [
      WidgetbookPageStateCard(
        label: 'host / overview / photos / contact',
        description:
            'Body composition exercises the screen-local hosts, about, photo, and contact sections together.',
        child: WidgetbookClubDeviceFrame(
          child: WidgetbookClubClubComposedPreview(
            isMember: true,
            isAuthenticated: true,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'minimal club',
        description:
            'No cover, no photos, no contact, no reviews, empty schedule.',
        child: WidgetbookClubDeviceFrame(
          child: WidgetbookClubClubComposedPreview(
            club: widgetbookClubMinimalClub,
            events: const [],
            reviews: const [],
            isMember: false,
            isAuthenticated: true,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'reduced motion candidate',
        description:
            'Same composition in a static review frame; future motion checks should pin route transitions separately.',
        child: WidgetbookClubDeviceFrame(
          child: WidgetbookClubClubComposedPreview(
            isMember: true,
            isAuthenticated: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Embedded read-only preview',
  type: ClubDetailReadOnlyPreviewSliver,
  path: '[Club Detail]/Sections',
)
Widget clubDetailReadOnlyPreviewComposition(BuildContext context) {
  return const WidgetbookScrollCatalogFrame(
    title: 'ClubDetailReadOnlyPreviewSliver',
    catalogId: 'screen.club.detail.sections.read_only_preview',
    children: [
      WidgetbookPageStateCard(
        label: 'consumer composition / interactions disabled',
        child: WidgetbookClubDeviceFrame(
          child: WidgetbookClubClubReadOnlyPreview(),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Shared sliver composition',
  type: ClubDetailSliverBody,
  path: '[Club Detail]/Sections',
)
Widget clubDetailSliverBodyComposition(BuildContext context) =>
    clubDetailReadOnlyPreviewComposition(context);
