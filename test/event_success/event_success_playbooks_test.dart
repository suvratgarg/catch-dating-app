import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_activity_profile.dart';
import 'package:catch_dating_app/event_success/domain/event_success_coach.dart';
import 'package:catch_dating_app/event_success/domain/event_success_defaults.dart';
import 'package:catch_dating_app/event_success/domain/event_success_feature_state.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_plan.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';
import 'package:flutter_test/flutter_test.dart';

import '../events/events_test_helpers.dart' show buildEvent;

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
          contains(EventSuccessModuleCatalog.wingmanRequests.id),
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

    test('compatibility questionnaire is a reusable opt-in module', () {
      for (final playbook in EventSuccessPlaybookLibrary.all) {
        expect(
          playbook.moduleIds,
          contains(EventSuccessModuleCatalog.compatibilityQuestionnaire.id),
          reason: '${playbook.id} should expose compatibility as a module',
        );
        final draft = EventSuccessHostDraft.fromPlaybook(playbook);
        if (playbook.activityType == ActivityKind.singlesMixer) {
          expect(
            draft.selectedModuleIds,
            contains(EventSuccessModuleCatalog.compatibilityQuestionnaire.id),
            reason:
                '${playbook.id} is the dating-forward format where questionnaire is part of the recommended setup',
          );
        } else {
          expect(
            draft.selectedModuleIds,
            isNot(
              contains(EventSuccessModuleCatalog.compatibilityQuestionnaire.id),
            ),
            reason:
                '${playbook.id} should not treat compatibility as the event type',
          );
        }
      }

      final runDraft = EventSuccessHostDraft.fromPlaybook(
        EventSuccessPlaybookLibrary.socialRun,
      ).toggleModule(EventSuccessModuleCatalog.compatibilityQuestionnaire.id);

      expect(
        runDraft.selectedModuleIds,
        contains(EventSuccessModuleCatalog.compatibilityQuestionnaire.id),
      );
      expect(runDraft.questionnaireConfig.pack.title, 'Balanced');
    });

    test('First Hello is an optional arrival module across playbooks', () {
      for (final playbook in EventSuccessPlaybookLibrary.all) {
        expect(
          playbook.moduleIds,
          contains(EventSuccessModuleCatalog.firstHelloCheckIn.id),
          reason: '${playbook.id} should expose First Hello as a module',
        );
      }

      final socialRunDraft = EventSuccessHostDraft.fromPlaybook(
        EventSuccessPlaybookLibrary.socialRun,
      );
      final mixerProfile = EventSuccessActivityProfile.forActivity(
        ActivityKind.singlesMixer,
      );

      expect(
        EventSuccessModuleCatalog.firstHelloCheckIn.productLayer,
        EventSuccessProductLayer.rosterAttendance,
      );
      expect(
        socialRunDraft.selectedModuleIds,
        isNot(contains(EventSuccessModuleCatalog.firstHelloCheckIn.id)),
      );
      expect(
        mixerProfile.isSelectable(
          EventSuccessModuleCatalog.firstHelloCheckIn.id,
        ),
        isTrue,
      );
      expect(
        mixerProfile.defaultModuleIds,
        isNot(contains(EventSuccessModuleCatalog.firstHelloCheckIn.id)),
      );
      expect(
        mixerProfile
            .recommendationFor(EventSuccessModuleCatalog.firstHelloCheckIn.id)
            ?.reason,
        contains('location-verified first hello'),
      );
    });

    test('module lookup throws for unknown module ids', () {
      expect(
        EventSuccessModuleCatalog.byId(
          EventSuccessModuleCatalog.wingmanRequests.id,
        ),
        EventSuccessModuleCatalog.wingmanRequests,
      );
      expect(
        () => EventSuccessModuleCatalog.byId('not_a_module'),
        throwsArgumentError,
      );
    });

    test('groups legacy modules into the simplified product layers', () {
      final socialRun = EventSuccessPlaybookLibrary.socialRun;
      final layers = socialRun.modulesByProductLayer;

      expect(
        layers[EventSuccessProductLayer.rosterAttendance],
        containsAll([
          EventSuccessModuleCatalog.crowdBalance,
          EventSuccessModuleCatalog.checkIn,
        ]),
      );
      expect(
        layers[EventSuccessProductLayer.assignments],
        contains(EventSuccessModuleCatalog.microPods),
      );
      expect(
        EventSuccessModuleCatalog.socialMissions.productLayer,
        EventSuccessProductLayer.conversation,
      );
      expect(
        EventSuccessModuleCatalog.contextualOpeners.productLayer,
        EventSuccessProductLayer.conversation,
      );
      expect(
        EventSuccessModuleCatalog.liveReveal.productLayer,
        EventSuccessProductLayer.liveReveal,
      );
      expect(
        EventSuccessPlaybookLibrary.algorithmicMixer.moduleIds,
        contains(EventSuccessModuleCatalog.liveReveal.id),
      );
      expect(
        EventSuccessModuleCatalog.safetyControls.productLayer,
        EventSuccessProductLayer.safety,
      );
    });

    test('sets structure defaults from the activity interaction model', () {
      final runDraft = EventSuccessHostDraft.fromPlaybook(
        EventSuccessPlaybookLibrary.socialRun,
        targetAttendeeCount: 30,
      );
      final quizDraft = EventSuccessHostDraft.fromPlaybook(
        EventSuccessPlaybookLibrary.pubQuiz,
      );
      final pickleballDraft = EventSuccessHostDraft.fromPlaybook(
        EventSuccessPlaybookLibrary.pickleball,
      );

      expect(
        runDraft.structureConfig.unitKind,
        EventSuccessUnitKind.wholeGroup,
      );
      expect(runDraft.structureConfig.unitSize, 30);
      expect(quizDraft.structureConfig.unitKind, EventSuccessUnitKind.teams);
      expect(quizDraft.structureConfig.unitCount, isNull);
      expect(quizDraft.structureConfig.estimatedUnitCount(50), 10);
      expect(pickleballDraft.structureConfig.rotationIntervalMinutes, 15);
    });

    test(
      'normalizes old fixed quiz team default to capacity-aware auto count',
      () {
        final defaults = const EventSuccessDefaults(
          enabled: true,
          playbookId: 'pub_quiz_team_mixer',
          structureConfig: EventSuccessStructureConfig(
            unitKind: EventSuccessUnitKind.teams,
            unitSize: 5,
            unitCount: 3,
          ),
        ).normalizedForActivity(ActivityKind.pubQuiz, targetAttendeeCount: 50);

        final draft = defaults.toDraft(targetAttendeeCount: 50);

        expect(draft.structureConfig.unitKind, EventSuccessUnitKind.teams);
        expect(draft.structureConfig.unitSize, 5);
        expect(draft.structureConfig.unitCount, isNull);
        expect(draft.structureConfig.estimatedUnitCount(50), 10);
      },
    );

    test('estimates group count and size ranges from actual attendance', () {
      const autoTeams = EventSuccessStructureConfig(
        unitKind: EventSuccessUnitKind.teams,
        unitSize: 5,
      );
      const fixedTeams = EventSuccessStructureConfig(
        unitKind: EventSuccessUnitKind.teams,
        unitSize: 5,
        unitCount: 4,
      );

      final fullAttendance = autoTeams.estimateForAttendance(50);
      final partialAttendance = autoTeams.estimateForAttendance(37);
      final fixedAttendance = fixedTeams.estimateForAttendance(11);

      expect(fullAttendance.unitCount, 10);
      expect(fullAttendance.minPeoplePerUnit, 5);
      expect(fullAttendance.maxPeoplePerUnit, 5);
      expect(partialAttendance.unitCount, 8);
      expect(partialAttendance.minPeoplePerUnit, 4);
      expect(partialAttendance.maxPeoplePerUnit, 5);
      expect(fixedAttendance.unitCount, 4);
      expect(fixedAttendance.minPeoplePerUnit, 2);
      expect(fixedAttendance.maxPeoplePerUnit, 3);
    });

    test('module selection owns derived wingman and opener booleans', () {
      final defaults = EventSuccessDefaults(
        enabled: true,
        selectedModuleIds: [EventSuccessModuleCatalog.checkIn.id],
        wingmanRequestsEnabled: true,
        contextualOpenersEnabled: true,
      ).normalizedForActivity(ActivityKind.socialRun);

      expect(
        defaults.selectedModuleIds,
        isNot(contains(EventSuccessModuleCatalog.wingmanRequests.id)),
      );
      expect(defaults.wingmanRequestsEnabled, isFalse);
      expect(defaults.contextualOpenersEnabled, isFalse);
    });

    test('activity profiles keep impossible toggles out of defaults', () {
      final racket = EventSuccessActivityProfile.forActivity(
        ActivityKind.pickleball,
      );
      final quiz = EventSuccessActivityProfile.forActivity(
        ActivityKind.pubQuiz,
      );
      final yoga = EventSuccessActivityProfile.forActivity(ActivityKind.yoga);
      final mixer = EventSuccessActivityProfile.forActivity(
        ActivityKind.singlesMixer,
      );

      expect(
        racket.defaultModuleIds,
        contains(EventSuccessModuleCatalog.guidedRotations.id),
      );
      expect(
        racket.defaultModuleIds,
        contains(EventSuccessModuleCatalog.liveReveal.id),
      );
      expect(
        racket.isSelectable(EventSuccessModuleCatalog.microPods.id),
        isFalse,
      );
      expect(
        quiz.defaultModuleIds,
        contains(EventSuccessModuleCatalog.microPods.id),
      );
      expect(
        yoga.isSelectable(EventSuccessModuleCatalog.guidedRotations.id),
        isFalse,
      );
      expect(
        mixer.defaultModuleIds,
        contains(EventSuccessModuleCatalog.compatibilityQuestionnaire.id),
      );
      expect(mixer.compatibilityAffectsRankingByDefault, isTrue);
    });

    test('format profiles use saved interaction model for custom formats', () {
      const format = EventFormatSnapshot(
        activityKind: ActivityKind.openActivity,
        interactionModel: EventInteractionModel.teamRotations,
        customActivityLabel: 'Trivia night',
      );

      final profile = EventSuccessActivityProfile.forFormat(
        format,
        targetAttendeeCount: 40,
      );

      expect(profile.formatLabel, 'Trivia night');
      expect(profile.interactionModel, EventInteractionModel.teamRotations);
      expect(
        profile.assignmentAlgorithm,
        EventSuccessAssignmentAlgorithm.teamBalancer,
      );
      expect(profile.playbook.id, EventSuccessPlaybookLibrary.pubQuiz.id);
      expect(profile.structureConfig.unitKind, EventSuccessUnitKind.teams);
      expect(
        profile.defaultModuleIds,
        contains(EventSuccessModuleCatalog.microPods.id),
      );
      expect(
        profile.defaultModuleIds,
        contains(EventSuccessModuleCatalog.liveReveal.id),
      );
    });

    test(
      'format primitives translate open custom formats into fixed behavior',
      () {
        const format = EventFormatSnapshot(
          activityKind: ActivityKind.openActivity,
          interactionModel: EventInteractionModel.openFormat,
          customActivityLabel: 'Trivia night',
          eventSuccessPrimitives: {
            'phoneAvailability': 'plannedPauses',
            'rotationSuitability': 'plannedBreaks',
            'assignmentAlgorithm': 'teamBalancer',
            'compatibilityPolicy': 'questionnaireClueOnly',
          },
        );

        final profile = EventSuccessActivityProfile.forFormat(
          format,
          targetAttendeeCount: 40,
        );

        expect(profile.formatLabel, 'Trivia night');
        expect(profile.interactionModel, EventInteractionModel.teamRotations);
        expect(
          profile.phoneAvailability,
          EventSuccessPhoneAvailability.plannedPauses,
        );
        expect(
          profile.rotationSuitability,
          EventSuccessRotationSuitability.plannedBreaks,
        );
        expect(
          profile.assignmentAlgorithm,
          EventSuccessAssignmentAlgorithm.teamBalancer,
        );
        expect(
          profile.compatibilityPolicy,
          EventSuccessCompatibilityPolicy.questionnaireClueOnly,
        );
        expect(profile.playbook.id, EventSuccessPlaybookLibrary.pubQuiz.id);
        expect(profile.structureConfig.unitKind, EventSuccessUnitKind.teams);
        expect(
          profile.defaultModuleIds,
          contains(EventSuccessModuleCatalog.microPods.id),
        );
      },
    );

    test('mutual-interest primitive makes custom mixers dating-forward', () {
      const format = EventFormatSnapshot(
        activityKind: ActivityKind.openActivity,
        interactionModel: EventInteractionModel.openFormat,
        customActivityLabel: 'Algorithmic mixer',
        eventSuccessPrimitives: {
          'assignmentAlgorithm': 'socialPods',
          'compatibilityPolicy': 'mutualInterestOnly',
        },
      );

      final profile = EventSuccessActivityProfile.forFormat(format);

      expect(profile.interactionModel, EventInteractionModel.freeFormMixer);
      expect(
        profile.compatibilityPolicy,
        EventSuccessCompatibilityPolicy.mutualInterestOnly,
      );
      expect(
        profile.playbook.id,
        EventSuccessPlaybookLibrary.algorithmicMixer.id,
      );
      expect(profile.compatibilityAffectsRankingByDefault, isTrue);
      expect(
        profile.defaultModuleIds,
        contains(EventSuccessModuleCatalog.compatibilityQuestionnaire.id),
      );
    });

    test('event defaults normalize to the selected activity', () {
      final racketDefaults = EventSuccessDefaults(
        enabled: true,
        selectedModuleIds: [EventSuccessModuleCatalog.microPods.id],
      ).normalizedForActivity(ActivityKind.pickleball);
      final mixerDefaults = const EventSuccessDefaults(
        enabled: true,
      ).normalizedForActivity(ActivityKind.singlesMixer);

      expect(
        racketDefaults.playbookId,
        EventSuccessPlaybookLibrary.pickleball.id,
      );
      expect(
        racketDefaults.selectedModuleIds,
        isNot(contains(EventSuccessModuleCatalog.microPods.id)),
      );
      expect(
        racketDefaults.selectedModuleIds,
        contains(EventSuccessModuleCatalog.guidedRotations.id),
      );
      expect(
        mixerDefaults.playbookId,
        EventSuccessPlaybookLibrary.algorithmicMixer.id,
      );
      expect(
        mixerDefaults.selectedModuleIds,
        contains(EventSuccessModuleCatalog.compatibilityQuestionnaire.id),
      );
      expect(mixerDefaults.compatibilityAffectsRanking, isTrue);
    });

    test('event plan factories use saved format interaction model', () {
      const format = EventFormatSnapshot(
        activityKind: ActivityKind.openActivity,
        interactionModel: EventInteractionModel.teamRotations,
        customActivityLabel: 'Trivia night',
      );
      final event = buildEvent(
        eventFormat: format,
        capacityLimit: 42,
        bookedCount: 30,
      );

      final defaultsPlan = const EventSuccessDefaults(
        enabled: true,
      ).toPlanForEvent(event, now: DateTime(2026, 5, 23, 12));
      final directPlan = EventSuccessPlan.defaultForEvent(
        event,
        now: DateTime(2026, 5, 23, 12),
      );

      for (final plan in [defaultsPlan, directPlan]) {
        expect(plan.playbookId, EventSuccessPlaybookLibrary.pubQuiz.id);
        expect(plan.structureConfig.unitKind, EventSuccessUnitKind.teams);
        expect(plan.structureConfig.estimatedUnitCount(42), 9);
        expect(
          plan.selectedModuleIds,
          contains(EventSuccessModuleCatalog.microPods.id),
        );
      }
    });

    test('activity normalization replaces legacy structure defaults', () {
      final normalizedDraft =
          EventSuccessHostDraft.fromPlaybook(
                EventSuccessPlaybookLibrary.socialRun,
              )
              .copyWith(
                structureConfig:
                    const EventSuccessStructureConfig.legacyDefault(),
              )
              .normalizeForActivity(ActivityKind.pickleball);

      expect(
        normalizedDraft.structureConfig.unitKind,
        EventSuccessUnitKind.pairs,
      );
      expect(normalizedDraft.structureConfig.unitSize, 2);
      expect(normalizedDraft.structureConfig.rotationIntervalMinutes, 15);
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
          'refresh_assignment_coverage',
          'reduce_assignment_pressure',
          'use_wingman_signal_live',
          'improve_first_message',
          'improve_host_welcome',
          'right_size_structure',
          'increase_feedback_response',
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
        contains('Arrival data is reliable enough for matching and reports.'),
      );
      expect(brief.strengths, contains('Most attendees met multiple people.'));
      expect(
        brief.strengths,
        contains('Mutual matches are converting into chat starts.'),
      );
      expect(
        brief.strengths,
        contains('Assignments reached most active attendees.'),
      );
      expect(
        brief.strengths,
        contains('Feedback response is strong enough to trust the report.'),
      );
    });
  });
}
