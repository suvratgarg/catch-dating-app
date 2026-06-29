import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/events/presentation/event_activity_visuals.dart';
import 'package:catch_dating_app/swipes/presentation/profile_redesign/profile_view.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_reaction_controls.dart';
import 'package:flutter/material.dart';

/// PHASE 2 — the flagship profile surface, in the locked editorial language:
/// a DARK "wow" hero on a graded photo, Archivo voice, IBM Plex Mono data,
/// proseL reading text, hairlines over boxes. Color = activity (the kicker +
/// reaction affordances borrow the meeting activity's pigment).
///
/// Pure presentation over a [ProfileView]; real data is mapped on via
/// `profileViewFromCardContent`. When [onReact] is non-null (the Catches flow)
/// every reactable section shows like + comment controls; in read-only modes
/// (profile preview, public profile) it is null and the surface is calm.
class CatchProfileView extends StatelessWidget {
  const CatchProfileView({
    super.key,
    required this.data,
    this.onReact,
    this.scrollController,
    this.scrollPhysics,
    this.onLeadingOverscroll,
    this.bottomPadding = CatchSpacing.s12,
  });

  static const scrollViewKey = ValueKey<String>('profile.surface.scroll');

  final ProfileView data;

  /// Non-null only in Catches: enables per-section like + comment.
  final ProfileReactionCallback? onReact;

  final ScrollController? scrollController;
  final ScrollPhysics? scrollPhysics;
  final ValueChanged<double>? onLeadingOverscroll;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final accent = data.kickerActivity == null
        ? null
        : ActivityPalette.of(context).forKind(data.kickerActivity!).accent;

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
            SliverToBoxAdapter(
              child: ProfileHeroWidget(
                data: data,
                accent: accent,
                onReact: onReact,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                CatchSpacing.s5,
                CatchSpacing.s7,
                CatchSpacing.s5,
                bottomPadding,
              ),
              sliver: SliverList.list(children: _body(context, accent)),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _body(BuildContext context, Color? accent) {
    final t = CatchTokens.of(context);
    final blocks = <Widget>[];
    for (var i = 0; i < data.sections.length; i++) {
      if (i > 0) blocks.add(ProfileRule(color: t.line));
      blocks.add(
        ProfileSectionView(
          section: data.sections[i],
          accent: accent,
          onReact: onReact,
        ),
      );
    }
    return [
      for (final block in blocks)
        Padding(padding: CatchInsets.contentVertical, child: block),
    ];
  }
}

// ── Hero (always-dark "wow" surface) ──────────────────────────────────────────

class ProfileHeroWidget extends StatelessWidget {
  const ProfileHeroWidget({
    super.key,
    required this.data,
    this.accent,
    this.onReact,
  });

  final ProfileView data;
  final Color? accent;
  final ProfileReactionCallback? onReact;

  @override
  Widget build(BuildContext context) {
    final dark = CatchTokens.sunsetDark;
    final kickerColor = accent ?? dark.ink;
    final reaction = data.heroReaction;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(CatchRadius.profileHeroBottom),
      ),
      child: AspectRatio(
        aspectRatio: CatchAspectRatio.portrait4x5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ProfilePhoto(
              image: data.heroPhoto,
              activity: data.kickerActivity,
            ),
            ProfileHeroScrim(base: dark.bg),
            if (onReact != null && reaction != null)
              Positioned(
                top: CatchSpacing.s4,
                right: CatchSpacing.s4,
                child: ProfileReactionControls(
                  target: reaction,
                  onReact: onReact!,
                  style: ProfileReactionControlsStyle.overlay,
                ),
              ),
            Positioned(
              left: CatchSpacing.s5,
              right: CatchSpacing.s5,
              bottom: CatchSpacing.s6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (data.kicker != null)
                    Text(
                      data.kicker!.toUpperCase(),
                      style: CatchTextStyles.kicker(context, color: kickerColor),
                    ),
                  gapH8,
                  Text(
                    '${data.name}, ${data.age}',
                    style: CatchTextStyles.display(context, color: dark.ink),
                  ),
                  if (data.metaLine != null) ...[
                    gapH10,
                    Text(
                      data.metaLine!.toUpperCase(),
                      style: CatchTextStyles.numericMeta(
                        context,
                        color: dark.ink2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileHeroScrim extends StatelessWidget {
  const ProfileHeroScrim({super.key, required this.base});

  final Color base;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: const [0.0, 0.45, 0.78, 1.0],
            colors: [
              base.withValues(alpha: CatchOpacity.profileHeroScrimTop),
              base.withValues(alpha: CatchOpacity.none),
              base.withValues(alpha: CatchOpacity.profileHeroScrimMid),
              base.withValues(alpha: CatchOpacity.profileHeroScrimBottom),
            ],
          ),
        ),
      ),
    );
  }
}

/// Real photo (graded at display time) or the activity-art fallback when absent.
class ProfilePhoto extends StatelessWidget {
  const ProfilePhoto({
    super.key,
    required this.image,
    this.activity,
  });

  final ImageProvider<Object>? image;
  final ActivityKind? activity;

  @override
  Widget build(BuildContext context) {
    final photo = image;
    if (photo == null) {
      return EventActivityBackdrop(
        visual: eventActivityVisual(
          activity ?? ActivityKind.openActivity,
          context: context,
        ),
        dense: true,
        iconSize: CatchLayout.profileFallbackArtworkIconSize,
        iconOpacity: CatchOpacity.profileFallbackArtworkIcon,
        patternOpacity: CatchOpacity.profileFallbackArtworkPattern,
      );
    }
    return CatchGradedImage(
      child: Image(image: photo, fit: BoxFit.cover),
    );
  }
}

// ── Section dispatch (content + optional reaction controls) ───────────────────

class ProfileSectionView extends StatelessWidget {
  const ProfileSectionView({
    super.key,
    required this.section,
    this.accent,
    this.onReact,
  });

  final ProfileSection section;
  final Color? accent;
  final ProfileReactionCallback? onReact;

  @override
  Widget build(BuildContext context) {
    // Photo sections embed their own overlay reaction control over the image.
    if (section case final ProfilePhotoSection photo) {
      return ProfilePhotoBlock(section: photo, onReact: onReact);
    }

    final content = switch (section) {
      ProfileCompatibilitySection s => ProfileCompatibility(
        section: s,
        accent: accent,
      ),
      ProfilePromptSectionData s => ProfilePrompt(section: s),
      ProfileRunningSection s => ProfileRunning(
        section: s,
        accent: accent,
      ),
      ProfileFactsSection s => ProfileFacts(section: s),
      ProfilePhotoSection() => const SizedBox.shrink(),
    };

    final reaction = section.reaction;
    if (onReact == null || reaction == null) return content;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        content,
        gapH3,
        Align(
          alignment: Alignment.centerLeft,
          child: ProfileReactionControls(target: reaction, onReact: onReact!),
        ),
      ],
    );
  }
}

class ProfileSectionKicker extends StatelessWidget {
  const ProfileSectionKicker(
    this.label, {
    super.key,
    this.color,
  });

  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Text(
      label.toUpperCase(),
      style: CatchTextStyles.kicker(context, color: color ?? t.ink3),
    );
  }
}

// ── Compatibility ("Why you might click") ─────────────────────────────────────

class ProfileCompatibility extends StatelessWidget {
  const ProfileCompatibility({
    super.key,
    required this.section,
    this.accent,
  });

  final ProfileCompatibilitySection section;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final markColor = accent ?? t.ink;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionKicker(section.title, color: accent),
        gapH10,
        for (final reason in section.reasons)
          Padding(
            padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: CatchSpacing.s1),
                  child: Icon(
                    CatchIcons.checkRounded,
                    size: CatchIcon.sm,
                    color: markColor,
                  ),
                ),
                gapW10,
                Expanded(
                  child: Text(
                    reason,
                    style: CatchTextStyles.proseM(context, color: t.ink),
                  ),
                ),
              ],
            ),
          ),
        if (section.confidence.isNotEmpty) ...[
          gapH4,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [
              for (final signal in section.confidence) CatchBadge(label: signal),
            ],
          ),
        ],
      ],
    );
  }
}

// ── Prompt (mono question + Archivo answer) ───────────────────────────────────

class ProfilePrompt extends StatelessWidget {
  const ProfilePrompt({super.key, required this.section});

  final ProfilePromptSectionData section;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionKicker(section.question),
        gapH8,
        Text(
          section.answer,
          style: CatchTextStyles.profileAnswer(context, color: t.ink),
        ),
      ],
    );
  }
}

// ── Running identity ──────────────────────────────────────────────────────────

class ProfileRunning extends StatelessWidget {
  const ProfileRunning({
    super.key,
    required this.section,
    this.accent,
  });

  final ProfileRunningSection section;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionKicker('Running rhythm', color: accent),
        gapH10,
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: RunningStat(label: 'Pace', value: section.pace)),
            gapW12,
            Expanded(
              child: RunningStat(label: 'Distance', value: section.distance),
            ),
          ],
        ),
        if (section.reasons.isNotEmpty || section.times.isNotEmpty) ...[
          gapH10,
          Text(
            [...section.reasons, ...section.times].join('  ·  '),
            style: CatchTextStyles.supporting(context, color: t.ink2),
          ),
        ],
        if (section.tags.isNotEmpty) ...[
          gapH10,
          Wrap(
            spacing: CatchSpacing.s2,
            runSpacing: CatchSpacing.s2,
            children: [for (final tag in section.tags) CatchBadge(label: tag)],
          ),
        ],
      ],
    );
  }
}

class RunningStat extends StatelessWidget {
  const RunningStat({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: CatchTextStyles.kicker(context, color: t.ink3),
        ),
        gapH4,
        Text(value, style: CatchTextStyles.numericLarge(context, color: t.ink)),
      ],
    );
  }
}

// ── Facts (details / lifestyle: icon + text rows) ─────────────────────────────

class ProfileFacts extends StatelessWidget {
  const ProfileFacts({super.key, required this.section});

  final ProfileFactsSection section;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ProfileSectionKicker(section.title),
        gapH10,
        for (final fact in section.facts)
          Padding(
            padding: const EdgeInsets.only(bottom: CatchSpacing.s2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: CatchSpacing.micro2),
                  child: Icon(fact.icon, size: CatchIcon.control, color: t.ink3),
                ),
                gapW12,
                Expanded(
                  child: Text(
                    fact.text,
                    style: CatchTextStyles.bodyL(context, color: t.ink),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ── Standalone photo (graded) + overlay reaction control ──────────────────────

class ProfilePhotoBlock extends StatelessWidget {
  const ProfilePhotoBlock({
    super.key,
    required this.section,
    this.onReact,
  });

  final ProfilePhotoSection section;
  final ProfileReactionCallback? onReact;

  @override
  Widget build(BuildContext context) {
    final reaction = section.reaction;
    return ClipRRect(
      borderRadius: BorderRadius.circular(CatchRadius.lg),
      child: AspectRatio(
        aspectRatio: CatchAspectRatio.portrait4x5,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ProfilePhoto(image: section.image),
            if (section.caption != null && section.caption!.trim().isNotEmpty)
              Positioned(
                left: CatchSpacing.s4,
                right: CatchSpacing.s4,
                bottom: CatchSpacing.s4,
                child: PhotoCaption(text: section.caption!),
              ),
            if (onReact != null && reaction != null)
              Positioned(
                top: CatchSpacing.s3,
                right: CatchSpacing.s3,
                child: ProfileReactionControls(
                  target: reaction,
                  onReact: onReact!,
                  style: ProfileReactionControlsStyle.overlay,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PhotoCaption extends StatelessWidget {
  const PhotoCaption({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final dark = CatchTokens.sunsetDark;
    return CatchSurface(
      padding: CatchInsets.compactControlContent,
      radius: CatchRadius.sm,
      backgroundColor: dark.darkScrimFill,
      borderWidth: 0,
      child: Text(text, style: CatchTextStyles.proseM(context, color: dark.ink)),
    );
  }
}

// ── Shared bits ───────────────────────────────────────────────────────────────

class ProfileRule extends StatelessWidget {
  const ProfileRule({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: CatchStroke.hairline,
      child: ColoredBox(color: color),
    );
  }
}
