import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';

abstract final class EventSuccessModuleCatalog {
  static const crowdBalance = EventSuccessModule(
    id: 'crowd_balance',
    title: 'Crowd balance planner',
    type: EventSuccessModuleType.crowdBalance,
    productLayer: EventSuccessProductLayer.rosterAttendance,
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
    title: 'Attendance and live roster',
    type: EventSuccessModuleType.checkIn,
    productLayer: EventSuccessProductLayer.rosterAttendance,
    stage: EventSuccessStage.arrival,
    attendeePromise: 'Arrival is quick and the right people enter the loop.',
    hostPromise: 'Confirms who actually attended before matching and reviews.',
    requiresLivePhoneUse: true,
    setupSteps: [
      'Use the shared event attendance system as the source of truth.',
      'Support QR check-in as one arrival method, not a separate product loop.',
      'Let hosts mark manual arrivals when phones fail.',
      'Use checked-in attendees as the eligible pool for post-event swipes.',
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
    productLayer: EventSuccessProductLayer.eventStructure,
    stage: EventSuccessStage.opening,
    attendeePromise: 'The room gets clear social permission to talk.',
    hostPromise: 'Gives non-professional hosts a simple live guide.',
    setupSteps: [
      'Prepare a welcome line, safety note, and first prompt.',
      'Keep the script short enough to use live.',
    ],
  );

  static const microPods = EventSuccessModule(
    id: 'micro_pods',
    title: 'Micro-pods',
    type: EventSuccessModuleType.microPods,
    productLayer: EventSuccessProductLayer.assignments,
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
    title: 'Live prompts',
    type: EventSuccessModuleType.socialMissions,
    productLayer: EventSuccessProductLayer.conversation,
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
    productLayer: EventSuccessProductLayer.assignments,
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
      ActivityKind.pickleball,
      ActivityKind.pubQuiz,
      ActivityKind.dinner,
      ActivityKind.singlesMixer,
    },
    riskControls: [
      'Do not use timed rotations for movement-heavy events unless there is a pause.',
    ],
  );

  static const liveReveal = EventSuccessModule(
    id: 'live_reveal',
    title: 'Live reveal',
    type: EventSuccessModuleType.liveReveal,
    productLayer: EventSuccessProductLayer.liveReveal,
    stage: EventSuccessStage.activity,
    attendeePromise:
        'The next assignment lands as a shared reveal, not a buried schedule.',
    hostPromise:
        'Runs countdowns, clues, and round-by-round reveal control from the live plan.',
    requiresLivePhoneUse: true,
    recommendedFor: {
      ActivityKind.pickleball,
      ActivityKind.pubQuiz,
      ActivityKind.dinner,
      ActivityKind.singlesMixer,
    },
    setupSteps: [
      'Generate or edit assignments before starting the first reveal.',
      'Use the saved countdown to create a synchronized room moment.',
      'Reveal only the current round so the next transition still has tension.',
    ],
    riskControls: [
      'Frame compatibility clues as conversation context, not certainty.',
      'Do not expose normal post-event swipe targets to hosts.',
    ],
  );

  static const compatibilityQuestionnaire = EventSuccessModule(
    id: 'compatibility_questionnaire',
    title: 'Match clue questions',
    type: EventSuccessModuleType.compatibilityQuestionnaire,
    productLayer: EventSuccessProductLayer.compatibility,
    stage: EventSuccessStage.before,
    attendeePromise: 'Matching moments have a reason beyond looks.',
    hostPromise:
        'Creates reveal clues and optional pairing context without promising chemistry.',
    enabledByDefault: false,
    setupSteps: [
      'Ask fewer than ten questions in the first version.',
      'Tie questions to the event vibe, not a permanent personality score.',
      'Explain compatibility as conversation context, not destiny.',
    ],
    riskControls: [
      'Avoid implying Catch can predict chemistry.',
      'Do not block organic interaction before the reveal.',
    ],
  );

  static const wingmanRequests = EventSuccessModule(
    id: 'wingman_requests',
    title: 'Wingman requests',
    type: EventSuccessModuleType.wingmanRequests,
    productLayer: EventSuccessProductLayer.hostFacilitation,
    stage: EventSuccessStage.mixing,
    attendeePromise:
        'Ask the host for help with a specific introduction while the event is still live.',
    hostPromise:
        'Shows only explicit, consented requests so the host can create natural introductions.',
    setupSteps: [
      'Open host-assisted requests after check-in or attendance confirmation.',
      'Limit candidates to compatible checked-in attendees.',
      'Use requests while the room is still active.',
    ],
    riskControls: [
      'Show hosts only requests where the attendee explicitly opted in.',
      'Do not notify the requested attendee automatically.',
      'Respect blocks, reports, and profile visibility settings.',
    ],
  );

  static const contextualOpeners = EventSuccessModule(
    id: 'contextual_openers',
    title: 'Post-match openers',
    type: EventSuccessModuleType.contextualOpeners,
    productLayer: EventSuccessProductLayer.conversation,
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
    title: 'Private feedback',
    type: EventSuccessModuleType.decomposedFeedback,
    productLayer: EventSuccessProductLayer.hostCoach,
    stage: EventSuccessStage.after,
    attendeePromise: 'Feedback is specific and private.',
    hostPromise:
        'Separates welcome, balance, structure, safety, and chemistry.',
    setupSteps: [
      'Ask short dimension-level questions after the event.',
      'Use private summaries before drawing public conclusions.',
    ],
  );

  static const hostAnalytics = EventSuccessModule(
    id: 'host_analytics',
    title: 'Host recap',
    type: EventSuccessModuleType.hostAnalytics,
    productLayer: EventSuccessProductLayer.hostCoach,
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
    title: 'Safety layer',
    type: EventSuccessModuleType.safetyControls,
    productLayer: EventSuccessProductLayer.safety,
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
    liveReveal,
    compatibilityQuestionnaire,
    wingmanRequests,
    contextualOpeners,
    decomposedFeedback,
    hostAnalytics,
    safetyControls,
  ];

  static Map<EventSuccessProductLayer, List<EventSuccessModule>>
  get allByProductLayer {
    final grouped = <EventSuccessProductLayer, List<EventSuccessModule>>{};
    for (final layer in EventSuccessProductLayer.values) {
      final modules = all
          .where((module) => module.productLayer == layer)
          .toList(growable: false);
      if (modules.isNotEmpty) grouped[layer] = modules;
    }
    return grouped;
  }

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

  static const wingmanRequestRate = EventSuccessMetric(
    id: 'wingman_requests_rate',
    label: 'Wingman request rate',
    description: 'Share of checked-in attendees who asked the host for help.',
    target: 'Use as a live facilitation signal, not a success target.',
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
    target: 'Use private coaching before public host-quality labels.',
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
    wingmanRequestRate,
    mutualMatchRate,
    chatStartRate,
    dimensionRatings,
    repeatAttendance,
  ];
}

abstract final class EventSuccessPlaybookLibrary {
  static const socialRun = EventSuccessPlaybook(
    id: 'social_run_light',
    title: 'Social Event Lite',
    activityType: ActivityKind.socialRun,
    socialIntensity: EventSocialIntensity.light,
    summary:
        'An event-first format that adds arrival structure, pace pods, optional prompts, and post-event swipe follow-up.',
    attendeePromise:
        'You can run naturally, meet people at your pace, and follow up privately afterward.',
    hostPromise:
        'Use check-in, pace pods, and a short cooldown prompt without turning the event into speed dating.',
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
      EventSuccessModuleCatalog.compatibilityQuestionnaire,
      EventSuccessModuleCatalog.socialMissions,
      EventSuccessModuleCatalog.wingmanRequests,
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
        hostInstruction: 'Keep pods visible and avoid mid-event phone use.',
        attendeeExperience: 'Event with a small group that matches your pace.',
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
        stage: EventSuccessStage.closing,
        title: 'Host-help last call',
        durationMinutes: 3,
        hostInstruction:
            'Invite checked-in attendees to ask for help with one natural introduction.',
        attendeeExperience:
            'Ask the host for help while there is still time to be introduced.',
        moduleIds: ['wingman_requests'],
      ),
    ],
    metrics: EventSuccessMetricCatalog.core,
    antiPatterns: [
      'Do not interrupt the actual event with phone-heavy prompts.',
      'Do not make one-to-one romantic pairing the headline for beginner events.',
      'Do not publish attendee interest unless it is mutual.',
    ],
    iterationQuestions: [
      'Did pace pods improve first conversations?',
      'Did cooldown prompts feel useful or awkward?',
      'Did host-help requests create useful live introductions?',
    ],
    wiringNotes: [
      'Could reuse booking and attendance once approved.',
      'Should not change current event booking until check-in behavior is validated.',
    ],
  );

  static const pickleball = EventSuccessPlaybook(
    id: 'pickleball_rotations',
    title: 'Pickleball Partner Rotations',
    activityType: ActivityKind.pickleball,
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
      EventSuccessModuleCatalog.compatibilityQuestionnaire,
      EventSuccessModuleCatalog.guidedRotations,
      EventSuccessModuleCatalog.liveReveal,
      EventSuccessModuleCatalog.socialMissions,
      EventSuccessModuleCatalog.wingmanRequests,
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
        moduleIds: ['host_script', 'safety_controls', 'live_reveal'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.activity,
        title: 'Timed partner rounds',
        durationMinutes: 50,
        hostInstruction: 'Advance rotations and handle sit-outs fairly.',
        attendeeExperience:
            'Play with several people at a matched skill level.',
        moduleIds: ['guided_rotations', 'live_reveal'],
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
    activityType: ActivityKind.pubQuiz,
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
      EventSuccessModuleCatalog.compatibilityQuestionnaire,
      EventSuccessModuleCatalog.liveReveal,
      EventSuccessModuleCatalog.socialMissions,
      EventSuccessModuleCatalog.wingmanRequests,
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
        moduleIds: ['qr_check_in', 'micro_pods', 'live_reveal'],
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
        title: 'Host-help last call',
        durationMinutes: 4,
        hostInstruction:
            'Offer to help with one introduction before people leave.',
        attendeeExperience:
            'Ask the host for help while the room is still together.',
        moduleIds: ['wingman_requests'],
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

  static const dinner = EventSuccessPlaybook(
    id: 'dinner_table_mixer',
    title: 'Dinner Table Mixer',
    activityType: ActivityKind.dinner,
    socialIntensity: EventSocialIntensity.structured,
    summary:
        'A seated format that uses table assignments, optional course changes, prompts, and a private follow-up loop.',
    attendeePromise:
        'You know where to sit, who to start with, and how to follow up without public pressure.',
    hostPromise:
        'Balance tables, reveal seating moments, and keep conversation moving without over-facilitating dinner.',
    capacity: EventCapacityGuidance(
      min: 12,
      max: 48,
      rationale: 'Table formats need enough mix while staying host-manageable.',
    ),
    modules: [
      EventSuccessModuleCatalog.crowdBalance,
      EventSuccessModuleCatalog.checkIn,
      EventSuccessModuleCatalog.hostScript,
      EventSuccessModuleCatalog.compatibilityQuestionnaire,
      EventSuccessModuleCatalog.guidedRotations,
      EventSuccessModuleCatalog.liveReveal,
      EventSuccessModuleCatalog.socialMissions,
      EventSuccessModuleCatalog.wingmanRequests,
      EventSuccessModuleCatalog.contextualOpeners,
      EventSuccessModuleCatalog.decomposedFeedback,
      EventSuccessModuleCatalog.hostAnalytics,
      EventSuccessModuleCatalog.safetyControls,
    ],
    runOfShow: [
      EventRunOfShowStep(
        stage: EventSuccessStage.arrival,
        title: 'Check in and seating reveal',
        durationMinutes: 12,
        hostInstruction:
            'Confirm arrivals and send attendees to their first table.',
        attendeeExperience: 'Know the first table and who to start with.',
        moduleIds: ['qr_check_in', 'live_reveal'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.opening,
        title: 'Welcome and table prompt',
        durationMinutes: 4,
        hostInstruction: 'Set the tone and give one easy table prompt.',
        attendeeExperience: 'Have a natural first line at the table.',
        moduleIds: ['host_script', 'social_missions', 'safety_controls'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.activity,
        title: 'Course or seat change',
        durationMinutes: 30,
        hostInstruction:
            'Only rotate when the dinner format has a planned course or seat-change moment.',
        attendeeExperience: 'Meet a new table without managing logistics.',
        moduleIds: ['guided_rotations', 'live_reveal'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.closing,
        title: 'Wrap and host help',
        durationMinutes: 5,
        hostInstruction:
            'Offer help with one introduction before people leave the table format.',
        attendeeExperience:
            'Ask the host for help with a natural introduction before leaving.',
        moduleIds: ['wingman_requests'],
      ),
    ],
    metrics: EventSuccessMetricCatalog.core,
    antiPatterns: [
      'Do not make people move tables without a clear course or transition.',
      'Do not expose compatibility answers to hosts or tablemates.',
      'Do not make the table plan feel like a verdict on chemistry.',
    ],
    iterationQuestions: [
      'Did the seating plan create balanced conversation?',
      'Did table changes feel energizing or disruptive?',
      'Did attendees follow up after the dinner?',
    ],
    wiringNotes: [
      'Table assignment generation should eventually become a dedicated assignment engine; V1 can use host-reviewed structure and reveal controls.',
    ],
  );

  static const hostLedSocial = EventSuccessPlaybook(
    id: 'host_led_social',
    title: 'Host-led Social',
    activityType: ActivityKind.openActivity,
    socialIntensity: EventSocialIntensity.light,
    summary:
        'A simple wrapper for classes, bar crawls, open activities, and host-led formats where the activity stays primary.',
    attendeePromise:
        'The event stays natural, with enough structure to arrive, talk, and follow up.',
    hostPromise:
        'Use check-in, a short script, prompts, wingman requests, feedback, and coaching without forcing rotations.',
    capacity: EventCapacityGuidance(
      min: 6,
      max: 80,
      rationale: 'Flexible formats need light defaults that can scale.',
    ),
    modules: [
      EventSuccessModuleCatalog.crowdBalance,
      EventSuccessModuleCatalog.checkIn,
      EventSuccessModuleCatalog.hostScript,
      EventSuccessModuleCatalog.compatibilityQuestionnaire,
      EventSuccessModuleCatalog.microPods,
      EventSuccessModuleCatalog.socialMissions,
      EventSuccessModuleCatalog.guidedRotations,
      EventSuccessModuleCatalog.liveReveal,
      EventSuccessModuleCatalog.wingmanRequests,
      EventSuccessModuleCatalog.contextualOpeners,
      EventSuccessModuleCatalog.decomposedFeedback,
      EventSuccessModuleCatalog.hostAnalytics,
      EventSuccessModuleCatalog.safetyControls,
    ],
    runOfShow: [
      EventRunOfShowStep(
        stage: EventSuccessStage.arrival,
        title: 'Check in',
        durationMinutes: 10,
        hostInstruction: 'Confirm arrivals and keep the room easy to enter.',
        attendeeExperience: 'Arrive and know the host has you checked in.',
        moduleIds: ['qr_check_in'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.opening,
        title: 'Welcome',
        durationMinutes: 3,
        hostInstruction:
            'Explain the format, safety expectations, and social permission.',
        attendeeExperience:
            'Know what is happening and that talking is welcome.',
        moduleIds: ['host_script', 'safety_controls'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.mixing,
        title: 'Prompted pause',
        durationMinutes: 8,
        hostInstruction:
            'Use one prompt at a natural pause, not during the core activity.',
        attendeeExperience:
            'Get one easy reason to start another conversation.',
        moduleIds: ['social_missions'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.closing,
        title: 'Host-help last call',
        durationMinutes: 3,
        hostInstruction:
            'Offer to help attendees make one introduction before the room disperses.',
        attendeeExperience:
            'Ask the host for help with a specific person from the event.',
        moduleIds: ['wingman_requests'],
      ),
    ],
    metrics: EventSuccessMetricCatalog.core,
    antiPatterns: [
      'Do not add phone-heavy mechanics to class or open formats by default.',
      'Do not imply compatibility scoring is part of every activity.',
      'Do not show assignment controls unless the host opts into structure.',
    ],
    iterationQuestions: [
      'Did the host script make the format clearer?',
      'Did prompts feel natural at the pause points?',
      'Did host-help requests create more live introductions?',
    ],
    wiringNotes: [
      'This playbook is the fallback for activities whose core unit is the whole group.',
    ],
  );

  static const algorithmicMixer = EventSuccessPlaybook(
    id: 'algorithmic_mixer_reveal',
    title: 'Singles Mixer',
    activityType: ActivityKind.singlesMixer,
    socialIntensity: EventSocialIntensity.algorithmic,
    summary:
        'A mixer format with short questions, clues, reveal moments, host help, and explanations.',
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
      EventSuccessModuleCatalog.liveReveal,
      EventSuccessModuleCatalog.socialMissions,
      EventSuccessModuleCatalog.wingmanRequests,
      EventSuccessModuleCatalog.contextualOpeners,
      EventSuccessModuleCatalog.decomposedFeedback,
      EventSuccessModuleCatalog.hostAnalytics,
      EventSuccessModuleCatalog.safetyControls,
    ],
    runOfShow: [
      EventRunOfShowStep(
        stage: EventSuccessStage.before,
        title: 'Quick questions',
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
        attendeeExperience: 'Meet people before seeing suggested matches.',
        moduleIds: ['guided_rotations', 'live_reveal', 'social_missions'],
      ),
      EventRunOfShowStep(
        stage: EventSuccessStage.closing,
        title: 'Host-help and openers',
        durationMinutes: 5,
        hostInstruction:
            'Use compatibility as conversation context and offer help with one introduction.',
        attendeeExperience:
            'Ask for host help while the room is live, then use shared context after matching.',
        moduleIds: ['wingman_requests'],
      ),
    ],
    metrics: EventSuccessMetricCatalog.core,
    antiPatterns: [
      'Do not sell compatibility as a guarantee of spark.',
      'Do not reveal too early; people should meet before match framing.',
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
    dinner,
    hostLedSocial,
    algorithmicMixer,
  ];

  static Iterable<EventSuccessPlaybook> forActivity(ActivityKind type) =>
      all.where((playbook) => playbook.activityType == type);

  static EventSuccessPlaybook byIdOrDefault(String id) =>
      all.firstWhere((playbook) => playbook.id == id, orElse: () => socialRun);

  static EventSuccessPlaybook recommendedFor({
    required ActivityKind activityType,
    EventSocialIntensity? preferredIntensity,
  }) {
    final matches = forActivity(activityType).toList();
    if (matches.isEmpty) {
      final id = activityType.defaultPlaybookId;
      if (id != null) return byIdOrDefault(id);
      return hostLedSocial;
    }
    if (preferredIntensity == null) return matches.first;
    return matches.firstWhere(
      (playbook) => playbook.socialIntensity == preferredIntensity,
      orElse: () => matches.first,
    );
  }
}
