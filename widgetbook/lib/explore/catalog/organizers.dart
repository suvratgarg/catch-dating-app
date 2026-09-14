import 'package:catch_dating_app/clubs/shared/catch_club_cover.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_events_section.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';

@widgetbook.UseCase(
  name: 'Organizer poster states',
  type: ExploreOrganizerPosterCard,
  path: '[Explore]/Cards',
)
Widget exploreOrganizerPosterCardStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ExploreOrganizerPosterCard',
    catalogId: 'card.explore.feed.organizer_poster',
    children: [
      WidgetbookPageStateCard(
        label: 'image-backed club',
        child: AbsorbPointer(
          child: ExploreOrganizerPosterCard(club: widgetbookExploreClubs[1]),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'fallback artwork',
        child: AbsorbPointer(
          child: ExploreOrganizerPosterCard(
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
  type: CatchClubCover,
  path: '[Explore]/Cards',
)
Widget exploreClubCoverStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'CatchClubCover',
    catalogId: 'card.explore.feed.club_cover',
    children: [
      WidgetbookPageStateCard(
        label: 'graded image',
        child: SizedBox(
          width: WidgetbookPreviewLayout.compactComponentWidth,
          height: WidgetbookPreviewLayout.compactPreviewExtent,
          child: CatchClubCover(club: widgetbookExploreClubs[0]),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'compact fallback',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.smallPreviewExtent,
          child: CatchClubCover(
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
  type: ExploreClubTags,
  path: '[Explore]/Cards',
)
Widget exploreClubTagsStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ExploreClubTags',
    catalogId: 'card.explore.feed.club_tags',
    children: [
      WidgetbookPageStateCard(
        label: 'visible tags',
        child: ExploreClubTags(
          state: ExploreClubCardState.from(
            widgetbookExploreClubs[0],
            l10n: context.l10n,
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'member fallback',
        child: ExploreClubTags(
          state: ExploreClubCardState.from(
            widgetbookExploreClubs[0].copyWith(tags: []),
            l10n: context.l10n,
          ),
        ),
      ),
    ],
  );
}
