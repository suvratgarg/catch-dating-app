import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';

enum ProfileConfidenceSignalKind { completeProfile, sharedRun, easyOpeners }

enum EmotionalRunTagKind {
  morningRegular,
  eveningRunner,
  middayMiles,
  easyMiles,
  tempoEnergy,
  flexiblePace,
  fiveKRegular,
  tenKReady,
  longRunPerson,
  socialMiles,
  headspaceRunner,
  trainingEnergy,
  feelGoodMiles,
}

enum EmotionalRunTagSource { derived, selected }

enum CompatibilityReasonKind {
  sharedRun,
  relationshipGoal,
  runningReason,
  runTime,
  distance,
  pace,
  language,
  easyOpener,
}

class ProfileConfidenceSignal {
  const ProfileConfidenceSignal({required this.kind, required this.label});

  final ProfileConfidenceSignalKind kind;
  final String label;
}

class EmotionalRunTag {
  const EmotionalRunTag({
    required this.kind,
    required this.label,
    required this.source,
  });

  final EmotionalRunTagKind kind;
  final String label;
  final EmotionalRunTagSource source;
}

class CompatibilityReason {
  const CompatibilityReason({required this.kind, required this.label});

  final CompatibilityReasonKind kind;
  final String label;
}

class ProfileQualitySuggestion {
  const ProfileQualitySuggestion({required this.title, required this.detail});

  final String title;
  final String detail;
}

class ProfileQualitySummary {
  const ProfileQualitySummary({
    required this.score,
    required this.completedItems,
    required this.totalItems,
    required this.suggestions,
  });

  final int score;
  final int completedItems;
  final int totalItems;
  final List<ProfileQualitySuggestion> suggestions;

  bool get isStrong => score >= 85;
  bool get isComplete => completedItems == totalItems;
}

class ProfileCardInsights {
  const ProfileCardInsights({
    required this.quality,
    required this.confidenceSignals,
    required this.emotionalRunTags,
    required this.compatibilityReasons,
  });

  factory ProfileCardInsights.fromProfile(
    PublicProfile profile, {
    UserProfile? viewerProfile,
    String? sharedRunTitle,
  }) {
    final quality = profileQualitySummary(profile);
    return ProfileCardInsights(
      quality: quality,
      confidenceSignals: _confidenceSignals(
        profile: profile,
        quality: quality,
        sharedRunTitle: sharedRunTitle,
      ),
      emotionalRunTags: emotionalRunTagsForProfile(profile),
      compatibilityReasons: compatibilityReasonsForProfile(
        targetProfile: profile,
        viewerProfile: viewerProfile,
        sharedRunTitle: sharedRunTitle,
      ),
    );
  }

  final ProfileQualitySummary quality;
  final List<ProfileConfidenceSignal> confidenceSignals;
  final List<EmotionalRunTag> emotionalRunTags;
  final List<CompatibilityReason> compatibilityReasons;
}

ProfileQualitySummary profileQualitySummary(PublicProfile profile) {
  final profilePhotos = profile.effectiveProfilePhotos;
  final photoCount = profilePhotos.isNotEmpty
      ? profilePhotos.length
      : profile.photoUrls.where((url) => url.trim().isNotEmpty).length;
  final promptCount = normalizeProfilePromptAnswers(
    profile.profilePrompts,
  ).length;
  final nestedPhotoPrompts = [
    for (final photo in profilePhotos)
      if (photo.prompt != null) photo.prompt!,
  ];
  final captionCount = normalizePhotoPromptAnswers(
    nestedPhotoPrompts.isNotEmpty ? nestedPhotoPrompts : profile.photoPrompts,
  ).length;
  final runningDetailsComplete =
      profile.preferredDistances.isNotEmpty &&
      profile.runningReasons.isNotEmpty &&
      profile.preferredRunTimes.isNotEmpty;
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
          captionCount >= _targetPhotoCaptionCount(photoCount),
      suggestion: const ProfileQualitySuggestion(
        title: 'Caption your photos',
        detail: 'A caption turns a photo into something people can reply to.',
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

List<EmotionalRunTag> emotionalRunTagsForProfile(PublicProfile profile) {
  final tags = <EmotionalRunTag>[];

  void add(
    EmotionalRunTagKind kind,
    String label, {
    EmotionalRunTagSource source = EmotionalRunTagSource.derived,
  }) {
    if (tags.any((tag) => tag.kind == kind || tag.label == label)) return;
    tags.add(EmotionalRunTag(kind: kind, label: label, source: source));
  }

  for (final reason in profile.runningReasons) {
    switch (reason) {
      case RunReason.community:
      case RunReason.social:
        add(
          EmotionalRunTagKind.socialMiles,
          'Social miles',
          source: EmotionalRunTagSource.selected,
        );
      case RunReason.mindfulness:
        add(
          EmotionalRunTagKind.headspaceRunner,
          'Runs for headspace',
          source: EmotionalRunTagSource.selected,
        );
      case RunReason.raceTraining:
      case RunReason.challenge:
        add(
          EmotionalRunTagKind.trainingEnergy,
          'Training energy',
          source: EmotionalRunTagSource.selected,
        );
      case RunReason.fitness:
      case RunReason.weightLoss:
        add(
          EmotionalRunTagKind.feelGoodMiles,
          'Feel-good miles',
          source: EmotionalRunTagSource.selected,
        );
    }
  }

  final runTimes = profile.preferredRunTimes.toSet();
  if (runTimes.contains(PreferredRunTime.earlyMorning) ||
      runTimes.contains(PreferredRunTime.morning)) {
    add(
      EmotionalRunTagKind.morningRegular,
      'Morning regular',
      source: EmotionalRunTagSource.selected,
    );
  }
  if (runTimes.contains(PreferredRunTime.evening) ||
      runTimes.contains(PreferredRunTime.night)) {
    add(
      EmotionalRunTagKind.eveningRunner,
      'Evening runner',
      source: EmotionalRunTagSource.selected,
    );
  }
  if (runTimes.contains(PreferredRunTime.afternoon)) {
    add(
      EmotionalRunTagKind.middayMiles,
      'Midday miles',
      source: EmotionalRunTagSource.selected,
    );
  }

  final distances = profile.preferredDistances.toSet();
  if (distances.contains(PreferredDistance.marathon) ||
      distances.contains(PreferredDistance.halfMarathon)) {
    add(EmotionalRunTagKind.longRunPerson, 'Long-run person');
  } else if (distances.contains(PreferredDistance.tenK)) {
    add(EmotionalRunTagKind.tenKReady, '10K ready');
  } else if (distances.contains(PreferredDistance.fiveK)) {
    add(EmotionalRunTagKind.fiveKRegular, '5K regular');
  }

  final paceMin = profile.paceMinSecsPerKm;
  final paceMax = profile.paceMaxSecsPerKm;
  if (paceMax <= 360) {
    add(EmotionalRunTagKind.tempoEnergy, 'Tempo energy');
  } else if (paceMin >= 360) {
    add(EmotionalRunTagKind.easyMiles, 'Easy miles');
  } else if (paceMax - paceMin >= 150) {
    add(EmotionalRunTagKind.flexiblePace, 'Flexible pace');
  }

  return tags.take(4).toList(growable: false);
}

List<CompatibilityReason> compatibilityReasonsForProfile({
  required PublicProfile targetProfile,
  UserProfile? viewerProfile,
  String? sharedRunTitle,
}) {
  final reasons = <CompatibilityReason>[];
  final targetPromptCount = normalizeProfilePromptAnswers(
    targetProfile.profilePrompts,
  ).length;

  void add(CompatibilityReasonKind kind, String label) {
    if (reasons.any((reason) => reason.kind == kind || reason.label == label)) {
      return;
    }
    reasons.add(CompatibilityReason(kind: kind, label: label));
  }

  final runTitle = _trimToNull(sharedRunTitle);
  if (runTitle != null) {
    add(CompatibilityReasonKind.sharedRun, 'You met at $runTitle');
  }

  final viewer = viewerProfile;
  if (viewer == null) {
    if (targetPromptCount >= maxProfilePromptAnswers) {
      add(
        CompatibilityReasonKind.easyOpener,
        'Their prompts give you easy openers',
      );
    }
    return reasons.take(3).toList(growable: false);
  }

  if (viewer.relationshipGoal != null &&
      viewer.relationshipGoal == targetProfile.relationshipGoal) {
    add(
      CompatibilityReasonKind.relationshipGoal,
      _relationshipGoalReason(viewer.relationshipGoal!),
    );
  }

  final sharedReasons = _sharedValues(
    viewer.runningReasons,
    targetProfile.runningReasons,
  );
  if (sharedReasons.isNotEmpty) {
    add(
      CompatibilityReasonKind.runningReason,
      _runningReasonCompatibilityLabel(sharedReasons),
    );
  }

  final sharedRunTimes = _sharedRunTimeBuckets(
    viewer.preferredRunTimes,
    targetProfile.preferredRunTimes,
  );
  if (sharedRunTimes.isNotEmpty) {
    add(
      CompatibilityReasonKind.runTime,
      'You both like ${_joinLabels(sharedRunTimes)} runs',
    );
  }

  final sharedDistances = _sharedValues(
    viewer.preferredDistances,
    targetProfile.preferredDistances,
  );
  if (sharedDistances.isNotEmpty) {
    add(
      CompatibilityReasonKind.distance,
      'You both like ${_joinLabels(sharedDistances.map((distance) => distance.label))}',
    );
  }

  if (_paceRangesOverlap(
    viewer.paceMinSecsPerKm,
    viewer.paceMaxSecsPerKm,
    targetProfile.paceMinSecsPerKm,
    targetProfile.paceMaxSecsPerKm,
  )) {
    add(CompatibilityReasonKind.pace, 'Your pace ranges overlap');
  }

  final sharedLanguages = _sharedValues(
    viewer.languages,
    targetProfile.languages,
  );
  if (sharedLanguages.isNotEmpty) {
    add(
      CompatibilityReasonKind.language,
      'You both speak ${_joinLabels(sharedLanguages.map((language) => language.label))}',
    );
  }

  if (targetPromptCount >= maxProfilePromptAnswers) {
    add(
      CompatibilityReasonKind.easyOpener,
      'Their prompts give you easy openers',
    );
  }

  return reasons.take(3).toList(growable: false);
}

String _relationshipGoalReason(RelationshipGoal goal) {
  return switch (goal) {
    RelationshipGoal.friendship => 'You both want new friends',
    RelationshipGoal.unsure => 'You are both still figuring it out',
    _ => 'You are both looking for ${goal.label.toLowerCase()}',
  };
}

String _runningReasonCompatibilityLabel(List<RunReason> reasons) {
  if (reasons.length == 1) {
    return switch (reasons.single) {
      RunReason.social => 'You both run to make friends',
      RunReason.fitness => 'You both run to stay fit',
      RunReason.challenge => 'You both run to push limits',
      RunReason.community => 'You both run for community',
      RunReason.mindfulness => 'You both run for headspace',
      RunReason.weightLoss => 'You both run for fitness goals',
      RunReason.raceTraining => 'You both run for race training',
    };
  }

  return 'You both run for ${_joinLabels(reasons.map((reason) => reason.label.toLowerCase()))}';
}

List<ProfileConfidenceSignal> _confidenceSignals({
  required PublicProfile profile,
  required ProfileQualitySummary quality,
  String? sharedRunTitle,
}) {
  final signals = <ProfileConfidenceSignal>[];
  if (quality.isStrong) {
    signals.add(
      const ProfileConfidenceSignal(
        kind: ProfileConfidenceSignalKind.completeProfile,
        label: 'Complete profile',
      ),
    );
  }

  final runTitle = _trimToNull(sharedRunTitle);
  if (runTitle != null) {
    signals.add(
      ProfileConfidenceSignal(
        kind: ProfileConfidenceSignalKind.sharedRun,
        label: 'Met at $runTitle',
      ),
    );
  }

  if (normalizeProfilePromptAnswers(profile.profilePrompts).length >=
      maxProfilePromptAnswers) {
    signals.add(
      const ProfileConfidenceSignal(
        kind: ProfileConfidenceSignalKind.easyOpeners,
        label: 'Easy openers',
      ),
    );
  }

  return signals.take(2).toList(growable: false);
}

int _targetPhotoCaptionCount(int photoCount) {
  if (photoCount <= 0) return 1;
  if (photoCount == 1) return 1;
  return 2;
}

bool _paceRangesOverlap(
  int firstMin,
  int firstMax,
  int secondMin,
  int secondMax,
) {
  return firstMin <= secondMax && secondMin <= firstMax;
}

List<T> _sharedValues<T>(Iterable<T> first, Iterable<T> second) {
  final secondSet = second.toSet();
  final values = <T>[];
  for (final value in first) {
    if (secondSet.contains(value) && !values.contains(value)) {
      values.add(value);
    }
  }
  return values;
}

List<String> _sharedRunTimeBuckets(
  Iterable<PreferredRunTime> first,
  Iterable<PreferredRunTime> second,
) {
  final firstBuckets = first.map(_runTimeBucketLabel).toSet();
  final secondBuckets = second.map(_runTimeBucketLabel).toSet();
  final buckets = <String>[];
  for (final bucket in const ['morning', 'afternoon', 'evening']) {
    if (firstBuckets.contains(bucket) && secondBuckets.contains(bucket)) {
      buckets.add(bucket);
    }
  }
  return buckets;
}

String _runTimeBucketLabel(PreferredRunTime time) {
  return switch (time) {
    PreferredRunTime.earlyMorning || PreferredRunTime.morning => 'morning',
    PreferredRunTime.afternoon => 'afternoon',
    PreferredRunTime.evening || PreferredRunTime.night => 'evening',
  };
}

String _joinLabels(Iterable<String> labels) {
  final values = labels
      .where((label) => label.trim().isNotEmpty)
      .take(2)
      .toList();
  if (values.isEmpty) return '';
  if (values.length == 1) return values.single;
  return '${values.first} and ${values.last}';
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
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
