import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_share_card.dart';
import 'package:catch_dating_app/clubs/shared/club_identity_atoms.dart';
import 'package:catch_ui/catch_ui.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'preview.dart';

@widgetbook.UseCase(
  name: 'Share card states',
  type: ClubShareCard,
  path: '[Club Detail]/Cards',
)
Widget clubShareCardStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubShareCard',
    catalogId: 'card.club.share',
    children: [
      WidgetbookPageStateCard(
        label: 'cover photo',
        child: ClubShareCard(club: widgetbookClubClub),
      ),
      WidgetbookPageStateCard(
        label: 'polaroid fallback',
        child: ClubShareCard(club: widgetbookClubMinimalClub),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Share artwork states',
  type: ClubShareArtwork,
  path: '[Club Detail]/Cards',
)
Widget clubShareArtworkStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubShareArtwork',
    catalogId: 'card.club.share.artwork',
    children: [
      WidgetbookPageStateCard(
        label: 'cover photo',
        child: WidgetbookClubClubMediaFrame(
          child: ClubShareArtwork(club: widgetbookClubClub),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'polaroid fallback',
        child: WidgetbookClubClubMediaFrame(
          child: ClubShareArtwork(club: widgetbookClubMinimalClub),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Share meta row states',
  type: CatchMetaRow,
  path: '[Club Detail]/Cards',
)
Widget clubShareMetaRowStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'CatchMetaRow',
    catalogId: 'card.club.share.meta_row',
    children: [
      WidgetbookPageStateCard(
        label: 'location',
        child: CatchMetaRow(
          icon: CatchIcons.locationOnOutlined,
          label: 'Bandra, Mumbai',
        ),
      ),
      WidgetbookPageStateCard(
        label: 'member count',
        child: CatchMetaRow(
          icon: CatchIcons.group,
          label: clubMemberCountLabel(widgetbookClubClub),
        ),
      ),
    ],
  );
}
