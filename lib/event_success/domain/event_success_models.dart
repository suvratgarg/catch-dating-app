/// IN DEVELOPMENT: event success layer.
///
/// This feature is intentionally not wired into production routes, Firestore,
/// Cloud Functions, booking, attendance, swipes, reviews, or chat yet. It is a
/// product-modeling workspace for the future live event layer.
const eventSuccessLayerDevelopmentStatus =
    'in_development_not_wired_to_live_event_flows';

enum EventActivityType {
  socialRun('Social run'),
  pickleball('Pickleball'),
  spinClass('Spin class'),
  pubQuiz('Pub quiz'),
  barCrawl('Bar crawl'),
  dinner('Dinner'),
  singlesMixer('Singles mixer'),
  openActivity('Open activity');

  const EventActivityType(this.label);

  final String label;

  bool get isMovementHeavy => switch (this) {
    EventActivityType.socialRun ||
    EventActivityType.pickleball ||
    EventActivityType.spinClass => true,
    EventActivityType.pubQuiz ||
    EventActivityType.barCrawl ||
    EventActivityType.dinner ||
    EventActivityType.singlesMixer ||
    EventActivityType.openActivity => false,
  };
}

enum EventSocialIntensity {
  light('Light', 'Small nudges that keep the activity primary.'),
  guided('Guided', 'Host-led prompts and small group structure.'),
  structured('Structured', 'Planned rotations, teams, or timed moments.'),
  algorithmic(
    'Algorithmic',
    'Questionnaires, compatibility clues, and reveal.',
  );

  const EventSocialIntensity(this.label, this.description);

  final String label;
  final String description;
}

enum EventSuccessStage {
  before('Before'),
  arrival('Arrival'),
  opening('Opening'),
  activity('Activity'),
  mixing('Mixing'),
  closing('Closing'),
  after('After'),
  hostDebrief('Host debrief');

  const EventSuccessStage(this.label);

  final String label;
}

enum EventSuccessModuleType {
  formatTemplate,
  crowdBalance,
  checkIn,
  microPods,
  socialMissions,
  guidedRotations,
  compatibilityQuestionnaire,
  privateCrush,
  contextualOpeners,
  decomposedFeedback,
  hostAnalytics,
  safetyControls,
}

enum EventRecommendationPriority { critical, high, medium, low }

class EventCapacityGuidance {
  const EventCapacityGuidance({
    required this.min,
    required this.max,
    required this.rationale,
  }) : assert(min > 0),
       assert(max >= min);

  final int min;
  final int max;
  final String rationale;

  bool contains(int attendeeCount) =>
      attendeeCount >= min && attendeeCount <= max;
}

class EventSuccessModule {
  const EventSuccessModule({
    required this.id,
    required this.title,
    required this.type,
    required this.stage,
    required this.attendeePromise,
    required this.hostPromise,
    this.enabledByDefault = true,
    this.requiresLivePhoneUse = false,
    this.recommendedFor = const {},
    this.setupSteps = const [],
    this.riskControls = const [],
  });

  final String id;
  final String title;
  final EventSuccessModuleType type;
  final EventSuccessStage stage;
  final String attendeePromise;
  final String hostPromise;
  final bool enabledByDefault;
  final bool requiresLivePhoneUse;
  final Set<EventActivityType> recommendedFor;
  final List<String> setupSteps;
  final List<String> riskControls;

  bool supports(EventActivityType activityType) =>
      recommendedFor.isEmpty || recommendedFor.contains(activityType);
}

class EventRunOfShowStep {
  const EventRunOfShowStep({
    required this.stage,
    required this.title,
    required this.hostInstruction,
    required this.attendeeExperience,
    required this.durationMinutes,
    this.moduleIds = const [],
  }) : assert(durationMinutes > 0);

  final EventSuccessStage stage;
  final String title;
  final String hostInstruction;
  final String attendeeExperience;
  final int durationMinutes;
  final List<String> moduleIds;
}

class EventSuccessMetric {
  const EventSuccessMetric({
    required this.id,
    required this.label,
    required this.description,
    required this.target,
  });

  final String id;
  final String label;
  final String description;
  final String target;
}

class EventSuccessPlaybook {
  const EventSuccessPlaybook({
    required this.id,
    required this.title,
    required this.activityType,
    required this.socialIntensity,
    required this.summary,
    required this.attendeePromise,
    required this.hostPromise,
    required this.capacity,
    required this.modules,
    required this.runOfShow,
    required this.metrics,
    required this.antiPatterns,
    required this.iterationQuestions,
    required this.wiringNotes,
  });

  final String id;
  final String title;
  final EventActivityType activityType;
  final EventSocialIntensity socialIntensity;
  final String summary;
  final String attendeePromise;
  final String hostPromise;
  final EventCapacityGuidance capacity;
  final List<EventSuccessModule> modules;
  final List<EventRunOfShowStep> runOfShow;
  final List<EventSuccessMetric> metrics;
  final List<String> antiPatterns;
  final List<String> iterationQuestions;
  final List<String> wiringNotes;

  Set<String> get moduleIds => modules.map((module) => module.id).toSet();

  bool get hasLivePhoneUse =>
      modules.any((module) => module.requiresLivePhoneUse);

  Map<EventSuccessStage, List<EventRunOfShowStep>> get runOfShowByStage {
    final grouped = <EventSuccessStage, List<EventRunOfShowStep>>{};
    for (final step in runOfShow) {
      grouped.putIfAbsent(step.stage, () => <EventRunOfShowStep>[]).add(step);
    }
    return grouped;
  }
}

class EventSuccessScorecard {
  const EventSuccessScorecard({
    required this.bookedCount,
    required this.checkedInCount,
    required this.attendeesWhoMetTwoPlusPeople,
    required this.privateCrushCount,
    required this.mutualMatchCount,
    required this.chatStartedCount,
    required this.repeatSignupCount,
    required this.averageWelcomeRating,
    required this.averageStructureRating,
    required this.safetyIncidentCount,
  }) : assert(bookedCount >= 0),
       assert(checkedInCount >= 0),
       assert(attendeesWhoMetTwoPlusPeople >= 0),
       assert(privateCrushCount >= 0),
       assert(mutualMatchCount >= 0),
       assert(chatStartedCount >= 0),
       assert(repeatSignupCount >= 0),
       assert(averageWelcomeRating >= 0 && averageWelcomeRating <= 5),
       assert(averageStructureRating >= 0 && averageStructureRating <= 5),
       assert(safetyIncidentCount >= 0);

  final int bookedCount;
  final int checkedInCount;
  final int attendeesWhoMetTwoPlusPeople;
  final int privateCrushCount;
  final int mutualMatchCount;
  final int chatStartedCount;
  final int repeatSignupCount;
  final double averageWelcomeRating;
  final double averageStructureRating;
  final int safetyIncidentCount;

  double get checkInRate => _rate(checkedInCount, bookedCount);

  double get introCoverageRate =>
      _rate(attendeesWhoMetTwoPlusPeople, checkedInCount);

  double get privateCrushRate => _rate(privateCrushCount, checkedInCount);

  double get mutualMatchRate => _rate(mutualMatchCount, checkedInCount);

  double get chatStartRate => _rate(chatStartedCount, mutualMatchCount);

  double get repeatSignupRate => _rate(repeatSignupCount, checkedInCount);

  double get experienceScore {
    final safetyPenalty = safetyIncidentCount > 0 ? 0.18 : 0.0;
    final raw =
        (checkInRate * 0.16) +
        (introCoverageRate * 0.22) +
        (privateCrushRate * 0.18) +
        (mutualMatchRate * 0.16) +
        (chatStartRate * 0.12) +
        ((averageWelcomeRating / 5) * 0.08) +
        ((averageStructureRating / 5) * 0.08) -
        safetyPenalty;
    return raw.clamp(0, 1);
  }

  static double _rate(int numerator, int denominator) {
    if (denominator <= 0) return 0;
    return (numerator / denominator).clamp(0, 1);
  }
}

class EventSuccessRecommendation {
  const EventSuccessRecommendation({
    required this.id,
    required this.title,
    required this.rationale,
    required this.priority,
    required this.stage,
    this.moduleIds = const [],
  });

  final String id;
  final String title;
  final String rationale;
  final EventRecommendationPriority priority;
  final EventSuccessStage stage;
  final List<String> moduleIds;
}

class EventSuccessBrief {
  const EventSuccessBrief({
    required this.scorecard,
    required this.recommendations,
    required this.strengths,
  });

  final EventSuccessScorecard scorecard;
  final List<EventSuccessRecommendation> recommendations;
  final List<String> strengths;
}
