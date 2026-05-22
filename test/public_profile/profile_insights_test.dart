import 'package:catch_dating_app/public_profile/domain/profile_insights.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart';

void main() {
  group('profileQualitySummary', () {
    test('scores strong public profiles and omits suggestions', () {
      final profile =
          buildPublicProfile(
            photoUrls: const ['1.jpg', '2.jpg', '3.jpg'],
            profilePrompts: [
              for (final promptId in defaultProfilePromptIds)
                profilePromptAnswerFor(
                  definition: profilePromptDefinition(promptId),
                  answer: 'A specific answer for $promptId.',
                ),
            ],
          ).copyWith(
            photoPrompts: const [
              PhotoPromptAnswer(
                photoIndex: 0,
                promptId: 'proofIRun',
                prompt: 'Proof I actually event',
                caption: 'Morning miles.',
              ),
              PhotoPromptAnswer(
                photoIndex: 1,
                promptId: 'finishLine',
                prompt: 'After the finish line',
                caption: 'Coffee stop.',
              ),
            ],
            relationshipGoal: RelationshipGoal.relationship,
            preferredDistances: const [PreferredDistance.fiveK],
            runningReasons: const [RunReason.community],
            preferredRunTimes: const [PreferredRunTime.morning],
            occupation: 'Designer',
            workout: WorkoutFrequency.often,
          );

      final summary = profileQualitySummary(profile);

      expect(summary.score, 100);
      expect(summary.isStrong, isTrue);
      expect(summary.suggestions, isEmpty);
    });

    test('returns the highest impact missing suggestions first', () {
      final summary = profileQualitySummary(buildPublicProfile());

      expect(summary.score, lessThan(85));
      expect(summary.suggestions.map((suggestion) => suggestion.title), [
        'Add 3 clear photos',
        'Answer all 3 prompts',
        'Add photo prompts',
      ]);
    });
  });

  group('emotionalRunTagsForProfile', () {
    test('turns running preferences into emotional tags', () {
      final profile = buildPublicProfile().copyWith(
        preferredDistances: const [PreferredDistance.halfMarathon],
        runningReasons: const [RunReason.mindfulness, RunReason.social],
        paceMinSecsPerKm: 390,
        paceMaxSecsPerKm: 480,
      );

      final tags = emotionalRunTagsForProfile(profile);

      expect(tags.map((tag) => tag.label), [
        'Events for headspace',
        'Social miles',
        'Long-event person',
        'Easy miles',
      ]);
      expect(tags.first.source, EmotionalRunTagSource.selected);
    });

    test('turns preferred event times into emotional tags', () {
      final profile = buildPublicProfile().copyWith(
        preferredRunTimes: const [
          PreferredRunTime.earlyMorning,
          PreferredRunTime.evening,
        ],
      );

      final tags = emotionalRunTagsForProfile(profile);

      expect(tags.map((tag) => tag.label), [
        'Morning regular',
        'Evening runner',
      ]);
    });
  });

  group('compatibilityReasonsForProfile', () {
    test('ranks shared event and concrete overlaps', () {
      final viewer = buildUser().copyWith(
        relationshipGoal: RelationshipGoal.relationship,
        preferredDistances: const [PreferredDistance.fiveK],
        runningReasons: const [RunReason.community],
        preferredRunTimes: const [PreferredRunTime.morning],
        languages: const [Language.english, Language.hindi],
      );
      final target = buildPublicProfile().copyWith(
        relationshipGoal: RelationshipGoal.relationship,
        preferredDistances: const [PreferredDistance.fiveK],
        runningReasons: const [RunReason.community],
        preferredRunTimes: const [PreferredRunTime.earlyMorning],
        languages: const [Language.english],
      );

      final reasons = compatibilityReasonsForProfile(
        targetProfile: target,
        viewerProfile: viewer,
        sharedRunTitle: 'Thursday Morning Event',
      );

      expect(reasons.map((reason) => reason.label), [
        'You met at Thursday Morning Event',
        'You are both looking for long-term relationship',
        'You both event for community',
      ]);
    });

    test(
      'uses shared time-of-day preferences when higher signals are absent',
      () {
        final viewer = buildUser().copyWith(
          preferredRunTimes: const [
            PreferredRunTime.morning,
            PreferredRunTime.evening,
          ],
        );
        final target = buildPublicProfile().copyWith(
          preferredRunTimes: const [
            PreferredRunTime.earlyMorning,
            PreferredRunTime.night,
          ],
        );

        final reasons = compatibilityReasonsForProfile(
          targetProfile: target,
          viewerProfile: viewer,
        );

        expect(reasons.first.label, 'You both like morning and evening events');
        expect(reasons.first.kind, CompatibilityReasonKind.runTime);
      },
    );
  });
}
