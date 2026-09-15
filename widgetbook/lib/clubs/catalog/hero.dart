import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_photo_strip.dart';
import 'package:catch_tokens/catch_tokens.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import '../../preview_layout_contracts.dart';
import '../../support/page_preview.dart';
import 'fixtures.dart';
import 'preview.dart';

final _logoOnlyHeroClub = widgetbookClubMinimalClub.copyWith(
  id: 'widgetbook-logo-only-club',
  name: 'Bandra Dawn Club',
  logoPhoto: widgetbookClubPhoto('club-logo-dawn', 0),
);

@widgetbook.UseCase(
  name: 'Photo strip states',
  type: ClubPhotoStrip,
  path: '[Club Detail]/Sections',
)
Widget clubPhotoStripStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubPhotoStrip',
    catalogId: 'section.club.photos',
    children: [
      WidgetbookPageStateCard(
        label: 'three photos',
        child: ClubPhotoStrip(club: widgetbookClubClub),
      ),
      WidgetbookPageStateCard(
        label: 'single photo',
        child: ClubPhotoStrip(
          club: widgetbookClubClub.copyWith(
            clubPhotos: [widgetbookClubClub.clubPhotos.first],
          ),
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hero states',
  type: ClubHeroAppBar,
  path: '[Club Detail]/Sections',
)
Widget clubHeroAppBarStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubHeroAppBar',
    catalogId: 'section.club.hero',
    children: [
      WidgetbookPageStateCard(
        label: 'photo polaroid',
        child: WidgetbookClubSliverFrame(
          height: WidgetbookPreviewLayout.profileExpandedEditorHeight,
          slivers: [
            ClubHeroAppBar(
              club: widgetbookClubClub,
              isHost: false,
              onShareClub: _ignoreShare,
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: WidgetbookPreviewLayout.mediaPanelHeight),
            ),
          ],
        ),
      ),
      WidgetbookPageStateCard(
        label: 'logo masthead',
        child: WidgetbookClubSliverFrame(
          height: WidgetbookPreviewLayout.clubExpandedPreviewHeight,
          slivers: [
            ClubHeroAppBar(
              club: _logoOnlyHeroClub,
              isHost: false,
              onShareClub: _ignoreShare,
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: WidgetbookPreviewLayout.mediaPanelHeight),
            ),
          ],
        ),
      ),
      WidgetbookPageStateCard(
        label: 'art polaroid',
        child: WidgetbookClubSliverFrame(
          height: WidgetbookPreviewLayout.profileExpandedEditorHeight,
          slivers: [
            ClubHeroAppBar(
              club: widgetbookClubMinimalClub,
              isHost: false,
              onShareClub: _ignoreShare,
            ),
            const SliverToBoxAdapter(
              child: SizedBox(height: WidgetbookPreviewLayout.mediaPanelHeight),
            ),
          ],
        ),
      ),
    ],
  );
}

@widgetbook.UseCase(
  name: 'Hero module states',
  type: ClubHeroModule,
  path: '[Club Detail]/Sections',
)
Widget clubHeroModuleStates(BuildContext context) {
  return WidgetbookScrollCatalogFrame(
    title: 'ClubHeroModule',
    catalogId: 'section.club.hero.module',
    children: [
      WidgetbookPageStateCard(
        label: 'photo polaroid module',
        child: WidgetbookClubDeviceFrame(
          height: WidgetbookPreviewLayout.tallRouteViewportHeight,
          child: ClubHeroModule(
            club: widgetbookClubClub,
            variant: ClubHeroVariant.poster,
            mediaHeight: 280,
            captionExtent: CatchLayout.clubDetailHeroCaptionExtent,
            kickerLabel: 'BANDRA · MUMBAI',
            locationLabel: 'Bandstand promenade',
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'logo masthead module',
        child: WidgetbookClubDeviceFrame(
          height: WidgetbookPreviewLayout.feedbackViewportHeight,
          child: ClubHeroModule(
            club: _logoOnlyHeroClub,
            variant: ClubHeroVariant.masthead,
            mediaHeight: 220,
            captionExtent: CatchLayout.clubDetailHeroCaptionExtent,
            kickerLabel: 'DINNER · MUMBAI',
            locationLabel: 'Khar Social',
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'art polaroid module',
        child: WidgetbookClubDeviceFrame(
          height: WidgetbookPreviewLayout.feedbackViewportHeight,
          child: ClubHeroModule(
            club: widgetbookClubMinimalClub,
            variant: ClubHeroVariant.poster,
            mediaHeight: 220,
            captionExtent: CatchLayout.clubDetailHeroCaptionExtent,
            kickerLabel: 'DINNER · MUMBAI',
            locationLabel: 'Khar Social',
          ),
        ),
      ),
      WidgetbookPageStateCard(
        label: 'full review module',
        child: WidgetbookClubDeviceFrame(
          height: WidgetbookPreviewLayout.tallRouteViewportHeight,
          child: ClubHeroModule(
            club: widgetbookClubClub,
            variant: ClubHeroVariant.full,
            mediaHeight: 280,
            captionExtent: CatchLayout.clubDetailHeroCaptionExtent,
            kickerLabel: 'BANDRA · MUMBAI',
            locationLabel: 'Bandstand promenade',
          ),
        ),
      ),
    ],
  );
}

Future<void> _ignoreShare(BuildContext context, Club club) async {}
