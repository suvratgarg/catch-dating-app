import 'dart:io';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/profile_redesign/catch_profile_view.dart';
import 'package:catch_dating_app/swipes/presentation/profile_redesign/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/golden_pump.dart';

/// Phase 2 flagship Profile — golden-iterated in isolation, rendered in the
/// Catches register (reactable) so the per-section like/comment controls and
/// every section type are part of the visual contract. The hero photo is a
/// committed fixture (FileImage, offline-deterministic) warmed via `precache`.
/// Regenerate: flutter test --update-goldens test/goldens/profile_view_test.dart
final _heroImage = FileImage(File('test/goldens/fixtures/portrait.jpg'));

void main() {
  testWidgets(
    'profile redesign (light + dark)',
    (tester) async {
      await matchCatchGolden(
        tester,
        'profile_redesign',
        size: const Size(440, 1820),
        precache: <ImageProvider<Object>>[_heroImage],
        builder: (context) =>
            CatchProfileView(data: _fixture, onReact: (target, comment) {}),
      );
    },
    tags: const ['golden'],
  );
}

ProfileReactionTarget _target(
  String id,
  SwipeReactionTargetType type,
  String label,
) => ProfileReactionTarget(id: id, type: type, label: label, preview: label);

final _fixture = ProfileView(
  name: 'Aanya',
  age: 27,
  heroPhoto: _heroImage,
  heroReaction: _target(
    'hero',
    SwipeReactionTargetType.heroPhoto,
    'Main photo',
  ),
  kicker: 'Was at · Sundowner 5K',
  kickerActivity: ActivityKind.socialRun,
  metaLine: 'Designer · Bandra',
  sections: <ProfileSection>[
    ProfileCompatibilitySection(
      title: 'Why you might click',
      reasons: const <String>[
        'You both run at dawn around Bandra',
        'Two mutual clubs',
        'Both here for something that starts as a run',
      ],
      confidence: const <String>['Verified photos', 'Active this week'],
      reaction: _target(
        'compatibility',
        SwipeReactionTargetType.compatibility,
        'Why you might click',
      ),
    ),
    ProfilePromptSectionData(
      question: 'A perfect Sunday',
      answer:
          'Long run, longer brunch, and a bookshop I have no business being in.',
      reaction: _target(
        'prompt-1',
        SwipeReactionTargetType.profilePrompt,
        'A perfect Sunday',
      ),
    ),
    ProfileRunningSection(
      pace: '5:20–6:00 /km',
      distance: '5K, 10K',
      reasons: const <String>['Headspace miles'],
      times: const <String>['Dawn'],
      tags: const <String>[
        'Morning regular',
        'Social miles',
        'Long-run person',
      ],
      reaction: _target(
        'running',
        SwipeReactionTargetType.running,
        'Running rhythm',
      ),
    ),
    ProfilePhotoSection(
      image: _heroImage,
      caption: 'Sunday sea-face crew',
      reaction: _target('photo-2', SwipeReactionTargetType.photo, 'Photo 2'),
    ),
    ProfileFactsSection(
      title: 'Looking for',
      facts: <ProfileFact>[
        ProfileFact(
          icon: CatchIcons.favoriteOutlineRounded,
          text: 'Long-term relationship',
        ),
      ],
    ),
    ProfileFactsSection(
      title: 'Details',
      facts: <ProfileFact>[
        ProfileFact(
          icon: CatchIcons.workOutlineRounded,
          text: 'Product designer',
        ),
        ProfileFact(icon: CatchIcons.straightenRounded, text: '168 cm'),
        ProfileFact(icon: CatchIcons.schoolOutlined, text: 'Design school'),
      ],
      reaction: _target('details', SwipeReactionTargetType.details, 'Details'),
    ),
  ],
);
