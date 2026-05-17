import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';

class EventSuccessCoach {
  const EventSuccessCoach();

  EventSuccessBrief analyze({
    required EventSuccessPlaybook playbook,
    required EventSuccessScorecard scorecard,
  }) {
    final recommendations = <EventSuccessRecommendation>[];
    final strengths = <String>[];

    if (scorecard.safetyIncidentCount > 0) {
      recommendations.add(
        const EventSuccessRecommendation(
          id: 'safety_first',
          title: 'Review comfort and safety before the next event',
          rationale:
              'Safety incidents should block optimization work until the host has a clear escalation and prevention plan.',
          priority: EventRecommendationPriority.critical,
          stage: EventSuccessStage.before,
          moduleIds: ['safety_controls', 'host_analytics'],
        ),
      );
    }

    if (scorecard.checkInRate < 0.85) {
      recommendations.add(
        const EventSuccessRecommendation(
          id: 'tighten_check_in',
          title: 'Tighten arrival and attendance capture',
          rationale:
              'Low check-in makes matching, private crushes, reviews, and host coaching less trustworthy.',
          priority: EventRecommendationPriority.high,
          stage: EventSuccessStage.arrival,
          moduleIds: ['qr_check_in'],
        ),
      );
    } else {
      strengths.add(
        'Arrival data is reliable enough to power post-event loops.',
      );
    }

    if (scorecard.introCoverageRate < 0.7) {
      recommendations.add(
        EventSuccessRecommendation(
          id: 'increase_intro_coverage',
          title: 'Create more social permission during the event',
          rationale: playbook.activityType.isMovementHeavy
              ? 'Movement-heavy events need light pods and cooldown prompts instead of phone-heavy live tasks.'
              : 'Stationary events can use teams, rotations, or prompts to reduce approach anxiety.',
          priority: EventRecommendationPriority.high,
          stage: EventSuccessStage.mixing,
          moduleIds: const ['micro_pods', 'social_missions'],
        ),
      );
    } else {
      strengths.add('Most attendees met multiple people.');
    }

    if (scorecard.privateCrushRate < 0.2) {
      recommendations.add(
        const EventSuccessRecommendation(
          id: 'lower_follow_up_friction',
          title: 'Make post-event interest feel safer',
          rationale:
              'Low private interest usually means attendees lacked either social context or confidence that non-mutual interest stays hidden.',
          priority: EventRecommendationPriority.medium,
          stage: EventSuccessStage.after,
          moduleIds: ['private_crush', 'contextual_openers'],
        ),
      );
    }

    if (scorecard.mutualMatchCount > 0 && scorecard.chatStartRate < 0.6) {
      recommendations.add(
        const EventSuccessRecommendation(
          id: 'improve_first_message',
          title: 'Give matches event-specific openers',
          rationale:
              'Matches are forming, but chat is not starting reliably. Shared event context should make the first message easier.',
          priority: EventRecommendationPriority.medium,
          stage: EventSuccessStage.after,
          moduleIds: ['contextual_openers'],
        ),
      );
    } else if (scorecard.mutualMatchCount > 0) {
      strengths.add('Mutual matches are converting into chat starts.');
    }

    if (scorecard.averageWelcomeRating < 4.0) {
      recommendations.add(
        const EventSuccessRecommendation(
          id: 'improve_host_welcome',
          title: 'Make the host opening clearer and warmer',
          rationale:
              'A weak welcome can make attendees feel like strangers sharing space instead of participants in the same event.',
          priority: EventRecommendationPriority.medium,
          stage: EventSuccessStage.opening,
          moduleIds: ['host_script'],
        ),
      );
    }

    if (scorecard.averageStructureRating < 3.8) {
      recommendations.add(
        const EventSuccessRecommendation(
          id: 'right_size_structure',
          title: 'Adjust the amount of live structure',
          rationale:
              'Structure should create permission to connect without making the event feel controlled or artificial.',
          priority: EventRecommendationPriority.medium,
          stage: EventSuccessStage.activity,
          moduleIds: ['host_script', 'decomposed_feedback'],
        ),
      );
    }

    if (scorecard.repeatSignupRate >= 0.35) {
      strengths.add(
        'Repeat signup is strong enough to treat this format as a keeper.',
      );
    }

    return EventSuccessBrief(
      scorecard: scorecard,
      recommendations: _sortRecommendations(recommendations),
      strengths: strengths,
    );
  }

  List<EventSuccessRecommendation> _sortRecommendations(
    List<EventSuccessRecommendation> recommendations,
  ) {
    final sorted = [...recommendations];
    sorted.sort(
      (a, b) => _priorityRank(a.priority).compareTo(_priorityRank(b.priority)),
    );
    return sorted;
  }

  int _priorityRank(EventRecommendationPriority priority) => switch (priority) {
    EventRecommendationPriority.critical => 0,
    EventRecommendationPriority.high => 1,
    EventRecommendationPriority.medium => 2,
    EventRecommendationPriority.low => 3,
  };
}

abstract final class EventSuccessSampleScorecards {
  static const strongSocialRun = EventSuccessScorecard(
    bookedCount: 28,
    checkedInCount: 25,
    attendeesWhoMetTwoPlusPeople: 19,
    privateCrushCount: 8,
    mutualMatchCount: 4,
    chatStartedCount: 3,
    repeatSignupCount: 10,
    averageWelcomeRating: 4.4,
    averageStructureRating: 4.1,
    safetyIncidentCount: 0,
  );

  static const needsStructure = EventSuccessScorecard(
    bookedCount: 34,
    checkedInCount: 23,
    attendeesWhoMetTwoPlusPeople: 9,
    privateCrushCount: 2,
    mutualMatchCount: 1,
    chatStartedCount: 0,
    repeatSignupCount: 4,
    averageWelcomeRating: 3.6,
    averageStructureRating: 3.1,
    safetyIncidentCount: 0,
  );

  static const safetyReviewRequired = EventSuccessScorecard(
    bookedCount: 30,
    checkedInCount: 27,
    attendeesWhoMetTwoPlusPeople: 20,
    privateCrushCount: 8,
    mutualMatchCount: 4,
    chatStartedCount: 4,
    repeatSignupCount: 7,
    averageWelcomeRating: 4.0,
    averageStructureRating: 4.0,
    safetyIncidentCount: 1,
  );
}

EventSuccessBrief sampleEventSuccessBrief() =>
    const EventSuccessCoach().analyze(
      playbook: EventSuccessPlaybookLibrary.socialRun,
      scorecard: EventSuccessSampleScorecards.needsStructure,
    );
