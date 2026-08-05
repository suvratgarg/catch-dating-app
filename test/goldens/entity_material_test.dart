import 'dart:io';

import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/shared/catch_organizer_poster.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_person_polaroid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

final _portrait = FileImage(File('test/goldens/fixtures/portrait.jpg'));
final _organizer = Club(
  id: 'entity-material-organizer',
  name: 'Afterfly Social',
  description: 'Bombay moves together.',
  location: 'in-mh-mumbai',
  area: 'Bandra',
  createdAt: DateTime(2026),
);

void main() {
  testWidgets('entity materials (light + dark)', (tester) async {
    await matchCatchGolden(
      tester,
      'entity_materials',
      size: const Size(440, 1320),
      precache: <ImageProvider<Object>>[_portrait],
      builder: (context) => SingleChildScrollView(
        padding: CatchInsets.pageBody,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CatchOrganizerPoster(
              media: OrganizerPosterArtwork(club: _organizer),
              kicker: 'Run club · Mumbai',
              title: _organizer.name,
              tagline: _organizer.description,
              meta: 'Every Saturday · 6:30 AM',
              showArrow: false,
            ),
            gapH24,
            CatchPersonPolaroid(
              media: CatchGradedImage(
                child: Image(image: _portrait, fit: BoxFit.cover),
              ),
              kicker: 'Was at · Sundowner 5K',
              name: 'Maya, 29',
              meta: 'Designer · Bandra',
            ),
          ],
        ),
      ),
    );
  }, tags: const ['golden']);
}
