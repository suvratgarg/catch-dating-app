import 'package:catch_dating_app/public_profile/domain/profile_insights.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/user_profile/domain/profile_prompts.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

typedef ProfileCardFact = ({IconData icon, String text});
typedef ProfileCardPhoto = ({String url, PhotoPromptAnswer? prompt});

class ProfileCardContent {
  const ProfileCardContent({
    required this.primaryPhoto,
    required this.additionalPhotos,
    required this.attributes,
    required this.lifestyle,
    required this.profilePrompts,
    required this.insights,
  });

  factory ProfileCardContent.fromProfile(
    PublicProfile profile, {
    UserProfile? viewerProfile,
    String? sharedRunTitle,
  }) {
    final photos = profile.effectiveProfilePhotos;
    final occupation = _trimToNull(profile.occupation);
    final company = _trimToNull(profile.company);

    final attributes = <ProfileCardFact>[
      if (profile.height != null)
        (icon: Icons.straighten_rounded, text: '${profile.height} cm'),
      if (occupation != null)
        (
          icon: Icons.work_outline_rounded,
          text: company != null ? '$occupation at $company' : occupation,
        ),
      if (profile.education != null)
        (icon: Icons.school_outlined, text: profile.education!.label),
      if (profile.religion != null)
        (icon: Icons.brightness_3_outlined, text: profile.religion!.label),
      if (profile.languages.isNotEmpty)
        (
          icon: Icons.translate_rounded,
          text: profile.languages.map((language) => language.label).join(', '),
        ),
    ];

    final lifestyle = <ProfileCardFact>[
      if (profile.drinking != null)
        (icon: Icons.local_bar_outlined, text: profile.drinking!.label),
      if (profile.smoking != null)
        (icon: Icons.smoke_free_rounded, text: profile.smoking!.label),
      if (profile.workout != null)
        (icon: Icons.fitness_center_rounded, text: profile.workout!.label),
      if (profile.diet != null)
        (icon: Icons.eco_outlined, text: profile.diet!.label),
      if (profile.children != null)
        (icon: Icons.child_friendly_outlined, text: profile.children!.label),
    ];

    final additionalPhotos = photos.indexed
        .skip(1)
        .map((photo) => (url: photo.$2.url, prompt: photo.$2.prompt))
        .toList(growable: false);

    return ProfileCardContent(
      primaryPhoto: photos.firstOrNull == null
          ? null
          : (url: photos.first.url, prompt: photos.first.prompt),
      additionalPhotos: additionalPhotos,
      attributes: attributes,
      lifestyle: lifestyle,
      profilePrompts: normalizeProfilePromptAnswers(profile.profilePrompts),
      insights: ProfileCardInsights.fromProfile(
        profile,
        viewerProfile: viewerProfile,
        sharedRunTitle: sharedRunTitle,
      ),
    );
  }

  final ProfileCardPhoto? primaryPhoto;
  final List<ProfileCardPhoto> additionalPhotos;
  final List<ProfileCardFact> attributes;
  final List<ProfileCardFact> lifestyle;
  final List<ProfilePromptAnswer> profilePrompts;
  final ProfileCardInsights insights;

  String? get primaryPhotoUrl => primaryPhoto?.url;

  bool get hasProfilePrompts => profilePrompts.isNotEmpty;
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
