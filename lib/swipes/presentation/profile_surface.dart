import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_reaction_controls.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/scrollable_profile.dart';
import 'package:catch_dating_app/user_profile/domain/user_profile.dart';
import 'package:flutter/material.dart';

enum ProfileSurfaceMode { catches, preview, publicProfile }

class ProfileSurface extends StatelessWidget {
  const ProfileSurface({
    super.key,
    required this.profile,
    this.mode = ProfileSurfaceMode.preview,
    this.scrollController,
    this.onLeadingOverscroll,
    this.bottomPadding = 24,
    this.onReact,
    this.viewerProfile,
    this.sharedRunTitle,
  });

  final PublicProfile profile;
  final ProfileSurfaceMode mode;
  final ScrollController? scrollController;
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

    return Semantics(
      label: 'Profile of ${profile.name}, ${profile.age}',
      hint: _semanticHint(mode),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final viewportHeight =
              constraints.hasBoundedHeight && constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : MediaQuery.sizeOf(context).height;

          return ScrollableProfile(
            profile: profile,
            surfaceHeight: viewportHeight,
            scrollController: scrollController,
            onLeadingOverscroll: onLeadingOverscroll,
            bottomPadding: bottomPadding,
            onReact: effectiveOnReact,
            viewerProfile: viewerProfile,
            sharedRunTitle: sharedRunTitle,
          );
        },
      ),
    );
  }
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
