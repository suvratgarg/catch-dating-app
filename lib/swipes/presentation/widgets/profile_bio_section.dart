import 'package:catch_dating_app/core/theme/catch_text_styles.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_card_style.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_section_card.dart';
import 'package:flutter/material.dart';

class ProfileBioSection extends StatelessWidget {
  const ProfileBioSection({super.key, required this.bio});

  final String bio;

  @override
  Widget build(BuildContext context) {
    final palette = ProfileCardPalette.of(context);

    return ProfileSectionCard(
      title: 'ON A PERFECT RUN',
      child: Text(
        bio,
        style: CatchTextStyles.titleL(
          context,
          color: palette.textPrimary,
        ).copyWith(height: 1.35),
      ),
    );
  }
}
