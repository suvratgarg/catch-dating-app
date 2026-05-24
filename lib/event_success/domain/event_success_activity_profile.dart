import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/event_success/domain/event_success_models.dart';
import 'package:catch_dating_app/event_success/domain/event_success_playbooks.dart';
import 'package:catch_dating_app/event_success/domain/event_success_structure.dart';

enum EventSuccessRecommendationLevel {
  defaultOn('Default on'),
  recommended('Recommended'),
  optional('Optional'),
  discouraged('Advanced'),
  unsupported('Unavailable');

  const EventSuccessRecommendationLevel(this.label);

  final String label;

  bool get selectable => this != EventSuccessRecommendationLevel.unsupported;
  bool get selectedByDefault =>
      this == EventSuccessRecommendationLevel.defaultOn;
}

enum EventSuccessPhoneAvailability {
  continuous,
  plannedPauses,
  arrivalAndPostEventOnly,
  hostOnlyLive,
  noneDuringActivity,
}

enum EventSuccessRotationSuitability { none, plannedBreaks, continuousRounds }

enum EventSuccessAssignmentAlgorithm {
  none,
  pacePods,
  socialPods,
  pairRotations,
  teamBalancer,
  tableSeating,
}

enum EventSuccessCompatibilityPolicy {
  none,
  socialCohortBalance,
  mutualInterestOnly,
  questionnaireClueOnly,
}

class EventSuccessModuleRecommendation {
  const EventSuccessModuleRecommendation({
    required this.module,
    required this.level,
    required this.reason,
  });

  final EventSuccessModule module;
  final EventSuccessRecommendationLevel level;
  final String reason;

  bool get selectable => level.selectable;
  bool get selectedByDefault => level.selectedByDefault;
}

class EventSuccessActivityProfile {
  const EventSuccessActivityProfile({
    required this.activityKind,
    required this.formatLabel,
    required this.interactionModel,
    required this.playbook,
    required this.structureConfig,
    required this.phoneAvailability,
    required this.rotationSuitability,
    required this.assignmentAlgorithm,
    required this.compatibilityPolicy,
    required this.summary,
    required this.recommendations,
    this.compatibilityAffectsRankingByDefault = false,
  });

  factory EventSuccessActivityProfile.forActivity(
    ActivityKind activityKind, {
    int? targetAttendeeCount,
  }) => EventSuccessActivityProfile.forFormat(
    EventFormatSnapshot.fromActivityKind(activityKind),
    targetAttendeeCount: targetAttendeeCount,
  );

  factory EventSuccessActivityProfile.forFormat(
    EventFormatSnapshot format, {
    int? targetAttendeeCount,
  }) {
    final assignmentAlgorithm = _assignmentAlgorithmFor(format);
    final interactionModel = _effectiveInteractionModel(
      format.interactionModel,
      assignmentAlgorithm,
    );
    final compatibilityPolicy = _compatibilityPolicyFor(
      format,
      interactionModel,
    );
    final playbook = _playbookForFormat(
      format,
      interactionModel,
      compatibilityPolicy,
    );
    final structureConfig =
        EventSuccessStructureConfig.defaultForInteractionModel(
          interactionModel,
          targetAttendeeCount: targetAttendeeCount ?? _targetFor(playbook),
        );
    final levels = _levelsForFormat(
      format,
      interactionModel,
      compatibilityPolicy,
    );
    final reasons = _reasonsFor(interactionModel);
    final recommendations = <EventSuccessModuleRecommendation>[
      for (final module in playbook.modules)
        EventSuccessModuleRecommendation(
          module: module,
          level: levels[module.id] ?? EventSuccessRecommendationLevel.optional,
          reason: reasons[module.id] ?? module.hostPromise,
        ),
    ];

    return EventSuccessActivityProfile(
      activityKind: format.activityKind,
      formatLabel: format.label,
      interactionModel: interactionModel,
      playbook: playbook,
      structureConfig: structureConfig,
      phoneAvailability: _phoneAvailabilityFor(format, interactionModel),
      rotationSuitability: _rotationSuitabilityFor(format),
      assignmentAlgorithm: assignmentAlgorithm,
      compatibilityPolicy: compatibilityPolicy,
      summary: _summaryFor(interactionModel),
      recommendations: recommendations,
      compatibilityAffectsRankingByDefault:
          compatibilityPolicy ==
          EventSuccessCompatibilityPolicy.mutualInterestOnly,
    );
  }

  final ActivityKind activityKind;
  final String formatLabel;
  final EventInteractionModel interactionModel;
  final EventSuccessPlaybook playbook;
  final EventSuccessStructureConfig structureConfig;
  final EventSuccessPhoneAvailability phoneAvailability;
  final EventSuccessRotationSuitability rotationSuitability;
  final EventSuccessAssignmentAlgorithm assignmentAlgorithm;
  final EventSuccessCompatibilityPolicy compatibilityPolicy;
  final String summary;
  final List<EventSuccessModuleRecommendation> recommendations;
  final bool compatibilityAffectsRankingByDefault;

  String get defaultAttendeePrompt {
    return switch (interactionModel) {
      EventInteractionModel.pacePods =>
        'Find someone running your pace and ask what route they want to try next.',
      EventInteractionModel.pairedRotations =>
        'Find your next partner and ask what they are hoping to play next.',
      EventInteractionModel.teamRotations =>
        'Find someone on your team and ask what brought them here.',
      EventInteractionModel.seatedTable =>
        'Ask someone at your table what made them say yes to tonight.',
      EventInteractionModel.freeFormMixer =>
        'Find someone nearby and ask what answer from tonight surprised them.',
      EventInteractionModel.hostLedProgram ||
      EventInteractionModel.openFormat =>
        'Find someone near you and ask what brought them here.',
    };
  }

  Set<String> get defaultModuleIds => recommendations
      .where((recommendation) => recommendation.selectedByDefault)
      .map((recommendation) => recommendation.module.id)
      .toSet();

  Set<String> get selectableModuleIds => recommendations
      .where((recommendation) => recommendation.selectable)
      .map((recommendation) => recommendation.module.id)
      .toSet();

  bool isSelectable(String moduleId) => selectableModuleIds.contains(moduleId);

  EventSuccessModuleRecommendation? recommendationFor(String moduleId) {
    for (final recommendation in recommendations) {
      if (recommendation.module.id == moduleId) return recommendation;
    }
    return null;
  }

  List<EventSuccessModuleRecommendation> recommendationsFor(
    EventSuccessRecommendationLevel level,
  ) => recommendations
      .where((recommendation) => recommendation.level == level)
      .toList(growable: false);

  Map<EventSuccessRecommendationLevel, List<EventSuccessModuleRecommendation>>
  get recommendationsByLevel {
    final grouped =
        <
          EventSuccessRecommendationLevel,
          List<EventSuccessModuleRecommendation>
        >{};
    for (final level in EventSuccessRecommendationLevel.values) {
      final items = recommendationsFor(level);
      if (items.isNotEmpty) grouped[level] = items;
    }
    return grouped;
  }
}

EventSuccessPlaybook _playbookForFormat(
  EventFormatSnapshot format,
  EventInteractionModel interactionModel,
  EventSuccessCompatibilityPolicy compatibilityPolicy,
) {
  final id = format.defaultPlaybookId;
  if (id != null) return EventSuccessPlaybookLibrary.byIdOrDefault(id);
  return switch (interactionModel) {
    EventInteractionModel.pacePods => EventSuccessPlaybookLibrary.socialRun,
    EventInteractionModel.pairedRotations =>
      EventSuccessPlaybookLibrary.pickleball,
    EventInteractionModel.teamRotations => EventSuccessPlaybookLibrary.pubQuiz,
    EventInteractionModel.seatedTable => EventSuccessPlaybookLibrary.dinner,
    EventInteractionModel.freeFormMixer =>
      compatibilityPolicy == EventSuccessCompatibilityPolicy.mutualInterestOnly
          ? EventSuccessPlaybookLibrary.algorithmicMixer
          : EventSuccessPlaybookLibrary.hostLedSocial,
    EventInteractionModel.hostLedProgram || EventInteractionModel.openFormat =>
      EventSuccessPlaybookLibrary.hostLedSocial,
  };
}

int _targetFor(EventSuccessPlaybook playbook) =>
    ((playbook.capacity.min + playbook.capacity.max) / 2).round();

Map<String, EventSuccessRecommendationLevel> _levelsForFormat(
  EventFormatSnapshot format,
  EventInteractionModel interactionModel,
  EventSuccessCompatibilityPolicy compatibilityPolicy,
) {
  final base = <String, EventSuccessRecommendationLevel>{
    EventSuccessModuleCatalog.crowdBalance.id:
        EventSuccessRecommendationLevel.recommended,
    EventSuccessModuleCatalog.checkIn.id:
        EventSuccessRecommendationLevel.defaultOn,
    EventSuccessModuleCatalog.firstHelloCheckIn.id:
        EventSuccessRecommendationLevel.optional,
    EventSuccessModuleCatalog.hostScript.id:
        EventSuccessRecommendationLevel.defaultOn,
    EventSuccessModuleCatalog.microPods.id:
        EventSuccessRecommendationLevel.optional,
    EventSuccessModuleCatalog.socialMissions.id:
        EventSuccessRecommendationLevel.defaultOn,
    EventSuccessModuleCatalog.guidedRotations.id:
        EventSuccessRecommendationLevel.optional,
    EventSuccessModuleCatalog.liveReveal.id:
        EventSuccessRecommendationLevel.optional,
    EventSuccessModuleCatalog.compatibilityQuestionnaire.id:
        EventSuccessRecommendationLevel.recommended,
    EventSuccessModuleCatalog.wingmanRequests.id:
        EventSuccessRecommendationLevel.defaultOn,
    EventSuccessModuleCatalog.contextualOpeners.id:
        EventSuccessRecommendationLevel.defaultOn,
    EventSuccessModuleCatalog.decomposedFeedback.id:
        EventSuccessRecommendationLevel.defaultOn,
    EventSuccessModuleCatalog.hostAnalytics.id:
        EventSuccessRecommendationLevel.defaultOn,
    EventSuccessModuleCatalog.safetyControls.id:
        EventSuccessRecommendationLevel.defaultOn,
  };

  switch (interactionModel) {
    case EventInteractionModel.pacePods:
      base[EventSuccessModuleCatalog.microPods.id] =
          EventSuccessRecommendationLevel.defaultOn;
      base[EventSuccessModuleCatalog.guidedRotations.id] =
          EventSuccessRecommendationLevel.unsupported;
      base[EventSuccessModuleCatalog.liveReveal.id] =
          EventSuccessRecommendationLevel.discouraged;
    case EventInteractionModel.pairedRotations:
      base[EventSuccessModuleCatalog.firstHelloCheckIn.id] =
          EventSuccessRecommendationLevel.recommended;
      base[EventSuccessModuleCatalog.guidedRotations.id] =
          EventSuccessRecommendationLevel.defaultOn;
      base[EventSuccessModuleCatalog.liveReveal.id] =
          EventSuccessRecommendationLevel.defaultOn;
      base[EventSuccessModuleCatalog.microPods.id] =
          EventSuccessRecommendationLevel.unsupported;
    case EventInteractionModel.teamRotations:
      base[EventSuccessModuleCatalog.firstHelloCheckIn.id] =
          EventSuccessRecommendationLevel.recommended;
      base[EventSuccessModuleCatalog.microPods.id] =
          EventSuccessRecommendationLevel.defaultOn;
      base[EventSuccessModuleCatalog.liveReveal.id] =
          EventSuccessRecommendationLevel.defaultOn;
      base[EventSuccessModuleCatalog.guidedRotations.id] =
          EventSuccessRecommendationLevel.discouraged;
    case EventInteractionModel.seatedTable:
      base[EventSuccessModuleCatalog.firstHelloCheckIn.id] =
          EventSuccessRecommendationLevel.recommended;
      base[EventSuccessModuleCatalog.guidedRotations.id] =
          EventSuccessRecommendationLevel.recommended;
      base[EventSuccessModuleCatalog.liveReveal.id] =
          EventSuccessRecommendationLevel.recommended;
      base[EventSuccessModuleCatalog.microPods.id] =
          EventSuccessRecommendationLevel.discouraged;
    case EventInteractionModel.freeFormMixer:
      base[EventSuccessModuleCatalog.firstHelloCheckIn.id] =
          EventSuccessRecommendationLevel.recommended;
      base[EventSuccessModuleCatalog.guidedRotations.id] =
          EventSuccessRecommendationLevel.defaultOn;
      base[EventSuccessModuleCatalog.liveReveal.id] =
          EventSuccessRecommendationLevel.defaultOn;
      base[EventSuccessModuleCatalog.compatibilityQuestionnaire.id] =
          compatibilityPolicy ==
              EventSuccessCompatibilityPolicy.mutualInterestOnly
          ? EventSuccessRecommendationLevel.defaultOn
          : EventSuccessRecommendationLevel.recommended;
      base[EventSuccessModuleCatalog.microPods.id] =
          EventSuccessRecommendationLevel.discouraged;
    case EventInteractionModel.hostLedProgram:
      base[EventSuccessModuleCatalog.microPods.id] =
          EventSuccessRecommendationLevel.discouraged;
      base[EventSuccessModuleCatalog.guidedRotations.id] =
          EventSuccessRecommendationLevel.unsupported;
      base[EventSuccessModuleCatalog.liveReveal.id] =
          EventSuccessRecommendationLevel.unsupported;
      base[EventSuccessModuleCatalog.compatibilityQuestionnaire.id] =
          EventSuccessRecommendationLevel.optional;
    case EventInteractionModel.openFormat:
      base[EventSuccessModuleCatalog.microPods.id] =
          EventSuccessRecommendationLevel.optional;
      base[EventSuccessModuleCatalog.guidedRotations.id] =
          EventSuccessRecommendationLevel.optional;
      base[EventSuccessModuleCatalog.liveReveal.id] =
          EventSuccessRecommendationLevel.optional;
      base[EventSuccessModuleCatalog.compatibilityQuestionnaire.id] =
          EventSuccessRecommendationLevel.optional;
  }

  for (final moduleId in format.defaultModuleIds) {
    final level = base[moduleId];
    if (level != null && level != EventSuccessRecommendationLevel.unsupported) {
      base[moduleId] = EventSuccessRecommendationLevel.defaultOn;
    }
  }

  return base;
}

EventSuccessPhoneAvailability _phoneAvailabilityFor(
  EventFormatSnapshot format,
  EventInteractionModel interactionModel,
) {
  final override = _primitiveOverride(
    format,
    'phoneAvailability',
    EventSuccessPhoneAvailability.values,
  );
  if (override != null) return override;
  return switch (interactionModel) {
    EventInteractionModel.pacePods =>
      EventSuccessPhoneAvailability.arrivalAndPostEventOnly,
    EventInteractionModel.pairedRotations ||
    EventInteractionModel.teamRotations ||
    EventInteractionModel.seatedTable ||
    EventInteractionModel.freeFormMixer =>
      EventSuccessPhoneAvailability.plannedPauses,
    EventInteractionModel.hostLedProgram =>
      format.activityKind.isMovementHeavy
          ? EventSuccessPhoneAvailability.hostOnlyLive
          : EventSuccessPhoneAvailability.plannedPauses,
    EventInteractionModel.openFormat =>
      EventSuccessPhoneAvailability.hostOnlyLive,
  };
}

EventSuccessRotationSuitability _rotationSuitabilityFor(
  EventFormatSnapshot format,
) {
  final override = _primitiveOverride(
    format,
    'rotationSuitability',
    EventSuccessRotationSuitability.values,
  );
  if (override != null) return override;
  final interactionModel = format.interactionModel;
  return switch (interactionModel) {
    EventInteractionModel.pacePods ||
    EventInteractionModel.hostLedProgram ||
    EventInteractionModel.openFormat => EventSuccessRotationSuitability.none,
    EventInteractionModel.pairedRotations ||
    EventInteractionModel.freeFormMixer =>
      EventSuccessRotationSuitability.continuousRounds,
    EventInteractionModel.teamRotations || EventInteractionModel.seatedTable =>
      EventSuccessRotationSuitability.plannedBreaks,
  };
}

EventSuccessAssignmentAlgorithm _assignmentAlgorithmFor(
  EventFormatSnapshot format,
) {
  final override = _primitiveOverride(
    format,
    'assignmentAlgorithm',
    EventSuccessAssignmentAlgorithm.values,
  );
  if (override != null) return override;
  final interactionModel = format.interactionModel;
  return switch (interactionModel) {
    EventInteractionModel.pacePods => EventSuccessAssignmentAlgorithm.pacePods,
    EventInteractionModel.pairedRotations =>
      EventSuccessAssignmentAlgorithm.pairRotations,
    EventInteractionModel.teamRotations =>
      EventSuccessAssignmentAlgorithm.teamBalancer,
    EventInteractionModel.seatedTable =>
      EventSuccessAssignmentAlgorithm.tableSeating,
    EventInteractionModel.freeFormMixer =>
      EventSuccessAssignmentAlgorithm.socialPods,
    EventInteractionModel.hostLedProgram ||
    EventInteractionModel.openFormat => EventSuccessAssignmentAlgorithm.none,
  };
}

EventSuccessCompatibilityPolicy _compatibilityPolicyFor(
  EventFormatSnapshot format,
  EventInteractionModel interactionModel,
) {
  final override = _primitiveOverride(
    format,
    'compatibilityPolicy',
    EventSuccessCompatibilityPolicy.values,
  );
  if (override != null) return override;
  return switch (interactionModel) {
    EventInteractionModel.freeFormMixer =>
      format.activityKind == ActivityKind.singlesMixer
          ? EventSuccessCompatibilityPolicy.mutualInterestOnly
          : EventSuccessCompatibilityPolicy.questionnaireClueOnly,
    EventInteractionModel.teamRotations ||
    EventInteractionModel.seatedTable ||
    EventInteractionModel.pairedRotations =>
      EventSuccessCompatibilityPolicy.questionnaireClueOnly,
    EventInteractionModel.pacePods =>
      EventSuccessCompatibilityPolicy.socialCohortBalance,
    EventInteractionModel.hostLedProgram ||
    EventInteractionModel.openFormat => EventSuccessCompatibilityPolicy.none,
  };
}

EventInteractionModel _effectiveInteractionModel(
  EventInteractionModel interactionModel,
  EventSuccessAssignmentAlgorithm assignmentAlgorithm,
) {
  final mapped = switch (assignmentAlgorithm) {
    EventSuccessAssignmentAlgorithm.pacePods => EventInteractionModel.pacePods,
    EventSuccessAssignmentAlgorithm.pairRotations =>
      EventInteractionModel.pairedRotations,
    EventSuccessAssignmentAlgorithm.teamBalancer =>
      EventInteractionModel.teamRotations,
    EventSuccessAssignmentAlgorithm.tableSeating =>
      EventInteractionModel.seatedTable,
    EventSuccessAssignmentAlgorithm.socialPods =>
      EventInteractionModel.freeFormMixer,
    EventSuccessAssignmentAlgorithm.none => null,
  };
  return mapped ?? interactionModel;
}

T? _primitiveOverride<T extends Enum>(
  EventFormatSnapshot format,
  String key,
  List<T> values,
) {
  final raw = format.eventSuccessPrimitives[key];
  if (raw is! String) return null;
  final normalized = raw.trim();
  for (final value in values) {
    if (value.name == normalized) return value;
  }
  return null;
}

Map<String, String> _reasonsFor(EventInteractionModel interactionModel) {
  final common = <String, String>{
    EventSuccessModuleCatalog.crowdBalance.id:
        'Useful before publishing, but it belongs beside booking and roster decisions.',
    EventSuccessModuleCatalog.checkIn.id:
        'Arrival state is the source of truth for assignments, host help, feedback, and post-event matching.',
    EventSuccessModuleCatalog.firstHelloCheckIn.id:
        'A location-verified first hello turns arrival into permission to start one conversation.',
    EventSuccessModuleCatalog.hostScript.id:
        'A short host script gives attendees permission to talk without making the host improvise.',
    EventSuccessModuleCatalog.socialMissions.id:
        'Prompts create one easy next conversation without adding another feature surface.',
    EventSuccessModuleCatalog.wingmanRequests.id:
        'Explicit host-help requests let shy attendees ask for a natural introduction while the room is live.',
    EventSuccessModuleCatalog.contextualOpeners.id:
        'Post-match openers use event context without exposing private answers.',
    EventSuccessModuleCatalog.decomposedFeedback.id:
        'Feedback should be specific enough to improve the next event without becoming a public score.',
    EventSuccessModuleCatalog.hostAnalytics.id:
        'Hosts need a short coaching summary, not a wall of metrics.',
    EventSuccessModuleCatalog.safetyControls.id:
        'Blocks, reports, visibility, and opt-outs have to apply across every live guide surface.',
  };

  switch (interactionModel) {
    case EventInteractionModel.pacePods:
      return {
        ...common,
        EventSuccessModuleCatalog.microPods.id:
            'For runs and walks this behaves as pace or arrival grouping, not romance scoring.',
        EventSuccessModuleCatalog.guidedRotations.id:
            'Timed pair rotations interrupt a moving group and should not be shown for this format.',
        EventSuccessModuleCatalog.liveReveal.id:
            'Reveal ceremonies are usually too phone-heavy during movement, but can be used at a planned stop.',
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id:
            'Answers can support clues or follow-up, but should not dominate the event.',
      };
    case EventInteractionModel.pairedRotations:
      return {
        ...common,
        EventSuccessModuleCatalog.guidedRotations.id:
            'Racket formats naturally break into pairs, courts, and timed rounds.',
        EventSuccessModuleCatalog.liveReveal.id:
            'Countdowns and reveals turn the next court or partner into a shared moment.',
        EventSuccessModuleCatalog.microPods.id:
            'A separate pod layer competes with the court-pair structure.',
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id:
            'Optional answers can add clues or softly guide partner suggestions after safety and interest checks.',
      };
    case EventInteractionModel.teamRotations:
      return {
        ...common,
        EventSuccessModuleCatalog.microPods.id:
            'For quiz formats this is the team setup.',
        EventSuccessModuleCatalog.liveReveal.id:
            'Team reveals give the host a clear start moment without showing every future move.',
        EventSuccessModuleCatalog.guidedRotations.id:
            'Pair rotations are not the main quiz structure; keep this advanced until team reshuffles need it.',
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id:
            'Answers can help balance teams or generate clues when the host wants a more dating-forward quiz.',
      };
    case EventInteractionModel.seatedTable:
      return {
        ...common,
        EventSuccessModuleCatalog.guidedRotations.id:
            'Table or course changes can work, but only when the host intentionally designs the cadence.',
        EventSuccessModuleCatalog.liveReveal.id:
            'Table reveals are useful for anticipation, but should follow the seating plan.',
        EventSuccessModuleCatalog.microPods.id:
            'Tables already define the room structure; a separate pod toggle adds confusion.',
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id:
            'Answers are useful for seating clues and soft table placement.',
      };
    case EventInteractionModel.freeFormMixer:
      return {
        ...common,
        EventSuccessModuleCatalog.guidedRotations.id:
            'A mixer benefits from planned rounds when the host wants momentum.',
        EventSuccessModuleCatalog.liveReveal.id:
            'The countdown and reveal are the memorable ceremony for this format.',
        EventSuccessModuleCatalog.microPods.id:
            'Pods can help arrival, but should not replace the main reveal or rotation flow.',
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id:
            'This is the right format for clue questions and suggested pairings.',
      };
    case EventInteractionModel.hostLedProgram:
      return {
        ...common,
        EventSuccessModuleCatalog.microPods.id:
            'Small groups can help after class, but the activity itself is host-led.',
        EventSuccessModuleCatalog.guidedRotations.id:
            'Timed pair rotations do not fit the core class structure.',
        EventSuccessModuleCatalog.liveReveal.id:
            'Reveal ceremonies need a pod or rotation plan and are not part of the default class flow.',
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id:
            'Optional answers can support post-event context without changing the class.',
      };
    case EventInteractionModel.openFormat:
      return {
        ...common,
        EventSuccessModuleCatalog.microPods.id:
            'Use only when the host wants small arrival groups.',
        EventSuccessModuleCatalog.guidedRotations.id:
            'Use only when the host turns the open event into a structured assignment flow.',
        EventSuccessModuleCatalog.liveReveal.id:
            'Use only with selected pods or rotations.',
        EventSuccessModuleCatalog.compatibilityQuestionnaire.id:
            'Use when the host wants clues or compatibility context.',
      };
  }
}

String _summaryFor(EventInteractionModel interactionModel) {
  return switch (interactionModel) {
    EventInteractionModel.pacePods =>
      'Keep the moving event primary. Use check-in, light grouping, prompts, and follow-up without turning it into speed dating.',
    EventInteractionModel.pairedRotations =>
      'Use the natural court/pair structure: timed rounds, partner reveals, and optional compatibility clues.',
    EventInteractionModel.teamRotations =>
      'Plan around teams. Balance arrivals, reveal teams, and use prompts between rounds.',
    EventInteractionModel.seatedTable =>
      'Plan around tables. Add rotations only when the host has a clear course or seat-change cadence.',
    EventInteractionModel.freeFormMixer =>
      'Create kinetic reveal moments with countdowns, clues, and structured rounds while keeping interest private.',
    EventInteractionModel.hostLedProgram =>
      'Keep the class or program intact. Add arrival, light prompts, follow-up, and feedback around the edges.',
    EventInteractionModel.openFormat =>
      'Start with basic safety, attendance, prompt, and follow-up tools; let the host opt into structure.',
  };
}
