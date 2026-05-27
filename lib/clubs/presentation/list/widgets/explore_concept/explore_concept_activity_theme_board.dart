import 'package:catch_dating_app/activity/domain/activity_taxonomy.dart';
import 'package:catch_dating_app/clubs/presentation/list/widgets/explore_concept/explore_concept_activity_visuals.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExploreConceptActivityThemeBoard extends StatelessWidget {
  const ExploreConceptActivityThemeBoard({
    super.key,
    this.kinds = exploreConceptAllActivityKinds,
  });

  final List<ActivityKind> kinds;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columnCount = switch (constraints.maxWidth) {
          >= 920 => 4,
          >= 640 => 3,
          _ => 2,
        };
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: kinds.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columnCount,
            mainAxisSpacing: CatchSpacing.s3,
            crossAxisSpacing: CatchSpacing.s3,
            childAspectRatio: columnCount == 2 ? 1.04 : 1.18,
          ),
          itemBuilder: (context, index) {
            return _ActivityThemeTile(
              visual: exploreConceptActivityVisual(kinds[index]),
            );
          },
        );
      },
    );
  }
}

class _ActivityThemeTile extends StatelessWidget {
  const _ActivityThemeTile({required this.visual});

  final ExploreConceptActivityVisualTheme visual;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    return CatchSurface(
      padding: EdgeInsets.zero,
      radius: CatchRadius.lg,
      borderColor: t.line,
      elevation: CatchSurfaceElevation.card,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ExploreConceptActivityBackdrop(
            visual: visual,
            iconAlignment: Alignment.topRight,
            iconSize: 104,
            iconOpacity: 0.14,
            patternOpacity: 0.22,
          ),
          Positioned(
            left: CatchSpacing.s3,
            right: CatchSpacing.s3,
            bottom: CatchSpacing.s3,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.78),
                borderRadius: BorderRadius.circular(CatchRadius.md),
              ),
              child: Padding(
                padding: const EdgeInsets.all(CatchSpacing.s3),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(visual.icon, size: 18, color: visual.accent),
                        gapW6,
                        Expanded(
                          child: Text(
                            visual.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: CatchTextStyles.titleS(
                              context,
                              color: t.ink,
                            ),
                          ),
                        ),
                      ],
                    ),
                    gapH6,
                    Text(
                      visual.activityKind.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.ibmPlexMono(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0,
                        color: t.ink3,
                      ),
                    ),
                    gapH8,
                    Row(
                      children: [
                        for (final color in visual.colors)
                          Expanded(
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(color: color),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
