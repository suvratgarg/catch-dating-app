import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_card_content.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_view.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/profile_readiness.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/widgets.dart';

/// Maps [ProfileCardContent] (which already projects a `PublicProfile` into
/// display content + insights) onto the section-based [ProfileView] the flagship
/// renders. Section order mirrors the handoff profile template:
/// compatibility, prompts, running, photos, details, then lifestyle.
ProfileView profileViewFromCardContent(
  ProfileCardContent content, {
  required String name,
  required int age,
  required RunningPreferences running,
  String? kicker,
  ActivityKind? kickerActivity,
  String? metaLine,
}) {
  final sections = <ProfileSection>[];

  // 1 · Compatibility / match signals.
  final confidence = content.insights.confidenceSignals
      .map((signal) => signal.label)
      .toList();
  final reasons = content.insights.compatibilityReasons
      .map((reason) => reason.label)
      .toList();
  if (confidence.isNotEmpty || reasons.isNotEmpty) {
    final title = reasons.isEmpty ? 'Profile signals' : 'Why you might click';
    sections.add(
      ProfileCompatibilitySection(
        title: title,
        reasons: reasons,
        confidence: confidence,
        reaction: _target(
          'compatibility',
          SwipeReactionTargetType.compatibility,
          title,
          [...confidence, ...reasons].join(' · '),
        ),
      ),
    );
  }

  // 2 · Prompts.
  for (final prompt in content.profilePrompts) {
    sections.add(
      ProfilePromptSectionData(
        question: prompt.displayPrompt,
        answer: prompt.answer,
        reaction: _target(
          'profile-prompt-${prompt.promptId}',
          SwipeReactionTargetType.profilePrompt,
          prompt.displayPrompt,
          prompt.answer,
        ),
      ),
    );
  }

  // 3 · Running identity.
  if (running.hasCurrentRunPreferences) {
    sections.add(
      ProfileRunningSection(
        pace: formatPaceRange(
          running.paceMinSecsPerKm,
          running.paceMaxSecsPerKm,
        ),
        distance: _distanceSummary(running),
        reasons: running.runningReasons.map((reason) => reason.label).toList(),
        times: running.preferredRunTimes.map((time) => time.label).toList(),
        tags: content.insights.emotionalRunTags
            .map((tag) => tag.label)
            .toList(),
        reaction: _target(
          'running',
          SwipeReactionTargetType.running,
          'Running rhythm',
          _runningPreview(running),
        ),
      ),
    );
  }

  final additional = content.additionalPhotos;

  // 4 · Inset photos.
  for (final (index, photo) in additional.indexed) {
    sections.add(_photoSection(name, photo, ordinal: index + 2));
  }

  // 5 · Details.
  final detailsFacts = _detailsFacts(content);
  if (detailsFacts.isNotEmpty) {
    sections.add(
      ProfileFactsSection(
        title: 'Details',
        facts: detailsFacts,
        reaction: _target(
          'details',
          SwipeReactionTargetType.details,
          'Details',
          detailsFacts.map((fact) => fact.text).join(' · '),
        ),
      ),
    );
  }

  // 6 · Lifestyle.
  if (content.lifestyle.isNotEmpty) {
    sections.add(
      ProfileFactsSection(
        title: 'Lifestyle',
        facts: content.lifestyle
            .map((fact) => ProfileFact(icon: fact.icon, text: fact.text))
            .toList(),
        reaction: _target(
          'lifestyle',
          SwipeReactionTargetType.lifestyle,
          'Lifestyle',
          content.lifestyle.map((fact) => fact.text).join(' · '),
        ),
      ),
    );
  }

  final hero = content.primaryPhoto;
  return ProfileView(
    name: name,
    age: age,
    heroPhoto: hero == null ? null : _profileImageProvider(hero.url),
    heroReaction: hero == null
        ? null
        : _target(
            'hero-photo',
            SwipeReactionTargetType.heroPhoto,
            'Main photo',
            _photoPreview(name, 'main profile photo', hero.prompt),
          ),
    kicker: kicker,
    kickerActivity: kickerActivity,
    metaLine: metaLine,
    sections: sections,
  );
}

List<ProfileFact> _detailsFacts(ProfileCardContent content) {
  return [
    if (content.relationshipGoal case final goal?)
      ProfileFact(icon: CatchIcons.favoriteBorderRounded, text: goal.label),
    for (final fact in content.attributes)
      ProfileFact(icon: fact.icon, text: fact.text),
  ];
}

ProfilePhotoSection _photoSection(
  String name,
  ProfileCardPhoto photo, {
  required int ordinal,
}) {
  final ordinalLabel = ordinal == 2
      ? 'second profile photo'
      : 'profile photo $ordinal';
  return ProfilePhotoSection(
    image: _profileImageProvider(photo.url),
    caption: photo.prompt?.displayPrompt,
    reaction: _target(
      'photo-$ordinal',
      SwipeReactionTargetType.photo,
      'Photo $ordinal',
      _photoPreview(name, ordinalLabel, photo.prompt),
    ),
  );
}

ProfileReactionTarget _target(
  String id,
  SwipeReactionTargetType type,
  String label,
  String preview,
) => ProfileReactionTarget(
  id: id,
  type: type,
  label: label,
  preview: _truncatePreview(preview),
);

ImageProvider<Object> _profileImageProvider(String url) {
  final trimmed = url.trim();
  if (trimmed.startsWith('assets/')) {
    return AssetImage(trimmed);
  }
  return NetworkImage(trimmed);
}

String _photoPreview(
  String name,
  String ordinalLabel,
  PhotoPromptAnswer? prompt,
) {
  final photoPrompt = prompt?.displayPrompt.trim();
  if (photoPrompt != null && photoPrompt.isNotEmpty) return photoPrompt;
  return "$name's $ordinalLabel";
}

String _runningPreview(RunningPreferences running) {
  final reasons = running.runningReasons
      .map((reason) => reason.label)
      .join(' · ');
  final times = running.preferredRunTimes.map((time) => time.label).join(' · ');
  return [
    'Pace ${formatPaceRange(running.paceMinSecsPerKm, running.paceMaxSecsPerKm)}',
    'Distance ${_distanceSummary(running)}',
    if (reasons.isNotEmpty) reasons,
    if (times.isNotEmpty) times,
  ].join(' · ');
}

String _distanceSummary(RunningPreferences running) {
  if (running.preferredDistances.isEmpty) return 'Any event';
  return running.preferredDistances.map((d) => d.label).take(2).join(', ');
}

String _truncatePreview(String value) {
  const maxPreviewLength = 180;
  final trimmed = value.trim();
  if (trimmed.length <= maxPreviewLength) return trimmed;
  return '${trimmed.substring(0, maxPreviewLength - 1)}…';
}
