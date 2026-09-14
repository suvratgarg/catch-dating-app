import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_detail_body.dart';
import 'package:catch_dating_app/clubs/shared/club_identity_atoms.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/contract_preview.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';

@widgetbook.UseCase(
  name: 'Next run banner states',
  type: ClubNextRunBanner,
  path: '[Club Detail]/Sections',
)
Widget clubNextRunBannerStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubNextRunBanner',
    catalogId: 'section.club.next_run_banner',
    children: [
      WidgetbookPageStateCard(
        label: 'tap target',
        child: ClubNextRunBanner(
          event: widgetbookClubEvents.first,
          onTap: widgetbookNoop,
        ),
      ),
      WidgetbookPageStateCard(
        label: 'display only',
        child: ClubNextRunBanner(event: widgetbookClubEvents[1]),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Activity section states',
  type: ClubActivitySection,
  path: '[Club Detail]/Sections',
)
Widget clubActivitySectionStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubActivitySection',
    catalogId: 'section.club.activity',
    children: [
      WidgetbookPageStateCard(
        label: 'activity and tags',
        child: ClubActivitySection(
          club: widgetbookClubClub,
          tags: visibleClubTags(widgetbookClubClub, limit: 6),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'generic dinner tags',
        child: ClubActivitySection(
          club: widgetbookClubMinimalClub,
          tags: visibleClubTags(widgetbookClubMinimalClub, limit: 4),
        ),
      ),
    ],
  );
}
