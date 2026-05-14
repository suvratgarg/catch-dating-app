import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_card_style.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_reaction_controls.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_section_card.dart';
import 'package:flutter/material.dart';

class ProfilePromptSection extends StatelessWidget {
  const ProfilePromptSection({
    super.key,
    required this.prompt,
    required this.answer,
    this.reactionTarget,
    this.onReact,
  });

  final String prompt;
  final String answer;
  final ProfileReactionTarget? reactionTarget;
  final ProfileReactionCallback? onReact;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return ProfileSectionCard(
      title: prompt.toUpperCase(),
      reactionTarget: reactionTarget,
      onReact: onReact,
      child: Text(
        answer,
        style: CatchTextStyles.displayS(
          context,
          color: palette.textPrimary,
        ).copyWith(height: 1.32),
      ),
    );
  }
}
