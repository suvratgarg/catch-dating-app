import 'package:catch_dating_app/clubs/domain/club.dart';
import 'package:catch_dating_app/clubs/shared/catch_polaroid.dart';
import 'package:catch_dating_app/clubs/shared/club_identity_atoms.dart';
import 'package:catch_dating_app/clubs/shared/club_transition_tags.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_badge.dart';
import 'package:catch_dating_app/core/widgets/catch_graded_image.dart';
import 'package:catch_dating_app/core/widgets/catch_network_image.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/explore/presentation/explore_screen_state.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_event_support_widgets.dart';
import 'package:catch_dating_app/explore/presentation/widgets/explore_synthetic_visual_fill.dart';
import 'package:catch_dating_app/l10n/l10n.dart';
import 'package:flutter/material.dart';

class ExploreClubPolaroidCard extends StatelessWidget {
  const ExploreClubPolaroidCard({
    super.key,
    required this.club,
    this.onClubSelected,
  });

  final Club club;
  final ValueChanged<Club>? onClubSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final isSynthetic = isSyntheticExploreClub(club);
    final state = ExploreClubCardState.from(club, l10n: context.l10n);
    final onTap = isSynthetic || onClubSelected == null
        ? null
        : () => onClubSelected!(club);
    final card = CatchPolaroid(
      onTap: onTap,
      paddingKey: const ValueKey('explore-club-polaroid-padding'),
      media: ExploreClubCover(club: club),
      mediaOverlay: Positioned(
        top: CatchSpacing.s3,
        right: CatchSpacing.s3,
        child: CatchBadge.solid(label: state.memberCountLabel),
      ),
      caption: state.caption,
      captionColor: t.ink3,
      title: state.title,
      subtitle: state.supportingLabel,
      showArrow: onTap != null,
      footer: Row(
        children: [
          Expanded(child: ExploreClubTags(state: state)),
          gapW10,
          ExploreMonoLabel(state.ratingReviewLabel, color: t.ink3),
        ],
      ),
    );
    final content = isSynthetic
        ? card
        : Hero(
            tag: clubInteractionHeroTag(club.id),
            transitionOnUserGestures: true,
            child: Material(color: Colors.transparent, child: card),
          );
    return Semantics(
      container: true,
      button: onTap != null,
      label: state.semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(child: content),
    );
  }
}

class ExploreFeedClubRow extends StatelessWidget {
  const ExploreFeedClubRow({
    super.key,
    required this.club,
    this.onClubSelected,
  });

  final Club club;
  final ValueChanged<Club>? onClubSelected;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    final palette = ClubCoverVisualPalette.forClub(context, club);
    final isSynthetic = isSyntheticExploreClub(club);
    final state = ExploreClubCardState.from(club, l10n: context.l10n);
    final onTap = isSynthetic || onClubSelected == null
        ? null
        : () => onClubSelected!(club);
    final card = CatchSurface(
      onTap: onTap,
      radius: CatchRadius.md,
      borderColor: t.line2,
      elevation: CatchSurfaceElevation.card,
      padding: CatchInsets.content,
      child: Row(
        children: [
          SizedBox.square(
            // Fixed compact cover thumbnail (not scaling media). A bounded box
            // gives the cover determinate constraints — an AspectRatio here gets
            // unbounded width (Row) and height (SliverList) and cannot lay out.
            dimension: CatchLayout.clubCoverThumbnailExtent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(
                CatchLayout.clubCoverCompactMediaRadius,
              ),
              child: ExploreClubCover(club: club, compact: true),
            ),
          ),
          gapW14,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ExploreMonoLabel(state.rowKicker, color: palette.accent),
                gapH4,
                Text(
                  state.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.clubDisplay(context, size: 27),
                ),
                gapH4,
                Text(
                  state.supportingLabel,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: CatchTextStyles.supporting(context, color: t.ink2),
                ),
                gapH4,
                ExploreMonoLabel(state.ratingReviewLabel, color: t.ink3),
              ],
            ),
          ),
          gapW12,
          Icon(
            CatchIcons.forwardArrow,
            size: CatchIcon.md,
            color: isSynthetic
                ? t.ink3.withValues(alpha: CatchOpacity.exploreMutedAffordance)
                : t.ink3,
          ),
        ],
      ),
    );
    return Semantics(
      container: true,
      button: onTap != null,
      label: state.semanticLabel,
      onTap: onTap,
      child: ExcludeSemantics(child: card),
    );
  }
}

class ExploreClubCover extends StatelessWidget {
  const ExploreClubCover({super.key, required this.club, this.compact = false});

  final Club club;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final url = club.primaryClubPhotoUrl?.trim();
    if (url == null || url.isEmpty) {
      return ClubPolaroidArtwork(club: club, compact: compact);
    }
    return CatchGradedImage(
      child: CatchNetworkImage(
        url,
        errorBuilder: (_, _, _) =>
            ClubPolaroidArtwork(club: club, compact: compact),
      ),
    );
  }
}

class ExploreClubTags extends StatelessWidget {
  const ExploreClubTags({super.key, required this.state});

  final ExploreClubCardState state;

  @override
  Widget build(BuildContext context) {
    final t = CatchTokens.of(context);
    if (state.tags.isEmpty) {
      return ExploreMonoLabel(
        state.memberCountLabel.toUpperCase(),
        color: t.ink3,
      );
    }
    return ClubTagWrap(tags: state.tags);
  }
}
