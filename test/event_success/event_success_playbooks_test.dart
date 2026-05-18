import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_coach.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('EventSuccessPlaybookLibrary', () {
    test('marks the event success layer as live-wired and iterating', () {
      expect(
        eventSuccessLayerDevelopmentStatus,
        'live_wired_with_preview_lab_and_iterating',
      );
    });

    test('includes playbooks beyond clubs', () {
      final activities = EventSuccessPlaybookLibrary.all
          .map((playbook) => playbook.activityType)
          .toSet();

      expect(activities, contains(ActivityKind.socialRun));
      expect(activities, contains(ActivityKind.pickleball));
      expect(activities, contains(ActivityKind.pubQuiz));
      expect(activities, contains(ActivityKind.singlesMixer));
    });

    test(
      'social event playbook keeps live phone use away from the actual event',
      () {
        final event = EventSuccessPlaybookLibrary.socialRun;
        final activitySteps = event.runOfShow.where(
          (step) => step.stage == EventSuccessStage.activity,
        );

        expect(activitySteps, isNotEmpty);
        expect(
          activitySteps.expand((step) => step.moduleIds),
          isNot(contains(EventSuccessModuleCatalog.checkIn.id)),
        );
        expect(
          event.moduleIds,
          contains(EventSuccessModuleCatalog.privateCrush.id),
        );
        expect(
          event.moduleIds,
          contains(EventSuccessModuleCatalog.safetyControls.id),
        );
      },
    );

    test('all run-of-show module ids refer to modules in their playbook', () {
      for (final playbook in EventSuccessPlaybookLibrary.all) {
        for (final step in playbook.runOfShow) {
          expect(
            playbook.moduleIds,
            containsAll(step.moduleIds),
            reason:
                '${playbook.id} references missing modules in ${step.title}',
          );
        }
      }
    });

    test('module lookup throws for unknown module ids', () {
      expect(
        EventSuccessModuleCatalog.byId(
          EventSuccessModuleCatalog.privateCrush.id,
        ),
        EventSuccessModuleCatalog.privateCrush,
      );
      expect(
        () => EventSuccessModuleCatalog.byId('not_a_module'),
        throwsArgumentError,
      );
    });
  });

  group('EventSuccessCoach', () {
    const coach = EventSuccessCoach();

    test('prioritizes safety before growth recommendations', () {
      final brief = coach.analyze(
        playbook: EventSuccessPlaybookLibrary.socialRun,
        scorecard: EventSuccessSampleScorecards.safetyReviewRequired,
      );

      expect(brief.recommendations.first.id, 'safety_first');
      expect(
        brief.recommendations.first.priority,
        EventRecommendationPriority.critical,
      );
    });

    test('detects weak arrival and weak mixing loops', () {
      final brief = coach.analyze(
        playbook: EventSuccessPlaybookLibrary.socialRun,
        scorecard: EventSuccessSampleScorecards.needsStructure,
      );

      expect(
        brief.recommendations.map((recommendation) => recommendation.id),
        containsAll([
          'tighten_check_in',
          'increase_intro_coverage',
          'lower_follow_up_friction',
          'improve_first_message',
          'improve_host_welcome',
          'right_size_structure',
        ]),
      );
    });

    test('recognizes strong loops as strengths', () {
      final brief = coach.analyze(
        playbook: EventSuccessPlaybookLibrary.socialRun,
        scorecard: EventSuccessSampleScorecards.strongSocialRun,
      );

      expect(
        brief.strengths,
        contains('Arrival data is reliable enough to power post-event loops.'),
      );
      expect(brief.strengths, contains('Most attendees met multiple people.'));
      expect(
        brief.strengths,
        contains('Mutual matches are converting into chat starts.'),
      );
    });
  });
}
