import 'dart:io';

import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/profile_redesign/catch_profile_view.dart';
import 'package:catch_dating_app/swipes/presentation/profile_redesign/profile_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../ui_captures/fixtures/sales_demo_synthetic_fixtures.dart';
import 'support/golden_pump.dart';

/// Phase 2 flagship Profile — golden-iterated in isolation, rendered in the
/// Catches register (reactable) so the per-section like/comment controls and
/// every section type are part of the visual contract. The hero photo is a
/// committed fixture (FileImage, offline-deterministic) warmed via `precache`.
/// Profile identity/copy comes from the checked sales demo persona projection so
/// captures, seed data, and this flagship golden share the same persona source.
/// Regenerate: flutter test --update-goldens test/goldens/profile_view_test.dart
final _heroImage = FileImage(File('test/goldens/fixtures/portrait.jpg'));
final _persona = salesDemoSyntheticFixtures.publicProfile('nyc_maya_shah_001');

void main() {
  testWidgets('profile redesign (light + dark)', (tester) async {
    await matchCatchGolden(
      tester,
      'profile_redesign',
      size: const Size(440, 1820),
      precache: <ImageProvider<Object>>[_heroImage],
      builder: (context) => CatchProfileView(
        data: _profileViewFromPersona(_persona),
        onReact: (target, comment) {},
      ),
    );
  }, tags: const ['golden']);
}

ProfileReactionTarget _target(
  String id,
  SwipeReactionTargetType type,
  String label,
) => ProfileReactionTarget(id: id, type: type, label: label, preview: label);

ProfileView _profileViewFromPersona(PublicProfile profile) {
  final photoCaption = profile.effectiveProfilePhotos
      .skip(1)
      .firstOrNull
      ?.prompt
      ?.displayPrompt;
  return ProfileView(
    name: profile.name,
    age: profile.age,
    heroPhoto: _heroImage,
    heroReaction: _target(
      'hero',
      SwipeReactionTargetType.heroPhoto,
      'Main photo',
    ),
    kicker: 'Was at · sales demo roster',
    kickerActivity: ActivityKind.socialRun,
    metaLine: [
      profile.occupation,
      profile.company,
      profile.city,
    ].nonNulls.join(' · '),
    sections: <ProfileSection>[
      ProfileCompatibilitySection(
        title: 'Why you might click',
        reasons: const <String>[
          'Shared event context from the sales demo roster',
          'Structured prompts and approved profile photos',
          'Projection-backed profile details',
        ],
        confidence: const <String>['Verified photos', 'Active this week'],
        reaction: _target(
          'compatibility',
          SwipeReactionTargetType.compatibility,
          'Why you might click',
        ),
      ),
      for (final prompt in profile.profilePrompts.take(2))
        ProfilePromptSectionData(
          question: prompt.displayPrompt,
          answer: prompt.answer,
          reaction: _target(
            'prompt-${prompt.promptId}',
            SwipeReactionTargetType.profilePrompt,
            prompt.displayPrompt,
          ),
        ),
      ProfileRunningSection(
        pace: '5:20-6:00 /km',
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
        caption: photoCaption,
        reaction: _target('photo-2', SwipeReactionTargetType.photo, 'Photo 2'),
      ),
      ProfileFactsSection(
        title: 'Details',
        facts: <ProfileFact>[
          if (profile.occupation case final occupation?)
            ProfileFact(icon: CatchIcons.workOutlineRounded, text: occupation),
          if (profile.height case final height?)
            ProfileFact(icon: CatchIcons.straightenRounded, text: '$height cm'),
          if (profile.company case final company?)
            ProfileFact(icon: CatchIcons.businessOutlined, text: company),
        ],
        reaction: _target(
          'details',
          SwipeReactionTargetType.details,
          'Details',
        ),
      ),
    ],
  );
}
