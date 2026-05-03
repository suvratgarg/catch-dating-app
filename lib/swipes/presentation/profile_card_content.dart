import 'package:catch_dating_app/core/format_utils.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

typedef ProfileCardFact = ({IconData icon, String text});

class ProfileCardContent {
  const ProfileCardContent({
    required this.primaryPhotoUrl,
    required this.additionalPhotoUrls,
    required this.attributes,
    required this.lifestyle,
    required this.bio,
    required this.running,
  });

  factory ProfileCardContent.fromProfile(
    PublicProfile profile, {
    LatLng? currentUserLocation,
  }) {
    final photos = profile.photoUrls;
    final occupation = _trimToNull(profile.occupation);
    final company = _trimToNull(profile.company);

    final attributes = <ProfileCardFact>[
      if (profile.city != null)
        (icon: Icons.location_on_outlined, text: profile.city!.label),
      if (currentUserLocation != null &&
          profile.latitude != null &&
          profile.longitude != null)
        (
          icon: Icons.near_me_outlined,
          text: _formatDistance(
            const Distance(roundResult: false).as(
              LengthUnit.Kilometer,
              currentUserLocation,
              LatLng(profile.latitude!, profile.longitude!),
            ),
          ),
        ),
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

    final running = <ProfileCardFact>[
      (
        icon: Icons.speed_outlined,
        text: '${formatPace(profile.paceMinSecsPerKm)}-${formatPace(profile.paceMaxSecsPerKm)} /km',
      ),
      if (profile.preferredDistances.isNotEmpty)
        (
          icon: Icons.straighten_outlined,
          text: profile.preferredDistances.map((d) => d.label).join(', '),
        ),
      if (profile.runningReasons.isNotEmpty)
        (
          icon: Icons.directions_run_outlined,
          text: profile.runningReasons.map((r) => r.label).join(', '),
        ),
    ];

    return ProfileCardContent(
      primaryPhotoUrl: photos.firstOrNull,
      additionalPhotoUrls: photos.skip(1).toList(growable: false),
      attributes: attributes,
      lifestyle: lifestyle,
      bio: profile.bio.trim(),
      running: running,
    );
  }

  final String? primaryPhotoUrl;
  final List<String> additionalPhotoUrls;
  final List<ProfileCardFact> attributes;
  final List<ProfileCardFact> lifestyle;
  final String bio;
  final List<ProfileCardFact> running;

  bool get hasBio => bio.isNotEmpty;
  bool get hasRunning => running.isNotEmpty;

  static String _formatDistance(double km) {
    if (km < 1.0) {
      return '${(km * 1000).round()} m away';
    } else if (km < 10.0) {
      return '${km.toStringAsFixed(1)} km away';
    } else {
      return '${km.round()} km away';
    }
  }
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}
