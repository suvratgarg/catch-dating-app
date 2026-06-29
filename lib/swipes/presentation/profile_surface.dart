import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_skeleton.dart';
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
      kickerActivity: ActivityKind.socialRun,
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

/// Content-shaped placeholder for the shared public/preview profile surface.
class ProfileSurfaceSkeleton extends StatelessWidget {
  const ProfileSurfaceSkeleton({
    super.key,
    this.scrollController,
    this.scrollPhysics,
    this.onLeadingOverscroll,
    this.bottomPadding = CatchSpacing.s6,
  });

  static const scrollViewKey = ValueKey<String>('profile.surface.skeleton');

  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final ValueChanged<double>? onLeadingOverscroll;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);

    return ColoredBox(
      color: t.bg,
      child: NotificationListener<OverscrollNotification>(
        onNotification: (notification) {
          if (notification.depth == 0 &&
              notification.overscroll < 0 &&
              notification.metrics.pixels <=
                  notification.metrics.minScrollExtent) {
            onLeadingOverscroll?.call(notification.overscroll);
          }
          return false;
        },
        child: CustomScrollView(
          key: scrollViewKey,
          controller: scrollController,
          physics: scrollPhysics,
          slivers: [
            SliverToBoxAdapter(child: const ProfileSurfaceHeroSkeleton()),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                CatchSpacing.s7,
                CatchSpacing.s5,
                bottomPadding,
              ),
              sliver: SliverList.list(
                children: [
                  const ProfileSurfaceSectionSkeleton(lines: 3),
                  ProfileSurfaceRule(),
                  const ProfileSurfaceRunningSkeleton(),
                  ProfileSurfaceRule(),
                  const ProfileSurfacePhotoSkeleton(),
                  ProfileSurfaceRule(),
                  const ProfileSurfaceFactsSkeleton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSurfaceHeroSkeleton extends StatelessWidget {
  const ProfileSurfaceHeroSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(CatchRadius.profileHeroBottom),
      ),
      child: AspectRatio(
        aspectRatio: CatchAspectRatio.portrait4x5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CatchSkeleton.box(
              width: double.infinity,
              height: double.infinity,
              borderRadius: BorderRadius.zero,
            ),
            Positioned(
              left: CatchSpacing.s5,
              right: CatchSpacing.s5,
              bottom: CatchSpacing.s6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
                  gapH10,
                  CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
                  gapH8,
                  CatchSkeleton.text(width: CatchLayout.skeletonTextShortWidth),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileSurfaceSectionSkeleton extends StatelessWidget {
  const ProfileSurfaceSectionSkeleton({super.key, required this.lines});

  final int lines;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.contentVertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
          gapH10,
          CatchSkeleton.textBlock(lines: lines),
          gapH10,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (var index = 0; index < 3; index++)
                CatchSkeleton.box(
                  width: CatchLayout.skeletonTextShortWidth,
                  height: CatchLayout.countPillIconSize,
                  radius: CatchRadius.pill,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class ProfileSurfaceRunningSkeleton extends StatelessWidget {
  const ProfileSurfaceRunningSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.contentVertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
          gapH10,
          Row(
            children: [
              Expanded(
                child: CatchSkeleton.card(
                  height: CatchLayout.skeletonCardCompactHeight,
                ),
              ),
              gapW12,
              Expanded(
                child: CatchSkeleton.card(
                  height: CatchLayout.skeletonCardCompactHeight,
                ),
              ),
            ],
          ),
          gapH10,
          CatchSkeleton.text(),
        ],
      ),
    );
  }
}

class ProfileSurfacePhotoSkeleton extends StatelessWidget {
  const ProfileSurfacePhotoSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.contentVertical,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(CatchRadius.lg),
        child: AspectRatio(
          aspectRatio: CatchAspectRatio.portrait4x5,
          child: CatchSkeleton.box(
            width: double.infinity,
            height: double.infinity,
            borderRadius: BorderRadius.zero,
          ),
        ),
      ),
    );
  }
}

class ProfileSurfaceFactsSkeleton extends StatelessWidget {
  const ProfileSurfaceFactsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: CatchInsets.contentVertical,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CatchSkeleton.text(width: CatchLayout.skeletonTextTitleWidth),
          gapH10,
          for (var index = 0; index < 4; index++) ...[
            Row(
              children: [
                CatchSkeleton.box(
                  width: CatchIcon.control,
                  height: CatchIcon.control,
                  radius: CatchRadius.pill,
                ),
                gapW12,
                Expanded(child: CatchSkeleton.text()),
              ],
            ),
            if (index < 3) gapH12,
          ],
        ],
      ),
    );
  }
}

class ProfileSurfaceRule extends StatelessWidget {
  const ProfileSurfaceRule({super.key});

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Padding(
      padding: CatchInsets.contentVertical,
      child: ColoredBox(
        color: t.line,
        child: const SizedBox(height: CatchStroke.hairline),
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
