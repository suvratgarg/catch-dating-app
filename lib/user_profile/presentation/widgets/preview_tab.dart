import 'package:catch_dating_app/public_profile/domain/public_profile.dart';
import 'package:catch_dating_app/swipes/presentation/profile_surface.dart';
import 'package:flutter/material.dart';

class PreviewTab extends StatelessWidget {
  const PreviewTab({
    super.key,
    required this.profile,
    this.scrollController,
    this.onLeadingOverscroll,
  });

  final PublicProfile profile;
  final ScrollController? scrollController;
  final ValueChanged<double>? onLeadingOverscroll;

  @override
  Widget build(BuildContext context) {
    return ProfileSurface(
      profile: profile,
      mode: ProfileSurfaceMode.preview,
      scrollController: scrollController,
      onLeadingOverscroll: onLeadingOverscroll,
    );
  }
}
