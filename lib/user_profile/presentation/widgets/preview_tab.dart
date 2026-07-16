import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/shared/profile_surface/profile_surface.dart';
import 'package:flutter/material.dart';

class PreviewTab extends StatelessWidget {
  const PreviewTab({
    super.key,
    required this.profile,
    this.scrollController,
    this.scrollPhysics,
    this.bottomPadding = 0,
    this.onLeadingOverscroll,
  });

  final PublicProfile profile;
  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final double bottomPadding;
  final ValueChanged<double>? onLeadingOverscroll;

  @override
  Widget build(BuildContext context) {
    return ProfileSurface(
      profile: profile,
      scrollController: scrollController,
      scrollPhysics: scrollPhysics,
      bottomPadding: bottomPadding,
      includeTerminalPadding: true,
      onLeadingOverscroll: onLeadingOverscroll,
    );
  }
}
