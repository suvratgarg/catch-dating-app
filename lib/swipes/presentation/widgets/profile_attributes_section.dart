import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/swipes/domain/swipe.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card_content.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_info_chip.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_reaction_controls.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_section_card.dart';
import 'package:flutter/material.dart';

class ProfileAttributesSection extends StatelessWidget {
  const ProfileAttributesSection({
    super.key,
    required this.attrs,
    this.reactionTarget,
    this.onReact,
  });

  final List<ProfileCardFact> attrs;
  final ProfileReactionTarget? reactionTarget;
  final ProfileReactionCallback? onReact;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'Details',
      reactionTarget: reactionTarget,
      onReact: onReact,
      child: Wrap(
        spacing: CatchSpacing.s2,
        runSpacing: CatchSpacing.s2,
        children: [
          for (final a in attrs) ProfileInfoChip(icon: a.icon, text: a.text),
        ],
      ),
    );
  }
}
