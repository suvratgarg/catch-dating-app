import 'package:catch_dating_app/core/theme/catch_spacing.dart';
import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/core/widgets/catch_surface.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_card_style.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_reaction_controls.dart';
import 'package:flutter/material.dart';

class ProfileSectionCard extends StatelessWidget {
  const ProfileSectionCard({
    super.key,
    required this.title,
    required this.child,
    this.margin = const EdgeInsets.fromLTRB(
      CatchSpacing.s4,
      CatchSpacing.s3,
      CatchSpacing.s4,
      CatchSpacing.micro2,
    ),
    this.reactionTarget,
    this.onReact,
  });

  final String title;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final ProfileReactionTarget? reactionTarget;
  final ProfileReactionCallback? onReact;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return CatchSurface(
      margin: margin,
      padding: const EdgeInsets.all(CatchSpacing.s4),
      backgroundColor: palette.surface,
      borderColor: palette.border,
      radius: CatchRadius.lg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: CatchTextStyles.kicker(
              context,
              color: palette.textSecondary,
            ),
          ),
          gapH10,
          child,
          if (reactionTarget != null && onReact != null) ...[
            gapH14,
            Align(
              alignment: Alignment.centerRight,
              child: ProfileReactionControls(
                target: reactionTarget!,
                onReact: onReact!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
