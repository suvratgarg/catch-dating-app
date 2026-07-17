import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/presentation/detail/widgets/club_hero_app_bar.dart';
import 'package:catch_dating_app/clubs/shared/catch_polaroid.dart';
import 'package:catch_dating_app/core/media/uploaded_photo.dart';
import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_person_avatar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'clubs_test_helpers.dart';

void main() {
  group('ClubHeroAppBar', () {
    test('resolves default hero variants from club media state', () {
      final clubPhoto = _photo('cover', 0);
      final logoPhoto = _photo('logo', 0);

      expect(
        clubHeroVariantFor(buildClub(clubPhotos: [clubPhoto])),
        ClubHeroVariant.polaroid,
      );
      expect(
        clubHeroVariantFor(buildClub(imageUrl: 'https://example.com/old.jpg')),
        ClubHeroVariant.polaroid,
      );
      expect(
        clubHeroVariantFor(buildClub(logoPhoto: logoPhoto)),
        ClubHeroVariant.masthead,
      );
      expect(clubHeroVariantFor(buildClub()), ClubHeroVariant.polaroid);
    });

    testWidgets('photo clubs render the polaroid hero shell', (tester) async {
      final club = buildClub(clubPhotos: [_photo('cover', 0)]);

      await _pumpHeroModule(tester, club, clubHeroVariantFor(club));

      expect(find.byType(CatchPolaroid), findsOneWidget);
      expect(find.byType(ClubPolaroidArtwork), findsNothing);
      expect(
        find.byKey(const ValueKey('club-detail-hero-polaroid-frame')),
        findsOneWidget,
      );
      expect(find.text('Stride Social'), findsOneWidget);
      expect(find.text('Bandra, Mumbai'), findsOneWidget);
    });

    testWidgets('clubs without photos render artwork in the polaroid shell', (
      tester,
    ) async {
      final club = buildClub();

      await _pumpHeroModule(tester, club, clubHeroVariantFor(club));

      expect(find.byType(CatchPolaroid), findsOneWidget);
      expect(find.byType(ClubPolaroidArtwork), findsOneWidget);
      expect(
        find.byKey(const ValueKey('club-detail-hero-polaroid-frame')),
        findsOneWidget,
      );
    });

    testWidgets('logo-only clubs render the masthead hero shell', (
      tester,
    ) async {
      final club = buildClub(logoPhoto: _photo('logo', 0));

      await _pumpHeroModule(tester, club, clubHeroVariantFor(club));

      expect(
        find.byKey(const ValueKey('club-detail-hero-masthead')),
        findsOneWidget,
      );
      expect(
        find.byKey(const ValueKey('club-detail-hero-logo-seal')),
        findsOneWidget,
      );
      expect(find.byType(CatchPersonAvatar), findsOneWidget);
      expect(find.byType(CatchPolaroid), findsNothing);
      expect(find.byType(ClubPolaroidArtwork), findsNothing);
      expect(find.text('Stride Social'), findsOneWidget);
    });

    testWidgets('embedded preview renders the hero without route chrome', (
      tester,
    ) async {
      final club = buildClub();

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: CustomScrollView(
              slivers: [
                ClubHeroAppBar(
                  club: club,
                  isHost: false,
                  presentationMode:
                      ClubHeroPresentationMode.embeddedReadOnlyPreview,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pump();

      expect(
        find.byKey(const ValueKey('club-detail-hero-module')),
        findsOneWidget,
      );
      expect(find.byType(SliverAppBar), findsNothing);
      expect(find.byTooltip('Back'), findsNothing);
      expect(find.byTooltip('Share club'), findsNothing);
    });
  });
}

Future<void> _pumpHeroModule(
  WidgetTester tester,
  Club club,
  ClubHeroVariant variant,
) async {
  const mediaHeight = CatchLayout.clubDetailHeroNoCoverPhoneHeight;
  const captionExtent = CatchLayout.clubDetailHeroCaptionExtent;
  const moduleHeight =
      mediaHeight + captionExtent + (CatchLayout.clubInteractionMediaInset * 2);

  await tester.pumpWidget(
    MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 390,
            height: moduleHeight,
            child: ClubHeroModule(
              club: club,
              variant: variant,
              mediaHeight: mediaHeight,
              captionExtent: captionExtent,
              kickerLabel: 'BANDRA · MUMBAI',
              locationLabel: 'Bandra, Mumbai',
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

UploadedPhoto _photo(String id, int position) {
  return UploadedPhoto.fromUpload(
    url: 'https://example.com/$id.jpg',
    storagePath: 'test/clubs/$id.jpg',
    position: position,
    now: DateTime(2026, 7, 6, 9),
  );
}
