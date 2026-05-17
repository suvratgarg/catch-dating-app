import 'package:catch_dating_app/event_success/domain/event_success_models.dart';

abstract final class EventSuccessModuleCatalog {
  static const crowdBalance = EventSuccessModule(
    id: 'crowd_balance',
    title: 'Crowd balance planner',
    type: EventSuccessModuleType.crowdBalance,
    stage: EventSuccessStage.before,
    attendeePromise: 'The room feels intentional instead of random.',
    hostPromise:
        'Shows waitlist, cohort, skill, and pace gaps before the event.',
    setupSteps: [
      'Collect only the fields needed for balance decisions.',
      'Show balance risk before the host confirms additional attendees.',
      'Use waitlist offers instead of silent rejection when possible.',
    ],
    riskControls: [
      'Do not expose private cohort counts to attendees.',
      'Keep non-binary and queer formats explicit instead of forcing binary caps.',
    ],
  );

  static const checkIn = EventSuccessModule(
    id: 'qr_check_in',
    title: 'QR check-in and live roster',
    type: EventSuccessModuleType.checkIn,
    stage: EventSuccessStage.arrival,
    attendeePromise: 'Arrival is quick and the right people enter the loop.',
    hostPromise: 'Confirms who actually attended before matching and reviews.',
    requiresLivePhoneUse: true,
    setupSteps: [
      'Generate a per-event check-in code.',
      'Let hosts mark manual arrivals when phones fail.',
      'Use checked-in attendees for post-event crushes and swipes.',
    ],
    riskControls: [
      'Never publish the full roster by default.',
      'Keep host overrides auditable.',
    ],
  );

  static const hostScript = EventSuccessModule(
    id: 'host_script',
    title: 'Host script',
    type: EventSuccessModuleType.formatTemplate,
    stage: EventSuccessStage.opening,
    attendeePromise: 'The room gets clear social permission to talk.',
    hostPromise: 'Gives non-professional hosts a simple run-of-show.',
    setupSteps: [
      'Prepare a welcome line, safety note, and first prompt.',
      'Keep the script short enough to use live.',
    ],
  );

  static const microPods = EventSuccessModule(
    id: 'micro_pods',
    title: 'Micro-pods',
    type: EventSuccessModuleType.microPods,
    stage: EventSuccessStage.opening,
    attendeePromise: 'Meet a small group before needing to approach strangers.',
    hostPromise: 'Creates mixing without forcing one-to-one pressure.',
    setupSteps: [
      'Group attendees into four to six person pods.',
      'Prefer pace, skill, geography, or interests over hidden romance scoring.',
      'Let hosts reshuffle pods when real arrivals differ from signups.',
    ],
    riskControls: ['Offer an opt-out for attendees who arrive with friends.'],
  );

  static const socialMissions = EventSuccessModule(
    id: 'social_missions',
    title: 'Social missions',
    type: EventSuccessModuleType.socialMissions,
    stage: EventSuccessStage.mixing,
    attendeePromise: 'There is an easy excuse to start one more conversation.',
    hostPromise: 'Improves room energy without heavy facilitation.',
    setupSteps: [
      'Generate three activity-specific prompts.',
      'Keep missions optional and non-performative.',
      'End each mission with a natural transition back to the activity.',
    ],
  );

  static const guidedRotations = EventSuccessModule(
    id: 'guided_rotations',
    title: 'Guided rotations',
    type: EventSuccessModuleType.guidedRotations,
    stage: EventSuccessStage.activity,
    attendeePromise: 'Everyone meets more people without doing the logistics.',
    hostPromise: 'Creates predictable mixing for games, tables, and teams.',
    setupSteps: [
      'Set round length and rotation count.',
      'Avoid back-to-back repeats.',
      'Show the next partner, table, or team only when needed.',
    ],
    requiresLivePhoneUse: true,
    recommendedFor: {
      EventActivityType.pickleball,
      EventActivityType.pubQuiz,
      EventActivityType.dinner,
      EventActivityType.singlesMixer,
    },
    riskControls: [
      'Do not use timed rotations for movement-heavy events unless there is a pause.',
    ],
  );

  static const compatibilityQuestionnaire = EventSuccessModule(
    id: 'compatibility_questionnaire',
    title: 'Compatibility questionnaire',
    type: EventSuccessModuleType.compatibilityQuestionnaire,
    stage: EventSuccessStage.before,
    attendeePromise: 'Matching moments have a reason beyond looks.',
    hostPromise: 'Supports clues, reveal, and post-event matching experiments.',
    enabledByDefault: false,
    setupSteps: [
      'Ask fewer than ten questions in the first version.',
      'Tie questions to the event vibe, not a permanent personality score.',
      'Explain compatibility as conversation context, not destiny.',
    ],
    riskControls: [
      'Avoid implying the algorithm can predict chemistry.',
      'Do not block organic interaction before the reveal.',
    ],
  );

  static const privateCrush = EventSuccessModule(
    id: 'private_crush',
    title: 'Private crush',
    type: EventSuccessModuleType.privateCrush,
    stage: EventSuccessStage.after,
    attendeePromise: 'Interest is private unless it is mutual.',
    hostPromise: 'Captures real event chemistry before the full swipe deck.',
    setupSteps: [
      'Open after check-in or host attendance confirmation.',
      'Limit visibility to people who attended the same event.',
      'Create a match only when both people express interest.',
    ],
    riskControls: [
      'Keep non-mutual interest invisible.',
      'Respect blocks, reports, and profile visibility settings.',
    ],
  );

  static const contextualOpeners = EventSuccessModule(
    id: 'contextual_openers',
    title: 'Contextual openers',
    type: EventSuccessModuleType.contextualOpeners,
    stage: EventSuccessStage.after,
    attendeePromise: 'A match starts with shared context instead of a cold hi.',
    hostPromise: 'Improves downstream chat starts without host involvement.',
    setupSteps: [
      'Use event, team, route, prompt, or table context.',
      'Let either person ignore the suggested opener.',
    ],
    riskControls: [
      'Do not reveal private questionnaire answers unless both people consented.',
    ],
  );

  static const decomposedFeedback = EventSuccessModule(
    id: 'decomposed_feedback',
    title: 'Decomposed feedback',
    type: EventSuccessModuleType.decomposedFeedback,
    stage: EventSuccessStage.after,
    attendeePromise: 'Feedback is specific and private.',
    hostPromise:
        'Separates welcome, balance, structure, safety, and chemistry.',
    setupSteps: [
      'Ask short dimension-level questions after the event.',
      'Use coaching summaries before public ranking changes.',
    ],
  );

  static const hostAnalytics = EventSuccessModule(
    id: 'host_analytics',
    title: 'Host analytics and coach',
    type: EventSuccessModuleType.hostAnalytics,
    stage: EventSuccessStage.hostDebrief,
    attendeePromise:
        'The next event should feel better because this one taught us something.',
    hostPromise:
        'Turns check-in, mixing, crushes, reviews, and repeats into advice.',
    setupSteps: [
      'Show a short post-event brief.',
      'Recommend one or two changes, not a dashboard wall.',
      'Track improvement over repeated events by the same host.',
    ],
  );

  static const safetyControls = EventSuccessModule(
    id: 'safety_controls',
    title: 'Comfort and safety controls',
    type: EventSuccessModuleType.safetyControls,
    stage: EventSuccessStage.before,
    attendeePromise: 'Attendees can participate without losing control.',
    hostPromise: 'Gives hosts escalation and boundary tools.',
    setupSteps: [
      'Respect block and report state everywhere.',
      'Let attendees opt out of live intros or visibility modules.',
      'Expose host help and report affordances without drama.',
    ],
    riskControls: [
      'Treat safety as a launch prerequisite for live event features.',
    ],
  );

  static const all = <EventSuccessModule>[
    crowdBalance,
    checkIn,
    hostScript,
    microPods,
    socialMissions,
    guidedRotations,
    compatibilityQuestionnaire,
    privateCrush,
    contextualOpeners,
    decomposedFeedback,
    hostAnalytics,
    safetyControls,
  ];

  static EventSuccessModule byId(String id) => all.firstWhere(
    (module) => module.id == id,
    orElse: () => throw ArgumentError.value(id, 'id', 'Unknown module id'),
  );
}

abstract final class EventSuccessMetricCatalog {
  static const checkInRate = EventSuccessMetric(
    id: 'check_in_rate',
    label: 'Check-in rate',
    description: 'Share of booked attendees who actually arrive.',
    target: '85 percent or higher for repeatable events.',
  );

  static const introCoverage = EventSuccessMetric(
    id: 'intro_coverage',
    label: 'Intro coverage',
    description: 'Share of attendees who met at least two new people.',
    target: '70 percent or higher for guided formats.',
  );

  static const privateCrushRate = EventSuccessMetric(
    id: 'private_crush_rate',
    label: 'Private crush rate',
    description: 'Share of attendees who marked at least one private interest.',
    target: '20 percent or higher without pressuring attendees.',
  );

  static const mutualMatchRate = EventSuccessMetric(
    id: 'mutual_match_rate',
    label: 'Mutual match rate',
    description:
        'Share of attendees who convert into at least one mutual match.',
    target: 'Measure by format; optimize trend, not one-event spikes.',
  );

  static const chatStartRate = EventSuccessMetric(
    id: 'chat_start_rate',
    label: 'Chat start rate',
    description: 'Share of mutual matches where someone sends a first message.',
    target: '60 percent or higher when contextual openers are available.',
  );

  static const dimensionRatings = EventSuccessMetric(
    id: 'dimension_ratings',
    label: 'Dimension ratings',
    description: 'Welcome, crowd balance, structure, safety, and venue scores.',
    target: 'Use private coaching before public ranking penalties.',
  );

  static const repeatAttendance = EventSuccessMetric(
    id: 'repeat_attendance',
    label: 'Repeat attendance',
    description: 'Share of attendees who book another host event.',
    target: 'Trend by host and event type.',
  );

  static const core = <EventSuccessMetric>[
    checkInRate,
    introCoverage,
    privateCrushRate,
    mutualMatchRate,
    chatStartRate,
    dimensionRatings,
    repeatAttendance,
  ];
}

abstract final class EventSuccessPlaybookLibrary {
  static const socialRun = EventSuccessPlaybook(
    id: 'social_run_light',
    title: 'Social Run Lite',
    activityType: EventActivityType.socialRun,
    socialIntensity: EventSocialIntensity.light,
    summary:
        'A run-first format that adds arrival structure, pace pods, optional prompts, and a post-run crush loop.',
    attendeePromise:
        'You can run naturally, meet people at your pace, and follow up privately afterward.',
    hostPromise:
        'Use check-in, pace pods, and a short cooldown prompt without turning the run into speed dating.',
    capacity: EventCapacityGuidance(
      min: 8,
      max: 36,
      rationale: 'Large enough for choice, small enough for pace groups.',
    ),
    modules: [
      EventSuccessModuleCatalog.crowdBalance,
      EventSuccessModuleCatalog.checkIn,
      EventSuccessModuleCatalog.hostScript,
      EventSuccessModuleCatalog.microPods,
      EventSuccessModuleCatalog.socialMissions,
      EventSuccessModuleCatalog.privateCrush,
      EventSuccessModuleCatalog.contextualOpeners,
      EventSuccessModuleCatalog.decomposedFeedback,
      EventSuccessModuleCatalog.hostAnalytics,
      EventSuccessModuleCatalog.safetyControls,
    ],
    runOfShow: [
      EventRunOfShowStep(
        stage: EventSuccessStage.arrival,
        title: 'Check in and pace sort',
        durationMinutes: 10,
        hostInstruction: 'Scan arrivals and confirm pace groups.',
        attendeeExperience: 'Arrive, check in, and see your pace pod.',
        moduleIds: ['qr_check_in', 'micro_pods'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.opening,
        title: 'Two-minute welcome',
        durationMinutes: 2,
        hostInstruction: 'Name the route, safety note, and social permission.',
        attendeeExperience:
            'Know what is happening and that talking is welcome.',
        moduleIds: ['host_script', 'safety_controls'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.activity,
        title: 'Run in pace pods',
        durationMinutes: 35,
        hostInstruction: 'Keep pods visible and avoid mid-run phone use.',
        attendeeExperience: 'Run with a small group that matches your pace.',
        moduleIds: ['micro_pods'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.mixing,
        title: 'Cooldown social mission',
        durationMinutes: 12,
        hostInstruction:
            'Offer one optional prompt before coffee or dispersal.',
        attendeeExperience: 'Get a natural reason to speak to one more person.',
        moduleIds: ['social_missions'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.after,
        title: 'Private follow-up',
        durationMinutes: 3,
        hostInstruction: 'Remind attendees that post-run crushes are private.',
        attendeeExperience: 'Mark interest without public rejection risk.',
        moduleIds: ['private_crush', 'contextual_openers'],
      ),
    ],
    metrics: EventSuccessMetricCatalog.core,
    antiPatterns: [
      'Do not interrupt the actual run with phone-heavy prompts.',
      'Do not make one-to-one romantic pairing the headline for beginner runs.',
      'Do not publish attendee interest unless it is mutual.',
    ],
    iterationQuestions: [
      'Did pace pods improve first conversations?',
      'Did cooldown prompts feel useful or awkward?',
      'Did private crush capture interest earlier than the full swipe deck?',
    ],
    wiringNotes: [
      'Could reuse booking and attendance once approved.',
      'Should not change current run booking until check-in behavior is validated.',
    ],
  );

  static const pickleball = EventSuccessPlaybook(
    id: 'pickleball_rotations',
    title: 'Pickleball Partner Rotations',
    activityType: EventActivityType.pickleball,
    socialIntensity: EventSocialIntensity.structured,
    summary:
        'A court-based mixer with rotating partners, skill-aware teams, and a post-game interest loop.',
    attendeePromise:
        'Play real games while meeting multiple partners without awkward logistics.',
    hostPromise:
        'The app handles pairings, sit-outs, timing, and post-event matching context.',
    capacity: EventCapacityGuidance(
      min: 12,
      max: 32,
      rationale: 'Works best with enough players for court rotation variety.',
    ),
    modules: [
      EventSuccessModuleCatalog.crowdBalance,
      EventSuccessModuleCatalog.checkIn,
      EventSuccessModuleCatalog.hostScript,
      EventSuccessModuleCatalog.guidedRotations,
      EventSuccessModuleCatalog.socialMissions,
      EventSuccessModuleCatalog.privateCrush,
      EventSuccessModuleCatalog.contextualOpeners,
      EventSuccessModuleCatalog.decomposedFeedback,
      EventSuccessModuleCatalog.hostAnalytics,
      EventSuccessModuleCatalog.safetyControls,
    ],
    runOfShow: [
      EventRunOfShowStep(
        stage: EventSuccessStage.arrival,
        title: 'Check in and skill confirm',
        durationMinutes: 10,
        hostInstruction: 'Confirm courts, arrivals, and beginner support.',
        attendeeExperience: 'Know your first court and partner.',
        moduleIds: ['qr_check_in', 'guided_rotations'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.opening,
        title: 'Rules and first rotation',
        durationMinutes: 5,
        hostInstruction: 'Explain rotation timing and sportsmanship norms.',
        attendeeExperience: 'Start with a clear partner assignment.',
        moduleIds: ['host_script', 'safety_controls'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.activity,
        title: 'Timed partner rounds',
        durationMinutes: 50,
        hostInstruction: 'Advance rotations and handle sit-outs fairly.',
        attendeeExperience:
            'Play with several people at a matched skill level.',
        moduleIds: ['guided_rotations'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.closing,
        title: 'Final rally and wrap',
        durationMinutes: 8,
        hostInstruction: 'Close with a low-pressure social prompt.',
        attendeeExperience: 'Get one more chance to talk off court.',
        moduleIds: ['social_missions'],
      ),
    ],
    metrics: EventSuccessMetricCatalog.core,
    antiPatterns: [
      'Do not strand beginners in repeated sit-outs.',
      'Do not let rotation logistics consume the social energy.',
    ],
    iterationQuestions: [
      'Were rotations fair across skill levels?',
      'Did people remember enough names to follow up?',
    ],
    wiringNotes: [
      'Needs an activity-specific rotation engine before production routing.',
    ],
  );

  static const pubQuiz = EventSuccessPlaybook(
    id: 'pub_quiz_team_mixer',
    title: 'Pub Quiz Team Mixer',
    activityType: EventActivityType.pubQuiz,
    socialIntensity: EventSocialIntensity.guided,
    summary:
        'A team-based format that uses role prompts and team reshuffles to make conversation easy.',
    attendeePromise:
        'You have teammates, prompts, and trivia as a reason to talk.',
    hostPromise:
        'Balance teams, avoid friend clumps, and measure whether teams actually mixed.',
    capacity: EventCapacityGuidance(
      min: 16,
      max: 60,
      rationale: 'Team formats need enough people for variety but can scale.',
    ),
    modules: [
      EventSuccessModuleCatalog.crowdBalance,
      EventSuccessModuleCatalog.checkIn,
      EventSuccessModuleCatalog.hostScript,
      EventSuccessModuleCatalog.microPods,
      EventSuccessModuleCatalog.socialMissions,
      EventSuccessModuleCatalog.privateCrush,
      EventSuccessModuleCatalog.contextualOpeners,
      EventSuccessModuleCatalog.decomposedFeedback,
      EventSuccessModuleCatalog.hostAnalytics,
      EventSuccessModuleCatalog.safetyControls,
    ],
    runOfShow: [
      EventRunOfShowStep(
        stage: EventSuccessStage.arrival,
        title: 'Check in and team assignment',
        durationMinutes: 12,
        hostInstruction:
            'Assign mixed teams and name one lightweight role per person.',
        attendeeExperience: 'Join a table with a reason to contribute.',
        moduleIds: ['qr_check_in', 'micro_pods'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.activity,
        title: 'Quiz rounds with role prompts',
        durationMinutes: 60,
        hostInstruction: 'Use prompts between rounds, not during questions.',
        attendeeExperience: 'Talk through trivia without forced dating rounds.',
        moduleIds: ['social_missions'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.closing,
        title: 'Mutual follow-up reminder',
        durationMinutes: 4,
        hostInstruction:
            'Remind attendees that interest stays private unless mutual.',
        attendeeExperience: 'Follow up with people from the room privately.',
        moduleIds: ['private_crush', 'contextual_openers'],
      ),
    ],
    metrics: EventSuccessMetricCatalog.core,
    antiPatterns: [
      'Do not let existing friend groups sit together unchanged.',
      'Do not over-script conversation during the actual game.',
    ],
    iterationQuestions: [
      'Did team assignment reduce awkward arrivals?',
      'Were people willing to follow up across tables?',
    ],
    wiringNotes: [
      'Can launch as a host-only playbook before full team assignment automation.',
    ],
  );

  static const algorithmicMixer = EventSuccessPlaybook(
    id: 'algorithmic_mixer_reveal',
    title: 'Questionnaire Reveal Mixer',
    activityType: EventActivityType.singlesMixer,
    socialIntensity: EventSocialIntensity.algorithmic,
    summary:
        'A Matchbox-like format with short questionnaires, clues, reveal moments, private interest, and explanations.',
    attendeePromise:
        'The event has a shared ritual, but chemistry is still yours to judge.',
    hostPromise:
        'Create a memorable reveal flow while measuring whether the structure actually improved outcomes.',
    capacity: EventCapacityGuidance(
      min: 20,
      max: 80,
      rationale:
          'Needs enough density for matching but not so many that reveal loses intimacy.',
    ),
    modules: [
      EventSuccessModuleCatalog.crowdBalance,
      EventSuccessModuleCatalog.checkIn,
      EventSuccessModuleCatalog.hostScript,
      EventSuccessModuleCatalog.compatibilityQuestionnaire,
      EventSuccessModuleCatalog.guidedRotations,
      EventSuccessModuleCatalog.socialMissions,
      EventSuccessModuleCatalog.privateCrush,
      EventSuccessModuleCatalog.contextualOpeners,
      EventSuccessModuleCatalog.decomposedFeedback,
      EventSuccessModuleCatalog.hostAnalytics,
      EventSuccessModuleCatalog.safetyControls,
    ],
    runOfShow: [
      EventRunOfShowStep(
        stage: EventSuccessStage.before,
        title: 'Short questionnaire',
        durationMinutes: 4,
        hostInstruction:
            'Use questions that set up conversation, not permanence.',
        attendeeExperience: 'Answer a few prompts before arrival.',
        moduleIds: ['compatibility_questionnaire'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.arrival,
        title: 'Check in and clue card',
        durationMinutes: 12,
        hostInstruction: 'Confirm attendance and issue first clue.',
        attendeeExperience: 'Enter with a playful search prompt.',
        moduleIds: ['qr_check_in', 'compatibility_questionnaire'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.mixing,
        title: 'Rounds and reveal',
        durationMinutes: 45,
        hostInstruction: 'Run two or three rounds before any match reveal.',
        attendeeExperience:
            'Meet people before seeing algorithmic suggestions.',
        moduleIds: ['guided_rotations', 'social_missions'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.after,
        title: 'Private interest and context',
        durationMinutes: 5,
        hostInstruction:
            'Make clear that compatibility is a prompt, not a promise.',
        attendeeExperience:
            'Use private crush and suggested openers after the reveal.',
        moduleIds: ['private_crush', 'contextual_openers'],
      ),
    ],
    metrics: EventSuccessMetricCatalog.core,
    antiPatterns: [
      'Do not sell compatibility as a guarantee of spark.',
      'Do not reveal too early; people should meet before algorithmic framing.',
      'Do not make phone use dominate the room.',
    ],
    iterationQuestions: [
      'Did the reveal create energy or pressure?',
      'Did questionnaire answers improve conversations?',
      'Did matches chat at a higher rate than non-reveal formats?',
    ],
    wiringNotes: [
      'Keep this behind WIP until consent, privacy, and explanation copy are approved.',
    ],
  );

  static const all = <EventSuccessPlaybook>[
    socialRun,
    pickleball,
    pubQuiz,
    algorithmicMixer,
  ];

  static Iterable<EventSuccessPlaybook> forActivity(EventActivityType type) =>
      all.where((playbook) => playbook.activityType == type);

  static EventSuccessPlaybook recommendedFor({
    required EventActivityType activityType,
    EventSocialIntensity? preferredIntensity,
  }) {
    final matches = forActivity(activityType).toList();
    if (matches.isEmpty) return socialRun;
    if (preferredIntensity == null) return matches.first;
    return matches.firstWhere(
      (playbook) => playbook.socialIntensity == preferredIntensity,
      orElse: () => matches.first,
    );
  }
}
