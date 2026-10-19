import 'package:catch_dating_app/clubs/shared/club_host_identity_row.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/page_preview.dart';
import 'fixtures.dart';

@widgetbook.UseCase(
  name: 'Tag wrap states',
  type: ClubTagList,
  path: '[Club Discovery]/Atoms',
)
Widget clubTagWrapStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubTagList',
    catalogId: 'atom.club.tag_wrap',
    children: [
      WidgetbookPageStateCard(
        label: 'brand tags',
        child: ClubTagList(tags: visibleClubTags(widgetbookClubClub, limit: 4)),
      ),
      const WidgetbookPageStateCard(
        label: 'neutral mixed case',
        child: ClubTagList(
          tags: ['coffee', 'first timers'],
          tone: CatchBadgeTone.neutral,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host identity states',
  type: ClubHostIdentityRow,
  path: '[Club Discovery]/Atoms',
)
Widget clubHostIdentityLineStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubHostIdentityRow',
    catalogId: 'atom.club.host_identity_line',
    children: [
      WidgetbookPageStateCard(
        label: 'with trailing',
        child: ClubHostIdentityRow(
          hostName: widgetbookClubClub.displayHostName,
          hostAvatarUrl: widgetbookClubClub.hostAvatarUrl,
          trailing: const CatchBadge(label: 'Owner'),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'fallback avatar',
        child: ClubHostIdentityRow(
          hostName: widgetbookClubMinimalClub.displayHostName,
        ),
      ),
    ],
  );
}
