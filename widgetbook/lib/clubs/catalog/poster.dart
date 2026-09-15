import 'package:catch_dating_app/clubs/shared/catch_organizer_poster.dart';
import 'package:catch_dating_app/clubs/shared/club_identity_atoms.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';

@widgetbook.UseCase(
  name: 'Poster states',
  type: CatchOrganizerPoster,
  path: '[Club Discovery]/Cards',
)
Widget catchOrganizerPosterStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'CatchOrganizerPoster',
    catalogId: 'card.organizer.poster',
    children: [
      WidgetbookPageStateCard(
        label: 'editorial paper',
        child: CatchOrganizerPoster(
          media: OrganizerPosterArtwork(club: widgetbookClubClub),
          kicker: 'Run club · Mumbai',
          title: widgetbookClubClub.name,
          tagline: widgetbookClubClub.description,
          meta: 'Every Wednesday · 6:45 AM',
          footer: ClubTagWrap(
            tags: visibleClubTags(widgetbookClubClub, limit: 3),
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'photo ink',
        child: CatchOrganizerPoster(
          media: OrganizerPosterArtwork(club: widgetbookClubClub),
          kicker: 'Run club · Mumbai',
          title: widgetbookClubClub.name,
          tagline: widgetbookClubClub.description,
          meta: 'Every Wednesday · 6:45 AM',
          layout: OrganizerPosterLayout.photo,
          treatment: OrganizerPosterTreatment.ink,
        ),
      ),
      WidgetbookPageStateCard(
        label: 'split signal',
        child: CatchOrganizerPoster(
          media: OrganizerPosterArtwork(club: widgetbookClubClub),
          kicker: 'Run club · Mumbai',
          title: widgetbookClubClub.name,
          tagline: widgetbookClubClub.description,
          meta: 'Every Wednesday · 6:45 AM',
          layout: OrganizerPosterLayout.split,
          treatment: OrganizerPosterTreatment.signal,
        ),
      ),
      WidgetbookPageStateCard(
        label: 'minimal paper',
        child: CatchOrganizerPoster(
          media: OrganizerPosterArtwork(club: widgetbookClubClub),
          kicker: 'Run club · Mumbai',
          title: widgetbookClubClub.name,
          tagline: widgetbookClubClub.description,
          meta: 'Every Wednesday · 6:45 AM',
          layout: OrganizerPosterLayout.minimal,
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Poster artwork states',
  type: OrganizerPosterArtwork,
  path: '[Club Discovery]/Cards',
)
Widget organizerPosterArtworkStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'OrganizerPosterArtwork',
    catalogId: 'card.organizer.poster_artwork',
    children: [
      WidgetbookPageStateCard(
        label: 'standard',
        child: AspectRatio(
          aspectRatio: 1,
          child: OrganizerPosterArtwork(club: widgetbookClubClub),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'compact',
        child: SizedBox.square(
          dimension: WidgetbookPreviewLayout.clubAvatarPreviewExtent,
          child: OrganizerPosterArtwork(
            club: widgetbookClubMinimalClub,
            compact: true,
          ),
        ),
      ),
    ],
  );
}
