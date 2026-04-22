import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:flutter/material.dart';

typedef ProfileCardFact = ({IconData icon, String text});

class ProfileCardContent {
  const ProfileCardContent({
    required this.primaryPhotoUrl,
    required this.additionalPhotoUrls,
    required this.attributes,
    required this.lifestyle,
    required this.bio,
  });

  factory ProfileCardContent.fromProfile(PublicProfile profile) {
    final photos = profile.photoUrls;
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

    return ProfileCardContent(
      primaryPhotoUrl: photos.firstOrNull,
      additionalPhotoUrls: photos.skip(1).toList(growable: false),
      attributes: attributes,
      lifestyle: lifestyle,
      bio: profile.bio.trim(),
    );
  }

  final String? primaryPhotoUrl;
  final List<String> additionalPhotoUrls;
  final List<ProfileCardFact> attributes;
  final List<ProfileCardFact> lifestyle;
  final String bio;

  bool get hasBio => bio.isNotEmpty;
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
