part of '../profile_insights.dart';

ProfileQualitySummary profileQualitySummary(PublicProfile profile) {
  final profilePhotos = profile.effectiveProfilePhotos;
  final photoCount = profilePhotos.length;
  final running = profile.activityPreferences.running;
  final promptCount = normalizeProfilePromptAnswers(
    profile.profilePrompts,
  ).length;
  final nestedPhotoPrompts = [
    for (final photo in profilePhotos)
      if (photo.prompt != null) photo.prompt!,
  ];
  final photoPromptCount = normalizePhotoPromptAnswers(
    nestedPhotoPrompts,
  ).length;
  final runningDetailsComplete =
      running.hasCurrentRunPreferences &&
      running.preferredDistances.isNotEmpty &&
      running.runningReasons.isNotEmpty &&
      running.preferredRunTimes.isNotEmpty;
  final hasBackgroundFact =
      profile.height != null ||
      _trimToNull(profile.occupation) != null ||
      _trimToNull(profile.company) != null ||
      profile.education != null ||
      profile.languages.isNotEmpty;
  final hasLifestyleFact =
      profile.drinking != null ||
      profile.smoking != null ||
      profile.workout != null ||
      profile.diet != null ||
      profile.children != null;

  final items = [
    _QualityItem(
      weight: 20,
      isComplete: photoCount >= 3,
      suggestion: const ProfileQualitySuggestion(
        title: 'Add 3 clear photos',
        detail:
            'A mix of face, full-body, and running/social photos gives people confidence.',
      ),
    ),
    _QualityItem(
      weight: 24,
      isComplete: promptCount >= maxProfilePromptAnswers,
      suggestion: const ProfileQualitySuggestion(
        title: 'Answer all 3 prompts',
        detail:
            'Specific prompts create the easiest openings for comments and likes.',
      ),
    ),
    _QualityItem(
      weight: 12,
      isComplete:
          photoCount > 0 &&
          photoPromptCount >= _targetPhotoPromptCount(photoCount),
      suggestion: const ProfileQualitySuggestion(
        title: 'Add photo prompts',
        detail:
            'Prompts make photos easier to react to without writing captions.',
      ),
    ),
    _QualityItem(
      weight: 12,
      isComplete: profile.relationshipGoal != null,
      suggestion: const ProfileQualitySuggestion(
        title: 'Add what you are looking for',
        detail:
            'Intent helps people decide whether starting a conversation makes sense.',
      ),
    ),
    _QualityItem(
      weight: 16,
      isComplete: runningDetailsComplete,
      suggestion: const ProfileQualitySuggestion(
        title: 'Fill out your running identity',
        detail:
            'Distance, reason, and time-of-day preferences power better compatibility signals.',
      ),
    ),
    _QualityItem(
      weight: 8,
      isComplete: hasBackgroundFact,
      suggestion: const ProfileQualitySuggestion(
        title: 'Add one background detail',
        detail:
            'Height, work, education, or languages help round out the card.',
      ),
    ),
    _QualityItem(
      weight: 8,
      isComplete: hasLifestyleFact,
      suggestion: const ProfileQualitySuggestion(
        title: 'Add one lifestyle detail',
        detail: 'Small details make the profile feel less generic.',
      ),
    ),
  ];

  final score = items
      .where((item) => item.isComplete)
      .fold<int>(0, (sum, item) => sum + item.weight)
      .clamp(0, 100);
  final suggestions = items
      .where((item) => !item.isComplete)
      .map((item) => item.suggestion)
      .take(3)
      .toList(growable: false);

  return ProfileQualitySummary(
    score: score,
    completedItems: items.where((item) => item.isComplete).length,
    totalItems: items.length,
    suggestions: suggestions,
  );
}

int _targetPhotoPromptCount(int photoCount) {
  if (photoCount <= 0) return 1;
  if (photoCount == 1) return 1;
  return 2;
}

class _QualityItem {
  const _QualityItem({
    required this.weight,
    required this.isComplete,
    required this.suggestion,
  });

  final int weight;
  final bool isComplete;
  final ProfileQualitySuggestion suggestion;
}
