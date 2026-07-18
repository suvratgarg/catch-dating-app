part of '../event_success_activity_profile.dart';

enum EventSuccessRecommendationLevel {
  defaultOn(StructuredDomainCopy.eventSuccessRecommendationDefaultOn),
  recommended(StructuredDomainCopy.eventSuccessRecommendationRecommended),
  optional(StructuredDomainCopy.eventSuccessRecommendationOptional),
  discouraged(StructuredDomainCopy.eventSuccessRecommendationAdvanced),
  unsupported(StructuredDomainCopy.eventSuccessRecommendationUnavailable);

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
