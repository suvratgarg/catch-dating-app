import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/shared/club_identity_atoms.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/page_preview.dart';
import 'fixtures.dart';

@widgetbook.UseCase(
  name: 'Tag wrap states',
  type: ClubTagWrap,
  path: '[Club Discovery]/Atoms',
)
Widget clubTagWrapStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubTagWrap',
    catalogId: 'atom.club.tag_wrap',
    children: [
      WidgetbookPageStateCard(
        label: 'brand tags',
        child: ClubTagWrap(tags: visibleClubTags(widgetbookClubClub, limit: 4)),
      ),
      const WidgetbookPageStateCard(
        label: 'neutral mixed case',
        child: ClubTagWrap(
          tags: ['coffee', 'first timers'],
          tone: CatchBadgeTone.neutral,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Host identity states',
  type: ClubHostIdentityLine,
  path: '[Club Discovery]/Atoms',
)
Widget clubHostIdentityLineStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubHostIdentityLine',
    catalogId: 'atom.club.host_identity_line',
    children: [
      WidgetbookPageStateCard(
        label: 'with trailing',
        child: ClubHostIdentityLine(
          hostName: widgetbookClubClub.displayHostName,
          hostAvatarUrl: widgetbookClubClub.hostAvatarUrl,
          trailing: const CatchBadge(label: 'Owner'),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'fallback avatar',
        child: ClubHostIdentityLine(
          hostName: widgetbookClubMinimalClub.displayHostName,
        ),
      ),
    ],
  );
}
