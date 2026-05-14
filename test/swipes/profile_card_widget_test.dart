import 'package:catch_dating_app/core/theme/app_theme.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/name_overlay.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../runs/runs_test_helpers.dart';

Widget _profileCardHarness({required ThemeData theme}) {
  final profile = buildPublicProfile(
    name: 'Manan',
    age: 26,
  ).copyWith(city: 'indore', relationshipGoal: RelationshipGoal.casual);

  return ProviderScope(
    child: MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 340,
            height: 620,
            child: ProfileCard(profile: profile),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('NameOverlay shows display name, age, city, and signal chips', (
    tester,
  ) async {
    final profile = buildPublicProfile(
      name: 'Manan',
      age: 26,
    ).copyWith(city: 'indore', relationshipGoal: RelationshipGoal.casual);

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: Scaffold(body: NameOverlay(profile: profile)),
      ),
    );

    expect(find.text('Manan'), findsOneWidget);
    expect(find.text('26'), findsOneWidget);
    expect(find.text('Indore'), findsOneWidget);
    expect(find.text('Something casual'), findsOneWidget);
    expect(find.text('5:00-7:00/km'), findsOneWidget);
  });

  testWidgets(
    'ProfileCard renders polished missing-photo state in light mode',
    (tester) async {
      final semantics = tester.ensureSemantics();

      await tester.pumpWidget(_profileCardHarness(theme: AppTheme.light));
      await tester.pump();

      expect(find.text('Photo coming soon'), findsOneWidget);
      expect(find.text('A PERFECT RUN WITH ME LOOKS LIKE...'), findsOneWidget);
      expect(find.text('Something casual'), findsOneWidget);
      expect(find.text('5:00-7:00/km'), findsWidgets);
      expect(find.text('RUNNING RHYTHM'), findsOneWidget);
      expect(
        tester.getSemantics(find.byType(ProfileCard)).hint,
        'Swipe left to pass, right to like. Scroll to read the full profile.',
      );
      semantics.dispose();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ProfileCard renders the same content in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(_profileCardHarness(theme: AppTheme.dark));
    await tester.pump();

    expect(find.text('Photo coming soon'), findsOneWidget);
    expect(find.text('Manan'), findsOneWidget);
    expect(find.text('RUNNING RHYTHM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileCard omits prompt cards when prompts are blank', (
    tester,
  ) async {
    final profile = buildPublicProfile(name: 'Manan', age: 26).copyWith(
      profilePrompts: const [],
      city: 'indore',
      relationshipGoal: RelationshipGoal.casual,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 340,
              height: 620,
              child: ProfileCard(profile: profile),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('A PERFECT RUN WITH ME LOOKS LIKE...'), findsNothing);
    expect(find.text('RUNNING RHYTHM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('ProfileCard handles long public profile text without overflow', (
    tester,
  ) async {
    final profile =
        buildPublicProfile(
          name: 'A very long display name that should not break the hero',
          age: 26,
          profilePrompts: normalizeProfilePromptAnswers(
            const [],
            legacyBio:
                'Long easy runs, coffee after the finish, and a playlist that keeps the whole group moving without making the card feel cramped.',
          ),
        ).copyWith(
          city: 'indore',
          height: 180,
          occupation: 'Senior product designer with an unusually long title',
          company: 'A company with an unusually long name',
        );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 340,
              height: 620,
              child: ProfileCard(profile: profile),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('A PERFECT RUN WITH ME LOOKS LIKE...'), findsOneWidget);
    expect(find.text('DETAILS'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'ProfileCard renders compatibility reasons and run identity tags',
    (tester) async {
      final viewer = buildUser().copyWith(
        relationshipGoal: RelationshipGoal.relationship,
        preferredDistances: const [PreferredDistance.fiveK],
        runningReasons: const [RunReason.community],
      );
      final profile = buildPublicProfile(name: 'Manan', age: 26).copyWith(
        relationshipGoal: RelationshipGoal.relationship,
        preferredDistances: const [PreferredDistance.fiveK],
        runningReasons: const [RunReason.community],
      );

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            theme: AppTheme.light,
            home: Scaffold(
              body: SizedBox(
                width: 340,
                height: 740,
                child: ProfileCard(
                  profile: profile,
                  viewerProfile: viewer,
                  sharedRunTitle: 'Thursday Morning Run',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('WHY YOU MIGHT CLICK'), findsOneWidget);
      expect(find.text('You met at Thursday Morning Run'), findsOneWidget);
      expect(find.text('Social miles'), findsOneWidget);
      expect(find.text('5K regular'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('ProfileCard surfaces section reaction controls when enabled', (
    tester,
  ) async {
    ProfileReactionTarget? reactedTarget;
    String? reactedComment;
    final profile = buildPublicProfile(
      name: 'Manan',
      age: 26,
    ).copyWith(city: 'indore');

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 340,
              height: 620,
              child: ProfileCard(
                profile: profile,
                onReact: (target, comment) {
                  reactedTarget = target;
                  reactedComment = comment;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(
      find.byTooltip('Like A perfect run with me looks like...'),
    );
    await tester.tap(
      find.byTooltip('Like A perfect run with me looks like...'),
    );
    await tester.pump();

    expect(reactedTarget?.id, 'profile-prompt-perfectRun');
    expect(reactedTarget?.type, SwipeReactionTargetType.profilePrompt);
    expect(reactedComment, isNull);
  });

  testWidgets('ProfileCard lets users react to compatibility signals', (
    tester,
  ) async {
    ProfileReactionTarget? reactedTarget;
    final viewer = buildUser().copyWith(
      preferredDistances: const [PreferredDistance.fiveK],
      runningReasons: const [RunReason.community],
    );
    final profile = buildPublicProfile(name: 'Manan', age: 26).copyWith(
      preferredDistances: const [PreferredDistance.fiveK],
      runningReasons: const [RunReason.community],
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 340,
              height: 740,
              child: ProfileCard(
                profile: profile,
                viewerProfile: viewer,
                onReact: (target, _) {
                  reactedTarget = target;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(find.byTooltip('Like Why you might click'));
    await tester.tap(find.byTooltip('Like Why you might click'));
    await tester.pump();

    expect(reactedTarget?.id, 'compatibility');
    expect(reactedTarget?.type, SwipeReactionTargetType.compatibility);
  });

  testWidgets('ProfileCard comment sheet sends a block-specific comment', (
    tester,
  ) async {
    ProfileReactionTarget? reactedTarget;
    String? reactedComment;
    final profile = buildPublicProfile(name: 'Manan', age: 26);

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: SizedBox(
              width: 340,
              height: 620,
              child: ProfileCard(
                profile: profile,
                onReact: (target, comment) {
                  reactedTarget = target;
                  reactedComment = comment;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.ensureVisible(
      find.byTooltip('Comment on A perfect run with me looks like...'),
    );
    await tester.tap(
      find.byTooltip('Comment on A perfect run with me looks like...'),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'This is a great hook.');
    await tester.pump();
    await tester.tap(find.text('Send like'));
    await tester.pumpAndSettle();

    expect(reactedTarget?.id, 'profile-prompt-perfectRun');
    expect(reactedComment, 'This is a great hook.');
  });
}
