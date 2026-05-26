part of '../event_success_activity_profile.dart';

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
