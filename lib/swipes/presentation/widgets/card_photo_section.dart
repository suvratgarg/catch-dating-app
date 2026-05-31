import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/graded_image.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_card_style.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_reaction_controls.dart';
import 'package:flutter/material.dart';

class CardPhotoSection extends StatelessWidget {
  const CardPhotoSection({
    super.key,
    required this.url,
    required this.height,
    this.overlayChild,
    this.reactionTarget,
    this.onReact,
  });

  final String? url;
  final double height;
  final Widget? overlayChild;
  final ProfileReactionTarget? reactionTarget;
  final ProfileReactionCallback? onReact;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (url != null)
            GradedImage(
              child: Image.network(
                url!,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const _PhotoFallback(),
              ),
            )
          else
            const _PhotoFallback(),

          if (overlayChild != null) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.50, 1.0],
                  colors: [
                    CatchTokens.editorialDark.withValues(
                      alpha: CatchOpacity.photoScrimLow,
                    ),
                    Colors.transparent,
                    CatchTokens.editorialDark.withValues(
                      alpha: CatchOpacity.eventRecapTileScrim,
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: CatchSpacing.s5,
              right: reactionTarget == null || onReact == null
                  ? CatchSpacing.s5
                  : CatchLayout.profileCardOverlayTrailingInset,
              bottom: CatchSpacing.s7,
              child: overlayChild!,
            ),
          ],
          if (reactionTarget != null && onReact != null)
            Positioned(
              right: CatchSpacing.micro18,
              bottom: CatchSpacing.s6,
              child: ProfileReactionControls(
                target: reactionTarget!,
                onReact: onReact!,
                style: ProfileReactionControlsStyle.overlay,
                axis: Axis.vertical,
              ),
            ),
        ],
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback();

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(gradient: palette.photoPlaceholder),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              CatchIcons.personRounded,
              color: palette.textMuted.withValues(
                alpha: CatchOpacity.eventHeroMutedInk,
              ),
              size: CatchIcon.avatarLg,
            ),
            gapH8,
            Text(
              'Photo coming soon',
              style: CatchTextStyles.labelL(
                context,
                color: palette.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
