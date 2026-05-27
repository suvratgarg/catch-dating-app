import 'dart:math' as math;

import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_activity_visuals.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_models.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreConceptCategoryGrid extends StatelessWidget {
  const ExploreConceptCategoryGrid({
    super.key,
    required this.categories,
    this.onCategoryTap,
  });

  final List<ExploreConceptCategoryData> categories;
  final ValueChanged<ExploreConceptCategoryData>? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 360 ? 2 : 1;
        const spacing = CatchSpacing.s3;
        final rawTileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;
        final tileWidth = math.min(rawTileWidth, 340.0);
        return Wrap(
          alignment: WrapAlignment.center,
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final category in categories)
              SizedBox(
                width: tileWidth,
                child: AspectRatio(
                  aspectRatio: 3.15,
                  child: _CategoryTile(
                    category: category,
                    onTap: onCategoryTap == null
                        ? null
                        : () => onCategoryTap!(category),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, this.onTap});

  final ExploreConceptCategoryData category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final visual = exploreConceptActivityVisual(category.activityKind);
    return CatchSurface(
      onTap: onTap,
      radius: CatchRadius.md,
      borderColor: t.line2,
      backgroundColor: t.surface,
      elevation: CatchSurfaceElevation.card,
      clipBehavior: Clip.antiAlias,
      padding: EdgeInsets.zero,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: -30,
            right: -28,
            child: _CategoryColorCue(visual: visual),
          ),
          Positioned(
            right: CatchSpacing.s4,
            top: 0,
            bottom: 0,
            child: Icon(
              CatchIcons.forwardArrow,
              size: 14,
              color: visual.deep.withValues(alpha: 0.66),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              CatchSpacing.s4,
              CatchSpacing.s3,
              CatchSpacing.s7,
              CatchSpacing.s3,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.getFont(
                    'Instrument Serif',
                    fontSize: 26,
                    fontStyle: FontStyle.italic,
                    height: 0.98,
                    letterSpacing: 0,
                    color: t.ink,
                  ),
                ),
                gapH2,
                Text(
                  category.countLabel.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexMono(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                    color: t.ink3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryColorCue extends StatelessWidget {
  const _CategoryColorCue({required this.visual});

  final ExploreConceptActivityVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: 92,
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              visual.accent.withValues(alpha: 0.92),
              visual.deep.withValues(alpha: 0.58),
              Colors.transparent,
            ],
            stops: const [0, 0.52, 1],
          ),
          boxShadow: [
            BoxShadow(
              color: visual.accent.withValues(alpha: 0.26),
              blurRadius: 18,
              spreadRadius: 1,
            ),
          ],
        ),
      ),
    );
  }
}
