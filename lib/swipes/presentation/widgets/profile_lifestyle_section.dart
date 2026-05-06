import 'package:catch_dating_app/core/theme/catch_tokens.dart';
import 'package:catch_dating_app/swipes/presentation/profile_card_content.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_info_chip.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_section_card.dart';
import 'package:flutter/material.dart';

class ProfileLifestyleSection extends StatelessWidget {
  const ProfileLifestyleSection({super.key, required this.items});

  final List<ProfileCardFact> items;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'LIFESTYLE',
      child: Wrap(
        spacing: CatchSpacing.s2,
        runSpacing: CatchSpacing.s2,
        children: [
          for (final item in items)
            ProfileInfoChip(icon: item.icon, text: item.text),
        ],
      ),
    );
  }
}
