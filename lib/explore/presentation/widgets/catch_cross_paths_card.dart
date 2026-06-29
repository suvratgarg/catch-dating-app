import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/core/theme/activity_palette.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_button.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:flutter/material.dart';

enum CatchCrossPathsVariant { postcard, photo }

/// Design-system `CrossPathsCard` (`components/explore/CrossPathsCard`): the
/// person-in-the-feed card. An Archivo invitation in the person's voice, a mono
/// attribution line, an ink CTA + hairline heart, and a graded, framed polaroid
/// of the person addressed "TO: YOU" (the `postcard` variant), or a compact
/// left-photo row (`photo`). The portrait is always graded; the no-photo
/// fallback is the activity gradient.
class CatchCrossPathsCard extends StatelessWidget {
  const CatchCrossPathsCard({
    super.key,
    required this.activityKind,
    required this.quote,
    required this.displayName,
    this.variant = CatchCrossPathsVariant.postcard,
    this.kicker,
    this.age,
    this.meta,
    this.photoUrl,
    this.cta = 'Join her there',
    this.onJoin,
    this.onLike,
  });

  final ActivityKind activityKind;
  final String quote;
  final String displayName;
  final CatchCrossPathsVariant variant;
  final String? kicker;
  final int? age;
  final String? meta;
  final String? photoUrl;
  final String cta;
  final VoidCallback? onJoin;
  final VoidCallback? onLike;

  String get _nameAge => age != null ? '$displayName, $age' : displayName;

  String? get _attribution {
    final lead = age != null ? '— $displayName, $age' : '— $displayName';
    return [lead, if (meta != null && meta!.isNotEmpty) meta].join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final activity = ActivityPalette.resolve(context, activityKind);

    if (variant == CatchCrossPathsVariant.photo) {
      return CrossPathsSurface(borderColor: t.line,
        radius: CatchRadius.md,
        clip: true,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: CatchLayout.crossPathsPhotoVariantWidth,
                child: CrossPathsPortrait(
                  activity: activity,
                  photoUrl: photoUrl,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    CatchSpacing.s4,
                    CatchSpacing.micro14,
                    CatchSpacing.s4,
                    CatchSpacing.micro14,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (kicker != null && kicker!.isNotEmpty) ...[
                        Text(
                          kicker!.toUpperCase(),
                          style: CatchTextStyles.kicker(
                            context,
                            color: activity.accent,
                          ),
                        ),
                        const SizedBox(height: CatchSpacing.micro6),
                      ],
                      Text(_nameAge, style: CatchTextStyles.titleL(context)),
                      const SizedBox(height: CatchSpacing.micro2),
                      Text(quote, style: CatchTextStyles.bodyS(context)),
                      if (meta != null && meta!.isNotEmpty) ...[
                        const SizedBox(height: CatchSpacing.micro6),
                        Text(
                          meta!.toUpperCase(),
                          style: CatchTextStyles.monoLabel(
                            context,
                            color: t.ink3,
                          ),
                        ),
                      ],
                      const SizedBox(height: CatchSpacing.s3),
                      CrossPathsCtaRow(cta: cta,
                        onJoin: onJoin,
                        onLike: onLike,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Postcard variant.
    return CrossPathsSurface(borderColor: t.line2,
      radius: CatchSpacing.micro6,
      elevation: CatchSurfaceShadow.raised,
      child: Padding(
        padding: const EdgeInsets.all(CatchSpacing.s4),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (kicker != null && kicker!.isNotEmpty) ...[
                      Text(
                        kicker!.toUpperCase(),
                        style: CatchTextStyles.kicker(
                          context,
                          color: activity.accent,
                        ),
                      ),
                      const SizedBox(height: CatchSpacing.s2),
                    ],
                    Text(quote, style: CatchTextStyles.profileAnswer(context)),
                    if (_attribution != null) ...[
                      const SizedBox(height: CatchSpacing.micro10),
                      Text(
                        _attribution!.toUpperCase(),
                        style: CatchTextStyles.monoLabel(
                          context,
                          color: t.ink3,
                        ),
                      ),
                    ],
                    const Spacer(),
                    const SizedBox(height: CatchSpacing.micro14),
                    CrossPathsCtaRow(cta: cta,
                      onJoin: onJoin,
                      onLike: onLike,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: CatchSpacing.micro14),
              ColoredBox(
                color: t.line,
                child: const SizedBox(width: CatchStroke.hairline),
              ),
              const SizedBox(width: CatchSpacing.micro14),
              SizedBox(
                width: CatchLayout.crossPathsRailColumnWidth,
                child: CrossPathsPolaroidRail(activity: activity,
                  photoUrl: photoUrl,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum CatchSurfaceShadow { card, raised }

class CrossPathsSurface extends StatelessWidget {
  const CrossPathsSurface({
    super.key,
    required this.child,
    required this.borderColor,
    required this.radius,
    this.elevation = CatchSurfaceShadow.card,
    this.clip = false,
  });

  final Widget child;
  final Color borderColor;
  final double radius;
  final CatchSurfaceShadow elevation;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final borderRadius = BorderRadius.circular(radius);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: t.surface,
        borderRadius: borderRadius,
        border: Border.all(color: borderColor),
        boxShadow: elevation == CatchSurfaceShadow.raised
            ? CatchElevation.raised
            : CatchElevation.card,
      ),
      child: clip ? ClipRRect(borderRadius: borderRadius, child: child) : child,
    );
  }
}

/// Graded portrait (photo variant left panel / fallback) — graded photo over the
/// activity gradient.
class CrossPathsPortrait extends StatelessWidget {
  const CrossPathsPortrait({super.key, required this.activity, this.photoUrl});

  final CatchActivity activity;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final url = photoUrl;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [activity.accent, activity.deep],
        ),
      ),
      child: url == null || url.isEmpty
          ? const SizedBox.expand()
          : CatchGradedImage(child: CatchNetworkImage(url)),
    );
  }
}

/// The tilted white polaroid + "TO: YOU" postal lines (postcard variant).
class CrossPathsPolaroidRail extends StatelessWidget {
  const CrossPathsPolaroidRail({
    super.key,
    required this.activity,
    this.photoUrl,
  });

  final CatchActivity activity;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Transform.rotate(
            angle: CatchLayout.crossPathsPolaroidTilt,
            child: Container(
              width: CatchLayout.crossPathsPolaroidWidth,
              height: CatchLayout.crossPathsPolaroidHeight,
              padding: const EdgeInsets.all(CatchSpacing.s1),
              decoration: BoxDecoration(
                color: t.surface,
                border: Border.all(color: t.line2),
                boxShadow: CatchElevation.card,
              ),
              child: CrossPathsPortrait(activity: activity, photoUrl: photoUrl),
            ),
          ),
        ),
        const SizedBox(height: CatchSpacing.micro14),
        Text(
          'TO: YOU',
          textAlign: TextAlign.right,
          style: CatchTextStyles.monoLabel(
            context,
            color: t.ink3,
          ).copyWith(fontSize: 8.5),
        ),
        const SizedBox(height: CatchSpacing.micro6),
        ColoredBox(
          color: t.line,
          child: const SizedBox(
            width: double.infinity,
            height: CatchStroke.hairline,
          ),
        ),
        const SizedBox(height: CatchSpacing.micro6),
        Align(
          alignment: Alignment.centerRight,
          child: FractionallySizedBox(
            widthFactor: 0.7,
            child: ColoredBox(
              color: t.line,
              child: const SizedBox(
                width: double.infinity,
                height: CatchStroke.hairline,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CrossPathsCtaRow extends StatelessWidget {
  const CrossPathsCtaRow({
    super.key,
    required this.cta,
    this.onJoin,
    this.onLike,
  });

  final String cta;
  final VoidCallback? onJoin;
  final VoidCallback? onLike;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CatchButton(label: cta, onPressed: onJoin, size: CatchButtonSize.sm),
        const SizedBox(width: CatchSpacing.s2),
        Semantics(
          button: true,
          label: 'Like',
          child: GestureDetector(
            onTap: onLike,
            child: Container(
              width: CatchLayout.crossPathsHeartExtent,
              height: CatchLayout.crossPathsHeartExtent,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: t.line2),
              ),
              child: Icon(
                CatchIcons.favoriteOutlineRounded,
                size: CatchIcon.sm,
                color: t.ink,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
