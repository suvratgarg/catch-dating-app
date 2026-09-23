import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_avatar_rail.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_discover_list.dart';
import 'package:catch_dating_app/clubs/presentation/discovery/widgets/club_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'preview.dart';
import 'scope.dart';

final _logoClub = widgetbookClubClub.copyWith(
  profileImageUrl:
      'https://images.unsplash.com/photo-1517841905240-472988babdf9?w=160&q=80',
);

@widgetbook.UseCase(
  name: 'Avatar rail states',
  type: ClubAvatarRail,
  path: '[Club Discovery]/Sections',
)
Widget clubAvatarRailStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubAvatarRail',
    catalogId: 'section.club.avatar_rail',
    children: [
      WidgetbookPageStateCard(
        label: 'joined clubs',
        child: ClubAvatarRail(
          clubs: [widgetbookClubClub, widgetbookClubMinimalClub],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Index row states',
  type: ClubIndexRow,
  path: '[Club Discovery]/Cards',
)
Widget clubIndexRowStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubIndexRow',
    catalogId: 'card.club.index_row',
    children: [
      WidgetbookPageStateCard(
        label: 'photo / joined',
        child: ClubIndexRow(club: widgetbookClubClub, isJoined: true),
      ),
      WidgetbookPageStateCard(
        label: 'fallback / joinable',
        child: WidgetbookClubClubDirectoryPreviewScope(
          child: ClubIndexRow(club: widgetbookClubMinimalClub, isJoined: false),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'logo club',
        child: WidgetbookClubClubDirectoryPreviewScope(
          child: ClubIndexRow(club: _logoClub, isJoined: false),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Avatar chip states',
  type: AvatarChip,
  path: '[Club Discovery]/Atoms',
)
Widget avatarChipStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'AvatarChip',
    catalogId: 'atom.club.avatar_chip',
    children: [
      WidgetbookPageStateCard(
        label: 'default',
        child: AvatarChip(club: _logoClub),
      ),
      WidgetbookPageStateCard(
        label: 'event soon',
        child: AvatarChip(club: widgetbookClubMinimalClub, showLiveBadge: true),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Club image states',
  type: ClubImage,
  path: '[Club Discovery]/Atoms',
)
Widget clubImageStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubImage',
    catalogId: 'atom.club.image',
    children: [
      WidgetbookPageStateCard(
        label: 'cover first',
        child: WidgetbookClubClubMediaFrame(
          child: ClubImage(club: widgetbookClubClub),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'profile first',
        child: WidgetbookClubClubMediaFrame(
          child: ClubImage(club: _logoClub, preferProfileImage: true),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'fallback',
        child: WidgetbookClubClubMediaFrame(
          child: ClubImage(club: widgetbookClubMinimalClub),
        ),
      ),
    ],
  );
}
