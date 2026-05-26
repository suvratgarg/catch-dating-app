part of '../event_success_activity_profile.dart';

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
