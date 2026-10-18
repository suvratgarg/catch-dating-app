import 'package:catch_dating_app/clubs/shared/club_cover.dart';
import 'package:catch_dating_app/explore/presentation/explore_club_display_state.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_events_section.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';

@widgetbook.UseCase(
  name: 'Organizer poster states',
  type: ClubCard,
  path: '[Explore]/Cards',
)
Widget exploreOrganizerPosterCardStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubCard',
    catalogId: 'card.explore.feed.club_card',
    children: [
      WidgetbookPageStateCard(
        label: 'image-backed club',
        child: AbsorbPointer(child: ClubCard(club: widgetbookExploreClubs[1])),
      ),
      WidgetbookPageStateCard(
        label: 'fallback artwork',
        child: AbsorbPointer(
          child: ClubCard(
            club: widgetbookExploreClubs[2].copyWith(imageUrl: null),
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Club row states',
  type: ExploreFeedClubRow,
  path: '[Explore]/Rows',
)
Widget exploreFeedClubRowStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ExploreFeedClubRow',
    catalogId: 'row.explore.feed.club',
    children: [
      WidgetbookPageStateCard(
        label: 'compact club',
        child: AbsorbPointer(
          child: ExploreFeedClubRow(club: widgetbookExploreClubs[0]),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'host unknown',
        child: AbsorbPointer(
          child: ExploreFeedClubRow(club: widgetbookExploreClubs[2]),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Club cover states',
  type: ClubCover,
  path: '[Explore]/Cards',
)
Widget exploreClubCoverStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubCover',
    catalogId: 'card.explore.feed.club_cover',
    children: [
      WidgetbookPageStateCard(
        label: 'graded image',
        child: SizedBox(
          width: WidgetbookPreviewLayout.compactComponentWidth,
          height: WidgetbookPreviewLayout.compactPreviewExtent,
          child: ClubCover(club: widgetbookExploreClubs[0]),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'compact fallback',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.smallPreviewExtent,
          child: ClubCover(
            club: widgetbookExploreClubs[2].copyWith(imageUrl: null),
            compact: true,
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Club tags states',
  type: ExploreClubTagList,
  path: '[Explore]/Cards',
)
Widget exploreClubTagsStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ExploreClubTagList',
    catalogId: 'card.explore.feed.club_tags',
    children: [
      WidgetbookPageStateCard(
        label: 'visible tags',
        child: ExploreClubTagList(
          state: ExploreClubCardState.from(
            widgetbookExploreClubs[0],
            l10n: context.l10n,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'member fallback',
        child: ExploreClubTagList(
          state: ExploreClubCardState.from(
            widgetbookExploreClubs[0].copyWith(tags: []),
            l10n: context.l10n,
          ),
        ),
      ),
    ],
  );
}
