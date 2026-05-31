import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card_content.dart';
import 'package:catch_dating_app/swipes/presentation/profile_redesign/catch_profile_view.dart';
import 'package:catch_dating_app/swipes/presentation/profile_redesign/profile_view_mapper.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_reaction_controls.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

enum ProfileSurfaceMode { catches, preview, publicProfile }

/// The single shared profile shell. Renders the flagship [CatchProfileView] for
/// all three modes; only [ProfileSurfaceMode.catches] is reactable (per-section
/// like + comment), so preview / public profile read calm and affordance-free.
class ProfileSurface extends StatelessWidget {
  const ProfileSurface({
    super.key,
    required this.profile,
    this.mode = ProfileSurfaceMode.preview,
    this.scrollController,
    this.scrollPhysics,
    this.onLeadingOverscroll,
    this.bottomPadding = CatchSpacing.s6,
    this.onReact,
    this.viewerProfile,
    this.sharedRunTitle,
  });

  final PublicProfile profile;
  final ProfileSurfaceMode mode;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final ValueChanged<double>? onLeadingOverscroll;
  final double bottomPadding;
  final ProfileReactionCallback? onReact;
  final UserProfile? viewerProfile;
  final String? sharedRunTitle;

  @override
  Widget build(BuildContext context) {
    final effectiveOnReact = mode == ProfileSurfaceMode.catches
        ? onReact
        : null;

    final content = ProfileCardContent.fromProfile(
      profile,
      viewerProfile: viewerProfile,
      sharedRunTitle: sharedRunTitle,
    );
    final view = profileViewFromCardContent(
      content,
      name: profile.name,
      age: profile.age,
      running: profile.activityPreferences.running,
      kicker: _kicker(sharedRunTitle),
      metaLine: _metaLine(profile),
    );

    return Semantics(
      label: 'Profile of ${profile.name}, ${profile.age}',
      hint: _semanticHint(mode),
      child: CatchProfileView(
        data: view,
        onReact: effectiveOnReact,
        scrollController: scrollController,
        scrollPhysics: scrollPhysics,
        onLeadingOverscroll: onLeadingOverscroll,
        bottomPadding: bottomPadding,
      ),
    );
  }
}

String? _kicker(String? sharedRunTitle) {
  final title = sharedRunTitle?.trim();
  if (title == null || title.isEmpty) return null;
  return 'Was at · $title';
}

String? _metaLine(PublicProfile profile) {
  final parts = <String>[
    ?_trimToNull(profile.occupation),
    ?_trimToNull(profile.city),
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

String? _trimToNull(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

String _semanticHint(ProfileSurfaceMode mode) {
  return switch (mode) {
    ProfileSurfaceMode.catches =>
      'Scroll to read the full profile. Like or comment on a section, or pass with the floating close button.',
    ProfileSurfaceMode.preview =>
      'Preview how your profile appears to other runners. Scroll to read the full profile.',
    ProfileSurfaceMode.publicProfile =>
      'Scroll to read the full public profile.',
  };
}
