import 'package:catch_dating_app/swipes/presentation/profile_card_content.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_info_chip.dart';
import 'package:catch_dating_app/swipes/presentation/widgets/profile_section_card.dart';
import 'package:flutter/material.dart';

class ProfileRunningSection extends StatelessWidget {
  const ProfileRunningSection({super.key, required this.items});

  final List<ProfileCardFact> items;

  @override
  Widget build(BuildContext context) {
    return ProfileSectionCard(
      title: 'RUNNING',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final item in items)
            ProfileInfoChip(icon: item.icon, text: item.text),
        ],
      ),
    );
  }
}
